import Foundation
import PaywallKit

/// The pure half of the RC adapter (R24.3): one neutral entitlement view in,
/// one `EntitlementSnapshot` out. The S23 doc-bound seam nuance becomes
/// type-exercised here (the carried E7.1 obligation): an entitlement that is
/// PRESENT but inactive maps to `isActive: false` — NEVER nil — so downstream
/// `EntitlementStateMapper` reads `.lapsed`, never a silent `.never`.
///
enum RevenueCatEntitlementMapper {
    /// `nil` view (no "premium" entitlement has ever existed) ⇒ nil snapshot
    /// (⇒ `.never`). A present view ALWAYS yields a snapshot, whatever its
    /// `isActive` — and an unrecognized SKU still honors the entitlement
    /// (architecture §8: "when in doubt, honor the entitlement" — a paying
    /// user must never be locked out by a catalog gap; tier defaults to the
    /// primary `.annual` for display/analytics granularity only).
    static func snapshot(from view: CustomerEntitlementView?) -> EntitlementSnapshot? {
        guard let view else { return nil }
        return EntitlementSnapshot(
            product: ProductCatalog.tier(forSKU: view.productIdentifier) ?? .annual,
            periodType: view.periodType,
            isActive: view.isActive,
            willRenew: view.willRenew
        )
    }
}
