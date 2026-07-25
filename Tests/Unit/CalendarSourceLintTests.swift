import Foundation
import Testing
@testable import Unhooked

// S46 unit lane — the calendar single-source lint (the `ThemeSourceLintTests`
// shape, applied to date math instead of color): NO shipping source may derive a
// date component through the AMBIENT calendar.
//
// Why this is a lint and not a code review note: `Calendar.current` follows the
// device's Settings › General › Language & Region › Calendar choice, and it reads
// as Gregorian on every CI simulator and every developer machine — so a
// regression here is invisible to the whole test suite AND to a golden. It only
// surfaces on a user's device, and it surfaced as a REAL defect (S46): the age
// gate derived `currentYear` through `Calendar.current`, so on an Islamic-calendar
// device its 18-year boundary spanned ~354-day years and the youngest passer was
// 16.60 SOLAR years old — a 17+ gate admitting 16-year-olds — while on a Japanese-
// calendar device `component(.year:)` returned the ERA year (8), collapsing the
// birth-year wheel to `-112...8`.
//
// The house convention this pins was already unanimous everywhere else:
// `StreakCardModel`, `AdherenceCalculator` and `StreakTimelinePlanner` each
// construct `Calendar(identifier: .gregorian)` explicitly. The age gate was the
// single dissenting site.
//
// Scope: App/Sources + Shared/Sources + Widgets/Sources recursively — ALL shipping
// code (unlike the Theme lint, widgets are IN scope here: the timeline planner's
// day math is exactly the class this protects). Tests are out of scope: a test may
// legitimately construct `Calendar.current` to prove a helper is independent of it.
//
// Comment handling: lines are stripped of `//` trailing comments (except `://` in
// URLs) and full-comment lines skipped, so the prose above and the explanatory
// comments at the fixed sites may still name the banned idiom.
//
// Born-green by construction (R31.4): the ban's entire evidence value —
// pass-on-real-bytes over the shipping corpus AND fire-on-mutation — was
// reproduced by an executed Linux harness over these exact bytes before this file
// was pushed; the calibration test below carries the fire-on-mutation half
// permanently.
@Suite("S46 · calendar single-source lint")
struct CalendarSourceLintTests {
    /// The banned idioms (grow-only). Each entry is a plain substring checked
    /// against comment-stripped code lines.
    private static let bannedIdioms: [String] = [
        // The device's Language & Region calendar. Every date component derived
        // through it silently changes meaning per user (year length, era origin).
        "Calendar.current",
        // The same hazard, plus it mutates underneath a running process.
        "Calendar.autoupdatingCurrent",
    ]

    /// The shipping roots. Widgets are IN scope (their day math is the point);
    /// Tests/ is not (a test may name the idiom to prove independence from it).
    private static let scopedRoots = ["App/Sources", "Shared/Sources", "Widgets/Sources"]

    /// Repo root from this file's compile-time path (Tests/Unit/<file> → up 3) —
    /// the `ThemeSourceLintTests` / `PrivacyManifestTests` idiom.
    private static var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    @Test func test_shippingSources_deriveNoDateComponentFromTheAmbientCalendar() throws {
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
                    let code = Self.strippingComment(rawLine)
                    for idiom in Self.bannedIdioms where code.contains(idiom) {
                        violations.append("\(root)/\(url.lastPathComponent):\(index + 1) uses '\(idiom)'")
                    }
                }
            }
        }

        // Corpus non-vacuity floor (the account-absence-lint discipline): the walk
        // must actually be seeing the shipping tree, not an empty/moved directory.
        // 119 shipping .swift files at S46; the floor sits well below that so honest
        // deletions never trip it, but a broken walk (0) always does.
        #expect(
            scannedFiles >= 100,
            "the lint walked only \(scannedFiles) files — the shipping corpus shrank implausibly"
        )
        #expect(
            violations.isEmpty,
            """
            ambient-calendar date math found in shipping source. Derive components \
            through an EXPLICIT calendar — `Calendar(identifier: .gregorian)`, or \
            `AgeGate.calendar` on the gate — so the meaning cannot change with the \
            device's Language & Region setting (S46: the age gate admitted \
            16.60-year-olds on Islamic-calendar devices). The ban list only grows:
            \(violations.joined(separator: "\n"))
            """
        )
    }

    /// Gate-gates-itself (the `ThemeSourceLintTests` calibration precedent): the
    /// matcher must FIRE on the exact shapes the fix retired and must NOT fire on
    /// prose, so a future regression cannot pass by being written in a comment.
    @Test func test_calibration_matcherFiresAndCommentsAreExempt() {
        let offending = "        let y = Calendar.current.component(.year, from: now)"
        #expect(Self.strippingComment(offending).contains("Calendar.current"))
        #expect(Self.strippingComment("var c = Calendar.autoupdatingCurrent").contains("Calendar.autoupdatingCurrent"))
        // The sanctioned form must NOT trip the ban.
        #expect(!Self.strippingComment("let cal = Calendar(identifier: .gregorian)").contains("Calendar.current"))
        // Prose naming the idiom is exempt (this file and the fixed sites rely on it).
        #expect(!Self.strippingComment("// never Calendar.current here").contains("Calendar.current"))
        #expect(!Self.strippingComment("/// prose about Calendar.current history").contains("Calendar.current"))
        #expect(Self.strippingComment("x() // trailing note re Calendar.current").contains("x()"))
        #expect(!Self.strippingComment("x() // trailing note re Calendar.current").contains("Calendar.current"))
        // URLs survive comment stripping (the :// guard).
        #expect(Self.strippingComment("let u = \"https://example.com\"").contains("https://example.com"))
    }

    /// Everything after the first `//` (except `://`) is comment; full-comment
    /// lines strip to nothing. Copied verbatim from `ThemeSourceLintTests` — the
    /// two lints must agree on what "code" means.
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
