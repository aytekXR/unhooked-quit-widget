/// The product TIER, not a SKU (E7.1 step-0 ruling d — "pricing is config, not
/// code"). The package knows monthly-vs-annual because the state machine's
/// consumers need the tier (`.active(product: .annual)`, test-suite §4.3) and
/// the trial is annual-only (MVP §6) — but SKU strings, display prices, and the
/// $29.99-vs-$39.99 A/B arm live app-side (`ProductCatalog` + the `.storekit`
/// file arrive with the wiring session; `price_test` rides `paywall_viewed`,
/// never an entitlement surface). Both annual A/B arms map to `.annual`.
public enum Product: String, CaseIterable, Sendable, Hashable {
    case monthly
    case annual
}
