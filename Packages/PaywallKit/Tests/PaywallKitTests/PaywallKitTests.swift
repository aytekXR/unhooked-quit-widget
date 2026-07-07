import Testing
@testable import PaywallKit

@Suite("PaywallKit walking skeleton")
struct PaywallKitSkeletonTests {
    @Test("package exposes its entry point")
    func packageExposesEntryPoint() {
        #expect(PaywallKit.version == "0.0.1-skeleton")
    }
}
