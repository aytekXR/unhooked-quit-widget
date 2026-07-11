import Foundation
import Observation

/// E5.2 — the quiz's @Observable shell (architecture §7 `QuizFlowModel`) over the
/// pure `QuizFlowEngine`. Holds NO clock (Architect MUST-FIX 4 — the repository
/// stamps every date) and imports NO SwiftData (MUST-FIX 7 — the QuizProfile is
/// assembled by `QuitRepository.completeQuiz`, handed in as `onComplete`).
///
/// Analytics discipline: production injects `.disabled` (the AgeGateModel
/// precedent — consent is hardwired OFF until E8.2); tests inject an opted-IN
/// spy. Every fire goes through `AnalyticsService.fire()`, post-checkpoint-write,
/// BESIDE the write, never inside it (§1.2 invariant 3). quiz_completed fires
/// via `onSummaryAppear()`, invoked by the summary view at render (R2's
/// canonical trigger: "Personalized summary shown") — never from `complete()`.
@MainActor
@Observable
final class QuizFlowModel {
    /// The E5.3 handoff (R2): `complete()` never fires quiz_completed — the
    /// summary render does (`onSummaryAppear()`), carrying exactly these two values.
    struct CompletionHandoff: Equatable, Sendable {
        var habitCategory: HabitCategory
        var goalMode: GoalMode
    }

    private(set) var engine: QuizFlowEngine
    private(set) var completion: CompletionHandoff?
    /// SHOULD-4: a completion failure surfaces calmly (never a dead end, never a
    /// `try!`); the checkpoint stays intact so nothing is lost.
    private(set) var completionFailed = false

    private let analytics: AnalyticsService
    private let checkpoint: QuizProgressStore
    private let variant: String
    private let onComplete: ([QuizAnswer]) throws -> Void
    /// MUST-FIX 6: a mid-quiz relaunch resumes from the checkpoint and must NOT
    /// re-fire onboarding_started (double-counting corrupts the start→summary
    /// funnel denominator).
    private let resumedFromCheckpoint: Bool
    private var didFireOnboardingStarted = false
    /// E5.3 (Architect Q4): the durable once-per-completion guard for the
    /// summary-render quiz_completed fire — the onboarding_started precedent.
    private var didFireQuizCompleted = false

    /// `variant` is `AppSettings.onboardingVariant` read verbatim at the
    /// composition root (R3 — "" until E7/Superwall assigns it; never fabricated).
    /// `onComplete` is `QuitRepository.completeQuiz` in production (MUST-FIX 7).
    /// A non-empty checkpoint resumes the interrupted quiz (architecture §7).
    init(
        config: QuizConfig,
        analytics: AnalyticsService = .disabled,
        checkpoint: QuizProgressStore = QuizProgressStore(),
        variant: String = "",
        onComplete: @escaping ([QuizAnswer]) throws -> Void = { _ in }
    ) {
        self.analytics = analytics
        self.checkpoint = checkpoint
        self.variant = variant
        self.onComplete = onComplete
        if let progress = checkpoint.load() {
            self.engine = QuizFlowEngine.resume(config: config, progress: progress)
            self.resumedFromCheckpoint = true
        } else {
            self.engine = QuizFlowEngine(config: config)
            self.resumedFromCheckpoint = false
        }
    }

    var visibleSteps: [QuizConfig.Step] { engine.visibleSteps }
    var currentStep: QuizConfig.Step? { engine.currentStep }
    /// The current step's FIXED canonical slot (R1) — the analytics number.
    var currentSlot: Int { engine.currentStep?.slot ?? 0 }
    /// The user's visible-sequence position (R9) — the progress-bar number. Two
    /// different numbers, both honest.
    var progressPosition: (index: Int, total: Int) {
        (engine.index + 1, engine.visibleSteps.count)
    }
    var isComplete: Bool { completion != nil }

    func record(_ answer: QuizAnswer) {
        engine.setAnswer(answer)
    }

    func answer(for stepID: String) -> QuizAnswer? {
        engine.answer(for: stepID)
    }

    /// Forward advance: commit the answers + position to the checkpoint FIRST,
    /// then fire quiz_step_completed(slot) beside that write (§1.2 invariant 3 —
    /// "post-save" for a step advance is post-checkpoint-write), then complete
    /// when the last visible step is passed.
    func advance() {
        let outcome = engine.advance()
        checkpoint.save(engine.progress())
        if let slot = outcome.firedStep {
            analytics.fire(.quizStepCompleted(stepNumber: slot))
        }
        if outcome.didComplete {
            complete()
        }
    }

    /// Back preserves answers and fires nothing (AC5); the checkpoint follows the
    /// position so a mid-quiz relaunch resumes exactly where the user stood.
    func back() {
        engine.back()
        checkpoint.save(engine.progress())
    }

    /// Fires onboarding_started(variant:) exactly once, when the FIRST quiz screen
    /// renders on a FRESH entry — idempotent against re-renders, suppressed on a
    /// checkpoint resume (MUST-FIX 6).
    func onFirstScreenAppear() {
        guard !resumedFromCheckpoint, !didFireOnboardingStarted else { return }
        didFireOnboardingStarted = true
        analytics.fire(.onboardingStarted(variant: variant))
    }

    /// E5.3 — the summary-render fire-point (R2's canonical trigger, Architect
    /// Q4/Session 18): the summary view calls this in `.onAppear`. Fires
    /// quiz_completed exactly once per completion, payload exactly the handoff's
    /// (habitCategory, goalMode) — the guard is durable because the model is the
    /// mounting view's @State (survives every re-render); no completion in hand
    /// → nothing, never a fabricated fire.
    func onSummaryAppear() {
        guard let completion, !didFireQuizCompleted else { return }
        didFireQuizCompleted = true
        analytics.fire(.quizCompleted(
            habitCategory: completion.habitCategory,
            goalMode: completion.goalMode
        ))
    }

    /// Completion: hand the ordered answers to the repository (the one QuizProfile
    /// assembler), expose the E5.3 handoff, and clear the checkpoint ONLY on
    /// success — a failed save keeps every answer recoverable.
    private func complete() {
        let answers = engine.orderedAnswers()
        do {
            try onComplete(answers)
            completionFailed = false
            let draft = QuizProfileMapping.draft(from: answers)
            completion = CompletionHandoff(
                habitCategory: draft.habitCategory,
                goalMode: draft.goalMode
            )
            checkpoint.clear()
        } catch {
            completionFailed = true
        }
    }
}
