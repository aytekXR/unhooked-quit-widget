import Foundation
import StreakEngine
import SwiftData
import Testing
@testable import Unhooked

// E2.2 unit lane. The five doc-canonical names from implementation-plan.md E2.2 are
// verbatim; the reboot-cap repository tests land the carried ADR-7 item (Sessions
// 03–05: "the repository provides the persisted last-known-good wall reading the cap
// needs"). Red evidence for this file = the CI run on the red commit (session-rules
// app-lane mechanics).

// Fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z.
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)
private let day = 86_400
private let bootA = UUID(uuidString: "0B00071D-A000-4000-8000-000000000001")!
private let bootB = UUID(uuidString: "0B00071D-B000-4000-8000-000000000002")!
private let cap = Int(StreakCalculator.defaultRebootGapCap)

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
/// test here may ever observe a call on it. Erase behavior is pinned in
/// EraseEverythingTests with a scriptable mock.
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
            defaults: UserDefaults(suiteName: "e22-tests-\(UUID().uuidString)")!
        )
        repository = QuitRepository(
            container: container,
            clock: clock,
            widgetRefresher: spy,
            lastKnownGoodStore: lkgStore,
            cloud: StubCloudSync(),
            appGroupDefaults: UserDefaults(suiteName: "e22-group-\(UUID().uuidString)")!,
            // Zero real time in tests: coalescing must come from the debouncer's
            // cancel-prior semantics, never from racing a wall clock (test-suite §7.7).
            debounceSleep: { _ in }
        )
    }
}

@MainActor
@Suite("E2.2 · QuitRepository")
struct QuitRepositoryTests {

    // MARK: - The five named tests (implementation-plan E2.2, verbatim)

    @Test func test_logSlip_isSynchronous_noAwaitNoNetwork() throws {
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(3 * day))

        // Type-level half: a synchronous throwing function — an `async` logSlip cannot
        // satisfy this binding, so "no await" is enforced by the compiler, not a timer.
        let logSlip: @MainActor (UUID, String?) throws -> Slip = {
            try h.repository.logSlip(quitID: $0, note: $1)
        }

        // Timing half (test-suite item 15 budget). No network is structural: the
        // repository holds no transport; the socket canary arrives with the
        // Integration test plan and this name is its future home.
        var slip: Slip?
        let duration = try ContinuousClock().measure {
            slip = try logSlip(quit.id, "measured")
        }
        #expect(duration < .milliseconds(50))
        #expect(slip?.quit?.id == quit.id, "the synchronous call returns the persisted, attached slip")
    }

    @Test func test_logSlip_persistsBeforeReturning() throws {
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape, weeklySpend: 26)
        h.clock.advance(by: TimeInterval(3 * day))

        let slip = try h.repository.logSlip(quitID: quit.id, note: "before any UI transition")

        // A FRESH context on the same container sees the row: save() ran before the
        // call returned — the slip write precedes any UI transition (§9 rule 1).
        let fresh = ModelContext(h.container)
        let slipID = slip.id
        let storedSlip = try fresh.fetch(
            FetchDescriptor<Slip>(predicate: #Predicate { $0.id == slipID })
        )
        #expect(storedSlip.count == 1)
        #expect(storedSlip.first?.note == "before any UI transition")
        #expect(storedSlip.first?.streakSecondsAtSlip == 3 * day)
        #expect(storedSlip.first?.at == epoch + TimeInterval(3 * day), "stamped at the guarded slip instant")

        // The quit's banked fields rode the same save. `totalCleanSeconds` is pinned
        // BANKED-only (== the engine's priorCleanSeconds; the live streak is added at
        // read time) — anything else double-counts momentum.
        let quitID = quit.id
        let storedQuit = try fresh.fetch(
            FetchDescriptor<Quit>(predicate: #Predicate { $0.id == quitID })
        ).first
        #expect(storedQuit?.totalCleanSeconds == 3 * day)
        #expect(storedQuit?.bestStreakSeconds == 3 * day)
        #expect(storedQuit?.startAt == epoch + TimeInterval(3 * day))
    }

    @Test func test_activeQuits_excludesArchived() throws {
        let h = try Harness()
        let first = try h.repository.createQuit(habitCategory: .vape)
        let second = try h.repository.createQuit(habitCategory: .porn)
        let third = try h.repository.createQuit(habitCategory: .alcohol, goalMode: .reduce)

        // Soft archive, the way Settings will (archiving UX is a later epic; tests own
        // the store, and Tests/ is inside the importer-lint allowlist).
        second.isArchived = true
        try h.container.mainContext.save()

        let active = try h.repository.activeQuits()
        #expect(active.count == 2)
        #expect(active.map(\.id) == [first.id, third.id], "sortIndex order, archived excluded")
    }

    @Test func test_createQuit_fourthActiveQuit_throwsLimitError() throws {
        let h = try Harness()
        for category in [HabitCategory.vape, .porn, .alcohol] {
            try h.repository.createQuit(habitCategory: category)
        }

        #expect(throws: QuitRepository.RepositoryError.activeQuitLimitReached) {
            try h.repository.createQuit(habitCategory: .doomscroll)
        }
        #expect(try h.repository.activeQuits().count == 3, "the failed create leaves no partial row")
    }

    @Test func test_logSlip_unknownQuit_throwsQuitNotFound() throws {
        // Legitimizes the quitNotFound branch (review: landed without a pinning test).
        let h = try Harness()
        let ghost = UUID()
        #expect(throws: QuitRepository.RepositoryError.quitNotFound(ghost)) {
            try h.repository.logSlip(quitID: ghost, note: nil)
        }
    }

    @Test func test_logUrgeEvent_persistsBeforeReturning_andCountsAvertedOnly() throws {
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: 3_600)

        let averted = try h.repository.logUrgeEvent(
            quitID: quit.id, source: .lockscreenWidget, outcome: .averted,
            stepsReached: [.breath, .timer]
        )
        _ = try h.repository.logUrgeEvent(quitID: quit.id, source: .inApp, outcome: .abandoned)

        // Same commit-point rule as logSlip: a fresh context sees the rows.
        let fresh = ModelContext(h.container)
        let avertedID = averted.id
        let stored = try fresh.fetch(
            FetchDescriptor<UrgeEvent>(predicate: #Predicate { $0.id == avertedID })
        ).first
        #expect(stored?.source == .lockscreenWidget)
        #expect(stored?.outcome == .averted)
        #expect(stored?.stepsReached == [.breath, .timer])
        #expect(stored?.at == epoch + 3_600)

        let quitID = quit.id
        let storedQuit = try fresh.fetch(
            FetchDescriptor<Quit>(predicate: #Predicate { $0.id == quitID })
        ).first
        #expect(storedQuit?.avertedUrgeCount == 1, "only .averted outcomes bump the count")
    }

    @Test func test_createQuit_afterArchive_assignsUnusedSortIndex() throws {
        // Review mutant: `sortIndex = active.count` collides after an archive frees a
        // low index while higher ones stay taken. max(active)+1 must not collide.
        let h = try Harness()
        let first = try h.repository.createQuit(habitCategory: .vape)      // 0
        _ = try h.repository.createQuit(habitCategory: .porn)              // 1
        _ = try h.repository.createQuit(habitCategory: .alcohol)           // 2
        first.isArchived = true
        try h.container.mainContext.save()

        let fourth = try h.repository.createQuit(habitCategory: .doomscroll)
        #expect(fourth.sortIndex == 3)
        #expect(try h.repository.activeQuits().map(\.sortIndex) == [1, 2, 3])
    }

    @Test func test_repositoryWrite_triggersDebouncedWidgetReload() async throws {
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: 3_600)

        // A 3-write burst well inside 500 ms (synchronous back-to-back calls): each
        // write schedules a trailing reload; the debounce must coalesce them into ONE.
        _ = try h.repository.logSlip(quitID: quit.id, note: nil)
        _ = try h.repository.logUrgeEvent(quitID: quit.id, source: .lockscreenWidget, outcome: .averted)
        _ = try h.repository.logUrgeEvent(quitID: quit.id, source: .inApp, outcome: .abandoned)
        #expect(h.spy.reloadCount == 0, "nothing reloads mid-burst")

        await h.repository.drainPendingWidgetReload()
        #expect(h.spy.reloadCount == 1, "a 3-write burst coalesces to a single reload")
    }

    // MARK: - The carried ADR-7 reboot cap, through the repository (Sessions 03–05)

    @Test func test_streakValue_rebootForwardJump_beyondCap_freezesNotInflates() throws {
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)

        // Day 5: an ordinary honest read — the repository persists this as the device's
        // last trusted reading (the LKG baseline the cap measures from).
        h.clock.advance(by: TimeInterval(5 * day))
        _ = try h.repository.streakValue(for: quit.id)

        // Reboot + wall jumped to day 1000: must NOT read .normal, must NOT inflate.
        h.clock.reboot(bootID: bootB, uptime: 5_000)
        h.clock.setWallClock(epoch + TimeInterval(1_000 * day))

        let value = try h.repository.streakValue(for: quit.id)
        #expect(value.clockSanity == .clockRolledBack)
        #expect(value.elapsedSeconds == 5 * day + cap)
    }

    @Test func test_logSlip_banksCappedTruth_notInflated_acrossRebootForwardJump() throws {
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)

        h.clock.advance(by: TimeInterval(5 * day))
        _ = try h.repository.streakValue(for: quit.id) // trusted reading at day 5

        h.clock.reboot(bootID: bootB, uptime: 5_000)
        h.clock.setWallClock(epoch + TimeInterval(1_000 * day))

        // The append-only banks must archive the CAPPED truth: a banked lie would
        // outlive the clock fix forever (best/totalClean never decrease).
        let slip = try h.repository.logSlip(quitID: quit.id, note: nil)
        #expect(slip.streakSecondsAtSlip == 5 * day + cap)
        #expect(quit.bestStreakSeconds == 5 * day + cap)
        #expect(quit.totalCleanSeconds == 5 * day + cap)
    }

    @Test func test_lastKnownGood_refreshedOnNormalVerdict_notOnRollback() throws {
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        #expect(
            h.lkgStore.load() == nil,
            "creation alone must not bless the wall — no pre-existing anchor verified it"
        )

        h.clock.advance(by: TimeInterval(day))
        _ = try h.repository.streakValue(for: quit.id)
        #expect(
            h.lkgStore.load()?.wallClock == epoch + TimeInterval(day),
            "a .normal read advances the trusted reading"
        )

        // Same boot, wall dragged back beyond tolerance in a non-timezone shape:
        // .clockRolledBack — the trusted reading must NOT move (blessing a lying wall
        // would poison every future reboot-cap baseline).
        h.clock.setWallClock(epoch + TimeInterval(day) - 11_200)
        _ = try h.repository.streakValue(for: quit.id)
        #expect(
            h.lkgStore.load()?.wallClock == epoch + TimeInterval(day),
            "a flagged read must not advance the trusted reading"
        )

        // A timezone-SHAPED set (−3h exactly): .timezoneShift — still not .normal, so
        // still no advance (review mutant: a `!= .clockRolledBack` gate would bless it).
        h.clock.setWallClock(epoch + TimeInterval(day) - 10_800)
        _ = try h.repository.streakValue(for: quit.id)
        #expect(
            h.lkgStore.load()?.wallClock == epoch + TimeInterval(day),
            "a timezone-shaped set must not advance the trusted reading either"
        )
    }

    @Test func test_lastKnownGood_freshAnchorCannotBlessTheWall_siblingQuitStaysCapped() throws {
        // Session 06 adversarial-review MAJOR (confirmed 3/3): a just-minted anchor
        // trivially reads .normal against the reading it was minted from — for ANY
        // absolute wall value — so reading a fresh quit under a forward-set wall must
        // not launder that wall into the device-global trusted reading. If it did, a
        // sibling quit's capped arm would trust the poisoned baseline and inflate,
        // UNFLAGGED, across the next reboot (the exact failure this whole diff exists
        // to prevent).
        let h = try Harness()
        let honest = try h.repository.createQuit(habitCategory: .vape)

        // 100 honest days: the trusted reading sits at day 100.
        h.clock.advance(by: TimeInterval(100 * day))
        _ = try h.repository.streakValue(for: honest.id)
        #expect(h.lkgStore.load()?.wallClock == epoch + TimeInterval(100 * day))

        // Same boot, wall set forward to day 1000; a NEW quit is created at the lying
        // wall and read. Its fresh anchor agrees with the lie by construction — the
        // read must NOT advance the trusted reading (continuity with the previous
        // reading fails: wall says +900d, uptime says +0).
        h.clock.setWallClock(epoch + TimeInterval(1_000 * day))
        let planted = try h.repository.createQuit(habitCategory: .doomscroll)
        _ = try h.repository.streakValue(for: planted.id)
        _ = try h.repository.logUrgeEvent(quitID: planted.id, source: .inApp, outcome: .abandoned)
        #expect(
            h.lkgStore.load()?.wallClock == epoch + TimeInterval(100 * day),
            "a fresh anchor must not bless the wall it was minted from"
        )

        // Across a reboot the honest quit must still read capped-and-flagged from the
        // day-100 baseline — not the planted day-1000 wall as .normal.
        h.clock.reboot(bootID: bootB, uptime: 5_000)
        let value = try h.repository.streakValue(for: honest.id)
        #expect(value.clockSanity == .clockRolledBack)
        #expect(value.elapsedSeconds == 100 * day + cap)
    }

    @Test func test_lastKnownGood_isDeviceLocal_notInSwiftDataStore() throws {
        let h = try Harness()
        let reading = MonotonicAnchor(bootID: bootA, uptime: 51_000, wallClock: epoch + 1_000)
        h.lkgStore.save(reading)
        #expect(h.lkgStore.load() == reading, "round-trips through device-local defaults")

        // The mirrored store's schema must NOT grow an entity for it: a clock reading is
        // device truth — syncing device A's boot/uptime onto device B would corrupt B's
        // cap baseline (AppSettings is mirrored, so it may not live there either).
        let names = Set(PersistentStore.schema.entities.map(\.name))
        #expect(names == ["Quit", "Slip", "UrgeEvent", "QuizProfile", "AppSettings"])
    }
}
