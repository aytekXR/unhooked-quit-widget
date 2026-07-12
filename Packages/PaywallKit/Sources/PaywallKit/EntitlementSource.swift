/// The seam the app-side RevenueCat adapter fills (ADR-4 removability: the
/// adapter is ~20 lines over `Purchases`, Darwin-only, and never enters this
/// package — recorded pin for the wiring session: purchases-ios 5.80.3 exact).
/// `restore()` takes NO identity input by design — restoration rides the store
/// account (StoreKit), never an app account ("without account", MVP §2
/// feature 12 posture). `reset()` is the erase seam E2.4 recorded
/// ("RevenueCat clear → E7 seam"): app-side it becomes the anonymous-ID reset.
public protocol EntitlementSource: Sendable {
    /// The source's current verdict; `nil` means no entitlement has ever
    /// existed. Throws when the source cannot answer (offline) — the caller
    /// keeps its last-known state (architecture §8 grace).
    func currentSnapshot() async throws -> EntitlementSnapshot?
    /// Re-syncs against the store account and returns the post-restore verdict.
    func restore() async throws -> EntitlementSnapshot?
    /// Clears source-side identity/cache state (erase path).
    func reset() async throws
}
