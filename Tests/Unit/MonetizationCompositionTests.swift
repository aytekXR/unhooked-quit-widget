import Foundation
import PaywallKit
import Testing
@testable import Unhooked

// E7.1 app half (Session 24) — the DORMANT gate as a pure, spy-checkable
// decision (R24.2): the `appID.isEmpty` fork of the TelemetryDeck precedent,
// extracted into `MonetizationComposition.makeEntitlementSource`. The
// closures are injected so this file never imports RevenueCat — the live
// wiring passes `Purchases.configure` and the real adapter; these tests pass
// counters. The docs-verified stake: purchases-ios's configure ALONE fetches
// CustomerInfo + Offerings from api.revenuecat.com and persists an anonymous
// ID — so "key absent ⇒ configure count 0" is a privacy pin, not bookkeeping.
//
// RED: the composition is inert (always the never-source, configure never
// invoked) — the key-present arm fails by design until green.

/// File-private adapter stand-in (the no-shared-fixtures convention): the
/// composition must vend exactly what `makeAdapter` builds on the live arm.
private struct SpyEntitlementSource: EntitlementSource {
    func currentSnapshot() async throws -> EntitlementSnapshot? { nil }
    func restore() async throws -> EntitlementSnapshot? { nil }
    func reset() async throws {}
}

@MainActor
@Suite("E7.1 · dormant-gate composition")
struct MonetizationCompositionTests {
    /// M9 (born-green safety pin — the shipping posture): the empty key vends
    /// the never-source and NEVER touches the configure closure.
    @Test func test_dormantKey_absent_buildsNeverSource_zeroRevenueCatConfigure() async throws {
        var configureCount = 0
        var adapterCount = 0

        let source = MonetizationComposition.makeEntitlementSource(
            apiKey: "",
            configureRevenueCat: { configureCount += 1 },
            makeAdapter: { adapterCount += 1; return SpyEntitlementSource() }
        )

        #expect(configureCount == 0, "DORMANT: the SDK is never configured — zero init, zero network")
        #expect(adapterCount == 0, "DORMANT: the adapter is never even constructed")
        #expect(source is NeverEntitlementSource, "the fallback is the never-source")
        let snapshot = try await source.currentSnapshot()
        #expect(EntitlementStateMapper.state(from: snapshot) == .never)
    }

    /// M10 (designed-red): a present key configures the SDK exactly once and
    /// vends the adapter (the operator's deliberate act flips the whole lane).
    @Test func test_dormantKey_present_configuresRevenueCatOnce_buildsAdapterSource() {
        var configureCount = 0
        var adapterCount = 0

        let source = MonetizationComposition.makeEntitlementSource(
            apiKey: "appl_test_key",
            configureRevenueCat: { configureCount += 1 },
            makeAdapter: { adapterCount += 1; return SpyEntitlementSource() }
        )

        #expect(configureCount == 1, "the ONE configure call, made before the adapter exists")
        #expect(adapterCount == 1)
        #expect(source is SpyEntitlementSource, "the live arm vends exactly what makeAdapter built")
    }
}
