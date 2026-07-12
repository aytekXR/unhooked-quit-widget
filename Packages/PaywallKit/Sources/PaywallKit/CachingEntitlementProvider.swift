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
        .never // inert seam — red commit (E7.1)
    }

    @discardableResult
    public func refresh() async -> EntitlementState {
        .never // inert seam — red commit (E7.1)
    }

    @discardableResult
    public func restore() async throws -> EntitlementState {
        .never // inert seam — red commit (E7.1)
    }

    public func reset() async throws {
        // inert seam — red commit (E7.1)
    }
}
