import Foundation
import Testing
@testable import Ballast

// E6.3 unit lane — S1: the discreet-settings string table (DiscreetSettingsCopy) faces
// the STANDARD dual lexicon (the shame register + the habit-LEAK nouns), mirroring
// StreakWidgetStyleTests' reflection-driven scan. DiscreetSettingsCopy is FINAL at red
// (the audited table ships whole), so S1 is BORN-GREEN — a permanent gate, green from
// birth like SlipLexiconTests / G1.
//
// LEXICON CHOICE: this is the STANDARD leak list (the PanicEntryPointTests habit nouns,
// as used in StreakWidgetStyleTests' G1) — NOT G2's EXPANDED discreet-render lexicon.
// "streak" appears LEGITIMATELY in widgetsFooter ("Widgets for this streak show numbers
// only."), so the expanded lexicon (which bans "streak"/"milestone") is deliberately the
// wrong tool here; this table is settings copy, not a discreet render.
//
// The Mirror walk collects the STORED string properties (the reproduced R9 trap: a
// computed-property style would yield nothing and pass vacuously). This lane CANNOT run
// locally (@testable app import); its evidence is the parse-gate + the predicted manifest.

@Suite("E6.3 · discreet settings copy")
struct DiscreetSettingsCopyTests {

    /// The shame register — StreakWidgetStyleTests' list, verbatim (the SlipLexiconTests
    /// foundation; the private list is not importable, so the mechanism is replicated).
    private static let shameSubstrings: [String] = [
        "failed", "failure", "failing", "blew it", "gave in",
        "ruined", "wasted", "thrown away", "you lost", "lost your streak",
        "back to day", "back to zero", "back to square one", "day zero",
        "start over", "from scratch", "reset to zero",
        "broke", "broken", "streak is over", "streak is gone", "streak is lost",
        "shame", "guilt", "weak", "willpower", "disappoint", "let yourself down",
        "relapse", "temptation", "purity", "clean slate", "sober up",
        "recover", "treatment",
    ]
    /// Word-boundary tokens: substring matching would false-positive ("using" ⊃ "sin",
    /// "secure" ⊃ "cure").
    private static let shameWords: [String] = ["sin", "cure"]

    /// The STANDARD habit-leak lexicon (§10 — the settings screen names the disguise the
    /// user chose; a habit noun here would defeat it). The StreakWidgetStyleTests list,
    /// verbatim — deliberately WITHOUT "streak" (see the file header).
    private static let leakSubstrings: [String] = [
        "vape", "vaping", "porn", "alcohol", "weed", "doomscroll",
        "smoke", "drink", "sober", "quit", "addiction", "relapse", "habit",
    ]

    /// Casefold + diacritic-fold + collapse whitespace — the SlipLexiconTests matcher.
    private static func folded(_ string: String) -> String {
        string.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            .split(whereSeparator: { $0.isWhitespace || $0.isNewline })
            .joined(separator: " ")
    }

    private static func firstShameViolation(in string: String) -> String? {
        let haystack = folded(string)
        for banned in shameSubstrings where haystack.contains(folded(banned)) { return banned }
        for banned in shameWords
        where haystack.range(of: "\\b\(banned)\\b", options: [.regularExpression, .caseInsensitive]) != nil {
            return banned
        }
        return nil
    }

    private static func firstLeakViolation(in string: String) -> String? {
        let haystack = folded(string)
        for banned in leakSubstrings where haystack.contains(folded(banned)) { return banned }
        return nil
    }

    // MARK: - S1 · the settings copy table is shame- AND leak-free (permanent gate)

    @Test func test_discreetSettingsCopy_shipping_isShameAndLeakFree_withNonVacuityFloor() {
        var collected: [String] = []
        for child in Mirror(reflecting: DiscreetSettingsCopy.shipping).children {
            guard let value = child.value as? String else { continue }
            collected.append(value)

            #expect(
                Self.firstShameViolation(in: value) == nil,
                "a shipped discreet-settings string carries the shame register '\(Self.firstShameViolation(in: value) ?? "?")': \(value)"
            )
            #expect(
                Self.firstLeakViolation(in: value) == nil,
                "a discreet-settings string leaks a habit noun '\(Self.firstLeakViolation(in: value) ?? "?")': \(value)"
            )
        }

        // Non-vacuity floor: DiscreetSettingsCopy is a STRUCT of STORED strings, never a
        // computed-property enum whose Mirror yields nothing — a collapse means the walk
        // (or the type's shape) silently broke and the scan is vacuous.
        //
        // S50 (S49 audit §3.3) — this floor read `>= 12` while the struct had grown to 20
        // (QW-2 added 8 erase strings), so the collapse detector had gone blind to any of
        // those 8. ME-7 then added 4 more (the section headers + the panic-access row
        // label), so the true count is 24:
        //     12 original + 8 QW-2 erase + 4 ME-7 = 24
        // (the `widgetsHeader` → `discreetModeSectionHeader` rename is net zero).
        // Verify with: `grep -c "^    let " App/Sources/DiscreetSettingsCopy.swift` == 24.
        #expect(
            collected.count >= 24,
            "the Mirror walk collapsed (<24 strings) — a computed-property style would scan nothing and pass forever"
        )
    }

    /// S50 — the trait-duplication guard, and it exists to make a specific future mistake
    /// legible instead of mysterious.
    ///
    /// Apple's `.trait` accessibility audit fails an element whose LABEL restates a trait
    /// the element already has: a `Button` labelled "…button" reports
    /// **"Label duplicates traits"**. Every row on the rebuilt settings screen is a
    /// `Button`, so no row label may contain a control-type noun.
    ///
    /// This fired for real on run `30220337353`: copy doc §11 drafts the panic-access row
    /// as "Add the lock-screen **button**" — meaning the WIDGET's panic button, a
    /// different object — and the audit failed the whole settings leg. The shipped byte is
    /// "Add the lock-screen **widget**" instead (see `DiscreetSettingsCopy`), and the
    /// deviation is flagged to the operator in `operator-expected.md` §0.
    ///
    /// The founder pass may well try to restore the doc's wording. When it does, this test
    /// says why it cannot in one line, on the unit lane — rather than the UI-smoke lane
    /// failing with a bare "Label duplicates traits" 20 minutes into a billed macOS run.
    /// If the founder wants those exact bytes anyway, the fix is a design change (drop the
    /// glyph and make the row a non-Button disclosure, or re-word), never an
    /// `.accessibilityLabel` override — that would break WCAG 2.5.3 (Label in Name) for
    /// Voice Control users to satisfy a machine check.
    @Test func test_settingsRowLabels_doNotRestateAControlTrait() {
        /// The control-type nouns Apple's `.trait` audit treats as trait duplication.
        let traitNouns = ["button", "image", "picture", "graphic", "icon", "switch", "toggle"]
        /// Only the strings that render AS a Button's label on the settings screen. Section
        /// headers, captions and the erase DIALOG's own strings are not row labels.
        let rowLabels: [(name: String, value: String)] = [
            ("widgetAdoptionRowLabel", DiscreetSettingsCopy.shipping.widgetAdoptionRowLabel),
            ("resourcesRowLabel", DiscreetSettingsCopy.shipping.resourcesRowLabel),
            ("winbackRowLabel", DiscreetSettingsCopy.shipping.winbackRowLabel),
            ("eraseRowLabel", DiscreetSettingsCopy.shipping.eraseRowLabel),
            ("iconRowDefault", DiscreetSettingsCopy.shipping.iconRowDefault),
            ("iconRowCalendar", DiscreetSettingsCopy.shipping.iconRowCalendar),
            ("iconRowTimer", DiscreetSettingsCopy.shipping.iconRowTimer),
        ]
        for row in rowLabels {
            let haystack = Self.folded(row.value)
            for noun in traitNouns {
                #expect(
                    !haystack.contains(noun),
                    """
                    `\(row.name)` = "\(row.value)" contains the control-type noun \
                    '\(noun)'. Every settings row renders as a Button, so Apple's .trait \
                    audit will fail the settings leg with "Label duplicates traits" \
                    (run 30220337353 — this is not hypothetical). Re-word the label; do \
                    NOT paper over it with .accessibilityLabel, which breaks WCAG 2.5.3.
                    """
                )
            }
        }
    }
}
