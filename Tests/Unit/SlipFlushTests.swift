import Foundation
import StreakEngine
import SwiftData
import Testing
@testable import Unhooked

// E4.1 · deferred slip application through `flushPanicOutcomes` (the cold half's
// landing pins — Session 11 decision record, BINDING). The flush is the moment a
// buffered cold slip becomes store truth, and every pin here is one of the record's
// named rules: the R-WIT equivalence property (a deferred slip applies with the
// SLIP-TIME evidence tuple and equals a live `logSlip` byte-for-byte), R-ORDER
// (append order, never wall-sorted), R-REVOKE (two-pass revocation collection; a
// revoked pair never reaches the store and a revocation is never an UrgeEvent),
// R-NILQUIT (a zero-quit slip is an unattributed UrgeEvent only), R-NEWEST (earlier
// same-quit rows are forced non-pending), R-HEAL (a same-launch heal collision banks
// toward 0, never inflates — pinned as bounds), the flush-time window check with
// `lastKnownGood: nil`, and the witness discipline (flush NEVER advances it).
//
// Red evidence for this file = the CI run on the red commit: the current flush
// inserts UrgeEvents only — no Slip row, no streak transition, no revocation
// handling — so each test fails through its DESIGNED assertion (never a compile
// error, never a crash). The designed failure is called out inline per test.
//
// Harness/ManualClock/SpyWidgetRefresher/StubCloudSync are the E2.2 conventions from
// QuitRepositoryTests; the buffer shares the pre-cache directory exactly the way the
// repository derives it (the PanicFlowTests RepoDoubles precedent), so a test append
// IS the file the flush reads. Fixture epoch is the test-suite §3.2 constant.

// Fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z.
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)
private let day = 86_400
private let baseUptime: TimeInterval = 50_000
private let bootA = UUID(uuidString: "0B00071D-A000-4000-8000-000000000001")!
private let bootB = UUID(uuidString: "0B00071D-B000-4000-8000-000000000002")!
private let cap = Int(StreakCalculator.defaultRebootGapCap)

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

/// One in-memory store + repository per test, PLUS the §9-rule-2 buffer over the SAME
/// directory the repository derives its own from — appends land in the file the flush
/// reads, with zero extra wiring (the constructor's design, pinned in E3.2).
@MainActor
private struct Harness {
    let container: ModelContainer
    let clock: ManualClock
    let spy: SpyWidgetRefresher
    let lkgStore: LastKnownGoodStore
    let repository: QuitRepository
    let buffer: PanicOutcomeBuffer

    init() throws {
        let cacheDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("e41-flush-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        container = try ModelContainer(
            for: PersistentStore.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        clock = ManualClock()
        spy = SpyWidgetRefresher()
        lkgStore = LastKnownGoodStore(
            defaults: UserDefaults(suiteName: "e41-flush-lkg-\(UUID().uuidString)")!
        )
        buffer = PanicOutcomeBuffer(directoryURL: cacheDirectory)
        repository = QuitRepository(
            container: container,
            clock: clock,
            widgetRefresher: spy,
            lastKnownGoodStore: lkgStore,
            cloud: StubCloudSync(),
            appGroupDefaults: UserDefaults(suiteName: "e41-flush-group-\(UUID().uuidString)")!,
            panicSnapshotStore: PanicSnapshotStore(directoryURL: cacheDirectory),
            debounceSleep: { _ in }
        )
    }

    /// Every Slip row in slip-instant order (the guarded `at`, which is total here —
    /// no two rows in this suite share an instant).
    func slips() throws -> [Slip] {
        try container.mainContext.fetch(FetchDescriptor<Slip>(sortBy: [SortDescriptor(\.at)]))
    }

    func urgeEvents() throws -> [UrgeEvent] {
        try container.mainContext.fetch(FetchDescriptor<UrgeEvent>())
    }

    /// The engine's view of a quit, mapped exactly the way the repository maps it
    /// (the SlipUndoLifecycleTests precedent for computing expected transitions).
    func engineSnapshot(of quit: Quit) -> StreakSnapshot {
        StreakSnapshot(
            startAt: quit.startAt,
            trackedSince: quit.createdAt,
            weeklySpend: quit.weeklySpend,
            priorCleanSeconds: quit.totalCleanSeconds,
            monotonicAnchor: quit.monotonicAnchor,
            bestStreakSeconds: quit.bestStreakSeconds,
            pendingUndo: nil
        )
    }
}

/// A buffered `.slipped` draft carrying the SLIP-TIME evidence tuple (decision record:
/// deferred application must equal live application, so the draft carries what the
/// cold flow captured — the monotonic reading and the LKG witness AT SLIP TIME).
private func slippedDraft(
    id: UUID = UUID(),
    quitID: UUID?,
    at: Date,
    uptime: TimeInterval? = nil,
    bootID: UUID? = nil,
    witness: MonotonicAnchor? = nil,
    revokes: UUID? = nil
) -> PanicOutcomeDraft {
    PanicOutcomeDraft(
        id: id, quitID: quitID, source: .lockscreenWidget, outcome: .slipped,
        stepsReached: [.breath], at: at,
        capturedUptime: uptime, capturedBootID: bootID,
        capturedWitnessBootID: witness?.bootID,
        capturedWitnessUptime: witness?.uptime,
        capturedWitnessWallClock: witness?.wallClock,
        revokesDraftID: revokes
    )
}

/// The three worlds the R-WIT equivalence property is quantified over: what happens
/// between the slip and the flush must not change what the slip banked.
private enum DeferredArm: String, CaseIterable {
    case sameBoot = "same boot"
    case rebootBetween = "reboot between slip and flush"
    case rolledBackWall = "wall rolled back before flush"
}

@MainActor
@Suite("E4.1 · flushPanicOutcomes — deferred slip application")
struct SlipFlushTests {

    // MARK: - The equivalence property (R-WIT — the load-bearing pin)

    @Test(arguments: DeferredArm.allCases)
    func test_flush_deferredSlip_equalsLiveLogSlip_forCapturedTuple(arm: DeferredArm) throws {
        // Two identical worlds. In LIVE the slip applies at the slip instant through
        // logSlip; in DEFERRED the cold flow buffers the slip-time evidence tuple and
        // the flush applies it later — after nothing (same boot), after a reboot, or
        // after the wall was dragged back. The store outcome must be BYTE-FOR-BYTE
        // identical: transition fields, slip row, undo payload, pending flag.
        let live = try Harness()
        let deferred = try Harness()
        let liveQuit = try live.repository.createQuit(habitCategory: .vape)
        let deferredQuit = try deferred.repository.createQuit(habitCategory: .vape)

        // Identical witness history: one honest read at day 1 blesses each witness.
        live.clock.advance(by: TimeInterval(day))
        deferred.clock.advance(by: TimeInterval(day))
        _ = try live.repository.streakValue(for: liveQuit.id)
        _ = try deferred.repository.streakValue(for: deferredQuit.id)
        live.clock.advance(by: TimeInterval(2 * day))
        deferred.clock.advance(by: TimeInterval(2 * day))

        // LIVE world: the slip applies now, at epoch+3d.
        let liveSlip = try live.repository.logSlip(quitID: liveQuit.id, note: nil)

        // DEFERRED world: the cold flow captures the tuple at the SAME instant.
        try deferred.buffer.append(slippedDraft(
            quitID: deferredQuit.id,
            at: deferred.clock.now,
            uptime: deferred.clock.monotonicNow.uptime,
            bootID: deferred.clock.monotonicNow.bootID,
            witness: deferred.lkgStore.load()
        ))

        // What happens between slip and flush — the property's quantifier.
        switch arm {
        case .sameBoot:
            deferred.clock.advance(by: 300)
        case .rebootBetween:
            deferred.clock.reboot(bootID: bootB, uptime: 700)
            deferred.clock.setWallClock(epoch + TimeInterval(3 * day) + 300)
        case .rolledBackWall:
            deferred.clock.advance(by: 300)
            deferred.clock.setWallClock(epoch + TimeInterval(2 * day))
        }

        // The production launch order (startIfNeeded): recompute, then flush.
        try deferred.repository.recomputeDerivedState()
        _ = deferred.repository.flushPanicOutcomes()

        // DESIGNED FAILURE: the current flush inserts UrgeEvents only — no Slip row
        // exists in the deferred world, so this #require fails on the red commit.
        // Green applies the transition from the captured tuple and every comparison
        // below holds in all three arms.
        let deferredSlip = try #require(
            try deferred.slips().first,
            "the flush lands the deferred slip as a Slip row [R-WIT]"
        )
        #expect(try deferred.slips().count == 1)

        // The slip row, byte-for-byte against live.
        #expect(deferredSlip.at == liveSlip.at, "the guarded slip instant, never the flush clock")
        #expect(deferredSlip.streakSecondsAtSlip == liveSlip.streakSecondsAtSlip)
        #expect(deferredSlip.note == liveSlip.note, "a buffered slip carries no note, ever (§10)")
        #expect(deferredSlip.countsAgainstAllowance == liveSlip.countsAgainstAllowance)
        #expect(deferredSlip.isPendingUndo == liveSlip.isPendingUndo, "the window is open in every arm — flush measured it with lastKnownGood: nil")
        #expect(deferredSlip.priorStartAt == liveSlip.priorStartAt)
        #expect(deferredSlip.priorCleanSeconds == liveSlip.priorCleanSeconds)
        #expect(deferredSlip.priorBestStreakSeconds == liveSlip.priorBestStreakSeconds)
        #expect(deferredSlip.priorMonotonicAnchor == liveSlip.priorMonotonicAnchor)

        // The quit's transition fields, byte-for-byte against live.
        #expect(deferredQuit.startAt == liveQuit.startAt)
        #expect(deferredQuit.monotonicAnchor == liveQuit.monotonicAnchor, "re-anchored from the CAPTURED reading — a flush-time reading would differ in every arm but the first")
        #expect(deferredQuit.bestStreakSeconds == liveQuit.bestStreakSeconds)
        #expect(deferredQuit.totalCleanSeconds == liveQuit.totalCleanSeconds)
    }

    // MARK: - Slip-time span, not flush-time span

    @Test func test_flush_slipAfterPreSlipReboot_banksSlipTimeSpan_notFlushTimeSpan() throws {
        // The slip itself happened AFTER a reboot (anchor boot ≠ captured boot), so its
        // guarded elapsed rides the witness-capped arm — with the SLIP-TIME witness and
        // the SLIP-TIME wall. Verified span to the witness (1d) + in-cap gap (1d) = 2d.
        // Applying flush-time inputs instead would bank 10d — a streak that never ran.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)

        h.clock.advance(by: TimeInterval(day))
        _ = try h.repository.streakValue(for: quit.id) // witness ← (bootA, +1d, epoch+1d)
        let witnessAtSlip = try #require(h.lkgStore.load())

        // Reboot BEFORE the slip; the cold slip happens at epoch+2d on the new boot.
        h.clock.reboot(bootID: bootB, uptime: 1_000)
        h.clock.setWallClock(epoch + TimeInterval(2 * day))
        try h.buffer.append(slippedDraft(
            quitID: quit.id,
            at: h.clock.now,
            uptime: h.clock.monotonicNow.uptime,
            bootID: h.clock.monotonicNow.bootID,
            witness: witnessAtSlip
        ))

        // The next normal launch runs 8 days later (inside the 14d cap — no heal).
        h.clock.advance(by: TimeInterval(8 * day))
        _ = h.repository.flushPanicOutcomes()

        // DESIGNED FAILURE: no Slip row / no transition on the red commit.
        let slip = try #require(try h.slips().first, "the deferred slip lands")
        #expect(
            slip.streakSecondsAtSlip == 2 * day,
            "banked = the SLIP-TIME guarded span (1d verified + 1d in-cap gap) — never the 10d flush-time span"
        )
        #expect(quit.totalCleanSeconds == 2 * day)
        #expect(quit.bestStreakSeconds == 2 * day)
        #expect(quit.startAt == epoch + TimeInterval(2 * day), "the counter restarts at the guarded slip instant")
        #expect(
            quit.monotonicAnchor == MonotonicAnchor(
                bootID: bootB, uptime: 1_000, wallClock: epoch + TimeInterval(2 * day)
            ),
            "re-anchored from the CAPTURED slip-time reading, wallClock == startAt"
        )
        #expect(slip.isPendingUndo == false, "8 days past the slip, the window is long closed at flush time")
    }

    // MARK: - Idempotency (the dedupe set gates the TRANSITION, not just the insert)

    @Test func test_flush_duplicateSlipDraftIds_applyTransitionOnce() throws {
        // The exit-time append retry can double-write one draft (E3.2 pin). For a
        // slipped draft the stakes are higher: the streak transition must apply once.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(day))
        let d = slippedDraft(
            quitID: quit.id, at: h.clock.now,
            uptime: h.clock.monotonicNow.uptime, bootID: h.clock.monotonicNow.bootID
        )
        try h.buffer.append(d)
        try h.buffer.append(d)
        h.clock.advance(by: 60)

        #expect(h.repository.flushPanicOutcomes() == 1, "one outcome, twice on disk, lands ONCE")
        #expect(try h.urgeEvents().count == 1)

        // DESIGNED FAILURE: no Slip row / no transition on the red commit. Green
        // applies exactly ONE transition — a doubled application would bank 1d twice.
        #expect(try h.slips().count == 1, "one Slip row for one slip, however many buffer lines")
        #expect(quit.totalCleanSeconds == day, "the transition applied exactly once")
        #expect(quit.startAt == epoch + TimeInterval(day))
    }

    @Test func test_flush_replayAfterSaveBeforeClear_doesNotDoubleApplySlip() throws {
        // A crash between save and clear replays the same draft on the next launch.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(day))
        let d = slippedDraft(
            quitID: quit.id, at: h.clock.now,
            uptime: h.clock.monotonicNow.uptime, bootID: h.clock.monotonicNow.bootID
        )
        try h.buffer.append(d)

        #expect(h.repository.flushPanicOutcomes() == 1)

        // DESIGNED FAILURE: the first flush lands no Slip row on the red commit.
        let slip = try #require(try h.slips().first, "the first flush applies the slip")
        #expect(quit.startAt == epoch + TimeInterval(day))
        #expect(quit.totalCleanSeconds == day)

        // The replay: same bytes, same id, next launch (clock unmoved — the crash and
        // relaunch happen within the window).
        try h.buffer.append(d)
        #expect(h.repository.flushPanicOutcomes() == 0, "an already-landed draft id must not re-apply")
        #expect(try h.slips().count == 1, "no second Slip row")
        #expect(quit.totalCleanSeconds == day, "the banked span did not double")
        #expect(quit.startAt == epoch + TimeInterval(day), "the counter did not restart again")
        #expect(
            slip.isPendingUndo,
            "the replayed (deduped) draft must not touch the live row — R-NEWEST forcing only runs for drafts that APPLY"
        )
    }

    // MARK: - Revocations (R-REVOKE: two-pass; the pair never reaches the store)

    @Test func test_flush_revokedPair_dropsBoth_revocationNeverAnUrgeEvent() throws {
        // The in-session cold undo appended a revocation record. The revoked slip and
        // the revocation itself both evaporate at flush: no UrgeEvent, no Slip row, no
        // transition. Collecting revokedIDs FIRST is what makes this hold in append
        // order — a single-pass flush would apply the slip before seeing its revocation.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(day))
        let d = slippedDraft(
            quitID: quit.id, at: h.clock.now,
            uptime: h.clock.monotonicNow.uptime, bootID: h.clock.monotonicNow.bootID
        )
        try h.buffer.append(d)
        h.clock.advance(by: 30)
        try h.buffer.append(slippedDraft(
            quitID: quit.id, at: h.clock.now,
            uptime: h.clock.monotonicNow.uptime, bootID: h.clock.monotonicNow.bootID,
            revokes: d.id
        ))
        h.clock.advance(by: 60)

        // DESIGNED FAILURE: the current flush knows nothing of revokesDraftID — it
        // lands BOTH lines as UrgeEvents and returns 2. Green drops the pair whole.
        #expect(h.repository.flushPanicOutcomes() == 0, "a revoked pair lands nothing")
        #expect(try h.urgeEvents().isEmpty, "the revoked slip is gone AND a revocation record is never an UrgeEvent")
        #expect(try h.slips().isEmpty, "no Slip row — the pair never reaches the store")
        #expect(quit.startAt == epoch, "no transition applied")
        #expect(quit.totalCleanSeconds == 0)
        #expect(quit.bestStreakSeconds == 0)
        #expect(h.buffer.drafts().isEmpty, "the consumed pair does not haunt the next launch")
    }

    @Test func test_flush_slipUndoSlip_landsExactlyOneSlip() throws {
        // slip → in-session undo → slip again: only the second slip is real. Its
        // transition applies against the ORIGINAL state (the revoked pair contributed
        // nothing), and exactly one UrgeEvent — the second slip's — survives.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(day))
        let first = slippedDraft(
            quitID: quit.id, at: h.clock.now,
            uptime: h.clock.monotonicNow.uptime, bootID: h.clock.monotonicNow.bootID
        )
        try h.buffer.append(first)
        h.clock.advance(by: 60)
        try h.buffer.append(slippedDraft(
            quitID: quit.id, at: h.clock.now,
            uptime: h.clock.monotonicNow.uptime, bootID: h.clock.monotonicNow.bootID,
            revokes: first.id
        ))
        h.clock.advance(by: 3_540) // the second slip, one hour after the first
        let second = slippedDraft(
            quitID: quit.id, at: h.clock.now,
            uptime: h.clock.monotonicNow.uptime, bootID: h.clock.monotonicNow.bootID
        )
        try h.buffer.append(second)
        h.clock.advance(by: 100)

        // DESIGNED FAILURE: the current flush returns 2 (both slipped lines land as
        // UrgeEvents) and applies no transition. Green lands exactly the second slip.
        #expect(h.repository.flushPanicOutcomes() == 1, "slip → undo → slip lands exactly one")
        let events = try h.urgeEvents()
        #expect(events.count == 1)
        #expect(events.first?.id == second.id, "the surviving UrgeEvent is the second slip's")
        #expect(try h.slips().count == 1)
        #expect(
            quit.totalCleanSeconds == day + 3_600,
            "the transition measures from the ORIGINAL start — the revoked slip never cut the streak"
        )
        #expect(quit.startAt == epoch + TimeInterval(day + 3_600))
    }

    // MARK: - Attribution edges (R-NILQUIT; erased-quit drop)

    @Test func test_flush_nilQuitSlippedDraft_landsUnattributedUrgeEventOnly() throws {
        // A zero-quit panic can still end in a slip. It is honest unattributed data:
        // an UrgeEvent with no quit — and NO streak transition anywhere, because there
        // is no streak to cut. A sibling attributed slip proves transitions still run.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(day))
        try h.buffer.append(slippedDraft(
            quitID: nil, at: h.clock.now,
            uptime: h.clock.monotonicNow.uptime, bootID: h.clock.monotonicNow.bootID
        ))
        try h.buffer.append(slippedDraft(
            quitID: quit.id, at: h.clock.now,
            uptime: h.clock.monotonicNow.uptime, bootID: h.clock.monotonicNow.bootID
        ))
        h.clock.advance(by: 60)

        #expect(h.repository.flushPanicOutcomes() == 2, "both land as UrgeEvents")
        let events = try h.urgeEvents()
        #expect(events.count == 2)
        #expect(events.contains { $0.quit == nil && $0.outcome == .slipped }, "the zero-quit slip lands unattributed [R-NILQUIT]")

        // DESIGNED FAILURE: no Slip rows exist on the red commit — the attributed
        // draft's row is the red driver; the nil-quit draft must add NOTHING to it.
        #expect(try h.slips().count == 1, "exactly ONE Slip row — the attributed slip's; a nil-quit slip is an UrgeEvent only")
        #expect(try h.slips().first?.quit?.id == quit.id)
        #expect(quit.startAt == epoch + TimeInterval(day), "the attributed quit transitioned")
    }

    @Test func test_flush_erasedQuitSlippedDraft_drops_liveQuitStillTransitions() throws {
        // Erase discipline: a draft for an erased quit must not resurrect behavioral
        // data about it — dropped whole, no unattributed fallback, no transition.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(day))
        let ghost = slippedDraft(
            quitID: UUID(), at: h.clock.now,
            uptime: h.clock.monotonicNow.uptime, bootID: h.clock.monotonicNow.bootID
        )
        try h.buffer.append(ghost)
        try h.buffer.append(slippedDraft(
            quitID: quit.id, at: h.clock.now,
            uptime: h.clock.monotonicNow.uptime, bootID: h.clock.monotonicNow.bootID
        ))
        h.clock.advance(by: 60)

        #expect(h.repository.flushPanicOutcomes() == 1, "the erased-quit draft drops; the live one lands")
        #expect(try h.urgeEvents().count == 1)
        #expect(try h.urgeEvents().contains(where: { $0.id == ghost.id }) == false, "not resurrected, not even unattributed")

        // DESIGNED FAILURE: no Slip row / no transition on the red commit.
        #expect(try h.slips().count == 1, "the live quit's slip lands")
        #expect(quit.startAt == epoch + TimeInterval(day), "the live quit transitioned")
    }

    // MARK: - Ordering (R-ORDER: append order, never wall-sorted)

    @Test func test_flush_appliesInAppendOrder_neverWallSorted() throws {
        // Two cold slips where the wall was rolled back BETWEEN them: the second slip
        // carries an earlier wall instant but a LATER uptime. Append order is causal
        // order; wall-sorting would apply them inverted and bank a corrupted best
        // (sorted application ends the first "slip" at 2d+300 and banks it into best —
        // a value no streak ever reached on the guarded timeline).
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)

        // Slip 1: honest, at epoch+2d. Then the wall rolls back a day; slip 2 happens
        // 300s of REAL time after slip 1, at wall epoch+1d+300.
        let firstAt = epoch + TimeInterval(2 * day)
        let firstReading = MonotonicNow(bootID: bootA, uptime: baseUptime + TimeInterval(2 * day))
        let secondAt = epoch + TimeInterval(day) + 300
        let secondReading = MonotonicNow(bootID: bootA, uptime: firstReading.uptime + 300)
        try h.buffer.append(slippedDraft(
            quitID: quit.id, at: firstAt, uptime: firstReading.uptime, bootID: firstReading.bootID
        ))
        try h.buffer.append(slippedDraft(
            quitID: quit.id, at: secondAt, uptime: secondReading.uptime, bootID: secondReading.bootID
        ))

        // The expected end state IS the engine composition in append order.
        let expected = StreakCalculator.applySlip(
            to: StreakCalculator.applySlip(
                to: h.engineSnapshot(of: quit), at: firstAt, monotonic: firstReading
            ),
            at: secondAt, monotonic: secondReading
        )

        // Flush 60s of real time after the second slip, on the rolled-back wall.
        h.clock.setWallClock(secondAt + 60)
        h.clock.monotonicNow = MonotonicNow(bootID: bootA, uptime: secondReading.uptime + 60)
        _ = h.repository.flushPanicOutcomes()

        // DESIGNED FAILURE: no Slip rows / no transitions on the red commit.
        let slips = try h.slips()
        #expect(slips.count == 2, "both slips land")
        #expect(
            slips.map(\.streakSecondsAtSlip) == [2 * day, 300],
            "append-order application: the honest 2d streak, then the 300s guarded remainder"
        )
        #expect(quit.startAt == expected.startAt)
        #expect(quit.monotonicAnchor == expected.monotonicAnchor)
        #expect(
            quit.bestStreakSeconds == expected.bestStreakSeconds,
            "best = 2d; wall-sorted application would have banked 2d+300 — a streak that never existed"
        )
        #expect(quit.totalCleanSeconds == expected.priorCleanSeconds, "BANKED-only: the quit's total is the engine's prior bank")
    }

    // MARK: - One reversible slip at a time (R-NEWEST)

    @Test func test_flush_twoSlipsSameQuit_onlyNewestPending() throws {
        // Both windows are still open at flush time — the older row is non-pending
        // because a NEWER slip finalizes it (§9 rule 3), not because time ran out.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(day))
        try h.buffer.append(slippedDraft(
            quitID: quit.id, at: h.clock.now,
            uptime: h.clock.monotonicNow.uptime, bootID: h.clock.monotonicNow.bootID
        ))
        h.clock.advance(by: 100)
        try h.buffer.append(slippedDraft(
            quitID: quit.id, at: h.clock.now,
            uptime: h.clock.monotonicNow.uptime, bootID: h.clock.monotonicNow.bootID
        ))
        h.clock.advance(by: 100)
        _ = h.repository.flushPanicOutcomes()

        // DESIGNED FAILURE: no Slip rows on the red commit.
        let slips = try h.slips()
        #expect(slips.count == 2)
        let older = try #require(slips.first)
        let newer = try #require(slips.last)
        #expect(older.isPendingUndo == false, "the older same-quit row is forced non-pending [R-NEWEST]")
        #expect(older.priorStartAt == nil, "finalize nils the older row's payload")
        #expect(newer.isPendingUndo, "the newest row keeps its open window")
        #expect(newer.priorStartAt != nil, "the newest row keeps its payload")
        #expect(
            try h.repository.pendingUndoSlip()?.at == newer.at,
            "the banner source is the one pending row — the newest"
        )
    }

    // MARK: - Witness discipline

    @Test func test_flush_neverAdvancesWitness() throws {
        // WITNESS discipline (standing rule): three advance paths only — flush is not
        // one of them. Replaying historical events earns no fresh wall trust; a green
        // implementation that reused the live logSlip's refresh would advance it here.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(day))
        _ = try h.repository.streakValue(for: quit.id) // the ONE blessed reading
        let witnessBefore = try #require(h.lkgStore.load())

        h.clock.advance(by: TimeInterval(day))
        try h.buffer.append(slippedDraft(
            quitID: quit.id, at: h.clock.now,
            uptime: h.clock.monotonicNow.uptime, bootID: h.clock.monotonicNow.bootID,
            witness: witnessBefore
        ))
        h.clock.advance(by: 100)
        _ = h.repository.flushPanicOutcomes()

        // DESIGNED FAILURE (the red driver): no transition on the red commit — the
        // witness half would pass trivially without it.
        #expect(quit.startAt == epoch + TimeInterval(2 * day), "the deferred slip applied")
        #expect(
            h.lkgStore.load() == witnessBefore,
            "the flush applied a slip and advanced NOTHING — the witness is exactly the day-1 reading"
        )
    }

    // MARK: - The window at flush time

    @Test func test_flush_windowClosedByFlushTime_landsFinalized() throws {
        // The undo window is measured at FLUSH time (engine gate, lastKnownGood: nil):
        // a slip whose 600s elapsed while the buffer waited lands already finalized —
        // the same bytes the sweep would have left (flag false, payload nil).
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(day))
        try h.buffer.append(slippedDraft(
            quitID: quit.id, at: h.clock.now,
            uptime: h.clock.monotonicNow.uptime, bootID: h.clock.monotonicNow.bootID
        ))
        h.clock.advance(by: 700) // past the boundary-inclusive 600s window
        _ = h.repository.flushPanicOutcomes()

        // DESIGNED FAILURE: no Slip row on the red commit.
        let slip = try #require(try h.slips().first, "the slip still lands — only its undo affordance expired")
        #expect(slip.streakSecondsAtSlip == day, "the transition is untouched by the window's state")
        #expect(slip.isPendingUndo == false, "the window closed while the draft waited — lands finalized")
        #expect(slip.priorStartAt == nil, "finalized means finalized: no payload")
        #expect(try h.repository.pendingUndoSlip() == nil, "no banner for a closed window")
    }

    // MARK: - Same-launch heal collision (R-HEAL: bounded, never inflated)

    @Test func test_flush_healCollision_banksTowardZero_neverInflates() throws {
        // The collision: a cold slip is buffered, then the device sits powered off past
        // the reboot cap. The SAME launch first heals the frozen streak (recompute
        // re-bases startAt forward) and then flushes the pre-heal slip. The healed
        // start postdates the slip instant, so the slip's guarded elapsed floors at the
        // verified span — 0 — and the engine clamps do the rest: the collision banks
        // toward 0 and can never inflate (accepted + pinned as BOUNDS, decision record).
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)

        h.clock.advance(by: TimeInterval(day))
        _ = try h.repository.streakValue(for: quit.id) // witness ← (bootA, +1d, epoch+1d)
        let witnessAtSlip = try #require(h.lkgStore.load())

        // The cold slip at epoch+2d, still on bootA — honest span at slip time: 2d.
        h.clock.advance(by: TimeInterval(day))
        try h.buffer.append(slippedDraft(
            quitID: quit.id, at: h.clock.now,
            uptime: h.clock.monotonicNow.uptime, bootID: h.clock.monotonicNow.bootID,
            witness: witnessAtSlip
        ))

        // Powered off for 20 days: reboot, wall at epoch+22d — the witness gap (21d)
        // exceeds the 14d cap, so the launch's recompute HEALS (re-bases the streak).
        h.clock.reboot(bootID: bootB, uptime: 5_000)
        h.clock.setWallClock(epoch + TimeInterval(22 * day))
        try h.repository.recomputeDerivedState()
        let healedStartAt = quit.startAt // epoch+22d − (1d verified + 14d cap) = epoch+7d
        #expect(healedStartAt == epoch + TimeInterval(22 * day) - TimeInterval(day + cap), "precondition: the heal ran")

        _ = h.repository.flushPanicOutcomes()

        // DESIGNED FAILURE: no Slip row on the red commit. Green lands it BOUNDED:
        // the honest slip-time span (2d) is the ceiling everywhere; the floor is 0.
        let slip = try #require(try h.slips().first, "the collision still lands the slip")
        #expect(slip.streakSecondsAtSlip >= 0, "the engine floor: a post-heal slip can never bank negative")
        #expect(slip.streakSecondsAtSlip <= 2 * day, "…and never more than the slip instant's honest span")
        #expect(quit.totalCleanSeconds <= 2 * day, "the banked total cannot exceed the slip-time truth")
        #expect(quit.bestStreakSeconds <= 2 * day, "best cannot inflate through the collision")
        #expect(quit.startAt >= healedStartAt, "the healed re-base is never rolled back by a deferred slip")
        #expect(quit.startAt <= h.clock.now, "…and never lands in the future")
    }
}
