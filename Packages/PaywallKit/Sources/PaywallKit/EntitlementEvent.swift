/// The package's DOMAIN events — deliberately not analytics. The app-side
/// AnalyticsEvent enum is CLOSED and lives with its consent gate; this package
/// holds no wire name and fires nothing. The wiring session maps
/// `.trialStarted` to the pre-existing `AnalyticsEventKind.trialStarted`
/// behind the ONE consent gate, and owns cross-launch at-most-once dedup
/// (the package detects edges per-process only — R23.4).
/// Payload is the product TIER only: no price, no currency, no dates.
public enum EntitlementEvent: Sendable, Equatable {
    /// Emitted on the transition INTO `.trial` (edge-triggered — RevenueCat
    /// replays current state on every launch, so only a diff is honest).
    case trialStarted(product: Product)
}
