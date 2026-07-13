#if DEBUG
import Foundation
import Observation

/// S29 (R25.9/Architect-P6, the recorded design) — the consent-honest debug
/// event spy: an `AnalyticsSink` DECORATOR that wraps the chosen transport at
/// the ONE composition site (`RepositoryProvider.liveRepository`) and records
/// the wire name of every event that reaches it, for the scenario-29 smoke's
/// `eachStepFiresEvent` tail to read back through the a11y bridge.
///
/// Consent-honesty is STRUCTURAL, not behavioral: `AnalyticsService.fire`
/// applies the ADR-8 gate (`guard isOptedIn()`) BEFORE `sink.receive`, so a
/// sink-level decorator can only ever observe events that already passed the
/// gate. The spy carries NO consent read of its own — giving it one would
/// either duplicate the gate or let it see swallowed events (the two failure
/// modes the recorded design forbids).
///
/// DEBUG-only BY CONSTRUCTION (this whole file compiles out of release), armed
/// ONLY by the launch env `UITEST_EVENT_SPY=1` (the UITEST_* family, S18
/// precedent) — an un-armed DEBUG build wires the plain transport, unchanged.
/// The spy observes; it never fires, persists, or transmits anything
/// (privacy ruling S29-P1: zero persistence, zero new outbound, names +
/// step ordinals only — never payload parameter values).
@MainActor
@Observable
final class DebugEventSpySink: AnalyticsSink {
    /// The wrapped real transport — every event is forwarded untouched;
    /// observation never swallows.
    private let base: any AnalyticsSink

    /// Ordered bridge entries, one per post-gate fire: the event's wire name,
    /// plus a `:N` ordinal suffix for `quiz_step_completed` (the one event
    /// whose ORDER-BY-SLOT the funnel assertion needs) — never any other
    /// payload parameter (S29-P1 data minimization).
    private(set) var capturedEntries: [String] = []

    init(wrapping base: any AnalyticsSink) {
        self.base = base
    }

    /// Records the bridge entry, then forwards — capture-then-forward keeps
    /// the observed order identical to the transport's.
    func receive(_ event: AnalyticsEvent) {
        capturedEntries.append(Self.entry(for: event))
        base.receive(event)
    }

    /// What the hidden bridge element exposes as its `accessibilityValue`:
    /// the comma-joined entry list (format pinned by DebugEventSpyTests).
    var accessibilityBridgeValue: String {
        capturedEntries.joined(separator: ",")
    }

    /// The arming read (composition-site + bridge-overlay gate). Inert unless
    /// the UITest launch environment sets it — the S18 `UITEST_RESET` shape.
    static var isArmed: Bool {
        ProcessInfo.processInfo.environment["UITEST_EVENT_SPY"] == "1"
    }

    /// One entry per fire: the wire name, `:N`-suffixed for quiz_step_completed
    /// ONLY (the funnel assertion needs order-by-slot; every other payload
    /// parameter stays out — S29-P1 data minimization).
    private static func entry(for event: AnalyticsEvent) -> String {
        if case let .quizStepCompleted(stepNumber) = event {
            return "\(AnalyticsEventKind.quizStepCompleted.rawValue):\(stepNumber)"
        }
        return event.kind.rawValue
    }
}
#endif
