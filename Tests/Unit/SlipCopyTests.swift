import Foundation
import Testing
@testable import Unhooked

// E4.1 unit lane — the bundled slip-flow copy audit. Mirrors PanicFlowTests'
// `test_panicScript_decodesShippingFile_pacerAndExitsPinned`: the SHIPPING content
// file is the fixture (test-suite §3.2 — static-content fixtures are the shipping
// files, never copies), loaded from the app bundle via `SlipCopy.loadShipping()`
// (default `bundle: .main`; the UnhookedTests host IS the app bundle).
//
// The banned-lexicon + token-integrity audit is the test-suite §1.1 tests 12–13
// technique, applied the session slipCopy.json becomes a CONSUMED, bundled file
// (REVIEW.md: "their audit tests … arrive with their consuming epics").
//
// RED: slipCopy.json is present in App/Resources/Content but deliberately UNBUNDLED
// (project.yml lists panicScript.json only; REVIEW.md: "the other four files stay
// inert and unbundled"), so `SlipCopy.loadShipping()` returns nil and each test's
// `#require` produces its DESIGNED failure — never a crash, never a compile error.
// GREEN bundles the file (adds it to project.yml) with the one agent-drafted
// `confirm.retryNote` addition flagged for operator tone review (decision record §UI).
// Red evidence for this file = the CI run on the red commit.

@Suite("E4.1 · slip copy audit")
struct SlipCopyTests {

    // A slip is DATA, not a verdict — zero shame lexicon, zero medical claims (brand
    // kit §1.2). Case-insensitive substring match over the DECODED strings ONLY: the
    // JSON's `_meta` audit note deliberately QUOTES banned phrases (e.g. "reset to
    // zero") in order to forbid them, so scanning raw bytes would false-positive —
    // SlipCopy's Codable model omits `_meta`, which is exactly why the scan decodes
    // first.
    private static let shameLexicon = [
        "relapse", "failed", "failure", "ruined", "broke", "broken",
        "back to day 1", "back to zero", "reset to zero", "shame", "weak", "guilty",
    ]
    private static let medicalClaims = [
        "cures", "reverses", "heals your", "clinically proven", "medical",
    ]

    /// Every user-facing string on the decoded copy (retryNote folded in when present).
    private func allStrings(_ c: SlipCopy) -> [String] {
        var strings = [c.confirm.title, c.confirm.body, c.confirm.confirmLabel, c.confirm.cancelLabel]
        if let retry = c.confirm.retryNote { strings.append(retry) }
        strings += [c.logged.title, c.logged.body, c.logged.bodyNoBest]
        strings += [c.reflection.prompt, c.reflection.placeholder, c.reflection.skipLabel, c.reflection.saveLabel]
        strings += [c.undo.banner, c.undo.undoLabel, c.undo.windowNote, c.undo.undoneConfirmation]
        strings += c.encouragement
        strings.append(c.motivationEcho)
        return strings
    }

    @Test func test_slipCopy_shippingFileBundledAndDecodes() throws {
        // RED gate: unbundled ⇒ loadShipping() is nil ⇒ this #require is the designed
        // failure (the panicScript precedent's exact shape, one epic later).
        let copy = try #require(
            SlipCopy.loadShipping(),
            "the shipping slipCopy.json must be BUNDLED and decode AS-IS (§3.2) — it is unbundled at red"
        )

        // Every section the flow renders is present and non-empty.
        #expect(!copy.confirm.title.isEmpty)
        #expect(!copy.confirm.body.isEmpty)
        #expect(!copy.confirm.confirmLabel.isEmpty)
        #expect(!copy.confirm.cancelLabel.isEmpty)
        #expect(!copy.logged.title.isEmpty)
        #expect(!copy.logged.body.isEmpty)
        #expect(!copy.logged.bodyNoBest.isEmpty)
        #expect(!copy.reflection.prompt.isEmpty)
        #expect(!copy.reflection.placeholder.isEmpty)
        #expect(!copy.reflection.skipLabel.isEmpty)
        #expect(!copy.reflection.saveLabel.isEmpty)
        #expect(!copy.undo.banner.isEmpty)
        #expect(!copy.undo.undoLabel.isEmpty)
        #expect(!copy.undo.windowNote.isEmpty)
        #expect(!copy.undo.undoneConfirmation.isEmpty)
        #expect(!copy.encouragement.isEmpty, "the forgiveness screen draws from at least one encouragement line")
        #expect(!copy.motivationEcho.isEmpty)

        // The ONE agent-drafted E4.1 addition (decision record §UI; REVIEW.md item 3
        // flags it for operator tone review): the calm, zero-shame append-failure line,
        // shown only when the durable write failed — "Logged." is never claimed without
        // durable bytes (§9 rule 1).
        #expect(
            copy.confirm.retryNote != nil,
            "confirm.retryNote must ship — the §9-rule-1 durable-write-failed line the E4.1 flow needs"
        )
    }

    @Test func test_slipCopy_containsNoShameLexicon_orMedicalClaims() throws {
        let copy = try #require(
            SlipCopy.loadShipping(),
            "unbundled at red — the audit needs the shipping bytes"
        )

        for string in allStrings(copy) {
            let haystack = string.lowercased()
            for banned in Self.shameLexicon {
                #expect(
                    !haystack.contains(banned),
                    "shame lexicon '\(banned)' must never appear — a slip is data, not a verdict (brand kit §1.2): \(string)"
                )
            }
            for banned in Self.medicalClaims {
                #expect(
                    !haystack.contains(banned),
                    "medical-claim token '\(banned)' must never appear — the app makes no medical claim: \(string)"
                )
            }
        }

        // Token integrity: the flow substitutes ONLY {{bestStreak}}, {{momentum}} and
        // {{motivation}} (brand kit §1.2 — a single user word echoed back, never
        // generated). A dropped token would render a literal "{{…}}" or lose the fact.
        #expect(copy.logged.body.contains("{{bestStreak}}"), "the logged body archives the user's best by token")
        #expect(copy.logged.body.contains("{{momentum}}"), "the logged body states momentum is preserved by token")
        #expect(copy.motivationEcho.contains("{{motivation}}"), "the echo replays the user's own word verbatim")
        #expect(copy.logged.bodyNoBest.contains("{{momentum}}"), "the no-best variant still states momentum")
        #expect(
            !copy.logged.bodyNoBest.contains("{{bestStreak}}"),
            "the no-best variant is EXACTLY for a 0-best quit — it must not reference an archived best it does not have"
        )
    }

    @Test func test_slipCopy_undoBannerCopy_isCalm() throws {
        let copy = try #require(
            SlipCopy.loadShipping(),
            "unbundled at red — the calm-tone pins need the shipping bytes"
        )

        #expect(
            copy.undo.windowNote.localizedCaseInsensitiveContains("10 minutes"),
            "the window note states the concrete 10-minute reversibility (brand §6 #13) — never a vague 'a while'"
        )

        // The undo surface is a NEUTRAL affordance, never an alarm (decision record §UI:
        // neutral surface, never amber/red — a turn, not an X). The COPY carries the same
        // calm: no urgency or warning language.
        let banner = copy.undo.banner.lowercased()
        for alarm in ["warning", "!", "last chance", "hurry"] {
            #expect(
                !banner.contains(alarm),
                "the undo banner stays calm — '\(alarm)' is alarm language a forgiveness surface never uses: \(copy.undo.banner)"
            )
        }
    }
}
