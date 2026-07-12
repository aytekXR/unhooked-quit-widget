import Foundation
import PaywallKit
import Testing
@testable import Unhooked

// E7.2 (R25.5/R25.7) — the paywall_viewed + teaser_entered fire-points, over
// the presentation seam's closure factory (`PaywallPresenter`): the S24
// deferrals R24.4 carried BY NAME, now wired. Every fire rides the ONE
// consent gate (`AnalyticsService.fire`); the assignment echo precedes the
// fire and exists ONLY on the live path (`echoAssignment` nil = the
// bundled/debug posture — dormant builds never write the echo, test-suite
// §4.4's honest reading). The variant wire value-domain is exactly
// {"teaser","hard"} (test-suite §4.4:213; R25.3).
//
// One of the four plan-named E7.2 tests lives here VERBATIM:
// `test_paywallViewed_carriesVariantAndSource`.
//
// RED: `PaywallPresenter`'s factories return inert closures and
// `PaywallModel.paywallPresented()`/`takeTeaser()` are no-ops — the fire
// pins fail by design; the opted-out zero-fire pins are born-green guards
// (they catch a green that fires around the consent gate).

/// The house spy shape, copied verbatim from QuizFlowModelTests (file-private
/// by the no-shared-fixtures convention).
@MainActor
private final class SpyAnalyticsSink: AnalyticsSink {
    private(set) var received: [AnalyticsEvent] = []
    func receive(_ event: AnalyticsEvent) { received.append(event) }
}

@MainActor
@Suite("E7.2 · paywall_viewed + teaser_entered wire")
struct PaywallViewedWireTests {
    private func makeModel(
        assignment: PaywallAssignment,
        source: PaywallSource,
        optedIn: Bool = true,
        echoAssignment: ((String) -> Void)? = nil
    ) -> (model: PaywallModel, spy: SpyAnalyticsSink) {
        let spy = SpyAnalyticsSink()
        let analytics = AnalyticsService(sink: spy, isOptedIn: { optedIn })
        let model = PaywallModel(
            purchase: { _ in .failed },
            restore: { .failed },
            firePaywallViewed: PaywallPresenter.makeFirePaywallViewed(
                assignment: assignment,
                source: source,
                analytics: analytics,
                echoAssignment: echoAssignment
            )
        )
        return (model, spy)
    }

    /// Plan-named (designed-red): one presentation fires exactly one
    /// paywall_viewed carrying the scripted assignment's variant + price arm
    /// AND the presentation source — and the live echo lands, echo-first
    /// (assign → echo → fire, R25.5).
    @Test func test_paywallViewed_carriesVariantAndSource() {
        var echoed: [String] = []
        let (model, spy) = makeModel(
            assignment: PaywallAssignment(variant: .teaser, priceTest: .annual3999),
            source: .onboarding,
            echoAssignment: { echoed.append($0) }
        )

        model.paywallPresented()

        #expect(
            spy.received == [.paywallViewed(variant: "teaser", priceTest: .annual3999, source: .onboarding)],
            "the render fires paywall_viewed with the assigned variant, the price arm, and the source (MVP §5)"
        )
        #expect(echoed == ["teaser"],
                "the live path echoes the assignment into AppSettings.paywallVariantAssigned (test-suite §4.4)")
    }

    /// Designed-red: the didFire guard — three presented() calls (SwiftUI
    /// re-renders, repeat onAppear) still fire ONE event per presentation.
    @Test func test_paywallViewed_firesOncePerPresentation() {
        let (model, spy) = makeModel(
            assignment: PaywallAssignment(variant: .hard, priceTest: .annual2999),
            source: .onboarding
        )

        model.paywallPresented()
        model.paywallPresented()
        model.paywallPresented()

        #expect(
            spy.received == [.paywallViewed(variant: "hard", priceTest: .annual2999, source: .onboarding)],
            "three appears, ONE event — once per presentation (the onSummaryAppear didFire precedent)"
        )
    }

    /// Designed-red: the bundled/dormant fallback's wire shape — variant
    /// "hard" (a first-class assignment value, NEVER a third "bundled"
    /// sentinel — R25.3 keeps the A/B denominator pristine), the CONTROL
    /// price arm, and NO echo (nil closure = the dormant posture; the echo
    /// is Superwall's sticky assignment alone).
    @Test func test_paywallViewed_bundledFallback_isHardControl_neverEchoes() async {
        let assignment = await BundledVariantAssigner().assignment(for: SuperwallPlacement.postSummary)
        let (model, spy) = makeModel(assignment: assignment, source: .onboarding, echoAssignment: nil)

        model.paywallPresented()

        #expect(
            spy.received == [.paywallViewed(variant: "hard", priceTest: .annual2999, source: .onboarding)],
            "the keyless/offline/removed fallback IS the hard control arm (architecture §8)"
        )
    }

    /// Born-green guard: opted-out ⇒ ZERO events — the ONE consent gate is
    /// real on every path, including the DEBUG render (a green that fires
    /// around the gate breaks ADR-8 and this pin catches it).
    @Test func test_paywallViewed_optedOut_firesNothing() {
        let (model, spy) = makeModel(
            assignment: PaywallAssignment(variant: .hard, priceTest: .annual2999),
            source: .onboarding,
            optedIn: false
        )

        model.paywallPresented()

        #expect(spy.received.isEmpty, "zero events before consent — the gate every seam shares")
    }

    /// Designed-red: taking the teaser escape fires teaser_entered(variant:
    /// "teaser") exactly once — double-taps stay single fires — and stamps
    /// the grant through the repository closure.
    @Test func test_teaserEntered_firesOnTeaserTake_once_andStampsGrant() {
        let spy = SpyAnalyticsSink()
        var stamped = 0
        let model = PaywallModel(
            purchase: { _ in .failed },
            restore: { .failed },
            onTeaserTaken: PaywallPresenter.makeOnTeaserTaken(
                analytics: AnalyticsService(sink: spy, isOptedIn: { true }),
                enterTeaser: { stamped += 1 }
            )
        )

        model.takeTeaser()
        model.takeTeaser()

        #expect(
            spy.received == [.teaserEntered(variant: "teaser")],
            "one take, one teaser_entered — the affordance only exists on the teaser arm (MVP §5)"
        )
        #expect(stamped == 1, "the grant stamps exactly once (single-use escape, R25.7)")
    }

    /// Designed-red on the stamp, born-green on the silence: an opted-out
    /// teaser take transmits NOTHING — but the grant itself must still stamp
    /// (consent gates ANALYTICS, never product behavior; a decliner's teaser
    /// day is as real as anyone's).
    @Test func test_teaserEntered_optedOut_firesNothing_grantStillStamps() {
        let spy = SpyAnalyticsSink()
        var stamped = 0
        let model = PaywallModel(
            purchase: { _ in .failed },
            restore: { .failed },
            onTeaserTaken: PaywallPresenter.makeOnTeaserTaken(
                analytics: AnalyticsService(sink: spy, isOptedIn: { false }),
                enterTeaser: { stamped += 1 }
            )
        )

        model.takeTeaser()

        #expect(spy.received.isEmpty, "zero events before consent (ADR-8)")
        #expect(stamped == 1, "the product grant is consent-independent — RED until takeTeaser wires")
    }

    /// Born-green data pins: the wire value-domains this session fixes
    /// (R25.3/R25.4/R25.11) — the free-String fields' value-domain tests the
    /// S15 Architect-SHOULD demands at each wiring session.
    @Test func test_wireValueDomains_areFixed() {
        #expect(Set(PaywallVariant.allCases.map(\.rawValue)) == ["teaser", "hard"],
                "variant assignment returns one of exactly {teaser, hard} (test-suite §4.4)")
        #expect(PaywallSource.teaserExpiry.rawValue == "teaser_expiry")
        #expect(SuperwallPlacement.postSummary == "quiz_completed",
                "the ONE E7.2 placement (architecture §5.2); winback is E7.3's")
    }
}
