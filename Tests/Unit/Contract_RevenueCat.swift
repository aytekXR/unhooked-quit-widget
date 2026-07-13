import Foundation
import PaywallKit
// S29: @_spi(Internal) — the winback wire-shape contract constructs a
// PromotionalOffer WITHOUT the RC backend via the SDK's own SPI
// (StoreProductDiscount.promotionalOffer(withSignedDataIdentifier:...),
// 5.80.3 StoreProductDiscount.swift:122). Acceptable ONLY because
// purchases-ios is exact-pinned at 5.80.3 (SPI cannot drift under the pin);
// a version bump re-verifies it at this contract tier BY DESIGN. This file
// stays the lint-allowlisted second importer.
@_spi(Internal) import RevenueCat
import Testing
@testable import Unhooked

// E7.1 app half (Session 24, green) — Contract_RevenueCat (test-suite §4
// naming: one contract file per vendor, documenting the assumption it guards
// and the incident it prevents). Assumption: the adapter's EntitlementInfo →
// CustomerEntitlementView extraction reads the REAL SDK types the way the
// 5.80.3 source says it does. Incident prevented: an adapter that read
// `.active` instead of `.all` would map a lapsed subscriber to nil → `.never`
// — silently hiding every win-back surface (the S23 carried obligation: "the
// adapter session should pin it against the real SDK mapping").
//
// These pins construct GENUINE RevenueCat values via the SDK's public inits
// (docstring "Useful for Unit testing purposes" — verified at tag 5.80.3:
// EntitlementInfo.swift:280, EntitlementInfos.swift:61, CustomerInfo.swift:204).
// Zero network, zero StoreKit: pure value construction, CI-safe (RC stays
// DORMANT; configure is never called anywhere in any test). Born-green BY
// DESIGN — contract tier, not red evidence (the behavior was red-pinned over
// the neutral view in RevenueCatMappingTests first).

/// Fixture epoch (test-suite §3.2): 2026-07-07T12:00:00Z — no live Date()
/// fixtures (the house clock discipline, applied to test data too).
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)

@Suite("E7.1 · Contract_RevenueCat (real SDK types)")
struct Contract_RevenueCat {
    private static func entitlementInfo(
        isActive: Bool,
        periodType: RevenueCat.PeriodType,
        sku: String = "com.beyondkaira.ballast.annual",
        willRenew: Bool = true
    ) -> RevenueCat.EntitlementInfo {
        EntitlementInfo(
            identifier: "premium",
            isActive: isActive,
            willRenew: willRenew,
            periodType: periodType,
            store: .appStore,
            productIdentifier: sku,
            isSandbox: true,
            ownershipType: .purchased
        )
    }

    private static func customerInfo(
        entitlements: [String: RevenueCat.EntitlementInfo]
    ) -> RevenueCat.CustomerInfo {
        CustomerInfo(
            entitlements: EntitlementInfos(entitlements: entitlements),
            requestDate: epoch,
            firstSeen: epoch,
            originalAppUserId: "$RCAnonymousID:contract-fixture"
        )
    }

    /// The load-bearing contract: a REAL present-but-inactive EntitlementInfo
    /// (in `.all`, not `.active`) survives extraction as `isActive: false` —
    /// never nil — and reads `.lapsed` end-to-end.
    @Test func contract_presentButInactiveEntitlement_readsLapsed() throws {
        let info = Self.customerInfo(
            entitlements: ["premium": Self.entitlementInfo(isActive: false, periodType: .normal)]
        )
        let view = try #require(
            RevenueCatEntitlementSource.entitlementView(of: info),
            "the extraction must read entitlements.all — a lapsed subscriber may never vanish into nil"
        )
        #expect(view.isActive == false)
        #expect(
            EntitlementStateMapper.state(from: RevenueCatEntitlementMapper.snapshot(from: view))
                == .lapsed(product: .annual)
        )
    }

    /// A real `.trial` period on the annual SKU reads `.trial(.annual)`.
    @Test func contract_trialPeriodEntitlement_readsTrial() {
        let info = Self.customerInfo(
            entitlements: ["premium": Self.entitlementInfo(isActive: true, periodType: .trial)]
        )
        let state = EntitlementStateMapper.state(
            from: RevenueCatEntitlementMapper.snapshot(
                from: RevenueCatEntitlementSource.entitlementView(of: info)
            )
        )
        #expect(state == .trial(product: .annual))
    }

    /// No "premium" entitlement — empty, AND a foreign key — extracts nil and
    /// reads `.never` (the extraction is keyed on ProductCatalog.entitlementKey,
    /// never "whatever exists").
    @Test func contract_absentPremiumEntitlement_readsNever() {
        let empty = Self.customerInfo(entitlements: [:])
        #expect(RevenueCatEntitlementSource.entitlementView(of: empty) == nil)

        let foreign = Self.customerInfo(
            entitlements: ["other_app_key": Self.entitlementInfo(isActive: true, periodType: .normal)]
        )
        #expect(RevenueCatEntitlementSource.entitlementView(of: foreign) == nil)
        #expect(
            EntitlementStateMapper.state(
                from: RevenueCatEntitlementMapper.snapshot(
                    from: RevenueCatEntitlementSource.entitlementView(of: foreign)
                )
            ) == .never
        )
    }

    /// The PeriodType mirror is one-to-one at 5.80.3 (normal|intro|trial|
    /// prepaid) — a renamed/renumbered SDK case must fail HERE, at the
    /// contract tier, not in production mapping.
    @Test func contract_periodTypeMirror_isOneToOne() {
        let pairs: [(RevenueCat.PeriodType, EntitlementPeriodType)] = [
            (.normal, .normal), (.intro, .intro), (.trial, .trial), (.prepaid, .prepaid),
        ]
        for (rc, mirrored) in pairs {
            #expect(RevenueCatEntitlementSource.periodType(from: rc) == mirrored)
        }
    }

    /// S29 (R29.6) — the winback WIRE-SHAPE contract: a real 5.80.3
    /// `StoreProductDiscount` minted from the SDK's public test double
    /// (`TestStoreProductDiscount`, docs "Test Data" — public init +
    /// `toStoreProductDiscount()`) carries our offer id, and a
    /// `PromotionalOffer` assembled around it (via the pinned-SPI
    /// constructor — the same discount+SignedData pair
    /// `purchase(package:promotionalOffer:)` transmits) round-trips both
    /// halves. Assumption guarded: the discount RC signs and the discount
    /// StoreKit applies are keyed by OUR `winback_annual` id, id-for-id
    /// with ProductCatalog and the Ballast.storekit adHocOffer. Incident
    /// prevented: an SDK bump renaming `offerIdentifier`/`SignedData`
    /// members would silently unkey the 50%-off purchase — it must fail
    /// HERE, not in the operator's sandbox sitting. Zero network, zero
    /// StoreKit runtime (the SDK signs server-side; the LIVE authorization
    /// stays key-gated, §8 — born-green contract tier BY DESIGN).
    @Test func contract_winbackPromotionalOffer_roundTripsOfferIdentifier() throws {
        let discount = TestStoreProductDiscount(
            identifier: ProductCatalog.winbackOfferID,
            price: 14.99,
            localizedPriceString: "$14.99",
            paymentMode: .payUpFront,
            subscriptionPeriod: .init(value: 1, unit: .year),
            numberOfPeriods: 1,
            type: .promotional
        ).toStoreProductDiscount()
        #expect(
            discount.offerIdentifier == ProductCatalog.winbackOfferID,
            "the SDK discount carries our ASC offer id — the key purchaseWinback() matches on"
        )

        let nonce = try #require(UUID(uuidString: "BA11A570-0008-4000-8000-000000000008"))
        let offer = discount.promotionalOffer(
            withSignedDataIdentifier: ProductCatalog.winbackOfferID,
            keyIdentifier: "CONTRACTKEY",
            nonce: nonce,
            signature: "contract-fixture-signature",
            timestamp: 1_783_425_600
        )
        #expect(offer.discount.offerIdentifier == ProductCatalog.winbackOfferID)
        #expect(
            offer.signedData.identifier == ProductCatalog.winbackOfferID,
            "the signed half is keyed by the SAME offer id — one id, two halves, no drift"
        )
    }
}
