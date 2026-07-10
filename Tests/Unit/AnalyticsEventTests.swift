import Foundation
import Testing
@testable import Unhooked

// E8.1 — the analytics privacy boundary, tested as load-bearing behavior
// (test-suite §7 rule 9: privacy assertions are tests, not comments).
//
// The fixture + whitelist tables below are the AUDITED transcription of the MVP §5
// event table — the only place event names and property keys may come from. The
// fixture table is the exhaustiveness mechanism: `AnalyticsEventKind` is CaseIterable,
// the completeness test pins fixtures to `allCases`, and the parameterized whitelist
// test audits every kind — a new event cannot ship without joining the audit.

/// The house spy shape (SpyWidgetRefresher precedent; test-suite §3.1 names this
/// double: "SpyAnalyticsSink capturing AnalyticsEvent values in-process — the typed
/// enum means the spy is trivially exhaustive").
@MainActor
private final class SpyAnalyticsSink: AnalyticsSink {
    private(set) var received: [AnalyticsEvent] = []
    func receive(_ event: AnalyticsEvent) { received.append(event) }
}

@MainActor
@Suite("E8.1 · analytics enum + service")
struct AnalyticsEventTests {

    // MARK: - The audited tables (MVP §5, key-for-key)

    private static let fixtures: [AnalyticsEventKind: AnalyticsEvent] = [
        .onboardingStarted: .onboardingStarted(variant: "a"),
        .quizStepCompleted: .quizStepCompleted(stepNumber: 7),
        .quizCompleted: .quizCompleted(habitCategory: .vape, goalMode: .quit),
        .paywallViewed: .paywallViewed(variant: "hard_v1", priceTest: .annual2999, source: .onboarding),
        .trialStarted: .trialStarted(product: "ballast.annual"),
        .purchase: .purchase(product: "ballast.annual", period: .annual),
        .teaserEntered: .teaserEntered(variant: "teaser_v1"),
        .quitCreated: .quitCreated(habitCategory: .weed, goalMode: .reduce, quitIndex: 2),
        .widgetAdded: .widgetAdded(kind: .panicRect, discreet: true),
        .panicOpened: .panicOpened(source: .controlCenter, coldStart: .under1s),
        .panicStepReached: .panicStepReached(step: .breath),
        .urgeAverted: .urgeAverted(habitCategory: .alcohol),
        .slipLogged: .slipLogged(habitCategory: .porn),
        .slipUndone: .slipUndone,
        .discreetModeEnabled: .discreetModeEnabled(component: .widget),
        .resourcesViewed: .resourcesViewed(source: .slipFlow),
        .eraseAllCompleted: .eraseAllCompleted,
        .winbackShown: .winbackShown(offer: "winback_50"),
        .winbackConverted: .winbackConverted(offer: "winback_50"),
    ]

    private static let whitelistedKeys: [AnalyticsEventKind: Set<String>] = [
        .onboardingStarted: ["variant"],
        .quizStepCompleted: ["step_number"],
        .quizCompleted: ["habit_category", "goal_mode"],
        .paywallViewed: ["variant", "price_test", "source"],
        .trialStarted: ["product"],
        .purchase: ["product", "period"],
        .teaserEntered: ["variant"],
        .quitCreated: ["habit_category", "goal_mode", "quit_index"],
        .widgetAdded: ["kind", "discreet"],
        .panicOpened: ["source", "cold_start_ms"],
        .panicStepReached: ["step"],
        .urgeAverted: ["habit_category"],
        .slipLogged: ["habit_category"],
        .slipUndone: [],
        .discreetModeEnabled: ["component"],
        .resourcesViewed: ["source"],
        .eraseAllCompleted: [],
        .winbackShown: ["offer"],
        .winbackConverted: ["offer"],
    ]

    /// The 19 audited wire names, byte-exact (the Session 14 byte-pin precedent) —
    /// a rawValue typo or rename is a deliberate two-place edit, never drift.
    private static let auditedWireNames: Set<String> = [
        "onboarding_started", "quiz_step_completed", "quiz_completed",
        "paywall_viewed", "trial_started", "purchase", "teaser_entered",
        "quit_created", "widget_added", "panic_opened", "panic_step_reached",
        "urge_averted", "slip_logged", "slip_undone", "discreet_mode_enabled",
        "resources_viewed", "erase_all_completed", "winback_shown",
        "winback_converted",
    ]

    // MARK: - Completeness pins

    @Test func test_analyticsFixtures_coverEveryEventKind() {
        #expect(
            Set(Self.fixtures.keys) == Set(AnalyticsEventKind.allCases),
            "the fixture table is the exhaustiveness mechanism — every MVP §5 event must be constructible and audited"
        )
        #expect(
            Set(AnalyticsEventKind.allCases.map(\.rawValue)) == Self.auditedWireNames,
            "the wire names are the audited MVP §5 rows byte-exact — a drifted name would split the funnel silently"
        )
        for (kind, event) in Self.fixtures {
            #expect(
                event.kind == kind,
                "a fixture mapped to the wrong case would audit the wrong payload: \(kind.rawValue)"
            )
        }
    }

    // MARK: - The plan-named four (implementation-plan E8.1 row)

    @Test(arguments: AnalyticsEventKind.allCases)
    func test_everyEventCase_serializesOnlyWhitelistedKeys(_ kind: AnalyticsEventKind) throws {
        let event = try #require(
            Self.fixtures[kind],
            "every wire event needs a fixture — a case without one cannot be audited"
        )
        let expectedKeys = try #require(
            Self.whitelistedKeys[kind],
            "every wire event needs an audited key whitelist (MVP §5)"
        )
        #expect(
            Set(event.parameters.keys) == expectedKeys,
            "\(kind.rawValue) serializes EXACTLY the MVP §5 property columns — a missing key undercounts the audited funnel, an extra key is a privacy leak"
        )
    }

    @Test func test_slipLogged_payload_hasNoTimestampProperty() throws {
        // The wire half: the category and NOTHING else (MVP §5: "no timestamp
        // property; no note content" — slip timestamps are aggregate-only data).
        let payload = AnalyticsEvent.slipLogged(habitCategory: .vape).parameters
        #expect(
            payload == ["habit_category": "vape"],
            "slip_logged carries exactly the habit category rawValue — never a timestamp, never a note"
        )
        // The representability half (test-suite §1.1 test 10): Mirror-walk EVERY
        // fixture — no Date and no floating-point value (a precise-timing carrier)
        // can hide in any associated value of any case (SlipLexiconTests reflection
        // precedent: a new associated value joins this scan automatically).
        for (kind, event) in Self.fixtures {
            let temporal = Self.reflectedTemporalCarriers(of: event)
            #expect(
                temporal.isEmpty,
                "\(kind.rawValue) carries a temporal-capable associated value (\(temporal)) — timestamps must be UNREPRESENTABLE in the enum (ADR-8)"
            )
        }
        // The key-name half: no audited payload smuggles a time-shaped key.
        for (kind, event) in Self.fixtures {
            for key in event.parameters.keys {
                let lowered = key.lowercased()
                for forbidden in ["time", "date", "stamp"] where lowered.contains(forbidden) {
                    Issue.record(
                        "\(kind.rawValue) payload key '\(key)' is time-shaped — the only sanctioned timing is the bucketed cold_start_ms"
                    )
                }
            }
        }
    }

    @Test func test_analyticsFacade_hasNoGenericTrackMethod() {
        let spy = SpyAnalyticsSink()
        let service = AnalyticsService(sink: spy, isOptedIn: { true })
        // Compile-time half: the facade's ONLY entry point binds to
        // (AnalyticsEvent) -> Void — there is no track(String)/track(name:parameters:)
        // overload to bind, and adding one is an Architect-gated change
        // (agent-workflows §1.4: "never add a generic track call").
        let onlyEntry: @MainActor (AnalyticsEvent) -> Void = service.fire
        onlyEntry(.slipUndone)
        // Runtime half: what crossed the seam is the TYPED value — the sink protocol
        // has no name/params surface an un-audited event could smuggle through.
        #expect(
            spy.received == [.slipUndone],
            "the sink receives the closed-enum value itself — serialization to wire strings happens inside the audited payload mapping, nowhere else"
        )
    }

    @Test func test_optOut_sendsNothing() throws {
        let spy = SpyAnalyticsSink()
        let service = AnalyticsService(sink: spy, isOptedIn: { false })
        for kind in AnalyticsEventKind.allCases {
            let event = try #require(Self.fixtures[kind], "fixture table covers allCases")
            service.fire(event)
        }
        #expect(
            spy.received.isEmpty,
            "zero events before opt-in is the MVP §5 / release-criteria HARD rule (ADR-8) — \(spy.received.count) event(s) leaked past the consent gate"
        )
    }

    // MARK: - Companions

    /// Guards the other direction of the gate: opted-in events must pass through
    /// unchanged — a gate that never sends would fail every funnel silently.
    @Test func test_optIn_deliversTypedEventToSink() {
        let spy = SpyAnalyticsSink()
        let service = AnalyticsService(sink: spy, isOptedIn: { true })
        service.fire(.urgeAverted(habitCategory: .doomscroll))
        #expect(
            spy.received == [.urgeAverted(habitCategory: .doomscroll)],
            "an opted-in fire delivers exactly the fired value to the transport"
        )
    }

    /// Architect MUST-FIX #2 (Session 15): the `panic_opened` source serializes the
    /// audited snake_case wire values — never `PanicSource.rawValue` camelCase — and
    /// the bucket vocabulary is pinned coarse.
    @Test func test_panicOpened_sourceAndBucket_serializeToAuditedWireValues() throws {
        let auditedSourceWire: [PanicSource: String] = [
            .lockscreenWidget: "lockscreen_widget",
            .homeWidget: "home_widget",
            .controlCenter: "control_center",
            .actionButton: "action_button",
            .inApp: "in_app",
        ]
        for source in PanicSource.allCases {
            let expected = try #require(
                auditedSourceWire[source],
                "every PanicSource case needs an audited wire value — a new source cannot ship unaudited: \(source.rawValue)"
            )
            let payload = AnalyticsEvent.panicOpened(source: source, coldStart: .under1s).parameters
            #expect(
                payload["source"] == expected,
                "panic_opened source is the audited snake_case value, not the camelCase rawValue: \(source.rawValue)"
            )
        }
        #expect(
            Set(ColdStartBucket.allCases.map(\.rawValue)) == ["under_1s", "1s_to_2s", "over_2s"],
            "the ONLY representable timing is the three coarse buckets (MVP §5: no precise timing fingerprint leaves the device)"
        )
        for bucket in ColdStartBucket.allCases {
            let payload = AnalyticsEvent.panicOpened(source: .inApp, coldStart: bucket).parameters
            #expect(
                payload["cold_start_ms"] == bucket.rawValue,
                "the bucket serializes under the audited cold_start_ms key: \(bucket.rawValue)"
            )
        }
    }

    // MARK: - Helpers

    /// Recursive Mirror walk collecting temporal-capable values: `Date` outright, and
    /// any floating-point (`Double`/`Float`) — the schema's only numbers are bounded
    /// Int ordinals (`step_number`, `quit_index`), so a float is a precise-timing
    /// carrier by definition.
    private static func reflectedTemporalCarriers(of subject: Any) -> [String] {
        if subject is Date { return ["Date"] }
        if subject is Double || subject is Float { return ["\(type(of: subject))"] }
        return Mirror(reflecting: subject).children.flatMap {
            reflectedTemporalCarriers(of: $0.value)
        }
    }
}
