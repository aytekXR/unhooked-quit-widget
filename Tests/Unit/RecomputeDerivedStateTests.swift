import Foundation
import StreakEngine
import SwiftData
import Testing
@testable import Unhooked

// E2.3 unit lane — the CloudKit dedupe merge pass + recomputeDerivedState() + the
// ADR-7 healing re-anchor + the conservative LKG witness. The five doc-canonical
// names from implementation-plan.md E2.3 are verbatim; the rest pin the Session 07
// panel/red-team rulings (option-(iii) heal, isArchived = OR, order-preserving
// deterministic unions, witness restart/accrual with the ≤ cap-per-reboot bound).
// Red evidence for this file = the CI run on the red commit (session-rules app-lane
// mechanics). Merge fixtures insert duplicate rows directly — Tests/ is inside the
// sole-importer lint allowlist, and simulated duplicates are the E2.3 contract
// (real CloudKit is contract-tier, test-suite §4.3).

// Fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z.
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)
private let day = 86_400
private let bootA = UUID(uuidString: "0B00071D-A000-4000-8000-000000000001")!
private let bootB = UUID(uuidString: "0B00071D-B000-4000-8000-000000000002")!
private let bootC = UUID(uuidString: "0B00071D-C000-4000-8000-000000000003")!
private let bootD = UUID(uuidString: "0B00071D-D000-4000-8000-000000000004")!
private let alienBoot = UUID(uuidString: "0B00071D-E000-4000-8000-000000000005")!
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

    func advance(by seconds: TimeInterval) {
        now += seconds
        monotonicNow.uptime += seconds
    }

    func setWallClock(_ date: Date) { now = date }

    func reboot(bootID: UUID, uptime: TimeInterval) {
        monotonicNow = MonotonicNow(bootID: bootID, uptime: uptime)
    }
}

@MainActor
private final class SpyWidgetRefresher: WidgetRefreshing {
    private(set) var reloadCount = 0
    func reloadAllTimelines() { reloadCount += 1 }
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
            defaults: UserDefaults(suiteName: "e23-tests-\(UUID().uuidString)")!
        )
        repository = QuitRepository(
            container: container,
            clock: clock,
            widgetRefresher: spy,
            lastKnownGoodStore: lkgStore,
            debounceSleep: { _ in }
        )
    }
}

/// Inserts one raw (possibly duplicate) Quit row the way a CloudKit import would
/// materialize it — same `id`, divergent fields, its own child rows.
@MainActor
@discardableResult
private func insertRow(
    id: UUID,
    into context: ModelContext,
    createdAt: Date,
    startAt: Date,
    anchor: MonotonicAnchor?,
    best: Int = 0,
    total: Int = 0,
    averted: Int = 0,
    motivations: [String] = [],
    archived: Bool = false,
    sortIndex: Int = 0,
    slips: [(id: UUID, at: Date)] = [],
    urges: [(id: UUID, outcome: UrgeOutcome)] = []
) throws -> Quit {
    let quit = Quit()
    quit.id = id
    quit.habitCategory = .vape
    quit.createdAt = createdAt
    quit.startAt = startAt
    quit.monotonicAnchor = anchor
    quit.bestStreakSeconds = best
    quit.totalCleanSeconds = total
    quit.avertedUrgeCount = averted
    quit.motivations = motivations
    quit.isArchived = archived
    quit.sortIndex = sortIndex
    context.insert(quit)
    for entry in slips {
        let slip = Slip()
        slip.id = entry.id
        slip.at = entry.at
        slip.quit = quit
        context.insert(slip)
    }
    for entry in urges {
        let urge = UrgeEvent()
        urge.id = entry.id
        urge.outcome = entry.outcome
        urge.quit = quit
        context.insert(urge)
    }
    try context.save()
    return quit
}

/// A coherent anchor for a row whose streak started at `startAt` on boot A
/// (anchor.wallClock == startAt, the engine's documented invariant).
private func coherentAnchor(startAt: Date, bootID: UUID = bootA) -> MonotonicAnchor {
    MonotonicAnchor(
        bootID: bootID,
        uptime: 50_000 + startAt.timeIntervalSince(epoch),
        wallClock: startAt
    )
}

/// Canonical, insertion-order-independent dump of the store's LOGICAL state —
/// resolved fields, child parentage (not just membership), and profile pointers.
@MainActor
private func logicalState(of container: ModelContainer) throws -> String {
    let context = ModelContext(container)
    var lines: [String] = []
    let quits = try context.fetch(FetchDescriptor<Quit>())
        .sorted { ($0.id.uuidString, $0.startAt) < ($1.id.uuidString, $1.startAt) }
    for q in quits {
        let slipIDs = (q.slips ?? []).map(\.id.uuidString).sorted().joined(separator: ",")
        let urgeIDs = (q.urgeEvents ?? []).map(\.id.uuidString).sorted().joined(separator: ",")
        lines.append(
            "quit \(q.id) created:\(q.createdAt.timeIntervalSince1970)"
            + " start:\(q.startAt.timeIntervalSince1970)"
            + " anchor:\(String(describing: q.monotonicAnchor))"
            + " best:\(q.bestStreakSeconds) total:\(q.totalCleanSeconds)"
            + " averted:\(q.avertedUrgeCount) spend:\(q.weeklySpend)"
            + " cat:\(q.habitCategory.rawValue) mode:\(q.goalMode.rawValue)"
            + " label:\(q.customLabel ?? "nil") currency:\(q.currencyCode)"
            + " triggers:\(q.triggers) motivations:\(q.motivations)"
            + " discreet:\(q.discreetMode) archived:\(q.isArchived) sort:\(q.sortIndex)"
            + " slips:[\(slipIDs)] urges:[\(urgeIDs)]"
        )
    }
    for s in try context.fetch(FetchDescriptor<Slip>()).sorted(by: { $0.id.uuidString < $1.id.uuidString }) {
        lines.append("slip \(s.id) at:\(s.at.timeIntervalSince1970) parent:\(s.quit?.id.uuidString ?? "nil")")
    }
    for u in try context.fetch(FetchDescriptor<UrgeEvent>()).sorted(by: { $0.id.uuidString < $1.id.uuidString }) {
        lines.append("urge \(u.id) outcome:\(u.outcome.rawValue) parent:\(u.quit?.id.uuidString ?? "nil")")
    }
    for p in try context.fetch(FetchDescriptor<QuizProfile>()).sorted(by: { $0.id.uuidString < $1.id.uuidString }) {
        lines.append("profile \(p.id) quit:\(p.quit?.id.uuidString ?? "nil")")
    }
    return lines.joined(separator: "\n")
}

@MainActor
private func fetchQuits(_ container: ModelContainer, id: UUID) throws -> [Quit] {
    try ModelContext(container).fetch(
        FetchDescriptor<Quit>(predicate: #Predicate { $0.id == id })
    )
}

// MARK: - The dedupe merge pass (the five doc-canonical names + ruling pins)

@MainActor
@Suite("E2.3 · CloudKit dedupe merge pass")
struct DedupeMergeTests {

    @Test func test_mergeDuplicateQuits_keepsMaxTotalTrackedSeconds() throws {
        // totalTrackedSeconds is DERIVED (now − createdAt): keeping the max span
        // means the merged record keeps the EARLIEST createdAt. History never shrinks.
        let h = try Harness()
        let id = UUID()
        try insertRow(
            id: id, into: h.container.mainContext,
            createdAt: epoch, startAt: epoch, anchor: coherentAnchor(startAt: epoch)
        )
        try insertRow(
            id: id, into: h.container.mainContext,
            createdAt: epoch + TimeInterval(5 * day), startAt: epoch + TimeInterval(5 * day),
            anchor: coherentAnchor(startAt: epoch + TimeInterval(5 * day))
        )
        h.clock.advance(by: TimeInterval(10 * day))

        try h.repository.recomputeDerivedState()

        let rows = try fetchQuits(h.container, id: id)
        #expect(rows.count == 1, "duplicates by id resolve to one record")
        #expect(rows.first?.createdAt == epoch, "the earliest origin wins — max tracked span")
    }

    @Test func test_merge_takesFieldwiseMax_bestStreak_totalClean() throws {
        // Field-WISE max: each monotonic counter takes its own max across records,
        // even when the maxima live on different duplicates.
        let h = try Harness()
        let id = UUID()
        try insertRow(
            id: id, into: h.container.mainContext,
            createdAt: epoch, startAt: epoch, anchor: coherentAnchor(startAt: epoch),
            best: 10 * day, total: 3 * day
        )
        try insertRow(
            id: id, into: h.container.mainContext,
            createdAt: epoch, startAt: epoch, anchor: coherentAnchor(startAt: epoch),
            best: 4 * day, total: 8 * day
        )

        try h.repository.recomputeDerivedState()

        let rows = try fetchQuits(h.container, id: id)
        #expect(rows.count == 1)
        #expect(rows.first?.bestStreakSeconds == 10 * day)
        #expect(rows.first?.totalCleanSeconds == 8 * day)
    }

    @Test func test_merge_unionsSlipsWithoutDuplicates() throws {
        // Slips union by UUID: shared ids collapse to one row, unique ids all survive.
        let h = try Harness()
        let id = UUID()
        let s1 = UUID(), s2 = UUID(), s3 = UUID()
        try insertRow(
            id: id, into: h.container.mainContext,
            createdAt: epoch, startAt: epoch, anchor: coherentAnchor(startAt: epoch),
            slips: [(s1, epoch + 1_000), (s2, epoch + 2_000)]
        )
        try insertRow(
            id: id, into: h.container.mainContext,
            createdAt: epoch, startAt: epoch, anchor: coherentAnchor(startAt: epoch),
            slips: [(s2, epoch + 2_000), (s3, epoch + 3_000)]
        )

        try h.repository.recomputeDerivedState()

        let fresh = ModelContext(h.container)
        let slips = try fresh.fetch(FetchDescriptor<Slip>())
        #expect(Set(slips.map(\.id)) == [s1, s2, s3])
        #expect(slips.count == 3, "the shared slip id keeps exactly one row")
        #expect(slips.allSatisfy { $0.quit?.id == id }, "every survivor slip hangs off the merged quit")
    }

    @Test func test_merge_noDuplicates_isNoOp() async throws {
        // PASS-BY-DESIGN pin (documented, E2.2 precedent): a do-nothing sentinel also
        // passes this; it exists to pin the fast path once the merge lands — no save,
        // no widget reload, no witness write, byte-identical store.
        let h = try Harness()
        try h.repository.createQuit(habitCategory: .vape)
        try h.repository.createQuit(habitCategory: .porn)
        await h.repository.drainPendingWidgetReload()
        let reloadsBefore = h.spy.reloadCount
        let stateBefore = try logicalState(of: h.container)
        let witnessBefore = h.lkgStore.load()

        let didMutate = try h.repository.recomputeDerivedState()
        await h.repository.drainPendingWidgetReload()

        #expect(didMutate == false)
        #expect(h.spy.reloadCount == reloadsBefore, "a no-op pass schedules no reload")
        #expect(try logicalState(of: h.container) == stateBefore)
        #expect(h.lkgStore.load() == witnessBefore)
    }

    @Test func test_merge_reparentsChildrenBeforeDelete_cascadeCannotEatHistory() throws {
        // The losing duplicate's children must be re-parented BEFORE the loser row is
        // deleted — Quit.slips/.urgeEvents are .cascade, so a delete-first merge would
        // destroy exactly the history §8 promises can never shrink. Asserted through a
        // FRESH context after the pass (the persisted graph, not the in-memory one).
        let h = try Harness()
        let id = UUID()
        let s1 = UUID(), s2 = UUID(), s3 = UUID(), s4 = UUID()
        let u1 = UUID()
        try insertRow(
            id: id, into: h.container.mainContext,
            createdAt: epoch, startAt: epoch, anchor: coherentAnchor(startAt: epoch),
            slips: [(s1, epoch + 1_000), (s2, epoch + 2_000)]
        )
        try insertRow(
            id: id, into: h.container.mainContext,
            createdAt: epoch + 3_600, startAt: epoch + 3_600,
            anchor: coherentAnchor(startAt: epoch + 3_600),
            slips: [(s3, epoch + 3_000), (s4, epoch + 4_000)],
            urges: [(u1, .averted)]
        )

        try h.repository.recomputeDerivedState()

        #expect(
            try fetchQuits(h.container, id: id).count == 1,
            "duplicates fold to one survivor — without this the same-id loser makes re-parenting unobservable"
        )
        let fresh = ModelContext(h.container)
        let slips = try fresh.fetch(FetchDescriptor<Slip>())
        let urges = try fresh.fetch(FetchDescriptor<UrgeEvent>())
        #expect(Set(slips.map(\.id)) == [s1, s2, s3, s4], "no child row lost to the cascade")
        #expect(Set(urges.map(\.id)) == [u1])
        #expect(slips.allSatisfy { $0.quit?.id == id })
        #expect(urges.allSatisfy { $0.quit?.id == id })
    }

    @Test func test_merge_keepsMaxStartAt_andCoherentAnchor_neverInflates() throws {
        // The current streak restarts from the LATEST slip-terminated startAt
        // (architecture §8) and the anchor rides along AS A COHERENT TUPLE from the
        // same record — the guard measures elapsed from anchor.wallClock, so grafting
        // an older anchor under the newer startAt (or forgetting to overwrite the
        // survivor's own anchor) would silently inflate, unflagged.
        let h = try Harness()
        let id = UUID()
        let newer = epoch + TimeInterval(30 * day)
        try insertRow(
            id: id, into: h.container.mainContext,
            createdAt: epoch, startAt: epoch, anchor: coherentAnchor(startAt: epoch)
        )
        try insertRow(
            id: id, into: h.container.mainContext,
            createdAt: epoch, startAt: newer, anchor: coherentAnchor(startAt: newer)
        )
        h.clock.advance(by: TimeInterval(31 * day))

        try h.repository.recomputeDerivedState()

        let rows = try fetchQuits(h.container, id: id)
        #expect(rows.count == 1)
        #expect(rows.first?.startAt == newer, "latest slip-terminated start wins")
        #expect(rows.first?.monotonicAnchor == coherentAnchor(startAt: newer))
        #expect(rows.first?.monotonicAnchor?.wallClock == rows.first?.startAt)

        let value = try h.repository.streakValue(for: id)
        #expect(value.clockSanity == .normal)
        #expect(value.elapsedSeconds == 1 * day, "the conservative (shorter) streak, never 31d")
    }

    @Test func test_merge_archivedOnAnyDevice_staysArchived_maxThreeHolds() throws {
        // isArchived resolves with OR: archiving is a deliberate act (often a privacy
        // act — a hidden sensitive quit must not resurrect onto widget selectors from
        // a stale un-synced copy), and OR can never push the active set past max-3.
        // Soft archive means no history shrinks either way.
        let h = try Harness()
        for category in [HabitCategory.vape, .porn, .alcohol] {
            try h.repository.createQuit(habitCategory: category)
        }
        let id = UUID()
        try insertRow(
            id: id, into: h.container.mainContext,
            createdAt: epoch, startAt: epoch, anchor: coherentAnchor(startAt: epoch),
            archived: true
        )
        try insertRow(
            id: id, into: h.container.mainContext,
            createdAt: epoch, startAt: epoch, anchor: coherentAnchor(startAt: epoch),
            archived: false
        )

        try h.repository.recomputeDerivedState()

        let rows = try fetchQuits(h.container, id: id)
        #expect(rows.count == 1)
        #expect(rows.first?.isArchived == true, "the user's archive wins over a stale active copy")
        #expect(try h.repository.activeQuits().count == 3, "the merge never mints a fourth active quit")
    }

    @Test func test_merge_unionsMotivations_deterministicallyAcrossOrders() throws {
        // The motivations union is a pure function of the SET of lists (no pairwise
        // fold, no insertion-order dependence): base = first list under the
        // structural total order (count desc, then ASCENDING element-wise
        // lexicographic — the direction is part of the contract), then the remaining
        // lists' unseen items in their own order. User order survives — motivations
        // render verbatim in the panic flow, so alphabetical sorting of ITEMS would
        // scramble user priority.
        let listA = ["see my kids grow up", "money for the trip", "b,c"]
        let listB = ["money for the trip", "a,b", "breathe better"]
        // Equal counts, so the element-wise tie-break decides: "money…" < "see…" ⇒
        // base = listB, then listA's unseen items in listA's own order.
        let expected = ["money for the trip", "a,b", "breathe better", "see my kids grow up", "b,c"]

        for (first, second) in [(listA, listB), (listB, listA)] {
            let h = try Harness()
            let id = UUID()
            try insertRow(
                id: id, into: h.container.mainContext,
                createdAt: epoch, startAt: epoch, anchor: coherentAnchor(startAt: epoch),
                motivations: first
            )
            try insertRow(
                id: id, into: h.container.mainContext,
                createdAt: epoch, startAt: epoch, anchor: coherentAnchor(startAt: epoch),
                motivations: second
            )
            try h.repository.recomputeDerivedState()
            let rows = try fetchQuits(h.container, id: id)
            #expect(rows.count == 1)
            #expect(rows.first?.motivations == expected, "identical result in both insertion orders")
        }
    }

    @Test func test_merge_repointsQuizProfileToSurvivor() throws {
        // QuizProfile points AT Quit with no inverse — deleting a losing duplicate
        // without re-pointing would leave the profile dangling.
        let h = try Harness()
        let id = UUID()
        try insertRow(
            id: id, into: h.container.mainContext,
            createdAt: epoch, startAt: epoch, anchor: coherentAnchor(startAt: epoch)
        )
        let loser = try insertRow(
            id: id, into: h.container.mainContext,
            createdAt: epoch + 3_600, startAt: epoch + 3_600,
            anchor: coherentAnchor(startAt: epoch + 3_600)
        )
        let profile = QuizProfile()
        profile.quit = loser
        h.container.mainContext.insert(profile)
        try h.container.mainContext.save()

        try h.repository.recomputeDerivedState()

        let fresh = ModelContext(h.container)
        let profiles = try fresh.fetch(FetchDescriptor<QuizProfile>())
        #expect(profiles.count == 1)
        #expect(profiles.first?.quit?.id == id, "the profile follows the survivor")
        #expect(try fetchQuits(h.container, id: id).count == 1)
    }

    @Test func test_activeQuits_ordersDeterministically_onSortIndexCollision() throws {
        // The merge resolves sortIndex with min, which can collide with a
        // different-id quit's index; activeQuits() must stay a total order (widget
        // selectors bind by position). Both insertion orders must agree.
        let low = UUID(uuidString: "00000000-0000-4000-8000-000000000001")!
        let high = UUID(uuidString: "FFFFFFFF-0000-4000-8000-000000000002")!
        for ids in [[high, low], [low, high]] {
            let h = try Harness()
            for id in ids {
                try insertRow(
                    id: id, into: h.container.mainContext,
                    createdAt: epoch, startAt: epoch, anchor: coherentAnchor(startAt: epoch),
                    sortIndex: 0
                )
            }
            #expect(
                try h.repository.activeQuits().map(\.id) == [low, high],
                "tied sortIndex breaks deterministically, independent of insertion order"
            )
        }
    }
}

// MARK: - Property: the merge is a pure function of the duplicate SET

private struct SplitMix64 {
    var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    mutating func draw(upTo bound: Int) -> Int {
        Int(next() % UInt64(bound + 1))
    }
}

/// One generated duplicate row (pure data, so the same specs can be inserted into
/// different containers in different orders).
private struct DupSpec {
    var createdAt: Date
    var startAt: Date
    var anchored: Bool
    var best: Int
    var total: Int
    var averted: Int
    var motivations: [String]
    var archived: Bool
    var sortIndex: Int
    var slips: [(id: UUID, at: Date)]
    var urges: [(id: UUID, outcome: UrgeOutcome)]
}

@MainActor
@Suite("E2.3 · merge property")
struct DedupeMergePropertyTests {

    @Test func test_property_mergeIsCommutativeAndIdempotent() throws {
        // Every insertion order of every generated duplicate set converges to the
        // same logical store state; a stale duplicate arriving AFTER a pass merges to
        // the same state as if it had been present all along; and a second pass over
        // converged state is a no-op. Divergently-ordered overlapping motivation
        // lists (with separator characters) and overlapping child id-sets are
        // generated on purpose — they are where order dependence hides.
        var rng = SplitMix64(seed: 0x5EED_0E23_0703_0031) // pinned; add failing seeds per test-suite §6.1.5
        let motivationPool = ["a", "b,c", "a,b", "c", "vape free", "money", "kids", "sleep"]

        for round in 0..<15 {
            let id = UUID(uuidString: String(
                format: "%08X-0000-4000-8000-00000000%04X",
                UInt32(truncatingIfNeeded: rng.next()), UInt32(round)
            ))!
            let sharedSlips = (0..<3).map { i in (id: UUID(), at: epoch + TimeInterval(i * 1_000)) }
            let sharedUrges = (0..<3).map { _ in
                (id: UUID(), outcome: UrgeOutcome.allCases[rng.draw(upTo: UrgeOutcome.allCases.count - 1)])
            }
            let count = 2 + rng.draw(upTo: 2) // 2–4 duplicates
            var specs: [DupSpec] = []
            for _ in 0..<count {
                let startOffset = rng.draw(upTo: 10 * day)
                var motivations: [String] = []
                for m in motivationPool where rng.draw(upTo: 2) > 0 {
                    motivations.append(m)
                }
                if rng.draw(upTo: 1) == 1 { motivations.reverse() } // divergent user order
                let start = epoch + TimeInterval(startOffset)
                specs.append(DupSpec(
                    createdAt: epoch + TimeInterval(rng.draw(upTo: 5 * day)),
                    startAt: start,
                    anchored: rng.draw(upTo: 3) > 0,
                    best: rng.draw(upTo: 20 * day),
                    total: rng.draw(upTo: 20 * day),
                    averted: rng.draw(upTo: 5),
                    motivations: motivations,
                    archived: rng.draw(upTo: 1) == 1,
                    sortIndex: rng.draw(upTo: 3),
                    slips: sharedSlips.filter { _ in rng.draw(upTo: 1) == 1 } + [(id: UUID(), at: epoch + 9_999)],
                    urges: sharedUrges.filter { _ in rng.draw(upTo: 1) == 1 }
                ))
            }

            @MainActor func build(_ order: [Int]) throws -> Harness {
                let h = try Harness()
                for index in order {
                    let s = specs[index]
                    try insertRow(
                        id: id, into: h.container.mainContext,
                        createdAt: s.createdAt, startAt: s.startAt,
                        anchor: s.anchored ? coherentAnchor(startAt: s.startAt) : nil,
                        best: s.best, total: s.total, averted: s.averted,
                        motivations: s.motivations, archived: s.archived,
                        sortIndex: s.sortIndex, slips: s.slips, urges: s.urges
                    )
                }
                return h
            }

            let forward = try build(Array(0..<count))
            let backward = try build(Array((0..<count).reversed()))
            try forward.repository.recomputeDerivedState()
            try backward.repository.recomputeDerivedState()

            #expect(try fetchQuits(forward.container, id: id).count == 1, "round \(round): duplicates fold to one row")
            let forwardState = try logicalState(of: forward.container)
            #expect(
                forwardState == (try logicalState(of: backward.container)),
                "round \(round): insertion order must not change the merged state"
            )

            // Late-arriving stale duplicate: merging it afterwards == having had it all along.
            let straggler = specs[count - 1]
            let allAtOnce = try build(Array(0..<count) + [count - 1])
            try insertRow(
                id: id, into: forward.container.mainContext,
                createdAt: straggler.createdAt, startAt: straggler.startAt,
                anchor: straggler.anchored ? coherentAnchor(startAt: straggler.startAt) : nil,
                best: straggler.best, total: straggler.total, averted: straggler.averted,
                motivations: straggler.motivations, archived: straggler.archived,
                sortIndex: straggler.sortIndex, slips: straggler.slips, urges: straggler.urges
            )
            try forward.repository.recomputeDerivedState()
            try allAtOnce.repository.recomputeDerivedState()
            #expect(
                (try logicalState(of: forward.container)) == (try logicalState(of: allAtOnce.container)),
                "round \(round): a straggler merges to the same state as a single pass"
            )

            // Converged state is a fixed point (backward never saw the straggler, so
            // it must still equal the first converged state, byte for byte).
            let again = try backward.repository.recomputeDerivedState()
            #expect(again == false, "round \(round): a second pass over converged state mutates nothing")
            #expect(
                (try logicalState(of: backward.container)) == forwardState,
                "round \(round): the fixed point holds"
            )
        }
    }
}

// MARK: - recomputeDerivedState: the ADR-7 heal + the conservative witness

@MainActor
@Suite("E2.3 · healing re-anchor + witness")
struct RecomputeHealTests {

    @Test func test_recompute_healsOverCapQuit_freezeThenResume() throws {
        // The innocent long-power-off user: verified to day 5, silent to day 35.
        // Reads freeze at verified+cap (E2.2, pinned below); the launch pass is the
        // one sync-safe write moment that re-bases the streak so it RESUMES — at the
        // frozen value, .normal, ticking — while createdAt (the tracking origin)
        // never moves and momentum turns honest-conservative, not zero.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(5 * day))
        _ = try h.repository.streakValue(for: quit.id) // trusted reading at day 5

        h.clock.reboot(bootID: bootB, uptime: 5_000)
        h.clock.setWallClock(epoch + TimeInterval(35 * day))
        let frozen = try h.repository.streakValue(for: quit.id)
        #expect(frozen.clockSanity == .clockRolledBack, "pre-heal: frozen and flagged (E2.2 pin)")
        #expect(frozen.elapsedSeconds == 5 * day + cap)

        let didMutate = try h.repository.recomputeDerivedState()
        #expect(didMutate == true)

        let healed = try h.repository.streakValue(for: quit.id)
        #expect(healed.clockSanity == .normal)
        #expect(healed.elapsedSeconds == 5 * day + cap, "resumes FROM the frozen value")
        #expect(quit.createdAt == epoch, "option (iii): the tracking origin never resets")
        #expect(healed.momentum == Double(5 * day + cap) / Double(35 * day),
                "conservative momentum: withheld days stay tracked, not clean")

        h.clock.advance(by: TimeInterval(1 * day))
        let later = try h.repository.streakValue(for: quit.id)
        #expect(later.clockSanity == .normal)
        #expect(later.elapsedSeconds == 6 * day + cap, "…and keeps ticking")
    }

    @Test func test_recompute_witnessRestart_grantsAtMostCap_neverTheLyingWall() throws {
        // The witness restart is bounded: +900d of lying wall advances the trusted
        // reading by exactly min(gap, cap) — never to the claimed wall. Any quit,
        // local or CloudKit-delivered (the alien-boot anchor), stays at its
        // capped-arm bound.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        let foreignID = UUID()
        try insertRow(
            id: foreignID, into: h.container.mainContext,
            createdAt: epoch, startAt: epoch,
            anchor: MonotonicAnchor(bootID: alienBoot, uptime: 0, wallClock: epoch)
        )
        h.clock.advance(by: TimeInterval(5 * day))
        _ = try h.repository.streakValue(for: quit.id) // trusted reading at day 5

        h.clock.reboot(bootID: bootB, uptime: 5_000)
        h.clock.setWallClock(epoch + TimeInterval(905 * day))
        try h.repository.recomputeDerivedState()

        let witness = h.lkgStore.load()
        #expect(witness?.bootID == bootB)
        #expect(witness?.wallClock == epoch + TimeInterval(5 * day) + StreakCalculator.defaultRebootGapCap,
                "the restart grants min(gap, cap), never the lying wall")

        let foreign = try h.repository.streakValue(for: foreignID)
        #expect(foreign.elapsedSeconds == 5 * day + cap,
                "a foreign-anchor quit reads its capped-arm bound, nothing more")
    }

    @Test func test_witness_stackedHeals_matchInWindowChannelBound() throws {
        // The sanctioned bound, pinned: k cheat reboots grant AT MOST k·cap — the
        // exact rate the ratified in-window channel (gap ≤ cap ⇒ .normal, gates pass,
        // reading advances; Session 06) has always laundered at. The witness extends
        // that accepted per-reboot grant to >cap gaps; it must never exceed it.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(5 * day))
        _ = try h.repository.streakValue(for: quit.id) // honest baseline: day 5

        let boots = [bootB, bootC, bootD]
        for (n, boot) in boots.enumerated() {
            h.clock.reboot(bootID: boot, uptime: TimeInterval(1_000 * (n + 1)))
            h.clock.setWallClock(h.clock.now + TimeInterval(100 * day))
            try h.repository.recomputeDerivedState()
        }
        let witness = h.lkgStore.load()
        let bound = epoch + TimeInterval(5 * day) + 3 * StreakCalculator.defaultRebootGapCap
        #expect(witness?.wallClock == bound, "3 stacked heals grant exactly 3·cap, never more")

        // A CloudKit-delivered epoch-anchored quit read at the witness wall shows the
        // channel-parity bound: truth + 3·cap — identical to what 3 in-window jumps
        // would have yielded, and no more.
        let foreignID = UUID()
        try insertRow(
            id: foreignID, into: h.container.mainContext,
            createdAt: epoch, startAt: epoch,
            anchor: MonotonicAnchor(bootID: alienBoot, uptime: 0, wallClock: epoch)
        )
        h.clock.setWallClock(bound)
        let foreign = try h.repository.streakValue(for: foreignID)
        #expect(foreign.elapsedSeconds == 5 * day + 3 * cap)
    }

    @Test func test_lastKnownGood_uptimeAccrual_advancesConservatively_neverTheLyingWall() throws {
        // Path 3: when the two-gate wall advance declines, the witness still accrues
        // by UPTIME DELTA only — pure monotonic arithmetic, no wall claim consulted,
        // so a forward-set wall can never launder in through it.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(day))
        _ = try h.repository.streakValue(for: quit.id)
        #expect(h.lkgStore.load()?.wallClock == epoch + TimeInterval(day), "gated advance (existing pin)")

        // Wall dragged +900d, uptime unchanged: gates decline, accrual has Δ=0.
        h.clock.setWallClock(epoch + TimeInterval(900 * day))
        _ = try h.repository.streakValue(for: quit.id)
        #expect(h.lkgStore.load()?.wallClock == epoch + TimeInterval(day))

        // One real hour passes under the lying wall: the witness advances by exactly
        // that hour — never toward the claimed wall.
        h.clock.advance(by: 3_600)
        _ = try h.repository.streakValue(for: quit.id)
        let witness = h.lkgStore.load()
        #expect(witness?.wallClock == epoch + TimeInterval(day) + 3_600)
        #expect(witness?.uptime == 50_000 + TimeInterval(day) + 3_600)
    }

    @Test func test_lastKnownGood_chainReconverges_afterHealLagDecaysBelowCap() throws {
        // The witness's purpose, end to end: after one >cap power-off the chain is
        // broken (the old rules would re-collapse every streak to ~cap at each
        // subsequent reboot, forever). With restart + accrual the lag decays by
        // (cap − true gap) per cycle until the ordinary two-gate advance re-certifies
        // the REAL wall. Numbers probe-verified in the Session 07 red team.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(5 * day))
        _ = try h.repository.streakValue(for: quit.id)

        // 30-day power-off; boot B at day 35. Heal resumes 19d; witness day 19 (lag 16d).
        h.clock.reboot(bootID: bootB, uptime: 5_000)
        h.clock.setWallClock(epoch + TimeInterval(35 * day))
        try h.repository.recomputeDerivedState()
        #expect(try h.repository.streakValue(for: quit.id).elapsedSeconds == 5 * day + cap)
        #expect(h.lkgStore.load()?.wallClock == epoch + TimeInterval(5 * day) + StreakCalculator.defaultRebootGapCap)

        // A month of honest boot-B use: streak 54d; the witness accrues 1:1 (day 54).
        h.clock.advance(by: TimeInterval(35 * day))
        let atDay70 = try h.repository.streakValue(for: quit.id)
        #expect(atDay70.clockSanity == .normal)
        #expect(atDay70.elapsedSeconds == 54 * day)
        #expect(h.lkgStore.load()?.wallClock == epoch + TimeInterval(19 * day + 35 * day))

        // Instant reboot to boot C at day 70: only the residual lag re-freezes
        // (52d, not 14d — no collapse), and the next heal shrinks the lag to 2d.
        h.clock.reboot(bootID: bootC, uptime: 1_000)
        let rebooted = try h.repository.streakValue(for: quit.id)
        #expect(rebooted.clockSanity == .clockRolledBack)
        #expect(rebooted.elapsedSeconds == 52 * day, "38d witnessed + cap — the streak survives the reboot")
        try h.repository.recomputeDerivedState()
        #expect(try h.repository.streakValue(for: quit.id).elapsedSeconds == 52 * day)
        #expect(h.lkgStore.load()?.wallClock == epoch + TimeInterval(68 * day))

        // Ten more honest days, then reboot to boot D at day 80: the gap since the
        // witness (2d) is inside the cap, so the read is .normal WITHOUT healing and
        // the ordinary two-gate advance re-certifies the REAL wall. Chain restored.
        h.clock.advance(by: TimeInterval(10 * day))
        _ = try h.repository.streakValue(for: quit.id)
        h.clock.reboot(bootID: bootD, uptime: 500)
        let reconverged = try h.repository.streakValue(for: quit.id)
        #expect(reconverged.clockSanity == .normal)
        #expect(reconverged.elapsedSeconds == 62 * day)
        let witness = h.lkgStore.load()
        #expect(witness?.bootID == bootD)
        #expect(witness?.wallClock == epoch + TimeInterval(80 * day), "the real wall, re-certified by the gates")
    }
}
