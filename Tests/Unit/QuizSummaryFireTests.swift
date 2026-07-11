import Foundation
import Testing
@testable import Unhooked

// E5.3 unit lane — the quiz_completed fire-point at the summary render (R2's
// canonical MVP §5 trigger: "Personalized summary shown"): the summary view calls
// `QuizFlowModel.onSummaryAppear()` in `.onAppear`, which fires exactly once per
// completion with payload EXACTLY {habit_category, goal_mode} from the
// CompletionHandoff — re-appears fire nothing (the durable-guard
// `onFirstScreenAppear` precedent), a pre-completion call fires nothing (never a
// fabricated completion), and the ADR-8 consent gate still swallows everything
// when opted out (production ships `.disabled` until E8.2).
//
// RED: `onSummaryAppear()` is a deliberate no-op — the designed failures are the
// fire assertions below; the two zero-fire pins pass at red BY DESIGN (guards
// that catch a green which fires unconditionally). Red evidence for this file =
// the CI run on the red commit; the Linux harness runs these bodies over the
// exact shipping bytes first (QuizFlowModel + the real AnalyticsService compile
// on the Linux toolchain).
//
// Models drive to completion over `QuizConfig.degraded` (4 steps — the shortest
// honest path to a real CompletionHandoff; the shipping-config completion path
// is QuizFlowModelTests/QuizCompletionTests territory).

/// The house spy shape, copied verbatim from QuizFlowModelTests (file-private by
/// the no-shared-fixtures convention).
@MainActor
private final class SpyAnalyticsSink: AnalyticsSink {
    private(set) var received: [AnalyticsEvent] = []
    func receive(_ event: AnalyticsEvent) { received.append(event) }
}

@MainActor
@Suite("E5.3 · quiz_completed fires on summary render")
struct QuizSummaryFireTests {

    private func throwawayStore() -> QuizProgressStore {
        QuizProgressStore(defaults: UserDefaults(suiteName: "e53-fire-\(UUID().uuidString)")!)
    }

    /// A model driven through the degraded config to a REAL completion (the
    /// default `onComplete` succeeds), with an opted-IN spy (the AgeGateTests
    /// polarity ruling: an opted-out service would swallow any stray fire and
    /// prove nothing).
    private func makeCompletedModel(
        habit: String = "vape", goal: String = "quit", optedIn: Bool = true
    ) -> (model: QuizFlowModel, spy: SpyAnalyticsSink) {
        let spy = SpyAnalyticsSink()
        let model = QuizFlowModel(
            config: .degraded,
            analytics: AnalyticsService(sink: spy, isOptedIn: { optedIn }),
            checkpoint: throwawayStore()
        )
        model.record(QuizAnswer(stepID: "habit", choiceIDs: [habit]))
        model.advance()
        model.record(QuizAnswer(stepID: "spend", choiceIDs: [], freeText: "26"))
        model.advance()
        model.record(QuizAnswer(stepID: "motivations", choiceIDs: ["Energy"]))
        model.advance()
        model.record(QuizAnswer(stepID: "goal", choiceIDs: [goal]))
        model.advance()
        return (model, spy)
    }

    /// The fire-point pin: one summary render → exactly one quiz_completed,
    /// carrying the handoff's values.
    @Test func test_summary_render_firesQuizCompletedOncePerCompletion() {
        let (model, spy) = makeCompletedModel()
        #expect(model.isComplete, "the degraded drive reaches a real completion")
        model.onSummaryAppear()
        let fired = spy.received.filter { $0.kind == .quizCompleted }
        #expect(
            fired == [.quizCompleted(habitCategory: .vape, goalMode: .quit)],
            "summary render fires quiz_completed exactly once, from the handoff (R2/AC7)"
        )
    }

    /// Re-appear/re-layout fires nothing more — the durable guard (the
    /// `onFirstScreenAppear` didFire precedent; the model is @State-held, so the
    /// guard survives every re-render).
    @Test func test_summary_reRender_firesNothing() {
        let (model, spy) = makeCompletedModel()
        model.onSummaryAppear()
        model.onSummaryAppear()
        model.onSummaryAppear()
        let fired = spy.received.filter { $0.kind == .quizCompleted }
        #expect(
            fired == [.quizCompleted(habitCategory: .vape, goalMode: .quit)],
            "three appears, ONE event — once per completion, idempotent re-render (AC7)"
        )
    }

    /// The payload is EXACTLY the two MVP §5 columns — no savings figure, no
    /// window token, no motivation, no spend can ride (unrepresentable in the
    /// closed case, and pinned here key-for-key).
    @Test func test_summary_payloadExact_carriesOnlyCategoryAndGoal() {
        let (model, spy) = makeCompletedModel(habit: "custom", goal: "reduce")
        model.onSummaryAppear()
        let fired = spy.received.filter { $0.kind == .quizCompleted }
        #expect(fired.count == 1, "exactly one quiz_completed per completion")
        #expect(
            fired.first?.parameters == ["habit_category": "custom", "goal_mode": "reduce"],
            "payload is EXACTLY {habit_category, goal_mode} — nothing else rides (MVP §5)"
        )
    }

    /// Zero-fire guard (passes at red AND green): no completion in hand → no
    /// event — a summary appear can never fabricate a completion.
    @Test func test_summary_onAppearBeforeCompletion_firesNothing() {
        let spy = SpyAnalyticsSink()
        let model = QuizFlowModel(
            config: .degraded,
            analytics: AnalyticsService(sink: spy, isOptedIn: { true }),
            checkpoint: throwawayStore()
        )
        model.record(QuizAnswer(stepID: "habit", choiceIDs: ["vape"]))
        model.advance() // mid-quiz: three steps remain — no completion exists
        model.onSummaryAppear()
        #expect(
            spy.received.filter { $0.kind == .quizCompleted }.isEmpty,
            "no completion → no quiz_completed, ever (never a fabricated fire)"
        )
    }

    /// Zero-fire guard (passes at red AND green): the ADR-8 consent gate holds at
    /// the summary seam — opted out, NOTHING reaches the sink (production ships
    /// `.disabled` until E8.2; this pins the seam against a bypass).
    @Test func test_summary_optedOut_firesNothing() {
        let (model, spy) = makeCompletedModel(optedIn: false)
        model.onSummaryAppear()
        #expect(
            spy.received.isEmpty,
            "opted out: zero events reach the sink from the whole quiz + summary surface"
        )
    }
}
