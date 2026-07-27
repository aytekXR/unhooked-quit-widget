import Foundation

/// ME-3 (S51, redesign §6.20 / copy doc §9) — the unlock moment's chrome strings.
///
/// The milestone TITLE and BODY are not here: they are catalog bytes from
/// `milestones.json`, rendered verbatim (`MilestoneRowModel.title`/`.body`), and the
/// catalog is founder-signed and CI-lexicon-gated. What this table carries is only the
/// frame around them — an eyebrow, two actions, and the discreet substitute line.
///
/// A STRUCT with STORED properties, never a computed-property enum — the R9
/// Mirror-vacuity rule: `MilestoneUnlockCopyTests`' lexicon walk scans exactly these
/// members and `Mirror` yields nothing over computed ones.
///
/// Every byte is DRAFT/founder-owned → `operator-expected.md` §0's copy pass, except
/// `doneLabel`, which is deliberately the SAME byte the app already uses for a quiet
/// dismissal (`DiscreetSettingsCopy.eraseCompletionDismissLabel`, `widgetMomentCopy`'s
/// `guideDismiss`) — one dismissal word across the app, not three.
struct MilestoneUnlockCopy: Sendable {
    /// The card's eyebrow — names the moment without inflating it. Never
    /// "Achievement"/"Unlocked!"; the brand's register is quiet pride, and a
    /// milestone is a marker, not a trophy.
    let eyebrow: String
    /// The quiet dismissal. Tapping it retires this rung's moment forever.
    let doneLabel: String
    /// The pass-through into Streak Detail's full milestone timeline (§6.20's
    /// "quiet 'See all'"). Carries no control-type noun — a settings-row label
    /// containing "button" failed Apple's `.trait` audit in S50.
    let seeAllLabel: String
    /// The DISCREET substitute for the catalog body (copy doc §9, verbatim). A
    /// discreet quit's card names no habit and renders no experiential claim — the
    /// time-only catalog title plus this line is the whole content. It is also why
    /// the not-medical-care disclaimer does not render on a discreet card: there is
    /// no medical-adjacent body to hedge.
    let discreetBody: String

    static let shipping = MilestoneUnlockCopy(
        eyebrow: "Milestone",
        doneLabel: "Done",
        seeAllLabel: "See all",
        discreetBody: "A marker worth noting. Your numbers tell the story."
    )
}
