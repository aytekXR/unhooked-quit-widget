import Foundation
import Testing
@testable import Unhooked

// E5.3 unit lane — the pure summary math + the navigation-order pin: projected
// annual savings is weeklySpend × 52 Decimal-exact with floor-to-ten display
// (Honest — a projection never overstates), the risk-window hint derives ONLY
// from frequency + trigger answers (the narrow signature makes every other input
// unrepresentable), insufficient data shows nothing (never a guessed window,
// never a fabricated "~$0/year"), and an in-session completion routes to the
// summary BEFORE anything else (P0 story 1: summary before any paywall, always).
// Doc-canonical names from implementation-plan.md E5.3.
//
// RED: `SummaryDerivation.projectedAnnualSavings` deliberately ignores the spend
// (returns .zero), `riskWindowToken` deliberately returns a non-nil EMPTY guess
// ("" — chosen so NO derivation row accidentally passes), `SummaryFormatter
// .savingsDisplay` deliberately fabricates "~$0/year" for every input, and
// `QuizGateRouting.postGateScreen` deliberately ignores `quizComplete` — the
// designed failures are the assertions below. Red evidence for this file = the
// CI run on the red commit; the Linux harness runs these bodies over the exact
// shipping bytes first and must predict the issues label-for-label.

/// Tests pin an EXPLICIT locale so the display literal is deterministic
/// (production passes the device locale for digit grouping only).
private let usEnglish = Locale(identifier: "en_US")

@Suite("E5.3 · summary derivation, display math & navigation order")
struct SummaryDerivationTests {

    // MARK: - Named test 1 (doc-canonical): savings math

    /// The test-suite §1.1 item-9 class: weekly spend $26 → stored Decimal 1352
    /// (26 × 52, exact) → floored to the tens → displayed "~$1,350/year". The
    /// PRD's illustrative "~$1,340/year" is class-level, not the rule's output.
    @Test func test_summary_projectedSavings_matchesSpendMath() {
        #expect(
            SummaryDerivation.projectedAnnualSavings(weeklySpend: 26) == Decimal(1352),
            "projected savings is weeklySpend × 52, Decimal-exact (MVP §2 item 1)"
        )
        #expect(
            SummaryFormatter.savingsDisplay(Decimal(1352), currencyCode: "USD", locale: usEnglish)
                == "~$1,350/year",
            "display floors to the tens with ~ and /year — a projection never overstates (Honest)"
        )
    }

    // MARK: - Decimal exactness (no floating point anywhere in the money path)

    /// A cents-bearing spend: a Double path drifts (9.99 × 52 → 519.47999…) and
    /// fails the Decimal equality — the exactness pin.
    @Test func test_summary_projectedSavings_decimalSafe_centsBearing() {
        #expect(
            SummaryDerivation.projectedAnnualSavings(weeklySpend: Decimal(string: "9.99")!)
                == Decimal(string: "519.48")!,
            "cents-bearing spend stays Decimal-exact — no Double in the money path"
        )
        #expect(
            SummaryFormatter.savingsDisplay(
                Decimal(string: "519.48")!, currencyCode: "USD", locale: usEnglish
            ) == "~$510/year",
            "519.48 floors to 510 — floor-to-ten applies below the thousands too"
        )
    }

    /// AC4: zero spend renders the savings-absent variant — never a fabricated
    /// "~$0/year" (MVP §7: no fabricated statistics).
    @Test func test_summary_projectedSavings_zeroSpend_showsNoFigure() {
        #expect(
            SummaryDerivation.projectedAnnualSavings(weeklySpend: 0) == 0,
            "zero spend stores the field default — nothing invented"
        )
        #expect(
            SummaryFormatter.savingsDisplay(0, currencyCode: "USD", locale: usEnglish) == nil,
            "zero spend displays NO figure — the absent variant renders, never ~$0/year (AC4)"
        )
    }

    // MARK: - Named test 2 (doc-canonical): risk window from trigger answers

    /// Multi-trigger picks the single highest-precedence token (PM §3.2 total
    /// order: evenings > afterWork > social > alone > boredom > stress).
    @Test func test_riskWindowHint_derivedFromTriggerAnswers() {
        #expect(
            SummaryDerivation.riskWindowToken(frequency: "daily", triggers: ["stress", "evenings"])
                == "evenings",
            "evenings outranks stress — the clock window is the actionable one"
        )
        #expect(
            SummaryDerivation.riskWindowToken(
                frequency: "weekly", triggers: ["afterWork", "social", "alone"]
            ) == "afterWork",
            "afterWork outranks social and alone (the §3.2 total order)"
        )
    }

    /// Each trigger alone maps to its own token — the identity row of the
    /// derivation table (tokens ARE the trigger choice IDs, quizConfig slot 7).
    @Test(arguments: ["evenings", "afterWork", "social", "alone", "boredom", "stress"])
    func test_riskWindow_singleTrigger_eachMapsToItsToken(_ trigger: String) {
        #expect(
            SummaryDerivation.riskWindowToken(frequency: "daily", triggers: [trigger]) == trigger,
            "a single selected trigger IS the window token: \(trigger)"
        )
    }

    /// AC5: no triggers → nil, regardless of frequency — insufficient data shows
    /// nothing, not guesses.
    @Test func test_riskWindow_noTriggers_isNilNoGuess() {
        #expect(
            SummaryDerivation.riskWindowToken(frequency: "daily", triggers: []) == nil,
            "no triggers → no window, never a guess (AC5)"
        )
        #expect(
            SummaryDerivation.riskWindowToken(frequency: "rarely", triggers: []) == nil,
            "frequency alone can never conjure a window"
        )
    }

    /// Frequency is a reserved v1 input that never alters the window; by the
    /// narrow signature, spend/motivations/custom-name are UNREPRESENTABLE inputs
    /// — "derived only from frequency + trigger answers" holds by construction.
    @Test func test_riskWindow_ignoresNonTriggerInputs() {
        #expect(
            SummaryDerivation.riskWindowToken(frequency: "multiDaily", triggers: ["evenings"])
                == "evenings",
            "the token is frequency-invariant (reserved v1 input)"
        )
        #expect(
            SummaryDerivation.riskWindowToken(frequency: "rarely", triggers: ["evenings"])
                == "evenings",
            "same triggers, different frequency, same token"
        )
    }

    // MARK: - Display rounding rule (floor, ratified over nearest — Brand-endorsed)

    /// Floor DOWN to the tens: 1359 and 1355 both display 1,350 — the …5 boundary
    /// proves floor ≠ nearest. A floored figure is always "this much or better."
    @Test func test_summary_savingsDisplay_floorsToTen() {
        #expect(
            SummaryFormatter.savingsDisplay(Decimal(1359), currencyCode: "USD", locale: usEnglish)
                == "~$1,350/year",
            "1359 floors to 1,350"
        )
        #expect(
            SummaryFormatter.savingsDisplay(Decimal(1355), currencyCode: "USD", locale: usEnglish)
                == "~$1,350/year",
            "1355 floors to 1,350 — floor, not nearest (never overstate)"
        )
    }

    /// Architect S4: the display uses the quit's STORED currencyCode — a non-USD
    /// code must not render a dollar sign (deterministic regardless of grouping).
    @Test func test_summary_savingsDisplay_usesQuitCurrencyCode() {
        let display = SummaryFormatter.savingsDisplay(
            Decimal(1352), currencyCode: "EUR", locale: usEnglish
        )
        #expect(
            display?.contains("$") == false,
            "EUR money never renders a dollar glyph — the stored code drives the symbol"
        )
    }

    // MARK: - Named test 3 (doc-canonical): summary before any paywall, always

    /// The routing tier pins P0 story 1 structurally: an in-session completion
    /// mounts the summary — and the post-gate screen set contains NO paywall
    /// surface at all this session (E7 owns paywall_viewed).
    @Test func test_summary_shownBeforeAnyPaywall() {
        #expect(
            QuizGateRouting.postGateScreen(hasActiveQuit: false, quizComplete: true) == .summary,
            "a fresh completion routes to the summary FIRST (P0 story 1)"
        )
        #expect(
            QuizGateRouting.postGateScreen(hasActiveQuit: false, quizComplete: false) == .quiz,
            "E5.2 behavior preserved: onboarding due → quiz"
        )
        #expect(
            QuizGateRouting.postGateScreen(hasActiveQuit: true, quizComplete: false) == .dashboard,
            "E5.2 behavior preserved: returning user → dashboard"
        )
        #expect(
            Set(QuizPostGateScreen.allCases) == Set([.quiz, .summary, .dashboard]),
            "the post-gate screen set carries NO paywall surface this session (E7's)"
        )
    }
}
