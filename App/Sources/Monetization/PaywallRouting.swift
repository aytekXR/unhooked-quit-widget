import Foundation
import PaywallKit

/// E7.1 — the pure summary-CTA routing decision (the `QuizGateRouting`
/// precedent: decisions are pure enums the unit tier pins; views stay thin).
/// `PostGateRootView` consults this ONLY when a live `EntitlementModel`
/// exists — dormant builds never reach it and fall to the dashboard (R24.2),
/// so the M1 loop is untouched until the operator's key lands.
enum PostSummaryDestination: Equatable, Sendable {
    /// Not entitled (never/lapsed): the hard-ish paywall (MVP §6 — nothing
    /// past the summary without trial/purchase; the teaser escape is E7.2's).
    case paywall
    /// Trial or active: straight to the dashboard — an entitled user must
    /// never meet the paywall on the onboarding path.
    case dashboard
}

/// E7.2 (R25.7) — the post-gate root's re-entry decision (the dashboard
/// branch, re-evaluated on task/scenePhase, live-model builds only): where a
/// returning user lands given entitlement + the teaser grant. Distinct from
/// `PostSummaryDestination` because the re-present carries its SOURCE (the
/// second-impression funnel split C1/R25.4 exists for).
enum ReentryDestination: Equatable, Sendable {
    case dashboard
    case paywall(source: PaywallSource)
}

enum PaywallRouting {
    static func postSummaryDestination(state: EntitlementState) -> PostSummaryDestination {
        state.isEntitled ? .dashboard : .paywall
    }

    /// E7.2 (R25.7): entitled WINS (checked first — a purchase never meets a
    /// stale teaser); an unexpired teaser grants the dashboard; an expired
    /// teaser re-presents the paywall with source `.teaserExpiry`. `now` is
    /// injected — no ambient clock (the TeaserPolicy discipline). A nil
    /// teaser also lands on the dashboard: the re-entry gate only ever acts
    /// on a taken-and-expired grant — non-teaser users are governed by the
    /// summary-CTA wall alone (never a surprise wall on re-entry).
    ///
    /// E7.3 (R26.6): `winbackEligible` slots the win-back OFFER between the
    /// entitled guard and the teaser rules — precedence entitled > winback
    /// (`.lapsed` only) > teaser-expiry. The default `false` keeps every
    /// E7.2 call site byte-compatible, and false is exactly what a dormant
    /// build always passes (R26.10: no keys ⇒ no lapse observed ⇒ never
    /// eligible), so `.paywall(source: .winback)` is unreachable dormant.
    static func reentryDestination(
        state: EntitlementState, teaserExpiresAt: Date?,
        winbackEligible: Bool = false, now: Date
    ) -> ReentryDestination {
        guard !state.isEntitled else { return .dashboard }
        // E7.3 red: inert seam — the winback branch lands green.
        guard teaserExpiresAt != nil else { return .dashboard }
        return TeaserPolicy.isExpired(teaserExpiresAt, now: now)
            ? .paywall(source: .teaserExpiry)
            : .dashboard
    }
}
