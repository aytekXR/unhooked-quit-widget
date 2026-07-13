import Foundation
import Testing
@testable import Unhooked

// E9.3 (R28.9) — the panic-script copy gate, BORN-GREEN permanent CI (the R27.13
// shape: scratch-verified over the exact shipping bytes on the free box before it
// landed — scratchpad/panic_lexicon_scratch.py, 39-string corpus, zero violations).
// It closes a real pre-existing hole: panicScript's STEP strings shipped under NO
// shame/leak gate (SlipLexiconTests scans slipCopy.json; SlipCopyTests' E4.1 scan
// covers only the slipped-exit label out of this file) — and it guards the NEW
// R28.4 `instructionNonVisual` string from the commit it lands in.
//
// Lexicons are the house STANDARD lists verbatim (SlipLexiconTests substrings +
// words; the DiscreetSettingsCopyTests/StreakWidgetStyleTests habit-leak list) —
// the lists only ever GROW. The scan runs over DECODED values only: the JSON
// `_meta` audit note deliberately QUOTES what it forbids and `Codable` omits it
// (the SlipCopyTests precedent). `PanicStep` is an enum (no Mirror children), so
// step kinds never join the corpus; every decoded String field does —
// reflection-driven, so a field added to `PanicScript` can never dodge the gate.

@Suite("E9.3 · panic-script copy gate")
struct PanicScriptLexiconTests {

    // MARK: - The forbidden lexicons (permanent; grow-only)

    /// The house shame lexicon — SlipLexiconTests' substring list, verbatim.
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

    /// Word-boundary tokens: substring matching would false-positive ("using" ⊃
    /// "sin", "secure" ⊃ "cure").
    private static let shameWords: [String] = ["sin", "cure"]

    /// The STANDARD habit-leak lexicon (the StreakWidgetStyleTests list, verbatim) —
    /// scanned over the DISCREET-rendered fields only: a discreet surface naming a
    /// habit defeats the disguise the user chose (§10).
    private static let leakSubstrings: [String] = [
        "vape", "vaping", "porn", "alcohol", "weed", "doomscroll",
        "smoke", "drink", "sober", "quit", "addiction", "relapse", "habit",
    ]

    // MARK: - The matcher (behavior-pinned below so it cannot silently rot)

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

    // MARK: - The corpus (reflection-driven — a new field joins automatically)

    /// Every `String` reachable from the decoded script, by reflection (the
    /// SlipLexiconTests collector verbatim): optionals unwrap through their sole
    /// child, arrays contribute their elements, enums contribute nothing.
    private static func reflectedStrings(of subject: Any) -> [String] {
        if let string = subject as? String { return [string] }
        return Mirror(reflecting: subject).children.flatMap { reflectedStrings(of: $0.value) }
    }

    private func shippingScript() throws -> PanicScript {
        try #require(
            PanicScript.loadShipping(),
            "the shipping panicScript.json must be bundled and decode AS-IS (§3.2)"
        )
    }

    // MARK: - S1 · every authored panic string is shame-free (permanent gate)

    @Test func test_panicScriptStrings_containNoShameLexicon() throws {
        let script = try shippingScript()
        let corpus = Self.reflectedStrings(of: script)

        // Non-vacuity floor: the shipping walk yields 35 decoded strings today
        // (2 entry titles + 17 step fields incl. the R28.4 instructionNonVisual +
        // 8 redirect-option ids/labels + 8 exit fields). The floor deliberately
        // LAGS the live count — grow it when the script grows, never shrink it.
        #expect(
            corpus.count >= 30,
            "the reflection walk went vacuous — \(corpus.count) strings reached; the Mirror corpus must cover the whole authored table"
        )

        for value in corpus {
            #expect(
                Self.firstShameViolation(in: value) == nil,
                "a panic-script string carries shame token '\(Self.firstShameViolation(in: value) ?? "?")': \(value)"
            )
        }
    }

    // MARK: - S2 · discreet-rendered fields are habit-leak-free (§10)

    @Test func test_panicScriptDiscreetStrings_containNoHabitLeak() throws {
        let script = try shippingScript()
        // Hand-enumerated: exactly the fields a DISCREET surface renders (the
        // entry title override + both exit-label overrides). The bloom-mode
        // strings render only after the user chose a non-discreet quit.
        let discreetRendered = [script.entryTitleDiscreet] + script.exits.map(\.labelDiscreet)

        #expect(discreetRendered.count == 3, "entry override + one override per exit")
        for value in discreetRendered {
            #expect(
                Self.firstLeakViolation(in: value) == nil,
                "a discreet-rendered panic string leaks habit token '\(Self.firstLeakViolation(in: value) ?? "?")': \(value)"
            )
        }
    }

    // MARK: - S3 · matcher behavior pins (the gate cannot silently rot)

    @Test func test_lexiconMatcher_firesOnViolations_passesSanctionedCopy() {
        #expect(Self.firstShameViolation(in: "You failed and broke your streak") == "failed")
        #expect(Self.firstShameViolation(in: "Ashamed of a wéak moment") == "shame", "inflections + diacritics fold into the match")
        #expect(
            Self.firstShameViolation(in: "nothing's lost — using data from clean days over total days") == nil,
            "sanctioned copy passes — loss framing is phrase-anchored, 'using' never trips the 'sin' word pin"
        )
        #expect(Self.firstLeakViolation(in: "Vaping quitline") == "vaping")
        #expect(Self.firstLeakViolation(in: "Take a moment.") == nil)
    }
}
