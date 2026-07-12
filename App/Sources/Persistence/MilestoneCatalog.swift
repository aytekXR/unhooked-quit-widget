import Foundation
import StreakEngine

/// The bundled milestone tables (`App/Resources/Content/milestones.json` — ADR-9
/// versioned static content; E6.2 is its consuming epic: the widget feed carries each
/// quit's ladder as elapsed-hour offsets). Decoding follows the QuizConfig `_meta`
/// precedent: the audit note is free-text review context and must never enter any
/// scanned corpus, so only the category tables are decoded.
///
/// The widget feed consumes HOURS ONLY (§10: titles/bodies are copy and never reach
/// the pre-unlock-readable file); the dashboard (E9) becomes the titles' first
/// renderer. A missing or undecodable file degrades to empty ladders — the milestone
/// bar simply does not render (never a fabricated target).
struct MilestoneCatalog: Sendable {
    let tables: [String: MilestoneTable]

    static let empty = MilestoneCatalog(tables: [:])

    /// Loaded once — the writer maps ladders on every rebuild and the bundle never
    /// changes mid-process.
    static let shipping = loadShipping() ?? .empty

    static func loadShipping(bundle: Bundle = .main) -> MilestoneCatalog? {
        guard let url = bundle.url(forResource: "milestones", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(CategoryTables.self, from: data)
        else { return nil }
        return MilestoneCatalog(tables: decoded.tables)
    }

    /// The quit's ladder as elapsed-hour offsets, ascending. Unknown category or no
    /// table ⇒ empty (no bar, no crossing entries — never a guess).
    func hours(for category: HabitCategory) -> [Int] {
        (tables[category.rawValue]?.milestones.map(\.afterHours) ?? []).sorted()
    }

    /// Dynamic-key decode of `{"_meta": …, "<category>": MilestoneTable, …}`, skipping
    /// `_meta` (its free-text audit note must never be decoded — the QuizConfig rule).
    private struct CategoryTables: Decodable {
        let tables: [String: MilestoneTable]

        private struct Key: CodingKey {
            let stringValue: String
            let intValue: Int? = nil
            init?(stringValue: String) { self.stringValue = stringValue }
            init?(intValue: Int) { nil }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Key.self)
            var decoded: [String: MilestoneTable] = [:]
            for key in container.allKeys where key.stringValue != "_meta" {
                decoded[key.stringValue] = try container.decode(MilestoneTable.self, forKey: key)
            }
            tables = decoded
        }
    }
}
