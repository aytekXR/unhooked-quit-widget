/// The package's OWN neutral mirror of the one RevenueCat entitlement this app
/// sells ("premium") — PaywallKit never imports the Darwin-only SDK (ADR-4; the
/// WidgetToolkit Foundation-only precedent keeps this lane on free Linux CI).
/// The app-side adapter maps `CustomerInfo.entitlements` down to this shape:
/// absent entitlement (never purchased) ⇒ a `nil` snapshot; present-but-inactive
/// (`entitlements.all` minus `entitlements.active`) ⇒ `isActive == false`.
///
/// MINIMAL BY RULING (Session 23 privacy MUST-FIX): no RevenueCat anonymous ID,
/// no receipt material, no purchase history, no management URL, no price or
/// currency — and NO dates: the mapper trusts `isActive` and never re-derives
/// entitlement from a clock (R23.2, the anti-Quittr grace direction). The type
/// is deliberately NOT Codable — the package persists zero bytes (architecture
/// §3/§7: entitlement state is never a data model of ours).
public struct EntitlementSnapshot: Sendable, Equatable {
    /// The tier of the product that granted (or last granted) the entitlement.
    public let product: Product
    /// The documented RevenueCat period discriminator; `.trial` splits the
    /// entitled states into trial-vs-active.
    public let periodType: PeriodType
    /// RevenueCat's own verdict ("access to this entitlement") — trusted, never
    /// second-guessed locally.
    public let isActive: Bool
    /// Carried ONLY so the mapper can be pinned IGNORING it: a cancelled trial
    /// (`willRenew == false`) stays entitled until the source says otherwise —
    /// "lapsed at expiry, never mid-trial" (test-suite §4.3).
    public let willRenew: Bool

    public init(product: Product, periodType: PeriodType, isActive: Bool, willRenew: Bool) {
        self.product = product
        self.periodType = periodType
        self.isActive = isActive
        self.willRenew = willRenew
    }
}
