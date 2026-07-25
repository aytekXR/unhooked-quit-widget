import Foundation

/// E5.1 — the age-gate boundary outcome. Two states only: there is no "unknown"
/// (the container fails closed while the store opens) and no stored "blocked"
/// (a blocked user persists NOTHING and simply re-meets the gate on relaunch —
/// never a permanent lockout from one mis-picked year; PM §4, Session 16).
enum AgeGateDecision: Equatable, Sendable {
    case pass
    case blocked
}

/// Pure boundary decision, I/O-free so it is unit-testable without UI or clock
/// (the LaunchRouter precedent). The current year arrives as a plain Int derived
/// from the injected ClockProviding seam at the composition root — production code
/// never calls Date() (Architect MUST-FIX #4).
enum AgeGate {
    /// The adopted conservative rule (PM §4, operator-vetoable): PASS only when the
    /// year PROVES the user is at least 17. Birth-year-only entry is deliberate PII
    /// minimization, so a difference of exactly 17 — who could still be 16 with a
    /// birthday pending — blocks. "Could be under 17" blocks; nothing else may pass.
    static func evaluate(birthYear: Int, currentYear: Int) -> AgeGateDecision {
        currentYear - birthYear >= 18 ? .pass : .blocked
    }

    /// S46 — the gate's OWN calendar, pinned Gregorian, never `Calendar.current`.
    ///
    /// `evaluate` counts YEARS, and a "year" is only ~365 days in a SOLAR calendar.
    /// `Calendar.current` follows the device's Settings › General › Language & Region ›
    /// Calendar choice, so the boundary silently changes meaning per device:
    ///
    /// - **Islamic** (civil / umm-al-qura — a one-tap Settings option): ~354-day years,
    ///   so an 18-year difference is only ~17.5 SOLAR years and the youngest passer is
    ///   **16.60 solar years old** (measured, not reasoned: the Linux probe in the S46
    ///   session log). A 17+ gate that admits 16-year-olds is a safety AND an App
    ///   Review defect.
    /// - **Japanese**: `component(.year:)` yields the ERA year (Reiwa 8 ⇒ `8`), so
    ///   `selectableYears` becomes `-112...8` — the birth-year wheel renders negative
    ///   years and no user in that locale can complete onboarding at all.
    ///
    /// Gregorian is what every other day-math site in the project already pins
    /// (`StreakCardModel`, `AdherenceCalculator`, `StreakTimelinePlanner`); the gate
    /// was the one site that read the ambient calendar. `CalendarSourceLintTests`
    /// keeps it that way by construction.
    static let calendar = Calendar(identifier: .gregorian)

    /// The `currentYear` the boundary consumes: derived from the INJECTED clock's
    /// instant (production never calls `Date()` here — Architect MUST-FIX #4) through
    /// the pinned calendar above, so the gate means the same thing on every device.
    static func currentYear(at now: Date) -> Int {
        calendar.component(.year, from: now)
    }
}
