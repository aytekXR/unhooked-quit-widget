import Foundation
import PaywallKit

/// The DORMANT fallback source (R24.2): vends "no entitlement has ever
/// existed" forever, throws never, touches nothing. This is what the
/// composition builds when the operator key is absent — and the app-side
/// analog of the package's own test doubles, so the erase/refresh unit tests
/// exercise the wiring without RevenueCat existing anywhere near them.
struct NeverEntitlementSource: EntitlementSource {
    func currentSnapshot() async throws -> EntitlementSnapshot? { nil }
    func restore() async throws -> EntitlementSnapshot? { nil }
    func reset() async throws {}
}
