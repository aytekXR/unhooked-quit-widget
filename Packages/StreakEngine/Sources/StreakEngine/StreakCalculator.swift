import Foundation

/// Stateless pure-function computation core. Time is ALWAYS a parameter; this file holds
/// no clock and never reads `Date()`/`ProcessInfo`. This is the file the E1.1 coverage bar
/// measures (100% branch coverage) — keep forwarders and types out of it.
public struct StreakCalculator: Sendable {
    public init() {}

    private static let secondsPerHour = 3_600
    private static let secondsPerWeek: Decimal = 604_800

    /// Momentum as a fraction 0...1 = cumulative clean ÷ total tracked (architecture §5.1).
    /// Zero tracked time ⇒ 1.0: nothing tracked yet means nothing wasted (the no-shame
    /// reading; the value first drops when a slip introduces a gap in E1.3). Negative clean
    /// reads as 0; the ratio is clamped so inconsistent inputs can never leave 0...1.
    public static func momentum(cleanSeconds: Int, totalSeconds: Int) -> Double {
        guard totalSeconds > 0 else { return 1.0 }
        let ratio = Double(max(0, cleanSeconds)) / Double(totalSeconds)
        return min(1.0, max(0.0, ratio))
    }

    /// Money saved, pro-rated from weekly spend by clean time: `weeklySpend × cleanSeconds
    /// ÷ 604_800`, `Decimal` end-to-end, multiply-BEFORE-divide (divide-first turns exact
    /// results like 365d × $87.50 = $4562.50 into repeating decimals). Returned exact and
    /// unrounded — rounding scale is currency-specific, so it belongs to presentation.
    /// Non-positive spend or clean time ⇒ 0 (never negative; free habits are first-class).
    public static func moneySaved(weeklySpend: Decimal, cleanSeconds: Int) -> Decimal {
        guard weeklySpend > 0, cleanSeconds > 0 else { return 0 }
        return weeklySpend * Decimal(cleanSeconds) / secondsPerWeek
    }

    /// First milestone not yet reached at `elapsedSeconds`. Reached ⇔ `elapsedSeconds >=
    /// afterHours × 3600` (the milestone you are exactly AT is earned), so "next" is the
    /// smallest `afterHours` strictly beyond the elapsed time. Sorted defensively — bundled
    /// JSON carries no ordering guarantee. Empty table or all reached ⇒ nil.
    public static func nextMilestone(elapsedSeconds: Int, in table: MilestoneTable) -> Milestone? {
        table.milestones
            .sorted { $0.afterHours < $1.afterHours }
            .first { $0.afterHours * secondsPerHour > max(0, elapsedSeconds) }
    }

    /// The E1.1 headline: a fully-derived readout from the snapshot and an injected `now`.
    /// Money and momentum use CUMULATIVE clean time (`priorCleanSeconds` + current elapsed),
    /// which equals the current streak for a never-slipped goal and stays correct when E1.3
    /// slip archiving populates the prior bank. `monotonic:` is deliberately unread in E1.1
    /// — the E1.2 clock guard activates through this same entry point; adding a branch on it
    /// now would leave an uncoverable arm under the 100%-branch bar.
    public static func currentStreak(
        for quit: QuitSnapshot,
        now: Date,
        monotonic: MonotonicNow? = nil,
        milestones: MilestoneTable? = nil
    ) -> StreakValue {
        let elapsed = max(0, Int(now.timeIntervalSince(quit.startAt)))
        let clean = max(0, quit.priorCleanSeconds) + elapsed
        let tracked = max(0, Int(now.timeIntervalSince(quit.trackedSince)))
        return StreakValue(
            elapsedSeconds: elapsed,
            moneySaved: moneySaved(weeklySpend: quit.weeklySpend, cleanSeconds: clean),
            momentum: momentum(cleanSeconds: clean, totalSeconds: tracked),
            nextMilestone: milestones.flatMap { nextMilestone(elapsedSeconds: elapsed, in: $0) },
            clockSanity: .normal
        )
    }
}
