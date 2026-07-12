import Foundation
import PaywallKit
import Testing
@testable import Unhooked

// E7.1 app half (Session 24) — the pricing-is-config pins (R24.5; test-suite
// §4.2's config-drift purpose, landed on the honest tier): ProductCatalog
// constants + the `Ballast.storekit` file's PARSED content, pinned against the
// MVP §6 canon ($6.99/mo; annual A/B $29.99 vs $39.99; 3-day trial on ANNUAL
// only; the bundled fallback shows the CONTROL arm). The runtime
// "StoreKit surfaces these display prices" claim stays in the DEFERRED
// SKTestSession/RC-sandbox contract tier (R24.1/V-K split — xcodebuild never
// engages a scheme's StoreKit configuration, docs-verified).
//
// JSON pins use JSONSerialization KEY-SET/value semantics, never byte or
// string equality (standing rule: JSONEncoder key order is hash-randomized).
//
// RED: ProductCatalog is inert and Ballast.storekit is not yet in the test
// bundle — every pin below fails by design until green.

/// Test-bundle anchor: `Ballast.storekit` is a UnhookedTests RESOURCE by
/// ruling (R24.5) — a dev/test artifact must never ship in the app bundle.
private final class MonetizationConfigBundleToken {}

@Suite("E7.1 · monetization config (catalog + storekit)")
struct MonetizationConfigTests {
    private static let monthlySKU = "com.beyondkaira.ballast.monthly"
    private static let annualSKU = "com.beyondkaira.ballast.annual"
    private static let annualHiSKU = "com.beyondkaira.ballast.annual.hi"

    /// M6 (designed-red): SKU↔tier — both annual arms are the SAME tier.
    @Test func test_productCatalog_tierForSKU_bothAnnualArmsMapToAnnual() {
        #expect(ProductCatalog.tier(forSKU: Self.monthlySKU) == .monthly)
        #expect(ProductCatalog.tier(forSKU: Self.annualSKU) == .annual)
        #expect(ProductCatalog.tier(forSKU: Self.annualHiSKU) == .annual)
        #expect(ProductCatalog.tier(forSKU: "com.other.app.sku") == nil, "foreign SKUs resolve to no tier")
    }

    /// M7 (designed-red): the RC entitlement identifier — the one key string
    /// the dashboard, the adapter, and the sandbox matrix all agree on.
    @Test func test_productCatalog_entitlementIdentifier_isThePremiumKey() {
        #expect(ProductCatalog.entitlementKey == "premium")
    }

    /// M7b (designed-red): the canonical analytics wire ids — the value-domain
    /// pin the closed enum's free-String `product` field has owed since E8.1
    /// (its committed fixture already fixed the vocabulary: "ballast.annual").
    @Test func test_productCatalog_wireProductIDs_matchTheAuditedFixtureVocabulary() {
        #expect(ProductCatalog.wireProductID(for: .monthly) == "ballast.monthly")
        #expect(ProductCatalog.wireProductID(for: .annual) == "ballast.annual")
    }

    /// M7c (designed-red): the static display prices the DORMANT/offline
    /// bundled paywall renders (architecture §8: control arm) — config
    /// constants, never copy-table literals (R24.5).
    @Test func test_productCatalog_staticDisplayPrices_matchMVP6() {
        #expect(ProductCatalog.monthlyDisplayPrice == "$6.99")
        #expect(ProductCatalog.annualControlDisplayPrice == "$29.99")
    }

    /// M8 (designed-red): parse the REAL `Ballast.storekit` (test-suite §3.2:
    /// the shipping file is the fixture) and pin ids, prices, and the
    /// annual-only 3-day free trial — key-set semantics over the parsed tree.
    @Test func test_storekitConfig_pricesAndTrials_matchMVP6_controlArmIs2999() throws {
        let url = try #require(
            Bundle(for: MonetizationConfigBundleToken.self)
                .url(forResource: "Ballast", withExtension: "storekit"),
            "Ballast.storekit must ship as a UnhookedTests resource (never the app bundle)"
        )
        let root = try #require(
            try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any]
        )
        let groups = try #require(root["subscriptionGroups"] as? [[String: Any]])
        let subscriptions = groups.flatMap { $0["subscriptions"] as? [[String: Any]] ?? [] }

        var byID: [String: [String: Any]] = [:]
        for subscription in subscriptions {
            if let id = subscription["productID"] as? String { byID[id] = subscription }
        }
        #expect(
            Set(byID.keys) == [Self.monthlySKU, Self.annualSKU, Self.annualHiSKU],
            "exactly the three catalog SKUs, id-for-id"
        )

        func displayPrice(_ sku: String) -> String? { byID[sku]?["displayPrice"] as? String }
        func introOffer(_ sku: String) -> [String: Any]? { byID[sku]?["introductoryOffer"] as? [String: Any] }

        #expect(displayPrice(Self.monthlySKU) == "6.99")
        #expect(displayPrice(Self.annualSKU) == "29.99", "the CONTROL arm is $29.99 (architecture §8)")
        #expect(displayPrice(Self.annualHiSKU) == "39.99")

        #expect(introOffer(Self.monthlySKU) == nil, "the 3-day trial is ANNUAL-ONLY (MVP §6)")
        for sku in [Self.annualSKU, Self.annualHiSKU] {
            let offer = try #require(introOffer(sku), "both annual arms carry the 3-day free trial")
            #expect(offer["paymentMode"] as? String == "free")
            #expect(offer["subscriptionPeriod"] as? String == "P3D")
            #expect(offer["numberOfPeriods"] as? Int == 1)
        }

        // The two config homes must agree (one drift pin across both): the
        // catalog's static display strings are the storekit prices, rendered.
        #expect(ProductCatalog.monthlyDisplayPrice == "$6.99")
        #expect(ProductCatalog.annualControlDisplayPrice == "$29.99")
    }
}
