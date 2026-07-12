import Foundation
import StreakEngine
import SwiftData
import Testing
@testable import Unhooked

// E7.2 (R25.5/R25.7) — the repository halves of the teaser + echo: the ONE
// writer of `AppSettings.teaserExpiresAt` stamps the 1-day grant from the
// INJECTED clock (no ambient Date anywhere), the ONE writer of
// `paywallVariantAssigned` round-trips the live echo, and one-tap erase's
// step-1 row sweep wipes BOTH — an erased device re-enters the funnel with
// no teaser residue and no stale assignment echo (fresh-install semantics;
// the sweep pin holds regardless of writer, so it is seeded directly).
//
// The Harness is the EntitlementEraseWiringTests shape, narrowed (the
// no-shared-fixtures convention) — in-memory store, manual clock, one
// repository per test.
//
// RED: `enterTeaser()` and `setPaywallVariantAssigned` are inert no-ops —
// the write pins fail by design; the erase-sweep pin is born-green (erase
// already deletes every AppSettings row) and stands as the permanent
// strengthen.

// Fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z.
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)
private let bootA = UUID(uuidString: "0B00071D-A000-4000-8000-000000000E72")!

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

    init(clock: ManualClock = ManualClock()) throws {
        container = try ModelContainer(
            for: PersistentStore.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        let snapshotDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("e72-teaser-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: snapshotDirectory, withIntermediateDirectories: true)
        repository = QuitRepository(
            container: container,
            clock: clock,
            widgetRefresher: SpyWidgetRefresher(),
            lastKnownGoodStore: LastKnownGoodStore(
                defaults: UserDefaults(suiteName: "e72-lkg-\(UUID().uuidString)")!
            ),
            cloud: NoopCloudSync(),
            appGroupDefaults: UserDefaults(suiteName: "e72-group-\(UUID().uuidString)")!,
            panicSnapshotStore: PanicSnapshotStore(directoryURL: snapshotDirectory),
            quizProgressStore: QuizProgressStore(
                defaults: UserDefaults(suiteName: "e72-quiz-\(UUID().uuidString)")!
            ),
            trialDedupeStore: TrialAnalyticsDedupeStore(
                defaults: UserDefaults(suiteName: "e72-dedupe-\(UUID().uuidString)")!
            ),
            debounceSleep: { _ in }
        )
    }
}

@MainActor
@Suite("E7.2 · teaser + variant-echo repository wiring")
struct TeaserWiringTests {
    /// Designed-red: the teaser take stamps expiry exactly one grant-length
    /// past the INJECTED clock's now — never an ambient Date read.
    @Test func test_enterTeaser_stampsExpiry_oneDayFromInjectedClock() throws {
        let h = try Harness()

        try h.repository.enterTeaser()

        #expect(
            h.repository.teaserExpiresAt() == epoch.addingTimeInterval(86_400),
            "the ONE writer stamps TeaserPolicy.expiry(from: clock.now) — 24h wall-clock duration (R25.7)"
        )
    }

    /// Designed-red: the live-assignment echo round-trips through the store
    /// (test-suite §4.4's named field; "" = never assigned).
    @Test func test_setPaywallVariantAssigned_roundTrips() throws {
        let h = try Harness()
        #expect(h.repository.paywallVariantAssigned() == "", "fresh install: never assigned")

        try h.repository.setPaywallVariantAssigned("teaser")

        #expect(h.repository.paywallVariantAssigned() == "teaser")
    }

    /// Born-green strengthen (the permanent sweep pin): one-tap erase wipes
    /// the teaser grant AND the assignment echo — seeded directly at the
    /// store so the pin holds regardless of the writers' state. Post-erase
    /// is a fresh install: no teaser residue, no stale echo (R25.5/R25.7).
    @Test func test_erase_wipesTeaserGrantAndVariantEcho() async throws {
        let h = try Harness()
        let settings = AppSettings()
        settings.teaserExpiresAt = epoch
        settings.paywallVariantAssigned = "teaser"
        h.container.mainContext.insert(settings)
        try h.container.mainContext.save()

        try await h.repository.eraseEverything()

        #expect(h.repository.teaserExpiresAt() == nil, "erase step 1 sweeps the grant")
        #expect(h.repository.paywallVariantAssigned() == "", "erase step 1 sweeps the echo")
    }
}
