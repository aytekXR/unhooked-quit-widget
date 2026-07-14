import Foundation
import Testing
@testable import Unhooked

// UIR-0 (Session 32) unit lane — the single-source-of-truth enforcement half of
// the Theme layer (the SlipLexiconTests shape, applied to source instead of
// copy): after the UIR-0 swap, NO App/Sources view may reach for the system
// palette idioms the swap retired — every color rides `Theme` so the contrast
// registry's guarantees actually cover what renders. The ban list only GROWS.
//
// Scope: App/Sources recursively, EXCLUDING App/Sources/DesignSystem (the one
// place colors are defined). Shared/Sources and Widgets/Sources are deliberately
// OUT: widgets are luminance-only by design (brandkit §2.4) and never consume
// the app Theme. AppSwitcherPrivacyOverlay needs no exemption — its two
// byte-stability-pinned surface hexes use `Color(red:green:blue:)`, which is not
// a banned idiom (and must NOT be re-routed through Theme in UIR-0; golden
// byte-stability ruling R32.2).
//
// Comment handling: lines are stripped of `//` trailing comments (except `://`
// in URLs) and full-comment lines are skipped, so prose may still say "teal".
@Suite("UIR-0 · Theme single-source lint")
struct ThemeSourceLintTests {
    /// The retired idioms (grow-only). Each entry is a plain substring checked
    /// against comment-stripped code lines.
    private static let bannedIdioms: [String] = [
        // System hues the palette replaced (any call-site form: .fill(.teal,
        // .foregroundStyle(.teal, .tint(.teal, .background(.teal, Color.teal…)
        "(.teal", "Color.teal",
        "(.indigo", "Color.indigo",
        "(.orange", "Color.orange",
        "(.green", "Color.green",
        "(.mint", "Color.mint",
        // Raw monochromes that dodged appearance adaptation (the dark-mode
        // white-on-teal 1.99:1 defect class)
        "Color.white", "Color.black", "(.white)",
        // System label/background dynamics the content/surface tokens replaced
        ".foregroundStyle(.secondary)", ".foregroundStyle(.primary)",
        "Color.secondary", "Color.primary",
        "Color(.system", "Color(.secondarySystemBackground",
    ]

    /// Repo root from this file's compile-time path (Tests/Unit/<file> → up 3) —
    /// the PrivacyManifestTests idiom.
    private static var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    @Test func test_appSources_carryNoRetiredColorIdioms() throws {
        let sourcesRoot = Self.repoRoot.appendingPathComponent("App/Sources", isDirectory: true)
        let enumerator = try #require(
            FileManager.default.enumerator(at: sourcesRoot, includingPropertiesForKeys: nil),
            "App/Sources must be walkable from the test host"
        )

        var violations: [String] = []
        var scannedFiles = 0
        for case let url as URL in enumerator {
            guard url.pathExtension == "swift" else { continue }
            // The one sanctioned definition site.
            guard !url.path.contains("/DesignSystem/") else { continue }
            scannedFiles += 1
            let source = try String(contentsOf: url, encoding: .utf8)
            for (index, rawLine) in source.components(separatedBy: "\n").enumerated() {
                let code = Self.strippingComment(rawLine)
                for idiom in Self.bannedIdioms where code.contains(idiom) {
                    violations.append("\(url.lastPathComponent):\(index + 1) uses '\(idiom)'")
                }
            }
        }

        // Corpus non-vacuity floor (the lexicon-gate discipline): the walk must
        // actually be seeing the view layer, not an empty directory.
        #expect(scannedFiles >= 25, "the lint walked only \(scannedFiles) files — the App/Sources corpus shrank implausibly")
        #expect(
            violations.isEmpty,
            """
            retired color idioms found outside the Theme layer — route through \
            Theme tokens so the contrast registry covers what renders (R28.13 \
            by-construction; the ban list only grows):
            \(violations.joined(separator: "\n"))
            """
        )
    }

    /// Gate-gates-itself: the stripper and matcher must FIRE on the exact shapes
    /// the swap retired, and must NOT fire on prose comments or URLs.
    @Test func test_calibration_matcherFiresAndCommentsAreExempt() {
        #expect(Self.strippingComment("    .foregroundStyle(.teal)").contains("(.teal"))
        #expect(Self.strippingComment("let c = Color.white").contains("Color.white"))
        #expect(!Self.strippingComment("// the old .teal chrome").contains("(.teal"))
        #expect(!Self.strippingComment("/// prose about Color.white history").contains("Color.white"))
        #expect(Self.strippingComment("x() // trailing note re Color.white").contains("x()"))
        #expect(!Self.strippingComment("x() // trailing note re Color.white").contains("Color.white"))
        // URLs survive comment stripping (the :// guard).
        #expect(Self.strippingComment("let u = \"https://example.com\"").contains("https://example.com"))
    }

    /// Everything after the first `//` (except `://`) is comment; full-comment
    /// lines strip to nothing.
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
