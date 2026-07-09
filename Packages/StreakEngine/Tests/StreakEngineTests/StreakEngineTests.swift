import Testing
@testable import StreakEngine

@Suite("StreakEngine version marker")
struct StreakEngineVersionTests {
    @Test("version marker matches the released tag")
    func versionMatchesReleasedTag() {
        // Pinned to the annotated git tag (streakengine-v1.2.0): a consumer reading
        // StreakEngine.version at runtime must see the version they depend on. 1.2.0
        // adds the ADR-7 healing re-anchor (`healFrozenStreak`, freeze-then-resume) —
        // additive, defaulted, semver-minor.
        #expect(StreakEngine.version == "1.2.0")
    }
}
