import Foundation
import PaywallKit
import Testing
@testable import Unhooked

// E7.1 app half (Session 24) — the consent-gated trial_started wire + the
// cross-launch at-most-once dedup (R23.4/R24.6). RevenueCat replays current
// state on EVERY cold start, so the package's per-process edge re-fires on
// every launch of a trialing install; the durable marker (app-STANDARD
// defaults) swallows the replay. The marker is set ONLY on a consented actual
// send: a decliner persists nothing at all, and an opt-in made later — while
// still trialing — counts exactly once (the ≥8% conversion numerator's
// load-bearing correctness pin, PM V-S).
//
// The wire VALUE is the catalog's canonical id ("ballast.annual") — the
// value-domain pin the closed enum's free-String `product` field has owed
// since E8.1, matching its committed fixture vocabulary byte-for-byte.
//
// RED: `TrialStartedAnalyticsSink.record` is inert — every fire/dedup pin
// below fails by design until green.

/// The house spy shape, copied verbatim from ConsentGateTests (file-private
/// by the no-shared-fixtures convention).
@MainActor
private final class SpyAnalyticsSink: AnalyticsSink {
    private(set) var received: [AnalyticsEvent] = []
    func receive(_ event: AnalyticsEvent) { received.append(event) }
}

@MainActor
private func makeDedupe() -> TrialAnalyticsDedupeStore {
    TrialAnalyticsDedupeStore(
        defaults: UserDefaults(suiteName: "e71-trialwire-\(UUID().uuidString)")!
    )
}

@MainActor
@Suite("E7.1 · trial_started wire + cross-launch dedup")
struct TrialStartedWireTests {
    /// M18 (designed-red): opted in ⇒ the domain edge fires the closed-enum
    /// case with the CANONICAL annual wire id — tier in, "ballast.annual" out.
    @Test func test_trialStartedSink_optedIn_firesTrialStartedWithCanonicalAnnualID() async {
        let spy = SpyAnalyticsSink()
        let sink = TrialStartedAnalyticsSink(
            analytics: AnalyticsService(sink: spy, isOptedIn: { true }),
            dedupe: makeDedupe()
        )

        await sink.record(.trialStarted(product: .annual))

        #expect(spy.received == [.trialStarted(product: "ballast.annual")])
    }

    /// M21 (designed-red): the monthly tier's canonical wire id — the other
    /// half of the value domain (both annual A/B arms are `.annual`, so
    /// exactly these two strings are ever constructible on the wire).
    @Test func test_trialStartedSink_tierMapsToCanonicalWireID_monthly() async {
        let spy = SpyAnalyticsSink()
        let sink = TrialStartedAnalyticsSink(
            analytics: AnalyticsService(sink: spy, isOptedIn: { true }),
            dedupe: makeDedupe()
        )

        await sink.record(.trialStarted(product: .monthly))

        #expect(spy.received == [.trialStarted(product: "ballast.monthly")])
    }

    /// M19 (born-green safety pin): consent OFF ⇒ nothing transmits AND the
    /// marker stays UNSET (R24.6: a non-consented device persists zero bytes,
    /// and a later opt-in while still trialing can still count).
    @Test func test_trialStartedSink_optedOut_firesNothing_andLeavesMarkerUnset() async {
        let spy = SpyAnalyticsSink()
        let dedupe = makeDedupe()
        let sink = TrialStartedAnalyticsSink(
            analytics: AnalyticsService(sink: spy, isOptedIn: { false }),
            dedupe: dedupe
        )

        await sink.record(.trialStarted(product: .annual))

        #expect(spy.received.isEmpty, "zero events before consent — the ONE gate")
        #expect(dedupe.hasFired == false, "no consented send ⇒ no persisted byte")
    }

    /// M20 (designed-red): the cold-start replay — two sink instances (two
    /// launches) over ONE durable marker fire exactly once in total.
    @Test func test_trialStartedSink_crossLaunchReplay_firesExactlyOnce() async {
        let spy = SpyAnalyticsSink()
        let dedupe = makeDedupe()
        let launch1 = TrialStartedAnalyticsSink(
            analytics: AnalyticsService(sink: spy, isOptedIn: { true }),
            dedupe: dedupe
        )
        let launch2 = TrialStartedAnalyticsSink(
            analytics: AnalyticsService(sink: spy, isOptedIn: { true }),
            dedupe: dedupe
        )

        await launch1.record(.trialStarted(product: .annual))
        await launch2.record(.trialStarted(product: .annual))

        #expect(
            spy.received == [.trialStarted(product: "ballast.annual")],
            "RC replays state every launch — the durable marker must swallow the replay"
        )
        #expect(dedupe.hasFired)
    }

    /// M20b (designed-red): the late-opt-in arm of R24.6 — a decliner's trial
    /// leaves no mark, so the NEXT replay after opting in fires exactly once.
    @Test func test_trialStartedSink_lateOptIn_whileStillTrialing_firesOnce() async {
        let spy = SpyAnalyticsSink()
        let dedupe = makeDedupe()
        var opted = false
        let sink = TrialStartedAnalyticsSink(
            analytics: AnalyticsService(sink: spy, isOptedIn: { opted }),
            dedupe: dedupe
        )

        await sink.record(.trialStarted(product: .annual))
        #expect(spy.received.isEmpty)

        opted = true
        await sink.record(.trialStarted(product: .annual))
        await sink.record(.trialStarted(product: .annual))

        #expect(
            spy.received == [.trialStarted(product: "ballast.annual")],
            "the first consented observation fires; every later replay is swallowed"
        )
    }
}
