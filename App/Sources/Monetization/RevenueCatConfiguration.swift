import Foundation

/// Operator-owned RevenueCat SDK configuration (agent-workflows §1.3: SaaS
/// console credentials are operator-held; agents never mint them). The
/// TelemetryDeck `AnalyticsConfiguration` precedent, byte-for-byte (R24.2).
enum RevenueCatConfiguration {
    /// The RevenueCat PUBLIC SDK key from the operator's dashboard
    /// (operator-expected §8). Empty ⇒ the wiring stays DORMANT:
    /// `MonetizationComposition` never constructs the adapter, `Purchases` is
    /// never configured (configure alone fetches CustomerInfo + Offerings from
    /// api.revenuecat.com and persists an anonymous ID — docs-verified against
    /// purchases-ios 5.80.3 source, Session 24), no `EntitlementModel` exists,
    /// and the summary CTA falls through to the dashboard exactly as before
    /// E7.1's app half landed. Zero SDK init, zero network, on any build until
    /// the operator acts.
    /// S48 — LIVE. This is the PUBLIC, app-specific SDK key (`appl_` prefix),
    /// which is designed to ship inside the binary and grants only what an app
    /// needs. RevenueCat's SECRET keys (`sk_` prefix) grant full account
    /// read/write and MUST NEVER appear here or anywhere else in this repo —
    /// anything in the app bundle is extractable by anyone who downloads it.
    static let revenueCatAPIKey = "appl_QpyyBBvPTyireURvyHvWQjTsPZO"
}
