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
/// - no feed on disk ⇒ `.unavailable` (fresh install / post-erase).
struct StreakWidgetComposer: Sendable {
    /// A planned timeline plus the selected quit's rich state for the templates
    /// (money/momentum/milestones render from the DTO; entries carry timing only).
    struct Composition: Sendable {
        var plan: StreakWidgetTimelinePlan
        var quit: WidgetQuitState?
    }

    /// E6.2 red: inert — always `.unavailable`. The green half implements selection,
    /// state mapping (explicit `TimeZone(identifier:)` — never a decoded TimeZone),
    /// and caller-computed milestone crossings.
    static func compose(
        feed: WidgetFeed?,
        configuredQuitID: UUID?,
        now: Date,
        horizonDays: Int
    ) -> Composition {
        struct NoState: StreakWidgetStateReading {
            func read() -> StreakWidgetState? { nil }
        }
        let plan = StreakTimelinePlanner().plan(reading: NoState(), now: now, horizonDays: horizonDays)
        return Composition(plan: plan, quit: nil)
    }
}
