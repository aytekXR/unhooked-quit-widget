import Foundation
import TelemetryDeck

/// Operator-owned TelemetryDeck app configuration (agent-workflows §1.3: SaaS
/// console credentials are operator-held; agents never mint them).
enum AnalyticsConfiguration {
    /// The TelemetryDeck app ID from the operator's console (operator-expected §8).
    /// Empty ⇒ the transport stays DORMANT: `RepositoryProvider` wires
    /// `NoopAnalyticsSink`, the SDK is never initialized, and zero bytes leave the
    /// device even if consent were somehow on — the second half of the ADR-8
    /// double gate.
    static let telemetryDeckAppID = ""
}

/// The production transport: TelemetryDeck, the SOLE analytics (ADR-8), SDK pinned
/// exact at 2.14.1 in project.yml (docs-checked Session 15 — 3.0.0 is beta-only).
///
/// LAZY init on first `receive` — never in `UnhookedApp.init`: analytics must never
/// run pre-frame on the panic path (ADR-6 thinness), and the SDK asserts on
/// pre-init signals in DEBUG, so the init rides the first post-frame, post-consent
/// fire instead. The SDK's on-disk `SignalCache` (10k cap, retry + exponential
/// backoff, restored across launches) is the plan's on-device queue — no hand-rolled
/// queue layer. `testMode` keeps its DEBUG default, so dev traffic never pollutes
/// live insights.
@MainActor
final class TelemetryDeckSink: AnalyticsSink {
    private let appID: String
    private var initialized = false

    init(appID: String) {
        self.appID = appID
    }

    func receive(_ event: AnalyticsEvent) {
        guard !appID.isEmpty else { return }
        if !initialized {
            TelemetryDeck.initialize(config: TelemetryDeck.Config(appID: appID))
            initialized = true
        }
        // The typed value serializes through the ONE audited mapping — name and
        // keys are the pinned MVP §5 vocabulary, nothing else is constructible.
        TelemetryDeck.signal(event.kind.rawValue, parameters: event.parameters)
    }
}
