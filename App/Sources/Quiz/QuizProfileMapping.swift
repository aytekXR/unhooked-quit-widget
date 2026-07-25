import Foundation

/// E5.2 — the pure answers→quit-fields derivation (Architect SHOULD-1): the
/// privacy-sensitive mapping is Foundation-only so the Linux harness verifies the
/// exact shipping bytes before any billed macOS run. The repository owns WHERE
/// these land (SwiftData); this owns WHAT they are.
///
/// Config-free by design (Architect MUST-FIX 2): the motivations step's choiceIDs
/// ARE the display words (id == label in the audited table), so the mapping never
/// needs the copy table to recover the user's verbatim words — and the panic
/// ReasonsView renders exactly what the user picked, in their order.
struct QuizQuitDraft: Equatable, Sendable {
    var habitCategory: HabitCategory
    var customLabel: String?
    var goalMode: GoalMode
    var weeklySpend: Decimal
    var weeklyAllowance: Int?
    var triggers: [String]
    var motivations: [String]
}

enum QuizProfileMapping {
    /// Derives the quit's field set from raw quiz answers. Tolerant in the safe
    /// direction on every field (a degraded or partial answer set still yields a
    /// valid quit — AC12): unknown habit → .custom, unknown goal → .quit,
    /// unparseable spend → 0, allowance only when reduce, custom label only when
    /// the habit IS custom (AC8 — never for non-custom even if a stray answer
    /// exists), triggers and motivations verbatim in the user's order.
    static func draft(from answers: [QuizAnswer]) -> QuizQuitDraft {
        func answer(_ stepID: String) -> QuizAnswer? {
            answers.first { $0.stepID == stepID }
        }

        let habit = answer("habit")?.choiceIDs.first
            .flatMap(HabitCategory.init(rawValue:)) ?? .custom
        let goal = answer("goal")?.choiceIDs.first
            .flatMap(GoalMode.init(rawValue:)) ?? .quit

        let trimmedName = answer("customName")?.freeText?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let customLabel: String? = (habit == .custom && trimmedName?.isEmpty == false)
            ? trimmedName : nil

        // S47/R47.1: the field is a `.decimalPad`, whose separator iOS renders from
        // the device's Language & Region setting — so the raw string may legitimately
        // read "26,50". The old bare `Decimal(string:)`/`Int(_:)` accepted a period
        // ONLY and silently truncated ("12,50" → 12, "0,50" → 0, "10,5" → nil), and
        // the result is persisted with no edit path. `DecimalInputParser` reads both
        // notations; parse failures still fall to the safe 0 / nil.
        let spend = answer("spend")?.freeText.flatMap { DecimalInputParser.decimal(from: $0) } ?? 0
        let allowance: Int? = goal == .reduce
            ? answer("allowance")?.freeText.flatMap { DecimalInputParser.int(from: $0) } : nil

        return QuizQuitDraft(
            habitCategory: habit,
            customLabel: customLabel,
            goalMode: goal,
            weeklySpend: spend,
            weeklyAllowance: allowance,
            triggers: answer("triggers")?.choiceIDs ?? [],
            motivations: answer("motivations")?.choiceIDs ?? []
        )
    }
}
