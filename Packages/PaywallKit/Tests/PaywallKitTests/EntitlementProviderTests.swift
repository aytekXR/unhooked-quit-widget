import Foundation
import Testing
@testable import PaywallKit

// E7.1 — the caching provider over the source seam (Session 23 rulings
// R23.2/R23.3/R23.4). The "cache" is the actor's in-memory last-known state —
// the package persists zero bytes; durable offline caching is the RevenueCat
// SDK's documented job on the app side.

/// Scripted source double (test-suite §7 rule 8: doubles conform to the
/// architecture protocol, never subclass an SDK type). Each call consumes the
/// next scripted result; an exhausted script throws, so a test that
/// under-scripts fails loudly instead of silently passing.
private actor ScriptedEntitlementSource: EntitlementSource {
    struct ScriptExhausted: Error {}
    struct Offline: Error {}

    private var snapshotScript: [Result<EntitlementSnapshot?, any Error>]
    private var restoreScript: [Result<EntitlementSnapshot?, any Error>]
    private var resetThrows: Bool

    init(
        snapshots: [Result<EntitlementSnapshot?, any Error>] = [],
        restores: [Result<EntitlementSnapshot?, any Error>] = [],
        resetThrows: Bool = false
    ) {
        self.snapshotScript = snapshots
        self.restoreScript = restores
        self.resetThrows = resetThrows
    }

    func currentSnapshot() async throws -> EntitlementSnapshot? {
        guard !snapshotScript.isEmpty else { throw ScriptExhausted() }
        return try snapshotScript.removeFirst().get()
    }

    func restore() async throws -> EntitlementSnapshot? {
        guard !restoreScript.isEmpty else { throw ScriptExhausted() }
        return try restoreScript.removeFirst().get()
    }

    func reset() async throws {
        if resetThrows { throw Offline() }
    }
}

/// Recorded-intent spy for the domain-event seam (R23.4): records, sends nothing.
private actor SpyEntitlementEventSink: EntitlementEventSink {
    private(set) var recorded: [EntitlementEvent] = []
    func record(_ event: EntitlementEvent) async {
        recorded.append(event)
    }
}

private let activeAnnual = EntitlementSnapshot(product: .annual, periodType: .normal, isActive: true, willRenew: true)
private let trialAnnual = EntitlementSnapshot(product: .annual, periodType: .trial, isActive: true, willRenew: true)

@Suite("E7.1 caching entitlement provider — offline grace, restore, trial edge, reset")
struct EntitlementProviderTests {

    // MARK: plan-named test #2 (the trial_started fire-point — the package's
    // domain event; the app maps it to the closed analytics enum at wiring)

    @Test("entering trial fires exactly one trialStarted domain event, with the tier only")
    func test_trialStart_firesTrialStartedEvent() async {
        let spy = SpyEntitlementEventSink()
        let provider = CachingEntitlementProvider(
            source: ScriptedEntitlementSource(snapshots: [.success(trialAnnual)]),
            events: spy
        )
        await provider.refresh()
        #expect(await spy.recorded == [.trialStarted(product: .annual)])
    }

    @Test("trialStarted is edge-triggered — a replayed trial snapshot does NOT re-fire")
    func test_trialStart_notRefiredWhenAlreadyInTrial() async {
        let spy = SpyEntitlementEventSink()
        let provider = CachingEntitlementProvider(
            source: ScriptedEntitlementSource(snapshots: [.success(trialAnnual), .success(trialAnnual)]),
            events: spy
        )
        await provider.refresh()
        await provider.refresh()
        #expect(await spy.recorded.count == 1)
    }

    // MARK: plan-named test #3 (restore needs no account, recovers in any state)

    @Test("restore recovers an entitlement from .never with zero identity input")
    func test_restore_recoversEntitlement_withoutAccount() async throws {
        let provider = CachingEntitlementProvider(
            source: ScriptedEntitlementSource(
                snapshots: [.success(nil)],
                restores: [.success(activeAnnual)]
            )
        )
        let before = await provider.refresh()
        try #require(before == .never)
        // restore() takes no identity parameter BY DESIGN — the store account
        // does the work (MVP: no account creation path exists anywhere).
        let after = try await provider.restore()
        #expect(after == .active(product: .annual))
        #expect(await provider.currentState == .active(product: .annual))
    }

    @Test("a restore that lands in trial also fires the trialStarted edge")
    func test_restore_intoTrial_firesTrialStartedEvent() async throws {
        let spy = SpyEntitlementEventSink()
        let provider = CachingEntitlementProvider(
            source: ScriptedEntitlementSource(restores: [.success(trialAnnual)]),
            events: spy
        )
        _ = try await provider.restore()
        #expect(await spy.recorded == [.trialStarted(product: .annual)])
    }

    // MARK: plan-named test #4 (offline ⇒ last-known state, the §8 grace)

    @Test("a failed refresh keeps the last-known entitled state — never locks a paying user out")
    func test_entitlementCheck_offline_usesCachedState() async throws {
        let provider = CachingEntitlementProvider(
            source: ScriptedEntitlementSource(snapshots: [
                .success(activeAnnual),
                .failure(ScriptedEntitlementSource.Offline()),
            ])
        )
        let online = await provider.refresh()
        try #require(online == .active(product: .annual))
        let offline = await provider.refresh()
        #expect(offline == .active(product: .annual))
        #expect(await provider.currentState == .active(product: .annual))
    }

    @Test("offline with no prior snapshot reports .never — a state is never fabricated")
    func test_offline_withNoPriorSnapshot_reportsNever() async {
        // NOTE (ledger): passes coincidentally under the red-commit inert stub —
        // this is a safety pin, not red evidence.
        let provider = CachingEntitlementProvider(
            source: ScriptedEntitlementSource(snapshots: [.failure(ScriptedEntitlementSource.Offline())])
        )
        let state = await provider.refresh()
        #expect(state == .never)
    }

    // MARK: the erase seam (E2.4's recorded "RevenueCat clear → E7 seam")

    @Test("reset clears the cached state FIRST, even when the source reset throws")
    func test_reset_clearsCachedState_evenWhenSourceResetThrows() async throws {
        let provider = CachingEntitlementProvider(
            source: ScriptedEntitlementSource(
                snapshots: [.success(activeAnnual)],
                resetThrows: true
            )
        )
        let seeded = await provider.refresh()
        try #require(seeded == .active(product: .annual))
        do {
            try await provider.reset()
            Issue.record("source reset was scripted to throw — reset() must propagate it for retry")
        } catch {
            // expected: the E2.4 local-first order — local clear precedes the
            // fallible source step, whose failure surfaces for retry.
        }
        #expect(await provider.currentState == .never)
    }

    // MARK: born-green pins

    @Test("a non-trial transition records no domain events")
    func test_provider_recordsNoEventsWithoutTrialTransition() async {
        // NOTE (ledger): passes coincidentally under the red-commit inert stub —
        // safety pin, not red evidence.
        let spy = SpyEntitlementEventSink()
        let provider = CachingEntitlementProvider(
            source: ScriptedEntitlementSource(snapshots: [.success(activeAnnual)]),
            events: spy
        )
        await provider.refresh()
        #expect(await spy.recorded.isEmpty)
    }
}
