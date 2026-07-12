import Foundation
import PaywallKit

/// E7.1 app half — the ONE config home for SKUs, tiers, and display prices
/// (R23.6/R24.5: "pricing is config, not code"; the state machine has zero
/// price knowledge). The `.storekit` test configuration mirrors these ids and
/// prices; `MonetizationConfigTests` pins the two homes against each other so
/// neither can drift from MVP §6 alone.
///
/// RED (Session 24): deliberately inert — every lookup vends the "no catalog"
/// answer so the designed-failing pins in `MonetizationConfigTests` /
/// `RevenueCatMappingTests` / `TrialStartedWireTests` stay red until green
/// fills the real table.
enum ProductCatalog {
    /// The RevenueCat entitlement identifier both annual arms + monthly unlock
    /// (test-suite §4.2 pins this against the dashboard key at sandbox time).
    static let entitlementKey = ""

    /// SKU → tier. Both annual A/B arms map to `.annual` (R23.6 — the
    /// $29.99-vs-$39.99 arm rides `paywall_viewed.price_test` app-side only,
    /// and that fire is E7.2's).
    static func tier(forSKU productIdentifier: String) -> Product? {
        nil
    }

    /// The canonical analytics wire id for a tier — the value-domain the
    /// closed enum's free-String `product` field is pinned to (the committed
    /// AnalyticsEventTests fixture: "ballast.annual").
    static func wireProductID(for product: Product) -> String {
        ""
    }

    /// Static display prices for the DORMANT/offline bundled paywall
    /// (architecture §8: the fallback shows the CONTROL arm). The copy table
    /// holds `%@` templates only — prose never carries a price literal, so a
    /// founder rewrite can never drift the pricing (R24.5).
    static let monthlyDisplayPrice = ""
    static let annualControlDisplayPrice = ""
}
