import Foundation
import PaywallKit

/// E7.1 app half — the ONE config home for SKUs, tiers, and display prices
/// (R23.6/R24.5: "pricing is config, not code"; the state machine has zero
/// price knowledge). The `.storekit` test configuration mirrors these ids and
/// prices; `MonetizationConfigTests` pins the two homes against each other so
/// neither can drift from MVP §6 alone.
///
/// SKU naming (R24.5, PM-ruled): reverse-DNS on the REAL registered prefix
/// (gate G0 CLEARED 2026-07-08 — AppIdentifiers.swift header) with NO price
/// embedded in any id (App Store Connect product ids are immutable; a price
/// change must never strand a misleading id). Nothing is registered in ASC by
/// this session — these ids are local (`Ballast.storekit` + this table) until
/// the operator's sandbox-verification pass creates them.
enum ProductCatalog {
    /// The RevenueCat entitlement identifier both annual arms + monthly unlock
    /// (test-suite §4.2 pins this against the dashboard key at sandbox time).
    static let entitlementKey = "premium"

    /// $6.99/mo, no trial (MVP §6).
    static let monthlySKU = "com.beyondkaira.ballast.monthly"
    /// $29.99/yr, 3-day trial — the CONTROL arm AND the bundled-fallback
    /// offer (architecture §8).
    static let annualSKU = "com.beyondkaira.ballast.annual"
    /// $39.99/yr, 3-day trial — the price-test B arm, reachable ONLY via
    /// Superwall's sticky per-install assignment (E7.2). Never offered by the
    /// bundled fallback.
    static let annualHiSKU = "com.beyondkaira.ballast.annual.hi"

    /// SKU → tier. Both annual A/B arms map to `.annual` (R23.6 — the
    /// $29.99-vs-$39.99 arm rides `paywall_viewed.price_test` app-side only,
    /// and that fire is E7.2's). A foreign SKU resolves to no tier.
    static func tier(forSKU productIdentifier: String) -> Product? {
        switch productIdentifier {
        case monthlySKU: .monthly
        case annualSKU, annualHiSKU: .annual
        default: nil
        }
    }

    /// The canonical analytics wire id for a tier — the value-domain the
    /// closed enum's free-String `product` field is pinned to (the committed
    /// AnalyticsEventTests fixture: "ballast.annual"). Exactly these two
    /// strings are ever constructible on the wire.
    static func wireProductID(for product: Product) -> String {
        switch product {
        case .monthly: "ballast.monthly"
        case .annual: "ballast.annual"
        }
    }

    /// Static display prices for the DORMANT/offline bundled paywall
    /// (architecture §8: the fallback shows the CONTROL arm). The copy table
    /// holds `%@` templates only — prose never carries a price literal, so a
    /// founder rewrite can never drift the pricing (R24.5). Pinned against
    /// `Ballast.storekit` in MonetizationConfigTests (two config homes, one
    /// drift pin).
    static let monthlyDisplayPrice = "$6.99"
    static let annualControlDisplayPrice = "$29.99"
}
