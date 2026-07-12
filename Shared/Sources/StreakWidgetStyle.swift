import Foundation

/// The streak widget's audited string table (Session 21 step-0, PM+Brand+QA
/// joint-signed; every string DRAFT/founder-owned — operator-expected §3). In
/// Shared/Sources so the unit lane can scan it; a STRUCT with STORED properties, NOT
/// a computed-property enum: the panel REPRODUCED that `Mirror` yields nothing over
/// computed members, so a PanicControlStyle-shaped type would pass the lexicon walk
/// vacuously (scanning nothing, green forever).
///
/// Two scans gate this table (StreakWidgetStyleTests): the 37-token shame lexicon
/// (user-facing copy rule) AND the habit-leak lexicon (§10: the widget gallery is
/// readable by anyone holding the phone mid-add — no habit noun anywhere; the
/// PanicEntryPointTests precedent), with a non-vacuity floor so an empty corpus can
/// never read as a pass.
struct StreakWidgetStyle: Sendable {
    /// The registered Widget `kind`. New in E6.2 — SkeletonWidget ("SkeletonWidget")
    /// is retired with it (step-0 ruling, operator-vetoable: testers re-add once).
    let widgetKind: String
    /// Widget-gallery display name.
    let displayName: String
    /// Widget-gallery description — visible pre-add to anyone holding the phone.
    let galleryDescription: String
    /// Micro-label over the ticking duration (brandkit `type/widgetLabel`; per-locale
    /// literal, NEVER `.uppercased()` — Turkish İ/ı casing).
    let durationLabel: String
    /// Micro-label beside the money figure.
    let savedLabel: String
    /// Micro-label over the systemMedium milestone progress bar. The bar itself is
    /// pure data (elapsed ÷ next rung) — milestone TITLES are copy and never reach
    /// the widget (§10: they stay out of the pre-unlock-readable feed entirely).
    let milestoneLabel: String
    /// The `.unavailable` state's one calm line (fresh install / post-erase: no data,
    /// no ticker, never a fabricated "Day 0", never an error).
    let unavailableText: String
    /// `placeholder(in:)` redacted-sample day text — a neutral static sample, never a
    /// live read (the gallery preview must not touch the feed).
    let placeholderDayText: String
    /// Accessibility label for the rectangular family's panic button (the shipped
    /// SkeletonWidget precedent, carried forward verbatim).
    let panicAccessibilityLabel: String

    /// The one shipping table. "Day N" itself renders from the entry's number under
    /// ADR-11 — it is data, not copy, and deliberately not a member here.
    static let shipping = StreakWidgetStyle(
        widgetKind: "StreakWidget",
        displayName: "Streak",
        galleryDescription: "Your streak, on your lock screen. A quick reset is one tap away.",
        durationLabel: "today",
        savedLabel: "saved",
        milestoneLabel: "next milestone",
        unavailableText: "Ready when you are.",
        placeholderDayText: "Day 7",
        panicAccessibilityLabel: "Panic — opens a full-screen reset"
    )
}
