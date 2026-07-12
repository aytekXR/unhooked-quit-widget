import Foundation
import StreakEngine
import SwiftData
import Testing
@testable import Unhooked

// E6.3 unit lane — the alternate-app-icon seam (AppIconSwitcher) and the launch-time
// reconciler (AppIconReconciler). AppIconSwitcher stores the UIKit-touching apply
// closure but never imports UIKit, so the unit lane spies it end-to-end:
//   I1 — select persists durably (setDiscreetIconId) AND requests the OS swap. The
//        switcher is INERT at red (empty select body), so BOTH halves fail honestly.
//   I2 — the erase FLOW erases first, THEN best-effort resets the icon to primary
//        (applyIcon(nil)); at red run() only erases, so the reset never records.
//   I6 — the reconciler's reset-only truth table (born-green: the type is final).
//
// This lane CANNOT run locally (I1 needs SwiftData/the simulator); its evidence is the
// parse-gate + the predicted red manifest. The Harness is the WidgetFeedTests shape,
// trimmed to the repository I1 needs; every fixture instant is a fixed literal
// (test-suite §3.1).

// Fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z.
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)
private let bootA = UUID(uuidString: "0B00071D-A000-4000-8000-000000000001")!

/// Manual test clock (test-suite §3.1): wall and monotonic evidence move only when told.
@MainActor
private final class ManualClock: ClockProviding {
    var now: Date
    var monotonicNow: MonotonicNow

    init(now: Date = epoch, bootID: UUID = bootA, uptime: TimeInterval = 50_000) {
        self.now = now
        self.monotonicNow = MonotonicNow(bootID: bootID, uptime: uptime)
    }

    func advance(by seconds: TimeInterval) {
        now += seconds
        monotonicNow.uptime += seconds
    }
}

@MainActor
private final class SpyWidgetRefresher: WidgetRefreshing {
    private(set) var reloadCount = 0
    func reloadAllTimelines() { reloadCount += 1 }
}

/// Inert CloudKit-seam stub (E2.4 init plumbing): nothing in this suite erases.
@MainActor
private final class StubCloudSync: CloudSyncControlling {
    func accountStatus() async -> CloudAccountStatus { .available }
    func deleteAllPrivateZones() async throws {}
}

/// Records the icon names the switcher's @Sendable async apply closure receives — an
/// actor so it is Sendable-safe under strict concurrency (the seam shape the panel
/// proved compiles clean).
private actor ApplyIconSpy {
    private(set) var applied: [String?] = []
    func record(_ iconID: String?) { applied.append(iconID) }
}

/// Ordered call log for the erase flow (I2): erase and applyIcon append tokens so the
/// pin asserts BOTH the calls and their order.
private actor CallLog {
    private(set) var calls: [String] = []
    func record(_ call: String) { calls.append(call) }
}

/// One in-memory store + repository per test (the WidgetFeedTests shape, trimmed): I1
/// only exercises setDiscreetIconId / discreetIconId (AppSettings, no quit needed).
@MainActor
private struct Harness {
    let container: ModelContainer
    let clock: ManualClock
    let repository: QuitRepository

    init() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("e63-icon-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        container = try ModelContainer(
            for: PersistentStore.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        clock = ManualClock()
        repository = QuitRepository(
            container: container,
            clock: clock,
            widgetRefresher: SpyWidgetRefresher(),
            lastKnownGoodStore: LastKnownGoodStore(
                defaults: UserDefaults(suiteName: "e63-icon-lkg-\(UUID().uuidString)")!
            ),
            cloud: StubCloudSync(),
            appGroupDefaults: UserDefaults(suiteName: "e63-icon-group-\(UUID().uuidString)")!,
            panicSnapshotStore: PanicSnapshotStore(directoryURL: directory),
            debounceSleep: { _ in }
        )
    }
}

@MainActor
@Suite("E6.3 · alternate app icon (switcher + reconciler)")
struct AltIconSwitcherTests {

    // MARK: - I1 · select persists the choice AND requests the OS swap (plan-named)

    @Test func test_altIcon_switch_appliesAndPersists() async throws {
        let h = try Harness()
        let spy = ApplyIconSpy()
        let switcher = AppIconSwitcher(
            persist: { try h.repository.setDiscreetIconId($0) },
            apply: { iconID in await spy.record(iconID) },
            fireIconEnabled: {}
        )

        try await switcher.select("AppIconTimer")

        #expect(
            h.repository.discreetIconId() == "AppIconTimer",
            "select persists the selection durably AT the tap (setDiscreetIconId) — inert at red, so the persisted id stays nil"
        )
        let applied = await spy.applied
        #expect(
            applied == ["AppIconTimer"],
            "select requests the OS icon swap exactly once with the chosen name — inert at red, so nothing is applied"
        )
    }

    // MARK: - I2 · the erase flow resets the icon to primary AFTER the data erase

    @Test func test_erase_requestsAlternateIconReset() async throws {
        let log = CallLog()
        let flow = EraseFlow(
            erase: { await log.record("erase") },
            applyIcon: { iconID in await log.record("applyIcon(\(iconID ?? "nil"))") }
        )

        try await flow.run()

        let calls = await log.calls
        #expect(
            calls == ["erase", "applyIcon(nil)"],
            "run() erases first, THEN best-effort requests the primary icon back (applyIcon(nil)) — at red run() only erases, so the reset never records (calls == [\"erase\"])"
        )
    }

    // MARK: - I6 · the reconciler resets ONLY when the OS icon outlives its selection

    @Test func test_iconReconciler_resetsOnlyWhenOSIconOutlivesSelection() {
        #expect(
            AppIconReconciler.reconcile(osAlternateIconName: "AppIconTimer", persistedIconID: nil) == .resetToPrimary,
            "an OS alternate icon that outlived its persisted selection (a lost erase-path reset) heals to primary at launch"
        )
        #expect(
            AppIconReconciler.reconcile(osAlternateIconName: nil, persistedIconID: nil) == .none,
            "no OS icon, no selection ⇒ nothing to do"
        )
        #expect(
            AppIconReconciler.reconcile(osAlternateIconName: "AppIconTimer", persistedIconID: "AppIconTimer") == .none,
            "the OS icon matches a live selection ⇒ leave the chosen disguise in place"
        )
        #expect(
            AppIconReconciler.reconcile(osAlternateIconName: nil, persistedIconID: "AppIconTimer") == .none,
            "reset-only direction: a persisted selection with no OS icon is NEVER re-applied at launch (no unprompted system icon-change alert)"
        )
    }
}
