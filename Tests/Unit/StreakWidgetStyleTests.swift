import Foundation
import Testing
@testable import Unhooked

// E6.2 unit lane — the streak widget's HOME-side surfaces: the gallery/micro-copy table
// (StreakWidgetStyle) and the rectangular family's panic-button display math
// (StreakWidgetDisplay.panicIntent). Both ship at red (the copy table and the display
// math are final at red — the goldens render through the final views), so these are the
// permanent gates that keep them honest, green-from-birth like SlipLexiconTests.
//
// The dual-lexicon scan follows SlipLexiconTests' reflection-driven corpus mechanism:
// its private token lists are not importable, so the mechanism (folded matcher +
// non-vacuity floor) is replicated here over the streak table. The Mirror walk collects
// the STORED string properties (the reproduced trap: a computed-property style would
// yield nothing and pass vacuously forever).
//
// This lane CANNOT run locally (it @testable-imports the app module); its evidence is the
// parse-gate + the predicted manifest.

@Suite("E6.2 · streak widget style + display")
struct StreakWidgetStyleTests {

    // MARK: - The dual lexicon (the SHAME register + the habit-LEAK nouns)

    /// The shame register (brandkit §1.1/§1.2; the SlipLexiconTests foundation list).
    /// Bare "reset" stays OUT — it is the sanctioned discreet-reset verb the streak
    /// copy uses ("a quick reset is one tap away").
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
    /// Word-boundary tokens: substring matching would false-positive ("using" contains
    /// "sin", "secure" contains "cure").
    private static let shameWords: [String] = ["sin", "cure"]

    /// The habit-leak lexicon (§10: the widget gallery is readable by anyone holding the
    /// phone mid-add). Habit nouns; the PanicEntryPointTests precedent list.
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

    // MARK: - G1 · the gallery/micro-copy table is shame- AND leak-free (permanent gate)

    @Test func test_streakWidgetStyle_shipping_isShameAndLeakFree_withNonVacuityFloor() {
        var collected: [String] = []
        for child in Mirror(reflecting: StreakWidgetStyle.shipping).children {
            guard let value = child.value as? String else { continue }
            collected.append(value)

            // Every string faces the shame register — including the panic a11y label.
            #expect(
                Self.firstShameViolation(in: value) == nil,
                "a shipped streak-widget string carries the shame register '\(Self.firstShameViolation(in: value) ?? "?")': \(value)"
            )
            // Every string EXCEPT the shipped "Panic" a11y label faces the habit-leak
            // lexicon (the a11y label is exempt by shipped precedent — "Panic" is the
            // flagship verb, not a habit noun — but it is NOT exempt from the shame scan).
            if child.label != "panicAccessibilityLabel" {
                #expect(
                    Self.firstLeakViolation(in: value) == nil,
                    "a pre-add gallery string leaks a habit noun '\(Self.firstLeakViolation(in: value) ?? "?")': \(value)"
                )
            }
        }

        // Non-vacuity floor: the table is a STRUCT of STORED strings (9 today), never a
        // computed-property enum whose Mirror yields nothing — a collapse below 7 means
        // the walk (or the type's shape) silently broke and the scan is vacuous.
        #expect(
            collected.count >= 7,
            "the Mirror walk collapsed (<7 strings) — a computed-property style would scan nothing and pass forever"
        )
        #expect(
            StreakWidgetStyle.shipping.widgetKind == "StreakWidget",
            "the registered widget kind is pinned — SkeletonWidget is retired with this table (R12)"
        )
    }

    // MARK: - D1 · the rectangular panic button carries the configured quit id (plan-named)

    @Test func test_rectangularWidget_panicButton_invokesPanicIntentWithQuitID() {
        let id = UUID()
        let quit = WidgetQuitState(
            id: id,
            streakStart: Date(timeIntervalSince1970: 1_783_425_600),
            timeZoneIdentifier: "America/New_York",
            weeklySpend: "26",
            currencyCode: "USD",
            bankedCleanSeconds: 0,
            momentumPercent: 50,
            milestoneHours: []
        )

        #expect(
            StreakWidgetDisplay.panicIntent(for: quit).quit?.id == id,
            "the rectangular family's panic button carries the CONFIGURED quit's id into OpenPanicIntent (mvp feature 5: per-widget binding by UUID)"
        )
        #expect(
            StreakWidgetDisplay.panicIntent(for: nil).quit == nil,
            "a nil quit falls back to the intent's own picker path — no fabricated id"
        )
    }
}
