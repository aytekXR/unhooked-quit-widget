import Foundation

/// E5.3 — the summary screen's read-only display inputs, straight from persisted
/// truth (Architect MUST-FIX 6): the profile's two filled fields + the quit's
/// stored currencyCode + the verbatim motivations. A plain value type so the
/// Linux harness compiles the exact shipping bytes.
struct QuizSummaryInputs: Equatable, Sendable {
    var savings: Decimal
    var currencyCode: String
    var riskToken: String?
    var motivations: [String]
}

/// What the summary card actually renders — absence is modeled at the DATA tier
/// (Architect S2): a nil line means the block is OMITTED and the card's rhythm
/// closes up (never an empty placeholder, never a dangling divider). The view is
/// a thin renderer over this.
struct SummaryViewData: Equatable, Sendable {
    var eyebrow: String
    /// "~$1,350" + the caption, or nil → the savingsAbsent reframe renders in
    /// the hero zone instead (AC4 — no figure, no "~$0/year").
    var savingsLine: String?
    var savingsCaption: String
    var savingsAbsent: String
    /// The hedged window phrase, or nil → no line at all (AC5 — insufficient
    /// data shows nothing, not guesses).
    var windowLine: String?
    /// The user's own words, verbatim, in their order; empty → the echo block is
    /// omitted entirely (invent no reasons — the ReasonsView discipline).
    var motivations: [String]
    var motivationIntro: String
    var cta: String
}

/// Pure inputs+copy → view data assembly (Architect Q3: display formatting is
/// computed, never stored). Foundation-only, Linux-harnessable.
enum SummaryPresentation {
    static func make(
        inputs: QuizSummaryInputs, copy: SummaryCopy, locale: Locale = .current
    ) -> SummaryViewData {
        SummaryViewData(
            eyebrow: copy.eyebrow,
            savingsLine: SummaryFormatter.savingsDisplay(
                inputs.savings, currencyCode: inputs.currencyCode, locale: locale
            ),
            savingsCaption: copy.savingsCaption,
            savingsAbsent: copy.savingsAbsent,
            windowLine: inputs.riskToken.flatMap { copy.phrase(forToken: $0) },
            motivations: inputs.motivations,
            motivationIntro: copy.motivationIntro,
            cta: copy.cta
        )
    }
}
