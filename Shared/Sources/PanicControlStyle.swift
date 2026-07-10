/// Pure styling data for the two panic control kinds, in Shared/Sources so the E3.3 unit
/// lane can assert on it (the Widgets/Sources control wrappers that consume it link only
/// into the widget target and are invisible to the tests). `standard` is the flagship
/// "Panic" control; `discreet` is the hide-in-plain-sight "Reset" control — every string
/// it exposes must stay neutral (§10: the Settings widget gallery is readable by anyone
/// holding the phone).
enum PanicControlStyle {
    case standard, discreet

    /// Control label / gallery title. "Reset" is the plan-locked discreet title.
    var title: String {
        switch self {
        case .standard: "Panic"
        case .discreet: "Reset"
        }
    }

    /// SF Symbol for the control glyph (docs-verified to exist on iOS 26). The discreet
    /// glyph is neutral — never the brand breath glyph `wind` (category-adjacent), never
    /// an outing glyph like `eye.slash`.
    var symbolName: String {
        switch self {
        case .standard: "wind"
        case .discreet: "arrow.counterclockwise"
        }
    }

    /// Settings-gallery display name (mirrors `title`).
    var displayName: String { title }

    /// Settings-gallery description. The discreet variant's copy must leak none of the
    /// habit lexicon.
    var description: String {
        switch self {
        case .standard: "Opens a full-screen reset, instantly."
        case .discreet: "Opens a quick reset."
        }
    }

    /// The registered ControlWidget `kind` string — must differ per variant or the two
    /// controls collapse into one registration. "PanicControl" predates E3.3 and must
    /// never change (it names existing users' placed controls).
    var controlKind: String {
        switch self {
        case .standard: "PanicControl"
        case .discreet: "PanicControlDiscreet"
        }
    }
}
