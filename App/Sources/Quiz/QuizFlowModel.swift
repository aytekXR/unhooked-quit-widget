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
/// BESIDE the write, never inside it (§1.2 invariant 3).
///
/// RED COMMIT: the marked members are deliberately wrong stubs — the designed
/// failures for the E5.2 red-evidence run.
@MainActor
@Observable
final class QuizFlowModel {
    /// The E5.3 handoff (R2): quiz_completed is NOT fired here — the summary
    /// screen fires it when it renders, carrying exactly these two values.
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
        } else {
            self.engine = QuizFlowEngine(config: config)
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

    /// RED STUB — advances without the checkpoint write; fires only what the
    /// engine reports (nothing at red).
    func advance() {
        let outcome = engine.advance()
        if let slot = outcome.firedStep {
            analytics.fire(.quizStepCompleted(stepNumber: slot))
        }
        if outcome.didComplete {
            complete()
        }
    }

    /// Back preserves answers and fires nothing (AC5) — the engine owns the
    /// preservation semantics (deliberately wrong at red).
    func back() {
        engine.back()
    }

    /// RED STUB — never fires. Green: fires onboarding_started(variant:) exactly
    /// once, on a FRESH quiz entry only — a checkpoint resume never re-fires
    /// (Architect MUST-FIX 6: double-counting corrupts the funnel denominator).
    func onFirstScreenAppear() {}

    /// Completion: hand the ordered answers to the repository (the one QuizProfile
    /// assembler), then expose the E5.3 handoff. RED: the checkpoint is
    /// deliberately NOT cleared here.
    private func complete() {
        let answers = engine.orderedAnswers()
        do {
            try onComplete(answers)
            let draft = QuizProfileMapping.draft(from: answers)
            completion = CompletionHandoff(
                habitCategory: draft.habitCategory,
                goalMode: draft.goalMode
            )
        } catch {
            completionFailed = true
        }
    }
}
