import Foundation
import PaywallKit
import Testing
@testable import Unhooked

// E7.3 (R26.6) — the win-back slot in the pure re-entry decision:
// precedence entitled > winback (`.lapsed`-only) > teaser-expiry. The
// `winbackEligible` parameter defaults `false` — every E7.2 call site stays
// byte-compatible, and false is exactly what a dormant build always passes
// (R26.10), so `.paywall(source: .winback)` is structurally unreachable
// dormant. The win-back presentation is an OFFER, not a wall (it carries
// the dismiss affordance, R26.6) — but the ROUTING decision is pinned here.
//
// RED: `reentryDestination` ignores `winbackEligible` (inert seam) — the
// winback-source and precedence pins fail by design; the fall-through and
// dormant pins are born-green guards (permanent).

// Fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z.
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)

@MainActor
@Suite("E7.3 · win-back re-entry routing")
struct WinbackReentryTests {
    /// Designed-red: a lapsed, winback-eligible user's re-entry presents the
    /// paywall with the OFFER source — the funnel split `PaywallSource.winback`
    /// has existed for since E8.1 (mvp §5's paywall_viewed source row).
    @Test func test_reentry_winbackEligible_representsWinbackSource() {
        #expect(
            PaywallRouting.reentryDestination(
                state: .lapsed(product: .annual), teaserExpiresAt: nil,
                winbackEligible: true, now: epoch
            ) == .paywall(source: .winback),
            "a lapsed + eligible re-entry meets the offer (source .winback — never .onboarding, never .teaserExpiry)"
        )
    }

    /// Designed-red (the precedence pin): entitled ALWAYS wins (an offer
    /// must never interrupt a paying user); below that, winback outranks the
    /// generic teaser-expiry wall — a real former subscriber with a live
    /// 50%-off offer sees the OFFER, not the wall (R26.6, vetoable).
    @Test func test_reentry_teaserVsWinback_precedence() {
        let expiredTeaser = epoch.addingTimeInterval(-1)

        #expect(
            PaywallRouting.reentryDestination(
                state: .active(product: .annual), teaserExpiresAt: expiredTeaser,
                winbackEligible: true, now: epoch
            ) == .dashboard,
            "entitled WINS over everything — an active subscriber never meets any paywall on re-entry"
        )
        #expect(
            PaywallRouting.reentryDestination(
                state: .lapsed(product: .annual), teaserExpiresAt: expiredTeaser,
                winbackEligible: true, now: epoch
            ) == .paywall(source: .winback),
            "for a lapsed + eligible user the OFFER outranks the expired-teaser wall (entitled > winback > teaser-expiry)"
        )
    }

    /// Born-green guard (permanent): winback-ineligible falls through to the
    /// unchanged E7.2 teaser rules — the whole existing teaser cohort sees
    /// ZERO behavior change (the defaulted-parameter guarantee, R26.6).
    @Test func test_reentry_winbackIneligible_fallsThroughToTeaserRules() {
        let expiredTeaser = epoch.addingTimeInterval(-1)

        #expect(
            PaywallRouting.reentryDestination(
                state: .lapsed(product: .annual), teaserExpiresAt: expiredTeaser,
                winbackEligible: false, now: epoch
            ) == .paywall(source: .teaserExpiry),
            "ineligible ⇒ the E7.2 expired-teaser re-present, byte-identical to before E7.3"
        )
        #expect(
            PaywallRouting.reentryDestination(
                state: .never, teaserExpiresAt: nil,
                winbackEligible: false, now: epoch
            ) == .dashboard,
            "ineligible + no teaser ⇒ dashboard, exactly as E7.2 ruled"
        )
    }

    /// Born-green guard (R26.10, permanent — the pure half of the dormancy
    /// pin): `winbackEligible: false` — the only value a dormant build can
    /// ever produce — can NEVER surface `.paywall(source: .winback)`,
    /// regardless of entitlement state.
    @Test func test_dormant_neverSurfacesWinback() {
        for state in [EntitlementState.never, .lapsed(product: .annual), .lapsed(product: .monthly)] {
            let destination = PaywallRouting.reentryDestination(
                state: state, teaserExpiresAt: nil,
                winbackEligible: false, now: epoch
            )
            #expect(
                destination != .paywall(source: .winback),
                "no eligibility ⇒ no winback surface, for state \(state) — dormancy by construction"
            )
        }
    }
}
