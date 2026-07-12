import Foundation
import PaywallKit
import Testing
@testable import Unhooked

// E7.2 (R25.7) — the teaser grant's pure arithmetic + the re-entry routing
// decision. The teaser is a 24-hour WALL-CLOCK DURATION ("1 day of access",
// MVP §6) — a bare absolute-Date comparison, timezone-invariant BY
// CONSTRUCTION and proven so by the ×3-zone Linux harness run (UTC / Berlin /
// Kiritimati; the QA clock-adjacent gate — these bodies run over the exact
// shipping bytes before any push). `now` is always injected; no ambient
// clock exists anywhere on this path.
//
// Two of the four plan-named E7.2 tests live here VERBATIM
// (implementation-plan E7.2 row): `test_teaserMode_expiresAfter1Day_representsPaywall`
// and `test_teaserExpiry_paywallSource_isTeaserExpiry`.
//
// RED: `TeaserPolicy` and `PaywallRouting.reentryDestination` are inert
// stubs (no grant math; always the dashboard) — the grant/expiry/re-present
// pins fail by design until green. The entitled-wins and nil-teaser pins are
// born-green on the inert stub BY DESIGN (permanent guards that catch a
// green which re-presents over an entitlement or invents a grant).

// Fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z.
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)

@MainActor
@Suite("E7.2 · teaser policy + re-entry routing")
struct TeaserPolicyTests {
    /// Plan-named (designed-red): the 1-day grant — expiry lands exactly
    /// 86_400 wall-clock seconds out; one second shy of the boundary still
    /// grants the dashboard; the boundary instant re-presents the paywall.
    @Test func test_teaserMode_expiresAfter1Day_representsPaywall() {
        #expect(
            TeaserPolicy.expiry(from: epoch) == epoch.addingTimeInterval(86_400),
            "the grant is one day as a DURATION — now + 86_400s, never a calendar-day anchor"
        )

        let expiresAt = epoch.addingTimeInterval(86_400)
        #expect(
            PaywallRouting.reentryDestination(
                state: .never, teaserExpiresAt: expiresAt,
                now: epoch.addingTimeInterval(86_399)
            ) == .dashboard,
            "one second before expiry the grant still holds"
        )
        #expect(
            PaywallRouting.reentryDestination(
                state: .never, teaserExpiresAt: expiresAt,
                now: expiresAt
            ) == .paywall(source: .teaserExpiry),
            "from the boundary instant onward the wall returns (MVP §6: the teaser defers, never waives)"
        )
    }

    /// Plan-named (designed-red): the re-present carries the SECOND-IMPRESSION
    /// source — `teaser_expiry`, the funnel split the teaser A/B is measured
    /// by (R25.4; test-suite §1.4 sc.36). Collapsing it into `onboarding`
    /// would make the teaser arm's post-expiry conversion indistinguishable
    /// from its first view.
    @Test func test_teaserExpiry_paywallSource_isTeaserExpiry() {
        let destination = PaywallRouting.reentryDestination(
            state: .lapsed(product: .annual),
            teaserExpiresAt: epoch,
            now: epoch.addingTimeInterval(1)
        )
        #expect(destination == .paywall(source: .teaserExpiry))
        #expect(PaywallSource.teaserExpiry.rawValue == "teaser_expiry",
                "the audited wire value, sc.36's spelling")
    }

    /// Born-green guard (the inert stub coincidentally routes to the
    /// dashboard; kept as the PERMANENT entitled-wins pin): an entitlement is
    /// checked FIRST — an expired teaser must never re-present over a trial
    /// or a paid state (a purchase never meets a stale teaser, R25.7).
    @Test func test_teaserActive_butEntitled_entitlementWins() {
        for state in [EntitlementState.trial(product: .annual), .active(product: .monthly)] {
            #expect(
                PaywallRouting.reentryDestination(
                    state: state, teaserExpiresAt: epoch, now: epoch.addingTimeInterval(999_999)
                ) == .dashboard,
                "entitled wins over any teaser state — never lock out a paying user"
            )
        }
    }

    /// Born-green guard: no teaser was ever taken (`nil`) ⇒ no expiry exists
    /// and re-entry stays the dashboard — the gate simply isn't in play (a
    /// non-teaser user's re-entry is governed by the summary-CTA wall alone).
    @Test func test_noTeaserTaken_neverRepresents() {
        #expect(TeaserPolicy.isExpired(nil, now: .distantFuture) == false)
        #expect(
            PaywallRouting.reentryDestination(
                state: .never, teaserExpiresAt: nil, now: .distantFuture
            ) == .dashboard
        )
    }

    /// Designed-red: the boundary semantics of the pure predicate itself —
    /// expired from the exact instant (`now >= expiresAt`), not a second
    /// later (the harness runs this ×3 host zones to prove no hidden
    /// Calendar/TimeZone read).
    @Test func test_isExpired_boundaryIsInclusive() {
        #expect(TeaserPolicy.isExpired(epoch, now: epoch) == true,
                "the boundary instant IS expired — a grant is [take, take+86400)")
        #expect(TeaserPolicy.isExpired(epoch, now: epoch.addingTimeInterval(-1)) == false)
        #expect(TeaserPolicy.isExpired(epoch, now: epoch.addingTimeInterval(1)) == true)
    }
}
