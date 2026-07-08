import Testing
@testable import StreakEngine

@Suite("StreakEngine version marker")
struct StreakEngineVersionTests {
    @Test("version marker matches the released tag")
    func versionMatchesReleasedTag() {
        // Pinned to the annotated git tag (streakengine-v1.0.0): a consumer reading
        // StreakEngine.version at runtime must see the version they depend on.
        #expect(StreakEngine.version == "1.0.0")
    }
}
