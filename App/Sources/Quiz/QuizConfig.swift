import Foundation

/// E5.2 — the bundled quiz definition (`App/Resources/Content/quizConfig.json`): the
/// ONE audited copy table for the onboarding quiz (ADR-9 — architecture §4 names the
/// quiz definition as bundled versioned static content; the ageGateCopy/slipCopy
/// precedent). Field names mirror the JSON exactly. Every string is DRAFT and
/// founder-owned (roadmap: agents scaffold screens, copy is founder-owned); the
/// decoded table AND the degraded fallback are scanned against the forbidden
/// lexicon on every CI run (SlipLexiconTests).
///
/// `_meta` deliberately decodes ONLY `version`: the free-text audit note quotes
/// review context that must never enter the scanned corpus (the SlipCopy precedent).
struct QuizConfig: Codable, Equatable, Sendable {
    struct Meta: Codable, Equatable, Sendable {
        var version: Int
    }

    /// The question kinds the engine renders. `seam` is a RESERVED slot another
    /// epic owns (today: slot 3, consent, E8.2) — never rendered, never numbered
    /// into events by E5.2 (resume-prompt scope guard c; R4).
    enum StepKind: String, Codable, Sendable {
        case singleChoice, multiChoice, decimalInput, freeText, slider, seam
    }

    struct Choice: Codable, Equatable, Sendable {
        var id: String
        var label: String
    }

    /// Conditional visibility: the step renders iff the referenced step's answer
    /// contains `equals` (custom-name iff habit == custom; allowance iff goal ==
    /// reduce). Canonical slots never renumber around hidden steps (R1).
    struct Condition: Codable, Equatable, Sendable {
        var whenStep: String
        var equals: String
    }

    struct Step: Codable, Equatable, Sendable {
        var id: String
        var kind: StepKind
        /// The FIXED canonical analytics ordinal (MVP §5 step_number 1–14; R1) —
        /// never a per-user rendered position (that is `progressPosition`, R9).
        var slot: Int
        var condition: Condition?
        var title: String?
        var choices: [Choice]?
        var placeholder: String?
        var helper: String?
        var sliderEchoes: [String]?
        /// Seam-only: which epic owns the reserved slot ("E8.2"). A seam carries
        /// no rendered strings by design.
        var owner: String?
    }

    struct Controls: Codable, Equatable, Sendable {
        var continueLabel: String
        var backLabel: String
        /// Filled with the user's VISIBLE-sequence position/total (R9) — never the
        /// canonical analytics slot.
        var progressA11yFormat: String
        var spendPlaceholder: String
    }

    var meta: Meta
    var steps: [Step]
    var controls: Controls

    enum CodingKeys: String, CodingKey {
        case meta = "_meta"
        case steps
        case controls
    }

    /// Decodes the shipping file from the app bundle. `nil` when missing or
    /// undecodable — the caller falls to `.degraded` (AC12: a decode failure must
    /// never dead-end onboarding; the funnel is the business).
    static func loadShipping(bundle: Bundle = .main) -> QuizConfig? {
        guard let url = bundle.url(forResource: "quizConfig", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else { return nil }
        return try? JSONDecoder().decode(QuizConfig.self, from: data)
    }

    /// The §9 degraded fallback — a minimal habit → spend → motivations → goal flow
    /// that still creates a valid Quit (the fields the panic flow, money math, and
    /// goal mode need). Plainer and shorter, still zero-shame, still scanned by the
    /// lexicon gate alongside the shipping table. Canonical slots keep their
    /// shipping numbers so analytics stay honest even degraded.
    static let degraded = QuizConfig(
        meta: Meta(version: 1),
        steps: [
            Step(
                id: "habit", kind: .singleChoice, slot: 1,
                title: "Choose a focus",
                choices: [
                    Choice(id: "vape", label: "Vaping"),
                    Choice(id: "porn", label: "Adult content"),
                    Choice(id: "alcohol", label: "Alcohol"),
                    Choice(id: "weed", label: "Cannabis"),
                    Choice(id: "doomscroll", label: "Doomscrolling"),
                    Choice(id: "custom", label: "Something else"),
                ]
            ),
            Step(
                id: "spend", kind: .decimalInput, slot: 5,
                title: "Weekly spend?",
                placeholder: "0"
            ),
            Step(
                id: "motivations", kind: .multiChoice, slot: 9,
                title: "What's driving this?",
                choices: [
                    Choice(id: "Energy", label: "Energy"),
                    Choice(id: "Money", label: "Money"),
                    Choice(id: "Relationships", label: "Relationships"),
                    Choice(id: "Self-respect", label: "Self-respect"),
                    Choice(id: "Faith", label: "Faith"),
                    Choice(id: "Focus", label: "Focus"),
                ]
            ),
            Step(
                id: "goal", kind: .singleChoice, slot: 11,
                title: "Quit or cut down?",
                choices: [
                    Choice(id: "quit", label: "Quit completely"),
                    Choice(id: "reduce", label: "Cut down"),
                ]
            ),
        ],
        controls: Controls(
            continueLabel: "Continue",
            backLabel: "Back",
            progressA11yFormat: "Step %1$d of %2$d",
            spendPlaceholder: "0"
        )
    )
}
