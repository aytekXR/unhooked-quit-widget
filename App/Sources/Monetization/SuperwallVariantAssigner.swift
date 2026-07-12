import Foundation
// @preconcurrency BY REPRODUCTION (probe-3b, Session 25): `Assignment` is a
// non-Sendable final class and `confirmAllAssignments()` is nonisolated
// async, so its result cannot hop into this @MainActor-isolated conformance
// under -strict-concurrency=complete — a plain import is a build ERROR on
// the app lane (warnings-as-errors; the S24 burn class, caught on the free
// probe this time). The annotation scopes the concession to this ONE file.
@preconcurrency import SuperwallKit

// E7.2 app half (Session 25) — THE one SuperwallKit-importing file in the
// whole app (R25.1/R25.10; the RevenueCatEntitlementSource sole-importer
// precedent — the free-lane `monetization-importer-lint` enforces it). Every
// SDK member below was verified VERBATIM against the Superwall-iOS 4.16.1
// tagged source (the Session 25 docs-verifier table; standing S22/S23 rule:
// a spelling the source does not confirm does not exist). This file NEVER
// imports RevenueCat (the two SDKs share StoreKit-shaped names —
// StoreProduct/CustomerInfo/SubscriptionPeriod — and a dual import makes
// every one ambiguous; burn-critic FORM A) and never references PaywallKit
// types (the app-side seam types below are this module's own).
//
// DORMANT discipline (R25.2): nothing in this file runs unless the
// operator's key is present — `Superwall.configure` alone fetches remote
// config from api.superwall.me, mints/persists an anonymous identity, and
// (unless event tracking is restricted) posts install attribution to
// mmp.superwall.com (4.16.1 Superwall.swift:456-534), so the key-absent
// branch in `PaywallPresentationComposition.makeAssigner` never references
// these symbols at runtime.

/// The adapter filling the app-side `VariantAssigning` seam (ADR-4
/// removability: everything but this file depends on the protocol; deleting
/// the Superwall dependency deletes exactly this file plus two config
/// entries, and the bundled hard-arm fallback keeps rendering).
struct SuperwallVariantAssigner: VariantAssigning {
    /// The ONE configure call (composition-injected so the dormant-gate
    /// tests count it without importing the SDK). `eventTrackingBehavior =
    /// .superwallOnly` (4.16.1 SuperwallOptions.swift:319): first-party
    /// placements only — no third-party event fan-out; the folklore knob
    /// `automaticDeviceIdentifierCollection` does NOT exist in this SDK
    /// (docs-verifier kill, Session 25).
    static func configure(apiKey: String) {
        let options = SuperwallOptions()
        options.eventTrackingBehavior = .superwallOnly
        Superwall.configure(apiKey: apiKey, options: options)
    }

    /// The sticky per-install assignment for one placement, read from
    /// Superwall's confirmed assignments (4.16.1 Superwall.swift:746-792)
    /// and mapped through the operator-owned table — the "(Superwall id)"
    /// keypath is `variant.id` (never the experiment id, never a paywall
    /// id). No assignment / unmapped id ⇒ the hard control arm (the grace
    /// direction, R24.3's unknown-SKU precedent). The price arm is derived
    /// separately at presentation time (`SuperwallPlacement.priceTest` over
    /// the shown product ids); the assigner reports the CONTROL price —
    /// the bundled screen this session renders only ever shows $29.99
    /// (architecture §8; the $39.99 arm lives in Superwall's remote paywall,
    /// wired at the live-key session).
    func assignment(for placement: String) async -> PaywallAssignment {
        let assignments = await Superwall.shared.confirmAllAssignments()
        let variant = SuperwallPlacement.variant(
            forSuperwallVariantID: assignments.first?.variant.id
        )
        return PaywallAssignment(variant: variant, priceTest: .annual2999)
    }
}
