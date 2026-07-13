import Foundation
import Testing
@testable import Unhooked

// E10.2 unit lane — the submission metadata lint (implementation-plan §E10.2:
// "`test_release_bundleContainsNoExplicitTermsInMetadata()`-style lint on metadata
// files where automatable"; MVP §7 App Review readiness: "no explicit terms in name,
// subtitle, keywords, or screenshots" — this gate is the IN-REPO bundled half of that
// row: the store-side fields (subtitle/keywords/promotional text/screenshots) exist
// only in App Store Connect behind Gate G0 and stay operator-scanned at submission).
//
// BOTH tests are BORN-GREEN permanent gates by design (the MilestoneCopyTests R27.13 /
// PanicScriptLexiconTests R28.9 shape): every scanned surface already ships clean —
// the S30 Linux rehearsal ran this exact matcher over the exact shipping bytes
// (357 content-table string values + the bundle names + 22 widget/control/intent
// strings) and found 0 violations, so there is no honest red to design and audit
// tests never enter a red manifest (standing rule).
//
// Register discipline (S30 panel, R30.2):
// - The EXPLICIT-TERMS register is GRAPHIC-register only. The category nouns
//   "porn"/"weed" are deliberately NOT banned — "porn addiction" is a sanctioned
//   ASO/clinical phrase (brandkit §9.3) and the structural category ids/keys ride
//   through decoded values; banning the noun would false-fire on sanctioned copy.
//   The clinical display forms ("Adult content", "Cannabis") are the SANCTIONED
//   register and pinned as negatives below.
// - The NO-MEDICAL-CLAIMS register here is the NARROW brandkit §9.3 ASO subset
//   ("recover", "treatment", "addiction cure" + word-boundary "cure") and scans the
//   BUNDLE DISPLAY NAMES ONLY: the content tables are already medical-gated
//   (SlipLexiconTests' shame list owns recover/treatment/cure on the copy tables;
//   MilestoneCopyTests owns milestones.json bodies). It deliberately EXCLUDES
//   detox/heal/toxin — "dopamine detox" is a sanctioned ASO keyword theme; those
//   tokens are milestone-body scope, not metadata scope. Zero duplication, zero
//   register conflict.
// - The content tables get the EXPLICIT register only (no existing gate runs it
//   over them); helplines.json is NEVER lexicon-scanned (verbatim sourced material,
//   standing rule) and is not read here.
// - `PanicControlStyle` is a computed-property enum whose Mirror yields NOTHING —
//   its cases are enumerated EXPLICITLY with a count pin (the R9 vacuity trap;
//   StreakWidgetStyle's own doc-comment records the lesson). AppIntent titles are
//   `LocalizedStringResource` (no scannable stored String) — pinned BYTE-EXACT via
//   `.key` (docs-confirmed member, iOS 16+), never reflected.
// - The widget extension's `CFBundleDisplayName` ("Ballast Widgets") lives in the
//   `.appex` Info.plist, which app-host `Bundle.main` cannot see; it is covered by
//   the S30 rehearsal over project.yml:219 (deliberately NOT a fragile
//   builtInPlugInsURL traversal).

@Suite("E10.2 · submission metadata lint")
struct SubmissionMetadataLintTests {

    // MARK: - The explicit-terms lexicon (graphic register ONLY; the list only GROWS)

    /// Substring tokens, matched over folded, whitespace-collapsed strings.
    /// "masturbat" catches the inflections; "jerk off"/"jerkoff" cover both spellings.
    private static let explicitSubstrings: [String] = [
        "hardcore", "hentai", "camgirl", "camwhore", "nude", "nudity",
        "masturbat", "fetish", "orgy", "blowjob", "smut", "jerkoff", "jerk off",
    ]

    /// Word-boundary tokens: substring matching would false-positive on innocent
    /// forms ("swank/swanky" contain "wank"; "nofap" contains "fap"; "xxx" rides
    /// inside stylized brand strings) — \b anchors keep those clean while bare
    /// "XXX"/"NSFW"/"wank"/"fap" still fire.
    private static let explicitWords: [String] = ["xxx", "nsfw", "wank", "fap"]

    // MARK: - The no-medical-claims register (narrow §9.3 ASO subset; display names ONLY)

    private static let medicalSubstrings: [String] = [
        "recover", "treatment", "addiction cure", "cures addiction",
    ]
    private static let medicalWords: [String] = ["cure"]

    /// The frozen S30 floor — NEVER edit this set; grow the live lists instead.
    /// `test_release_metadataLexicons_onlyGrow_fromFoundationFloor` pins the live
    /// union as a superset, so removing a token is a deliberate two-place edit a
    /// review can't miss, never a drive-by (the E4.2 discipline).
    private static let metadataFoundationFloor: Set<String> = [
        "hardcore", "hentai", "camgirl", "camwhore", "nude", "nudity",
        "masturbat", "fetish", "orgy", "blowjob", "smut", "jerkoff", "jerk off",
        "xxx", "nsfw", "wank", "fap",
        "recover", "treatment", "addiction cure", "cures addiction",
        "cure",
    ]

    // MARK: - The matcher (behavior-pinned below so it cannot silently rot)

    /// Casefold + diacritic-fold + collapse whitespace runs to one space — the
    /// SlipLexiconTests matcher, verbatim technique.
    private static func folded(_ string: String) -> String {
        string.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            .split(whereSeparator: { $0.isWhitespace || $0.isNewline })
            .joined(separator: " ")
    }

    /// The first explicit-register token the string carries, or nil when clean.
    private static func firstExplicitViolation(in string: String) -> String? {
        let haystack = folded(string)
        for banned in explicitSubstrings where haystack.contains(folded(banned)) {
            return banned
        }
        for banned in explicitWords
        where haystack.range(of: "\\b\(banned)\\b", options: [.regularExpression, .caseInsensitive]) != nil {
            return banned
        }
        return nil
    }

    /// The first metadata-medical token the string carries, or nil when clean.
    private static func firstMedicalViolation(in string: String) -> String? {
        let haystack = folded(string)
        for banned in medicalSubstrings where haystack.contains(folded(banned)) {
            return banned
        }
        for banned in medicalWords
        where haystack.range(of: "\\b\(banned)\\b", options: [.regularExpression, .caseInsensitive]) != nil {
            return banned
        }
        return nil
    }

    // MARK: - The corpus walkers

    /// Every `String` reachable from the decoded value, by reflection — the
    /// SlipLexiconTests walker verbatim: a field added to any table joins the scan
    /// automatically instead of waiting for a hand-rolled collector to learn it.
    private static func reflectedStrings(of subject: Any) -> [String] {
        if let string = subject as? String { return [string] }
        return Mirror(reflecting: subject).children.flatMap { reflectedStrings(of: $0.value) }
    }

    /// Every (title, body) pair across every milestones category table — the
    /// MilestoneCopyTests mechanics verbatim (no production Milestones copy model
    /// exists or may be added for an audit — the PM fence, R27.13).
    private static func milestoneRows() throws -> [(title: String, body: String)] {
        let url = try #require(
            Bundle.main.url(forResource: "milestones", withExtension: "json"),
            "the shipping milestones.json must be bundled (ships since S21)"
        )
        let root = try #require(
            try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any]
        )
        var rows: [(String, String)] = []
        for key in Set(root.keys).subtracting(["_meta"]) {
            let table = try #require(root[key] as? [String: Any])
            let milestones = try #require(table["milestones"] as? [[String: Any]])
            for row in milestones {
                rows.append((
                    try #require(row["title"] as? String),
                    try #require(row["body"] as? String)
                ))
            }
        }
        return rows
    }

    // MARK: - The plan-named gate (implementation-plan §E10.2)

    @Test func test_release_bundleContainsNoExplicitTermsInMetadata() throws {
        // ── Surface group 1: the bundled app metadata (BOTH registers) ──────────
        // App-hosted lane ⇒ Bundle.main IS the Ballast app bundle (the
        // MilestoneCopyTests precedent).
        let displayName = try #require(
            Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String,
            "the app's display name must be present in the shipped Info.plist"
        )
        #expect(!displayName.isEmpty, "the display name must never be blank")

        var bundleNames = [displayName]
        if let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
            bundleNames.append(bundleName)
        }
        // Alternate-icon names surface in Settings and the app switcher — scan the
        // declared keys when the generated Info.plist carries them (defensive: the
        // display-name #require above is the group's non-vacuity anchor).
        if let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
           let alternates = icons["CFBundleAlternateIcons"] as? [String: Any] {
            bundleNames.append(contentsOf: alternates.keys)
        }
        #expect(bundleNames.count >= 2, "the bundle-name corpus collapsed — the scan would be vacuous")

        for string in bundleNames {
            #expect(
                Self.firstExplicitViolation(in: string) == nil,
                "explicit term in bundled metadata (MVP §7 App Review readiness): \(string)"
            )
            #expect(
                Self.firstMedicalViolation(in: string) == nil,
                "medical-claim vocabulary in bundled metadata (brandkit §9.3): \(string)"
            )
        }

        // ── Surface group 2: the bundled content tables (EXPLICIT register only —
        //    each table's shame/leak/medical gate already exists; helplines.json is
        //    NEVER read) ──────────────────────────────────────────────────────────
        let slip = try #require(SlipCopy.loadShipping(), "shipping slipCopy.json must decode (§3.2)")
        let age = try #require(AgeGateCopy.loadShipping(), "shipping ageGateCopy.json must decode (§3.2)")
        let quiz = try #require(QuizConfig.loadShipping(), "shipping quizConfig.json must decode (§3.2)")
        let summary = try #require(SummaryCopy.loadShipping(), "shipping summaryCopy.json must decode (§3.2)")
        let safety = try #require(SafetyCopy.loadShipping(), "shipping safetyCopy.json must decode (§3.2)")
        let script = try #require(PanicScript.loadShipping(), "shipping panicScript.json must decode (§3.2)")
        let paywall = try #require(PaywallCopy.loadShipping(), "shipping paywallCopy.json must decode (§3.2)")
        let milestones = try Self.milestoneRows()

        // Per-table non-vacuity floors (each neighbor gate's own floor, so a decode
        // or walker collapse here can never read as a pass).
        #expect(Self.reflectedStrings(of: slip).count >= 20, "slip corpus collapsed")
        #expect(Self.reflectedStrings(of: age).count >= 8, "age-gate corpus collapsed")
        #expect(Self.reflectedStrings(of: quiz).count >= 40, "quiz corpus collapsed")
        #expect(Self.reflectedStrings(of: summary).count >= 11, "summary corpus collapsed")
        #expect(Self.reflectedStrings(of: safety).count >= 9, "safety corpus collapsed")
        #expect(Self.reflectedStrings(of: script).count >= 30, "panic-script corpus collapsed")
        #expect(Self.reflectedStrings(of: paywall).count >= 20, "paywall corpus collapsed")
        #expect(milestones.count >= 40, "the shipping table carries 40+ milestones (43 at S27)")

        let tableCorpus: [String] =
            Self.reflectedStrings(of: slip) + Self.reflectedStrings(of: SlipCopy.degraded)
            + Self.reflectedStrings(of: age) + Self.reflectedStrings(of: AgeGateCopy.degraded)
            + Self.reflectedStrings(of: quiz) + Self.reflectedStrings(of: QuizConfig.degraded)
            + Self.reflectedStrings(of: summary) + Self.reflectedStrings(of: SummaryCopy.degraded)
            + Self.reflectedStrings(of: safety) + Self.reflectedStrings(of: SafetyCopy.AlcoholNotice.degraded)
            + [SafetyResourcesPresentation.degradedTitle, SafetyResourcesPresentation.degradedIntro]
            + Self.reflectedStrings(of: script)
            + Self.reflectedStrings(of: paywall) + Self.reflectedStrings(of: PaywallCopy.degraded)
            + milestones.flatMap { [$0.title, $0.body] }

        for string in tableCorpus {
            let violation = Self.firstExplicitViolation(in: string)
            #expect(
                violation == nil,
                "explicit term '\(violation ?? "?")' in a bundled copy table — the clinical register is the only sanctioned one (MVP §7, brandkit §9.3): \(string)"
            )
        }

        // ── Surface group 3: widget/control gallery + intent titles (EXPLICIT
        //    register; PanicControlStyle enumerated — its Mirror is empty, the R9
        //    vacuity trap; intent titles pinned byte-exact — LocalizedStringResource
        //    has no scannable stored String) ───────────────────────────────────────
        let galleryCorpus = Self.reflectedStrings(of: StreakWidgetStyle.shipping)
        #expect(galleryCorpus.count >= 12, "the widget-gallery corpus collapsed")

        let controlCorpus = [PanicControlStyle.standard, PanicControlStyle.discreet].flatMap {
            [$0.title, $0.displayName, $0.description, $0.symbolName, $0.controlKind]
        }
        #expect(controlCorpus.count == 10, "the control corpus is the explicit 2×5 enumeration")

        for string in galleryCorpus + controlCorpus {
            let violation = Self.firstExplicitViolation(in: string)
            #expect(
                violation == nil,
                "explicit term '\(violation ?? "?")' in a gallery/control string — readable by anyone holding the phone (§10): \(string)"
            )
        }

        #expect(OpenPanicIntent.title.key == "Panic", "the widget-button intent title is the plan-locked literal")
        #expect(OpenPanicControlIntent.title.key == "Panic", "the control intent title is the plan-locked literal")
    }

    // MARK: - The gate gates itself

    @Test func test_release_metadataLexicons_onlyGrow_fromFoundationFloor() {
        let live = Set(Self.explicitSubstrings)
            .union(Self.explicitWords)
            .union(Self.medicalSubstrings)
            .union(Self.medicalWords)
        #expect(
            live.isSuperset(of: Self.metadataFoundationFloor),
            "the metadata lexicons only ever GROW — a removed token is a deliberate two-place edit, never a drive-by"
        )

        // The matcher is alive (positive pins)…
        #expect(Self.firstExplicitViolation(in: "XXX Live Cams") == "xxx")
        #expect(Self.firstExplicitViolation(in: "Masturbation tracker") == "masturbat")
        #expect(Self.firstExplicitViolation(in: "nsfw content") == "nsfw")
        #expect(Self.firstExplicitViolation(in: "totally nude") == "nude")
        #expect(Self.firstMedicalViolation(in: "the addiction cure") == "addiction cure")
        #expect(Self.firstMedicalViolation(in: "recover your health") == "recover")
        #expect(Self.firstMedicalViolation(in: "addiction treatment app") == "treatment")
        #expect(Self.firstMedicalViolation(in: "we cure addiction") == "cure")

        // …and calibrated (the sanctioned clinical/ASO register never trips it —
        // the category nouns and clinical forms are the register MVP §7 mandates).
        #expect(Self.firstExplicitViolation(in: "Ballast") == nil)
        #expect(Self.firstExplicitViolation(in: "Adult content") == nil)
        #expect(Self.firstExplicitViolation(in: "Cannabis") == nil)
        #expect(Self.firstExplicitViolation(in: "porn addiction") == nil)
        #expect(Self.firstExplicitViolation(in: "quit vaping") == nil)
        #expect(Self.firstExplicitViolation(in: "dopamine detox") == nil)
        #expect(Self.firstExplicitViolation(in: "nofap community") == nil)
        #expect(Self.firstExplicitViolation(in: "a swanky new widget") == nil)
        #expect(Self.firstMedicalViolation(in: "Ballast") == nil)
        #expect(Self.firstMedicalViolation(in: "Ballast Widgets") == nil)
        #expect(Self.firstMedicalViolation(in: "your data stays secure") == nil)
    }
}
