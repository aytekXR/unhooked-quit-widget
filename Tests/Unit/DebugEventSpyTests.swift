import Foundation
import Testing
@testable import Unhooked

// S29 unit lane — the DebugEventSpySink decorator (R25.9/Architect-P6, deferred
// BY NAME from S25 to this named StoreKit-config/contract session): capture of
// every post-gate fire, fire-order preservation, structural consent-honesty
// (the decorator sits DOWNSTREAM of `AnalyticsService.fire`'s ADR-8 guard, so
// pre-consent fires can never reach it), and the a11y read-bridge string the
// scenario-29 smoke reads back (`wire_name` entries, `:N` ordinal suffix for
// quiz_step_completed ONLY — S29-P1 data minimization: no payload values).
//
// RED: `DebugEventSpySink` is a designed-inert seam — `receive` forwards but
// records nothing and the bridge value is empty — so the four spy failures
// below are designed; they flip when green fills the capture + join. The
// forwarding guard inside R2 passes at red AND green by design.

/// The house spy shape, copied verbatim from ConsentGateTests (file-private by
/// the no-shared-fixtures convention) — here it is the WRAPPED base transport,
/// proving the decorator forwards and never swallows.
@MainActor
private final class SpyAnalyticsSink: AnalyticsSink {
    private(set) var received: [AnalyticsEvent] = []
    func receive(_ event: AnalyticsEvent) { received.append(event) }
}

/// A mutable opt-in the consent-honesty test flips mid-sequence — the same
/// late-bound reference shape ConsentGateTests uses for the live gate read.
private final class OptInFlag {
    var isOn = false
}

@MainActor
@Suite("S29 · debug event-spy — the consent-honest sink decorator + a11y bridge")
struct DebugEventSpyTests {

    /// Designed-red 2: every event the gate lets through is recorded — and
    /// forwarded (the guard half passes at red and green: observation never
    /// swallows the real transport's traffic).
    @Test func test_debugEventSpy_capturesEachEventThatPassedTheConsentGate() {
        let base = SpyAnalyticsSink()
        let spy = DebugEventSpySink(wrapping: base)
        let service = AnalyticsService(sink: spy, isOptedIn: { true })

        service.fire(.quizStepCompleted(stepNumber: 3))
        service.fire(.slipUndone)
        service.fire(.eraseAllCompleted)

        #expect(
            spy.capturedEntries.count == 3,
            "the debug event-spy must record every event the consent gate let through"
        )
        #expect(
            base.received.count == 3,
            "the decorator forwards every event to the wrapped transport — observation never swallows"
        )
    }

    /// Designed-red 3: capture order IS fire order, and the entry format is
    /// pinned — bare wire names, `:N` ordinal for quiz_step_completed only.
    @Test func test_debugEventSpy_preservesFireOrder() {
        let spy = DebugEventSpySink(wrapping: NoopAnalyticsSink())
        let service = AnalyticsService(sink: spy, isOptedIn: { true })

        service.fire(.quizStepCompleted(stepNumber: 3))
        service.fire(.quizStepCompleted(stepNumber: 4))
        service.fire(.quizCompleted(habitCategory: .vape, goalMode: .quit))
        service.fire(.slipUndone)

        #expect(
            spy.capturedEntries == [
                "quiz_step_completed:3", "quiz_step_completed:4", "quiz_completed", "slip_undone",
            ],
            "the spy must preserve fire order — the funnel is an ordered sequence"
        )
    }

    /// Designed-red 4: structural consent-honesty — a pre-consent fire never
    /// reaches the sink tier, a post-consent fire always does. The phases are
    /// MIXED so the expected value is non-empty (an inert-empty stub fails;
    /// a pure opted-out assertion would pass from birth and prove nothing).
    @Test func test_debugEventSpy_capturesOnlyPostConsentEvents() {
        let flag = OptInFlag() // off — the fresh-install default
        let base = SpyAnalyticsSink()
        let spy = DebugEventSpySink(wrapping: base)
        let service = AnalyticsService(sink: spy, isOptedIn: { flag.isOn })

        service.fire(.onboardingStarted(variant: "")) // pre-consent — gate-dropped
        service.fire(.quizStepCompleted(stepNumber: 1)) // pre-consent — gate-dropped
        flag.isOn = true // the slot-3 opt-in, write-at-tap
        service.fire(.quizStepCompleted(stepNumber: 3))
        service.fire(.quizCompleted(habitCategory: .vape, goalMode: .quit))

        #expect(
            spy.capturedEntries == ["quiz_step_completed:3", "quiz_completed"],
            "the spy observes only events past the consent gate — pre-consent fires are swallowed, post-consent are kept"
        )
        #expect(
            base.received.count == 2,
            "the gate property holds for the wrapped transport too — fire() gates BEFORE the sink tier"
        )
    }

    /// Designed-red 5: the app-side WRITE half of the a11y read bridge — the
    /// bridge element's `accessibilityValue` is the comma-joined entry list.
    /// (The XCUITest READ half is the smoke's green-side, first-run-is-evidence
    /// territory — R25.9's "unproven read-path tech" stays out of red.)
    @Test func test_debugEventSpy_bridgeExposesCapturedKindsAsAccessibilityValue() {
        let spy = DebugEventSpySink(wrapping: NoopAnalyticsSink())
        let service = AnalyticsService(sink: spy, isOptedIn: { true })

        service.fire(.quizStepCompleted(stepNumber: 3))
        service.fire(.quizCompleted(habitCategory: .vape, goalMode: .quit))

        #expect(
            spy.accessibilityBridgeValue == "quiz_step_completed:3,quiz_completed",
            "the a11y read-bridge must expose captured wire names as its accessibility value"
        )
    }
}
