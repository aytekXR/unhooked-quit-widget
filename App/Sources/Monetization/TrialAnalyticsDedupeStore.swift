import Foundation

/// The cross-launch at-most-once marker for the trial_started analytics fire
/// (R24.6). Storage ruling mirrors `QuizProgressStore` (R5): app-STANDARD
/// UserDefaults, NEVER the App Group suite (not pre-unlock/widget-readable
/// data) and never anything iCloud-synced. The payload is a bare Bool — no
/// Date, no product, no price (Architect §7 pre-approval condition) — and it
/// is written ONLY in the same act as a consented, actually-sent fire, so a
/// non-consented device persists nothing at all.
///
/// Swept by `eraseEverything` step 2's infallible local clears: an
/// app-standard key is INVISIBLE to the App Group defaults sweep, so the
/// explicit `clear()` beside `quizProgressStore.clear()` is load-bearing
/// (post-erase, a fresh tracking era's trial may fire again — by design).
struct TrialAnalyticsDedupeStore {
    static let key = "analytics.trialStarted.fired.v1"

    /// Injected for tests; production default is the app-standard suite BY
    /// DESIGN (the R5 ruling) — never `UserDefaults(suiteName: appGroupID)`.
    let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasFired: Bool {
        defaults.bool(forKey: Self.key)
    }

    func markFired() {
        defaults.set(true, forKey: Self.key)
    }

    func clear() {
        defaults.removeObject(forKey: Self.key)
    }
}
