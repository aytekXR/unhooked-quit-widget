import Foundation
import StreakEngine

/// UIR-2 (Session 34) — the plain-value inputs `StreakDashboardCard` renders. Kept as a
/// value type (never the SwiftData `@Model` `Quit`) so the card is trivially fixture-able
/// in the snapshot lane and the a11y-audit mount without a live `ModelContext`, and so a
/// snapshot render can never touch a store.
struct StreakCardModel: Equatable, Sendable {
    /// ADR-11 1-based CALENDAR day in the quit's FIXED start timezone — NOT
    /// `StreakValue.days` (which is timezone-invariant 24h blocks). See
    /// `DashboardCardComposer.calendarDayNumber`.
    let dayNumber: Int
    /// Exact realized savings (`StreakValue.moneySaved`); the card formats it with
    /// `currencyCode`, zero fraction digits. `<= 0` hides the money section.
    let moneySaved: Decimal
    let currencyCode: String
    /// Momentum as a fraction 0...1 (`StreakValue.momentum`); the card shows the rounded
    /// percent and the ring fills to it.
    let momentumFraction: Double
    /// Progress toward the next milestone rung, 0...1, or `nil` to omit the bar (no
    /// ladder, or every rung climbed — never a fabricated target).
    let milestoneProgress: Double?
    /// Discreet mode hides the money section and neutralizes the ring (R22.2).
    let isDiscreet: Bool
    /// Reduce-goal mode (ADR-10). Currently renders identically to a quit goal; the
    /// adherence-framing copy is §3-blocked (`DashboardCopy.reduceModeFraming`).
    let isReduceMode: Bool
    /// A streak frozen by the ADR-7 reboot/clock-rollback cap
    /// (`StreakValue.clockSanity == .clockRolledBack`): the numbers are still valid, the
    /// ring goes neutral, and there is no ticking. Not a problem state.
    let isFrozen: Bool
}

/// Pure display derivations for the dashboard card — separated from the view so the unit
/// lane (and a Linux scratch harness) can pin them. Everything takes explicit inputs;
/// nothing reads an ambient clock, `TimeZone.current` (except the documented pre-E6.2
/// fallback), or a store.
enum DashboardCardComposer {
    /// ADR-11's displayed "Day N": the 1-based count of CALENDAR days from the quit's
    /// start to `now`, both measured in the quit's FIXED start timezone and anchored at
    /// LOCAL NOON. Noon anchoring is what makes the count immune to DST shifts and to a
    /// streak that started just before local midnight — this is the exact algorithm
    /// `StreakTimelinePlanner.daysBetween` uses for the widget's "Day N", so the two
    /// surfaces can never disagree (pinned by `DashboardCardComposerTests`).
    ///
    /// NEVER `StreakValue.days + 1`: that is timezone-invariant absolute 24h blocks and
    /// diverges from the calendar day whenever a streak started before the user's local
    /// midnight.
    static func calendarDayNumber(startAt: Date, timeZoneIdentifier: String, now: Date) -> Int {
        // Pre-E6.2 rows carry an empty identifier until the launch backfill runs;
        // `TimeZone(identifier: "")` fails, so fall back to the device zone — the same
        // fallback `QuitRepository.rebuildSnapshots()` uses for the feed.
        let zone = TimeZone(identifier: timeZoneIdentifier) ?? .current
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        func noon(of date: Date) -> Date? {
            let day = calendar.dateComponents([.year, .month, .day], from: date)
            return calendar.date(
                from: DateComponents(year: day.year, month: day.month, day: day.day, hour: 12)
            )
        }
        guard let startNoon = noon(of: startAt), let nowNoon = noon(of: now) else { return 1 }
        let days = calendar.dateComponents([.day], from: startNoon, to: nowNoon).day ?? 0
        return max(1, days + 1)
    }

    /// Progress toward the next milestone rung, 0...1, through the engine's own boundary
    /// semantics (a rung you are exactly AT is earned). `nil` when there is no ladder or
    /// every rung is climbed — the dashboard OMITS the bar rather than fabricating a full
    /// one (an earned ladder needs no further nudge; a "next milestone" label with no
    /// next milestone would be a lie).
    static func milestoneProgress(elapsedSeconds: Int, milestoneHours: [Int]) -> Double? {
        guard !milestoneHours.isEmpty else { return nil }
        let table = MilestoneTable(
            milestones: milestoneHours.map { Milestone(afterHours: $0, title: "", body: "") }
        )
        guard let next = StreakCalculator.nextMilestone(elapsedSeconds: elapsedSeconds, in: table),
              next.afterHours > 0
        else { return nil }
        return min(1.0, Double(max(0, elapsedSeconds)) / Double(next.afterHours * 3_600))
    }
}
