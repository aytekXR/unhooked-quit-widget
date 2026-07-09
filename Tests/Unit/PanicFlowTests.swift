import Foundation
import StreakEngine
import SwiftData
import Testing
@testable import Unhooked

// E3.2 unit lane — panic flow + the §9-rule-2 write buffer. Plan-named tests are
// verbatim; the two exits are scope-adjusted per resume-prompt v2.1 §objective:
//   - `test_exitUrgePassed_logsUrgeEventAverted` goes THROUGH the write buffer
//     (append at exit → flush on repository start), never a store open from the
//     panic scene — the E3.1 zero-store spy pin is extended, not weakened;
//   - `test_exitSlipped_routesToSlipFlow` pins the ROUTING SEAM only (a named
//     handoff carrying quitID + source + stepsReached): E4.1 owns the slip flow
//     and its writes as one unit.
// Erase coverage for the buffer file lands HERE, in the same session the file is
// born (the Session 08→09 carry rule: every new App Group file joins the owned
// file-set sweep + a file-shaped sentinel test immediately).
// Red evidence for this file = the CI run on the red commit (app-lane mechanics).

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

/// Inert CloudKit-seam stub (the cloud policy is EraseEverythingTests' pin).
@MainActor
private final class StubCloudSync: CloudSyncControlling {
    func accountStatus() async -> CloudAccountStatus { .available }
    func deleteAllPrivateZones() async throws {}
}

/// The §3.1 haptics fake: records pattern-play calls so pacer logic is assertable
/// without CoreHaptics (real haptics are device-tier only).
@MainActor
private final class FakeHapticsEngine: HapticsPlaying {
    private(set) var patterns: [BreathPacerPattern] = []
    private(set) var celebrationTaps = 0
    func playBreathPattern(_ pattern: BreathPacerPattern) { patterns.append(pattern) }
    func playCelebrationTap() { celebrationTaps += 1 }
}

/// Records the slipped-exit handoffs (the E4.1 routing seam's observable).
@MainActor
private final class SlipRouteRecorder {
    private(set) var handoffs: [PanicSlipHandoff] = []
    func record(_ handoff: PanicSlipHandoff) { handoffs.append(handoff) }
}

/// One in-memory store + repository per test; the pre-cache store AND the outcome
/// buffer share a per-test temp directory standing in for the App Group root (the
/// repository derives the buffer's location from the pre-cache's directory).
@MainActor
private struct Harness {
    let container: ModelContainer
    let clock: ManualClock
    let spy: SpyWidgetRefresher
    let appGroupDefaults: UserDefaults
    let snapshotDirectory: URL
    let panicSnapshotStore: PanicSnapshotStore
    let outcomeBuffer: PanicOutcomeBuffer
    let repository: QuitRepository

    init() throws {
        container = try ModelContainer(
            for: PersistentStore.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        clock = ManualClock()
        spy = SpyWidgetRefresher()
        appGroupDefaults = UserDefaults(suiteName: "e32-group-\(UUID().uuidString)")!
        snapshotDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("e32-snap-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: snapshotDirectory, withIntermediateDirectories: true)
        panicSnapshotStore = PanicSnapshotStore(directoryURL: snapshotDirectory)
        outcomeBuffer = PanicOutcomeBuffer(directoryURL: snapshotDirectory)
        repository = QuitRepository(
            container: container,
            clock: clock,
            widgetRefresher: spy,
            lastKnownGoodStore: LastKnownGoodStore(
                defaults: UserDefaults(suiteName: "e32-lkg-\(UUID().uuidString)")!
            ),
            cloud: StubCloudSync(),
            appGroupDefaults: appGroupDefaults,
            panicSnapshotStore: panicSnapshotStore,
            debounceSleep: { _ in }
        )
    }

    func urgeEvents() throws -> [UrgeEvent] {
        try container.mainContext.fetch(FetchDescriptor<UrgeEvent>())
    }
}

/// Counting store-opener spy (the E3.1 init-order pin's instrument).
@MainActor
private final class StoreOpenSpy {
    private(set) var opens = 0
    private let prepared: ModelContainer?

    init(returning prepared: ModelContainer? = nil) {
        self.prepared = prepared
    }

    func open() throws -> ModelContainer {
        opens += 1
        if let prepared { return prepared }
        return try ModelContainer(
            for: PersistentStore.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
    }
}

/// Test-double bundle for the provider's `makeRepository` seam.
@MainActor
private struct RepoDoubles {
    let clock = ManualClock()
    let spy = SpyWidgetRefresher()
    let appGroupDefaults = UserDefaults(suiteName: "e32-provider-group-\(UUID().uuidString)")!
    let panicSnapshotStore: PanicSnapshotStore
    let outcomeBuffer: PanicOutcomeBuffer

    init() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("e32-provider-snap-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        panicSnapshotStore = PanicSnapshotStore(directoryURL: directory)
        outcomeBuffer = PanicOutcomeBuffer(directoryURL: directory)
    }

    func make(_ container: ModelContainer) -> QuitRepository {
        QuitRepository(
            container: container,
            clock: clock,
            widgetRefresher: spy,
            lastKnownGoodStore: LastKnownGoodStore(
                defaults: UserDefaults(suiteName: "e32-provider-lkg-\(UUID().uuidString)")!
            ),
            cloud: StubCloudSync(),
            appGroupDefaults: appGroupDefaults,
            panicSnapshotStore: panicSnapshotStore,
            debounceSleep: { _ in }
        )
    }
}

private func card(
    _ label: String?,
    id: UUID = UUID(),
    discreet: Bool = false,
    motivations: [String] = []
) -> QuitSnapshot {
    QuitSnapshot(id: id, label: label, discreet: discreet, motivations: motivations)
}

private func draft(
    id: UUID = UUID(),
    quitID: UUID?,
    outcome: UrgeOutcome = .averted,
    steps: [PanicStep] = [.breath],
    at: Date = epoch
) -> PanicOutcomeDraft {
    PanicOutcomeDraft(
        id: id, quitID: quitID, source: .lockscreenWidget,
        outcome: outcome, stepsReached: steps, at: at
    )
}

/// Inline script fixture for MODEL-mechanics tests only — deliberately test-tagged
/// strings so no shipping copy is duplicated (the shipping file itself is pinned by
/// `test_panicScript_decodesShippingFile_pacerAndExitsPinned` and rendered by the
/// snapshot lane, per the §3.2 "shipping files, never copies" rule).
private func fixtureScript() -> PanicScript {
    PanicScript(
        entryTitle: "t-entry",
        entryTitleDiscreet: "t-entry-discreet",
        steps: [
            .init(
                step: .breath, title: "t-breath", instruction: "t-breath-i",
                pacer: .init(inhaleSeconds: 4, holdSeconds: 7, exhaleSeconds: 8, cycles: 3, hapticGuided: true),
                hapticOnlyLabel: "t-haptic-only", subtext: nil, motivationsToken: nil,
                emptyFallback: nil, options: nil, skipLabel: "t-skip-breath"
            ),
            .init(
                step: .timer, title: "t-timer", instruction: "t-timer-i",
                pacer: nil, hapticOnlyLabel: nil, subtext: "t-sub", motivationsToken: nil,
                emptyFallback: nil, options: nil, skipLabel: "t-skip-timer"
            ),
            .init(
                step: .reasons, title: "t-reasons", instruction: "t-reasons-i",
                pacer: nil, hapticOnlyLabel: nil, subtext: nil, motivationsToken: "{{motivations}}",
                emptyFallback: "t-fallback", options: nil, skipLabel: "t-skip-reasons"
            ),
            .init(
                step: .redirect, title: "t-redirect", instruction: "t-redirect-i",
                pacer: nil, hapticOnlyLabel: nil, subtext: nil, motivationsToken: nil,
                emptyFallback: nil,
                options: [.init(id: "water", label: "t-water"), .init(id: "breathe", label: "t-breathe")],
                skipLabel: "t-skip-redirect"
            ),
        ],
        exits: [
            .init(id: "averted", label: "t-averted", labelDiscreet: "t-averted-d",
                  confirmation: "t-confirm", routesTo: nil),
            .init(id: "slipped", label: "t-slipped", labelDiscreet: "t-slipped-d",
                  confirmation: nil, routesTo: "slipFlow"),
        ]
    )
}

/// A flow model + its doubles, buffered into a per-test temp directory.
@MainActor
private struct FlowFixture {
    let clock: ManualClock
    let haptics = FakeHapticsEngine()
    let recorder = SlipRouteRecorder()
    let buffer: PanicOutcomeBuffer
    let model: PanicFlowModel

    init(
        quit: QuitSnapshot?,
        hapticsOnlyPacer: Bool = false,
        source: PanicSource = .lockscreenWidget,
        now: Date = epoch
    ) throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("e32-flow-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        clock = ManualClock(now: now)
        buffer = PanicOutcomeBuffer(directoryURL: directory)
        let recorder = recorder
        model = PanicFlowModel(
            quit: quit,
            script: fixtureScript(),
            source: source,
            hapticsOnlyPacer: hapticsOnlyPacer,
            clock: clock,
            haptics: haptics,
            buffer: buffer,
            onSlipRoute: { recorder.record($0) }
        )
    }
}

@MainActor
@Suite("E3.2 · panic flow + write buffer")
struct PanicFlowTests {

    // MARK: - The write buffer (append-only NDJSON, §9 rule 2)

    @Test func test_outcomeBuffer_appendIsDurableNDJSON_readsBackInOrder() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("e32-buf-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let buffer = PanicOutcomeBuffer(directoryURL: directory)

        let first = draft(quitID: UUID(), steps: [.breath, .timer])
        let second = draft(quitID: nil, outcome: .abandoned, at: epoch + 60)
        try buffer.append(first)
        try buffer.append(second)

        #expect(
            FileManager.default.fileExists(atPath: buffer.fileURL.path),
            "the append must be DURABLE at exit time — the on-disk half of §9 rule 2"
        )
        #expect(buffer.drafts() == [first, second], "append order is replay order")

        // Red guard: with nothing durable on disk there is nothing left to inspect —
        // the designed failures above already carry this test's red evidence.
        guard FileManager.default.fileExists(atPath: buffer.fileURL.path) else { return }
        let raw = try #require(String(data: Data(contentsOf: buffer.fileURL), encoding: .utf8))
        #expect(
            raw.hasSuffix("\n") && raw.split(separator: "\n").count == 2,
            "one JSON object per line (NDJSON): a torn write can only ever cost the newest outcome"
        )
    }

    @Test func test_outcomeBuffer_toleratesTornTailLine() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("e32-buf-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let buffer = PanicOutcomeBuffer(directoryURL: directory)
        let first = draft(quitID: UUID())
        let second = draft(quitID: nil, at: epoch + 30)
        // Seeded DIRECTLY (append's own contract is the sibling test's pin): this
        // test isolates the READER's torn-tail tolerance.
        let encoder = JSONEncoder()
        let lines = try encoder.encode(first) + Data("\n".utf8) + encoder.encode(second) + Data("\n".utf8)
        try lines.write(to: buffer.fileURL)

        // A crash mid-append leaves a torn final line — earlier outcomes must survive.
        let handle = try FileHandle(forWritingTo: buffer.fileURL)
        try handle.seekToEnd()
        try handle.write(contentsOf: Data("{\"id\":\"torn-mid-cra".utf8))
        try handle.close()

        #expect(
            buffer.drafts() == [first, second],
            "a torn tail line decodes as nothing and is skipped — 'a crash between panic exit and flush loses nothing' (§9 rule 2)"
        )
    }

    @Test func test_outcomeBuffer_clearRemovesOwnedFileOnly() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("e32-buf-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let buffer = PanicOutcomeBuffer(directoryURL: directory)
        try buffer.append(draft(quitID: nil))
        let sibling = directory.appendingPathComponent("unrelated-user-file.txt")
        try "keep me".write(to: sibling, atomically: true, encoding: .utf8)

        #expect(FileManager.default.fileExists(atPath: buffer.fileURL.path))
        try buffer.clear()
        #expect(!FileManager.default.fileExists(atPath: buffer.fileURL.path))
        #expect(
            FileManager.default.fileExists(atPath: sibling.path),
            "clear owns exactly ONE file — never the directory around it (E2.4 scope pin)"
        )
        try buffer.clear() // missing file = nothing to do, never a throw
    }

    // MARK: - Breath pacer (plan-named pattern model + §3.1 haptics seam)

    @Test func test_breathPacer_pattern_478_threeRounds() {
        let pattern = BreathPacerPattern(
            pacer: .init(inhaleSeconds: 4, holdSeconds: 7, exhaleSeconds: 8, cycles: 3, hapticGuided: true)
        )
        let phases = pattern.phases()

        #expect(phases.count == 9, "three rounds of inhale → hold → exhale")
        #expect(phases.map(\.kind) == [
            .inhale, .hold, .exhale, .inhale, .hold, .exhale, .inhale, .hold, .exhale,
        ])
        #expect(phases.map(\.duration) == [4, 7, 8, 4, 7, 8, 4, 7, 8], "4-7-8 — the pattern IS the therapy; never resequenced")
        #expect(phases.map(\.round) == [1, 1, 1, 2, 2, 2, 3, 3, 3])
        #expect(pattern.totalDuration == 57, "3 × (4+7+8)s — the ~90s flow budget's biggest block")

        #expect(pattern.phase(at: 0) == phases.first)
        #expect(pattern.phase(at: 3.9)?.kind == .inhale)
        #expect(pattern.phase(at: 4)?.kind == .hold, "phase boundaries belong to the NEXT phase")
        #expect(pattern.phase(at: 11)?.kind == .exhale)
        #expect(pattern.phase(at: 19)?.round == 2, "round 2 starts at 19s")
        #expect(pattern.phase(at: -1) == phases.first, "negative time clamps to the first phase — the pacer never renders nothing")
        #expect(pattern.phase(at: 57) == nil, "the pattern ends after 57s")
    }

    @Test func test_breathPacer_hapticsSeam_firesPatternInBothModes() throws {
        let visual = try FlowFixture(quit: card("Vaping"))
        #expect(
            visual.haptics.patterns.count == 1,
            "entering the breath step plays the haptic pattern once (hapticGuided pacer)"
        )
        #expect(visual.model.hapticsOnlyPacer == false)

        let hapticsOnly = try FlowFixture(quit: card("Vaping"), hapticsOnlyPacer: true)
        #expect(
            hapticsOnly.haptics.patterns.count == 1,
            "haptics-only changes what the SCREEN shows, never the rhythm — CoreHaptics carries the full 4-7-8 (brandkit §8)"
        )
        #expect(hapticsOnly.model.hapticsOnlyPacer == true)
    }

    // MARK: - Flow steps (plan-named)

    @Test func test_panicFlow_everyStepSkippable() throws {
        let f = try FlowFixture(quit: card("Vaping"))
        #expect(f.model.stage == .breath, "the first frame IS the pacer (zero decorative animation before it)")

        f.model.skip()
        #expect(f.model.stage == .timer)
        f.model.skip()
        #expect(f.model.stage == .reasons)
        f.model.skip()
        #expect(f.model.stage == .redirect)
        f.model.skip()
        #expect(f.model.stage == .exits, "PRD §6.4: skippable at any point — four skips land on the exit states")

        f.model.skip()
        #expect(f.model.stage == .exits, "there is nothing to skip past the exits")
        #expect(f.buffer.drafts().isEmpty, "skipping writes nothing — only an exit records an outcome")
    }

    @Test func test_panicFlow_recordsStepsReached() throws {
        let f = try FlowFixture(quit: card("Vaping"))
        #expect(f.model.stepsReached == [.breath], "the entry step is reached the moment the flow opens")

        f.model.skip()
        f.model.skip()
        #expect(f.model.stepsReached == [.breath, .timer, .reasons], "steps are recorded ON ENTRY, in order — a skipped-through step was still reached")

        f.model.skip() // → redirect
        f.model.selectRedirect("breathe")
        #expect(f.model.stage == .breath, "the 'one more round of breathing' option re-enters the pacer")
        #expect(
            f.model.stepsReached == [.breath, .timer, .reasons, .redirect],
            "re-entering a step never duplicates it — order recorded, not enforced"
        )

        f.model.skip()
        f.model.skip()
        f.model.skip() // back at redirect
        f.model.selectRedirect("water")
        #expect(f.model.stage == .exits, "a committed redirect has served its purpose — the flow closes at the exits")

        f.model.exitUrgePassed()
        #expect(
            f.buffer.drafts().first?.stepsReached == [.breath, .timer, .reasons, .redirect],
            "the buffered outcome carries the full reached set for §12.4 insights"
        )
    }

    @Test func test_reasonsStep_rendersVerbatimMotivations_fromPreCache() throws {
        // End to end from the pre-cache FILE: write → read → resolve → flow model,
        // exactly the cold panic route's path (the seam E3.1 landed).
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("e32-reasons-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let store = PanicSnapshotStore(directoryURL: directory)
        try store.write(PanicSnapshot(quits: [
            card("Vaping", motivations: ["money for the trip", "For my kids", "breathe easier"])
        ]))

        let cached = try #require(store.read())
        let presentation = PanicRouteResolver.resolve(selectedQuitID: nil, snapshot: cached)
        guard case .breathe(let quit) = presentation else {
            Issue.record("a single cached quit must resolve straight to its frame")
            return
        }

        let f = try FlowFixture(quit: quit)
        #expect(
            f.model.reasons == ["money for the trip", "For my kids", "breathe easier"],
            "motivations render VERBATIM in user order — never sorted, never edited, never truncated (brand rule; the user's words outrank ours)"
        )

        let empty = try FlowFixture(quit: card("Vaping", motivations: []))
        #expect(empty.model.reasons.isEmpty, "no captured motivations → the view falls back to the script's emptyFallback (never blank)")
    }

    // MARK: - Exits (plan-named, scope-adjusted per resume-prompt v2.1)

    @Test func test_exitUrgePassed_logsUrgeEventAverted() throws {
        // The full §9-rule-2 arc: exit → append-only buffer (panic side, storeless)
        // → flush on repository start (normal side) → UrgeEvent row + counter.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)

        let flowClock = ManualClock(now: epoch + 3_600)
        let haptics = FakeHapticsEngine()
        let flowBuffer = PanicOutcomeBuffer(directoryURL: h.snapshotDirectory)
        let model = PanicFlowModel(
            quit: card("Vaping", id: quit.id),
            script: fixtureScript(),
            source: .lockscreenWidget,
            clock: flowClock,
            haptics: haptics,
            buffer: flowBuffer,
            onSlipRoute: { _ in }
        )
        model.skip()
        model.exitUrgePassed()

        #expect(model.stage == .celebration, "urge passed → the quiet celebration")
        #expect(model.outcomeRecorded, "the outcome landed durably in the buffer")
        #expect(haptics.celebrationTaps == 1, "ONE soft haptic — never confetti (brandkit §7)")
        let buffered = try #require(
            flowBuffer.drafts().first,
            "the exit records through the WRITE BUFFER — never a store open from the panic scene"
        )
        #expect(flowBuffer.drafts().count == 1)
        #expect(buffered.outcome == .averted)
        #expect(buffered.quitID == quit.id)
        #expect(buffered.stepsReached == [.breath, .timer])
        #expect(buffered.at == epoch + 3_600, "the draft stamps the TRUE exit instant from the flow's clock")

        // The flush half — the repository derives the same buffer location from the
        // pre-cache directory, so this IS the same file.
        #expect(h.repository.flushPanicOutcomes() == 1)
        let events = try h.urgeEvents()
        #expect(events.count == 1)
        #expect(events.first?.outcome == .averted)
        #expect(events.first?.id == buffered.id, "the UrgeEvent adopts the draft's id — the dedupe key end to end")
        #expect(events.first?.quit?.id == quit.id)
        // Session 10 review pins: the flush's field mapping is the ONLY way this
        // data reaches the store — a dropped copy would silently blind §12.4.
        #expect(events.first?.stepsReached == [.breath, .timer], "the flushed event carries the draft's reached steps")
        #expect(events.first?.source == .lockscreenWidget, "the flushed event carries the draft's source")
        #expect(events.first?.at == epoch + 3_600)
        #expect(quit.avertedUrgeCount == 1, "averted increments the quit's counter exactly once")
        #expect(flowBuffer.drafts().isEmpty, "a successful flush consumes the buffer")
        #expect(h.panicSnapshotStore.read() != nil, "a flush is a mutating write — it rebuilds the pre-cache like every other write (ADR-6)")
    }

    @Test func test_exitSlipped_routesToSlipFlow() throws {
        let quitID = UUID()
        let f = try FlowFixture(quit: card("Vaping", id: quitID))
        f.model.skip() // → timer
        f.model.exitSlipped()

        #expect(
            f.recorder.handoffs == [
                PanicSlipHandoff(quitID: quitID, source: .lockscreenWidget, stepsReached: [.breath, .timer])
            ],
            "the slipped exit is a NAMED ROUTING SEAM carrying everything only the flow knows — E4.1 attaches its slip flow here"
        )
        #expect(
            f.buffer.drafts().isEmpty,
            "the panic scene writes NOTHING for a slip — E4.1 owns the slip flow and its writes as one unit (undo lifecycle included)"
        )
        #expect(f.model.stage != .celebration, "a slip is never celebrated — it routes, zero shame, zero fanfare")
    }

    // MARK: - The shipping script (bundled as-is; the flow's only copy source)

    @Test func test_panicScript_decodesShippingFile_pacerAndExitsPinned() throws {
        let script = try #require(
            PanicScript.loadShipping(),
            "the shipping panicScript.json must be bundled and decode AS-IS (§3.2: shipping files, never copies)"
        )
        let pacer = try #require(script.step(.breath)?.pacer)
        #expect(pacer.inhaleSeconds == 4 && pacer.holdSeconds == 7 && pacer.exhaleSeconds == 8)
        #expect(pacer.cycles == 3 && pacer.hapticGuided, "4-7-8 × 3, haptic-guided (PRD §6.4)")

        #expect(
            script.steps.map(\.step) == [.breath, .timer, .reasons, .redirect],
            "the script's step order mirrors the PanicStep sequence"
        )
        #expect(script.step(.reasons)?.motivationsToken == "{{motivations}}")
        #expect(
            script.step(.reasons)?.emptyFallback?.isEmpty == false,
            "the reasons step is never blank — the fallback ships in the script"
        )
        #expect(script.step(.breath)?.hapticOnlyLabel?.isEmpty == false, "haptics-only mode has its own instruction line")
        #expect(script.entryTitleDiscreet == "Take a moment.", "discreet entry carries zero habit context")
        #expect(script.exit("averted")?.confirmation?.isEmpty == false, "the quiet celebration renders the averted confirmation copy")
        #expect(script.exit("slipped")?.routesTo == "slipFlow")
        #expect(script.exit("slipped")?.labelDiscreet == "Log it")
    }

    // MARK: - Flush semantics (§9 rule 2: idempotent, timestamp-preserving, consuming)

    @Test func test_flush_preservesExitTimestamp_notFlushClock() throws {
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .alcohol)
        try h.outcomeBuffer.append(draft(quitID: quit.id, at: epoch - 7_200))
        h.clock.advance(by: 999_999)

        #expect(h.repository.flushPanicOutcomes() == 1)
        #expect(
            try h.urgeEvents().first?.at == epoch - 7_200,
            "the flushed event keeps the TRUE exit instant — §12.4 insights aggregate on urge timing, never on whenever the next launch ran"
        )
    }

    @Test func test_flush_isIdempotent_afterCrashBetweenSaveAndClear() throws {
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        let d = draft(quitID: quit.id)
        try h.outcomeBuffer.append(d)
        #expect(h.repository.flushPanicOutcomes() == 1)

        // A crash between save and clear replays the same draft on the next launch.
        try h.outcomeBuffer.append(d)
        #expect(
            h.repository.flushPanicOutcomes() == 0,
            "an already-landed draft id must not re-apply — the UrgeEvent adopted the draft's id exactly so replays dedupe"
        )
        #expect(try h.urgeEvents().count == 1)
        #expect(quit.avertedUrgeCount == 1, "monotonic counters never inflate through a replay (ADR-7 spirit)")
        #expect(h.outcomeBuffer.drafts().isEmpty, "the replayed buffer is still consumed")
    }

    @Test func test_flush_dropsDraftsForErasedQuits_keepsUnattributed() throws {
        let h = try Harness()
        let survivor = try h.repository.createQuit(habitCategory: .vape)
        try h.outcomeBuffer.append(draft(quitID: UUID())) // erased/unknown quit → DROP
        try h.outcomeBuffer.append(draft(quitID: nil, at: epoch + 10)) // zero-quit panic → keep
        try h.outcomeBuffer.append(draft(quitID: survivor.id, at: epoch + 20))

        #expect(
            h.repository.flushPanicOutcomes() == 2,
            "a draft for an erased quit must not resurrect behavioral data about it (the not-resurrected discipline); a zero-quit outcome is honest unattributed data"
        )
        let events = try h.urgeEvents()
        #expect(events.count == 2)
        #expect(events.contains { $0.quit == nil }, "the zero-quit outcome lands unattributed")
        #expect(events.contains { $0.quit?.id == survivor.id })
        #expect(survivor.avertedUrgeCount == 1, "only the attributed averted bumps its quit's counter")
        #expect(h.outcomeBuffer.drafts().isEmpty)
    }

    @Test func test_redirectBreatheOption_restartsThePacerRun() throws {
        // Session 10 review pin: the shipping "One more round of breathing" option
        // must start a FRESH pacer run — a stale start instant leaves the bloom
        // frozen past the 57s pattern, guiding nothing.
        let f = try FlowFixture(quit: card("Vaping"))
        f.model.markPacerStarted()
        let firstRun = f.model.pacerStartedAt
        #expect(firstRun != nil)

        f.clock.advance(by: 120) // long past the 57s pattern
        f.model.skip()
        f.model.skip()
        f.model.skip() // → redirect
        f.model.selectRedirect("breathe")

        #expect(f.model.pacerStartedAt == nil, "re-entering the pacer clears the run — the view's .task stamps a fresh start")
        f.model.markPacerStarted()
        #expect(f.model.pacerStartedAt == f.clock.now)
        #expect(f.model.pacerStartedAt != firstRun)
        #expect(f.haptics.patterns.count == 2, "the re-entered pacer replays its haptic rhythm")
    }

    @Test func test_flush_duplicateDraftIdsInOneBuffer_landOnce() throws {
        // Session 10 review pin: the exit-time append RETRY can double-write one
        // draft (the first write's bytes land but its fsync error surfaces late) —
        // the flush must land it once, not once per line.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        let d = draft(quitID: quit.id)
        try h.outcomeBuffer.append(d)
        try h.outcomeBuffer.append(d)

        #expect(h.repository.flushPanicOutcomes() == 1, "one outcome, twice on disk, lands ONCE")
        #expect(try h.urgeEvents().count == 1)
        #expect(quit.avertedUrgeCount == 1, "monotonic counters never inflate through a duplicated buffer line")
    }

    @Test func test_flush_emptyBuffer_isNoOp() async throws {
        // DECLARED green-from-birth regression guard (test-suite §7.1 exemption by
        // declaration): an empty flush is indistinguishable from the red skeleton by
        // construction — this test's value is protecting the common empty-buffer
        // launch from future churn; the red evidence lives in the sibling flush tests.
        let h = try Harness()
        _ = try h.repository.createQuit(habitCategory: .doomscroll)
        await h.repository.drainPendingWidgetReload()
        let reloadsBefore = h.spy.reloadCount
        let cacheBefore = try Data(contentsOf: h.panicSnapshotStore.fileURL)

        #expect(h.repository.flushPanicOutcomes() == 0)
        #expect(try h.urgeEvents().isEmpty)
        await h.repository.drainPendingWidgetReload()
        #expect(h.spy.reloadCount == reloadsBefore, "an empty buffer schedules zero widget churn at launch")
        #expect(
            try Data(contentsOf: h.panicSnapshotStore.fileURL) == cacheBefore,
            "a no-op flush rewrites nothing — not even a byte-identical pre-cache"
        )
    }

    @Test func test_launch_normalRoute_flushesBuffer_panicRouteNever() async throws {
        let doubles = try RepoDoubles()
        let container = try ModelContainer(
            for: PersistentStore.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        let quit = Quit()
        container.mainContext.insert(quit)
        try container.mainContext.save()
        try doubles.outcomeBuffer.append(draft(quitID: quit.id))

        let spy = StoreOpenSpy(returning: container)
        let provider = RepositoryProvider(
            storeOpener: { try spy.open() },
            makeRepository: { doubles.make($0) }
        )

        provider.startIfNeeded(for: .panicPlaceholder)
        #expect(spy.opens == 0, "the PANIC route never opens the store — the E3.1 pin, unweakened")
        #expect(
            doubles.outcomeBuffer.drafts().count == 1,
            "the panic route flushes NOTHING — the buffer waits for the normal route"
        )

        provider.startIfNeeded(for: .placeholderTabs)
        #expect(spy.opens == 1)
        #expect(
            doubles.outcomeBuffer.drafts().isEmpty,
            "the normal route's deferred start flushes the buffer — §9 rule 2: 'flushed into SwiftData as soon as the context is ready'"
        )
        let events = try container.mainContext.fetch(FetchDescriptor<UrgeEvent>())
        #expect(events.count == 1)
        #expect(events.first?.quit?.id == quit.id)

        // Session 10 review pin: a LANDING flush reloads widget timelines like every
        // other mutating write. This launch is otherwise non-mutating (single clean
        // quit — recompute merges/heals nothing; the refresh schedules no reload),
        // so only the flush's own schedule can produce this.
        let repository = try #require(provider.repository)
        await repository.drainPendingWidgetReload()
        #expect(doubles.spy.reloadCount == 1, "the flushed outcome must reach the widget without waiting for the next user write")
    }

    // MARK: - Erase coverage (same-session rule for every new App Group file)

    @Test func test_erase_removesPanicOutcomeBuffer_unownedSiblingSurvives() async throws {
        let h = try Harness()
        _ = try h.repository.createQuit(habitCategory: .weed)
        // Seeded DIRECTLY so this pin is independent of the append implementation
        // (the E3.1 erase pins seed the pre-cache the same way).
        try JSONEncoder().encode(draft(quitID: nil)).write(to: h.outcomeBuffer.fileURL)
        let sibling = h.snapshotDirectory.appendingPathComponent("unrelated-user-file.txt")
        try "keep me".write(to: sibling, atomically: true, encoding: .utf8)

        try await h.repository.eraseEverything()

        #expect(
            !FileManager.default.fileExists(atPath: h.outcomeBuffer.fileURL.path),
            "buffered urge outcomes are §10 'never leaves the device' data — one-tap erase must destroy the buffer file (the new file joins the owned set in its landing session)"
        )
        #expect(
            FileManager.default.fileExists(atPath: sibling.path),
            "the sweep is an owned FILE SET, never a directory (E2.4 scope pin)"
        )
    }

    @Test func test_panicOutcomeBuffer_notResurrectedByErase() async throws {
        let h = try Harness()
        _ = try h.repository.createQuit(habitCategory: .porn)
        try JSONEncoder().encode(draft(quitID: nil)).write(to: h.outcomeBuffer.fileURL)

        try await h.repository.eraseEverything()
        await h.repository.drainPendingWidgetReload()

        #expect(
            !FileManager.default.fileExists(atPath: h.outcomeBuffer.fileURL.path),
            "nothing after the erase sweep may rewrite the buffer — erased means absent until a NEW panic outcome"
        )
        #expect(h.outcomeBuffer.drafts().isEmpty)
    }
}
