import Foundation

/// E6.3 (R22.7/R22.8) — the discreet-settings screen's audited string table
/// (Session 22 step-0, PM+Brand+QA joint-signed; every row DRAFT/founder-owned →
/// operator-expected §3 EXCEPT the two brandkit-LITERAL picker names). A STRUCT with
/// STORED properties, NOT a computed-property enum — the R9 Mirror-vacuity rule: the
/// S1 lexicon walk (shame + habit-leak, non-vacuity floor) scans exactly these
/// members, and `Mirror` yields nothing over computed members.
struct DiscreetSettingsCopy: Sendable {
    /// Navigation title of the one settings screen (mvp feature 9's literal clause).
    let screenTitle: String
    /// Section header over the per-quit discreet toggles.
    let widgetsHeader: String
    /// Section footer — deliberately OBSERVABLE copy ("show numbers only" = exactly
    /// what the toggle does); no unverifiable privacy claim (the S19 "anonymous"
    /// strike precedent: promise nothing the payload audit can't prove).
    let widgetsFooter: String
    /// Section header over the app-icon picker.
    let iconHeader: String
    /// Icon picker row 1 — the primary icon. Brand constraint: never the brand name
    /// ("Ballast" would defeat the row's purpose), never a habit token.
    let iconRowDefault: String
    /// Icon picker row 2 — brandkit §4.3 LITERAL (Brand-locked; founder-confirm only).
    let iconRowCalendar: String
    /// Icon picker row 3 — brandkit §4.3 LITERAL (Brand-locked; founder-confirm only).
    let iconRowTimer: String
    /// Accessibility label of the RootPlaceholderView entry point (a `gearshape`
    /// glyph button — the label is what VoiceOver reads).
    let settingsEntryAccessibilityLabel: String
    /// E7.3 (R26.6/R26.9) — the win-back settings row (visible ONLY when the
    /// eligibility check passes; visibility is view-gated, never an optional
    /// String — the Mirror-walk rule). Habit-name-free by the shoulder-surface
    /// discipline; neutral register ("Reactivate"/"Come back" rejected —
    /// fact-wrong for a trial-lapse who may never have paid). DRAFT/§3.
    let winbackRowLabel: String

    static let shipping = DiscreetSettingsCopy(
        screenTitle: "Discreet Mode",
        widgetsHeader: "Widgets",
        widgetsFooter: "Widgets for this streak show numbers only.",
        iconHeader: "App Icon",
        iconRowDefault: "Default",
        iconRowCalendar: "Calendar style",
        iconRowTimer: "Timer style",
        settingsEntryAccessibilityLabel: "Settings",
        winbackRowLabel: "See your plan options"
    )
}
