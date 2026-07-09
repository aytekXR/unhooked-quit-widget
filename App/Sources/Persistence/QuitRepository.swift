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

    private let context: ModelContext
    private let clock: any ClockProviding
    private let widgetRefresher: any WidgetRefreshing
    private let lastKnownGoodStore: LastKnownGoodStore
    private let debounceSleep: @Sendable (Duration) async -> Void

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

    // MARK: - E2.2 red sentinels (cries-wolf bodies so no test passes from birth)

    /// All quits the user has not archived, in widget-selector order.
    func activeQuits() throws -> [Quit] {
        [] // E2.2 red sentinel
    }

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
        Quit() // E2.2 red sentinel — nothing persisted, no limit enforced
    }

    /// Synchronous local slip log: archive → best, bank the ended streak, restart the
    /// counter — persisted BEFORE returning.
    @discardableResult
    func logSlip(quitID: UUID, note: String?) throws -> Slip {
        Slip() // E2.2 red sentinel — nothing persisted
    }

    /// Records a panic-flow outcome (architecture §5.1 `recordUrgeOutcome`).
    @discardableResult
    func logUrgeEvent(
        quitID: UUID,
        source: PanicSource,
        outcome: UrgeOutcome,
        stepsReached: [PanicStep] = []
    ) throws -> UrgeEvent {
        UrgeEvent() // E2.2 red sentinel — nothing persisted
    }

    /// The streak readout for one quit, routed through the clock-integrity guard with
    /// the device's persisted last-known-good reading (the ADR-7 reboot cap).
    func streakValue(for quitID: UUID) throws -> StreakValue {
        StreakValue(elapsedSeconds: -1, moneySaved: -1, momentum: -1) // E2.2 red sentinel
    }

    /// Test hook: awaits the pending debounced reload, if any. Internal on purpose —
    /// production never waits on widget refreshes.
    func drainPendingWidgetReload() async {
        // E2.2 red sentinel
    }
}
