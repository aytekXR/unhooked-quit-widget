import Foundation

/// E5.1 — what the normal route's first frame hosts.
enum AgeGateFirstScreen: Equatable, Sendable {
    /// The age gate (entry or blocked state) — everything else is unreachable.
    case ageGate
    /// Habit content (today: the placeholder root; E5.2: the quiz/dashboard).
    case onward
}

/// Pure first-screen decision for the normal route (the panic route never consults
/// it — pre-gate that route renders only the empty-pre-cache breathe frame, which
/// the existing PanicRouteResolver pins cover). Kept I/O-free so un-bypassability
/// is a unit pin: content is reachable ONLY through a store-truth `true`.
enum AgeGateRouting {
    static func firstScreen(ageGatePassed: Bool) -> AgeGateFirstScreen {
        // E5.1 RED: deliberately ignores the flag — the designed failure for the
        // fail-closed routing pin. Green: `ageGatePassed ? .onward : .ageGate`.
        .onward
    }
}
