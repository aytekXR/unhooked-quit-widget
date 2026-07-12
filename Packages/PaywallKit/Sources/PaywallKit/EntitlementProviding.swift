/// The consumer seam test-suite §3.1 names — app UI logic ("show paywall vs
/// dashboard") talks to this, and `FakeEntitlementProvider` doubles it in
/// app-unit tests. All members vend `EntitlementState`; nothing here exposes
/// snapshots, dates, or SKUs.
public protocol EntitlementProviding: Sendable {
    var currentState: EntitlementState { get async }
    /// Refreshes from the source; on failure (offline) the last-known state is
    /// kept and returned — never a fabricated `.never` (architecture §8).
    @discardableResult
    func refresh() async -> EntitlementState
    /// Restore is available in EVERY state (Epic 7 DoD: the paywall never
    /// traps a user) and needs no account.
    @discardableResult
    func restore() async throws -> EntitlementState
    /// The erase seam: local state clears FIRST, then the source reset runs
    /// (its failure propagates for retry — the E2.4 local-first order).
    func reset() async throws
}
