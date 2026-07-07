import Foundation

/// The closed analytics event vocabulary (ADR-8: privacy by unrepresentability).
///
/// Deliberately uninhabited at skeleton stage: cases land in E8.1, copied verbatim
/// from the MVP §5 event table and nowhere else. Because the enum has no cases, no
/// event can even be constructed yet — the strongest possible form of "zero events
/// before consent". Adding cases or associated values is an Architect-gated change
/// (agent-workflows §1.2/§1.4).
enum AnalyticsEvent: Sendable {
    // E8.1: cases arrive here, exactly the MVP §5 closed list. No timestamps, no
    // content, no custom habit names are ever representable as associated values.
}

/// App-local TelemetryDeck wrapper (architecture §14 lists no shared analytics
/// package — this stays app code). Skeleton stub: the TelemetryDeck SDK is wired in
/// E8.1; until then this transmits nothing, unconditionally.
struct AnalyticsService: Sendable {
    /// Fires a funnel event. No generic track(String) API exists or may be added —
    /// the enum is the entire transmittable surface (MVP §5; test 10 in test-suite §1.1).
    func fire(_ event: AnalyticsEvent) {
        // E8.1: consent gate (opt-in, default OFF) then TelemetryDeck send.
        // Unreachable today: AnalyticsEvent is uninhabited.
    }
}
