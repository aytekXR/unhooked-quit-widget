import Foundation

// E7.2 (R25.1/R25.3) — the variant-assignment seam, APP-SIDE by ruling:
// SuperwallKit is UIKit-required (85 unconditional UIKit imports at 4.16.1;
// Linux build fails on the transitive Rust binary), so PaywallKit stays
// Foundation-only on the free Linux lane and ADR-4's "Superwall isolated
// behind PaywallKit" is satisfied by this ABSTRACTION — everything but the
// one adapter file depends on these types, never on the SDK (the
// RevenueCatEntitlementSource sole-importer precedent).

/// The canonical assignment domain — test-suite §4.4: "Variant assignment
/// returns one of exactly `{teaser, hard}`". These rawValues ARE the
/// `paywall_viewed.variant` / `teaser_entered.variant` wire value-domain
/// (R25.3: semantic labels on the wire; the raw Superwall variant id maps
/// through the operator-owned table in `SuperwallPlacement`, never
/// transmitted — the MVP §5 "(Superwall id)" deviation is the operator's
/// ratification item).
enum PaywallVariant: String, CaseIterable, Sendable {
    case teaser, hard
}

/// One paywall presentation's assignment: the STRUCTURE arm (teaser-vs-hard)
/// and the PRICE arm ($29.99-vs-$39.99) — orthogonal dimensions of the same
/// `paywall_viewed` event (R25.3; the price arm rides `price_test`, never
/// the product id — R23.6).
struct PaywallAssignment: Equatable, Sendable {
    var variant: PaywallVariant
    var priceTest: PriceTestVariant
}

/// The house seam the Superwall adapter fills (§3.1 rule: doubles conform to
/// house seams, never SDK types — the four plan-named tests script this via
/// a fake, no SDK import anywhere near the red evidence).
@MainActor
protocol VariantAssigning {
    /// The sticky per-install assignment for one placement. Async because
    /// the live adapter awaits Superwall's config; the bundled assigner
    /// answers immediately.
    func assignment(for placement: String) async -> PaywallAssignment
}

/// The dormant / offline / de-integrated fallback (ADR-4's removability
/// guarantee; architecture §8): deterministically the HARD control arm —
/// close-free, $29.99, never the $39.99 Superwall-only arm. A keyless or
/// Superwall-removed build IS a hard impression (R25.3 — never a third
/// "bundled" value; A/B denominators stay pristine).
struct BundledVariantAssigner: VariantAssigning {
    func assignment(for _: String) async -> PaywallAssignment {
        PaywallAssignment(variant: .hard, priceTest: .annual2999)
    }
}
