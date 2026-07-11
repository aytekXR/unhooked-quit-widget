import Foundation

/// E5.2 — what the normal route hosts AFTER the age gate passes (Architect
/// MUST-FIX 8; the AgeGateRouting pure-decision precedent). Additive: the gate's
/// own `firstScreen` contract is untouched — this decides only what the passed
/// branch mounts.
enum QuizPostGateScreen: Equatable, Sendable, CaseIterable {
    /// No active quit exists: onboarding continues — the quiz is the first habit
    /// surface (the Epic-5 DoD un-bypassability seam: content is never reachable
    /// except through gate → quiz → quit).
    case quiz
    /// E5.3: the quiz completed IN THIS SESSION — the personalized summary (the
    /// payoff screen; quiz_completed's canonical MVP §5 trigger surface). The
    /// completion is in-memory only (summary-once, Architect Q2): a relaunch has
    /// no completion in hand and lands on the dashboard, never a re-shown summary.
    case summary
    /// A quit exists (and no in-session completion): the dashboard placeholder.
    case dashboard
}

enum QuizGateRouting {
    /// `quizComplete` defaults false so the E5.2 call sites (the model-build
    /// decision) are untouched — they ask "is onboarding due", never "what does
    /// a completion mount". An in-session completion routes to .summary BEFORE
    /// anything else (P0 story 1: the summary always precedes any future paywall
    /// surface) — including over `hasActiveQuit`, because completing the quiz
    /// just CREATED a quit.
    static func postGateScreen(hasActiveQuit: Bool, quizComplete: Bool = false) -> QuizPostGateScreen {
        if quizComplete { return .summary }
        return hasActiveQuit ? .dashboard : .quiz
    }
}
