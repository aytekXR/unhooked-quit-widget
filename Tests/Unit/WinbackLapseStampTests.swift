import Foundation
import StreakEngine
import SwiftData
import Testing
@testable import Unhooked

// E7.3 (R26.1) — the repository half of the win-back clock: the ONE writer
// of `AppSettings.lapseObservedAt` stamps the FIRST observed lapse from the
// INJECTED clock (nil→set only — a still-lapsed re-observation never moves
// the stamp, so the 7-day window runs from the first sighting; fail-safe,
// late-only), and one-tap erase's step-1 row sweep wipes it — an erased
// device re-enters with no lapse residue (fresh-install semantics; the
// sweep pin is seeded directly so it holds regardless of the writer).
//
// The Harness is the TeaserWiringTests shape, narrowed (the
// no-shared-fixtures convention) — in-memory store, manual clock, one
// repository per test.
//
// RED: `recordLapseObserved()` is an inert no-op — the stamp pins fail by
// design; the erase-sweep pin is born-green (erase already deletes every
// AppSettings row) and stands as the permanent strengthen.

// Fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z.
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)
private let bootA = UUID(uuidString: "0B00071D-A000-4000-8000-000000000E73")!

@MainActor
private final class ManualClock: ClockProviding {
    var now: Date
    var monotonicNow: MonotonicNow

    init(now: Date = epoch, bootID: UUID = bootA, uptime: TimeInterval = 50_000) {
        self.now = now
        self.monotonicNow = MonotonicNow(bootID: bootID, uptime: uptime)
    }
}

@MainActor
private final class SpyWidgetRefresher: WidgetRefreshing {
    private(set) var reloadCount = 0
    func reloadAllTimelines() { reloadCount += 1 }
}

@MainActor
private final class NoopCloudSync: CloudSyncControlling {
    func accountStatus() async -> CloudAccountStatus { .available }
    func deleteAllPrivateZones() async throws {}
}

/// One store + repository per test, in-memory, zero cross-test state.
@MainActor
private struct Harness {
    let container: ModelContainer
    let repository: QuitRepository
    let clock: ManualClock

    init(clock: ManualClock = ManualClock()) throws {
        self.clock = clock
        container = try ModelContainer(
            for: PersistentStore.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        let snapshotDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("e73-winback-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: snapshotDirectory, withIntermediateDirectories: true)
        repository = QuitRepository(
            container: container,
            clock: clock,
            widgetRefresher: SpyWidgetRefresher(),
            lastKnownGoodStore: LastKnownGoodStore(
                defaults: UserDefaults(suiteName: "e73-lkg-\(UUID().uuidString)")!
            ),
            cloud: NoopCloudSync(),
            appGroupDefaults: UserDefaults(suiteName: "e73-group-\(UUID().uuidString)")!,
            panicSnapshotStore: PanicSnapshotStore(directoryURL: snapshotDirectory),
            quizProgressStore: QuizProgressStore(
                defaults: UserDefaults(suiteName: "e73-quiz-\(UUID().uuidString)")!
            ),
            trialDedupeStore: TrialAnalyticsDedupeStore(
                defaults: UserDefaults(suiteName: "e73-dedupe-\(UUID().uuidString)")!
            ),
            debounceSleep: { _ in }
        )
    }
}

@MainActor
@Suite("E7.3 · observed-lapse stamp repository wiring")
struct WinbackLapseStampTests {
    /// Designed-red: the first observation stamps the INJECTED clock's now
    /// (never an ambient Date), and a later re-observation NEVER moves it —
    /// nil→set only; the 7-day window runs from the first sighting.
    @Test func test_observeLapse_stampsLapseFromInjectedClock() throws {
        let h = try Harness()

        try h.repository.recordLapseObserved()
        #expect(
            h.repository.lapseObservedAt() == epoch,
            "the ONE writer stamps clock.now on the FIRST observed lapse (R26.1)"
        )

        h.clock.now = epoch.addingTimeInterval(3 * 86_400)
        try h.repository.recordLapseObserved()
        #expect(
            h.repository.lapseObservedAt() == epoch,
            "a still-lapsed re-observation never moves the stamp — nil→set only (the window must not creep)"
        )
    }

    /// Born-green strengthen (the permanent sweep pin): one-tap erase wipes
    /// the observed-lapse stamp — seeded directly at the store so the pin
    /// holds regardless of the writer's state. Post-erase is a fresh
    /// install: a re-onboarded device carries no lapse residue (R26.1).
    @Test func test_erase_wipesLapseStamp() async throws {
        let h = try Harness()
        let settings = AppSettings()
        settings.lapseObservedAt = epoch
        h.container.mainContext.insert(settings)
        try h.container.mainContext.save()

        try await h.repository.eraseEverything()

        #expect(h.repository.lapseObservedAt() == nil, "erase step 1 sweeps the stamp with its row")
    }
}
