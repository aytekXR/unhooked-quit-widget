import Foundation
import StreakEngine
import SwiftData
import Testing
@testable import Unhooked

// E7.1 app half (Session 24) — the erase→entitlement wiring (R24.7): the
// injected `resetEntitlement` closure runs INSIDE `eraseEverything()` as the
// new step 5 — after the widget reload is scheduled (widgets drop regardless
// of BOTH remote steps), BEFORE the CloudKit purge (§10 order: RC reset →
// CloudKit LAST) — and its failure SURFACES for retry (the cloud-purge
// precedent; erase is re-runnable). The trial_started dedupe marker joins
// step 2's infallible local clears: it lives in app-STANDARD defaults, which
// the App Group sweep can NEVER reach (the load-bearing Architect catch) —
// post-erase is a fresh tracking era whose trial may fire again.
//
// A NEW file so the 433-line EraseEverythingTests keeps every assertion
// byte-untouched (never weaken a QA assertion); its Harness shape is copied
// per the no-shared-fixtures convention, minus the on-disk arm (the file-set
// pins live in the neighbor — these tests pin ORDER and SWEEP membership).
//
// RED: `eraseEverything()` calls neither the reset closure nor the dedupe
// clear yet (the params landed inert) — all three pins fail by design.

// Fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z.
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)
private let bootA = UUID(uuidString: "0B00071D-A000-4000-8000-000000000E71")!

@MainActor
private final class ManualClock: ClockProviding {
    var now: Date
    var monotonicNow: MonotonicNow

    init(now: Date = epoch, bootID: UUID = bootA, uptime: TimeInterval = 50_000) {
        self.now = now
        self.monotonicNow = MonotonicNow(bootID: bootID, uptime: uptime)
    }
}

/// One shared order journal: the reset closure and the cloud mock both append,
/// so the reset-before-cloud canon is a plain array assertion. The debounced
/// widget reload rides its own Task, so its entry is deliberately NOT part of
/// the order pin (only presence/absence is ever asserted on it elsewhere).
@MainActor
private final class OrderLog {
    private(set) var entries: [String] = []
    func append(_ entry: String) { entries.append(entry) }
    func only(_ names: Set<String>) -> [String] { entries.filter { names.contains($0) } }
}

@MainActor
private final class LoggingCloudSync: CloudSyncControlling {
    private let log: OrderLog

    init(log: OrderLog) {
        self.log = log
    }

    func accountStatus() async -> CloudAccountStatus { .available }

    func deleteAllPrivateZones() async throws {
        log.append("cloud")
    }
}

@MainActor
private final class SpyWidgetRefresher: WidgetRefreshing {
    private(set) var reloadCount = 0
    func reloadAllTimelines() { reloadCount += 1 }
}

private struct EntitlementResetFailed: Error {}

/// One store + repository per test, in-memory, zero cross-test state — the
/// EraseEverythingTests Harness, narrowed to this file's seams.
@MainActor
private struct Harness {
    let container: ModelContainer
    let log: OrderLog
    let dedupe: TrialAnalyticsDedupeStore
    let repository: QuitRepository

    init(log: OrderLog = OrderLog(), resetEntitlement: @escaping () async throws -> Void = {}) throws {
        container = try ModelContainer(
            for: PersistentStore.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        self.log = log
        let snapshotDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("e71-erase-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: snapshotDirectory, withIntermediateDirectories: true)
        dedupe = TrialAnalyticsDedupeStore(
            defaults: UserDefaults(suiteName: "e71-dedupe-\(UUID().uuidString)")!
        )
        repository = QuitRepository(
            container: container,
            clock: ManualClock(),
            widgetRefresher: SpyWidgetRefresher(),
            lastKnownGoodStore: LastKnownGoodStore(
                defaults: UserDefaults(suiteName: "e71-lkg-\(UUID().uuidString)")!
            ),
            cloud: LoggingCloudSync(log: log),
            appGroupDefaults: UserDefaults(suiteName: "e71-group-\(UUID().uuidString)")!,
            panicSnapshotStore: PanicSnapshotStore(directoryURL: snapshotDirectory),
            quizProgressStore: QuizProgressStore(
                defaults: UserDefaults(suiteName: "e71-quiz-\(UUID().uuidString)")!
            ),
            trialDedupeStore: dedupe,
            resetEntitlement: resetEntitlement,
            debounceSleep: { _ in }
        )
    }
}

@MainActor
@Suite("E7.1 · erase → entitlement wiring")
struct EntitlementEraseWiringTests {
    /// M15 (designed-red): the reset runs exactly once per erase, and BEFORE
    /// the CloudKit purge (§10: RC reset → CloudKit LAST).
    @Test func test_erase_resetsEntitlementOnce_beforeCloudPurge() async throws {
        let log = OrderLog()
        // NOTE: no `await` on the append — the non-Sendable literal inherits
        // this suite's @MainActor isolation, so the call is synchronous; a
        // spurious `await` marker is a warning, and warnings are errors on
        // the app lane (the Session 24 burned-run lesson, now shape-gated).
        let h = try Harness(log: log, resetEntitlement: { log.append("reset") })
        _ = try h.repository.createQuit(habitCategory: .vape)

        try await h.repository.eraseEverything()

        #expect(
            h.log.only(["reset", "cloud"]) == ["reset", "cloud"],
            "the entitlement reset must run exactly once, ordered before the CloudKit purge"
        )
    }

    /// M16 (designed-red): a throwing reset SURFACES for retry (the
    /// cloud-purge failure precedent) — after the local erase completed, and
    /// WITHOUT the CloudKit purge having run (erase is re-runnable; retry
    /// re-attempts both remote steps).
    @Test func test_erase_entitlementResetFailure_surfacesForRetry_afterLocalErase() async throws {
        let h = try Harness(resetEntitlement: { throw EntitlementResetFailed() })
        _ = try h.repository.createQuit(habitCategory: .vape)

        await #expect(throws: EntitlementResetFailed.self) {
            try await h.repository.eraseEverything()
        }

        let remaining = try h.container.mainContext.fetch(FetchDescriptor<Quit>())
        #expect(remaining.isEmpty, "the local erase half completed before the reset threw")
        #expect(h.log.only(["cloud"]).isEmpty, "the CloudKit purge never ran — retry re-attempts it")
    }

    /// M17 (designed-red): the dedupe marker joins the erase sweep — an
    /// app-standard-defaults key the App Group sweep cannot reach, cleared
    /// explicitly in step 2 (post-erase = a fresh tracking era).
    @Test func test_erase_sweepsTrialDedupeMarker() async throws {
        let h = try Harness()
        h.dedupe.markFired()
        #expect(h.dedupe.hasFired)

        try await h.repository.eraseEverything()

        #expect(h.dedupe.hasFired == false, "erase must clear the trial_started dedupe marker")
    }
}
