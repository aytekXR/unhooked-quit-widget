import Foundation
import Testing
@testable import Ballast

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

    // ══════════════════════════════════════════════════════════════════════════
    // MARK: - S61 · the incompressible-floor rule (the R60.2 shape)
    // ══════════════════════════════════════════════════════════════════════════
    //
    // R60.2 made a legally-required 17+ gate IMPASSABLE at AX5 for the entire life
    // of the screen, and the mechanism was structural rather than typographic:
    //
    //   `OnboardingScaffold` lays out `VStack { header; ScrollView { content };
    //   actions }`. TWO children there are flexible — the ScrollView and, because
    //   `UIPickerView` reports a flexible height, the year wheel. At AX5 the pinned
    //   action zone's fixed children over-subscribe the space and SwiftUI takes it
    //   out of the flexible ones. The wheel lost, silently and TOTALLY: zero height,
    //   no control to pick a year, a CTA that could never enable.
    //
    // **Why this is a lint and not only an audit leg.** S61 adds AX5 legs to the
    // accessibility audit, and they are the broad net — but an audit leg only ever
    // sees the surfaces it mounts, and it costs a launch on the priciest runner in
    // the matrix. A source lint sees EVERY file for free, on every lane, including
    // Linux. The wheel that broke was on a surface that had an audit leg and a
    // funnel smoke and still shipped the defect for the life of the screen, because
    // both mounted at the default content size. This rule needs no size at all: a
    // wheel with no floor is wrong whether or not anything has rendered it yet.
    //
    // **The rule is unconditional, deliberately.** It does not ask whether the
    // picker sits in a pinned zone, because the two containers a wheel can land in
    // are the two that punish it: outside a ScrollView it is the compressible child
    // (R60.2), and inside one it fights its ancestor for the scroll gesture — the
    // fight `OnboardingScaffold`'s own doc comment names as the reason the picker
    // lives in `actions:` at all. A `.wheel` picker always wants an explicit floor,
    // so the rule has no exemption to rot.
    //
    // **Scope is APP-WIDE**, unlike the idiom rule above, which is scoped to the
    // directories UIR rebuilt. There is exactly ONE wheel picker in the app today,
    // so the rule is worth little as a finding and everything as a ratchet: the next
    // one is written by someone who has not read this file.

    /// Walked in full — this rule earns its keep on files nobody has written yet.
    private static let floorRuleDirectory = "App/Sources"

    /// A `.wheel` picker reports a FLEXIBLE height, so it must state a floor or a
    /// parent under pressure will compress it — to zero, as R60.2 proved.
    @Test func test_everyWheelPicker_carriesAnIncompressibleFloor() throws {
        var violations: [String] = []
        var scannedFiles = 0
        var wheelsSeen = 0

        let root = Self.repoRoot.appendingPathComponent(
            Self.floorRuleDirectory, isDirectory: true
        )
        let enumerator = try #require(
            FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil),
            "\(Self.floorRuleDirectory) must be walkable from the test host"
        )
        for case let url as URL in enumerator {
            guard url.pathExtension == "swift" else { continue }
            scannedFiles += 1
            let source = try String(contentsOf: url, encoding: .utf8)
            wheelsSeen += Self.wheelPickerChains(in: source).count
            violations += Self.scanPickerFloors(source, in: url.lastPathComponent)
        }

        // Corpus non-vacuity floor (the lexicon-gate discipline), twice over: the
        // walk must be seeing the app's view layer, AND it must still be finding a
        // wheel to judge. A rule that silently stops matching anything is a rule
        // that passes forever — which is how R60.2 survived two lanes.
        #expect(
            scannedFiles >= 100,
            "the floor lint walked only \(scannedFiles) app files — the corpus shrank implausibly"
        )
        #expect(
            wheelsSeen >= 1,
            """
            the floor lint found NO `.wheel` picker in \(Self.floorRuleDirectory). The age \
            gate's year wheel is the one this rule was written for, so either it was \
            removed (in which case delete this rule deliberately) or the chain scanner \
            stopped matching it — which would make this whole suite vacuously green.
            """
        )
        #expect(
            violations.isEmpty,
            """
            A `.wheel` picker with no height floor. It reports a FLEXIBLE height, so \
            a parent under pressure will compress it — R60.2 compressed the age gate's \
            to ZERO at AX5 and made a legally-required 17+ gate impassable. Give it \
            `.frame(minHeight:)`; do not weaken this assertion:
            \(violations.joined(separator: "\n"))
            """
        )
    }

    /// The gate must gate itself. This is the EXACT shipping chain with the one line
    /// the R60.2 fix added removed again — i.e. the bytes that made the gate
    /// impassable. If this stops firing, the rule has stopped protecting anything.
    @Test func test_theFloorLint_firesOnThePreFixAgeGateWheel() {
        let preFixWheel = """
        Picker(copy.yearLabel, selection: $model.selectedBirthYear) {
            Text(verbatim: "—").tag(Int?.none)
            ForEach(model.selectableYears.reversed(), id: \\.self) { year in
                Text(verbatim: String(year)).tag(Int?.some(year))
            }
        }
        .pickerStyle(.wheel)
        .accessibilityIdentifier("ageGate.yearPicker")
        """
        #expect(
            Self.scanPickerFloors(preFixWheel, in: "fixture").count == 1,
            "the pre-R60.2 wheel — flexible height, no floor — must fire exactly once"
        )
    }

    /// The shipping form must NOT fire, and the multi-line trailing closure is the
    /// part that makes this non-trivial: the modifier chain resumes AFTER the
    /// picker's content closure closes, so a scanner that ends the chain at the
    /// first non-`.` line would never see `.frame(minHeight:)` and would fail the
    /// whole app lane on correct code.
    @Test func test_theFloorLint_acceptsTheShippingWheel() {
        let shippingWheel = """
        Picker(copy.yearLabel, selection: $model.selectedBirthYear) {
            Text(verbatim: "—").tag(Int?.none)
            ForEach(model.selectableYears.reversed(), id: \\.self) { year in
                Text(verbatim: String(year)).tag(Int?.some(year))
            }
        }
        .pickerStyle(.wheel)
        .frame(minHeight: Self.pickerMinHeight)
        .accessibilityIdentifier("ageGate.yearPicker")
        """
        #expect(
            Self.scanPickerFloors(shippingWheel, in: "fixture").isEmpty,
            "the shipping wheel carries `.frame(minHeight:)` — the lint must not fire on it"
        )
    }

    /// False-positive probe (the S58 rule: every new lint entry needs one, not just
    /// a born-green run). A NON-wheel picker has an intrinsic height and is not the
    /// compressible child, so the rule must leave it alone — otherwise the next
    /// author's `.segmented` picker fails a lane for a defect it cannot have.
    @Test func test_theFloorLint_ignoresPickersThatAreNotWheels() {
        let segmented = """
        Picker("Mode", selection: $mode) {
            Text("A").tag(Mode.a)
            Text("B").tag(Mode.b)
        }
        .pickerStyle(.segmented)
        """
        #expect(
            Self.scanPickerFloors(segmented, in: "fixture").isEmpty,
            "a segmented picker has an intrinsic height — the floor rule must not fire on it"
        )

        // And prose ABOUT the idiom must not fire either: `AgeGateView`'s own header
        // comment says "the wheel stays a wheel (`.pickerStyle(.wheel)` …)", which a
        // comment-blind scanner would read as a second, floorless wheel.
        let proseOnly = """
        /// - the wheel stays a wheel (`.pickerStyle(.wheel)` — the funnel smoke drives it
        ///   by value, so a floorless one would be a defect)
        """
        #expect(
            Self.scanPickerFloors(proseOnly, in: "fixture").isEmpty,
            "a comment discussing `.pickerStyle(.wheel)` is not a picker — the scanner strips comments"
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

    /// A floorless `.wheel` picker, per source. One violation per offending chain.
    private static func scanPickerFloors(_ source: String, in fileName: String) -> [String] {
        wheelPickerChains(in: source).compactMap { chain in
            guard !chain.lines.contains(where: { $0.contains(".frame(minHeight:") }) else {
                return nil
            }
            return "\(fileName):\(chain.line) declares `.pickerStyle(.wheel)` with no "
                + "`.frame(minHeight:)`. A wheel reports a FLEXIBLE height, so a parent "
                + "under pressure compresses it — R60.2 compressed the age gate's to ZERO "
                + "at AX5 and a legally-required 17+ gate could not be completed."
        }
    }

    /// Every `.wheel` picker's modifier chain, with the 1-based line its `Picker(`
    /// opened on.
    ///
    /// **The trailing closure is the whole difficulty**, and getting it wrong fails
    /// in the expensive direction. A `Picker` carries a multi-line content closure,
    /// so its modifiers resume AFTER that closure closes:
    ///
    ///     Picker(…) {          ← chain opens, brace depth 1
    ///         Text(…)          ← inside the closure, not a modifier
    ///     }                    ← depth back to 0
    ///     .pickerStyle(.wheel) ← the chain continues HERE
    ///     .frame(minHeight: …) ← …and the floor is only visible past that point
    ///
    /// A scanner that ends the chain at the first non-`.` line (the `Image(` rule
    /// above does exactly that, correctly, because a glyph has no content closure)
    /// would never reach the floor and would fail the app lane on CORRECT code. So
    /// this one tracks brace depth: a line belongs to the chain while it is inside
    /// the closure, or is a `.modifier`, or is blank/comment-only.
    ///
    /// KNOWN LIMIT, stated rather than discovered later: brace counting is literal,
    /// so a `{` or `}` inside a string literal in a picker's closure would skew the
    /// depth. Nothing in the app does that, and the non-vacuity `#expect` above fires
    /// if this ever stops matching the wheel it was written for.
    private static func wheelPickerChains(
        in source: String
    ) -> [(line: Int, lines: [String])] {
        var chains: [(line: Int, lines: [String])] = []
        var openedAt = 0
        var current: [String]?
        var depth = 0

        func close() {
            guard let chain = current else { return }
            if chain.contains(where: { $0.contains(".pickerStyle(.wheel)") }) {
                chains.append((openedAt, chain))
            }
            current = nil
            depth = 0
        }

        for (index, rawLine) in source.components(separatedBy: "\n").enumerated() {
            let code = strippingComment(rawLine)
            let trimmed = code.trimmingCharacters(in: .whitespaces)

            if current == nil {
                guard code.contains("Picker(") else { continue }
                openedAt = index + 1
                current = [code]
                depth = braceDelta(code)
                continue
            }

            let depthBeforeThisLine = depth
            depth += braceDelta(code)

            // Inside the content closure, a modifier, or blank/comment-only: keep it.
            if depthBeforeThisLine > 0 || trimmed.hasPrefix(".") || trimmed.isEmpty {
                current?.append(code)
                continue
            }

            // Anything else is the next statement — the chain ended before it, and
            // that statement may itself open the next picker.
            close()
            if code.contains("Picker(") {
                openedAt = index + 1
                current = [code]
                depth = braceDelta(code)
            }
        }
        close() // a chain running to end-of-file still counts
        return chains
    }

    /// Net brace balance of one comment-stripped line.
    private static func braceDelta(_ code: String) -> Int {
        code.filter { $0 == "{" }.count - code.filter { $0 == "}" }.count
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
