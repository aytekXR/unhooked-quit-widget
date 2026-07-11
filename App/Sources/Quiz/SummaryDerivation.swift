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
    /// RED STUB — deliberately ignores the spend. Green: `weeklySpend × 52`,
    /// Decimal-exact, no floating point anywhere.
    static func projectedAnnualSavings(weeklySpend: Decimal) -> Decimal {
        .zero
    }

    /// RED STUB — deliberately returns a non-nil empty guess. Green: the single
    /// highest-precedence selected trigger's token (evenings > afterWork >
    /// social > alone > boredom > stress — PM §3.2 total order); [] → nil.
    static func riskWindowToken(frequency: String?, triggers: [String]) -> String? {
        ""
    }

    /// Convenience over the raw ordered answers, mirroring
    /// `QuizProfileMapping.draft(from:)` — the `createQuit` call site is one line.
    /// RED STUB — feeds the stubs above nothing real.
    static func derive(from answers: [QuizAnswer]) -> (savings: Decimal, windowToken: String?) {
        (projectedAnnualSavings(weeklySpend: .zero), riskWindowToken(frequency: nil, triggers: []))
    }
}
