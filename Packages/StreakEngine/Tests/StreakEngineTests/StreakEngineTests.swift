import Testing
@testable import StreakEngine

@Suite("StreakEngine walking skeleton")
struct StreakEngineSkeletonTests {
    @Test("package exposes its entry point")
    func packageExposesEntryPoint() {
        #expect(StreakEngine.version == "0.0.1-skeleton")
    }
}
