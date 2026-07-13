import Foundation

/// E9.1 (R27.6) — the alcohol withdrawal-danger notice's pure present-decision
/// (mvp feature 11: "the alcohol module shows the fixed withdrawal-danger notice
/// once, calmly"). Category-gated, GOAL-MODE-INDEPENDENT by ruling: a heavy drinker
/// REDUCING faces the same abrupt-cessation risk as one quitting (the Alex/reduce
/// persona, mvp feature 4), so `.reduce` triggers it too. "Once" = once EVER
/// app-wide (`alreadyShown` reads the AppSettings stamp; erase sweeps the row, so a
/// post-erase user is a fresh user and sees it again — fresh-install honesty).
///
/// Pure Foundation — Linux-harnessed ×3 host timezones (standing rule #4). The
/// stamp itself lives on `AppSettings` behind the repository's injected clock;
/// this policy holds NO clock and NO storage.
enum AlcoholNoticePolicy {
    /// True exactly when the notice should present: an alcohol goal exists (either
    /// goal mode) and the once-stamp has never been written.
    static func shouldShow(habitCategory: HabitCategory, goalMode: GoalMode, alreadyShown: Bool) -> Bool {
        habitCategory == .alcohol && !alreadyShown
    }
}
