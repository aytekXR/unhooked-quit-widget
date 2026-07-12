import Foundation
import Testing
@testable import Unhooked

// E7.1 app half (Session 24) — the paywall copy table's gates (R24.9/R24.10):
// the shipping `paywallCopy.json` decodes, passes the STANDARD dual lexicon
// (shame + habit-leak — the DiscreetSettingsCopyTests mechanism, replicated
// per the no-shared-fixtures convention), and the COMPOSED screen data
// carries every guideline-3.1.1/3.1.2(c) disclosure as a plain string
// assertion (test-suite §4.4: "automated as a string-presence check on the
// paywall view"): plan titles, billing-period price lines, the trial length
// AND what follows it, the auto-renewal statement, Terms/Privacy labels, and
// the 3.1.1-mandated restore mechanism. Prices arrive through the `%@`
// templates from ProductCatalog's static control-arm constants (R24.5) — the
// copy table itself carries no price literal to drift.
//
// RED: paywallCopy.json is not yet bundled (loadShipping ⇒ nil) and
// `PaywallPresentation.make` is inert — the shipping/composition pins fail by
// design; the `.degraded` scan is born-green (the fallback is final at red).

@Suite("E7.1 · paywall copy + guideline-3.1.1 strings")
struct PaywallCopyTests {
    /// The shame register — StreakWidgetStyleTests' list, verbatim (the
    /// SlipLexiconTests foundation; the private list is not importable, so
    /// the mechanism is replicated — the DiscreetSettingsCopyTests shape).
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
    /// Word-boundary tokens: substring matching would false-positive ("using"
    /// ⊃ "sin", "secure" ⊃ "cure").
    private static let shameWords: [String] = ["sin", "cure"]

    /// The STANDARD habit-leak lexicon (§10): the paywall is name-free BY
    /// BRAND RULE (a shoulder-surfed purchase sheet must not out the habit) —
    /// the StreakWidgetStyleTests list, verbatim.
    private static let leakSubstrings: [String] = [
        "vape", "vaping", "porn", "alcohol", "weed", "doomscroll",
        "smoke", "drink", "sober", "quit", "addiction", "relapse", "habit",
    ]

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

    private static func expectShameAndLeakFree(_ copy: PaywallCopy, label: String) {
        var collected: [String] = []
        for child in Mirror(reflecting: copy).children {
            guard let value = child.value as? String else { continue }
            collected.append(value)
            #expect(
                Self.firstShameViolation(in: value) == nil,
                "a \(label) paywall string carries the shame register '\(Self.firstShameViolation(in: value) ?? "?")': \(value)"
            )
            #expect(
                Self.firstLeakViolation(in: value) == nil,
                "a \(label) paywall string leaks a habit noun '\(Self.firstLeakViolation(in: value) ?? "?")': \(value)"
            )
        }
        // Non-vacuity floor (the reproduced R9 trap): PaywallCopy is a STRUCT
        // of 27 STORED strings (20 + 3 teaser, S25 + 4 winback, S26/R26.9) —
        // a collapse below 27 means the walk (or the type's shape) silently
        // broke and the scan is vacuous.
        #expect(
            collected.count >= 27,
            "the Mirror walk collapsed (<27 strings) — the scan would pass vacuously"
        )
    }

    /// M22a (designed-red): the shipping table decodes from the app bundle
    /// (the audited-copy-table lane: founder-owned JSON, never compiled
    /// constants that bypass the tone queue).
    @Test func test_paywallCopy_shipping_decodesFromBundle() throws {
        _ = try #require(
            PaywallCopy.loadShipping(),
            "paywallCopy.json must ship as an app-bundle resource (project.yml Content entry)"
        )
    }

    /// M22b (designed-red until the file ships): the shipping table passes
    /// the STANDARD dual lexicon with the non-vacuity floor.
    @Test func test_paywallCopy_shipping_isShameAndLeakFree_withNonVacuityFloor() throws {
        let copy = try #require(PaywallCopy.loadShipping())
        Self.expectShameAndLeakFree(copy, label: "shipping")
    }

    /// M22c (born-green): the degraded fallback faces the SAME gates — a
    /// decode failure may never route around the register rules.
    @Test func test_paywallCopy_degraded_isShameAndLeakFree_withNonVacuityFloor() {
        Self.expectShameAndLeakFree(.degraded, label: "degraded")
    }

    /// M22d (designed-red): the COMPOSED screen data carries every
    /// guideline-3.1.1/3.1.2(c) disclosure — price, trial length AND the
    /// price that follows it, the auto-renewal statement, Terms/Privacy, and
    /// the mandated restore mechanism. The control-arm prices arrive from
    /// ProductCatalog through the `%@` templates (architecture §8: the
    /// bundled fallback renders the $29.99 control arm, offline-safe).
    @Test func test_paywallComposed_carriesGuideline311Disclosures() {
        let data = PaywallPresentation.make(copy: PaywallCopy.loadShipping() ?? .degraded)

        #expect(data.priceMonthlyLine.contains("$6.99"))
        #expect(data.priceAnnualLine.contains("$29.99"), "the CONTROL arm — never the $39.99 Superwall arm")
        #expect(data.trialBadge.contains("3-day"))
        #expect(
            data.trialMechanicsLine.contains("3 days") && data.trialMechanicsLine.contains("$29.99"),
            "trial length AND the price that follows it, unmistakable in one line (3.1.2(c))"
        )
        #expect(data.autoRenewDisclosure.contains("renews automatically"))
        #expect(data.autoRenewDisclosure.contains("cancel"))
        #expect(data.restoreLabel == "Restore purchases", "the 3.1.1-mandated restore mechanism")
        #expect(!data.termsLabel.isEmpty && !data.privacyLabel.isEmpty, "functional Terms/Privacy links (Schedule 2)")
        #expect(!data.retryCta.isEmpty && !data.failureBanner.isEmpty, "the never-trap failure surface exists")
        #expect(!data.planMonthlyTitle.isEmpty && !data.planAnnualTitle.isEmpty)
    }

    // MARK: - E7.2 (R25.8): the teaser strings + the variant fork

    /// E7.2 D1 (born-green — the three teaser fields land WITH this test, in
    /// both the shipping JSON and `.degraded`; non-optional BY RULING so the
    /// Mirror lexicon walk above covers them like their 20 siblings): every
    /// teaser string is present and non-empty in both tables.
    @Test func test_paywallCopy_teaserStrings_presentAndNonEmpty() throws {
        let shipping = try #require(PaywallCopy.loadShipping())
        for copy in [shipping, .degraded] {
            #expect(!copy.teaserEscapeLabel.isEmpty)
            #expect(!copy.teaserEscapeNote.isEmpty)
            #expect(!copy.teaserExpiryEyebrow.isEmpty)
        }
    }

    /// E7.2 D2 (designed-red): the TEASER variant's first impression
    /// composes the escape (label + note, the §6.2 QuietButton data) AND
    /// still carries every 3.1.1/3.1.2(c) disclosure — the escape is
    /// additive, never a displacement (test-suite §4.4: both variants'
    /// rendered paywalls contain price, trial length, renewal terms).
    @Test func test_paywallComposed_teaserVariant_carriesEscapeAndAllDisclosures() throws {
        let copy = try #require(PaywallCopy.loadShipping())
        let data = PaywallPresentation.make(copy: copy, variant: .teaser, source: .onboarding)

        let escape = try #require(data.teaserEscape, "the teaser arm's first impression renders the escape")
        #expect(escape.label == copy.teaserEscapeLabel)
        #expect(escape.note == copy.teaserEscapeNote)
        #expect(data.expiryEyebrow == nil, "no eyebrow on a first impression")
        #expect(data.trialMechanicsLine.contains("$29.99") && data.autoRenewDisclosure.contains("renews automatically"),
                "the escape never sheds a disclosure")
        #expect(data.restoreLabel == "Restore purchases")
    }

    /// E7.2 D2b (designed-red): the teaser-EXPIRY re-present is close-free
    /// (single-use escape — "Then this screen returns." must stay true) and
    /// carries the zero-shame eyebrow; the hard variant composes NEITHER.
    @Test func test_paywallComposed_teaserExpiryRepresent_eyebrowNoEscape_hardComposesNeither() throws {
        let copy = try #require(PaywallCopy.loadShipping())

        let represent = PaywallPresentation.make(copy: copy, variant: .teaser, source: .teaserExpiry)
        #expect(represent.teaserEscape == nil, "the escape is SINGLE-USE — the re-present is the hard form (R25.7)")
        #expect(represent.expiryEyebrow == copy.teaserExpiryEyebrow)
        #expect(represent.autoRenewDisclosure.contains("renews automatically"),
                "the re-present keeps the full disclosure set")

        let hard = PaywallPresentation.make(copy: copy, variant: .hard, source: .onboarding)
        #expect(hard.teaserEscape == nil, "the hard variant stays close-free (R24.9 carried)")
        #expect(hard.expiryEyebrow == nil)
    }
}
