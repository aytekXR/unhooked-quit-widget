import Foundation
import StreakEngine
import SwiftData
import Testing
@testable import Unhooked

// E9.1 (R27.5) — the repository half of the alcohol-notice once-guarantee: the ONE
// writer of `AppSettings.alcoholNoticeShownAt` stamps the FIRST display from the
// INJECTED clock (nil→set only — "shown once" means once EVER app-wide), the
// repository present-decision runs the pure policy over the active quits + the
// stamp, and one-tap erase's step-1 row sweep wipes it — a post-erase user is a
// fresh user and meets the notice again (fresh-install honesty).
//
// Lands GREEN beside the field (the WinbackLapseStampTests precedent: born-green
// permanent strengthen pins over a green-commit schema field — the plan-named RED
// test pins the PURE policy in SafetyResourcesTests, so no red bytes reference
// the field; standing rule #6's exact-set sweep rides the same green commit).
//
// The Harness is the WinbackLapseStampTests shape, verbatim (the
// no-shared-fixtures convention) — in-memory store, manual clock, one
// repository per test.

// Fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z.
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)
private let bootA = UUID(uuidString: "0B00071D-A000-4000-8000-000000000E91")!

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
            .appendingPathComponent("e91-notice-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: snapshotDirectory, withIntermediateDirectories: true)
        repository = QuitRepository(
            container: container,
            clock: clock,
            widgetRefresher: SpyWidgetRefresher(),
            lastKnownGoodStore: LastKnownGoodStore(
                defaults: UserDefaults(suiteName: "e91-lkg-\(UUID().uuidString)")!
            ),
            cloud: NoopCloudSync(),
            appGroupDefaults: UserDefaults(suiteName: "e91-group-\(UUID().uuidString)")!,
            panicSnapshotStore: PanicSnapshotStore(directoryURL: snapshotDirectory),
            quizProgressStore: QuizProgressStore(
                defaults: UserDefaults(suiteName: "e91-quiz-\(UUID().uuidString)")!
            ),
            trialDedupeStore: TrialAnalyticsDedupeStore(
                defaults: UserDefaults(suiteName: "e91-dedupe-\(UUID().uuidString)")!
            ),
            debounceSleep: { _ in }
        )
    }
}

@MainActor
@Suite("E9.1 · alcohol-notice once-shown stamp wiring")
struct AlcoholNoticeStampTests {
    /// The ONE writer stamps the injected clock's now on the first display and a
    /// later call NEVER moves it — nil→set only ("shown once" never creeps).
    @Test func test_recordAlcoholNoticeShown_stampsOnce_fromInjectedClock() throws {
        let h = try Harness()

        try h.repository.recordAlcoholNoticeShown()
        #expect(
            h.repository.alcoholNoticeShownAt() == epoch,
            "the ONE writer stamps clock.now on the FIRST display (R27.5)"
        )

        h.clock.now = epoch.addingTimeInterval(3 * 86_400)
        try h.repository.recordAlcoholNoticeShown()
        #expect(
            h.repository.alcoholNoticeShownAt() == epoch,
            "a re-display request never moves the stamp — nil→set only"
        )
    }

    /// The composed present-decision: an alcohol goal (either mode) triggers it,
    /// the stamp silences it forever after, and non-alcohol quits never do.
    @Test func test_shouldShowAlcoholNotice_composedOverActiveQuitsAndStamp() throws {
        let h = try Harness()
        #expect(!h.repository.shouldShowAlcoholNotice(), "no quits ⇒ no notice")

        try h.repository.createQuit(habitCategory: .vape)
        #expect(!h.repository.shouldShowAlcoholNotice(), "a vape quit never triggers the alcohol notice")

        try h.repository.createQuit(habitCategory: .alcohol, goalMode: .reduce)
        #expect(
            h.repository.shouldShowAlcoholNotice(),
            "an alcohol REDUCE goal triggers the notice (R27.6 — the Alex persona)"
        )

        try h.repository.recordAlcoholNoticeShown()
        #expect(
            !h.repository.shouldShowAlcoholNotice(),
            "once shown, never again — even when another alcohol quit is added"
        )
    }

    /// Born-green strengthen (the permanent sweep pin, WinbackLapseStampTests
    /// shape): one-tap erase wipes the stamp — seeded directly at the store so the
    /// pin holds regardless of the writer. Post-erase relaunch = fresh install:
    /// a new alcohol goal meets the notice again (R27.5).
    @Test func test_erase_wipesAlcoholNoticeStamp() async throws {
        let h = try Harness()
        let settings = AppSettings()
        settings.alcoholNoticeShownAt = epoch
        h.container.mainContext.insert(settings)
        try h.container.mainContext.save()

        try await h.repository.eraseEverything()

        #expect(h.repository.alcoholNoticeShownAt() == nil, "erase step 1 sweeps the stamp with its row")
    }
}
