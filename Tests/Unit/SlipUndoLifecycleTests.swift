import Foundation
import StreakEngine
import SwiftData
import Testing
@testable import Unhooked

// E4.1 · the STORE-BACKED slip undo lifecycle through QuitRepository (dashboard half).
// The whole 10-minute-undo unit lands together (decision-record "Store-backed path"):
// logSlip opens the window (isPendingUndo + persisted PendingSlipUndo payload),
// undoSlip is the engine-gated exact restore + row removal, finalizePendingSlips is the
// scene-phase sweep, pendingUndoSlip is the banner source, updateSlipNote is the
// reflection autosave target. Every window measurement passes `lastKnownGood: nil`
// (decision-record: "Window measurements pass lastKnownGood: nil" — the ratified E1.3
// undo semantics; an ahead-witness must not BURN the window across a boot).
//
// Red evidence for this file = the CI run on the red commit: the stubs return
// false/0/nil/no-op and logSlip still writes isPendingUndo=false with a nil payload, so
// each test below fails through its DESIGNED assertion (never a compile error, never a
// crash). Two tests are green-from-birth guards — declared inline with the reason.
//
// Harness/ManualClock/SpyWidgetRefresher/StubCloudSync are copied from
// QuitRepositoryTests (the E2.2 conventions): in-memory ModelContainer, injected clock,
// spy refresher, zero-wall-time debounce. Fixture epoch is the test-suite §3.2 constant.

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

/// Inert CloudKit-seam stub (E2.4 init plumbing): nothing in this suite erases, so no
/// test here may ever observe a call on it.
@MainActor
private final class StubCloudSync: CloudSyncControlling {
    func accountStatus() async -> CloudAccountStatus { .available }
    func deleteAllPrivateZones() async throws {}
}

/// One in-memory store + repository per test — the E2.1 schema, zero cross-test state.
@MainActor
private struct Harness {
    let container: ModelContainer
    let clock: ManualClock
    let spy: SpyWidgetRefresher
    let lkgStore: LastKnownGoodStore
    let repository: QuitRepository

    init() throws {
        container = try ModelContainer(
            for: PersistentStore.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        clock = ManualClock()
        spy = SpyWidgetRefresher()
        lkgStore = LastKnownGoodStore(
            defaults: UserDefaults(suiteName: "e41-tests-\(UUID().uuidString)")!
        )
        repository = QuitRepository(
            container: container,
            clock: clock,
            widgetRefresher: spy,
            lastKnownGoodStore: lkgStore,
            cloud: StubCloudSync(),
            appGroupDefaults: UserDefaults(suiteName: "e41-group-\(UUID().uuidString)")!,
            panicSnapshotStore: PanicSnapshotStore(
                directoryURL: FileManager.default.temporaryDirectory
                    .appendingPathComponent("e41-snap-\(UUID().uuidString)", isDirectory: true)
            ),
            debounceSleep: { _ in }
        )
    }
}

@MainActor
@Suite("E4.1 · Slip undo lifecycle (store route)")
struct SlipUndoLifecycleTests {

    // MARK: - logSlip opens the window

    @Test func test_logSlip_opensUndoWindow_flagAndPayloadPersisted() throws {
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(3 * day))

        // Expected payload = the engine's PendingSlipUndo for the SAME inputs the
        // repository will feed applySlip (equivalence: what a live logSlip records is
        // exactly what applySlip produces). Computed BEFORE the write, off the pre-slip
        // quit state — the repository maps the model onto StreakSnapshot identically.
        let before = StreakSnapshot(
            startAt: quit.startAt,
            trackedSince: quit.createdAt,
            weeklySpend: quit.weeklySpend,
            priorCleanSeconds: quit.totalCleanSeconds,
            monotonicAnchor: quit.monotonicAnchor,
            bestStreakSeconds: quit.bestStreakSeconds,
            pendingUndo: nil
        )
        let expected = StreakCalculator.applySlip(
            to: before, at: h.clock.now, monotonic: h.clock.monotonicNow, lastKnownGood: h.lkgStore.load()
        )
        let undo = try #require(expected.pendingUndo)

        let slip = try h.repository.logSlip(quitID: quit.id, note: nil)

        // DESIGNED FAILURE: the stub logSlip writes isPendingUndo=false and never
        // persists the four prior* fields (the whole lifecycle lands with the green
        // commit). Green opens the window and records the payload verbatim.
        #expect(slip.isPendingUndo, "logSlip opens the 10-minute undo window")
        #expect(slip.priorStartAt == undo.priorStartAt)
        #expect(slip.priorCleanSeconds == undo.priorCleanSeconds)
        #expect(slip.priorBestStreakSeconds == undo.priorBestStreakSeconds)
        #expect(slip.priorMonotonicAnchor == undo.priorMonotonicAnchor)

        // A FRESH context on the same container proves the flag + payload were saved
        // (§9 rule 1: the write precedes any UI transition — the banner reads store truth).
        let fresh = ModelContext(h.container)
        let slipID = slip.id
        let stored = try #require(
            try fresh.fetch(FetchDescriptor<Slip>(predicate: #Predicate { $0.id == slipID })).first
        )
        #expect(stored.isPendingUndo)
        #expect(stored.priorStartAt == undo.priorStartAt)
        #expect(stored.priorCleanSeconds == undo.priorCleanSeconds)
        #expect(stored.priorBestStreakSeconds == undo.priorBestStreakSeconds)
        #expect(stored.priorMonotonicAnchor == undo.priorMonotonicAnchor)
    }

    @Test func test_logSlip_newerSlip_finalizesOlderPendingUndo() throws {
        // Decision-record store path: "logSlip finalizes any prior pending Slip rows for
        // the quit (newer finalizes older)" — one reversible slip at a time (§9 rule 3).
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)

        h.clock.advance(by: TimeInterval(day))
        let slip1 = try h.repository.logSlip(quitID: quit.id, note: nil)
        h.clock.advance(by: 3_600)
        let slip2 = try h.repository.logSlip(quitID: quit.id, note: nil)

        let fresh = ModelContext(h.container)
        let id1 = slip1.id
        let id2 = slip2.id
        let stored1 = try #require(
            try fresh.fetch(FetchDescriptor<Slip>(predicate: #Predicate { $0.id == id1 })).first
        )
        let stored2 = try #require(
            try fresh.fetch(FetchDescriptor<Slip>(predicate: #Predicate { $0.id == id2 })).first
        )

        // DESIGNED FAILURE: on the stub NEITHER slip is ever pending, so the newest is
        // not pending (fails) and no row was ever the "one pending". Green leaves exactly
        // slip2 pending and finalizes slip1 (flag false + payload nil'd).
        #expect(stored2.isPendingUndo, "only the newest slip stays reversible")
        #expect(stored1.isPendingUndo == false, "the older pending row is finalized")
        #expect(stored1.priorStartAt == nil, "finalize nils the older row's payload")

        let pending = try fresh.fetch(FetchDescriptor<Slip>(predicate: #Predicate { $0.isPendingUndo }))
        #expect(pending.count == 1, "exactly one pending row after two same-quit slips")
        #expect(pending.first?.id == slip2.id)
    }

    // MARK: - undoSlip restores + removes

    @Test func test_undoSlip_withinWindow_restoresExactPriorState_andRemovesRow() throws {
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(2 * day))

        // The exact pre-slip values the undo must restore, captured before the slip.
        let priorStartAt = quit.startAt
        let priorAnchor = quit.monotonicAnchor
        let priorBest = quit.bestStreakSeconds
        let priorClean = quit.totalCleanSeconds

        let slip = try h.repository.logSlip(quitID: quit.id, note: nil)
        h.clock.advance(by: 300) // well inside the 600s window

        // DESIGNED FAILURE: the stub undoSlip returns false and mutates nothing, so the
        // quit stays in its post-slip state and the row survives. Green restores the
        // EXACT recorded priors (the one sanctioned §9-rule-3 decrease) and removes the row.
        let didUndo = try h.repository.undoSlip(slipID: slip.id)
        #expect(didUndo, "an in-window undo succeeds")

        #expect(quit.startAt == priorStartAt)
        #expect(quit.monotonicAnchor == priorAnchor)
        #expect(quit.bestStreakSeconds == priorBest)
        #expect(quit.totalCleanSeconds == priorClean)

        let slipID = slip.id
        let remaining = try h.container.mainContext.fetch(
            FetchDescriptor<Slip>(predicate: #Predicate { $0.id == slipID })
        )
        #expect(remaining.isEmpty, "a completed undo removes the undone row")
    }

    @Test func test_undoSlip_at600s_restores_at601s_calmNoOp() throws {
        // Boundary is inclusive: the engine's undoWindowSeconds gate is `sinceSlip <= 600`
        // on the guarded timeline. 600 restores; 601 is a calm no-op that FINALIZES the row.

        // --- 600s: restores (the designed-red arm) ---
        let hIn = try Harness()
        let quitIn = try hIn.repository.createQuit(habitCategory: .vape)
        hIn.clock.advance(by: TimeInterval(day))
        let priorStartAt = quitIn.startAt
        let priorBest = quitIn.bestStreakSeconds
        let slipIn = try hIn.repository.logSlip(quitID: quitIn.id, note: nil)
        hIn.clock.advance(by: 600)

        // DESIGNED FAILURE: stub returns false and does not restore/remove; green restores.
        #expect(try hIn.repository.undoSlip(slipID: slipIn.id), "600s is inside the inclusive window")
        #expect(quitIn.startAt == priorStartAt)
        #expect(quitIn.bestStreakSeconds == priorBest)
        let inID = slipIn.id
        #expect(
            try hIn.container.mainContext.fetch(
                FetchDescriptor<Slip>(predicate: #Predicate { $0.id == inID })
            ).isEmpty,
            "the restored row is removed"
        )

        // --- 601s: calm no-op that finalizes (row REMAINS, flag false, payload nil) ---
        let hOut = try Harness()
        let quitOut = try hOut.repository.createQuit(habitCategory: .vape)
        hOut.clock.advance(by: TimeInterval(day))
        let slipOut = try hOut.repository.logSlip(quitID: quitOut.id, note: nil)
        hOut.clock.advance(by: 601)

        // These post-conditions are GREEN-FROM-BIRTH: a calm past-window no-op leaves the
        // SAME bytes the inert stub already writes (returns false; the row it never made
        // pending simply stays non-pending with a nil payload and is NOT deleted). They
        // pin the green contract — the test's redness rides entirely on the 600s arm above.
        #expect(try hOut.repository.undoSlip(slipID: slipOut.id) == false, "601s is past the window")
        let outID = slipOut.id
        let survivor = try #require(
            try hOut.container.mainContext.fetch(
                FetchDescriptor<Slip>(predicate: #Predicate { $0.id == outID })
            ).first
        )
        #expect(survivor.isPendingUndo == false, "a past-window undo finalizes rather than restores")
        #expect(survivor.priorStartAt == nil, "finalize nils the payload; the row remains")
    }

    @Test func test_undoSlip_nothingPending_returnsFalse() throws {
        // GREEN-FROM-BIRTH GUARD (Session 10 precedent): "nothing pending" returns false
        // in BOTH the stub and the green commit — there is no state that distinguishes
        // them, so no designed failure is possible. Its role is to pin the calm-no-op
        // contract for the green implementation: a non-pending slip must return false,
        // never throw or crash, and must mutate nothing.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(day))
        let slip = try h.repository.logSlip(quitID: quit.id, note: nil)

        // Force the row non-pending (tests own the store — QuitRepositoryTests sets model
        // flags directly): now there is nothing pending for undoSlip to act on.
        slip.isPendingUndo = false
        try h.container.mainContext.save()

        let postSlipStart = quit.startAt
        let postSlipBest = quit.bestStreakSeconds

        #expect(try h.repository.undoSlip(slipID: slip.id) == false, "nothing pending → calm false")

        // Nothing moved and the row survives.
        #expect(quit.startAt == postSlipStart)
        #expect(quit.bestStreakSeconds == postSlipBest)
        let slipID = slip.id
        #expect(
            try h.container.mainContext.fetch(
                FetchDescriptor<Slip>(predicate: #Predicate { $0.id == slipID })
            ).count == 1
        )
    }

    @Test func test_undoSlip_doesNotAdvanceWitness() throws {
        // Decision-record: undo carries "NO witness refresh — restoring a historical
        // anchor earns no fresh wall trust". The invariant is the focus; `didUndo` is
        // what makes it a LIVE (successful) undo rather than a trivial no-op.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(day))
        let slip = try h.repository.logSlip(quitID: quit.id, note: nil) // .normal write blesses the witness
        h.clock.advance(by: 300) // inside the window; advancing the clock never touches the witness

        let witnessBefore = try #require(h.lkgStore.load(), "logSlip's normal verdict set a witness")

        // DESIGNED FAILURE: the stub undoSlip returns false — no undo happened — so the
        // witness-unchanged half passes trivially and this assertion is the red driver.
        let didUndo = try h.repository.undoSlip(slipID: slip.id)
        #expect(didUndo, "the in-window undo succeeds")
        #expect(h.lkgStore.load() == witnessBefore, "a successful undo never advances the witness")
    }

    // MARK: - finalize sweep

    @Test func test_finalizePendingSlips_sweepsClosedWindows_idempotent() throws {
        // Two quits so each slip's window is measured against its OWN post-slip anchor
        // (no newer-finalizes-older interaction). slipA closes; slipB is still open.
        let h = try Harness()
        let quitA = try h.repository.createQuit(habitCategory: .vape)
        let quitB = try h.repository.createQuit(habitCategory: .porn)

        h.clock.advance(by: TimeInterval(day))
        let slipA = try h.repository.logSlip(quitID: quitA.id, note: nil) // instant = epoch+1d
        h.clock.advance(by: 700)
        let slipB = try h.repository.logSlip(quitID: quitB.id, note: nil) // instant = now; age 0

        // At now, slipA is 700s old (past 600) and slipB is 0s old (inside).
        // DESIGNED FAILURE: the stub returns 0 and finalizes nothing; slipB was never
        // pending. Green finalizes exactly slipA and leaves slipB pending with its payload.
        #expect(h.repository.finalizePendingSlips() == 1, "one closed window swept")

        #expect(slipA.isPendingUndo == false, "the closed-window row is finalized")
        #expect(slipA.priorStartAt == nil, "finalize nils the closed row's payload")
        #expect(slipB.isPendingUndo, "the still-open row is left pending")
        #expect(slipB.priorStartAt != nil, "the still-open row keeps its payload")

        // Idempotent: slipA is already finalized and slipB is still inside its window.
        #expect(h.repository.finalizePendingSlips() == 0, "a second sweep changes nothing")
    }

    @Test func test_finalizePendingSlips_windowMeasuredOnGuardedTimeline_rollbackCannotBurnIt() throws {
        // Sharpest scenario: within a single boot the wall is dragged FORWARD an hour but
        // monotonic uptime advanced only 300s. The window rides the guarded timeline (the
        // engine takes the monotonic truth when wall and uptime disagree), so the honest
        // elapsed-since-slip is 300s — inside the window. A forward-set wall CANNOT burn
        // the window within a boot (decision-record: window measured with lastKnownGood:nil
        // on the guarded timeline). Raw-wall math would read 3600s and wrongly finalize.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(day))
        let slip = try h.repository.logSlip(quitID: quit.id, note: nil) // instant = epoch+1d

        h.clock.advance(by: 300)                                   // uptime +300, wall +300
        h.clock.setWallClock(epoch + TimeInterval(day) + 3_600)    // wall jumps forward; uptime unchanged

        // GREEN-FROM-BIRTH edge: `== 0` also holds for the inert stub. The designed
        // failure is that the slip must REMAIN pending with its payload — proving the
        // guarded window was honored. The stub never made it pending, so these fail.
        #expect(h.repository.finalizePendingSlips() == 0, "forward-set wall does not close the window")
        #expect(slip.isPendingUndo, "the window is still open on the guarded timeline")
        #expect(slip.priorStartAt != nil, "an unfinalized row keeps its payload")
    }

    // MARK: - pendingUndoSlip (banner source)

    @Test func test_pendingUndoSlip_returnsTheOnePendingRow() throws {
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)

        // Before any slip: nothing pending (green-from-birth — both stub and green nil).
        #expect(try h.repository.pendingUndoSlip() == nil, "no slip → no pending row")

        h.clock.advance(by: TimeInterval(day))
        let slip = try h.repository.logSlip(quitID: quit.id, note: nil)

        // DESIGNED FAILURE: the stub returns nil; green returns the one pending row.
        #expect(try h.repository.pendingUndoSlip()?.id == slip.id, "the open slip is the banner source")

        // After the window closes and the sweep finalizes it, nothing is pending again
        // (green-from-birth tail: both nil once no row carries the flag).
        h.clock.advance(by: 601)
        _ = h.repository.finalizePendingSlips()
        #expect(try h.repository.pendingUndoSlip() == nil, "a finalized slip is no longer the banner source")
    }

    // MARK: - reflection note

    @Test func test_updateSlipNote_persistsOnStoreRoute() throws {
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(day))
        let slip = try h.repository.logSlip(quitID: quit.id, note: "first thoughts")
        let slipID = slip.id

        // DESIGNED FAILURE: the stub updateSlipNote is a no-op, so the note stays
        // "first thoughts". Green persists the new note synchronously (§10: notes live
        // ONLY in the store), provable from a fresh context.
        try h.repository.updateSlipNote(slipID: slipID, note: "revised on reflection")
        let afterWrite = ModelContext(h.container)
        let stored = try #require(
            try afterWrite.fetch(FetchDescriptor<Slip>(predicate: #Predicate { $0.id == slipID })).first
        )
        #expect(stored.note == "revised on reflection")

        // DESIGNED FAILURE: a nil note clears the field; the stub leaves it unchanged.
        try h.repository.updateSlipNote(slipID: slipID, note: nil)
        let afterClear = ModelContext(h.container)
        let cleared = try #require(
            try afterClear.fetch(FetchDescriptor<Slip>(predicate: #Predicate { $0.id == slipID })).first
        )
        #expect(cleared.note == nil, "a nil note clears the reflection")
    }

    // MARK: - the one sanctioned decrease

    @Test func test_undoSlip_restoresBankedFields_theOneSanctionedDecrease() throws {
        // §9 rule 3: undo is the ONE sanctioned monotonic DECREASE of the append-only
        // banked fields (bestStreakSeconds, totalCleanSeconds). Test-suite item 7's
        // append-only invariant exempts a completed undo — the engine encodes this too
        // (SlipTransition: undoSlip "is the one sanctioned exemption and never runs" the
        // append-only detector). This test proves BOTH banked fields fall back to their
        // exact recorded priors.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)

        // Streak 1 (5 days) → slip banks best=5d, totalClean=5d.
        h.clock.advance(by: TimeInterval(5 * day))
        _ = try h.repository.logSlip(quitID: quit.id, note: nil)
        // Streak 2 (10 days > prior best) → slip raises best=10d, totalClean=15d and
        // finalizes slip 1. These are the priors the undo must roll BACK past.
        h.clock.advance(by: TimeInterval(10 * day))
        let slip2 = try h.repository.logSlip(quitID: quit.id, note: nil)

        let postSlipBest = quit.bestStreakSeconds      // 10d on both stub and green
        let postSlipClean = quit.totalCleanSeconds     // 15d on both stub and green

        h.clock.advance(by: 200) // inside the window
        let didUndo = try h.repository.undoSlip(slipID: slip2.id)

        // DESIGNED FAILURE: the stub undoSlip returns false and leaves the banked fields
        // at their raised post-slip values. Green restores the recorded priors — the
        // sanctioned decrease.
        #expect(didUndo, "the in-window undo succeeds")
        #expect(quit.bestStreakSeconds == 5 * day, "best falls back to its recorded prior")
        #expect(quit.totalCleanSeconds == 5 * day, "banked clean falls back to its recorded prior")
        // Explicit: both fields DECREASED across the undo (the only place this is legal).
        #expect(quit.bestStreakSeconds < postSlipBest, "best decreased across the undo")
        #expect(quit.totalCleanSeconds < postSlipClean, "banked clean decreased across the undo")
    }
}
