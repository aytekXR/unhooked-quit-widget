import Foundation
import Testing
@testable import Ballast

// ME-1 (redesign §6.15) unit lane — the widget-adoption handshake + the
// `widget_added` wiring. The handshake is the ONE detection channel for "the
// user actually added a widget": the extension's timeline provider stamps a
// write-once App Group defaults key per family; the app consumes each stamp
// into at most one consent-gated fire and acknowledges it either way (ADR-8:
// consent-off means the event never existed — it is never parked for a later
// opt-in). Every test runs on a throwaway suite (the house convention).

@MainActor
@Suite("ME-1 · widget-adoption handshake + widget_added wiring")
struct WidgetAdoptionTests {

    private func makeDefaults() -> UserDefaults {
        UserDefaults(suiteName: "me1-adoption-\(UUID().uuidString)")!
    }

    /// The typed-event spy (test-suite §3.1 `SpyAnalyticsSink`) — file-local
    /// copy, the house no-shared-fixtures convention.
    @MainActor
    private final class SpyAnalyticsSink: AnalyticsSink {
        private(set) var received: [AnalyticsEvent] = []
        func receive(_ event: AnalyticsEvent) { received.append(event) }
    }

    // MARK: - Wire-name contract (the Shared table ↔ the closed app enum)

    /// Every family's wire name must BE a `WidgetKind` rawValue (MVP §5 kind
    /// values, byte-for-byte) — the mapping is `WidgetKind(rawValue:)`, and a
    /// drifted name would strand its stamp forever.
    @Test func test_everyFamilyWireName_isAnAuditedWidgetKind() {
        for family in StreakWidgetFamily.allCases {
            let name = WidgetAdoptionHandshake.wireName(for: family)
            #expect(
                WidgetKind(rawValue: name) != nil,
                "wire name '\(name)' must be an audited WidgetKind rawValue"
            )
        }
        // The flagship binds to the flagship (the north-star metric's kind).
        #expect(WidgetAdoptionHandshake.wireName(for: .rectangular) == WidgetKind.panicRect.rawValue)
    }

    // MARK: - Handshake semantics

    @Test func test_recordFirstRender_isWriteOnce_andKeepsAddTimeDiscreetFlag() {
        let defaults = makeDefaults()
        WidgetAdoptionHandshake.recordFirstRender(family: .rectangular, discreet: true, in: defaults)
        // A later refill with a flipped flag must NOT rewrite the stamp — the
        // fire reports the ADD-time state.
        WidgetAdoptionHandshake.recordFirstRender(family: .rectangular, discreet: false, in: defaults)

        let pending = WidgetAdoptionHandshake.pending(in: defaults)
        #expect(pending == [
            WidgetAdoptionHandshake.PendingAdoption(kindWireName: "panic_rect", discreet: true),
        ])
        #expect(WidgetAdoptionHandshake.hasAnyRender(in: defaults))
    }

    @Test func test_acknowledge_consumesTheStamp_butDetectionSurvives() {
        let defaults = makeDefaults()
        WidgetAdoptionHandshake.recordFirstRender(family: .circular, discreet: false, in: defaults)
        WidgetAdoptionHandshake.acknowledge("circular", in: defaults)

        #expect(WidgetAdoptionHandshake.pending(in: defaults).isEmpty)
        // Detection is about the widget EXISTING, not analytics bookkeeping —
        // the adoption screen's check-off must survive the ack.
        #expect(WidgetAdoptionHandshake.hasAnyRender(in: defaults))
    }

    @Test func test_freshSuite_hasNothingPending_andNoRender() {
        let defaults = makeDefaults()
        #expect(WidgetAdoptionHandshake.pending(in: defaults).isEmpty)
        #expect(!WidgetAdoptionHandshake.hasAnyRender(in: defaults))
    }

    @Test func test_nilSuite_degradesToCalmNoOps() {
        WidgetAdoptionHandshake.recordFirstRender(family: .small, discreet: false, in: nil)
        #expect(WidgetAdoptionHandshake.pending(in: nil).isEmpty)
        #expect(!WidgetAdoptionHandshake.hasAnyRender(in: nil))
    }

    // MARK: - The wiring (fire once, acknowledge either way)

    @Test func test_firePendingAdoptions_firesOncePerStamp_thenNeverAgain() {
        let defaults = makeDefaults()
        let spy = SpyAnalyticsSink()
        let analytics = AnalyticsService(sink: spy, isOptedIn: { true })
        WidgetAdoptionHandshake.recordFirstRender(family: .rectangular, discreet: false, in: defaults)
        WidgetAdoptionHandshake.recordFirstRender(family: .medium, discreet: true, in: defaults)

        let consumed = WidgetAdoptionWiring.firePendingAdoptions(analytics: analytics, defaults: defaults)
        #expect(consumed == 2)
        #expect(spy.received == [
            .widgetAdded(kind: .panicRect, discreet: false),
            .widgetAdded(kind: .homeMedium, discreet: true),
        ])

        // The second sweep is a structural no-op — widget_added is once per
        // family per tracking era, never per foreground.
        #expect(WidgetAdoptionWiring.firePendingAdoptions(analytics: analytics, defaults: defaults) == 0)
        #expect(spy.received.count == 2)
    }

    @Test func test_consentOff_swallowsTheFire_butStillAcknowledges() {
        let defaults = makeDefaults()
        let spy = SpyAnalyticsSink()
        let analytics = AnalyticsService(sink: spy, isOptedIn: { false })
        WidgetAdoptionHandshake.recordFirstRender(family: .inline, discreet: false, in: defaults)

        let consumed = WidgetAdoptionWiring.firePendingAdoptions(analytics: analytics, defaults: defaults)

        // ADR-8: consent-off means the event never existed — nothing transmits,
        // and the stamp is NOT parked for a later opt-in (that would transmit a
        // pre-consent fact).
        #expect(consumed == 1)
        #expect(spy.received.isEmpty)
        #expect(WidgetAdoptionHandshake.pending(in: defaults).isEmpty)
    }

    // MARK: - Erase (the App Group defaults sweep clears the stamps wholesale)

    @Test func test_eraseDefaultsSweep_clearsTheHandshake() throws {
        let defaults = makeDefaults()
        WidgetAdoptionHandshake.recordFirstRender(family: .rectangular, discreet: false, in: defaults)
        WidgetAdoptionHandshake.acknowledge("panic_rect", in: defaults)

        // The exact production sweep (`QuitRepository.eraseLocalArtifacts`
        // removes every key in the App Group suite) — no new enumeration site.
        try QuitRepository.eraseLocalArtifacts(
            storeURLs: [], appGroupFileURLs: [], appGroupDefaults: defaults
        )

        #expect(!WidgetAdoptionHandshake.hasAnyRender(in: defaults))
        #expect(WidgetAdoptionHandshake.pending(in: defaults).isEmpty)
    }

    // MARK: - The preview's zero-suppression (redesign §6.15)

    /// The first hours of a real streak yield a positive-but-sub-unit figure
    /// that ROUNDS to the locale's zero — the money line must render nothing,
    /// never "$0 saved" (the never-"$0" rule; the `saved > 0` guard's intent,
    /// previously defeated by rounding).
    @Test func test_widgetMoneyLine_isZeroSuppressed_whileTheFigureRoundsToZero() {
        let epoch = Date(timeIntervalSince1970: 1_783_425_600)
        func quit(startedSecondsAgo: TimeInterval) -> WidgetQuitState {
            WidgetQuitState(
                id: UUID(),
                streakStart: epoch - startedSecondsAgo,
                timeZoneIdentifier: "America/New_York",
                weeklySpend: "26.50",
                currencyCode: "USD",
                bankedCleanSeconds: 0,
                momentumPercent: 100,
                milestoneHours: [],
                discreet: nil
            )
        }
        // One hour in: ~$0.16 — rounds to "$0", so the line is suppressed.
        #expect(StreakWidgetDisplay.moneyText(for: quit(startedSecondsAgo: 3_600), at: epoch) == nil)
        // A week in: a real figure still renders.
        #expect(StreakWidgetDisplay.moneyText(for: quit(startedSecondsAgo: 7 * 86_400), at: epoch) != nil)
    }

    // MARK: - The copy table (decode + degrade totality)

    @Test func test_widgetMomentCopy_shipsAndDecodes_withTheDraftBytes() throws {
        let copy = try #require(
            WidgetMomentCopy.loadShipping(),
            "the audited table is the shipping widgetMomentCopy.json — it must be bundled and decode as-is (§3.2)"
        )
        // The copy-doc §4 bytes, verbatim (DRAFT — founder pass pending).
        #expect(copy.title == "Put help on your lock screen")
        #expect(copy.eyebrow == "Before the first hard moment")
        #expect(copy.primaryCTA == "Show me how")
        #expect(copy.secondaryCTA == "Maybe later")
        #expect(copy.guideSteps.count == 3)
        // Degraded == shipping (the SummaryCopy shape): no visible degradation.
        #expect(copy == WidgetMomentCopy.degraded)
    }
}
