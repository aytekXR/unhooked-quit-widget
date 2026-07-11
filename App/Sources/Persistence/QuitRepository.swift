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
    /// The §9-rule-2 panic write buffer, derived from the pre-cache's directory: both
    /// files live in the App Group container root by design (architecture §4), so the
    /// injected pre-cache location places the buffer too — tests land in the same
    /// temp directory, production in the real container, with zero extra wiring.
    private let panicOutcomeBuffer: PanicOutcomeBuffer
    /// The E8.1 analytics seam (ADR-8): events fire BESIDE the durable writes —
    /// post-save, never inside or blocking one (Architect ruling, Session 15; §1.2
    /// invariant 3). Defaulted to the transmit-nothing service, so construction
    /// sites opt in per test exactly like `debounceSleep`.
    private let analytics: AnalyticsService
    /// E5.2 — the quiz resume checkpoint (app-STANDARD defaults by design, R5 —
    /// never the App Group suite, §10). Injected so erase tests use a throwaway
    /// suite; defaulted so existing construction sites are untouched (the
    /// debounceSleep/analytics precedent). Erase must sweep it (relaunch =
    /// fresh install).
    private let quizProgressStore: QuizProgressStore
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
        quizProgressStore: QuizProgressStore = QuizProgressStore(),
        debounceSleep: @escaping @Sendable (Duration) async -> Void = { try? await Task.sleep(for: $0) },
        analytics: AnalyticsService = .disabled
    ) {
        self.container = container
        self.context = container.mainContext
        self.clock = clock
        self.widgetRefresher = widgetRefresher
        self.lastKnownGoodStore = lastKnownGoodStore
        self.cloud = cloud
        self.appGroupDefaults = appGroupDefaults
        self.panicSnapshotStore = panicSnapshotStore
        self.panicOutcomeBuffer = PanicOutcomeBuffer(
            directoryURL: panicSnapshotStore.fileURL.deletingLastPathComponent()
        )
        self.quizProgressStore = quizProgressStore
        self.debounceSleep = debounceSleep
        self.analytics = analytics
    }

    // MARK: - E3.2/E4.1 · panic write-buffer flush (§9 rule 2)

    /// Replays the panic flow's buffered outcomes into the store — the "flushed into
    /// SwiftData as soon as the context is ready" half of §9 rule 2. Returns how many
    /// outcomes landed.
    ///
    /// Non-throwing by design (Session 10 design-panel ruling): a flush failure is
    /// the §9 silent-recover class — the buffer stays intact for the next launch and
    /// the launch sequence continues; only a store that cannot OPEN is blocking.
    /// Idempotent under replay: the flushed `UrgeEvent` ADOPTS the draft's id, so a
    /// crash between save and clear re-runs as a no-op instead of double-counting —
    /// and the SAME id set gates the E4.1 streak transition, so a replayed slip can
    /// never re-cut a streak. `at` is the draft's TRUE exit instant, never the flush
    /// clock (§12.4 insights aggregate on urge timing). A draft whose quit no longer
    /// exists is DROPPED — erased means erased, nothing may resurrect behavioral data
    /// about that quit — while a nil-quit draft (zero-quit panic) lands honestly
    /// unattributed, as an UrgeEvent ONLY [R-NILQUIT]. The launch's witness work
    /// stays with `recomputeDerivedState()`, which runs first in the same sequence —
    /// replaying historical events earns no fresh wall trust.
    ///
    /// E4.1 (Session 11 decision record, binding): TWO passes. Revocation ids are
    /// collected FIRST [R-REVOKE] — in append order a revocation always follows its
    /// target, so a single pass would apply a slip before learning its own session
    /// already took it back. Then drafts apply in APPEND order, never wall-sorted
    /// [R-ORDER]: a rolled-back wall between two cold slips would invert causality
    /// under sorting. A revoked pair (the slip draft + its revocation) drops whole —
    /// neither becomes an UrgeEvent, neither touches a streak.
    @discardableResult
    func flushPanicOutcomes() -> Int {
        let drafts = panicOutcomeBuffer.drafts()
        guard !drafts.isEmpty else { return 0 }
        let now = clock.now
        let reading = clock.monotonicNow
        do {
            // Pass 1 [R-REVOKE]: every draft an in-session cold undo took back.
            let revokedIDs = Set(drafts.compactMap(\.revokesDraftID))
            // A var, extended per insert: the buffer itself can hold the SAME draft
            // twice (the exit-time append retry re-writes when the first write's
            // fsync error surfaced after the bytes landed), and the store-side set
            // alone would land both copies.
            var existing = Set(try context.fetch(FetchDescriptor<UrgeEvent>()).map(\.id))
            var landed = 0
            // Collected during the replay, fired only past the commit point below —
            // a thrown save rolls back the rows AND forfeits their events together.
            var avertedCategories: [HabitCategory] = []
            for draft in drafts where !existing.contains(draft.id) {
                // Revocation records are bookkeeping, never UrgeEvents; a revoked
                // slip never reaches the store (§9 rule 3 governs STORE rows — the
                // pair evaporates before one exists).
                if draft.revokesDraftID != nil || revokedIDs.contains(draft.id) { continue }
                let quit: Quit?
                if let quitID = draft.quitID {
                    guard let found = try? fetchQuit(quitID) else { continue }
                    quit = found
                } else {
                    quit = nil
                }
                let event = UrgeEvent()
                event.id = draft.id
                event.at = draft.at
                event.source = draft.source
                event.outcome = draft.outcome
                event.stepsReached = draft.stepsReached
                event.quit = quit
                context.insert(event)
                if draft.outcome == .averted, let quit {
                    quit.avertedUrgeCount += 1
                    avertedCategories.append(quit.habitCategory)
                }
                if draft.outcome == .slipped, let quit {
                    applyDeferredSlip(draft, to: quit, flushNow: now, flushReading: reading)
                }
                existing.insert(draft.id)
                landed += 1
            }
            if landed > 0 {
                try context.save()
                rebuildPanicSnapshot()
                scheduleWidgetReload()
                // Post-commit (§1.2 invariant 3): one urge_averted per LANDED
                // attributed averted row. [R-NILQUIT] rows fire nothing — the
                // category is unconstructible without a quit — and replayed or
                // revoked drafts never reach this list.
                for category in avertedCategories {
                    analytics.fire(.urgeAverted(habitCategory: category))
                }
            }
            // Consume only after the commit point — a crash before this line replays
            // safely (the id dedupe above), a crash after it has nothing left to lose.
            try? panicOutcomeBuffer.clear()
            return landed
        } catch {
            context.rollback() // no half-flushed rows may ride a later unrelated save
            return 0
        }
    }

    /// Applies one buffered cold slip exactly as a live `logSlip` at the slip instant
    /// would have — the R-WIT equivalence pin: the transition runs on the SLIP-TIME
    /// evidence tuple the draft captured (its monotonic reading + its witness), so a
    /// reboot, a rolled-back wall, or plain elapsed time between slip and flush can
    /// neither shrink nor inflate what the slip banks. Only the UNDO WINDOW is
    /// measured at flush time (engine gate, `lastKnownGood: nil` — the ratified E1.3
    /// semantics): the affordance is honored across the deferral exactly as long as
    /// it would have survived live. The witness is NEVER advanced here.
    private func applyDeferredSlip(
        _ draft: PanicOutcomeDraft, to quit: Quit, flushNow: Date, flushReading: MonotonicNow
    ) {
        let captured: MonotonicNow? = {
            guard let bootID = draft.capturedBootID, let uptime = draft.capturedUptime else {
                return nil
            }
            return MonotonicNow(bootID: bootID, uptime: uptime)
        }()
        let capturedWitness: MonotonicAnchor? = {
            guard let bootID = draft.capturedWitnessBootID,
                  let uptime = draft.capturedWitnessUptime,
                  let wallClock = draft.capturedWitnessWallClock else { return nil }
            return MonotonicAnchor(bootID: bootID, uptime: uptime, wallClock: wallClock)
        }()

        let before = snapshot(of: quit)
        let next = StreakCalculator.applySlip(
            to: before, at: draft.at, monotonic: captured, lastKnownGood: capturedWitness
        )
        // The ended streak, recovered from the bank delta (the logSlip identity).
        let ended = next.priorCleanSeconds - max(0, before.priorCleanSeconds)

        // R-NEWEST: earlier same-quit rows are forced non-pending — one reversible
        // slip at a time, whichever route logged it.
        finalizePendingRows(for: quit)

        let slip = Slip()
        slip.at = next.startAt // the guarded slip instant, byte-equal to live logSlip
        slip.streakSecondsAtSlip = ended
        slip.countsAgainstAllowance = quit.goalMode == .reduce
        // Note stays nil FOREVER for a cold slip: the draft has no note field (§10).
        if StreakCalculator.undoSlip(
            on: next, at: flushNow, monotonic: flushReading, lastKnownGood: nil
        ) != nil {
            slip.isPendingUndo = true
            applyUndoPayload(next.pendingUndo, to: slip)
        }
        // else: the window closed while the draft waited — the row lands already
        // FINALIZED (flag false, payload nil): the sweep's exact bytes.
        slip.quit = quit
        context.insert(slip)

        quit.startAt = next.startAt
        quit.monotonicAnchor = next.monotonicAnchor
        quit.bestStreakSeconds = next.bestStreakSeconds
        // BANKED-only (== the engine's priorCleanSeconds), same as live logSlip.
        quit.totalCleanSeconds = next.priorCleanSeconds
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
        rebuildPanicSnapshot()
        scheduleWidgetReload()
        return quit
    }

    /// E5.2 — the quiz's create (architecture §5.1: the `from profile:` form arrives
    /// with its consumer). RED STUB — deliberately ignores the profile: no field
    /// mapping, no max-3 guard, no profile insert/link, no anchor. The designed
    /// failures on the red commit (QuizCompletionTests + the erase pin).
    @discardableResult
    func createQuit(from profile: QuizProfile) throws -> Quit {
        let quit = Quit()
        context.insert(quit)
        try context.save()
        rebuildPanicSnapshot()
        scheduleWidgetReload()
        return quit
    }

    /// E5.2 — the quiz completion seam (Architect MUST-FIX 7): `QuizProfile` is a
    /// @Model, so it is assembled HERE (the sole SwiftData importer), never in a
    /// Quiz/* view or model — the composition root hands `QuizFlowModel` this
    /// method reference as its `onComplete`.
    func completeQuiz(_ answers: [QuizAnswer]) throws {
        let profile = QuizProfile()
        profile.answers = answers
        _ = try createQuit(from: profile)
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

        // One reversible slip at a time (§9 rule 3): a newer slip finalizes any prior
        // pending row for this quit BEFORE opening its own window — mirroring the
        // engine, whose applySlip just replaced the snapshot's pendingUndo the same way.
        finalizePendingRows(for: quit)

        let slip = Slip()
        slip.at = next.startAt // the guarded slip instant — never a lying wall reading
        slip.note = note
        slip.streakSecondsAtSlip = ended
        slip.countsAgainstAllowance = quit.goalMode == .reduce
        // The window opens NOW: the flag plus the engine's recorded pre-slip values —
        // undoSlip restores RECORDED bytes, never reconstructions (§9 rule 3).
        slip.isPendingUndo = true
        applyUndoPayload(next.pendingUndo, to: slip)
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
        rebuildPanicSnapshot()
        scheduleWidgetReload()
        return slip
    }

    // MARK: - E4.1 · undo lifecycle (red-commit surface; behavior lands green)

    /// Undoes a still-pending slip: restores the EXACT recorded pre-slip values via
    /// the engine (the ONE sanctioned monotonic decrease, §9 rule 3) and removes the
    /// undone row. Returns false — a calm no-op, never an error — when the window has
    /// closed or nothing is pending (the tap raced the sweep at most one render).
    @discardableResult
    func undoSlip(slipID: UUID) throws -> Bool {
        guard let slip = try fetchSlip(slipID), slip.isPendingUndo, let quit = slip.quit else {
            return false
        }
        // A pending flag without its recorded payload cannot restore honestly (a
        // partial write that should never exist) — finalize it and answer calmly.
        guard let pendingUndo = persistedUndo(of: slip) else {
            finalizeRow(slip)
            try context.save()
            return false
        }
        let now = clock.now
        let reading = clock.monotonicNow

        // The post-slip state IS the quit's current snapshot; the engine gate measures
        // the window on the guarded timeline with `lastKnownGood: nil` — the ratified
        // E1.3 undo semantics (an ahead witness must not burn the window, S11 record).
        var current = snapshot(of: quit)
        current.pendingUndo = pendingUndo
        guard let restored = StreakCalculator.undoSlip(
            on: current, at: now, monotonic: reading, lastKnownGood: nil
        ) else {
            // Past the window: a calm no-op that FINALIZES — the same bytes the
            // scene-phase sweep would have written (the tap raced it one render).
            finalizeRow(slip)
            try context.save()
            return false
        }

        // The ONE sanctioned monotonic decrease (§9 rule 3): exact recorded priors.
        quit.startAt = restored.startAt
        quit.monotonicAnchor = restored.monotonicAnchor
        quit.bestStreakSeconds = restored.bestStreakSeconds
        quit.totalCleanSeconds = restored.priorCleanSeconds
        // An undone slip must not count against Reduce allowance or future insights:
        // the row is DELETED (S11 ratified; its CloudKit tombstoning is a named
        // design item for the §4.3 flip). The panic-session UrgeEvent survives — the
        // session happened; only the streak-affecting row is undone.
        context.delete(slip)
        try context.save()

        // Post-save (§1.2 invariant 3): the restore is committed — the undo is real.
        // Property-less by MVP §5; the two calm no-op arms above fire nothing.
        analytics.fire(.slipUndone)

        // NO witness refresh: restoring a historical anchor earns no fresh wall trust.
        rebuildPanicSnapshot()
        scheduleWidgetReload()
        return true
    }

    /// The undo-window finalize sweep (architecture §7: scene-phase driven, never a
    /// background timer). Idempotent; returns how many pending slips it finalized.
    /// E8's post-window `slip_logged` trigger attaches here when the enum exists.
    @discardableResult
    func finalizePendingSlips() -> Int {
        guard let pending = try? context.fetch(
            FetchDescriptor<Slip>(predicate: #Predicate { $0.isPendingUndo })
        ), !pending.isEmpty else { return 0 }
        let now = clock.now
        let reading = clock.monotonicNow
        var finalized = 0
        for slip in pending {
            // Orphaned or payload-less pending rows cannot restore — sweep them too.
            guard let quit = slip.quit, let pendingUndo = persistedUndo(of: slip) else {
                finalizeRow(slip)
                finalized += 1
                continue
            }
            var current = snapshot(of: quit)
            current.pendingUndo = pendingUndo
            // Window still open (engine gate, guarded timeline, nil witness) → leave
            // the row alone; closed → finalize. Idempotent by construction: a
            // finalized row no longer matches the pending fetch.
            if StreakCalculator.undoSlip(
                on: current, at: now, monotonic: reading, lastKnownGood: nil
            ) == nil {
                finalizeRow(slip)
                finalized += 1
            }
        }
        if finalized > 0 {
            // Silent-recover class (§9): the sweep runs on scene-phase changes; a
            // failed save simply leaves the rows for the next sweep.
            try? context.save()
        }
        return finalized
    }

    /// Reflection-note autosave target (store-backed slips only — §10: notes live
    /// ONLY in the store, never in any App Group file).
    func updateSlipNote(slipID: UUID, note: String?) throws {
        guard let slip = try fetchSlip(slipID) else { return }
        slip.note = note
        try context.save()
        // No pre-cache rebuild, no widget reload: notes NEVER leave the store (§10),
        // so nothing widget- or cache-visible changed.
    }

    /// The normal route's undo-banner source: the one still-pending slip, if any
    /// (one reversible slip at a time — §9 rule 3). Backed by the E4.1
    /// `#Index<Slip>([\.isPendingUndo])`.
    func pendingUndoSlip() throws -> Slip? {
        var descriptor = FetchDescriptor<Slip>(predicate: #Predicate { $0.isPendingUndo })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
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

        if outcome == .averted {
            // Post-save, BESIDE the write (§1.2 invariant 3): the durable row is
            // committed; analytics can neither block nor fail it. The category is
            // the closed enum — `custom` is the ceiling, never the free-text label.
            analytics.fire(.urgeAverted(habitCategory: quit.habitCategory))
        }

        refreshLastKnownGood(
            anchor: quit.monotonicAnchor, now: now, reading: reading, lastKnownGood: lastKnownGood
        )
        rebuildPanicSnapshot()
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

        // 3. Defaults sweep (infallible) + owned App Group files + store file set
        //    (the fallible local steps) — shared verbatim with the launch-time smoke
        //    hook. The panic pre-cache is IN the owned file set (E3.1): its verbatim
        //    motivations are exactly what one-tap erase promises to destroy. The
        //    panic write buffer joined in ITS landing session (E3.2, the standing
        //    rule): buffered urge outcomes are §10 "never leaves the device" data.
        try Self.eraseLocalArtifacts(
            storeURLs: container.configurations.compactMap { $0.isStoredInMemoryOnly ? nil : $0.url },
            appGroupFileURLs: [panicSnapshotStore.fileURL, panicOutcomeBuffer.fileURL],
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

    /// The device-local half of erase (App Group defaults + owned App Group files +
    /// store file set), static so the app's launch-time smoke hook shares the
    /// identical implementation with `eraseEverything()`.
    static func eraseLocalArtifacts(
        storeURLs: [URL],
        appGroupFileURLs: [URL],
        appGroupDefaults: UserDefaults
    ) throws {
        // Infallible first: sweep every KEY out of the App Group defaults — the
        // panic launch flag + quitID selection today. `removeObject` is a no-op on
        // the global-domain keys that `dictionaryRepresentation()` merges in, so the
        // sweep cannot overreach.
        for key in appGroupDefaults.dictionaryRepresentation().keys {
            appGroupDefaults.removeObject(forKey: key)
        }
        // Owned App Group FILES (E3.1 closes the Session-08 carry item):
        // panic-snapshot.json today; widget-state.json joins with its E6 writer. An
        // allowlist of exact URLs, never a directory sweep (E2.4 scope pin — the real
        // container holds unrelated files). Missing file = nothing to do.
        let fileManager = FileManager.default
        for url in appGroupFileURLs where fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
        // Then the store file set: base file + SQLite sidecars (`-shm`/`-wal`/
        // `-journal`) + hidden support artifacts. Unlinking an open store is safe
        // (POSIX semantics — the inode lives until the container closes); the
        // container is dead by design after an erase, relaunch = fresh install.
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

    // MARK: - Age gate (E5.1)

    /// The fail-closed age-gate read: only a store-truth `true` opens habit content —
    /// a missing row, a fresh row, or a failed fetch all read NOT passed (Architect
    /// MUST-FIX #6, Session 16). Store-only by design: no App Group mirror exists or
    /// may be added (MUST-FIX #3), so the panic route stays structurally unable to
    /// read (or need) gate state.
    func isAgeGatePassed() -> Bool {
        var descriptor = FetchDescriptor<AppSettings>()
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor).first?.ageGatePassed) ?? false
    }

    /// The ONE writer of `ageGatePassed` — reached only from the gate's pass branch
    /// (after `AgeGate.evaluate == .pass`). Fires no analytics (E5.1 AC4: the whole
    /// age-gate surface is zero-fire, test-pinned).
    func markAgeGatePassed() throws {
        let settings = try fetchOrCreateAppSettings()
        settings.ageGatePassed = true
        try context.save()
    }

    /// Fetch-FIRST the AppSettings singleton, creating only when absent — so the row
    /// stays the singleton and E8.2's consent step SHARES this helper instead of
    /// minting a second row (Architect MUST-FIX #6; no uniqueness constraint may
    /// exist by the CloudKit checklist).
    private func fetchOrCreateAppSettings() throws -> AppSettings {
        var descriptor = FetchDescriptor<AppSettings>()
        descriptor.fetchLimit = 1
        if let existing = try context.fetch(descriptor).first { return existing }
        let fresh = AppSettings()
        context.insert(fresh)
        return fresh
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

    /// Optional-returning on purpose (unlike `fetchQuit`): every E4.1 caller treats a
    /// missing row as a calm no-op, never an error — the undo tap racing the sweep,
    /// or a note autosave landing after an undo deleted its row.
    private func fetchSlip(_ id: UUID) throws -> Slip? {
        var descriptor = FetchDescriptor<Slip>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    /// The row's persisted undo payload as the engine value — nil when any recorded
    /// field is missing (`priorMonotonicAnchor` alone may honestly be nil: a slip
    /// logged without a monotonic reading recorded a nil prior anchor).
    private func persistedUndo(of slip: Slip) -> PendingSlipUndo? {
        guard let priorStartAt = slip.priorStartAt,
              let priorCleanSeconds = slip.priorCleanSeconds,
              let priorBestStreakSeconds = slip.priorBestStreakSeconds else { return nil }
        return PendingSlipUndo(
            priorStartAt: priorStartAt,
            priorCleanSeconds: priorCleanSeconds,
            priorBestStreakSeconds: priorBestStreakSeconds,
            priorMonotonicAnchor: slip.priorMonotonicAnchor
        )
    }

    private func applyUndoPayload(_ undo: PendingSlipUndo?, to slip: Slip) {
        slip.priorStartAt = undo?.priorStartAt
        slip.priorCleanSeconds = undo?.priorCleanSeconds
        slip.priorBestStreakSeconds = undo?.priorBestStreakSeconds
        slip.priorMonotonicAnchor = undo?.priorMonotonicAnchor
    }

    /// Finalized means finalized: flag down AND payload gone — the recorded priors
    /// exist exactly as long as the window does (they are restore material, not
    /// history; history is the row's own banked fields).
    private func finalizeRow(_ slip: Slip) {
        slip.isPendingUndo = false
        applyUndoPayload(nil, to: slip)
    }

    /// Forces every still-pending row of one quit non-pending (no window check):
    /// a NEWER slip replaces any open undo, exactly as the engine's applySlip just
    /// replaced the snapshot's `pendingUndo` (§9 rule 3 — one reversible slip).
    private func finalizePendingRows(for quit: Quit) {
        for slip in (quit.slips ?? []) where slip.isPendingUndo {
            finalizeRow(slip)
        }
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
            rebuildPanicSnapshot()
            scheduleWidgetReload()
        }
        return didMutate
    }

    // MARK: - E3.1 · panic pre-cache (panic-snapshot.json)

    /// ADR-6's dual-representation invariant: every mutating write rebuilds the panic
    /// pre-cache AFTER the store commit, so the cold panic route always renders the
    /// user's current quits + verbatim motivations without touching the store.
    /// Best-effort by design (§9 silent-recover): a failed write leaves the last good
    /// cache standing — the store stays the source of truth and the next write or
    /// launch refresh heals the file. NEVER called from `eraseEverything` — erased
    /// means ABSENT until a new tracking era's first write (the sweep owns the file).
    private func rebuildPanicSnapshot() {
        guard let quits = try? activeQuits() else { return }
        let now = clock.now
        let reading = clock.monotonicNow
        let lastKnownGood = lastKnownGoodStore.load()
        let cards = quits.map { quit -> QuitSnapshot in
            // E4.1 additive streak fields (§3 sketch; schemaVersion stays 1): raw
            // scalars from store truth — the cold slip flow's forgiveness framing
            // renders from these because the store never opens on that route.
            // Momentum comes from the same guarded read the dashboard shows; this is
            // a READ — the rebuild never refreshes the witness (not one of the three
            // sanctioned advance paths).
            let value = StreakCalculator.currentStreak(
                for: snapshot(of: quit), now: now, monotonic: reading, lastKnownGood: lastKnownGood
            )
            return QuitSnapshot(
                id: quit.id,
                // §10: discreet mode strips labels from snapshots (readable pre-unlock).
                label: quit.discreetMode ? nil : Self.displayLabel(for: quit),
                discreet: quit.discreetMode,
                motivations: quit.motivations, // verbatim, user order — the flow renders these
                startAt: quit.startAt,
                anchorBootID: quit.monotonicAnchor?.bootID,
                anchorUptime: quit.monotonicAnchor?.uptime,
                bestStreakSeconds: quit.bestStreakSeconds,
                momentumPercent: Int((value.momentum * 100).rounded())
            )
        }
        try? panicSnapshotStore.write(PanicSnapshot(quits: cards))
    }

    /// Launch-time refresh (`RepositoryProvider.startIfNeeded`): rewrites the cache
    /// from store truth — heals a previously failed best-effort write and prunes any
    /// residue the moment a new tracking era begins.
    func refreshPanicSnapshot() {
        rebuildPanicSnapshot()
    }

    /// Brand-safe display label for the pre-cache: the user's own words when they
    /// gave any (brandkit: "the user's words outrank ours"), else the category's
    /// plain clinical noun — in-app surfaces may name habits; only discreet surfaces
    /// must not, and those take the `nil` branch above.
    private static func displayLabel(for quit: Quit) -> String {
        if let custom = quit.customLabel, !custom.isEmpty { return custom }
        switch quit.habitCategory {
        case .vape: return "Vaping"
        case .porn: return "Porn"
        case .alcohol: return "Alcohol"
        case .weed: return "Weed"
        case .doomscroll: return "Doomscrolling"
        case .custom: return "Your goal"
        }
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
