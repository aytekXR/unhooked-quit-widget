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

    private let context: ModelContext
    private let clock: any ClockProviding
    private let widgetRefresher: any WidgetRefreshing
    private let lastKnownGoodStore: LastKnownGoodStore
    private let debounceSleep: @Sendable (Duration) async -> Void
    private var pendingReload: Task<Void, Never>?

    init(
        container: ModelContainer,
        clock: any ClockProviding,
        widgetRefresher: any WidgetRefreshing,
        lastKnownGoodStore: LastKnownGoodStore,
        debounceSleep: @escaping @Sendable (Duration) async -> Void = { try? await Task.sleep(for: $0) }
    ) {
        self.context = container.mainContext
        self.clock = clock
        self.widgetRefresher = widgetRefresher
        self.lastKnownGoodStore = lastKnownGoodStore
        self.debounceSleep = debounceSleep
    }

    // MARK: - Reads

    /// All quits the user has not archived, in widget-selector order. This is the query
    /// that justifies `#Index<Quit>([\.isArchived, \.sortIndex])` (architecture §4).
    func activeQuits() throws -> [Quit] {
        try context.fetch(
            FetchDescriptor<Quit>(
                predicate: #Predicate { !$0.isArchived },
                sortBy: [SortDescriptor(\.sortIndex)]
            )
        )
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

    /// Advances the device's trusted reading ONLY when BOTH hold:
    ///  1. a guard verdict computed against a pre-existing anchor reads `.normal`
    ///     (never on `.clockRolledBack`/`.timezoneShift` — persisting a disputed wall
    ///     would poison every future reboot-cap baseline; never without an anchor), and
    ///  2. the new reading is CONTINUOUS with the previous trusted reading — the old
    ///     reading itself re-run through the guard as the anchor. A freshly-minted
    ///     quit anchor agrees with the reading it was minted from for ANY wall value,
    ///     so gate 1 alone would let a fresh quit launder a forward-set wall into the
    ///     device-global baseline (Session 06 review MAJOR); the continuity gate
    ///     refuses it (within a boot the uptime delta disputes the wall jump; across a
    ///     reboot the advance stays inside the same cap the display honors).
    private func refreshLastKnownGood(
        anchor: MonotonicAnchor?,
        now: Date,
        reading: MonotonicNow,
        lastKnownGood: MonotonicAnchor?
    ) {
        guard let anchor else { return }
        let verdict = StreakCalculator.sanityCheck(
            anchor: anchor, now: now, monotonic: reading, lastKnownGood: lastKnownGood
        )
        guard verdict == .normal else { return }
        if let previous = lastKnownGood {
            let continuity = StreakCalculator.sanityCheck(
                anchor: previous, now: now, monotonic: reading, lastKnownGood: previous
            )
            guard continuity == .normal else { return }
        }
        lastKnownGoodStore.save(
            MonotonicAnchor(bootID: reading.bootID, uptime: reading.uptime, wallClock: now)
        )
    }
}
