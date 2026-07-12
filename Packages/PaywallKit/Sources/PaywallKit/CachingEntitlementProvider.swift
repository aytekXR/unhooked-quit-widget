/// The deliverable: the state machine over the source seam, holding the
/// IN-MEMORY last-known state that `test_entitlementCheck_offline_usesCachedState`
/// pins. This is the whole "cached-entitlement store" BY RULING (Session 23
/// privacy MUST-FIX #1): the package persists ZERO bytes — no file, no App
/// Group, no UserDefaults. Durable/reinstall caching is the RevenueCat SDK's
/// documented job app-side ("CustomerInfo will be returned while offline"),
/// and the pre-unlock widget/panic mirror stays the existing app-side
/// PanicSnapshot boolean (architecture §3).
public actor CachingEntitlementProvider: EntitlementProviding {
    private let source: any EntitlementSource
    private let events: (any EntitlementEventSink)?
    private var lastKnown: EntitlementState = .never

    public init(source: any EntitlementSource, events: (any EntitlementEventSink)? = nil) {
        self.source = source
        self.events = events
    }

    public var currentState: EntitlementState {
        lastKnown
    }

    @discardableResult
    public func refresh() async -> EntitlementState {
        do {
            return await adopt(EntitlementStateMapper.state(from: try await source.currentSnapshot()))
        } catch {
            // Offline/failed fetch: keep the last-known state (architecture §8
            // grace — never lock a paying user out because the network is down).
            return lastKnown
        }
    }

    @discardableResult
    public func restore() async throws -> EntitlementState {
        await adopt(EntitlementStateMapper.state(from: try await source.restore()))
    }

    public func reset() async throws {
        // Local clear FIRST (the E2.4 local-first order); the fallible source
        // step goes last and its failure propagates for retry.
        lastKnown = .never
        try await source.reset()
    }

    private func adopt(_ next: EntitlementState) async -> EntitlementState {
        let previous = lastKnown
        lastKnown = next
        if case .trial(let product) = next, !previous.isTrial {
            await events?.record(.trialStarted(product: product))
        }
        return next
    }
}
