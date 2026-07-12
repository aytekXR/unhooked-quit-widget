import Foundation

/// Operator-owned Superwall SDK configuration (agent-workflows §1.3: SaaS
/// console credentials are operator-held; agents never mint them). The
/// RevenueCatConfiguration / AnalyticsConfiguration precedent, byte-for-byte
/// (R25.2).
enum SuperwallConfiguration {
    /// The Superwall PUBLIC API key from the operator's dashboard
    /// (operator-expected §8). Empty ⇒ the variant wiring stays DORMANT:
    /// `PaywallPresentationComposition` vends the bundled hard-arm assigner,
    /// `Superwall.configure` is never called (configure alone fetches remote
    /// config from api.superwall.me, mints/persists an anonymous identity,
    /// and can post install attribution — docs-verified against the
    /// SuperwallKit 4.16.1 tagged source, Session 25), no placement is ever
    /// registered, and the paywall renders the S24 bundled control arm
    /// exactly as before this session. Zero SDK init, zero network, on any
    /// build until the operator acts.
    static let superwallAPIKey = ""
}
