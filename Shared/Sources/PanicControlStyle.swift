/// Pure styling data for the two panic control kinds, in Shared/Sources so the E3.3 unit
/// lane can assert on it (the Widgets/Sources control wrappers that consume it link only
/// into the widget target and are invisible to the tests). `standard` is the flagship
/// "Panic" control; `discreet` is the hide-in-plain-sight "Reset" control — every string
/// it exposes must stay neutral (§10: the Settings widget gallery is readable by anyone
/// holding the phone).
enum PanicControlStyle {
    case standard, discreet

    /// Control label / gallery title.
    var title: String {
        // E3.3 red stub: BOTH variants return the standard title. The green commit
        // switches on `self` — .discreet returns the plan-locked "Reset".
        "Panic"
    }

    /// SF Symbol for the control glyph (docs-verified to exist on iOS 26).
    var symbolName: String {
        // red stub: both return the brand breath glyph. Green: .discreet returns the
        // neutral "arrow.counterclockwise".
        "wind"
    }

    /// Settings-gallery display name (mirrors `title`).
    var displayName: String { title }

    /// Settings-gallery description. The discreet variant's copy must leak none of the
    /// habit lexicon.
    var description: String {
        // red stub: both return the standard description. Green: .discreet returns the
        // neutral "Opens a quick reset."
        "Opens a full-screen reset, instantly."
    }

    /// The registered ControlWidget `kind` string — must differ per variant or the two
    /// controls collapse into one registration.
    var controlKind: String {
        // red stub: both return the standard kind (so the "separate kind" pin fails).
        // Green: .discreet returns "PanicControlDiscreet".
        "PanicControl"
    }
}
