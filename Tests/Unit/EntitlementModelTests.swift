import Foundation
import PaywallKit
import Testing
@testable import Unhooked

// E7.1 app half (Session 24) — the app-wide entitlement model + the pure
// summary-CTA routing decision (R24.2/R24.10). `FakeEntitlementProvider`
// lives HERE, file-private, conforming PaywallKit's `EntitlementProviding`
// (test-suite §3.1 names this double; the house no-shared-fixtures
// convention — no TestSupport target exists or is wanted).
//
// RED: `EntitlementModel.refresh()` is inert (never consults the provider)
// and `PaywallRouting` always answers `.dashboard` — the designed failures
// below are the state-flow and routing pins.

/// The §3.1-named double: a scriptable provider, actor-shaped like the real
/// `CachingEntitlementProvider` so the conformance is honest about isolation.
private actor FakeEntitlementProvider: EntitlementProviding {
    private var scripted: EntitlementState

    init(_ state: EntitlementState) {
        self.scripted = state
    }

    func script(_ state: EntitlementState) {
        scripted = state
    }

    var currentState: EntitlementState {
        scripted
    }

    @discardableResult
    func refresh() async -> EntitlementState {
        scripted
    }

    @discardableResult
    func restore() async throws -> EntitlementState {
        scripted
    }

    func reset() async throws {
        scripted = .never
    }
}

@MainActor
@Suite("E7.1 · entitlement model + summary-CTA routing")
struct EntitlementModelTests {
    /// M11 (designed-red): a refresh reflects the provider's verdict into the
    /// observable state the CTA gate reads.
    @Test func test_entitlementModel_refresh_reflectsProviderState() async {
        let model = EntitlementModel(provider: FakeEntitlementProvider(.active(product: .annual)))
        #expect(model.state == .never, "pre-refresh the model knows nothing (in-memory only, R23.3)")

        await model.refresh()
        #expect(model.state == .active(product: .annual))
    }

    /// M14 (designed-red): the model TRACKS provider transitions — a second
    /// refresh after the source moves (trial → paid conversion) updates the
    /// published state; nothing is latched.
    @Test func test_entitlementModel_secondRefresh_tracksProviderTransitions() async {
        let provider = FakeEntitlementProvider(.trial(product: .annual))
        let model = EntitlementModel(provider: provider)

        await model.refresh()
        #expect(model.state == .trial(product: .annual))

        await provider.script(.active(product: .annual))
        await model.refresh()
        #expect(model.state == .active(product: .annual), "trial→paid conversion must flow through")
    }

    /// M12 (designed-red): not-entitled routes to the paywall — both the
    /// never-purchased and the lapsed subscriber (MVP §6 hard-ish wall).
    @Test func test_summaryCTA_whenNotEntitled_routesToPaywall() {
        #expect(PaywallRouting.postSummaryDestination(state: .never) == .paywall)
        #expect(PaywallRouting.postSummaryDestination(state: .lapsed(product: .annual)) == .paywall)
    }

    /// M13 (born-green at red — the inert routing coincidentally answers
    /// `.dashboard`; kept as the permanent entitled-arm pin): an entitled user
    /// never meets the paywall on the onboarding path.
    @Test func test_summaryCTA_whenEntitled_routesToDashboard() {
        #expect(PaywallRouting.postSummaryDestination(state: .trial(product: .annual)) == .dashboard)
        #expect(PaywallRouting.postSummaryDestination(state: .active(product: .monthly)) == .dashboard)
    }
}
