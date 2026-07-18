import Foundation
import Testing
@testable import Unhooked

// UIR-1 (Session 33) unit lane — the SOURCE half of the Dynamic-Type closure, on
// the ThemeSourceLintTests shape (which does the same job for colour).
//
// UIR-1 restored `.dynamicType` and `.textClipped` to the accessibility audit on
// every onboarding leg (age gate, quiz, summary). The audit runs on macOS CI only,
// so it cannot tell a Linux-side agent — or a reviewer — that a change has quietly
// re-introduced the exact idioms that made onboarding text un-scalable in the first
// place. This lint can, for free, on every lane.
//
// Each banned idiom below is a REAL defect this session removed, and the two that
// carry `R33.12` were not reasoned out — they were MEASURED, in the audit's own
// element screenshots from run 29303961082:
//
//   • `.font(.system(size: …))` ON TEXT — banned for ANY size, literal or variable.
//     A point-size font carries no type metrics, so Apple's audit reports *"User will
//     not be able to change the font size of this SwiftUI.AccessibilityNode"* — and a
//     `@ScaledMetric` driving the number does NOT rescue it (the hero shipped exactly
//     that way and fired anyway). The sanctioned form is a TEXT STYLE:
//     `.font(.system(.largeTitle, design: .rounded, weight: .bold))`.
//     Decorative `Image` glyphs are EXEMPT — the audit does not scan an SF Symbol for
//     type scaling, and both screen glyphs passed the full set on that same run. The
//     lint tracks `Image(` modifier chains so it can tell the two apart.
//   • `ViewThatFits` — banned on any audited surface. It sizes its candidates at a
//     FIXED ideal, and the audit then reports every Text inside it as un-scalable. It
//     fired on BOTH hero Texts, including the suffix, which carried a plain `.title3`
//     text style — the CONTAINER, not the font, was the defect. brandkit §8's
//     "switches to a stacked layout rather than shrinking" must be read off
//     `@Environment(\.dynamicTypeSize)` instead.
//   • `.minimumScaleFactor(` — shrink-to-fit. brandkit §8 rules it out for the hero
//     in as many words. The layout gives way, never the glyph.
//   • `.lineLimit(1)` — a one-line cap on copy that must be free to wrap is how text
//     gets truncated at accessibility sizes.
//   • `.buttonStyle(.plain)` — R32.9: the plain style silently composites a DISABLED
//     label at ~50% opacity ON TOP of any explicit foregroundStyle (an authored
//     5.89:1 rendered at 2.14:1 and fired the contrast audit). Every onboarding
//     button rides a Theme primitive style instead.
//
// Scope: the onboarding surfaces UIR-1 owns. The panic and slip flows legitimately
// still use some of these idioms (their 56pt targets and their own fixed-size glyphs
// are UIR-3's and UIR-2's to close) — a repo-wide ban would fail today and would be
// a lie about what has actually been fixed. The scope GROWS as each UIR session
// closes its surfaces; it never shrinks.
@Suite("UIR-1 · onboarding layout lint")
struct OnboardingLayoutLintTests {
    /// The directories UIR rebuilt. Grow-only: UIR-2 adds the dashboard, UIR-3 the
    /// panic/slip flows, and so on until the whole of App/Sources is covered.
    private static let scopedDirectories = [
        "App/Sources/AgeGate", "App/Sources/Quiz", "App/Sources/Dashboard",
        "App/Sources/Monetization",
    ]

    /// Idioms that defeat Dynamic Type, plus the disabled-label dimming trap.
    /// Substring matches against comment-stripped code lines.
    private static let bannedIdioms: [String] = [
        ".minimumScaleFactor(",
        ".lineLimit(1)",
        ".buttonStyle(.plain)",
        ".background(.quaternary",
        "ViewThatFits",
    ]

    /// Repo root from this file's compile-time path (Tests/Unit/<file> → up 3) —
    /// the PrivacyManifestTests / ThemeSourceLintTests idiom.
    private static var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    @Test func test_onboardingSources_carryNoDynamicTypeDefeatingIdioms() throws {
        var violations: [String] = []
        var scannedFiles = 0

        for directory in Self.scopedDirectories {
            let root = Self.repoRoot.appendingPathComponent(directory, isDirectory: true)
            let enumerator = try #require(
                FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil),
                "\(directory) must be walkable from the test host"
            )
            for case let url as URL in enumerator {
                guard url.pathExtension == "swift" else { continue }
                scannedFiles += 1
                let source = try String(contentsOf: url, encoding: .utf8)
                violations += Self.scan(source, in: url.lastPathComponent)
            }
        }

        // Corpus non-vacuity floor (the lexicon-gate discipline): the walk must
        // actually be seeing the onboarding view layer, not an empty directory.
        #expect(
            scannedFiles >= 35,
            "the lint walked only \(scannedFiles) onboarding files — the corpus shrank implausibly"
        )
        #expect(
            violations.isEmpty,
            """
            Dynamic-Type-defeating idioms found on an onboarding surface. These \
            surfaces run the FULL accessibility audit (.dynamicType + .textClipped \
            restored in UIR-1) — fix the layout, never this assertion:
            \(violations.joined(separator: "\n"))
            """
        )
    }

    /// The gate must gate itself (the ThemeContrastTests calibration discipline): a
    /// lint that cannot fire on the very bytes it was written to remove is vacuous.
    /// These are the EXACT idioms the pre-UIR-1 `QuizSummaryView` hero carried, plus
    /// the `ViewThatFits` ladder that UIR-1's own FIRST attempt shipped and the audit
    /// then rejected.
    @Test func test_theLint_firesOnEveryRetiredHeroIdiom() {
        let retiredHero = """
        ViewThatFits(in: .horizontal) {
            Text(parts.amount)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .buttonStyle(.plain)
        """
        #expect(
            Self.scan(retiredHero, in: "fixture").count == 5,
            """
            the lint must catch all five retired idioms (ViewThatFits, the point-size \
            font, shrink-to-fit, the one-line cap, the plain style) — it caught \
            \(Self.scan(retiredHero, in: "fixture").count)
            """
        )
    }

    /// A `@ScaledMetric` variable does NOT make a point-size font acceptable ON TEXT —
    /// that is the exact form run 29303961082 rejected, and the exact form a reader of
    /// the old lint would have believed was sanctioned.
    @Test func test_theLint_firesOnAScaledMetricDrivenPointSize_onText() {
        let scaledButStillPointSized = """
        Text(amount)
            .font(.system(size: min(heroSize, Theme.type.heroCap), weight: .bold))
        """
        #expect(
            Self.scan(scaledButStillPointSized, in: "fixture").count == 1,
            "a @ScaledMetric-driven POINT SIZE on text is still un-scalable to the audit — the lint must fire"
        )
    }

    /// The two sanctioned forms must NOT fire: a TEXT STYLE on text, and a point size
    /// on a decorative `Image` glyph (both passed the full audit on the same run).
    @Test func test_theLint_acceptsTextStylesAndImageGlyphs() {
        let sanctionedText = """
        Text(amount)
            .font(.system(.largeTitle, design: .rounded, weight: .bold))
            .monospacedDigit()
        """
        #expect(
            Self.scan(sanctionedText, in: "fixture").isEmpty,
            "a text-style font is THE sanctioned form — the lint must not fire on it"
        )

        let sanctionedGlyph = """
        Image(systemName: "calendar")
            .font(.system(size: min(glyphSize, Theme.type.screenGlyphCap), weight: .light))
            .accessibilityHidden(true)
        """
        #expect(
            Self.scan(sanctionedGlyph, in: "fixture").isEmpty,
            "a decorative SF-Symbol glyph may carry a point size — the audit does not scan images for type scaling"
        )
    }

    // MARK: - The rules

    /// Every violation in one source, in line order.
    ///
    /// The `Image(` chain state is what lets one line-based rule serve both facts the
    /// audit taught us: a point size is a DEFECT on text and FINE on a glyph. A line
    /// that opens an `Image(...)` starts a chain; the `.modifier` lines that follow
    /// belong to it; any other statement ends it.
    private static func scan(_ source: String, in fileName: String) -> [String] {
        var violations: [String] = []
        var inImageChain = false

        for (index, rawLine) in source.components(separatedBy: "\n").enumerated() {
            let code = strippingComment(rawLine)
            let trimmed = code.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            if trimmed.hasPrefix("Image(") {
                inImageChain = true
            } else if !trimmed.hasPrefix(".") {
                inImageChain = false
            }

            for idiom in bannedIdioms where code.contains(idiom) {
                violations.append("\(fileName):\(index + 1) uses '\(idiom)'")
            }
            if !inImageChain, let size = pointSizedFont(in: code) {
                violations.append(
                    "\(fileName):\(index + 1) sizes TEXT by a point value "
                    + "('.font(.system(size: \(size)') — it carries no type metrics, so Apple's audit "
                    + "reports it un-scalable even under @ScaledMetric (R33.12). Use a text style: "
                    + ".font(.system(.largeTitle, design: .rounded, weight: .bold))"
                )
            }
        }
        return violations
    }

    /// Prose may still discuss the idioms it bans (this file does, at length), so a
    /// trailing `//` comment is stripped and a whole-line comment is skipped —
    /// the ThemeSourceLintTests contract, reused verbatim.
    private static func strippingComment(_ line: String) -> String {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("//") || trimmed.hasPrefix("///") { return "" }
        guard let range = line.range(of: "//") else { return line }
        // `://` inside a URL is not a comment marker.
        if line[..<range.lowerBound].hasSuffix(":") { return line }
        return String(line[..<range.lowerBound])
    }

    /// Returns the size EXPRESSION when a line sizes a font by a point value —
    /// `56` and `min(heroSize, …)` alike. Both are defects on text; only a text style
    /// (`.font(.system(.largeTitle, …))`, which never matches this needle) is not.
    private static func pointSizedFont(in code: String) -> String? {
        let needle = ".font(.system(size: "
        guard let start = code.range(of: needle) else { return nil }
        let rest = code[start.upperBound...]
        let expression = rest.prefix { $0 != "," && $0 != ")" }
        return expression.isEmpty ? nil : String(expression)
    }
}
