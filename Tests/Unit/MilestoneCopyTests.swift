import Foundation
import Testing
@testable import Unhooked

// E9.2 unit lane — the milestones content-table audit (implementation-plan §E9.2;
// test-suite §1.1 test 12: "content-table audit as a test"). BOTH tests are
// BORN-GREEN permanent gates by design (R27.13): milestones.json has shipped with
// "commonly reported" framing on every body since S21; the value here is the
// PERMANENT CI gate (Epic 9 DoD: "banned-lexicon tests permanent in CI") plus the
// in-test matcher pins that keep the gate non-vacuous. The shipping bundled file is
// the fixture, never a copy (§3.2). No production Milestones model exists or may be
// added for this audit — the tests read the JSON directly (PM fence, R27.13).
//
// Matcher discipline (burn-critic REPRODUCED, R27.13): the banned list is
// PHRASE-ANCHORED — bare experiential vocabulary ("breathing", "sleep", "energy")
// is the SANCTIONED register mvp §7 allows under "commonly reported" framing, and a
// naive token like "breathing" false-fires on the shipping vape table. Word tokens
// use word boundaries so "clearer" never trips and "healthy" never matches "heal".

@Suite("E9.2 · milestone content audit")
struct MilestoneCopyTests {

    // MARK: - The banned medical-claim lexicon (only grows; foundation-floor pinned)

    /// Phrase tokens — substring match over the normalized text.
    private static let bannedPhrases: [String] = [
        "cures", "cure your", "reverses", "reverse the", "heals your",
        "your lungs heal", "lungs heal", "will heal", "clinically proven",
        "detox", "flush out toxins", "cleanse", "repairs your",
        "guaranteed", "prevents cancer", "reduces your risk", "boosts your immune",
    ]

    /// Bare words — word-boundary match (a substring would false-positive:
    /// "clearer" ∌ \bclinical\b, "healthy" ∌ \bheal\b).
    private static let bannedWords: [String] = [
        "cure", "heal", "reverse", "toxin", "toxins", "disease",
        "clinical", "clinically", "medically", "diagnose", "diagnosis",
    ]

    /// The frozen foundation set (the E4.2 only-grows pin): removing a token is a
    /// deliberate two-place edit, never a drive-by.
    private static let foundationFloor: Set<String> = [
        "cures", "reverses", "your lungs heal", "clinically proven",
        "cure", "heal", "reverse", "toxin", "disease", "diagnose",
    ]

    /// Casefold + diacritic-fold + whitespace collapse (the SlipLexicon matcher,
    /// verbatim technique), then phrase-substring + word-boundary scan.
    private func firstMedicalViolation(in text: String) -> String? {
        let folded = text
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US"))
            .lowercased()
        let normalized = folded.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        for phrase in Self.bannedPhrases where normalized.contains(phrase) {
            return phrase
        }
        for word in Self.bannedWords
        where normalized.range(of: "\\b\(word)\\b", options: .regularExpression) != nil {
            return word
        }
        return nil
    }

    // MARK: - Shipping-file access (the real bundled bytes, §3.2)

    private func milestonesRoot() throws -> [String: Any] {
        let url = try #require(
            Bundle.main.url(forResource: "milestones", withExtension: "json"),
            "the shipping milestones.json must be bundled (ships since S21)"
        )
        return try #require(
            try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any]
        )
    }

    /// Every (title, body) pair across every category table.
    private func allRows(_ root: [String: Any]) throws -> [(title: String, body: String)] {
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

    // MARK: - Plan-named test · schema (key-SET semantics)

    @Test func test_milestonesJSON_matchesSchema() throws {
        let root = try milestonesRoot()

        // One table per launch category — exact set (a new category is a deliberate
        // content PR that re-audits this file, per §3.2).
        #expect(
            Set(root.keys).subtracting(["_meta"])
                == ["vape", "porn", "alcohol", "weed", "doomscroll", "custom"]
        )

        for key in Set(root.keys).subtracting(["_meta"]) {
            let table = try #require(root[key] as? [String: Any], "table \(key)")
            #expect(Set(table.keys) == ["category", "milestones"], "table \(key)")
            #expect(table["category"] as? String == key, "table \(key) names itself")

            let milestones = try #require(table["milestones"] as? [[String: Any]])
            #expect(!milestones.isEmpty, "table \(key) must carry milestones")
            for row in milestones {
                #expect(Set(row.keys) == ["afterHours", "title", "body"], "row in \(key)")
                #expect(row["afterHours"] is NSNumber, "afterHours is a number (boundary-inclusive hours)")
                #expect((row["title"] as? String)?.isEmpty == false)
                #expect((row["body"] as? String)?.isEmpty == false)
            }
        }
    }

    // MARK: - Plan-named test · the medical-claim lexicon gate

    @Test func test_milestoneCopy_containsNoMedicalClaimLexicon() throws {
        let rows = try allRows(try milestonesRoot())

        // Non-vacuity floor: a decode/collector collapse cannot pass silently.
        #expect(rows.count >= 40, "the shipping table carries 40+ milestones (43 at S27)")

        for row in rows {
            #expect(
                firstMedicalViolation(in: row.title) == nil,
                "medical-claim vocabulary in a milestone title: \(row.title)"
            )
            #expect(
                firstMedicalViolation(in: row.body) == nil,
                "medical-claim vocabulary in a milestone body: \(row.body)"
            )
            // The mvp §7 release-gate row, as a permanent sub-pin: milestones say
            // "commonly reported" — every body carries the framing marker.
            #expect(
                row.body.lowercased().contains("commonly reported"),
                "a milestone body without the 'commonly reported' framing: \(row.body)"
            )
        }

        // The matcher is alive (positive pins) and calibrated (negative pins) — the
        // gate cannot rot into vacuity while looking green.
        #expect(firstMedicalViolation(in: "This cures your addiction.") != nil)
        #expect(firstMedicalViolation(in: "Reverses lung damage.") != nil)
        #expect(firstMedicalViolation(in: "By day three your lungs heal.") != nil)
        #expect(firstMedicalViolation(in: "Clinically proven results.") != nil)
        #expect(firstMedicalViolation(in: "Commonly reported: better sleep and easier breathing.") == nil)
        #expect(firstMedicalViolation(in: "Three days in — clearer, healthier mornings.") == nil)

        // Only-grows: the live lexicon is a superset of the frozen foundation floor
        // (the E4.2 two-place-edit discipline).
        #expect(Set(Self.bannedPhrases).union(Self.bannedWords).isSuperset(of: Self.foundationFloor))
    }
}
