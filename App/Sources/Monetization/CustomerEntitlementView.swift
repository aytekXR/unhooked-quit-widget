import Foundation
import PaywallKit

/// The neutral, RC-free mirror of the one RevenueCat `EntitlementInfo` this
/// app reads (R24.3). A plain struct — deliberately NOT a protocol over the
/// SDK type (RC's `EntitlementInfo` already owns the member name `periodType`
/// with its own PeriodType, so a same-named protocol requirement could never
/// be satisfied by extension). The single RC-importing adapter file extracts
/// `EntitlementInfo` → this struct; everything downstream (the pure mapper,
/// every unit test, the Linux pre-push harness) works on this shape and never
/// touches the Darwin-only SDK.
struct CustomerEntitlementView: Equatable, Sendable {
    /// RC `EntitlementInfo.productIdentifier` — resolved to a tier via
    /// `ProductCatalog.tier(forSKU:)`.
    let productIdentifier: String
    /// RC's period discriminator, already translated to PaywallKit's mirror
    /// (the translation switch is the adapter's ONE semantic line).
    let periodType: PeriodType
    /// RC's own verdict — trusted, never second-guessed locally (R23.2).
    let isActive: Bool
    /// Carried so the mapper can keep IGNORING it (never a mid-trial lapse).
    let willRenew: Bool
}
