import Foundation
import StreakEngine
import SwiftData
import Testing
@testable import Unhooked

// E8.2 unit lane — consent persistence at the repository seam, SwiftData tier:
// the two plan-named tests (`test_consentDefaultsToOff`,
// `test_analyticsEventsBlockedBeforeConsent`) plus the setter/live-gate/erase
// pins over the settled repository contract — `isAnalyticsOptedIn()` (fetch-only
// fail-closed read, the onboardingVariant/isAgeGatePassed precedent) and
// `setAnalyticsOptIn(_:)` (the markAgeGatePassed shape: the SHARED
// fetchOrCreateAppSettings singleton helper + synchronous save; Architect
// MUST-FIX #6, Session 16, honored). The live-gate case proves ONE
// AnalyticsService instance whose isOptedIn closure reads the repository flips
// behavior when the stored consent flips — the property that retires the
// composition root's hardwired `isOptedIn: { false }`.
//
// RED: the repository stubs are deliberately inert (reader always false, setter
// a no-op) so this suite COMPILES and the designed failures are assertion
// misses. Red evidence for this file = the CI run on the red commit (SwiftData
// is CI-only; the pure gate lane is Linux-harnessed in ConsentGateTests).
//
// Harness/ManualClock/SpyWidgetRefresher/StubCloudSync are the E2.2 conventions,
// copied verbatim from QuizCompletionTests (the proven in-memory-container +
// real-repository shape). Fixture epoch is the test-suite §3.2 constant.

// Fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z.
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)
private let baseUptime: TimeInterval = 50_000
private let bootA = UUID(uuidString: "0B00071D-A000-4000-8000-000000000001")!

/// Manual test clock (test-suite §3.1): wall and monotonic evidence move only when told.
@MainActor
private final class ManualClock: ClockProviding {
    var now: Date
    var monotonicNow: MonotonicNow

    init(now: Date = epoch, bootID: UUID = bootA, uptime: TimeInterval = baseUptime) {
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

/// Inert CloudKit-seam stub (E2.4 init plumbing): erase's cloud step is a no-op here.
@MainActor
private final class StubCloudSync: CloudSyncControlling {
    func accountStatus() async -> CloudAccountStatus { .available }
    func deleteAllPrivateZones() async throws {}
}

/// The typed-event spy (test-suite §3.1) — file-local copy, the house
/// no-shared-fixtures convention.
@MainActor
private final class SpyAnalyticsSink: AnalyticsSink {
    private(set) var received: [AnalyticsEvent] = []
    func receive(_ event: AnalyticsEvent) { received.append(event) }
}

/// One in-memory store + repository per test (the QuizCompletionTests shape).
@MainActor
private struct Harness {
    let container: ModelContainer
    let clock: ManualClock
    let analyticsSpy: SpyAnalyticsSink
    let appGroupDefaults: UserDefaults
    let panicSnapshotStore: PanicSnapshotStore
    let repository: QuitRepository

    init() throws {
        let cacheDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("e82-consent-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        container = try ModelContainer(
            for: PersistentStore.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        clock = ManualClock()
        analyticsSpy = SpyAnalyticsSink()
        appGroupDefaults = UserDefaults(suiteName: "e82-consent-group-\(UUID().uuidString)")!
        panicSnapshotStore = PanicSnapshotStore(directoryURL: cacheDirectory)
        repository = QuitRepository(
            container: container,
            clock: clock,
            widgetRefresher: SpyWidgetRefresher(),
            lastKnownGoodStore: LastKnownGoodStore(
                defaults: UserDefaults(suiteName: "e82-consent-lkg-\(UUID().uuidString)")!
            ),
            cloud: StubCloudSync(),
            appGroupDefaults: appGroupDefaults,
            panicSnapshotStore: panicSnapshotStore,
            debounceSleep: { _ in },
            analytics: AnalyticsService(sink: analyticsSpy, isOptedIn: { false })
        )
    }
}

@MainActor
@Suite("E8.2 · consent persistence + live composition")
struct ConsentPersistenceTests {

    // MARK: - PLAN-NAMED test 1: consent defaults to OFF (ADR-8; the fetch-only
    // fail-closed read — no row, no value, an error all read OFF)

    @Test func test_consentDefaultsToOff() throws {
        let harness = try Harness()
        #expect(
            harness.repository.isAnalyticsOptedIn() == false,
            "a fresh install reads consent OFF — default off until answered (MVP §5 / ADR-8)"
        )
    }

    // MARK: - Setter pin: the write rides the SHARED singleton helper

    @Test func test_setAnalyticsOptIn_persistsThroughSingletonHelper() throws {
        let harness = try Harness()
        try harness.repository.setAnalyticsOptIn(true)
        #expect(
            harness.repository.isAnalyticsOptedIn() == true,
            "the setter persists the choice to AppSettings.analyticsOptIn"
        )

        let fresh = ModelContext(harness.container)
        let rows = try fresh.fetch(FetchDescriptor<AppSettings>())
        #expect(
            rows.count == 1,
            "the setter shares fetchOrCreateAppSettings — never a second AppSettings row (Architect MUST-FIX #6, Session 16)"
        )
        #expect(rows.first?.analyticsOptIn == true, "the durable row carries the choice")

        try harness.repository.setAnalyticsOptIn(false)
        #expect(
            harness.repository.isAnalyticsOptedIn() == false,
            "a decline (or a changed mind) round-trips the same way"
        )
    }

    // MARK: - PLAN-NAMED test 2: analytics events are BLOCKED before consent

    @Test func test_analyticsEventsBlockedBeforeConsent() throws {
        let harness = try Harness()
        let service = AnalyticsService(
            sink: harness.analyticsSpy,
            isOptedIn: { harness.repository.isAnalyticsOptedIn() }
        )
        service.fire(.quizCompleted(habitCategory: .vape, goalMode: .quit))
        service.fire(.urgeAverted(habitCategory: .vape))
        #expect(
            harness.analyticsSpy.received.isEmpty,
            "zero events before consent — the repository-backed live gate drops everything by default"
        )
    }

    // MARK: - Live-gate pin: ONE service instance, the stored consent write flips
    // subsequent fires — the property that retires `isOptedIn: { false }`

    @Test func test_consentWrite_flipsLiveGate_sameServiceInstance() throws {
        let harness = try Harness()
        let service = AnalyticsService(
            sink: harness.analyticsSpy,
            isOptedIn: { harness.repository.isAnalyticsOptedIn() }
        )
        service.fire(.slipUndone)
        #expect(harness.analyticsSpy.received.isEmpty, "pre-consent: dropped")

        try harness.repository.setAnalyticsOptIn(true)
        service.fire(.slipUndone)
        #expect(
            harness.analyticsSpy.received == [.slipUndone],
            "the SAME service instance transmits after the stored opt-in — fire() re-reads consent live, so a mid-run opt-in governs later fires"
        )
    }

    // MARK: - Resume-prompt pin: erase resets consent to OFF (rides the existing
    // AppSettings row deletion — no new erase code)

    @Test func test_erase_resetsConsentToOff() async throws {
        let harness = try Harness()
        try harness.repository.setAnalyticsOptIn(true)
        #expect(harness.repository.isAnalyticsOptedIn() == true, "precondition: opted in")

        try await harness.repository.eraseEverything()
        #expect(
            harness.repository.isAnalyticsOptedIn() == false,
            "erase deletes the AppSettings row; the fetch-only reader returns the fresh default — consent is OFF, the re-onboarding user is re-asked"
        )
    }
}
