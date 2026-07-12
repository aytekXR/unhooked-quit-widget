import Foundation
import PaywallKit

/// E7.3 (R26.1/R26.3/R26.4) — the pure win-back eligibility predicate (the
/// TeaserPolicy twin: injected `now`, no ambient clock, no Calendar/TimeZone —
/// the 7-day window is a wall-clock DURATION, timezone-invariant BY
/// CONSTRUCTION and proven by the ×3-zone Linux harness).
///
/// The lapse clock is the APP-SIDE observed-lapse stamp
/// (`AppSettings.lapseObservedAt`, R26.1): Apple win-back offers cannot
/// express "lapsed ≥ 7 days" (App Store Connect eligibility is
/// months-granular and requires prior PAID duration — docs-verified against
/// ASC help + purchases-ios 5.80.3), and RevenueCat Targeting has no
/// lapse-cohort condition — so eligibility is app-determined and the offer
/// mechanics are a promotional offer on the SAME `ballast.annual` SKU
/// (R26.2). Observed-lapse is fail-SAFE: a user who reopens late gets the
/// window from re-observation — never early, only ever late.
///
/// Eligibility = ANY `.lapsed` tier (R26.4, operator-vetoable): the machine
/// deliberately carries no trial-vs-paid history (S23 — no dates, no clock),
/// so "post trial-lapse" is honestly implementable only as "post lapse"; a
/// lapsed-monthly user meets the annual offer as an upsell.
enum WinbackPolicy {
    /// 7 days, as a DURATION (R26.3 — never calendar-anchored; ADR-11 is
    /// scoped to displayed Day-N).
    static let eligibilityWindow: TimeInterval = 7 * 86_400

    /// `true` iff the state is `.lapsed` AND the observed-lapse stamp is at
    /// least `eligibilityWindow` old (boundary INCLUSIVE — sc.26's
    /// "…Plus7Days_notBefore"). A nil stamp is never eligible: dormant
    /// builds observe no lapse, ever (R26.10).
    static func isEligible(state: EntitlementState, lapseObservedAt: Date?, now: Date) -> Bool {
        // E7.3 red: inert seam — the real predicate lands green.
        false
    }
}
