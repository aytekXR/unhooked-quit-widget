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
// Each banned idiom below is a REAL defect this session removed, not a style
// preference:
//
//   • `.font(.system(size: <literal>` — a fixed point size does not respond to
//     Dynamic Type AT ALL. The summary hero shipped as `.font(.system(size: 56…))`.
//     The sanctioned form is `@ScaledMetric` (the PanicFlowView `reasonSize`
//     precedent) feeding `.font(.system(size: <variable>…))`, so a size that is a
//     VARIABLE is fine and a size that is a NUMBER is not — which is exactly what
//     the literal-digit match distinguishes.
//   • `.minimumScaleFactor(` — shrink-to-fit. brandkit §8 rules it out for the hero
//     in as many words ("caps its scaling at accessibility-XL and switches to a
//     stacked layout rather than shrinking"). The layout gives way, never the glyph.
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
//
// Born-green (R31.4 valve): the designed red's entire evidence value is reproduced
// FREE — the suite fires on the pre-UIR-1 bytes (verified in the pre-push Linux
// rehearsal: the old QuizSummaryView alone carries `.font(.system(size: 56`,
// `.minimumScaleFactor(0.5)`, `.lineLimit(1)` and `.buttonStyle(.plain)` — 4 hits in
// one file) and passes on the shipping bytes; the green run's own results prove the
// tests executed.
@Suite("UIR-1 · onboarding layout lint")
struct OnboardingLayoutLintTests {
    /// The directories UIR-1 rebuilt. Grow-only: UIR-2 adds the dashboard, UIR-3 the
    /// panic/slip flows, and so on until the whole of App/Sources is covered.
    private static let scopedDirectories = ["App/Sources/AgeGate", "App/Sources/Quiz"]

    /// Idioms that defeat Dynamic Type, plus the disabled-label dimming trap.
    /// Substring matches against comment-stripped code lines.
    private static let bannedIdioms: [String] = [
        ".minimumScaleFactor(",
        ".lineLimit(1)",
        ".buttonStyle(.plain)",
        ".background(.quaternary",
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
                for (index, rawLine) in source.components(separatedBy: "\n").enumerated() {
                    let code = Self.strippingComment(rawLine)
                    for idiom in Self.bannedIdioms where code.contains(idiom) {
                        violations.append("\(url.lastPathComponent):\(index + 1) uses '\(idiom)'")
                    }
                    if let literal = Self.literalFontSize(in: code) {
                        violations.append(
                            "\(url.lastPathComponent):\(index + 1) hardcodes a font size "
                            + "('.font(.system(size: \(literal)') — it will not scale with Dynamic Type; "
                            + "drive it from @ScaledMetric (Theme.type.*)"
                        )
                    }
                }
            }
        }

        // Corpus non-vacuity floor (the lexicon-gate discipline): the walk must
        // actually be seeing the onboarding view layer, not an empty directory.
        #expect(
            scannedFiles >= 12,
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
    /// These are the EXACT idioms the pre-UIR-1 `QuizSummaryView` hero carried.
    @Test func test_theLint_firesOnThePreUIR1HeroIdioms() {
        let preUIR1Hero = """
        Text(parts.amount)
            .font(.system(size: 56, weight: .bold, design: .rounded))
            .monospacedDigit()
            .minimumScaleFactor(0.5)
            .lineLimit(1)
        }
        .buttonStyle(.plain)
        """
        var hits = 0
        for rawLine in preUIR1Hero.components(separatedBy: "\n") {
            let code = Self.strippingComment(rawLine)
            for idiom in Self.bannedIdioms where code.contains(idiom) { hits += 1 }
            if Self.literalFontSize(in: code) != nil { hits += 1 }
        }
        #expect(
            hits == 4,
            "the lint must catch all four pre-UIR-1 hero idioms (fixed size, shrink, one-line cap, plain style) — it caught \(hits)"
        )
    }

    /// The sanctioned form must NOT fire: a size driven by a @ScaledMetric variable
    /// is exactly what we want people to write.
    @Test func test_theLint_acceptsScaledMetricDrivenSizes() {
        let shipping = ".font(.system(size: min(heroSize, Theme.type.heroCap), weight: .bold, design: .rounded))"
        #expect(
            Self.literalFontSize(in: shipping) == nil,
            "a @ScaledMetric-driven font size is the SANCTIONED form — the lint must not fire on it"
        )
        #expect(
            Self.bannedIdioms.allSatisfy { !shipping.contains($0) },
            "the sanctioned hero line contains no banned idiom"
        )
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

    /// Returns the literal point size when a line hardcodes one in
    /// `.font(.system(size: <digits>`; nil when the size is an expression.
    private static func literalFontSize(in code: String) -> String? {
        let needle = ".font(.system(size: "
        guard let start = code.range(of: needle) else { return nil }
        let rest = code[start.upperBound...]
        let digits = rest.prefix { $0.isNumber || $0 == "." }
        return digits.isEmpty ? nil : String(digits)
    }
}
