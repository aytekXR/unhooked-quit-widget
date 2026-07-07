import Foundation

/// Stateless pure-function computation core. Time is ALWAYS a parameter; this file holds
/// no clock and never reads `Date()`/`ProcessInfo`. This is the file the E1.1 coverage bar
/// measures (100% branch coverage) — keep forwarders and types out of it.
public struct StreakCalculator: Sendable {
    public init() {}

    // RED (E1.1 commit A): sentinel bodies so the named tests and the branch-coverage
    // suite compile and FAIL (test-suite §7.1 — red first, always). Minimal green math
    // lands in commit B.

    /// Momentum as a fraction 0...1 = clean ÷ total tracked (architecture §5.1).
    public static func momentum(cleanSeconds: Int, totalSeconds: Int) -> Double {
        -1
    }

    /// Money saved, pro-rated from weekly spend by clean time. `Decimal` end-to-end.
    public static func moneySaved(weeklySpend: Decimal, cleanSeconds: Int) -> Decimal {
        -1
    }

    /// First milestone not yet reached at `elapsedSeconds`.
    public static func nextMilestone(elapsedSeconds: Int, in table: MilestoneTable) -> Milestone? {
        Milestone(afterHours: -1, title: "red-stub", body: "red-stub")
    }

    /// The E1.1 headline: a fully-derived readout from the snapshot and an injected `now`.
    /// `monotonic:` stays `nil` in E1.1 (clock guard is E1.2, same entry point).
    public static func currentStreak(
        for quit: QuitSnapshot,
        now: Date,
        monotonic: MonotonicNow? = nil,
        milestones: MilestoneTable? = nil
    ) -> StreakValue {
        StreakValue(elapsedSeconds: 1, moneySaved: -1, momentum: -1)
    }
}
