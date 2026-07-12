import Foundation
import PaywallKit

/// The pure DORMANT-gate decision (R24.2), extracted so the key fork is
/// unit-testable with spies — the `appID.isEmpty` fork in
/// `RepositoryProvider.liveRepository` (the TelemetryDeck precedent), as a
/// function. `startIfNeeded`'s live branch calls this with the real closures;
/// tests inject counters and stay fully RC-free.
///
enum MonetizationComposition {
    /// Key absent ⇒ the never-source, and `configureRevenueCat` is NEVER
    /// invoked (zero SDK init, zero network — the whole point of DORMANT).
    /// Key present ⇒ configure exactly once, then the adapter.
    static func makeEntitlementSource(
        apiKey: String,
        configureRevenueCat: () -> Void,
        makeAdapter: () -> any EntitlementSource
    ) -> any EntitlementSource {
        guard !apiKey.isEmpty else { return NeverEntitlementSource() }
        configureRevenueCat()
        return makeAdapter()
    }
}
