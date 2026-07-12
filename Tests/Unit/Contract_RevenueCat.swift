import Foundation
import PaywallKit
import RevenueCat
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
        let pairs: [(RevenueCat.PeriodType, PaywallKit.PeriodType)] = [
            (.normal, .normal), (.intro, .intro), (.trial, .trial), (.prepaid, .prepaid),
        ]
        for (rc, mirrored) in pairs {
            #expect(RevenueCatEntitlementSource.periodType(from: rc) == mirrored)
        }
    }
}
