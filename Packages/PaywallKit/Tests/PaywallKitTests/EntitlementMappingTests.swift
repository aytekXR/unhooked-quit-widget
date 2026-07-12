import Foundation
import Testing
@testable import PaywallKit

// E7.1 — the pure snapshot→state mapping (Session 23 rulings R23.1/R23.2).
//
// The mapper trusts the source's `isActive` and carries NO clock: a lapse only
// ever arrives as the next snapshot, which is what keeps the offline grace
// policy (architecture §8 — "when in doubt, honor the entitlement") structural
// rather than conditional. `willRenew` is carried by the snapshot ONLY so the
// tests below can pin the mapper IGNORING it ("lapsed at expiry, never
// mid-trial", test-suite §4.3).

/// One row of the four-state mapping matrix (plus the tier variants).
private struct MappingFixture: Sendable {
    let note: String
    let snapshot: EntitlementSnapshot?
    let expected: EntitlementState
}

@Suite("E7.1 entitlement mapping — snapshot → state")
struct EntitlementMappingTests {

    // MARK: plan-named test #1 (all four states, mocked CustomerInfo shapes)

    @Test("maps every mocked CustomerInfo shape to its state — never/trial/active/lapsed")
    func test_entitlementState_mapsRevenueCatCustomerInfo() {
        let fixtures: [MappingFixture] = [
            .init(
                note: "no entitlement ever (nil snapshot) ⇒ never",
                snapshot: nil,
                expected: .never
            ),
            .init(
                note: "active annual trial ⇒ trial(annual)",
                snapshot: EntitlementSnapshot(product: .annual, periodType: .trial, isActive: true, willRenew: true),
                expected: .trial(product: .annual)
            ),
            .init(
                note: "active normal annual ⇒ active(annual)",
                snapshot: EntitlementSnapshot(product: .annual, periodType: .normal, isActive: true, willRenew: true),
                expected: .active(product: .annual)
            ),
            .init(
                note: "active normal monthly ⇒ active(monthly)",
                snapshot: EntitlementSnapshot(product: .monthly, periodType: .normal, isActive: true, willRenew: true),
                expected: .active(product: .monthly)
            ),
            .init(
                note: "present but inactive (in .all, not in .active) ⇒ lapsed",
                snapshot: EntitlementSnapshot(product: .annual, periodType: .normal, isActive: false, willRenew: false),
                expected: .lapsed(product: .annual)
            ),
            .init(
                note: "expired trial (inactive, periodType still .trial) ⇒ lapsed, not trial",
                snapshot: EntitlementSnapshot(product: .annual, periodType: .trial, isActive: false, willRenew: false),
                expected: .lapsed(product: .annual)
            ),
        ]
        for fixture in fixtures {
            #expect(
                EntitlementStateMapper.state(from: fixture.snapshot) == fixture.expected,
                "\(fixture.note)"
            )
        }
    }

    // MARK: the §4.3 semantics pins the panel forced

    @Test("a cancelled trial (willRenew=false) STAYS trial — lapsed at expiry, never mid-trial")
    func test_cancelledTrial_willRenewFalse_staysTrialNeverLapsesMidTrial() {
        let cancelled = EntitlementSnapshot(product: .annual, periodType: .trial, isActive: true, willRenew: false)
        #expect(EntitlementStateMapper.state(from: cancelled) == .trial(product: .annual))
    }

    @Test("trial→paid conversion (periodType flips to normal) maps to active(annual)")
    func test_trialToPaidConversion_mapsToActiveAnnual() {
        let converted = EntitlementSnapshot(product: .annual, periodType: .normal, isActive: true, willRenew: true)
        #expect(EntitlementStateMapper.state(from: converted) == .active(product: .annual))
    }

    @Test("an intro period is ACTIVE, not trial — .trial is the only trial gate (docs-verified)")
    func test_introPeriod_mapsToActiveNotTrial() {
        let intro = EntitlementSnapshot(product: .monthly, periodType: .intro, isActive: true, willRenew: true)
        #expect(EntitlementStateMapper.state(from: intro) == .active(product: .monthly))
    }

    @Test("isEntitled: true for trial/active, false for lapsed/never")
    func test_isEntitled_trueForTrialAndActive_falseForLapsedAndNever() {
        #expect(EntitlementState.trial(product: .annual).isEntitled)
        #expect(EntitlementState.active(product: .monthly).isEntitled)
        #expect(!EntitlementState.lapsed(product: .annual).isEntitled)
        #expect(!EntitlementState.never.isEntitled)
    }

    // MARK: born-green shape pins

    @Test("state is Equatable with exact tier identity — shape pin")
    func test_entitlementState_equatableShapePin() {
        #expect(EntitlementState.active(product: .annual) == EntitlementState.active(product: .annual))
        #expect(EntitlementState.active(product: .annual) != EntitlementState.active(product: .monthly))
        #expect(EntitlementState.trial(product: .annual) != EntitlementState.active(product: .annual))
    }

    @Test("Product is the tier taxonomy exactly {monthly, annual} — zero SKU/price tokens")
    func test_product_tierTokenSetPin() {
        #expect(Set(Product.allCases.map(\.rawValue)) == Set(["monthly", "annual"]))
    }
}
