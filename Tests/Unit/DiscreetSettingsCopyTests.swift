import Foundation
import Testing
@testable import Unhooked

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

        // Non-vacuity floor: DiscreetSettingsCopy is a STRUCT of 8 STORED strings, never a
        // computed-property enum whose Mirror yields nothing — a collapse below 8 means the
        // walk (or the type's shape) silently broke and the scan is vacuous.
        #expect(
            collected.count >= 8,
            "the Mirror walk collapsed (<8 strings) — a computed-property style would scan nothing and pass forever"
        )
    }
}
