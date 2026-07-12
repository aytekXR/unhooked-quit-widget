import Foundation
import WidgetToolkit

/// The provider's testable core: selects ONE quit from the feed, maps it onto the
/// planner's domain-neutral state, computes milestone-crossing instants, and plans the
/// timeline. Lives in Shared so the unit lane can pin it — the WidgetKit provider in
/// Widgets/Sources is a ~5-line shim over this (the extension target links into no
/// test bundle, so anything only IT compiles is untestable; test-suite §2's
/// "TimelineProviders tested" intent is met here).
///
/// Selection rules (step-0 R5, mvp feature 5 — no cross-contamination):
/// - a CONFIGURED quit id binds by UUID, never by position;
/// - a configured id no longer in the feed ⇒ `.unavailable` (an erased/archived quit
///   must never silently repoint a widget at a different habit);
/// - no configuration ⇒ the feed's first quit (the repository's total order) —
///   deterministic, and the ordinary experience for a freshly-added widget;
/// - no feed on disk ⇒ `.unavailable` (fresh install / post-erase);
/// - an unconstructable `TimeZone(identifier:)` ⇒ `.unavailable`, never a device-zone
///   guess (falling back to `.current` would silently defeat ADR-11's travel-immunity
///   for exactly the corrupted-feed case where honesty matters most).
struct StreakWidgetComposer: Sendable {
    /// A planned timeline plus the selected quit's rich state for the templates
    /// (money/momentum/milestones render from the DTO; entries carry timing only).
    struct Composition: Sendable {
        var plan: StreakWidgetTimelinePlan
        var quit: WidgetQuitState?
    }

    static func compose(
        feed: WidgetFeed?,
        configuredQuitID: UUID?,
        now: Date,
        horizonDays: Int
    ) -> Composition {
        guard let feed,
              let quit = select(from: feed.quits, configuredQuitID: configuredQuitID),
              let timeZone = TimeZone(identifier: quit.timeZoneIdentifier)
        else { return unavailable(now: now, horizonDays: horizonDays) }

        let state = StreakWidgetState(
            streakStart: quit.streakStart,
            timeZone: timeZone, // explicit construction from the identifier — never a decoded TimeZone
            generatedAt: feed.generatedAt
        )
        let plan = StreakTimelinePlanner().plan(
            reading: FixedReader(state: state),
            now: now,
            horizonDays: horizonDays,
            milestones: crossings(for: quit, now: now, horizonDays: horizonDays)
        )
        return Composition(plan: plan, quit: quit)
    }

    // MARK: - Pieces

    private static func select(
        from quits: [WidgetQuitState],
        configuredQuitID: UUID?
    ) -> WidgetQuitState? {
        guard let configuredQuitID else { return quits.first }
        return quits.first { $0.id == configuredQuitID }
    }

    /// The quit's milestone rungs as absolute instants (`streakStart + hours`), capped
    /// to the plan's own window plus one day — the ladder reaches a year out, and a
    /// timeline must not carry a boundary WidgetKit could sit on for months (the §11
    /// refresh budget; the planner drops past instants itself).
    private static func crossings(
        for quit: WidgetQuitState,
        now: Date,
        horizonDays: Int
    ) -> [Date] {
        let windowEnd = now + TimeInterval((max(0, horizonDays) + 1) * 86_400)
        return quit.milestoneHours
            .map { quit.streakStart + TimeInterval($0 * 3_600) }
            .filter { $0 > now && $0 <= windowEnd }
    }

    private static func unavailable(now: Date, horizonDays: Int) -> Composition {
        struct NoState: StreakWidgetStateReading {
            func read() -> StreakWidgetState? { nil }
        }
        let plan = StreakTimelinePlanner().plan(
            reading: NoState(), now: now, horizonDays: horizonDays
        )
        return Composition(plan: plan, quit: nil)
    }

    /// One composed state per plan — the planner's single-read discipline holds (its
    /// seam is a file read in production; here the read already happened).
    private struct FixedReader: StreakWidgetStateReading {
        let state: StreakWidgetState
        func read() -> StreakWidgetState? { state }
    }
}
