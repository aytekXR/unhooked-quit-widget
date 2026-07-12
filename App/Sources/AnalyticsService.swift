import Foundation

// E8.1 — the closed analytics vocabulary + the consent-gated facade (ADR-8: privacy
// by unrepresentability; MVP §5 is the ONLY source of event names and properties).
// This file stays pure Foundation on purpose: the Linux empirical harness compiles
// these exact bytes, so every payload-mapping change is exercised before a billed
// macOS run. The TelemetryDeck binding lives in its own file (TelemetryDeckSink.swift)
// behind the AnalyticsSink seam for the same reason.

/// The 19 audited wire names — exactly the MVP §5 event table, snake_case verbatim.
/// CaseIterable so the whitelist test is exhaustive BY CONSTRUCTION: a new case
/// cannot ship without a fixture and a key whitelist (test-suite §1.1 test 10).
enum AnalyticsEventKind: String, CaseIterable, Sendable {
    case onboardingStarted = "onboarding_started"
    case quizStepCompleted = "quiz_step_completed"
    case quizCompleted = "quiz_completed"
    case paywallViewed = "paywall_viewed"
    case trialStarted = "trial_started"
    case purchase
    case teaserEntered = "teaser_entered"
    case quitCreated = "quit_created"
    case widgetAdded = "widget_added"
    case panicOpened = "panic_opened"
    case panicStepReached = "panic_step_reached"
    case urgeAverted = "urge_averted"
    case slipLogged = "slip_logged"
    case slipUndone = "slip_undone"
    case discreetModeEnabled = "discreet_mode_enabled"
    case resourcesViewed = "resources_viewed"
    case eraseAllCompleted = "erase_all_completed"
    case winbackShown = "winback_shown"
    case winbackConverted = "winback_converted"
}

/// Cold-start latency bucket for `panic_opened` — the ONLY representable timing
/// (MVP §5: "bucket `cold_start_ms` client-side so no precise timing fingerprint
/// leaves the device"). Derived at fire time, never stored (§1.2 invariant 2).
enum ColdStartBucket: String, CaseIterable, Sendable {
    case under1s = "under_1s"
    case oneToTwoSeconds = "1s_to_2s"
    case over2s = "over_2s"
}

/// Where a paywall was presented from (MVP §5 `paywall_viewed.source`).
/// `teaserExpiry` is E7.2's second-impression value (R25.4): the teaser A/B
/// is un-analyzable if the post-expiry re-present collapses into
/// `onboarding` — test-suite §1.4 sc.36 + the plan's E7.2 row name it
/// verbatim. mvp.md §5's source row predates it; the vocabulary addition is
/// the operator's ratification item (the R24.9 flagged-deviation shape).
enum PaywallSource: String, CaseIterable, Sendable {
    case onboarding, settings, winback
    case teaserExpiry = "teaser_expiry"
}

/// The annual price A/B arm (MVP §6: $29.99 vs $39.99 from day one).
enum PriceTestVariant: String, CaseIterable, Sendable {
    case annual2999 = "29_99"
    case annual3999 = "39_99"
}

/// Subscription period for `purchase` (MVP §5).
enum SubscriptionPeriod: String, CaseIterable, Sendable {
    case monthly, annual
}

/// Widget family for `widget_added` (MVP §5 kind values, verbatim).
enum WidgetKind: String, CaseIterable, Sendable {
    case panicRect = "panic_rect"
    case circular
    case inline
    case homeSmall = "home_s"
    case homeMedium = "home_m"
}

/// Which discreet component was enabled (MVP §5 `discreet_mode_enabled.component`).
enum DiscreetComponent: String, CaseIterable, Sendable {
    case widget, icon
}

/// Where the resources/helplines screen was opened from (MVP §5).
enum ResourcesSource: String, CaseIterable, Sendable {
    case settings
    case slipFlow = "slip_flow"
}

/// The closed analytics event vocabulary (ADR-8). Every case is one MVP §5 table row;
/// associated values are that row's properties and NOTHING else — journal/note
/// content, quiz free text, precise timings, and custom habit names are
/// unrepresentable in this type. `HabitCategory`/`GoalMode`/`PanicStep`/`PanicSource`
/// are reused from the models deliberately: one source of truth, and
/// `Quit.customLabel` (the user's free-text habit name) is a separate field the
/// mapping cannot reach — `custom` is the wire ceiling (Architect ruling, Session 15).
/// Adding cases or associated values is an Architect-gated change
/// (agent-workflows §1.2/§1.4).
enum AnalyticsEvent: Equatable, Sendable {
    case onboardingStarted(variant: String)
    case quizStepCompleted(stepNumber: Int)
    case quizCompleted(habitCategory: HabitCategory, goalMode: GoalMode)
    case paywallViewed(variant: String, priceTest: PriceTestVariant, source: PaywallSource)
    case trialStarted(product: String)
    case purchase(product: String, period: SubscriptionPeriod)
    case teaserEntered(variant: String)
    /// `quitIndex` is the 1-based ordinal (1–3), NEVER an identifier — a UUID here
    /// would be the cross-service join §10 forbids (Architect ruling, Session 15).
    case quitCreated(habitCategory: HabitCategory, goalMode: GoalMode, quitIndex: Int)
    case widgetAdded(kind: WidgetKind, discreet: Bool)
    case panicOpened(source: PanicSource, coldStart: ColdStartBucket)
    case panicStepReached(step: PanicStep)
    case urgeAverted(habitCategory: HabitCategory)
    /// NO timestamp property is representable (MVP §5: aggregate counts only) —
    /// pinned by `test_slipLogged_payload_hasNoTimestampProperty`.
    case slipLogged(habitCategory: HabitCategory)
    case slipUndone
    case discreetModeEnabled(component: DiscreetComponent)
    case resourcesViewed(source: ResourcesSource)
    case eraseAllCompleted
    case winbackShown(offer: String)
    case winbackConverted(offer: String)

    // The free-String fields — `variant`, `product`, `offer` — are experiment ids /
    // StoreKit SKUs / offer ids: compile-time or operator-console constants, never
    // user input. The type cannot constrain them; the payload audit (E8.2) and a
    // value-domain test at each event's wiring session enforce the discipline
    // (Architect SHOULD, Session 15).

    /// The audited wire name this event serializes under.
    var kind: AnalyticsEventKind {
        switch self {
        case .onboardingStarted: .onboardingStarted
        case .quizStepCompleted: .quizStepCompleted
        case .quizCompleted: .quizCompleted
        case .paywallViewed: .paywallViewed
        case .trialStarted: .trialStarted
        case .purchase: .purchase
        case .teaserEntered: .teaserEntered
        case .quitCreated: .quitCreated
        case .widgetAdded: .widgetAdded
        case .panicOpened: .panicOpened
        case .panicStepReached: .panicStepReached
        case .urgeAverted: .urgeAverted
        case .slipLogged: .slipLogged
        case .slipUndone: .slipUndone
        case .discreetModeEnabled: .discreetModeEnabled
        case .resourcesViewed: .resourcesViewed
        case .eraseAllCompleted: .eraseAllCompleted
        case .winbackShown: .winbackShown
        case .winbackConverted: .winbackConverted
        }
    }

    /// The transmittable payload — exactly the MVP §5 property columns, key-for-key.
    /// Values are String (the TelemetryDeck parameter type); numerics are bounded
    /// Int ordinals, stringified — no floating point exists in the schema.
    var parameters: [String: String] {
        switch self {
        case let .onboardingStarted(variant):
            ["variant": variant]
        case let .quizStepCompleted(stepNumber):
            ["step_number": String(stepNumber)]
        case let .quizCompleted(habitCategory, goalMode):
            ["habit_category": habitCategory.rawValue, "goal_mode": goalMode.rawValue]
        case let .paywallViewed(variant, priceTest, source):
            ["variant": variant, "price_test": priceTest.rawValue, "source": source.rawValue]
        case let .trialStarted(product):
            ["product": product]
        case let .purchase(product, period):
            ["product": product, "period": period.rawValue]
        case let .teaserEntered(variant):
            ["variant": variant]
        case let .quitCreated(habitCategory, goalMode, quitIndex):
            [
                "habit_category": habitCategory.rawValue,
                "goal_mode": goalMode.rawValue,
                "quit_index": String(quitIndex),
            ]
        case let .widgetAdded(kind, discreet):
            ["kind": kind.rawValue, "discreet": String(discreet)]
        case let .panicOpened(source, coldStart):
            ["source": Self.wireValue(of: source), "cold_start_ms": coldStart.rawValue]
        case let .panicStepReached(step):
            ["step": step.rawValue]
        case let .urgeAverted(habitCategory):
            ["habit_category": habitCategory.rawValue]
        case let .slipLogged(habitCategory):
            ["habit_category": habitCategory.rawValue]
        case .slipUndone:
            [:]
        case let .discreetModeEnabled(component):
            ["component": component.rawValue]
        case let .resourcesViewed(source):
            ["source": source.rawValue]
        case .eraseAllCompleted:
            [:]
        case let .winbackShown(offer):
            ["offer": offer]
        case let .winbackConverted(offer):
            ["offer": offer]
        }
    }

    /// The audited snake_case wire value for a panic source — never `rawValue`
    /// (camelCase; Architect MUST-FIX #2, Session 15). Exhaustive: a new source
    /// cannot ship without choosing its audited wire value.
    private static func wireValue(of source: PanicSource) -> String {
        switch source {
        case .lockscreenWidget: "lockscreen_widget"
        case .homeWidget: "home_widget"
        case .controlCenter: "control_center"
        case .actionButton: "action_button"
        case .inApp: "in_app"
        }
    }
}

/// The transport seam (test-suite §3.1: "the `AnalyticsEvent` sink" — doubles conform
/// to this protocol, never to an SDK type). @MainActor like every house seam
/// (ClockProviding / WidgetRefreshing / CloudSyncControlling / HapticsPlaying):
/// every fire site is already main-actor-isolated.
@MainActor
protocol AnalyticsSink {
    func receive(_ event: AnalyticsEvent)
}

/// The transport that transmits nothing, unconditionally — the injection default at
/// every seam, and the production transport while the TelemetryDeck app ID is
/// operator-pending (the dormant half of the double gate).
@MainActor
struct NoopAnalyticsSink: AnalyticsSink {
    func receive(_ event: AnalyticsEvent) {}
}

/// App-local TelemetryDeck facade (architecture §14 lists no shared analytics
/// package — this stays app code). The closed enum is the ENTIRE transmittable
/// surface: no generic track(String) API exists or may be added (MVP §5;
/// test-suite §1.1 test 10; agent-workflows §1.4).
@MainActor
struct AnalyticsService {
    /// The transport behind the consent gate. Tests inject `SpyAnalyticsSink`;
    /// production wires TelemetryDeck (or stays no-op until the operator app ID lands).
    let sink: any AnalyticsSink
    /// The ADR-8 consent read — default OFF until the quiz consent step (E8.2)
    /// writes it. Injected so tests exercise both gate states without storage.
    let isOptedIn: () -> Bool

    /// The one seam every fire site uses — never on the panic pre-frame path (ADR-6).
    func fire(_ event: AnalyticsEvent) {
        // ADR-8: zero events before consent — the ONE gate every seam shares
        // (opt-in default OFF; nothing can opt in until E8.2's consent step ships).
        guard isOptedIn() else { return }
        sink.receive(event)
    }

    /// The default at every injection seam: transmits nothing, consent reads false.
    static let disabled = AnalyticsService(sink: NoopAnalyticsSink(), isOptedIn: { false })
}
