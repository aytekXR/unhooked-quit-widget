import Foundation

/// E5.2 — what the normal route hosts AFTER the age gate passes (Architect
/// MUST-FIX 8; the AgeGateRouting pure-decision precedent). Additive: the gate's
/// own `firstScreen` contract is untouched — this decides only what the passed
/// branch mounts.
enum QuizPostGateScreen: Equatable, Sendable {
    /// No active quit exists: onboarding continues — the quiz is the first habit
    /// surface (the Epic-5 DoD un-bypassability seam: content is never reachable
    /// except through gate → quiz → quit).
    case quiz
    /// A quit exists: the dashboard placeholder (E5.3+ replaces it).
    case dashboard
}

enum QuizGateRouting {
    static func postGateScreen(hasActiveQuit: Bool) -> QuizPostGateScreen {
        hasActiveQuit ? .dashboard : .quiz
    }
}
