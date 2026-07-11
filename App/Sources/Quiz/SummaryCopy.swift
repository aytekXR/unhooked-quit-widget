import Foundation

/// E5.3 — the summary screen's ONE audited copy table (ADR-9; the SlipCopy /
/// AgeGateCopy precedent): its own file + its own type, deliberately SEPARATE
/// from `QuizConfig` so there is NO code path by which a summary string becomes
/// an engine-rendered quiz step (Architect Q1, Session 18 — the `steps[]` hazard
/// is eliminated by construction; `QuizFlowEngine` imports `QuizConfig`, never
/// this). Every string is DRAFT / founder-owned (operator-expected §3) and
/// lexicon-scanned by SlipLexiconTests' reflection walk — shipping AND degraded.
/// `_meta` decodes only `version`: the audit note quotes review context that must
/// never enter the scanned corpus (the SlipCopy precedent).
struct SummaryCopy: Codable, Equatable, Sendable {
    struct Meta: Codable, Equatable, Sendable {
        var version: Int
    }

    var meta: Meta
    /// Quiet eyebrow above the hero savings figure.
    var eyebrow: String
    /// Under the hero figure; carries the Honest hedge — the projection assumes
    /// staying on track and the spend was user-estimated.
    var savingsCaption: String
    /// AC4: zero spend → this non-monetary reframe renders in the hero zone.
    /// Never "~$0/year" — no fabricated figure (MVP §7).
    var savingsAbsent: String
    /// The six risk-window phrases, one per trigger token (explicit named fields —
    /// Architect Q1: the strongest reflection-walk guarantee; a map could hide a
    /// missing row from Mirror-based floors). Lookup via `phrase(forToken:)`.
    /// Register rule (Brand, Session 18): every phrase carries the "likely"
    /// reflection hedge — the user's own answer echoed back, never a clinical
    /// prediction; "predicted" stays quarantined to the internal field name.
    var windowEvenings: String
    var windowAfterWork: String
    var windowSocial: String
    var windowAlone: String
    var windowBoredom: String
    var windowStress: String
    /// Intro line above the user's verbatim motivation words (their words, their
    /// order — the framing is ours, the words are theirs).
    var motivationIntro: String
    /// The single forward CTA — the label on AC8's named E7 seam.
    var cta: String

    enum CodingKeys: String, CodingKey {
        case meta = "_meta"
        case eyebrow, savingsCaption, savingsAbsent
        case windowEvenings, windowAfterWork, windowSocial
        case windowAlone, windowBoredom, windowStress
        case motivationIntro, cta
    }

    /// The stored token → display phrase map (PM §3.2). An unknown token renders
    /// nothing (the defensive arm of AC5 — never a guessed window).
    func phrase(forToken token: String) -> String? {
        switch token {
        case "evenings": windowEvenings
        case "afterWork": windowAfterWork
        case "social": windowSocial
        case "alone": windowAlone
        case "boredom": windowBoredom
        case "stress": windowStress
        default: nil
        }
    }

    /// Decodes the shipping file from the app bundle. `nil` when missing or
    /// undecodable — the caller falls to `.degraded` (a decode failure must never
    /// dead-end the payoff screen; the funnel is the business).
    static func loadShipping(bundle: Bundle = .main) -> SummaryCopy? {
        guard let url = bundle.url(forResource: "summaryCopy", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else { return nil }
        return try? JSONDecoder().decode(SummaryCopy.self, from: data)
    }

    /// The §9 degraded fallback — byte-identical to the shipping strings (this
    /// table is small enough that degraded == shipping; no visible degradation).
    /// Scanned by the lexicon gate alongside the shipping file.
    static let degraded = SummaryCopy(
        meta: Meta(version: 1),
        eyebrow: "Based on your answers",
        savingsCaption: "saved in a year, if you stay on track.",
        savingsAbsent: "Every clean day is time and focus back — we'll count the streak that matters to you.",
        windowEvenings: "Your first hard window is likely evenings.",
        windowAfterWork: "Your first hard window is likely just after work.",
        windowSocial: "Your first hard window is likely around social plans.",
        windowAlone: "Your first hard window is likely in quiet moments alone.",
        windowBoredom: "Your first hard window is likely when things get idle.",
        windowStress: "Your first hard window is likely when stress spikes.",
        motivationIntro: "You're doing this for:",
        cta: "Continue"
    )
}
