import Foundation

/// E5.2 — the quiz resume checkpoint (architecture §7: an interrupted quiz resumes
/// at the same step; the funnel is the business — never lose a user at step 9).
struct QuizProgress: Codable, Equatable, Sendable {
    /// The step to resume ON (the current step AFTER the last committed advance).
    var currentStepID: String
    /// The in-progress answers, visible order. This is the ONE sanctioned place
    /// in-progress quiz free text (custom habit name, spend) persists — see the
    /// storage ruling on `QuizProgressStore`.
    var answers: [QuizAnswer]
}

/// Storage ruling (R5 + Architect MUST-FIX, Session 17): app-STANDARD UserDefaults,
/// NEVER the App Group suite (§10: App Group content is readable pre-unlock for
/// lock-screen rendering, and this checkpoint may hold the custom habit name and
/// free text) and never anything iCloud-synced (no NSUbiquitousKeyValueStore; an
/// abandoned quiz must leave no synced residue). Cleared on completion; swept by
/// `eraseEverything` (relaunch = fresh install).
struct QuizProgressStore {
    static let key = "quiz.progress.v1"

    /// Injected for tests; production default is the app-standard suite BY DESIGN
    /// (the whole point of R5) — never `UserDefaults(suiteName: appGroupID)`.
    let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> QuizProgress? {
        guard let data = defaults.data(forKey: Self.key) else { return nil }
        return try? JSONDecoder().decode(QuizProgress.self, from: data)
    }

    func save(_ progress: QuizProgress) {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        defaults.set(data, forKey: Self.key)
    }

    func clear() {
        defaults.removeObject(forKey: Self.key)
    }
}
