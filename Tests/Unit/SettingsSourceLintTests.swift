import Foundation
import Testing
@testable import Ballast

// S50 unit lane — the height-capped-container lint (the `ThemeSourceLintTests` /
// `CalendarSourceLintTests` shape, applied to LAYOUT): no shipping screen may render text
// inside a container whose height iOS controls.
//
// Why this is a lint and not a code-review note. Two mechanisms in this app clipped text
// at accessibility sizes, and BOTH were invisible to the free lanes and to every golden:
//
//   * a `List` ROW is height-constrained, so a wrapping title inside one truncates. This
//     is why the SHORT icon-picker labels ("Default", "Calendar style") passed the S40
//     audits on the very same screen where the longer "Support & resources" label failed —
//     and why five runs of alternative row shapes ping-ponged between `.textClipped` and
//     "Dynamic Type partially unsupported" without ever converging.
//   * a `Section(footer:)` SLOT has its height capped by iOS, so the long haptic-pacer
//     caption clipped at AX5 no matter what the text itself declared (S39). Adding
//     `.fixedSize` to it did not help (S40 run 1), because the constraint was never the
//     text's.
//
// The cost of learning that was seven billed macOS runs across S38, S39 and S40, three
// added-then-reverted audit legs, and one item parked as "Mac-gated, needs Xcode's
// Accessibility Inspector". ME-7 (S50) rebuilt the settings screen with no `List` at all,
// which retires the class by construction — and this lint is what keeps it retired.
//
// It is deliberately stronger than an audit leg. An audit checks one render of one mount:
// the `UITEST_SETTINGS` mount injects no repository, so the Breathing caption — the exact
// string that clipped in S39 — is not even in its render tree. A lint checks every line of
// every shipping file, including the ones no lane mounts.
//
// Scope: App/Sources + Shared/Sources + Widgets/Sources, recursively. Tests are out of
// scope. GROW-ONLY, and amendable only with evidence: a future session that genuinely
// needs a `List` (cell recycling on a long collection, say) may lift the ban for a named
// surface — but it owes an audit leg that renders that surface's longest string at AX5
// first, because that is the evidence nobody had in S38–S40.
//
// Born-green by construction (R31.4): the ban's entire evidence value — pass-on-real-bytes
// over the shipping corpus AND fire-on-mutation — was reproduced by an executed Linux
// harness over these exact bytes before this file was pushed; the calibration test below
// carries the fire-on-mutation half permanently.
@Suite("S50 · height-capped container lint")
struct SettingsSourceLintTests {
    /// The banned idioms (grow-only), as REGEXES checked against comment-stripped code
    /// lines. Regex rather than plain substring for one measured reason: the executed
    /// born-green harness caught `Section(` matching this very file's sibling method names
    /// — `discreetModeSection(repository)`, `breathingSection(...)`,
    /// `yourPlanSection(...)` — which would have reddened the unit lane on a billed run.
    /// `\b` before the type name is what distinguishes the SwiftUI container from any
    /// identifier that merely ends in the same word.
    private static let bannedIdioms: [(name: String, pattern: String)] = [
        // The container whose ROWS cap height. `\s*[({]` covers both the
        // trailing-closure and data-driven spellings.
        (name: "List container", pattern: #"\bList\s*[({]"#),
        // The container whose `header:`/`footer:` SLOTS cap height.
        (name: "Section container", pattern: #"\bSection\s*[({]"#),
        // List-only modifiers. Their presence means a List is being styled somewhere,
        // even if the container itself is spelled in a way the two entries above miss.
        (name: "listRowBackground modifier", pattern: #"\.listRowBackground\("#),
        (name: "scrollContentBackground modifier", pattern: #"\.scrollContentBackground\("#),
    ]

    /// True when a comment-stripped line trips any banned pattern.
    private static func firstViolation(in code: String) -> String? {
        for idiom in Self.bannedIdioms
        where code.range(of: idiom.pattern, options: .regularExpression) != nil {
            return idiom.name
        }
        return nil
    }

    /// The shipping roots — the `CalendarSourceLintTests` set, minus the SwiftPM packages
    /// (pure logic, no SwiftUI, so a layout ban there would be noise).
    private static let scopedRoots = ["App/Sources", "Shared/Sources", "Widgets/Sources"]

    /// Repo root from this file's compile-time path (Tests/Unit/<file> → up 3) —
    /// the `ThemeSourceLintTests` / `CalendarSourceLintTests` idiom.
    private static var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    @Test func test_shippingSources_renderNoTextInsideAHeightCappedContainer() throws {
        var violations: [String] = []
        var scannedFiles = 0

        for root in Self.scopedRoots {
            let sourcesRoot = Self.repoRoot.appendingPathComponent(root, isDirectory: true)
            let enumerator = try #require(
                FileManager.default.enumerator(at: sourcesRoot, includingPropertiesForKeys: nil),
                "\(root) must be walkable from the test host"
            )
            for case let url as URL in enumerator {
                guard url.pathExtension == "swift" else { continue }
                scannedFiles += 1
                let source = try String(contentsOf: url, encoding: .utf8)
                for (index, rawLine) in source.components(separatedBy: "\n").enumerated() {
                    if let idiom = Self.firstViolation(in: Self.strippingComment(rawLine)) {
                        violations.append("\(root)/\(url.lastPathComponent):\(index + 1) uses a \(idiom)")
                    }
                }
            }
        }

        // Corpus non-vacuity floor (the account-absence-lint discipline): the walk must
        // actually be seeing the shipping tree, not an empty or moved directory. 123
        // shipping .swift files across these three roots at S50; the floor sits well below
        // that so honest deletions never trip it, but a broken walk (0) always does.
        #expect(
            scannedFiles >= 100,
            "the lint walked only \(scannedFiles) files — the shipping corpus shrank implausibly"
        )
        #expect(
            violations.isEmpty,
            """
            a height-capped container was found in shipping source. iOS controls the height \
            of a `List` row and of a `Section` header/footer slot, so text inside one \
            truncates at accessibility sizes no matter what the text declares — and \
            neither the free lanes nor a golden can see it. Compose the screen the way \
            `DiscreetSettingsView` and `StreakDetailView` do: a ScrollView of \
            `themedCard` sections, every wrapping `Text` carrying \
            `.fixedSize(horizontal: false, vertical: true)`, and touch targets built from \
            PADDING rather than a height floor. S38-S40 spent seven billed runs learning \
            this. The ban list only grows:
            \(violations.joined(separator: "\n"))
            """
        )
    }

    /// Gate-gates-itself (the `ThemeSourceLintTests` calibration precedent): the matcher
    /// must FIRE on the exact shapes ME-7 retired, must NOT fire on the sanctioned
    /// replacement, and must NOT fire on prose — so a regression cannot slip through by
    /// being written in a comment, and this file's own header stays legal.
    @Test func test_calibration_matcherFiresAndCommentsAreExempt() {
        // Every shape ME-7 retired must fire.
        for line in [
            "            List {",
            "        List(quits, id: \\.id) { quit in",
            "            Section {",
            "        Section(header: h) {",
            "        .listRowBackground(Theme.color.surfaceRaised.color)",
            "        .scrollContentBackground(.hidden)",
        ] {
            #expect(
                Self.firstViolation(in: Self.strippingComment(line)) != nil,
                "a retired shape slipped past the matcher: \(line)"
            )
        }

        // Nothing sanctioned may fire. The first three entries are the exact false
        // positives the executed born-green harness caught against a plain-substring
        // matcher — an identifier that merely ENDS in "Section" is not a Section, and a
        // copy table's `footer` property is not a Section slot (`SummaryCopy`,
        // `AgeGateCopy` and `SummaryPresentation` each carry one).
        for line in [
            "                        discreetModeSection(repository)",
            "    private func breathingSection(_ repository: QuitRepository) -> some View {",
            "                        yourPlanSection(repository)",
            "    var footer: String",
            "        footer: \"Steady beats perfect.\",",
            "        ScrollView(.vertical) {",
            "            VStack(alignment: .leading, spacing: Theme.space.s6) {",
            "        .themedCard()",
            "        .scrollBounceBehavior(.basedOnSize)",
            "        .themedScreenSurface()",
        ] {
            #expect(
                Self.firstViolation(in: Self.strippingComment(line)) == nil,
                "sanctioned line tripped the matcher: \(line)"
            )
        }

        // Prose naming an idiom is exempt — this file's own header depends on it.
        #expect(Self.firstViolation(in: Self.strippingComment("// the old List { } shell clipped")) == nil)
        #expect(Self.firstViolation(in: Self.strippingComment("/// Section(footer:) capped its height")) == nil)
        #expect(Self.strippingComment("x() // note re List {").contains("x()"))
        #expect(Self.firstViolation(in: Self.strippingComment("x() // note re List {")) == nil)

        // URLs survive comment stripping (the :// guard).
        #expect(Self.strippingComment("let u = \"https://example.com\"").contains("https://example.com"))
    }

    /// Everything after the first `//` (except `://`) is comment; full-comment lines strip
    /// to nothing. Copied verbatim from `ThemeSourceLintTests` / `CalendarSourceLintTests`
    /// — every lint in this project must agree on what "code" means.
    private static func strippingComment(_ line: String) -> String {
        var result = ""
        var previous: Character = " "
        var index = line.startIndex
        while index < line.endIndex {
            let character = line[index]
            if character == "/", line.index(after: index) < line.endIndex,
               line[line.index(after: index)] == "/", previous != ":" {
                break
            }
            result.append(character)
            previous = character
            index = line.index(after: index)
        }
        return result
    }
}
