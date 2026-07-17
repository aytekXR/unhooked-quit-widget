import Foundation

/// UIR-2 (Session 34) — the dashboard card's copy table.
///
/// UIR moves pixels, never words (roadmap §2.5): every string a user reads on the
/// new `StreakDashboardCard` is either **already audited** or **pure ADR-11 data**
/// ("Day N", a currency figure, "N%"). The two audited labels below are byte-identical
/// to `StreakWidgetStyle.shipping` (Session-21 PM+Brand+QA joint-signed) —
/// `DashboardCopyTests` pins that byte-identity so a §3 edit to one can never silently
/// diverge the other. They are re-declared here rather than imported from the
/// widget-facing `StreakWidgetStyle` so the in-app dashboard and the widget surface
/// stay decoupled types (the pin keeps them honest).
///
/// The remaining slots are **§3-BLOCKED**: brandkit specifies a concept but no audited
/// string exists yet (the frozen tooltip, the empty-state heading/CTA, the reduce-mode
/// adherence framing, and the card's composed VoiceOver sentence). Each ships as `""`
/// and the view guards every one with a non-empty check, so **no empty `Text` ever
/// renders**. They are filled by the operator's founder copy pass (operator-expected
/// §3), and `DashboardCopyTests` fails the unit lane the instant any of them gains a
/// value without that sign-off — the same discipline the onboarding copy tables carry.
enum DashboardCopy {
    /// AUDITED — Session-21 PM+Brand+QA joint-signed. Byte-identical to
    /// `StreakWidgetStyle.shipping.savedLabel` (`Shared/Sources/StreakWidgetStyle.swift`).
    static let savedLabel = "saved"

    /// AUDITED — Session-21 PM+Brand+QA joint-signed. Byte-identical to
    /// `StreakWidgetStyle.shipping.milestoneLabel` (`Shared/Sources/StreakWidgetStyle.swift`).
    static let milestoneLabel = "next milestone"

    /// §3-BLOCKED. Concept string in brandkit §6#9: "streak paused — clock issue,
    /// it'll self-heal". Not in any audited `.swift`/`.json`. The card renders it only
    /// when non-empty; until the founder pass signs it, a frozen streak reads its
    /// (correct, frozen) numbers with a neutral ring and NO tooltip.
    static let frozenTooltip = ""

    /// §3-BLOCKED. Concept string in brandkit §6#15: "Start your first quit". The
    /// in-app dashboard never reaches an empty state in production (a zero-quit install
    /// routes to the quiz, not here), so this slot is reserved, not on any live path.
    static let emptyStateHeading = ""

    /// §3-BLOCKED. No exact string is defined anywhere. Reserved for the same empty-state
    /// pass as `emptyStateHeading`.
    static let emptyStateCTA = ""

    /// §3-BLOCKED. brandkit §6#9 asks for "adherence framing" on reduce-mode goals but
    /// defines no exact words. Until the founder pass, a reduce goal renders the same
    /// card as a quit goal (the widget precedent — no special reduce copy ships today).
    static let reduceModeFraming = ""

    /// §3-BLOCKED. The card's single-element VoiceOver sentence (brandkit §8: "34 days,
    /// 412 dollars saved, momentum 82 percent"). The framing words "days" and "momentum"
    /// are absent from every audited table, so this returns `""` and the card instead
    /// uses `.accessibilityElement(children: .contain)` — each `Text` carries its own
    /// natural VoiceOver description (all audited or pure data). Once the founder pass
    /// signs the template, the card upgrades to `.ignore` + this composed label.
    static func composedLabel(dayNumber: Int, moneyText: String?, momentumPercent: Int) -> String { "" }
}
