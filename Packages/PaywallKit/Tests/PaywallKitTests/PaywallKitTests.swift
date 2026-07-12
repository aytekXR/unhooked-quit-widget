import Testing
@testable import PaywallKit

@Suite("PaywallKit walking skeleton")
struct PaywallKitSkeletonTests {
    @Test("package exposes its entry point")
    func packageExposesEntryPoint() {
        #expect(PaywallKit.version == "1.0.0")
    }
}
