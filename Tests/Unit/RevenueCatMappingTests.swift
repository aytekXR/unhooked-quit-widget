import Foundation
import PaywallKit
import Testing
@testable import Unhooked

// E7.1 app half (Session 24) — the adapter's PURE mapping half, pinned over the
// neutral `CustomerEntitlementView` struct (R24.3): every test here is RC-free
// and Linux-harnessable; the single RC-importing file only EXTRACTS
// `EntitlementInfo` → this struct (its real-SDK pins ride the green commit's
// Contract_RevenueCat file, built on the docs-verified public test inits).
//
// The load-bearing S23 carried nuance becomes type-exercised here: an
// entitlement that is PRESENT but inactive maps to `isActive: false` — NEVER
// nil — so `EntitlementStateMapper` reads `.lapsed`, never a silent `.never`
// (an adapter that mapped lapsed→nil would misroute a lapsed subscriber as a
// never-subscriber, hiding the win-back surface forever).
//
// RED: `RevenueCatEntitlementMapper.snapshot(from:)` is inert (always nil) and
// `ProductCatalog` vends no tiers — the designed failures below are the
// mapping pins; red evidence = the CI run on the red commit (app-lane
// mechanics), with the pure subset predicted by the local Linux harness first.

@Suite("E7.1 · RevenueCat entitlement mapping (pure)")
struct RevenueCatMappingTests {
    private static let monthlySKU = "com.beyondkaira.ballast.monthly"
    private static let annualSKU = "com.beyondkaira.ballast.annual"
    private static let annualHiSKU = "com.beyondkaira.ballast.annual.hi"

    private static func view(
        sku: String = annualSKU,
        periodType: PeriodType = .normal,
        isActive: Bool = true,
        willRenew: Bool = true
    ) -> CustomerEntitlementView {
        CustomerEntitlementView(
            productIdentifier: sku, periodType: periodType,
            isActive: isActive, willRenew: willRenew
        )
    }

    /// M1 (designed-red): present-but-inactive ⇒ a REAL snapshot with
    /// `isActive: false` — never nil (the twice-documented adapter seam rule).
    @Test func test_rcMapping_presentButInactive_mapsToInactiveSnapshot_neverNil() throws {
        let snapshot = try #require(
            RevenueCatEntitlementMapper.snapshot(from: Self.view(isActive: false)),
            "a PRESENT entitlement must always yield a snapshot — nil is reserved for never-purchased"
        )
        #expect(snapshot.isActive == false, "the source's inactive verdict must survive the mapping")
    }

    /// M2 (born-green at red — the inert mapper coincidentally returns nil for
    /// everything; kept as the permanent absent-arm pin, not red evidence).
    @Test func test_rcMapping_absentEntitlement_mapsToNilSnapshot_neverState() {
        let snapshot = RevenueCatEntitlementMapper.snapshot(from: nil)
        #expect(snapshot == nil, "no entitlement ever granted ⇒ nil snapshot")
        #expect(
            EntitlementStateMapper.state(from: snapshot) == .never,
            "nil snapshot must read .never downstream"
        )
    }

    /// M3 (designed-red): the RC `.trial` period discriminator carries through
    /// to `.trial` — the only trial gate (docs-verified: PeriodType.trial).
    @Test func test_rcMapping_trialPeriod_carriesTrialThroughToTrialState() throws {
        let snapshot = try #require(
            RevenueCatEntitlementMapper.snapshot(from: Self.view(periodType: .trial))
        )
        #expect(
            EntitlementStateMapper.state(from: snapshot) == .trial(product: .annual),
            "an active .trial period on the annual SKU must read .trial(.annual)"
        )
    }

    /// M4 (designed-red): SKU → tier rides ProductCatalog — monthly maps
    /// `.monthly`, BOTH annual A/B arms map `.annual` (R23.6: the price arm is
    /// analytics-only, never an entitlement distinction).
    @Test func test_rcMapping_skuResolvesTierViaCatalog_bothAnnualArmsAnnual() throws {
        let monthly = try #require(RevenueCatEntitlementMapper.snapshot(from: Self.view(sku: Self.monthlySKU)))
        #expect(monthly.product == .monthly)

        let control = try #require(RevenueCatEntitlementMapper.snapshot(from: Self.view(sku: Self.annualSKU)))
        #expect(control.product == .annual)

        let variant = try #require(RevenueCatEntitlementMapper.snapshot(from: Self.view(sku: Self.annualHiSKU)))
        #expect(variant.product == .annual, "the $39.99 arm is the SAME .annual tier")
    }

    /// M4b (designed-red): an ACTIVE entitlement with a SKU the catalog does
    /// not know still yields a snapshot (tier defaults to the primary
    /// `.annual`) — architecture §8's grace direction: a catalog gap must
    /// never lock a paying user out (the anti-Quittr rule, applied to config).
    @Test func test_rcMapping_unknownSKU_stillHonorsActiveEntitlement() throws {
        let snapshot = try #require(
            RevenueCatEntitlementMapper.snapshot(from: Self.view(sku: "com.beyondkaira.ballast.future")),
            "an unrecognized SKU must not drop an active entitlement"
        )
        #expect(snapshot.isActive)
        #expect(snapshot.product == .annual, "unknown SKU defaults to the primary tier for display/analytics only")
    }

    /// M5 (designed-red): the end-to-end composition of the S23 nuance —
    /// present + inactive reads `.lapsed`, never `.never`.
    @Test func test_rcMapping_presentInactive_readsLapsedNeverNever() {
        let state = EntitlementStateMapper.state(
            from: RevenueCatEntitlementMapper.snapshot(from: Self.view(isActive: false))
        )
        #expect(
            state == .lapsed(product: .annual),
            "a lapsed subscriber must read .lapsed — .never would hide every win-back surface"
        )
    }
}
