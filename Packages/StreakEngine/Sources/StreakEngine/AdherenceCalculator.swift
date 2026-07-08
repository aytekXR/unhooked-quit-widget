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
        // Sentinel (red): a readout no real window can produce.
        Adherence(adherentDays: -1, evaluatedDays: -1)
    }
}
