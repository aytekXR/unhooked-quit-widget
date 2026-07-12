import Foundation
import PaywallKit

/// The app-side `EntitlementEventSink` conformer (R23.4/R24.6) — the ONLY
/// place PaywallKit's domain events meet the consent-gated analytics service.
/// Maps the tier-only domain payload to the pre-existing closed-enum case
/// `AnalyticsEvent.trialStarted(product:)` using the catalog's canonical wire
/// ids (the committed fixture vocabulary: "ballast.annual") — no new event
/// case, no new key (Architect §7 item 1).
///
/// Cross-launch at-most-once: RevenueCat replays current state every cold
/// start, so the package's per-process edge re-fires on every launch of a
/// trialing install; the durable marker swallows the replay. The marker is
/// set ONLY on a consented actual send (R24.6): a decliner persists nothing,
/// and an opt-in made later — while still trialing — counts exactly once.
///
/// @MainActor: the conformance hop — `AnalyticsService` and every house fire
/// site are main-actor-isolated, and an async requirement may be witnessed by
/// an isolated method (the actor hop is the await the protocol already pays;
/// the shape was reproduced under -strict-concurrency=complete pre-push).
@MainActor
final class TrialStartedAnalyticsSink: EntitlementEventSink {
    private let analytics: AnalyticsService
    private let dedupe: TrialAnalyticsDedupeStore

    init(analytics: AnalyticsService, dedupe: TrialAnalyticsDedupeStore) {
        self.analytics = analytics
        self.dedupe = dedupe
    }

    func record(_ event: EntitlementEvent) async {
        guard case .trialStarted(let product) = event else { return }
        // At-most-once, marked ONLY on a consented actual send (R24.6): a
        // decliner persists nothing — RC's next cold-start replay re-offers
        // the edge, so an opt-in made while still trialing counts exactly
        // once. The service's own fire() gate re-checks consent; this read
        // exists so the MARKER stays honest, not as a second gate.
        guard !dedupe.hasFired, analytics.isOptedIn() else { return }
        analytics.fire(.trialStarted(product: ProductCatalog.wireProductID(for: product)))
        dedupe.markFired()
    }
}
