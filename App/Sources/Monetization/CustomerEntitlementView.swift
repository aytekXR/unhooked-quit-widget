import Foundation
import PaywallKit

/// Module-vs-type disambiguation (the Session 24 run-3 burn, Linux-reproduced):
/// the PaywallKit MODULE exports an enum ALSO named `PaywallKit` (the S23
/// version marker), so the qualified `PaywallKit.PeriodType` resolves to the
/// ENUM — "'PeriodType' is not a member type" — in any file that must qualify
/// (the RC adapter imports both SDKs, where the bare name is ambiguous
/// against `RevenueCat.PeriodType`). This alias is declared HERE, where
/// PaywallKit is the sole import and the bare name is exact; both-SDK files
/// use the alias and never the qualified form.
typealias EntitlementPeriodType = PeriodType

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
