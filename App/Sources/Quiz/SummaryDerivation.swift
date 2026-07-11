import Foundation

/// E5.3 — the pure answers→summary derivation (Architect Q3, Session 18; the
/// QuizProfileMapping precedent): Foundation-only so the Linux harness runs the
/// exact shipping bytes before any billed macOS run. The repository owns WHERE
/// the two values land (the EXISTING `QuizProfile.projectedAnnualSavings` /
/// `.predictedRiskWindow` fields, filled before the ONE save — no new field, no
/// second save); this owns WHAT they are.
///
/// The narrow `riskWindowToken(frequency:triggers:)` signature makes "derived
/// ONLY from frequency + trigger answers" provable by construction — spend,
/// motivations, and the custom name are unrepresentable inputs. `frequency` is
/// accepted but unused in v1 (a reserved cadence input, PM §3.2 — the wording is
/// a pure function of the selected triggers). No triggers → nil: insufficient
/// data shows nothing, not guesses (MVP §7 — no fabricated statistics).
///
/// These are quiz-time projections of IMMUTABLE answers — computed once at
/// completion, never recomputed against live time. They are deliberately NOT
/// wired into `recomputeDerivedState()` (Architect MUST-FIX 2: the
/// computed-never-stored invariant governs time-varying live state, not this).
enum SummaryDerivation {
    /// The precedence total order (PM §3.2): a clock/rhythm window (evenings,
    /// after work) is more actionable than a mood state, and the PRD's own
    /// example anchors on "evenings". First match over the user's selection wins.
    private static let precedence = ["evenings", "afterWork", "social", "alone", "boredom", "stress"]

    /// `weeklySpend × 52`, Decimal-exact — no floating point anywhere in the
    /// money path (the §1.1 test-9 class).
    static func projectedAnnualSavings(weeklySpend: Decimal) -> Decimal {
        weeklySpend * 52
    }

    /// The single highest-precedence selected trigger's token — "the FIRST hard
    /// window" is singular, so multiple selections collapse to the primary one.
    /// No triggers → nil (never a guess); an unrecognized ID can never win.
    static func riskWindowToken(frequency: String?, triggers: [String]) -> String? {
        precedence.first { triggers.contains($0) }
    }

    /// Convenience over the raw ordered answers, mirroring
    /// `QuizProfileMapping.draft(from:)` — the `createQuit` call site is one
    /// line. Reads ONLY spend, frequency, and triggers; the draft's field set
    /// stays untouched (frequency is deliberately NOT added to QuizQuitDraft).
    static func derive(from answers: [QuizAnswer]) -> (savings: Decimal, windowToken: String?) {
        func answer(_ stepID: String) -> QuizAnswer? {
            answers.first { $0.stepID == stepID }
        }
        let spend = answer("spend")?.freeText.flatMap { Decimal(string: $0) } ?? 0
        return (
            projectedAnnualSavings(weeklySpend: spend),
            riskWindowToken(
                frequency: answer("frequency")?.choiceIDs.first,
                triggers: answer("triggers")?.choiceIDs ?? []
            )
        )
    }
}
