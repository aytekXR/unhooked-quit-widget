import Foundation
import StreakEngine
import SwiftData
import Testing
@testable import Unhooked

// E2.4 unit lane — one-tap erase. The plan-named tests from implementation-plan.md
// E2.4 are verbatim, scope-adjusted per resume-prompt v1.9 §objective:
//   - "both store files" TODAY means the single product store's file set (base +
//     -shm/-wal/journal sidecars + hidden support artifacts) — the non-mirrored
//     companion transcript store joins the set in E12;
//   - the CloudKit purge is a protocol seam + mock (`CloudSyncControlling`) — the
//     real zone deletion is contract/device-tier (test-suite §4.3), and the store is
//     still `cloudKitDatabase: .none`;
//   - RevenueCat cache clear + the final analytics event are E7/E8 seams (neither
//     SDK nor the event enum exists yet) — named TODO seams, deliberately untested.
// `test_erase_appRelaunch_startsAtOnboarding` lives in the UI-smoke lane
// (Tests/UITests/EraseUITests.swift). Red evidence for this file = the CI run on the
// red commit (session-rules app-lane mechanics).

// Fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z.
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)
private let day = 86_400
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

/// Scriptable double for the CloudKit seam (test-suite §3.1: mock at the protocol
/// seams the architecture defines; never stub CKContainer internals — "that path lies").
@MainActor
private final class MockCloudSync: CloudSyncControlling {
    var status: CloudAccountStatus
    /// While non-nil, every zone-deletion request throws it (clear to heal — retry story).
    var zoneDeletionError: Error?
    private(set) var zoneDeletionRequests = 0

    init(status: CloudAccountStatus = .available) {
        self.status = status
    }

    func accountStatus() async -> CloudAccountStatus { status }

    func deleteAllPrivateZones() async throws {
        zoneDeletionRequests += 1
        if let zoneDeletionError { throw zoneDeletionError }
    }
}

private struct CloudUnreachable: Error {}

/// One store + repository per test, zero cross-test state. In-memory by default;
/// `onDisk: true` builds a real store file set in a throwaway temp directory
/// (test-suite §1.2: throwaway on-disk stores in a temp path).
@MainActor
private struct Harness {
    let container: ModelContainer
    let clock: ManualClock
    let spy: SpyWidgetRefresher
    let lkgStore: LastKnownGoodStore
    let cloud: MockCloudSync
    let appGroupDefaults: UserDefaults
    let storeDirectory: URL?
    let repository: QuitRepository

    init(onDisk: Bool = false, cloudStatus: CloudAccountStatus = .available) throws {
        if onDisk {
            let directory = FileManager.default.temporaryDirectory
                .appendingPathComponent("e24-erase-\(UUID().uuidString)", isDirectory: true)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            storeDirectory = directory
            container = try ModelContainer(
                for: PersistentStore.schema,
                configurations: [ModelConfiguration(
                    schema: PersistentStore.schema,
                    url: directory.appendingPathComponent("unhooked.store", isDirectory: false),
                    cloudKitDatabase: .none
                )]
            )
        } else {
            storeDirectory = nil
            container = try ModelContainer(
                for: PersistentStore.schema,
                configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
            )
        }
        clock = ManualClock()
        spy = SpyWidgetRefresher()
        lkgStore = LastKnownGoodStore(
            defaults: UserDefaults(suiteName: "e24-lkg-\(UUID().uuidString)")!
        )
        cloud = MockCloudSync(status: cloudStatus)
        appGroupDefaults = UserDefaults(suiteName: "e24-group-\(UUID().uuidString)")!
        repository = QuitRepository(
            container: container,
            clock: clock,
            widgetRefresher: spy,
            lastKnownGoodStore: lkgStore,
            cloud: cloud,
            appGroupDefaults: appGroupDefaults,
            debounceSleep: { _ in }
        )
    }

    /// Every on-disk file that belongs to the store's file set: the base file plus
    /// SQLite sidecars (`-shm`/`-wal`/`-journal`) plus hidden support artifacts.
    func storeFileSet() -> [String] {
        guard let storeDirectory else { return [] }
        let names = (try? FileManager.default.contentsOfDirectory(atPath: storeDirectory.path)) ?? []
        return names
            .filter { $0 == "unhooked.store" || $0.hasPrefix("unhooked.store-") || $0.hasPrefix(".unhooked.store") }
            .sorted()
    }
}

@MainActor
@Suite("E2.4 · one-tap erase")
struct EraseEverythingTests {

    // MARK: - The plan-named tests (implementation-plan E2.4, scope-adjusted)

    @Test func test_erase_deletesBothStoreFiles() async throws {
        // Scope note (resume-prompt v1.9): "both stores" is the E12 world; TODAY the
        // product has exactly one store, so the pin is its ENTIRE on-disk file set —
        // base + whatever sidecars this SQLite build actually created. The companion
        // transcript store joins this file set in E12.
        let h = try Harness(onDisk: true)
        let quit = try h.repository.createQuit(habitCategory: .vape, weeklySpend: 26)
        h.clock.advance(by: TimeInterval(3 * day))
        _ = try h.repository.logSlip(quitID: quit.id, note: "on disk before erase")

        let before = h.storeFileSet()
        #expect(before.contains("unhooked.store"), "the store file must exist before erase")

        try await h.repository.eraseEverything()

        #expect(
            h.storeFileSet() == [],
            "erase must remove the store's whole file set (was: \(before)) — a leftover \
            sidecar can resurrect rows on the next open"
        )
    }

    @Test func test_erase_requestsCloudKitZoneDeletion() async throws {
        // The seam, not the SDK: the real CKContainer purge is contract/device-tier
        // (test-suite §4.3 erase contract) and the store is still cloudKitDatabase: .none.
        let h = try Harness()
        _ = try h.repository.createQuit(habitCategory: .vape)

        try await h.repository.eraseEverything()

        #expect(
            h.cloud.zoneDeletionRequests == 1,
            "an available account gets exactly one private-zone deletion request per erase"
        )
    }

    @Test func test_erase_clearsPanicPreCacheDefaults() async throws {
        let h = try Harness()
        _ = try h.repository.createQuit(habitCategory: .vape)

        // App Group defaults TODAY: the panic launch flag + (future, E3.1) pre-cache
        // keys — seeded here as an arbitrary sentinel so the sweep needs no key
        // registry — plus the LKG WITNESS, which lives in its own suite in this
        // harness so its clearing is pinned through LastKnownGoodStore, not as a
        // side effect of the sweep.
        h.appGroupDefaults.set(true, forKey: PanicLaunchFlag.key)
        h.appGroupDefaults.set(["my reason, verbatim"], forKey: "e31.panic.precache.sentinel")
        h.lkgStore.save(MonotonicAnchor(bootID: bootA, uptime: 51_000, wallClock: epoch + 1_000))

        try await h.repository.eraseEverything()

        #expect(h.appGroupDefaults.object(forKey: PanicLaunchFlag.key) == nil,
                "a pending panic launch flag must not survive an erase")
        #expect(h.appGroupDefaults.object(forKey: "e31.panic.precache.sentinel") == nil,
                "pre-cached panic content is user data — erased")
        #expect(h.lkgStore.load() == nil,
                "the clock WITNESS is erased state: a fresh install has none, and a stale \
                one would poison the next tracking era's cap baseline (Session 07 discipline)")
    }

    @Test func test_iCloudUnavailable_appFunctionsFullyLocal() async throws {
        // MVP feature #13 / architecture §8: iCloud OFF is a first-class mode, not an
        // error. Every repository operation — including a COMPLETE local erase — must
        // work with the account unavailable, and the CloudKit seam must not be called.
        let h = try Harness(onDisk: true, cloudStatus: .unavailable)

        let quit = try h.repository.createQuit(habitCategory: .vape, weeklySpend: 26)
        h.clock.advance(by: TimeInterval(2 * day))
        let value = try h.repository.streakValue(for: quit.id)
        #expect(value.elapsedSeconds == 2 * day)
        #expect(value.clockSanity == .normal)
        _ = try h.repository.logSlip(quitID: quit.id, note: "fully local")
        _ = try h.repository.logUrgeEvent(quitID: quit.id, source: .inApp, outcome: .averted)
        #expect(try h.repository.recomputeDerivedState() == false, "clean single-row state is a no-op pass")

        try await h.repository.eraseEverything() // must complete, not throw

        #expect(h.cloud.zoneDeletionRequests == 0,
                "no CloudKit call may fire while the account is unavailable")
        #expect(h.storeFileSet() == [], "the local erase is COMPLETE without iCloud")
        #expect(h.lkgStore.load() == nil)
    }

    // MARK: - Supporting pins

    @Test func test_erase_deletesAllEntities_freshContextSeesEmptyStore() async throws {
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: 3_600)
        _ = try h.repository.logSlip(quitID: quit.id, note: "row")
        _ = try h.repository.logUrgeEvent(quitID: quit.id, source: .inApp, outcome: .averted)
        // Entity types the repository does not create yet (QuizProfile is E5's, the
        // AppSettings singleton is fetched-or-created at first consumer): inserted
        // directly — Tests/ is inside the sole-importer lint allowlist.
        let context = h.container.mainContext
        let profile = QuizProfile()
        profile.quit = quit
        context.insert(profile)
        context.insert(AppSettings())
        try context.save()

        try await h.repository.eraseEverything()

        // A FRESH context proves the deletes were saved, mirroring the E2.2
        // persistsBeforeReturning discipline.
        let fresh = ModelContext(h.container)
        #expect(try fresh.fetchCount(FetchDescriptor<Quit>()) == 0)
        #expect(try fresh.fetchCount(FetchDescriptor<Slip>()) == 0)
        #expect(try fresh.fetchCount(FetchDescriptor<UrgeEvent>()) == 0)
        #expect(try fresh.fetchCount(FetchDescriptor<QuizProfile>()) == 0)
        #expect(try fresh.fetchCount(FetchDescriptor<AppSettings>()) == 0)
    }

    @Test func test_erase_cloudFailureSurfaces_localEraseCompletes_thenRetrySucceeds() async throws {
        // The privacy promise is "erase = gone", BOTH copies. Spec-review ruling
        // (Session 08): the on-device copy — verbatim motivations pre-cache, witness,
        // store file, readable by a person holding the phone — is the MORE sensitive
        // one, so the LOCAL erase must complete even when the cloud purge fails;
        // with an AVAILABLE account the failed zone purge must still surface
        // (architecture §9: actionable, retry offered) — never a silent success that
        // leaves mirrored data alive. Erase is re-runnable: the retry finishes the
        // cloud half.
        let h = try Harness(onDisk: true)
        _ = try h.repository.createQuit(habitCategory: .vape)
        h.appGroupDefaults.set(["my reason, verbatim"], forKey: "e31.panic.precache.sentinel")
        h.lkgStore.save(MonotonicAnchor(bootID: bootA, uptime: 51_000, wallClock: epoch + 1_000))
        h.cloud.zoneDeletionError = CloudUnreachable()

        await #expect(throws: CloudUnreachable.self) {
            try await h.repository.eraseEverything()
        }
        #expect(h.cloud.zoneDeletionRequests == 1, "the purge was attempted before failing")
        #expect(h.storeFileSet() == [],
                "LOCAL erase completes before the fallible cloud step — a transient \
                CloudKit error may never strand sensitive data on-device")
        #expect(h.appGroupDefaults.object(forKey: "e31.panic.precache.sentinel") == nil)
        #expect(h.lkgStore.load() == nil)

        h.cloud.zoneDeletionError = nil
        try await h.repository.eraseEverything()

        #expect(h.cloud.zoneDeletionRequests == 2, "erase is re-runnable; the retry purges the zone")
    }

    @Test func test_erase_triggersDebouncedWidgetReload() async throws {
        // Erase is a repository write like any other: widgets must drop their streaks
        // through the same debounced reload discipline (E2.2), not linger until the
        // next unrelated write.
        //
        // Spec-review ruling (Session 08): NO repository write may precede the awaited
        // erase here — a pre-seeded write parks its own reload task in pendingReload,
        // and a no-op erase body would let drain fire THAT task and read 1, passing
        // from birth. On an untouched repository the only possible reload is erase's
        // own: red reads 0, green reads exactly 1.
        let h = try Harness()

        try await h.repository.eraseEverything()
        #expect(h.spy.reloadCount == 0, "debounced — nothing reloads synchronously")
        await h.repository.drainPendingWidgetReload()

        #expect(h.spy.reloadCount == 1, "erase schedules the standard debounced reload")
    }
}
