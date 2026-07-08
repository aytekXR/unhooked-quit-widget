import Foundation

/// The DI/mock seam (test-suite §3 names `StreakCalculating`): view-model tests depend on
/// `any StreakCalculating` and inject a fake; production injects `StreakCalculator()`.
/// Thin forwarders live here, in a separate file from the computation core, so
/// straight-line forwarding does not dilute the computation file's coverage number.
public protocol StreakCalculating: Sendable {
    func currentStreak(
        for snapshot: StreakSnapshot,
        now: Date,
        monotonic: MonotonicNow?,
        milestones: MilestoneTable?
    ) -> StreakValue
    func momentum(cleanSeconds: Int, totalSeconds: Int) -> Double
    func moneySaved(weeklySpend: Decimal, cleanSeconds: Int) -> Decimal
    func nextMilestone(elapsedSeconds: Int, in table: MilestoneTable) -> Milestone?
}

public extension StreakCalculating {
    /// The canonical two-argument form (protocol requirements cannot carry default args).
    func currentStreak(for snapshot: StreakSnapshot, now: Date) -> StreakValue {
        currentStreak(for: snapshot, now: now, monotonic: nil, milestones: nil)
    }
}

extension StreakCalculator: StreakCalculating {
    public func currentStreak(
        for snapshot: StreakSnapshot,
        now: Date,
        monotonic: MonotonicNow?,
        milestones: MilestoneTable?
    ) -> StreakValue {
        Self.currentStreak(for: snapshot, now: now, monotonic: monotonic, milestones: milestones)
    }

    public func momentum(cleanSeconds: Int, totalSeconds: Int) -> Double {
        Self.momentum(cleanSeconds: cleanSeconds, totalSeconds: totalSeconds)
    }

    public func moneySaved(weeklySpend: Decimal, cleanSeconds: Int) -> Decimal {
        Self.moneySaved(weeklySpend: weeklySpend, cleanSeconds: cleanSeconds)
    }

    public func nextMilestone(elapsedSeconds: Int, in table: MilestoneTable) -> Milestone? {
        Self.nextMilestone(elapsedSeconds: elapsedSeconds, in: table)
    }
}
