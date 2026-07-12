import Foundation
import PaywallKit
import Testing
@testable import Unhooked

// E7.3 (R26.1/R26.3/R26.4) — the pure win-back eligibility predicate: an
// app-side observed-lapse stamp + an injected clock, because NEITHER Apple
// NOR RevenueCat can compute "7 days post trial-lapse" server-side
// (ASC win-back eligibility is months-granular + paid-history-gated; RC
// Targeting has no lapse-cohort condition — Session 26 docs-verified). The
// 7-day window is a wall-clock DURATION (7×86_400s), timezone-invariant BY
// CONSTRUCTION (the TeaserPolicy discipline; ×3-zone Linux harness), with an
// INCLUSIVE boundary (sc.26 "…Plus7Days_notBefore").
//
// Two of the three plan-named E7.3 tests live here VERBATIM
// (implementation-plan E7.3 row): `test_winback_eligibility_trialLapsedPlus7Days`
// and `test_winback_notShownToActiveOrNeverTrialed`.
//
// RED: `WinbackPolicy.isEligible` is an inert false-always stub — the
// positive eligibility pins fail by design; the exclusion pins are
// born-green on the stub BY DESIGN (permanent guards that catch a lazy
// green which ignores the state discriminator and would show the offer to
// active/never users).

// Fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z.
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)
private let sevenDays: TimeInterval = 7 * 86_400

@MainActor
@Suite("E7.3 · win-back eligibility policy")
struct WinbackPolicyTests {
    /// Plan-named (designed-red): a lapsed user whose observed-lapse stamp
    /// is at least 7 days old is eligible — at the window and well past it —
    /// and NOT before (the day-6 guard is the "notBefore" half).
    @Test func test_winback_eligibility_trialLapsedPlus7Days() {
        let lapsed = EntitlementState.lapsed(product: .annual)

        #expect(
            WinbackPolicy.isEligible(state: lapsed, lapseObservedAt: epoch, now: epoch.addingTimeInterval(sevenDays)),
            "at exactly lapse + 7 days the offer opens (inclusive boundary, sc.26)"
        )
        #expect(
            WinbackPolicy.isEligible(state: lapsed, lapseObservedAt: epoch, now: epoch.addingTimeInterval(30 * 86_400)),
            "the window has no far edge — a day-30 re-open still meets the offer"
        )
        #expect(
            !WinbackPolicy.isEligible(state: lapsed, lapseObservedAt: epoch, now: epoch.addingTimeInterval(6 * 86_400)),
            "day 6 is NOT eligible — 7 days post lapse, never before"
        )
    }

    /// Plan-named (born-green guard, permanent): never-trialed, trialing,
    /// and active users are NEVER eligible — regardless of any stamp — and
    /// a nil stamp is never eligible regardless of state. This is the guard
    /// that catches a state-blind green (`now >= stamp + 7d` alone would
    /// wrongly offer the discount to an ACTIVE subscriber).
    @Test func test_winback_notShownToActiveOrNeverTrialed() {
        let ripeStamp = epoch
        let ripeNow = epoch.addingTimeInterval(sevenDays)

        #expect(
            !WinbackPolicy.isEligible(state: .never, lapseObservedAt: ripeStamp, now: ripeNow),
            "a never-trialed user has nothing to win back"
        )
        #expect(
            !WinbackPolicy.isEligible(state: .trial(product: .annual), lapseObservedAt: ripeStamp, now: ripeNow),
            "a trialing user is entitled — never an offer target"
        )
        #expect(
            !WinbackPolicy.isEligible(state: .active(product: .annual), lapseObservedAt: ripeStamp, now: ripeNow),
            "an active subscriber must NEVER meet a discount on what they already pay full price for"
        )
        #expect(
            !WinbackPolicy.isEligible(state: .lapsed(product: .annual), lapseObservedAt: nil, now: ripeNow),
            "no observed lapse ⇒ no clock ⇒ never eligible (the dormant floor, R26.10)"
        )
    }

    /// Designed-red: the knife edge — one second shy of the 7-day boundary
    /// is out; the boundary instant itself is IN (inclusive, R26.3). The
    /// window is a bare Date comparison: no Calendar, no TimeZone — the
    /// ×3-zone harness proves the invariance over these exact bytes.
    @Test func test_winbackEligibility_boundaryIsInclusiveAtSevenDays() {
        let lapsed = EntitlementState.lapsed(product: .annual)
        let boundary = epoch.addingTimeInterval(sevenDays)

        #expect(
            !WinbackPolicy.isEligible(state: lapsed, lapseObservedAt: epoch, now: boundary.addingTimeInterval(-1)),
            "one second shy of the boundary stays ineligible"
        )
        #expect(
            WinbackPolicy.isEligible(state: lapsed, lapseObservedAt: epoch, now: boundary),
            "the boundary instant is eligible — inclusive, the teaser boundary precedent"
        )
    }

    /// Designed-red (R26.4, operator-vetoable): ANY `.lapsed` tier is
    /// eligible — the machine deliberately carries no trial-vs-paid history
    /// (S23: no dates, no clock), so "post trial-lapse" is honestly
    /// implementable only as "post lapse"; a lapsed-MONTHLY user meets the
    /// annual offer as an upsell.
    @Test func test_winbackEligibility_lapsedProductTier() {
        #expect(
            WinbackPolicy.isEligible(
                state: .lapsed(product: .monthly),
                lapseObservedAt: epoch,
                now: epoch.addingTimeInterval(sevenDays)
            ),
            "a lapsed-monthly user is eligible (any-lapse ruling R26.4 — restricting to .annual is the operator's one-line veto)"
        )
    }

    /// Born-green guard (R26.10, permanent): the dormant floor as an
    /// explicit named pin — no keys ⇒ no live entitlement branch ⇒ no lapse
    /// ever observed ⇒ the stamp stays nil ⇒ never eligible, at any instant.
    @Test func test_winback_dormantNeverObservesLapse() {
        for offset in [0.0, sevenDays, 365.0 * 86_400.0] {
            #expect(
                !WinbackPolicy.isEligible(
                    state: .lapsed(product: .annual),
                    lapseObservedAt: nil,
                    now: epoch.addingTimeInterval(offset)
                ),
                "nil stamp is never eligible — dormancy by construction"
            )
        }
    }
}
