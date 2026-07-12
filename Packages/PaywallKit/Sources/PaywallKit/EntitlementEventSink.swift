/// The recorded-intent seam for domain events. Test doubles conform to this
/// protocol (test-suite §7 rule 8); the app's conformer arrives with the
/// wiring session and is the ONLY place `EntitlementEvent` meets the
/// consent-gated analytics service.
public protocol EntitlementEventSink: Sendable {
    func record(_ event: EntitlementEvent) async
}
