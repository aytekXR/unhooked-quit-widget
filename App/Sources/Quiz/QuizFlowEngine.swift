import Foundation

/// E5.2 — the pure quiz flow (Architect SHOULD-2; the AgeGate "pure decision +
/// thin model" precedent): config + answers + a position, Foundation-only so the
/// Linux harness runs the exact shipping bytes. The @Observable shell is
/// `QuizFlowModel`; the risky logic (visibility, conditional gating, the R1
/// fixed-ordinal numbering, back/advance semantics, resume) lives HERE.
struct QuizFlowEngine {
    let config: QuizConfig
    private(set) var answers: [String: QuizAnswer]
    private(set) var index: Int

    struct AdvanceOutcome: Equatable, Sendable {
        /// The FIXED canonical slot to report as quiz_step_completed (R1) — nil
        /// when nothing fires (seam/hidden steps never report).
        var firedStep: Int?
        var didComplete: Bool
    }

    init(config: QuizConfig) {
        self.config = config
        self.answers = [:]
        self.index = 0
    }

    /// The rendered sequence: the reserved seam is ALWAYS excluded in E5.2 (R4 —
    /// E8.2 renders it), and a conditional step is visible iff its referenced
    /// answer contains the required choice. Canonical slots ride the steps
    /// untouched — hiding a step never renumbers its neighbors (R1).
    var visibleSteps: [QuizConfig.Step] {
        config.steps.filter { step in
            guard step.kind != .seam else { return false }
            guard let condition = step.condition else { return true }
            return answers[condition.whenStep]?.choiceIDs.contains(condition.equals) == true
        }
    }

    var currentStep: QuizConfig.Step? {
        let steps = visibleSteps
        guard index >= 0, index < steps.count else { return nil }
        return steps[index]
    }

    /// Answers are keyed by the answer's OWN stepID — a record never lands on the
    /// wrong step because the sequence moved.
    mutating func setAnswer(_ answer: QuizAnswer) {
        answers[answer.stepID] = answer
    }

    func answer(for stepID: String) -> QuizAnswer? {
        answers[stepID]
    }

    /// Advances past the current visible step, reporting its fixed slot for the
    /// quiz_step_completed fire ("every step advance" — a re-advance after Back
    /// honestly re-fires). Advancing past the last visible step completes.
    mutating func advance() -> AdvanceOutcome {
        guard let step = currentStep else {
            return AdvanceOutcome(firedStep: nil, didComplete: true)
        }
        index += 1
        return AdvanceOutcome(firedStep: step.slot, didComplete: index >= visibleSteps.count)
    }

    /// Back moves to the prior visible step and preserves every answer (AC5) —
    /// the prior screen re-hydrates from `answer(for:)`.
    mutating func back() {
        index = max(0, index - 1)
    }

    /// The canonical (visible-order) answer list — what completion hands the
    /// repository for `QuizProfile.answers`.
    func orderedAnswers() -> [QuizAnswer] {
        visibleSteps.compactMap { answers[$0.id] }
    }

    /// The checkpoint payload for the CURRENT position (written after an advance,
    /// so a resume lands on the step the user was about to answer).
    func progress() -> QuizProgress {
        QuizProgress(currentStepID: currentStep?.id ?? "", answers: orderedAnswers())
    }

    /// Rebuilds an engine from a checkpoint (architecture §7 resume). Answers are
    /// restored FIRST so conditional visibility is computed before the position
    /// is resolved against the visible sequence.
    static func resume(config: QuizConfig, progress: QuizProgress) -> QuizFlowEngine {
        var engine = QuizFlowEngine(config: config)
        for answer in progress.answers {
            engine.setAnswer(answer)
        }
        engine.index = engine.visibleSteps.firstIndex { $0.id == progress.currentStepID } ?? 0
        return engine
    }
}
