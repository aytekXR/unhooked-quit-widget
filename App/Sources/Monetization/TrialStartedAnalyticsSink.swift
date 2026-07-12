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
/// an isolated method (the actor hop is the await the protocol already pays).
///
/// RED (Session 24): inert — records nothing, so `TrialStartedWireTests`
/// stays red until green.
@MainActor
final class TrialStartedAnalyticsSink: EntitlementEventSink {
    private let analytics: AnalyticsService
    private let dedupe: TrialAnalyticsDedupeStore

    init(analytics: AnalyticsService, dedupe: TrialAnalyticsDedupeStore) {
        self.analytics = analytics
        self.dedupe = dedupe
    }

    func record(_ event: EntitlementEvent) async {
    }
}
