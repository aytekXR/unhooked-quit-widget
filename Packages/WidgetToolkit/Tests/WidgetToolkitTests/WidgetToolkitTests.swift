import Testing
@testable import WidgetToolkit

@Suite("WidgetToolkit walking skeleton")
struct WidgetToolkitSkeletonTests {
    @Test("package exposes its entry point")
    func packageExposesEntryPoint() {
        #expect(WidgetToolkit.version == "0.0.1-skeleton")
    }
}
