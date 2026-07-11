import Foundation
import Testing
@testable import Unhooked

// E4.2 unit lane — the zero-shame copy gate (implementation-plan §E4.2: "every
// slip/relapse string passes the no-shame checklist; copy centralized in one audited
// strings table"). The audited table is the bundled slipCopy.json decoded as `SlipCopy`
// (test-suite §3.2: the SHIPPING file is the fixture) — E4.2 extends it with the
// `dashboard` section so the root dashboard surface's slip strings come from the same
// audited table instead of view-inline literals.
//
// The forbidden lexicon derives from the brandkit no-shame checklist
// (frontend-brandkit §1.1 anti-personality, §1.2 tone rules, §9.3 banned strings),
// MVP §3 excluded shame mechanics / §7 copy audit, and the slipCopy `_meta` monotonic
// note. It EXTENDS SlipCopyTests' E4.1 `shameLexicon` (which stays green alongside);
// this suite is the permanent CI gate the E4.2 acceptance names. `slip`/`slipped` is
// the SANCTIONED clinical noun (brandkit §1.2) and is never banned; the scan runs over
// DECODED values only — the JSON `_meta` notes deliberately QUOTE banned phrases in
// order to forbid them, and `Codable` omits them (the SlipCopyTests precedent; same
// reason panicScript's undecoded `note`/`analytics` fields stay out of scope).
//
// RED: `SlipCopy.dashboard` exists as a decode-tolerant optional (the retryNote
// precedent) but slipCopy.json does not carry the section yet and RootPlaceholderView
// still renders inline literals — the two `#require(copy.dashboard)` calls below are
// the DESIGNED failures (exactly 2; every other test in this suite and the repo stays
// green). GREEN adds the section to slipCopy.json byte-identical to the rendered
// strings (no snapshot golden may change) and points RootPlaceholderView at the table.
// Red evidence for this file = the CI run on the red commit.

@Suite("E4.2 · zero-shame copy gate")
struct SlipLexiconTests {

    // MARK: - The forbidden lexicon (permanent gate; the list only ever GROWS)

    /// Substring tokens, matched case/diacritic-insensitively over whitespace-collapsed
    /// strings. Bare words stay out wherever sanctioned copy collides: "nothing's lost"
    /// ships (so loss framing is phrase-anchored), bare "reset" is the discreet control,
    /// bare "clean"/"over" ship in "clean days over total days", bare "sober" is an ASO
    /// keyword (brandkit §9.3). Inflection catching is deliberate: "shame" catches
    /// "ashamed", "guilt" catches "guilty", "weak" catches "weakness", "recover"
    /// catches "recovery", "disappoint" catches "disappointed".
    private static let forbiddenSubstrings: [String] = [
        // Verdict/failure language (the impl-plan E4.2 seeds "failed" and "ruined").
        "failed", "failure", "failing", "blew it", "gave in",
        // Loss/ruin framing (slipCopy _meta: progress is preserved, never lost).
        "ruined", "wasted", "thrown away", "you lost", "lost your streak",
        // Reset framing ("back to day" subsumes the plan's "back to day 1").
        "back to day", "back to zero", "back to square one", "day zero",
        "start over", "from scratch", "reset to zero",
        // Broken-streak verdicts (brandkit §1.1: no broken-chain metaphors).
        "broke", "broken", "streak is over", "streak is gone", "streak is lost",
        // Shame/moralizing register (MVP §3; brandkit §1.2 "coach, never judge").
        "shame", "guilt", "weak", "willpower", "disappoint", "let yourself down",
        // Recovery-culture / religious framing (brandkit §1.1 anti-AA, §1.2).
        "relapse", "temptation", "purity", "clean slate", "sober up",
        // Medical claims (brandkit §9.3; complements SlipCopyTests.medicalClaims).
        "recover", "treatment",
    ]

    /// Word-boundary tokens: substring matching would false-positive on innocent words
    /// ("single"/"using" contain "sin"; "secure"/"obscure" contain "cure").
    private static let forbiddenWords: [String] = ["sin", "cure"]

    /// The frozen E4.2 floor — NEVER edit this set; grow `forbiddenSubstrings` /
    /// `forbiddenWords` instead (the floor deliberately LAGS the live lists once they
    /// grow). `test_forbiddenLexicon_onlyGrows_fromFoundationFloor` pins the live
    /// lists as a superset, so removing a token is a deliberate two-place edit a
    /// review can't miss, never a drive-by.
    private static let foundationLexicon: Set<String> = [
        "failed", "failure", "failing", "blew it", "gave in",
        "ruined", "wasted", "thrown away", "you lost", "lost your streak",
        "back to day", "back to zero", "back to square one", "day zero",
        "start over", "from scratch", "reset to zero",
        "broke", "broken", "streak is over", "streak is gone", "streak is lost",
        "shame", "guilt", "weak", "willpower", "disappoint", "let yourself down",
        "relapse", "temptation", "purity", "clean slate", "sober up",
        "recover", "treatment",
        "sin", "cure",
    ]

    // MARK: - The matcher (behavior-pinned below so it cannot silently rot)

    /// Casefold + diacritic-fold + collapse all whitespace runs to one space — the
    /// normalization both sides of every match go through (diacritic folding is the
    /// TR-fast-follow posture, brandkit §1.2).
    private static func folded(_ string: String) -> String {
        string.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            .split(whereSeparator: { $0.isWhitespace || $0.isNewline })
            .joined(separator: " ")
    }

    /// The first banned token the string carries, or nil when it is clean.
    private static func firstViolation(in string: String) -> String? {
        let haystack = folded(string)
        for banned in forbiddenSubstrings where haystack.contains(folded(banned)) {
            return banned
        }
        for banned in forbiddenWords
        where haystack.range(of: "\\b\(banned)\\b", options: [.regularExpression, .caseInsensitive]) != nil {
            return banned
        }
        return nil
    }

    // MARK: - The corpus (reflection-driven, so a new field can never dodge the gate)

    /// Every `String` reachable from the decoded value, by reflection — a field added
    /// to `SlipCopy` (or any nested section) joins the scan automatically instead of
    /// waiting for a hand-rolled collector to learn about it (the resume prompt's
    /// table-completeness requirement). Optionals unwrap through their sole child;
    /// arrays contribute their elements.
    private static func reflectedStrings(of subject: Any) -> [String] {
        if let string = subject as? String { return [string] }
        return Mirror(reflecting: subject).children.flatMap { reflectedStrings(of: $0.value) }
    }

    // MARK: - The named E4.2 gate

    @Test func test_slipStrings_containNoForbiddenLexicon() throws {
        let copy = try #require(
            SlipCopy.loadShipping(),
            "the audited table is the shipping slipCopy.json — it must be bundled and decode as-is (§3.2)"
        )
        // DESIGNED RED: copy is only "centralized in one audited strings table"
        // (impl-plan §E4.2) once the table carries the dashboard surface's strings —
        // inline in RootPlaceholderView until green.
        let dashboard = try #require(
            copy.dashboard,
            "the audited table must carry the dashboard slip strings — they are view-inline literals at red"
        )
        let script = try #require(
            PanicScript.loadShipping(),
            "the slipped-exit labels are slip strings; the shipping panicScript.json carries them"
        )
        let slippedExit = try #require(
            script.exit("slipped"),
            "the panic flow's slipped exit is the doorway into the slip flow"
        )

        // The full slip-rendered corpus: the shipping table (dashboard included via
        // reflection), the §9 degraded fallback (it renders too), and the slipped exit.
        let corpus = Self.reflectedStrings(of: copy)
            + Self.reflectedStrings(of: SlipCopy.degraded)
            + Self.reflectedStrings(of: slippedExit)

        // Non-vacuity floor: the shipping table reflects 20+ strings (23 with the
        // dashboard section today); 20 keeps the scan honest without pinning shape.
        #expect(
            Self.reflectedStrings(of: copy).count >= 20,
            "the reflected corpus collapsed — the scan would be vacuous"
        )
        #expect(
            !dashboard.pendingBanner.isEmpty && !dashboard.undoLabel.isEmpty
                && !dashboard.discreetRowLabel.isEmpty,
            "the dashboard section must carry real strings, never blanks"
        )

        for string in corpus {
            let violation = Self.firstViolation(in: string)
            #expect(
                violation == nil,
                "forbidden lexicon '\(violation ?? "?")' must never appear in a slip string — a slip is data, not a verdict (brandkit §1.2, MVP §7): \(string)"
            )
        }
    }

    // MARK: - The E5.1 age-gate gate (Session 16 — QA change #4: the age-gate strings
    // are not slip strings, so without this scan the no-shame gate would not cover
    // them; the joint PM+Brand+QA sign-off is CI-pinned here)

    @Test func test_ageGateStrings_containNoForbiddenLexicon() throws {
        let copy = try #require(
            AgeGateCopy.loadShipping(),
            "the audited table is the shipping ageGateCopy.json — it must be bundled and decode as-is (§3.2)"
        )
        // Both gate screens' shipping copy AND the degraded fallback (it renders
        // too), by the same reflection walk — a new field can never dodge the scan.
        let corpus = Self.reflectedStrings(of: copy) + Self.reflectedStrings(of: AgeGateCopy.degraded)

        // Non-vacuity floor: 8 shipping strings today (5 gate + 3 blocked).
        #expect(
            Self.reflectedStrings(of: copy).count >= 8,
            "the reflected age-gate corpus collapsed — the scan would be vacuous"
        )

        for string in corpus {
            let violation = Self.firstViolation(in: string)
            #expect(
                violation == nil,
                "forbidden lexicon '\(violation ?? "?")' must never appear on the age gate — the blocked screen is a calm resource surface, not a verdict (brandkit §1.2, agent-workflows §2.3 safety-content gate): \(string)"
            )
        }
    }

    // MARK: - The E5.2 quiz gate (Session 17 — the quiz config IS its audited copy
    // table, ADR-9; every string DRAFT/founder-owned; the reflection walk covers the
    // shipping table AND the degraded fallback so a new config field can never dodge
    // the scan. `_meta` deliberately decodes only `version`, keeping review notes out
    // of the corpus — the SlipCopy precedent.)

    @Test func test_quizConfigStrings_containNoForbiddenLexicon() throws {
        let config = try #require(
            QuizConfig.loadShipping(),
            "the audited quiz table is the shipping quizConfig.json — it must be bundled and decode as-is (§3.2)"
        )
        let corpus = Self.reflectedStrings(of: config) + Self.reflectedStrings(of: QuizConfig.degraded)

        // Non-vacuity floor: the 13-slot draft reflects 12 titles + ~76 choice
        // strings + helpers + echoes + controls — far above 40; a collapse to fewer
        // means the walk (or the decode) silently broke.
        #expect(
            Self.reflectedStrings(of: config).count >= 40,
            "the reflected quiz corpus collapsed — the scan would be vacuous"
        )

        for string in corpus {
            let violation = Self.firstViolation(in: string)
            #expect(
                violation == nil,
                "forbidden lexicon '\(violation ?? "?")' must never appear in the quiz — a quiz prompt is a calm question, never a verdict (brandkit §1.2): \(string)"
            )
        }
    }

    // MARK: - Table completeness (the audit-found inline strings, byte-exact)

    @Test func test_slipTable_carriesDashboardStrings_byteExactWithRenderedCopy() throws {
        let copy = try #require(
            SlipCopy.loadShipping(),
            "the shipping table must be bundled and decode as-is (§3.2)"
        )
        // DESIGNED RED: same completeness gate as the named test, pinned byte-exact.
        let dashboard = try #require(
            copy.dashboard,
            "the audited table must carry the dashboard slip strings — they are view-inline literals at red"
        )

        // Byte-exact with what the root surface has always rendered: centralization
        // moves the SOURCE of a string, never its bytes (no golden may change; the
        // E4.1 goldens pixel-pin the flow's strings and WalkingSkeleton pins the root).
        #expect(dashboard.pendingBanner == "Slip logged. Undo?")
        #expect(dashboard.undoLabel == "Undo")
        #expect(dashboard.discreetRowLabel == "Tracked goal")

        // The discreet row label carries zero habit context (brandkit §1.2; the
        // PanicControlStyle leak-scan precedent, one surface later).
        let leakLexicon = ["panic", "urge", "quit", "habit", "vape", "smoke", "drink"]
        let rowLabel = dashboard.discreetRowLabel.lowercased()
        for term in leakLexicon {
            #expect(
                !rowLabel.contains(term),
                "the discreet row must not leak '\(term)' — a family member may read this screen"
            )
        }

        // Honest-degrade totality: the fallback table keeps the dashboard surface
        // functional (plainest labels, never blank) when the shipping section is absent.
        let degraded = try #require(
            SlipCopy.degraded.dashboard,
            "the §9 degrade path must stay total for the dashboard surface"
        )
        #expect(!degraded.pendingBanner.isEmpty)
        #expect(!degraded.undoLabel.isEmpty)
        #expect(!degraded.discreetRowLabel.isEmpty)
    }

    // MARK: - The gate gates itself

    @Test func test_forbiddenLexicon_onlyGrows_fromFoundationFloor() {
        let live = Set(Self.forbiddenSubstrings).union(Self.forbiddenWords)
        #expect(
            live.isSuperset(of: Self.foundationLexicon),
            "the forbidden lexicon only ever GROWS — a removed token is a deliberate two-place edit, never a drive-by"
        )

        // The plan row's seed tokens, verbatim (impl-plan §E4.2): "failed", "ruined",
        // "back to day 1" — the last via the stricter "back to day".
        #expect(Self.firstViolation(in: "You failed.") == "failed")
        #expect(Self.firstViolation(in: "You ruined your streak.") == "ruined")
        #expect(Self.firstViolation(in: "Back to day 1.") == "back to day")

        // Matcher behavior pins: inflections and case/whitespace variance are caught…
        #expect(Self.firstViolation(in: "Ashamed of a RELAPSE?") != nil)
        #expect(Self.firstViolation(in: "your streak\n   is  broken") != nil)
        // …while sanctioned shipping copy never trips it (the word-boundary tokens
        // are exactly why "single" and "secure" stay clean).
        #expect(Self.firstViolation(in: "Log a slip?") == nil)
        #expect(Self.firstViolation(in: "That didn't save just yet — nothing's lost.") == nil)
        #expect(Self.firstViolation(in: "Momentum is clean days over total days — a single day barely moves it.") == nil)
        #expect(Self.firstViolation(in: "your data stays secure") == nil)
        #expect(Self.firstViolation(in: "It is a sin.") == "sin")
        #expect(Self.firstViolation(in: "we cure addiction") == "cure")
    }
}
