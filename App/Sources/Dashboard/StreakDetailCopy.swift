import Foundation

/// P2 (redesign §6.17) — the Streak Detail screen's copy table (the
/// `DashboardCopy` shape: audited-or-DRAFT statics; views render these, never
/// literals). Every NEW string below is DRAFT / founder-owned
/// (operator-instructed, founder pass pending — operator-expected §3), drafted
/// verbatim from redesign/product-copy.md §6/§9 and lexicon-scanned by
/// `StreakDetailCopyTests` with the house shame + habit-leak lists.
///
/// The milestone FOOTER is deliberately NOT here: safety-adjacent framing must
/// be the SIGNED `notMedicalCareDisclaimer` from `safetyCopy.json` verbatim
/// (clinician + counsel gated) — the view reads it from that table, and this
/// file must never grow a parallel draft of it.
enum StreakDetailCopy {
    /// Discreet screen title — byte-identical to the slip table's discreet row
    /// label ("Tracked goal", Session-21 signed); pinned by the test so a §3
    /// edit to one can never silently diverge the other.
    static let screenTitleDiscreet = "Tracked goal"

    /// DRAFT (copy doc §9) — the milestone list's title.
    static let milestonesTitle = "Milestones"

    /// DRAFT (copy doc §9) — the locked-row template prefix: "Unlocks at" +
    /// a formatted duration (locale data, e.g. "2 weeks"). Time only — no
    /// preview of the body; anticipation without promise.
    static let milestoneLockedPrefix = "Unlocks at"

    /// DRAFT (copy doc §6, "82% momentum") — names the number once; the ring
    /// alone doesn't teach the concept.
    static let momentumLabel = "momentum"

    /// DRAFT (copy doc §6, with the S46 "steady" ruling) — the plain-language
    /// momentum explanation the app has never offered.
    static let momentumExplainer =
        "Momentum is your steady days over all your days. A slip barely moves it — only time does."

    /// DRAFT (copy doc §6.17) — the private notes list's header.
    static let notesHeader = "Only on this phone."

    /// DRAFT (copy doc §6) — the per-quit slip action, verb-first. The discreet
    /// twin is byte-identical to the panic slipped-exit's discreet label
    /// ("Log it" — one vocabulary across surfaces).
    static let logSlipLabel = "Log a slip"
    static let logSlipLabelDiscreet = "Log it"

    /// DRAFT (copy doc §6, the brandkit's own example) — quiet pride as a
    /// stat. Singular/plural is grammar over data, not new vocabulary; hidden
    /// until count ≥ 1 (the caller guards).
    static func avertedLine(count: Int) -> String {
        count == 1
            ? "1 urge surfed and counting."
            : "\(count) urges surfed and counting."
    }
}
