import Foundation
import StreakEngine
import SwiftData
import Testing
@testable import Unhooked

// E4.1 unit lane — the two-tap slip flow + 10-minute undo as ONE unit (mvp feature #3).
// SlipFlowModel serves both routes; every behavior difference is the SlipRoute write
// target (decision record §UI). These tests are written against the RED stubs
// (SlipFlowModel.confirm()/undo()/noteChanged() no-op; undoAvailable false; logSlip
// still writes isPendingUndo=false; undoSlip/finalizePendingSlips/updateSlipNote inert)
// and FAIL on them via their designed assertions — the green commit lands the behavior.
// Red evidence for this file = the CI run on the red commit (app-lane mechanics).
//
// Conventions copied from Tests/Unit/QuitRepositoryTests.swift: private Harness, private
// ManualClock, the 2026-07-07T12:00:00Z fixture epoch, bootA/bootB UUID constants, and
// time driven ONLY through the injected clock (never Date()).

// Fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z.
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)
private let day = 86_400
private let baseUptime: TimeInterval = 50_000
private let bootA = UUID(uuidString: "0B00071D-A000-4000-8000-000000000001")!
private let bootB = UUID(uuidString: "0B00071D-B000-4000-8000-000000000002")!

/// Manual test clock (test-suite §3.1): wall and monotonic evidence move only when told.
@MainActor
private final class ManualClock: ClockProviding {
    var now: Date
    var monotonicNow: MonotonicNow

    init(now: Date = epoch, bootID: UUID = bootA, uptime: TimeInterval = 50_000) {
        self.now = now
        self.monotonicNow = MonotonicNow(bootID: bootID, uptime: uptime)
    }

    /// Real time passes: wall and uptime advance together.
    func advance(by seconds: TimeInterval) {
        now += seconds
        monotonicNow.uptime += seconds
    }

    /// The user drags the wall clock; uptime is unaffected.
    func setWallClock(_ date: Date) { now = date }

    /// Reboot: new boot session, uptime restarts.
    func reboot(bootID: UUID, uptime: TimeInterval) {
        monotonicNow = MonotonicNow(bootID: bootID, uptime: uptime)
    }
}

@MainActor
private final class SpyWidgetRefresher: WidgetRefreshing {
    private(set) var reloadCount = 0
    func reloadAllTimelines() { reloadCount += 1 }
}

/// Inert CloudKit-seam stub (nothing here exercises the cloud policy).
@MainActor
private final class StubCloudSync: CloudSyncControlling {
    func accountStatus() async -> CloudAccountStatus { .available }
    func deleteAllPrivateZones() async throws {}
}

// MARK: - Fixtures

/// Test-tagged slip copy — deliberately NOT the shipping strings (§3.2: no shipping copy
/// is duplicated; `SlipCopy.loadShipping()` returns nil until the file is bundled, so the
/// model is fed an explicit fixture here).
private func fixtureCopy() -> SlipCopy {
    SlipCopy(
        confirm: .init(
            title: "t-confirm-title", body: "t-confirm-body",
            confirmLabel: "t-log", cancelLabel: "t-cancel", retryNote: "t-retry"
        ),
        logged: .init(title: "t-logged-title", body: "t-logged-body", bodyNoBest: "t-logged-nobest"),
        reflection: .init(prompt: "t-prompt", placeholder: "t-placeholder", skipLabel: "t-skip", saveLabel: "t-save"),
        undo: .init(banner: "t-banner", undoLabel: "t-undo", windowNote: "t-window", undoneConfirmation: "t-undone"),
        encouragement: ["t-enc"],
        motivationEcho: "t-echo"
    )
}

/// A pre-cache card with the E4.1 additive streak fields populated (the framing source).
/// Legacy/degraded cards pass the additive fields as nil.
private func coldCard(
    id: UUID = UUID(),
    discreet: Bool = false,
    motivations: [String] = ["m1"],
    startAt: Date? = epoch,
    anchorBootID: UUID? = bootA,
    anchorUptime: TimeInterval? = baseUptime,
    bestStreakSeconds: Int? = 0,
    momentumPercent: Int? = nil
) -> QuitSnapshot {
    QuitSnapshot(
        id: id, label: "Vaping", discreet: discreet, motivations: motivations,
        startAt: startAt, anchorBootID: anchorBootID, anchorUptime: anchorUptime,
        bestStreakSeconds: bestStreakSeconds, momentumPercent: momentumPercent
    )
}

private func makeTempDir() throws -> URL {
    let dir = FileManager.default.temporaryDirectory
        .appendingPathComponent("e41-slip-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    return dir
}

/// A cold-route SlipFlowModel wired over a REAL buffer in a throwaway directory, a
/// ManualClock, and a LastKnownGood witness over a throwaway defaults suite — the
/// store never opens on this route by contract (SlipRoute.cold carries no repository).
@MainActor
private struct ColdKit {
    let clock: ManualClock
    let buffer: PanicOutcomeBuffer
    let witness: LastKnownGoodStore
    let model: SlipFlowModel
    let directory: URL
}

@MainActor
private func makeCold(
    card: QuitSnapshot?,
    handoff: PanicSlipHandoff,
    witnessAnchor: MonotonicAnchor? = nil,
    clock: ManualClock = ManualClock()
) throws -> ColdKit {
    let dir = try makeTempDir()
    let buffer = PanicOutcomeBuffer(directoryURL: dir)
    let witness = LastKnownGoodStore(defaults: UserDefaults(suiteName: "e41-lkg-\(UUID().uuidString)")!)
    if let witnessAnchor { witness.save(witnessAnchor) }
    let model = SlipFlowModel(
        route: .cold(handoff: handoff, card: card, buffer: buffer, witnessStore: witness),
        copy: fixtureCopy(),
        clock: clock
    )
    return ColdKit(clock: clock, buffer: buffer, witness: witness, model: model, directory: dir)
}

/// One in-memory store + repository per test — the QuitRepositoryTests Harness pattern,
/// trimmed to what the store-route slip flow needs.
@MainActor
private struct StoreHarness {
    let container: ModelContainer
    let clock: ManualClock
    let repository: QuitRepository

    init() throws {
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
                defaults: UserDefaults(suiteName: "e41-store-lkg-\(UUID().uuidString)")!
            ),
            cloud: StubCloudSync(),
            appGroupDefaults: UserDefaults(suiteName: "e41-store-group-\(UUID().uuidString)")!,
            panicSnapshotStore: PanicSnapshotStore(
                directoryURL: FileManager.default.temporaryDirectory
                    .appendingPathComponent("e41-store-snap-\(UUID().uuidString)", isDirectory: true)
            ),
            debounceSleep: { _ in }
        )
    }
}

@MainActor
@Suite("E4.1 · slip flow (cold + store routes)")
struct SlipFlowModelTests {

    // MARK: - Cold route: confirm writes the buffer (the ONE cold write boundary, [R1])

    @Test func test_coldConfirm_appendsSlippedDraft_withCapturedTuple_beforeLoggedStage() throws {
        let quitID = UUID()
        let handoff = PanicSlipHandoff(quitID: quitID, source: .lockscreenWidget, stepsReached: [.breath, .timer])
        let kit = try makeCold(
            card: coldCard(id: quitID),
            handoff: handoff,
            // A witness DISTINCT from the flow clock's own reading — proves confirm reads
            // the App Group witness store [R-WIT], not the live monotonic reading.
            witnessAnchor: MonotonicAnchor(bootID: bootB, uptime: 60_000, wallClock: epoch - 1_000)
        )
        kit.model.confirm()

        let d = try #require(
            kit.buffer.drafts().first,
            "tap 2 appends the .slipped draft + fsync BEFORE the stage advances (the one cold write boundary [R1])"
        )
        #expect(kit.buffer.drafts().count == 1)
        #expect(d.outcome == .slipped)
        #expect(d.quitID == handoff.quitID, "quitID rides the handoff")
        #expect(d.source == handoff.source)
        #expect(d.stepsReached == handoff.stepsReached)
        #expect(d.at == epoch, "stamped at the flow clock's slip instant, never the flush clock")
        #expect(d.capturedUptime == baseUptime, "the monotonic reading AT SLIP TIME [R-WIT]")
        #expect(d.capturedBootID == bootA)
        #expect(d.capturedWitnessBootID == bootB, "the witness AT SLIP TIME, read store-free from App Group defaults [R-WIT]")
        #expect(d.capturedWitnessUptime == 60_000)
        #expect(d.capturedWitnessWallClock == epoch - 1_000)
        #expect(d.revokesDraftID == nil, "a first slip is not a revocation")
        #expect(kit.model.stage == .logged, "only after the durable append does the UI reach the forgiveness screen")
        #expect(kit.model.loggedSlipID == d.id, "the published slip id IS the buffered draft's id (== the deferred UrgeEvent's id)")
    }

    @Test func test_coldConfirm_capturesNilWitnessAsNil() throws {
        let quitID = UUID()
        // No witness saved — the App Group witness is empty at slip time.
        let kit = try makeCold(
            card: coldCard(id: quitID),
            handoff: PanicSlipHandoff(quitID: quitID, source: .inApp, stepsReached: [])
        )
        kit.model.confirm()

        let d = try #require(kit.buffer.drafts().first, "cold confirm appends the .slipped draft")
        #expect(d.capturedWitnessBootID == nil)
        #expect(d.capturedWitnessUptime == nil)
        #expect(
            d.capturedWitnessWallClock == nil,
            "an empty witness captures nil — matching a live logSlip with lastKnownGood nil (no invented baseline)"
        )
    }

    @Test func test_coldConfirm_appendFailure_staysConfirming_showsRetryNote() throws {
        // Point the buffer at an impossible location: a directoryURL that is an existing
        // FILE, so createDirectory/append throws on every attempt (including the retry).
        let parent = try makeTempDir()
        let fileAsDir = parent.appendingPathComponent("occupied-\(UUID().uuidString)")
        try Data().write(to: fileAsDir)
        let buffer = PanicOutcomeBuffer(directoryURL: fileAsDir)
        let witness = LastKnownGoodStore(defaults: UserDefaults(suiteName: "e41-lkg-\(UUID().uuidString)")!)
        let model = SlipFlowModel(
            route: .cold(
                handoff: PanicSlipHandoff(quitID: UUID(), source: .inApp, stepsReached: []),
                card: coldCard(),
                buffer: buffer,
                witnessStore: witness
            ),
            copy: fixtureCopy(),
            clock: ManualClock()
        )
        model.confirm()

        #expect(
            model.retryNoteVisible,
            "a failed durable append keeps the confirm stage with the calm retry note — a slip is §9-rule-1 class, 'Logged.' is never claimed without durable bytes"
        )
    }

    // MARK: - Cold route: forgiveness framing (pure engine math over the card fields)

    @Test(arguments: [(10, 10), (1, 3)])
    func test_coldFraming_bestIsMaxOfCardBestAndGuardedEnded_momentumUnchanged(
        cardBestDays: Int, expectedBestDays: Int
    ) throws {
        // elapsed is 3d in both rows; best' = max(card best, ended): card best 10d wins,
        // card best 1d loses to the 3d ended. Momentum is UNCHANGED across a slip (S04).
        let quitID = UUID()
        let kit = try makeCold(
            card: coldCard(
                id: quitID, motivations: ["m1", "m2"],
                bestStreakSeconds: cardBestDays * day, momentumPercent: 42
            ),
            handoff: PanicSlipHandoff(quitID: quitID, source: .inApp, stepsReached: [])
        )
        kit.clock.advance(by: TimeInterval(3 * day))
        kit.model.confirm()

        let framing = try #require(kit.model.framing, "cold confirm computes the forgiveness framing")
        #expect(framing.endedStreakSeconds == 3 * day, "ended = guarded elapsed from the card anchor at the flow clock")
        #expect(framing.bestStreakSeconds == expectedBestDays * day, "best' = max(card best, ended)")
        #expect(framing.momentumPercent == 42, "momentum is UNCHANGED in the same tick across the slip (ratified S04)")
        #expect(framing.motivation == "m1", "the motivation echo is the user's FIRST motivation, verbatim")
    }

    @Test func test_coldFraming_degradedCard_missingFields_yieldsNilNumbers_notInventedOnes() throws {
        // A stale pre-E4.1 cache: additive fields nil. The framing degrades to the
        // no-numbers copy — it never invents a stale number.
        let quitID = UUID()
        let kit = try makeCold(
            card: coldCard(
                id: quitID, startAt: nil, anchorBootID: nil, anchorUptime: nil,
                bestStreakSeconds: nil, momentumPercent: nil
            ),
            handoff: PanicSlipHandoff(quitID: quitID, source: .inApp, stepsReached: [])
        )
        kit.clock.advance(by: TimeInterval(3 * day))
        kit.model.confirm()

        let framing = try #require(kit.model.framing, "a degraded card still logs the slip and frames it")
        #expect(framing.momentumPercent == nil, "missing momentum stays nil — the copy degrades, it never invents")
        #expect(framing.bestStreakSeconds == 0, "no card best → 0 (the no-best copy variant), not a fabricated number")
        #expect(framing.endedStreakSeconds == 0, "no anchor/start → no elapsed can be computed honestly")
    }

    @Test func test_coldFraming_foldsEarlierUnrevokedSlipDrafts() throws {
        // DELIBERATE DEVIATION R-RMW: repeat cold slips are NOT rewritten to
        // panic-snapshot.json (no second store-truth writer — the ADR-6 dual-writer
        // hazard). Display honesty for repeat cold slips comes instead from folding
        // earlier unrevoked .slipped drafts already in the buffer, IN MEMORY, before the
        // current slip's framing (decision record point 4).
        let quitID = UUID()
        let kit = try makeCold(
            card: coldCard(id: quitID, bestStreakSeconds: 0, momentumPercent: 50),
            handoff: PanicSlipHandoff(quitID: quitID, source: .inApp, stepsReached: [])
        )
        // A first slip from a PRIOR cold session (2d streak, ended at epoch+2d).
        let earlier = PanicOutcomeDraft(
            quitID: quitID, source: .inApp, outcome: .slipped, stepsReached: [],
            at: epoch + TimeInterval(2 * day),
            capturedUptime: baseUptime + TimeInterval(2 * day),
            capturedBootID: bootA
        )
        try kit.buffer.append(earlier)

        kit.clock.advance(by: TimeInterval(3 * day))
        kit.model.confirm()

        let framing = try #require(kit.model.framing, "the framing folds the earlier slip first")
        #expect(
            framing.endedStreakSeconds == day,
            "ended is measured from the FIRST slip's instant (epoch+2d → epoch+3d = 1d), not the card start"
        )
        #expect(framing.bestStreakSeconds == 2 * day, "the first slip's 2d streak is folded into best")
        #expect(framing.momentumPercent == 50, "momentum still unchanged")
    }

    // MARK: - Cold route: in-session undo (revocation record, live-gated window)

    @Test func test_coldUndo_withinWindow_appendsRevocation_andRestoresStage() throws {
        let quitID = UUID()
        let kit = try makeCold(
            card: coldCard(id: quitID),
            handoff: PanicSlipHandoff(quitID: quitID, source: .inApp, stepsReached: [])
        )
        kit.model.confirm()
        kit.model.undo() // still inside the window (clock never advanced)

        let revocation = try #require(
            kit.buffer.drafts().first { $0.revokesDraftID != nil },
            "an in-session undo appends a REVOCATION record — the revoked pair never reaches the store (§9 rule 3 governs store rows; none exists yet)"
        )
        #expect(revocation.revokesDraftID == kit.model.loggedSlipID, "the revocation names the just-logged draft")
        #expect(kit.model.stage == .undone)
    }

    @Test func test_coldUndo_pastWindow_isCalmNoOp() throws {
        let quitID = UUID()
        let kit = try makeCold(
            card: coldCard(id: quitID),
            handoff: PanicSlipHandoff(quitID: quitID, source: .inApp, stepsReached: [])
        )
        kit.model.confirm()
        let afterConfirm = kit.buffer.drafts().count
        kit.clock.advance(by: 601) // past the boundary-inclusive 600s window

        #expect(kit.model.undoAvailable(at: kit.clock.now) == false, "past the window the live gate is closed")
        kit.model.undo()
        #expect(kit.buffer.drafts().count == afterConfirm, "a past-window undo appends nothing — no revocation")
        #expect(kit.model.stage == .logged, "the slip stays LOGGED — undo past the window is a calm no-op, not an error")
    }

    @Test func test_undoAvailable_liveGate_honestUnderClockFiddle() throws {
        let quitID = UUID()
        let kit = try makeCold(
            card: coldCard(id: quitID),
            handoff: PanicSlipHandoff(quitID: quitID, source: .inApp, stepsReached: [])
        )
        kit.model.confirm() // slip anchored at (bootA, baseUptime, epoch)

        // Inside the window: 100s on the monotonic timeline.
        kit.clock.now = epoch + 100
        kit.clock.monotonicNow = MonotonicNow(bootID: bootA, uptime: baseUptime + 100)
        #expect(kit.model.undoAvailable(at: epoch + 100) == true, "inside 600s the live gate is OPEN")

        // Past the window on an honest wall.
        kit.clock.now = epoch + 601
        kit.clock.monotonicNow = MonotonicNow(bootID: bootA, uptime: baseUptime + 601)
        #expect(kit.model.undoAvailable(at: epoch + 601) == false, "601s > 600s closes the gate")

        // Wall dragged BACKWARD while uptime advanced past the window: same boot, so the
        // monotonic delta is ground truth — a rolled-back wall cannot re-open the window
        // (window measurements pass lastKnownGood: nil — H11 killed).
        kit.clock.now = epoch - 5_000
        kit.clock.monotonicNow = MonotonicNow(bootID: bootA, uptime: baseUptime + 601)
        #expect(
            kit.model.undoAvailable(at: epoch - 5_000) == false,
            "monotonic ground truth within a boot keeps the closed window closed under a rolled-back wall"
        )
    }

    @Test func test_coldRoute_writesOnlyTheBufferFile() throws {
        // The single-writer pin (R-RMW dropped): the cold slip flow writes ONE file.
        let quitID = UUID()
        let kit = try makeCold(
            card: coldCard(id: quitID),
            handoff: PanicSlipHandoff(quitID: quitID, source: .inApp, stepsReached: [])
        )
        kit.model.confirm()
        kit.model.undo()

        #expect(
            try FileManager.default.contentsOfDirectory(atPath: kit.directory.path).sorted()
                == [PanicOutcomeBuffer.fileName],
            "the cold slip flow writes ONLY panic-outcomes.ndjson — no panic-snapshot.json rewrite, no store (one cold write boundary; the ADR-6 dual-writer hazard removed)"
        )
    }

    @Test func test_coldRoute_hasNoReflectionNote() throws {
        // DECLARED green-from-birth guard (red-spec §2 exemption, Session 10 precedent):
        // supportsReflectionNote is a pure type-level switch over the route and is final
        // in the stub. Its value protects the §10 "notes live only in the store" boundary
        // from future churn (the type-level half of §10); the behavioral red evidence
        // lives in the confirm/undo tests.
        let coldModel = SlipFlowModel(
            route: .cold(
                handoff: PanicSlipHandoff(quitID: UUID(), source: .inApp, stepsReached: []),
                card: coldCard(), buffer: nil, witnessStore: nil
            ),
            copy: fixtureCopy(), clock: ManualClock()
        )
        let h = try StoreHarness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        let storeModel = SlipFlowModel(
            route: .store(repository: h.repository, quitID: quit.id),
            copy: fixtureCopy(), clock: h.clock
        )

        #expect(coldModel.supportsReflectionNote == false, "§10: the cold route has no note field at all")
        #expect(storeModel.supportsReflectionNote == true, "notes live only where the store backs the flow")
    }

    // MARK: - Store route (dashboard half; synchronous logSlip, engine-gated undo)

    @Test func test_storeConfirm_logsSynchronouslyThroughRepository() throws {
        let h = try StoreHarness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(3 * day))
        let model = SlipFlowModel(
            route: .store(repository: h.repository, quitID: quit.id),
            copy: fixtureCopy(), clock: h.clock, noteDebounceSleep: { _ in }
        )
        model.confirm()

        #expect(model.stage == .logged, "store confirm logs synchronously, THEN advances (§9 rule 1)")
        let slipID = try #require(model.loggedSlipID, "the persisted slip's id is published")
        let fresh = ModelContext(h.container)
        let stored = try #require(
            try fresh.fetch(FetchDescriptor<Slip>(predicate: #Predicate { $0.id == slipID })).first,
            "a fresh context sees the row — confirm persisted it before returning"
        )
        #expect(
            stored.isPendingUndo,
            "a freshly logged slip OPENS the undo window — isPendingUndo TRUE (logSlip's flag flips ON with the E4.1 lifecycle; the stub keeps it false)"
        )
        let framing = try #require(model.framing, "framing comes from the freshly persisted transition")
        #expect(framing.endedStreakSeconds == 3 * day, "ended = the archived 3-day streak")
        #expect(framing.bestStreakSeconds == 3 * day, "a fresh 3-day best is archived")
    }

    @Test func test_storeUndo_restoresThroughRepository() throws {
        let h = try StoreHarness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(3 * day))
        let model = SlipFlowModel(
            route: .store(repository: h.repository, quitID: quit.id),
            copy: fixtureCopy(), clock: h.clock, noteDebounceSleep: { _ in }
        )
        model.confirm()
        let loggedID = try #require(model.loggedSlipID, "confirm logged a slip through the repository")
        model.undo() // inside the window

        #expect(model.stage == .undone, "an in-window undo restores the streak and lands the undone stage")
        let fresh = ModelContext(h.container)
        #expect(
            try fresh.fetch(FetchDescriptor<Slip>(predicate: #Predicate { $0.id == loggedID })).isEmpty,
            "the undone slip row is DELETED — it must not count against Reduce allowance or future insights"
        )
        let quitID = quit.id
        let restored = try #require(
            try fresh.fetch(FetchDescriptor<Quit>(predicate: #Predicate { $0.id == quitID })).first
        )
        #expect(restored.startAt == epoch, "the pre-slip start is restored EXACTLY (the one sanctioned decrease, §9 rule 3)")
        #expect(restored.bestStreakSeconds == 0, "the archived best is rolled back with it")
    }

    @Test func test_reflectionNote_autosavesOnKeystrokePause() async throws {
        let h = try StoreHarness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(day))
        let model = SlipFlowModel(
            route: .store(repository: h.repository, quitID: quit.id),
            copy: fixtureCopy(), clock: h.clock,
            noteDebounceSleep: { _ in } // zero-time debounce: the drain, not a wall clock, gates the save (§7.7)
        )
        model.confirm()
        let slipID = try #require(model.loggedSlipID, "confirm logged a slip to attach the note to")

        model.noteChanged("trigger: stress")
        let before = try #require(
            try ModelContext(h.container)
                .fetch(FetchDescriptor<Slip>(predicate: #Predicate { $0.id == slipID })).first
        )
        #expect(before.note == nil, "the keystroke only SCHEDULES the debounced save — nothing is persisted mid-typing")

        await model.drainPendingNoteSave()
        let after = try #require(
            try ModelContext(h.container)
                .fetch(FetchDescriptor<Slip>(predicate: #Predicate { $0.id == slipID })).first
        )
        #expect(
            after.note == "trigger: stress",
            "after the keystroke pause the reflection note autosaves through the repository (§10: notes live ONLY in the store)"
        )
    }

    // MARK: - Route-independent guards

    @Test func test_cancel_writesNothing() throws {
        // DECLARED green-from-birth guard (red-spec §2 exemption): "cancel writes nothing"
        // is inherently satisfied by the no-op stub — its value is protecting the confirm
        // stage's "Not now" from a FUTURE regression where cancel accidentally writes.
        let quitID = UUID()
        let kit = try makeCold(
            card: coldCard(id: quitID),
            handoff: PanicSlipHandoff(quitID: quitID, source: .inApp, stepsReached: [])
        )
        #expect(kit.model.cancel() == true, "cancel from confirming dismisses the flow")
        #expect(kit.buffer.drafts().isEmpty, "cancel leaves without writing a single byte to the buffer")
        #expect(kit.model.stage == .confirming, "no write, no stage advance")
    }

    @Test func test_discreetCard_flagsDiscreet() throws {
        // DECLARED green-from-birth guard (red-spec §2 exemption): the discreet flag is a
        // pure type-level read of the card and is final in the stub. The view consumes
        // this to keep zero habit context on screen; the guard protects both arms from
        // future churn.
        let discreetKit = try makeCold(
            card: coldCard(discreet: true),
            handoff: PanicSlipHandoff(quitID: UUID(), source: .inApp, stepsReached: [])
        )
        let openKit = try makeCold(
            card: coldCard(discreet: false),
            handoff: PanicSlipHandoff(quitID: UUID(), source: .inApp, stepsReached: [])
        )
        #expect(discreetKit.model.discreet == true, "a discreet card flags discreet — the strings carry zero habit context")
        #expect(openKit.model.discreet == false, "an open card does not")
    }
}
