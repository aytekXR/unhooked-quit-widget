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
}
