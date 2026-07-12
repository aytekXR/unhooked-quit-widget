import Foundation
import Observation
import PaywallKit

/// The app-wide entitlement model (architecture §7): a thin @MainActor
/// observable face over PaywallKit's `CachingEntitlementProvider` actor, so
/// SwiftUI can gate the summary CTA on `state.isEntitled` (R24.2). PULL-based
/// by ruling: refresh on construction, after purchase/restore, and on
/// foreground — no `customerInfoStream` subscription in v1 (green-minimal;
/// the trialStarted edge still fires through refresh adoptions).
///
/// Constructed ONLY on the live branch of `startIfNeeded` (key present) —
/// dormant builds have no instance at all, which IS the CTA fall-through
/// guarantee. Never constructed on the panic route (route guard by contract).
///
/// RED (Session 24): inert — `refresh()` never consults the provider, so
/// `EntitlementModelTests` stays red until green.
@MainActor
@Observable
final class EntitlementModel {
    private let provider: any EntitlementProviding
    /// In-memory only, like everything entitlement-shaped (R23.3): the model
    /// persists zero bytes; RC's SDK owns durable caching.
    private(set) var state: EntitlementState = .never

    init(provider: any EntitlementProviding) {
        self.provider = provider
    }

    @discardableResult
    func refresh() async -> EntitlementState {
        state
    }

    @discardableResult
    func restore() async throws -> EntitlementState {
        state
    }
}
