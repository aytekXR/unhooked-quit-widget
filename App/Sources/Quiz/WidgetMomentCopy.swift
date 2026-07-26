import Foundation

/// ME-1 (redesign §6.15) — the widget-adoption moment's ONE audited copy table
/// (ADR-9; the `SummaryCopy` precedent: its own file + its own type, so no code
/// path can turn an adoption string into an engine-rendered quiz step). Every
/// string is DRAFT / founder-owned (operator-instructed, founder pass pending —
/// operator-expected §3) and lexicon-scanned by SlipLexiconTests' reflection
/// walk — shipping AND degraded. `_meta` decodes only `version`: the audit note
/// quotes review context that must never enter the scanned corpus (the SlipCopy
/// precedent).
struct WidgetMomentCopy: Codable, Equatable, Sendable {
    struct Meta: Codable, Equatable, Sendable {
        var version: Int
    }

    var meta: Meta
    /// Quiet eyebrow above the title — "Before the first hard moment", never
    /// keynote cosplay (copy doc §4).
    var eyebrow: String
    var title: String
    /// The wedge, stated plainly: help that works pre-unlock.
    var body: String
    /// Sits under the live preview; the second sentence IS the discreet-mode
    /// reassurance the app previously lacked.
    var visualCaption: String
    /// VoiceOver framing for the live preview (redesign §8: "the widget-adoption
    /// preview is described"). The preview's CONTENT is pure feed data (Day N,
    /// money, Reset) appended at render time — this label carries no data.
    var previewAccessibilityLabel: String
    /// Opens the 3-step guided overlay.
    var primaryCTA: String
    /// The guided add, honest about iOS's manual flow — each step one line, no
    /// body text (copy doc §4).
    var guideSteps: [String]
    /// The overlay's quiet door.
    var guideDismiss: String
    /// The quiet escape ("Maybe later") — a Settings row keeps the door open
    /// (copy doc §11; the settings re-entry rides ME-7's rebuilt Settings).
    var secondaryCTA: String
    /// Serves the privacy-first persona without naming why (copy doc §4).
    var discreetFootnote: String

    enum CodingKeys: String, CodingKey {
        case meta = "_meta"
        case eyebrow, title, body, visualCaption, previewAccessibilityLabel
        case primaryCTA, guideSteps, guideDismiss, secondaryCTA, discreetFootnote
    }

    /// Decodes the shipping file from the app bundle. `nil` when missing or
    /// undecodable — the caller falls to `.degraded` (a decode failure must
    /// never dead-end the funnel's north-star step).
    static func loadShipping(bundle: Bundle = .main) -> WidgetMomentCopy? {
        guard let url = bundle.url(forResource: "widgetMomentCopy", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else { return nil }
        return try? JSONDecoder().decode(WidgetMomentCopy.self, from: data)
    }

    /// The §9 degraded fallback — byte-identical to the shipping strings (the
    /// SummaryCopy shape: this table is small enough that degraded == shipping;
    /// no visible degradation). Scanned by the lexicon gate alongside shipping.
    static let degraded = WidgetMomentCopy(
        meta: Meta(version: 1),
        eyebrow: "Before the first hard moment",
        title: "Put help on your lock screen",
        body: "The panic button works before you even unlock your phone. Add the Ballast widget, and a 90-second reset is one tap away — right when an urge shows up.",
        visualCaption: "This is what it looks like. Numbers only, if you prefer — it never names the habit.",
        previewAccessibilityLabel: "Preview of your lock screen widget",
        primaryCTA: "Show me how",
        guideSteps: [
            "Press and hold your lock screen",
            "Tap Customize, then the widget area",
            "Choose Ballast.",
        ],
        guideDismiss: "Done",
        secondaryCTA: "Maybe later",
        discreetFootnote: "Prefer quieter? The Reset button in Control Center does the same job and carries no name at all."
    )
}
