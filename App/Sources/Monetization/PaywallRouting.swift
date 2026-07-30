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
        if case .lapsed = state, winbackEligible {
            return .paywall(source: .winback)
        }
        guard teaserExpiresAt != nil else { return .dashboard }
        return TeaserPolicy.isExpired(teaserExpiresAt, now: now)
            ? .paywall(source: .teaserExpiry)
            : .dashboard
    }

    /// ME-9 (§6.11) — which paywall the Settings *Your plan* row opens, or `nil`
    /// for no row at all. §6.11 asks that section for "restore; win-back row when
    /// eligible; **plan options for never-paid users**", and before this the row
    /// was win-back-only, so someone who never subscribed had no route to the
    /// plans from Settings at all.
    ///
    /// **Widening the row without widening its DESTINATION would have been a
    /// defect, not a feature.** The row's tap goes to `presentLivePaywall`, which
    /// branches on the source: `.winback` swaps the purchase path to
    /// `RevenueCatPurchaser.purchaseWinback()` — a REAL, signed App Store
    /// promotional offer scoped to a lapsed subscriber (S29/R29.6). Handing that
    /// to a `.never` user is both dishonest ("now at half price" of nothing they
    /// ever paid) and un-purchasable, since they do not qualify for the offer in
    /// App Store Connect either. So the two cases return DIFFERENT sources and the
    /// existing branch does the rest — no new mechanism.
    ///
    /// `.settings` is already in `PaywallSource`'s closed enum and already in
    /// MVP §5's `paywall_viewed.source` row, so this adds no analytics vocabulary
    /// and needs no ratification (the privacy-surface gate is untouched).
    ///
    /// Precedence and the deliberate silence in the middle: an ENTITLED user gets
    /// no row (never re-paywall a paid user — the §6.6 contract); an eligible
    /// lapsed user gets the offer; a never-paid user gets the plans; and a lapsed
    /// user still INSIDE the 7-day quiet window gets nothing, which preserves the
    /// win-back policy's deliberate wait rather than routing around it.
    static func planRowSource(state: EntitlementState, winbackEligible: Bool) -> PaywallSource? {
        guard !state.isEntitled else { return nil }
        if winbackEligible { return .winback }
        if case .never = state { return .settings }
        return nil
    }
}
