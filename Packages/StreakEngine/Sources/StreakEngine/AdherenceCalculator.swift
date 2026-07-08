import Foundation

// E1.4 — Reduce-mode adherence (ADR-10: a first-class engine mode, not a variant).
// This is the package's FIRST timezone-aware math, so it lives in its own file with its
// own 100%-branch bar, away from StreakCalculator.swift's absolute-time core: day
// boundaries are computed in the quit's timezone, absolute time is never re-derived.
// Time stays injected — occurrences, window, and timezone are all values; no clock reads.
extension StreakCalculator {

    /// Counts allowance-adherent days: a calendar day (in `timezone`) is adherent when
    /// the occurrences that fall inside it number at or under `allowancePerDay` —
    /// adherent, not abstinent (a day with logged occurrences still counts; that IS the
    /// Reduce framing). Days are evaluated whole: the window selects WHICH days (every
    /// day it touches, boundary day at `window.end`'s exact start excluded, zero-duration
    /// windows evaluating the single day they fall in), never partial-day slices — a
    /// day's verdict must not depend on where a query window happens to cut it.
    /// DST transitions are one calendar day of whatever wall length (23h/25h) the
    /// timezone gives them; the repeated fall-back hour folds into that single day.
    public static func adherence(
        for occurrences: [Date],
        in window: DateInterval,
        allowancePerDay: Int,
        timezone: TimeZone
    ) -> Adherence {
        // A fixed Gregorian calendar in the quit's timezone — never `.current` or
        // `.autoupdatingCurrent`, which would smuggle device state into pure math.
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timezone

        let allowance = max(0, allowancePerDay)
        var adherent = 0
        var evaluated = 0
        var dayStart = calendar.startOfDay(for: window.start)
        repeat {
            // Foundation owns the day length here: byAdding handles 23h/25h DST days, so
            // the repeated fall-back hour folds into one evaluated day by construction —
            // but its result must be re-anchored to startOfDay: a spring-forward AT local
            // midnight (America/Santiago) skips 00:00, byAdding snaps to 01:00, and an
            // unanchored chain would keep that 01:00 wall time for every later boundary
            // (Session 04 review finding). Unwrap is total: adding one day on a fixed
            // Gregorian calendar cannot fail, and crashing would still beat silently
            // mis-measuring an adherence day.
            let dayEnd = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: dayStart)!)
            let units = occurrences.count { $0 >= dayStart && $0 < dayEnd }
            if units <= allowance { adherent += 1 }
            evaluated += 1
            dayStart = dayEnd
        } while dayStart < window.end
        return Adherence(adherentDays: adherent, evaluatedDays: evaluated)
    }
}
