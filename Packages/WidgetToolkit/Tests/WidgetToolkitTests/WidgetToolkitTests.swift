import Testing
@testable import WidgetToolkit

@Suite("WidgetToolkit package surface")
struct WidgetToolkitSurfaceTests {
    /// 1.0.0 = E6.1: the streak timeline planner (midnight/DST day rollover, stale-grace,
    /// ticking windows). WidgetToolkit stops being a walking skeleton here, so the version
    /// leaves its `0.0.1-skeleton` placeholder — semver-major for the first real API.
    /// The app target pins the same constant (Tests/Unit/WalkingSkeletonTests.swift): both
    /// move together or the billed macOS lane goes red.
    @Test("package exposes its version")
    func packageExposesEntryPoint() {
        #expect(WidgetToolkit.version == "1.1.0")
    }
}
