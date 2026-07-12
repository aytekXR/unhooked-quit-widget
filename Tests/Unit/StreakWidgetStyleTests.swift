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

        // Non-vacuity floor: the table is a STRUCT of STORED strings (12 today after E6.3
        // lifted the two discreet-panic strings + the normal glyph into the table), never a
        // computed-property enum whose Mirror yields nothing — a collapse below 12 means
        // the walk (or the type's shape) silently broke and the scan is vacuous. RAISED
        // from 7 with E6.3's three new members (strengthening — never lowered).
        #expect(
            collected.count >= 12,
            "the Mirror walk collapsed (<12 strings) — a computed-property style would scan nothing and pass forever"
        )
        #expect(
            StreakWidgetStyle.shipping.widgetKind == "StreakWidget",
            "the registered widget kind is pinned — SkeletonWidget is retired with this table (R12)"
        )
    }

    // MARK: - G2 · the DISCREET-render corpus leaks no habit/tracker vocabulary (plan-named)

    /// The EXPANDED discreet lexicon (R22.2): habit nouns + tracker/recovery vocabulary +
    /// category synonyms. CRITICAL scoping: it applies ONLY to the discreet-render corpus
    /// below — NEVER to the gallery strings, where "Streak"/"streak"/"next milestone" live
    /// LEGITIMATELY (displayName, galleryDescription, milestoneLabel). A shoulder-surfer
    /// reading a discreet lock-screen widget — or its VoiceOver — must see no abstinence
    /// signal, so this corpus is strictly the strings a discreet render actually surfaces.
    private static let discreetLexicon: [String] = [
        // habit nouns (the §10 leak list)
        "vape", "vaping", "porn", "alcohol", "weed", "doomscroll",
        "smoke", "drink", "sober", "addiction", "relapse",
        // tracker / recovery vocabulary
        "panic", "urge", "quit", "habit", "streak", "milestone",
        // category synonyms
        "nicotine", "cigarette", "cig", "beer", "wine", "booze",
        "cannabis", "marijuana", "pot", "scrolling", "screentime",
        "nofap", "gambling", "bet",
    ]

    @Test func test_discreetWidgets_accessibilityLabels_containNoHabitTerms() {
        // The discreet-render corpus: every "…Discreet"-suffixed member (the strings a
        // discreet render actually shows) PLUS unavailableText (reachable in any render).
        // Collected by Mirror LABEL, so the scoping is explicit and the gallery strings are
        // structurally excluded from this stricter lexicon.
        var corpus: [String] = []
        var discreetSuffixedCount = 0
        for child in Mirror(reflecting: StreakWidgetStyle.shipping).children {
            guard let label = child.label, let value = child.value as? String else { continue }
            if label.hasSuffix("Discreet") {
                corpus.append(value)
                discreetSuffixedCount += 1
            } else if label == "unavailableText" {
                corpus.append(value)
            }
        }

        // Non-vacuity floor: the two discreet-suffixed members (panicGlyphDiscreet,
        // panicAccessibilityLabelDiscreet) must be present — a Mirror collapse or a rename
        // would empty this corpus and pass the scan vacuously (the reproduced R9 trap).
        #expect(
            discreetSuffixedCount >= 2,
            "the discreet-suffixed corpus collapsed (<2 members) — the scan would pass vacuously"
        )

        for value in corpus {
            let haystack = Self.folded(value)
            for token in Self.discreetLexicon {
                #expect(
                    !haystack.contains(token),
                    "a discreet-render string leaks the tracker/habit token '\(token)': \(value)"
                )
            }
        }
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

    // MARK: - W1 · the panic button swaps glyph AND a11y label with the bound quit's mode

    @Test func test_panicButton_discreetSelection_swapsGlyphAndLabel() {
        let base = WidgetQuitState(
            id: UUID(),
            streakStart: Date(timeIntervalSince1970: 1_783_425_600),
            timeZoneIdentifier: "America/New_York",
            weeklySpend: "26",
            currencyCode: "USD",
            bankedCleanSeconds: 0,
            momentumPercent: 50,
            milestoneHours: []
        )
        var discreetCard = base
        discreetCard.discreet = true
        let normalCard = base // discreet defaults nil ⇒ normal render (presence-only)

        let style = StreakWidgetStyle.shipping

        #expect(
            StreakWidgetDisplay.panicGlyph(for: discreetCard, style: style) == "arrow.counterclockwise"
                && StreakWidgetDisplay.panicAccessibilityLabel(for: discreetCard, style: style) == "Reset",
            "a discreet card selects the neutral reset pair (arrow.counterclockwise / \"Reset\") — no breath glyph, no descriptive panic label (R22.2)"
        )
        #expect(
            StreakWidgetDisplay.panicGlyph(for: normalCard, style: style) == "wind"
                && StreakWidgetDisplay.panicAccessibilityLabel(for: normalCard, style: style) == "Panic — opens a full-screen reset",
            "a normal card keeps the shipped panic pair (wind / the descriptive label)"
        )
        #expect(
            StreakWidgetDisplay.panicGlyph(for: nil, style: style) == "wind"
                && StreakWidgetDisplay.panicAccessibilityLabel(for: nil, style: style) == "Panic — opens a full-screen reset",
            "a nil quit (the .unavailable state) carries no discreet flag ⇒ the normal pair by construction"
        )
    }
}
