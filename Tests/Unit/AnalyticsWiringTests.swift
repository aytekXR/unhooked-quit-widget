import Foundation
import SwiftData
import Testing
@testable import Unhooked

// E8.1 · analytics wiring at the repository seams — `urge_averted` (warm + cold
// arms) and `slip_undone`. Every fire is post-save, quit-guarded, and BESIDE the
// durable write (Architect ruling, Session 15: analytics may never block or fail a
// write — §1.2 invariant 3). `slip_logged` wiring is DEFERRED to its own session
// (the four-arm post-save placement in the same ruling); `panic_opened` /
// `panic_step_reached` / `erase_all_completed` are deferred with named reasons in
// the Session 15 ledger — nothing here may fire them.
//
// Red evidence for this file = the CI run on the red commit: the analytics seam
// param exists but no repository write fires an event yet, so the three wiring
// tests fail through their DESIGNED spy-empty assertion (never a compile error).
//
// Harness/ManualClock/SpyWidgetRefresher/StubCloudSync are the E2.2 conventions from
// QuitRepositoryTests; the buffer shares the pre-cache directory exactly the way the
// repository derives it (the SlipFlushTests precedent). Fixture epoch is the
// test-suite §3.2 constant.

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

    /// Real time passes: wall and uptime advance together.
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

/// The typed-event spy (test-suite §3.1 `SpyAnalyticsSink`) — file-local copy, the
/// house no-shared-fixtures convention.
@MainActor
private final class SpyAnalyticsSink: AnalyticsSink {
    private(set) var received: [AnalyticsEvent] = []
    func receive(_ event: AnalyticsEvent) { received.append(event) }
}

/// One in-memory store + repository per test, with the analytics seam injected the
/// way production will inject it: the CONCRETE gated facade over a spy transport —
/// so these tests exercise gate + seam together, end-to-end in-process.
@MainActor
private struct Harness {
    let container: ModelContainer
    let clock: ManualClock
    let analyticsSpy: SpyAnalyticsSink
    let repository: QuitRepository
    let buffer: PanicOutcomeBuffer

    init(optedIn: Bool = true) throws {
        let cacheDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("e81-wiring-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        container = try ModelContainer(
            for: PersistentStore.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        clock = ManualClock()
        analyticsSpy = SpyAnalyticsSink()
        buffer = PanicOutcomeBuffer(directoryURL: cacheDirectory)
        repository = QuitRepository(
            container: container,
            clock: clock,
            widgetRefresher: SpyWidgetRefresher(),
            lastKnownGoodStore: LastKnownGoodStore(
                defaults: UserDefaults(suiteName: "e81-wiring-lkg-\(UUID().uuidString)")!
            ),
            cloud: StubCloudSync(),
            appGroupDefaults: UserDefaults(suiteName: "e81-wiring-group-\(UUID().uuidString)")!,
            panicSnapshotStore: PanicSnapshotStore(directoryURL: cacheDirectory),
            debounceSleep: { _ in },
            analytics: AnalyticsService(sink: analyticsSpy, isOptedIn: { optedIn })
        )
    }
}

/// A buffered `.averted` draft (the cold flow's "The urge passed" exit, flushed later).
private func avertedDraft(id: UUID = UUID(), quitID: UUID?, at: Date) -> PanicOutcomeDraft {
    PanicOutcomeDraft(
        id: id, quitID: quitID, source: .controlCenter, outcome: .averted,
        stepsReached: [.breath], at: at,
        capturedUptime: nil, capturedBootID: nil,
        capturedWitnessBootID: nil, capturedWitnessUptime: nil,
        capturedWitnessWallClock: nil, revokesDraftID: nil
    )
}

@MainActor
@Suite("E8.1 · analytics wiring — urge_averted + slip_undone")
struct AnalyticsWiringTests {

    // MARK: - urge_averted, warm arm (logUrgeEvent)

    @Test func test_urgeAverted_firesOncePerAvertedOutcome_warmRoute() throws {
        let harness = try Harness()
        let quit = try harness.repository.createQuit(habitCategory: .vape)

        try harness.repository.logUrgeEvent(quitID: quit.id, source: .inApp, outcome: .averted)
        #expect(
            harness.analyticsSpy.received == [.urgeAverted(habitCategory: .vape)],
            "an averted warm outcome fires urge_averted with the quit's category, post-save (MVP §5)"
        )

        try harness.repository.logUrgeEvent(quitID: quit.id, source: .inApp, outcome: .abandoned)
        #expect(
            harness.analyticsSpy.received.count == 1,
            "abandoned sessions fire nothing — urge_averted means the averted exit only (MVP §5 trigger)"
        )
    }

    // MARK: - urge_averted, cold arm (flushPanicOutcomes)

    @Test func test_urgeAverted_firesFromColdFlush_onlyForLandedAttributedDrafts() throws {
        let harness = try Harness()
        let quit = try harness.repository.createQuit(habitCategory: .doomscroll)

        // Three drafts, one fires: attributed averted → event; nil-quit averted lands
        // honestly unattributed [R-NILQUIT] but urge_averted(habit_category) is not
        // constructible without a quit — fires nothing; unknown-quit drafts are
        // DROPPED (erased means erased) — fires nothing.
        try harness.buffer.append(avertedDraft(quitID: quit.id, at: epoch + 60))
        try harness.buffer.append(avertedDraft(quitID: nil, at: epoch + 90))
        try harness.buffer.append(avertedDraft(quitID: UUID(), at: epoch + 120))

        harness.repository.flushPanicOutcomes()
        #expect(
            harness.analyticsSpy.received == [.urgeAverted(habitCategory: .doomscroll)],
            "the cold flush fires urge_averted once per LANDED attributed averted row, after the commit point"
        )

        harness.repository.flushPanicOutcomes()
        #expect(
            harness.analyticsSpy.received.count == 1,
            "a re-flush is a no-op (consumed buffer, id dedupe) — replays must never double-count the funnel"
        )
    }

    // MARK: - slip_undone (undoSlip, true arm only)

    @Test func test_slipUndone_firesOnlyOnRealUndo() throws {
        let harness = try Harness()
        let quit = try harness.repository.createQuit(habitCategory: .alcohol)
        harness.clock.advance(by: 3_600)

        let slip = try harness.repository.logSlip(quitID: quit.id, note: nil)
        #expect(
            harness.analyticsSpy.received.isEmpty,
            "logSlip fires nothing in E8.1 — slip_logged is post-undo-window and its four-arm wiring is a deferred session (Architect ruling)"
        )

        let undone = try harness.repository.undoSlip(slipID: slip.id)
        #expect(undone, "fixture sanity: the undo happens inside the 10-minute window")
        #expect(
            harness.analyticsSpy.received == [.slipUndone],
            "a real undo fires slip_undone (property-less, MVP §5), post-save"
        )

        harness.clock.advance(by: 3_600)
        let secondSlip = try harness.repository.logSlip(quitID: quit.id, note: nil)
        harness.clock.advance(by: 700) // past the 10-minute window
        let lateUndo = try harness.repository.undoSlip(slipID: secondSlip.id)
        #expect(!lateUndo, "fixture sanity: the window has closed")
        #expect(
            harness.analyticsSpy.received == [.slipUndone],
            "the past-window calm no-op finalizes without firing — only a REAL undo is a slip_undone"
        )
    }

    // MARK: - The gate holds at the seams (companion pin; meaningful at green)

    @Test func test_wiring_respectsConsentGate_endToEnd() throws {
        let harness = try Harness(optedIn: false)
        let quit = try harness.repository.createQuit(habitCategory: .weed)

        try harness.repository.logUrgeEvent(quitID: quit.id, source: .inApp, outcome: .averted)
        harness.clock.advance(by: 3_600)
        let slip = try harness.repository.logSlip(quitID: quit.id, note: nil)
        _ = try harness.repository.undoSlip(slipID: slip.id)

        #expect(
            harness.analyticsSpy.received.isEmpty,
            "opted-out, the seams transmit nothing — zero events before consent is the ADR-8 hard rule, enforced at the ONE gate the seams share"
        )
    }
}
