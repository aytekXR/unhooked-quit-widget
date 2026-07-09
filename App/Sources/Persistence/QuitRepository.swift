import Foundation
import StreakEngine
import SwiftData

/// E2.2 — the repository: the ONLY component that touches SwiftData contexts outside
/// trivial `@Query` lists (implementation-plan E2.2 acceptance; a CI grep enforces the
/// import boundary). Synchronous-fast writes — the local save IS the transaction
/// (architecture §9 rule 1: a slip write precedes any UI transition and never depends
/// on the network) — followed by a debounced widget-timeline reload.
@MainActor
final class QuitRepository {
    /// Failures surfaced before/instead of persisting anything.
    enum RepositoryError: Error, Equatable {
        /// A fourth active quit was requested (architecture §3: max 3, service-enforced).
        case activeQuitLimitReached
        case quitNotFound(UUID)
    }

    /// Active (non-archived) quits may never exceed this (architecture §3).
    static let activeQuitLimit = 3

    /// Trailing-debounce window for widget reloads: a burst of writes inside this window
    /// costs exactly one `reloadAllTimelines()` (freshness stays seconds — far inside
    /// the ≤60 s widget-staleness acceptance).
    static let widgetReloadDebounce: Duration = .milliseconds(500)

    private let container: ModelContainer
    private let context: ModelContext
    private let clock: any ClockProviding
    private let widgetRefresher: any WidgetRefreshing
    private let lastKnownGoodStore: LastKnownGoodStore
    private let cloud: any CloudSyncControlling
    private let appGroupDefaults: UserDefaults
    private let panicSnapshotStore: PanicSnapshotStore
    private let debounceSleep: @Sendable (Duration) async -> Void
    private var pendingReload: Task<Void, Never>?

    init(
        container: ModelContainer,
        clock: any ClockProviding,
        widgetRefresher: any WidgetRefreshing,
        lastKnownGoodStore: LastKnownGoodStore,
        cloud: any CloudSyncControlling,
        appGroupDefaults: UserDefaults,
        panicSnapshotStore: PanicSnapshotStore,
        debounceSleep: @escaping @Sendable (Duration) async -> Void = { try? await Task.sleep(for: $0) }
    ) {
        self.container = container
        self.context = container.mainContext
        self.clock = clock
        self.widgetRefresher = widgetRefresher
        self.lastKnownGoodStore = lastKnownGoodStore
        self.cloud = cloud
        self.appGroupDefaults = appGroupDefaults
        self.panicSnapshotStore = panicSnapshotStore
        self.debounceSleep = debounceSleep
    }

    // MARK: - Reads

    /// All quits the user has not archived, in widget-selector order. This is the query
    /// that justifies `#Index<Quit>([\.isArchived, \.sortIndex])` (architecture §4).
    /// The in-memory id tiebreak keeps the order TOTAL: the dedupe merge resolves a
    /// duplicate group's sortIndex with min, which can land on an existing quit's
    /// value — widget selectors bind by position, so ties must not flap.
    func activeQuits() throws -> [Quit] {
        try context.fetch(
            FetchDescriptor<Quit>(
                predicate: #Predicate { !$0.isArchived },
                sortBy: [SortDescriptor(\.sortIndex)]
            )
        )
        .sorted { ($0.sortIndex, $0.id.uuidString) < ($1.sortIndex, $1.id.uuidString) }
    }

    /// The streak readout for one quit, routed through the clock-integrity guard with
    /// the device's persisted last-known-good reading — the ADR-7 reboot cap, end to
    /// end: a reboot + forward-set wall can neither read `.normal` nor inflate.
    func streakValue(for quitID: UUID) throws -> StreakValue {
        let quit = try fetchQuit(quitID)
        let now = clock.now
        let reading = clock.monotonicNow
        let lastKnownGood = lastKnownGoodStore.load()
        let value = StreakCalculator.currentStreak(
            for: snapshot(of: quit), now: now, monotonic: reading, lastKnownGood: lastKnownGood
        )
        refreshLastKnownGood(
            anchor: quit.monotonicAnchor, now: now, reading: reading, lastKnownGood: lastKnownGood
        )
        return value
    }

    // MARK: - Writes (synchronous; save() before returning; then a debounced reload)

    /// Creates a quit, enforcing the max-3-active rule. Quiz-driven fields (triggers,
    /// motivations, spend details) arrive with their consumers (E5); this takes only
    /// what E2.2 exercises.
    @discardableResult
    func createQuit(
        habitCategory: HabitCategory,
        customLabel: String? = nil,
        goalMode: GoalMode = .quit,
        weeklySpend: Decimal = 0
    ) throws -> Quit {
        let active = try activeQuits()
        guard active.count < Self.activeQuitLimit else {
            throw RepositoryError.activeQuitLimitReached
        }
        let now = clock.now
        let reading = clock.monotonicNow

        let quit = Quit()
        quit.habitCategory = habitCategory
        quit.customLabel = customLabel
        quit.goalMode = goalMode
        quit.weeklySpend = weeklySpend
        quit.startAt = now
        quit.createdAt = now
        // The streak's anchor: wallClock == startAt (the engine's documented invariant).
        quit.monotonicAnchor = MonotonicAnchor(
            bootID: reading.bootID, uptime: reading.uptime, wallClock: now
        )
        quit.sortIndex = (active.map(\.sortIndex).max() ?? -1) + 1
        context.insert(quit)
        try context.save()

        // NO last-known-good refresh here: a fresh anchor trivially agrees with the
        // reading it was minted from, so a verdict against it would be self-blessing —
        // a forward-set wall could poison the baseline through quit creation.
        scheduleWidgetReload()
        return quit
    }

    /// Synchronous local slip log: archive → best, bank the ended streak, restart the
    /// counter at the guarded slip instant — persisted BEFORE returning.
    @discardableResult
    func logSlip(quitID: UUID, note: String?) throws -> Slip {
        let quit = try fetchQuit(quitID)
        let now = clock.now
        let reading = clock.monotonicNow
        let lastKnownGood = lastKnownGoodStore.load()

        let before = snapshot(of: quit)
        let next = StreakCalculator.applySlip(
            to: before, at: now, monotonic: reading, lastKnownGood: lastKnownGood
        )
        // The ended streak (guarded + capped), recovered from the bank delta; the
        // repository owns totalCleanSeconds, so `before.priorCleanSeconds` is never
        // negative and the delta is exactly the archived streak.
        let ended = next.priorCleanSeconds - max(0, before.priorCleanSeconds)

        let slip = Slip()
        slip.at = next.startAt // the guarded slip instant — never a lying wall reading
        slip.note = note
        slip.streakSecondsAtSlip = ended
        slip.countsAgainstAllowance = quit.goalMode == .reduce
        // isPendingUndo stays false: the whole undo lifecycle (the flag, the finalize
        // sweep, undoSlip, and the §4 isPendingUndo index) lands as one unit with E4.1.
        slip.quit = quit
        context.insert(slip)

        quit.startAt = next.startAt
        quit.monotonicAnchor = next.monotonicAnchor
        quit.bestStreakSeconds = next.bestStreakSeconds
        // BANKED-only (== the engine's priorCleanSeconds): the live streak is added at
        // read time — storing it here too would double-count momentum's numerator.
        quit.totalCleanSeconds = next.priorCleanSeconds

        try context.save() // the commit point — before any UI transition (§9 rule 1)

        // Verdict computed against the PRE-slip anchor (the post-slip anchor was just
        // minted from this same reading and would self-bless).
        refreshLastKnownGood(
            anchor: before.monotonicAnchor, now: now, reading: reading, lastKnownGood: lastKnownGood
        )
        scheduleWidgetReload()
        return slip
    }

    /// Records a panic-flow outcome (architecture §5.1 `recordUrgeOutcome`).
    @discardableResult
    func logUrgeEvent(
        quitID: UUID,
        source: PanicSource,
        outcome: UrgeOutcome,
        stepsReached: [PanicStep] = []
    ) throws -> UrgeEvent {
        let quit = try fetchQuit(quitID)
        let now = clock.now
        let reading = clock.monotonicNow
        let lastKnownGood = lastKnownGoodStore.load()

        let event = UrgeEvent()
        event.at = now
        event.source = source
        event.outcome = outcome
        event.stepsReached = stepsReached
        event.quit = quit
        context.insert(event)
        if outcome == .averted {
            quit.avertedUrgeCount += 1
        }
        try context.save()

        refreshLastKnownGood(
            anchor: quit.monotonicAnchor, now: now, reading: reading, lastKnownGood: lastKnownGood
        )
        scheduleWidgetReload()
        return event
    }

    // MARK: - E2.4 · one-tap erase

    /// One-tap erase (architecture §5.1 `eraseEverything`, §10 scope, §6 — the
    /// complement of no-accounts): every SwiftData entity, the store's file set, the
    /// App Group defaults (panic pre-caches, launch flag), the clock witness, and the
    /// CloudKit private-zone mirror. LOCAL erase runs first and completes even when
    /// the cloud purge fails (Session 08 ruling: the on-device copy — verbatim
    /// motivations, readable by a person holding the phone — is the more sensitive
    /// one; the cloud step is the only fallible remote dependency, so it goes last
    /// and its failure surfaces for retry). Post-erase the app's relaunch state is a
    /// fresh install; this repository (and its container) are dead by design afterwards.
    func eraseEverything() async throws {
        // 1. Every entity row, children first — plain fetch-and-delete (no reliance
        //    on cascade ordering; identical behavior on in-memory and on-disk
        //    stores), one save as the local commit point.
        try deleteAllRows(Slip.self)
        try deleteAllRows(UrgeEvent.self)
        try deleteAllRows(QuizProfile.self)
        try deleteAllRows(Quit.self)
        try deleteAllRows(AppSettings.self)
        try context.save()

        // 2. Infallible local clears before anything that can throw: the witness is
        //    erased state (a stale one would poison the next tracking era's cap
        //    baseline), and it may never outlive a partially-failed erase.
        lastKnownGoodStore.clear()

        // 3. Defaults sweep (infallible) + store file set (the one fallible local
        //    step) — shared verbatim with the launch-time smoke hook.
        try Self.eraseLocalArtifacts(
            storeURLs: container.configurations.compactMap { $0.isStoredInMemoryOnly ? nil : $0.url },
            appGroupDefaults: appGroupDefaults
        )

        // E7 seam (named TODO, not a stub): RevenueCat anonymous-ID reset + SDK cache
        // clear wires here once the SDK exists — after the local erase, with restore
        // still one StoreKit call away (architecture §3).
        // E8 seam (named TODO, not a stub): the final `erase_all_completed` fires here
        // IF opted in, once the closed AnalyticsEvent enum exists (E8.1) — zero events
        // before consent, and none after erase in the same process lifetime.

        // 4. Widgets must drop their streaks regardless of the cloud outcome.
        scheduleWidgetReload()

        // 5. The one fallible REMOTE step goes last (Session 08 spec-review ruling —
        //    inverts the architecture §10 sketch, corrected there): iCloud OFF is
        //    first-class, skip and never fail (architecture §8); an available
        //    account's purge failure SURFACES after local completion, so the caller
        //    can offer retry (erase is re-runnable) and never silently claims the
        //    mirror is gone.
        if await cloud.accountStatus() == .available {
            try await cloud.deleteAllPrivateZones()
        }
    }

    /// The device-local half of erase (store file set + App Group defaults), static so
    /// the app's launch-time smoke hook shares the identical implementation with
    /// `eraseEverything()`.
    static func eraseLocalArtifacts(storeURLs: [URL], appGroupDefaults: UserDefaults) throws {
        // Infallible first: sweep every KEY out of the App Group defaults — the
        // panic launch flag today, defaults-shaped pre-cache keys tomorrow.
        // `removeObject` is a no-op on the global-domain keys that
        // `dictionaryRepresentation()` merges in, so the sweep cannot overreach.
        // SCOPE (review-pinned, Session 08): this helper covers defaults keys + the
        // store file set ONLY. E3.1 seam: when the App Group JSON snapshots land
        // (panic-snapshot.json / widget-state.json, architecture §4 — files, not
        // keys), their file names JOIN this sweep with a file-shaped sentinel test;
        // until then no such writer exists (verified in the Session 08 review).
        for key in appGroupDefaults.dictionaryRepresentation().keys {
            appGroupDefaults.removeObject(forKey: key)
        }
        // Then the store file set: base file + SQLite sidecars (`-shm`/`-wal`/
        // `-journal`) + hidden support artifacts. Unlinking an open store is safe
        // (POSIX semantics — the inode lives until the container closes); the
        // container is dead by design after an erase, relaunch = fresh install.
        let fileManager = FileManager.default
        for url in storeURLs {
            let directory = url.deletingLastPathComponent()
            let base = url.lastPathComponent
            let names = (try? fileManager.contentsOfDirectory(atPath: directory.path)) ?? []
            for name in names where name == base || name.hasPrefix(base + "-") || name.hasPrefix("." + base) {
                try fileManager.removeItem(at: directory.appendingPathComponent(name))
            }
        }
    }

    /// Fetch-and-delete every row of one model type (erase step 1). Deliberately not
    /// the batch-delete API: row-level deletes behave identically across in-memory
    /// and on-disk stores and stay idempotent under the Quit cascade.
    private func deleteAllRows<T: PersistentModel>(_ type: T.Type) throws {
        for row in try context.fetch(FetchDescriptor<T>()) {
            context.delete(row)
        }
    }

    // MARK: - Widget reload debounce

    /// Trailing debounce: every write replaces the pending reload; only a quiet tail
    /// reaches WidgetCenter. The sleep is injected so tests exercise the REAL
    /// cancel-prior semantics in zero wall time (test-suite §7.7: no sleep-based waits).
    private func scheduleWidgetReload() {
        pendingReload?.cancel()
        let sleep = debounceSleep
        pendingReload = Task { @MainActor [widgetRefresher] in
            await sleep(Self.widgetReloadDebounce)
            guard !Task.isCancelled else { return }
            widgetRefresher.reloadAllTimelines()
        }
    }

    /// Test hook: awaits the pending debounced reload, if any. Internal on purpose —
    /// production never waits on widget refreshes.
    func drainPendingWidgetReload() async {
        await pendingReload?.value
    }

    // MARK: - Private helpers

    private func fetchQuit(_ id: UUID) throws -> Quit {
        var descriptor = FetchDescriptor<Quit>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        guard let quit = try context.fetch(descriptor).first else {
            throw RepositoryError.quitNotFound(id)
        }
        return quit
    }

    /// The engine's domain-neutral input, mapped from the model (architecture §5.1).
    private func snapshot(of quit: Quit) -> StreakSnapshot {
        StreakSnapshot(
            startAt: quit.startAt,
            trackedSince: quit.createdAt,
            weeklySpend: quit.weeklySpend,
            priorCleanSeconds: quit.totalCleanSeconds,
            monotonicAnchor: quit.monotonicAnchor,
            bestStreakSeconds: quit.bestStreakSeconds,
            pendingUndo: nil
        )
    }

    /// Maintains the device's conservative WITNESS — a provable lower bound on
    /// elapsed real time. Session 07 EXTENSION of the Session 06 discipline: the two
    /// original gates are unchanged and preferred, and no path ever writes an
    /// unverified wall claim into the baseline.
    ///
    /// Path 1 — REAL-WALL ADVANCE (the Session 06 gates, unchanged): only when BOTH
    ///  a. a guard verdict computed against a pre-existing anchor reads `.normal`
    ///     (never on `.clockRolledBack`/`.timezoneShift` — persisting a disputed wall
    ///     would poison every future reboot-cap baseline; never without an anchor), and
    ///  b. the new reading is CONTINUOUS with the previous trusted reading — the old
    ///     reading itself re-run through the guard as the anchor. A freshly-minted
    ///     quit anchor agrees with the reading it was minted from for ANY wall value,
    ///     so gate (a) alone would let a fresh quit launder a forward-set wall into
    ///     the device-global baseline (Session 06 review MAJOR); the continuity gate
    ///     refuses it (within a boot the uptime delta disputes the wall jump; across a
    ///     reboot the advance stays inside the same cap the display honors).
    ///
    /// Path 2 — heal-time RESTART: lives in `recomputeDerivedState()`, bounded to
    /// ≤ `defaultRebootGapCap` per reboot (the same credit the capped arm grants).
    ///
    /// Path 3 — UPTIME ACCRUAL (fallback when path 1 declines): same boot and the
    /// uptime advanced ⇒ the witness wall moves by exactly the uptime delta. Pure
    /// monotonic arithmetic — no wall claim is consulted, so a lying wall cannot
    /// launder in — and it keeps the witness live under a disputed wall so the chain
    /// re-certifies through path 1 once the conservative lag decays below the cap.
    private func refreshLastKnownGood(
        anchor: MonotonicAnchor?,
        now: Date,
        reading: MonotonicNow,
        lastKnownGood: MonotonicAnchor?
    ) {
        if let anchor {
            let verdict = StreakCalculator.sanityCheck(
                anchor: anchor, now: now, monotonic: reading, lastKnownGood: lastKnownGood
            )
            if verdict == .normal {
                let continuity = lastKnownGood.map { previous in
                    StreakCalculator.sanityCheck(
                        anchor: previous, now: now, monotonic: reading, lastKnownGood: previous
                    ) == .normal
                } ?? true
                if continuity {
                    lastKnownGoodStore.save(
                        MonotonicAnchor(bootID: reading.bootID, uptime: reading.uptime, wallClock: now)
                    )
                    return
                }
            }
        }
        guard let previous = lastKnownGood,
              previous.bootID == reading.bootID,
              reading.uptime > previous.uptime else { return }
        lastKnownGoodStore.save(MonotonicAnchor(
            bootID: previous.bootID,
            uptime: reading.uptime,
            wallClock: previous.wallClock + (reading.uptime - previous.uptime)
        ))
    }

    // MARK: - E2.3 · recomputeDerivedState (dedupe merge + heal + witness restart)

    /// The launch-time derived-state pass (architecture §8): the CloudKit dedupe merge
    /// (same-`id` records fold into one that never shrinks history), the ADR-7 healing
    /// re-anchor (freeze-then-resume) for streaks frozen by the reboot cap, and the
    /// bounded witness restart that lets the trusted-reading chain recover.
    /// Deterministic — a pure function of the record SET, so every arrival/processing
    /// order converges to the same state — idempotent, and safe at every launch: a
    /// no-op pass saves nothing and schedules no reload. App-launch wiring lands with
    /// E3.1; remote-change wiring with the §4.3 CloudKit flip.
    @discardableResult
    func recomputeDerivedState() throws -> Bool {
        let now = clock.now
        let reading = clock.monotonicNow
        var didMutate = false

        let groups = Dictionary(grouping: try context.fetch(FetchDescriptor<Quit>()), by: \.id)
            .values.filter { $0.count > 1 }
        for rows in groups {
            try merge(rows)
            didMutate = true
        }

        // Heal AFTER the merge so the re-anchor is minted against the merged record.
        let witness = lastKnownGoodStore.load()
        var healedAny = false
        for quit in try context.fetch(FetchDescriptor<Quit>()) {
            guard let healed = StreakCalculator.healFrozenStreak(
                on: snapshot(of: quit), at: now, monotonic: reading, lastKnownGood: witness
            ) else { continue }
            // Option (iii): ONLY the streak re-bases. createdAt (the tracking origin,
            // "never resets") and the banked monotonic fields never move — post-heal
            // momentum reads honest-conservative, and counting resumes.
            quit.startAt = healed.startAt
            quit.monotonicAnchor = healed.monotonicAnchor
            healedAny = true
            didMutate = true
        }
        if healedAny, let previous = witness, previous.bootID != reading.bootID {
            // Witness restart (path 2): grant exactly what the capped arm granted the
            // healed quits — min(gap, cap) — NEVER the raw wall, which the bridge arm
            // would trust uncapped for any older (incl. CloudKit-delivered) anchor.
            // Per-reboot unverifiable optimism stays ≤ cap, the Session-06 bound; the
            // in-window channel has always granted the same per-reboot credit. The
            // bootID gate is what makes the bound PER-REBOOT: the first grant stamps
            // the current boot onto the witness, so later same-boot passes (remote-
            // change wiring fires many per boot) can heal but never re-grant —
            // within a boot, path 3's uptime accrual is the only witness movement.
            let gap = now.timeIntervalSince(previous.wallClock)
            lastKnownGoodStore.save(MonotonicAnchor(
                bootID: reading.bootID,
                uptime: reading.uptime,
                wallClock: previous.wallClock + min(max(0, gap), StreakCalculator.defaultRebootGapCap)
            ))
        }

        if didMutate {
            try context.save()
            scheduleWidgetReload()
        }
        return didMutate
    }

    /// Folds one duplicate group into its canonical survivor: every field OVERWRITTEN
    /// with an order-free resolution over the whole group, every child re-parented —
    /// the logical result is independent of which physical row survives.
    private func merge(_ rows: [Quit]) throws {
        let ordered = rows.sorted {
            ($0.createdAt, $0.startAt, -$0.bestStreakSeconds)
                < ($1.createdAt, $1.startAt, -$1.bestStreakSeconds)
        }
        let survivor = ordered[0]
        let losers = ordered.dropFirst()

        // The record whose startAt wins contributes its anchor AS A COHERENT TUPLE —
        // the guard measures elapsed from anchor.wallClock, so pairing the newest
        // startAt with an older anchor would silently inflate, unflagged.
        let startWinner = rows.min { a, b in
            if a.startAt != b.startAt { return a.startAt > b.startAt } // latest start first
            switch (a.monotonicAnchor, b.monotonicAnchor) {
            case (.some, nil): return true // an anchored record beats an unanchored one
            case (nil, .some), (nil, nil): return false
            case let (.some(x), .some(y)):
                return (x.wallClock, x.uptime, x.bootID.uuidString)
                    < (y.wallClock, y.uptime, y.bootID.uuidString)
            }
        }!

        survivor.createdAt = rows.map(\.createdAt).min()! // max total tracked span
        survivor.startAt = startWinner.startAt            // latest slip-terminated start (§8)
        survivor.monotonicAnchor = startWinner.monotonicAnchor
        survivor.bestStreakSeconds = rows.map(\.bestStreakSeconds).max()!
        survivor.totalCleanSeconds = rows.map(\.totalCleanSeconds).max()!
        survivor.weeklySpend = rows.map(\.weeklySpend).max()!
        survivor.weeklyAllowance = rows.compactMap(\.weeklyAllowance).max()
        survivor.habitCategory = rows.map(\.habitCategory).min { $0.rawValue < $1.rawValue }!
        survivor.goalMode = rows.map(\.goalMode).min { $0.rawValue < $1.rawValue }!
        survivor.customLabel = rows.compactMap(\.customLabel).min()
        survivor.currencyCode = rows.map(\.currencyCode).min()!
        survivor.triggers = Self.orderPreservingUnion(of: rows.map(\.triggers))
        survivor.motivations = Self.orderPreservingUnion(of: rows.map(\.motivations))
        survivor.discreetMode = rows.contains { $0.discreetMode } // fails toward privacy
        survivor.isArchived = rows.contains { $0.isArchived }     // the user's archive wins
        survivor.sortIndex = rows.map(\.sortIndex).min()!

        // Children union by id, re-parented BEFORE any delete (.cascade would eat
        // them). The recount corrects the cross-device undercount: two devices can
        // each hold averted events the other missed, so max-of-counters alone is low;
        // flooring at the stored max keeps the counter monotonic.
        let unionedAverted = adoptChildren(of: ordered, into: survivor)
        survivor.avertedUrgeCount = max(rows.map(\.avertedUrgeCount).max()!, unionedAverted)

        // QuizProfile points AT Quit with no inverse: re-point before a loser delete
        // leaves it dangling. Re-point only — profile semantics are E5's.
        let loserIdentities = Set(losers.map { ObjectIdentifier($0) })
        for profile in try context.fetch(FetchDescriptor<QuizProfile>()) {
            if let owner = profile.quit, loserIdentities.contains(ObjectIdentifier(owner)) {
                profile.quit = survivor
            }
        }

        // Persist the re-parenting BEFORE deleting losers: belt-and-suspenders so the
        // cascade can never act on a stale in-memory inverse (Session 07 red team).
        try context.save()
        for loser in losers { context.delete(loser) }
    }

    /// Re-parents every child row onto the survivor, deduping same-id child rows to
    /// one. Returns the number of distinct `.averted` urge events in the union.
    private func adoptChildren(of ordered: [Quit], into survivor: Quit) -> Int {
        var keptSlips: [UUID: Slip] = [:]
        var keptUrges: [UUID: UrgeEvent] = [:]
        for row in ordered {
            for slip in Array(row.slips ?? []).sorted(by: { $0.at < $1.at }) {
                if let kept = keptSlips[slip.id] {
                    if kept !== slip { context.delete(slip) }
                } else {
                    keptSlips[slip.id] = slip
                    slip.quit = survivor
                }
            }
            for urge in Array(row.urgeEvents ?? []).sorted(by: { $0.at < $1.at }) {
                if let kept = keptUrges[urge.id] {
                    if kept !== urge { context.delete(urge) }
                } else {
                    keptUrges[urge.id] = urge
                    urge.quit = survivor
                }
            }
        }
        return keptUrges.values.count { $0.outcome == .averted }
    }

    /// Order-preserving union over string lists — a pure function of the SET of
    /// lists: candidates ordered by (count desc, then ASCENDING element-wise
    /// lexicographic; the direction is contractual), the first is the base, the rest
    /// append their unseen items in their own order. No pairwise fold (order-
    /// dependent) and no joined-string tie-break (not injective over free text) —
    /// user-entered order survives, and every insertion order of the same lists
    /// converges byte-identically. Motivations render verbatim in the panic flow, so
    /// sorting ITEMS alphabetically would scramble user priority.
    private static func orderPreservingUnion(of lists: [[String]]) -> [String] {
        let ordered = lists.sorted { a, b in
            if a.count != b.count { return a.count > b.count }
            return a.lexicographicallyPrecedes(b)
        }
        var seen = Set<String>()
        var union: [String] = []
        for list in ordered {
            for item in list where seen.insert(item).inserted {
                union.append(item)
            }
        }
        return union
    }
}
