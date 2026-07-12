import Foundation

/// E7.2 (R25.2) — the Superwall DORMANT gate as a pure, spy-checkable
/// decision: the `MonetizationComposition.makeEntitlementSource` twin. The
/// closures are injected so this file (and its tests) never import
/// SuperwallKit — the live wiring passes `Superwall.configure` and the real
/// adapter; tests pass counters. The docs-verified stake (4.16.1 source):
/// configure ALONE fetches remote config, mints a persisted anonymous
/// identity, and posts install attribution unless event tracking is off —
/// so "key absent ⇒ configure count 0" is a privacy pin, not bookkeeping.
@MainActor
enum PaywallPresentationComposition {
    /// Key absent ⇒ the bundled hard-arm assigner, and `configureSuperwall`
    /// is NEVER invoked (zero SDK init, zero network — the whole point of
    /// DORMANT). Key present ⇒ configure exactly once, then the adapter.
    static func makeAssigner(
        apiKey: String,
        configureSuperwall: () -> Void,
        makeAdapter: () -> any VariantAssigning
    ) -> any VariantAssigning {
        guard !apiKey.isEmpty else { return BundledVariantAssigner() }
        configureSuperwall()
        return makeAdapter()
    }
}
