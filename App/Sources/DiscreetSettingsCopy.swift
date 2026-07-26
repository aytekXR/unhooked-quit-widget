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
    /// E9.1 (R27.10) — the safety-resources row (UNCONDITIONAL when the host
    /// wires it: resources are always one tap away, never eligibility- or
    /// entitlement-gated). Habit-name-free by the shoulder-surface discipline —
    /// the leak lexicon bans "Quitline"-class labels here. DRAFT/§3.
    let resourcesRowLabel: String
    /// E9.3 (R28.3 — the THIRD R22.7 amendment) — the haptics-only breath-pacer
    /// toggle's row label. NEVER framed as an accommodation (brandkit §8's
    /// first-class, eyes-free-for-anyone mandate); habit-name-free by the
    /// shoulder-surface discipline ("breath"/"taps" clear the leak lexicon).
    /// DRAFT/founder-owned → operator §3.
    let hapticPacerRowLabel: String
    /// E9.3 (R28.3) — the toggle's section footer: OBSERVABLE copy (the
    /// `widgetsFooter` rule — names exactly what the switch does) framing the
    /// mode UNIVERSALLY (screen-off / eyes-closed breathing, for anyone), never
    /// as an accessibility accommodation. DRAFT/founder-owned → operator §3.
    let hapticPacerFooter: String
    /// QW-2 (redesign copy doc §11) — the erase-everything settings row. Amber
    /// (caution) label, per the no-red rule; the destructive dialog it opens is
    /// the App Review / store-listing "one-tap erase" promise made real.
    let eraseRowLabel: String
    /// QW-2 — the erase dialog title (copy doc §11, verbatim).
    let eraseConfirmTitle: String
    /// QW-2 — the erase dialog body (copy doc §11, verbatim): the honest
    /// manifest — icon reset stated because a surviving disguise would break the
    /// erase promise; entitlement survival stated because losing paid access
    /// would be a false fear.
    let eraseConfirmBody: String
    /// QW-2 — the hold-to-confirm action label (copy doc §11, verbatim).
    let eraseConfirmActionLabel: String
    /// QW-2 — the quiet cancel (copy doc §11, verbatim). Cancel is always the
    /// easy path.
    let eraseCancelLabel: String
    /// QW-2 — the completion line (copy doc §11, verbatim), on the
    /// crest-anchored confirmation frame. Shown once, never again.
    let eraseCompletionBody: String
    /// QW-2 — the completion frame's quiet door (adopts the copy system's
    /// standing dismiss byte — §7 celebration / §9 milestone "Done").
    /// DRAFT/founder-owned → operator §3.
    let eraseCompletionDismissLabel: String
    /// QW-2 — the VoiceOver hint on the standard double-activation alternative
    /// to the 600ms hold (redesign §8: "an explicit hint"). Factual, no urgency.
    /// DRAFT/founder-owned → operator §3.
    let eraseAssistiveHint: String

    static let shipping = DiscreetSettingsCopy(
        screenTitle: "Discreet Mode",
        widgetsHeader: "Widgets",
        widgetsFooter: "Widgets for this streak show numbers only.",
        iconHeader: "App Icon",
        iconRowDefault: "Default",
        iconRowCalendar: "Calendar style",
        iconRowTimer: "Timer style",
        settingsEntryAccessibilityLabel: "Settings",
        winbackRowLabel: "See your plan options",
        resourcesRowLabel: "Support & resources",
        hapticPacerRowLabel: "Breathe with taps",
        hapticPacerFooter: "The breathing exercise guides you with gentle taps, so you can follow it with the screen off or your eyes closed.",
        eraseRowLabel: "Erase everything",
        eraseConfirmTitle: "Erase everything?",
        eraseConfirmBody: "This deletes every streak, note, answer, and setting, resets your app icon, and returns Ballast to a fresh install. There's no copy anywhere else — once it's gone, it's gone. If you have a subscription, it stays with your Apple Account.",
        eraseConfirmActionLabel: "Erase everything",
        eraseCancelLabel: "Keep my data",
        eraseCompletionBody: "Everything's gone. This app is now exactly as it was before you opened it.",
        eraseCompletionDismissLabel: "Done",
        eraseAssistiveHint: "Erases everything right away."
    )
}
