import Foundation
import StreakEngine
import SwiftData
import Testing
@testable import Unhooked

// E3.1 unit lane — panic path productionizing. The plan-named tests from
// implementation-plan.md E3.1 are verbatim where the unit tier owns them,
// scope-adjusted per resume-prompt v2.0 §objective:
//   - `test_motivationsPreCache_updatedOnEveryQuitWrite` — the pre-cache is the
//     architecture §4/ADR-6 `panic-snapshot.json` FILE in the App Group (Session 09
//     design-panel ruling: §4/§10/§11/ADR-6 outrank the plan's "app-group defaults"
//     phrasing), so its ERASE coverage lands in the same session (the Session 08
//     review-confirmed carry item — file-shaped sentinel tests below);
//   - `test_panicLaunch_skipsSDKInitBeforeFirstFrame` is scope-adjusted to
//     "zero store/repository work before the panic first frame" (no SDKs exist yet):
//     the init-order spy proves the provider opens nothing pre-frame and that the
//     PANIC route opens nothing even post-frame;
//   - `test_panicLaunch_withQuitID_selectsThatQuit` / `_noQuitSelected_showsQuitPicker`
//     pin the pure selection matrix (the picker itself is placeholder-grade UI; the
//     real flow is E3.2); the quitID channel is an App Group key — the widget intent
//     stays parameterless until E3.3 and will write this same key;
//   - the permanent latency gate stays BLOCKED on the operator's E0.3 device
//     measurement (docs/spike-panic-latency.md still `_pending_`) — the existing
//     harness is untouched and no verdict is hardcoded anywhere.
// Red evidence for this file = the CI run on the red commit (session-rules app-lane
// mechanics).

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

/// Inert CloudKit-seam stub: nothing here exercises the cloud policy (that is
/// EraseEverythingTests' pin); erase tests here only need the local half to run.
@MainActor
private final class StubCloudSync: CloudSyncControlling {
    func accountStatus() async -> CloudAccountStatus { .available }
    func deleteAllPrivateZones() async throws {}
}

/// One in-memory store + repository per test, zero cross-test state; the pre-cache
/// store points at a per-test temp directory standing in for the App Group root.
@MainActor
private struct Harness {
    let container: ModelContainer
    let clock: ManualClock
    let spy: SpyWidgetRefresher
    let lkgStore: LastKnownGoodStore
    let appGroupDefaults: UserDefaults
    let snapshotDirectory: URL
    let panicSnapshotStore: PanicSnapshotStore
    let repository: QuitRepository

    init() throws {
        container = try ModelContainer(
            for: PersistentStore.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        clock = ManualClock()
        spy = SpyWidgetRefresher()
        lkgStore = LastKnownGoodStore(
            defaults: UserDefaults(suiteName: "e31-lkg-\(UUID().uuidString)")!
        )
        appGroupDefaults = UserDefaults(suiteName: "e31-group-\(UUID().uuidString)")!
        snapshotDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("e31-snap-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: snapshotDirectory, withIntermediateDirectories: true)
        panicSnapshotStore = PanicSnapshotStore(directoryURL: snapshotDirectory)
        repository = QuitRepository(
            container: container,
            clock: clock,
            widgetRefresher: spy,
            lastKnownGoodStore: lkgStore,
            cloud: StubCloudSync(),
            appGroupDefaults: appGroupDefaults,
            panicSnapshotStore: panicSnapshotStore,
            debounceSleep: { _ in }
        )
    }

    /// Inserts a raw duplicate Quit row the way a CloudKit import would materialize
    /// it — same `id`, its own field values (the E2.3 merge is the launch pass's
    /// observable side effect).
    @discardableResult
    func insertDuplicate(of id: UUID, motivations: [String] = []) throws -> Quit {
        let dup = Quit()
        dup.id = id
        dup.createdAt = epoch - TimeInterval(10 * day)
        dup.startAt = epoch - TimeInterval(10 * day)
        dup.motivations = motivations
        container.mainContext.insert(dup)
        try container.mainContext.save()
        return dup
    }
}

/// Counting store-opener spy for the init-order pins: every open mints a fresh
/// throwaway in-memory container (or hands back a prepared one).
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

/// Test-double bundle for the provider's `makeRepository` seam, so provider tests
/// never touch the real App Group suite or the production clock.
@MainActor
private struct RepoDoubles {
    let clock = ManualClock()
    let spy = SpyWidgetRefresher()
    let lkgStore = LastKnownGoodStore(
        defaults: UserDefaults(suiteName: "e31-provider-lkg-\(UUID().uuidString)")!
    )
    let appGroupDefaults = UserDefaults(suiteName: "e31-provider-group-\(UUID().uuidString)")!
    let panicSnapshotStore: PanicSnapshotStore

    init() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("e31-provider-snap-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        panicSnapshotStore = PanicSnapshotStore(directoryURL: directory)
    }

    func make(_ container: ModelContainer) -> QuitRepository {
        QuitRepository(
            container: container,
            clock: clock,
            widgetRefresher: spy,
            lastKnownGoodStore: lkgStore,
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

@MainActor
@Suite("E3.1 · panic path productionizing")
struct PanicPathTests {

    // MARK: - Pre-cache: rebuilt on every repository write (plan-named)

    @Test func test_motivationsPreCache_updatedOnEveryQuitWrite() throws {
        let h = try Harness()

        // Write path 1 — createQuit.
        let quit = try h.repository.createQuit(habitCategory: .vape)
        var cached = try #require(
            h.panicSnapshotStore.read(),
            "createQuit must rebuild the panic pre-cache (ADR-6: every mutating write)"
        )
        #expect(cached.quits.map(\.id) == [quit.id])

        // Write path 2 — logUrgeEvent, after the user's verbatim motivations changed.
        quit.motivations = ["For my kids", "money for the trip"]
        _ = try h.repository.logUrgeEvent(quitID: quit.id, source: .inApp, outcome: .averted)
        cached = try #require(h.panicSnapshotStore.read())
        #expect(
            cached.quits.first?.motivations == ["For my kids", "money for the trip"],
            "motivations render VERBATIM in the panic flow — the cache carries them unedited, in user order"
        )

        // Write path 3 — logSlip.
        quit.motivations = ["For my kids", "money for the trip", "breathe easier"]
        h.clock.advance(by: TimeInterval(3 * day))
        _ = try h.repository.logSlip(quitID: quit.id, note: nil)
        cached = try #require(h.panicSnapshotStore.read())
        #expect(cached.quits.first?.motivations.count == 3)

        // Write path 4 — recomputeDerivedState, when it mutates (dedupe merge). The
        // duplicate carries a motivation of its own so the merged union is observably
        // different from the pre-merge cache.
        try h.insertDuplicate(of: quit.id, motivations: ["quiet mornings"])
        #expect(try h.repository.recomputeDerivedState(), "the seeded duplicate must make the pass mutate")
        cached = try #require(h.panicSnapshotStore.read())
        #expect(cached.quits.count == 1, "the cache reflects the MERGED store truth")
        #expect(
            cached.quits.first?.motivations.contains("quiet mornings") == true,
            "a mutating recompute must rebuild the cache with the merged motivations union"
        )
    }

    @Test func test_panicPreCache_discreetQuit_labelStripped_motivationsKept() throws {
        let h = try Harness()

        let open = try h.repository.createQuit(habitCategory: .custom, customLabel: "Late-night snacking")
        let hidden = try h.repository.createQuit(habitCategory: .porn)
        hidden.discreetMode = true
        hidden.motivations = ["be present with my partner"]
        _ = try h.repository.logUrgeEvent(quitID: hidden.id, source: .inApp, outcome: .averted)

        let cached = try #require(h.panicSnapshotStore.read())
        let openCard = try #require(cached.quits.first { $0.id == open.id })
        let hiddenCard = try #require(cached.quits.first { $0.id == hidden.id })

        #expect(openCard.label == "Late-night snacking", "a custom label is the user's own words — it IS the display label")
        #expect(openCard.discreet == false)
        #expect(hiddenCard.label == nil, "§10: discreet mode strips labels from snapshots (readable pre-unlock)")
        #expect(hiddenCard.discreet == true)
        #expect(
            hiddenCard.motivations == ["be present with my partner"],
            "discretion strips the LABEL, not the flow's content — motivations stay verbatim"
        )
    }

    @Test func test_panicPreCache_excludesSlipNotes() throws {
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .alcohol)
        h.clock.advance(by: TimeInterval(2 * day))
        _ = try h.repository.logSlip(quitID: quit.id, note: "midnight kitchen slip, talked to J about it")

        // §10 hard boundary: slip notes live ONLY in the store — never in the
        // pre-unlock-readable App Group snapshot. Asserted on the raw bytes so no
        // decoding step can hide a leak.
        let data = try #require(
            try? Data(contentsOf: h.panicSnapshotStore.fileURL),
            "the pre-cache file must exist after a slip write (it is rebuilt on every write)"
        )
        let raw = try #require(String(data: data, encoding: .utf8))
        #expect(!raw.contains("midnight kitchen"), "slip notes must be physically absent from panic-snapshot.json (§10)")
    }

    // MARK: - Erase coverage (the Session 08 review-confirmed carry item)

    @Test func test_erase_removesPanicSnapshotFile_unownedSiblingSurvives() async throws {
        let h = try Harness()
        _ = try h.repository.createQuit(habitCategory: .vape)
        // Seed the owned file directly so this pin is independent of the write hook.
        try h.panicSnapshotStore.write(PanicSnapshot(quits: [card("Vaping")]))
        let sibling = h.snapshotDirectory.appendingPathComponent("unrelated-user-file.txt")
        try "keep me".write(to: sibling, atomically: true, encoding: .utf8)

        try await h.repository.eraseEverything()

        #expect(
            !FileManager.default.fileExists(atPath: h.panicSnapshotStore.fileURL.path),
            "erase must remove the owned panic-snapshot.json — verbatim motivations are exactly what one-tap erase promises to destroy (Session 08 carry item)"
        )
        #expect(
            FileManager.default.fileExists(atPath: sibling.path),
            "the sweep is an owned FILE SET, never a directory (E2.4 scope pin)"
        )
    }

    @Test func test_panicPreCache_notResurrectedByErase() async throws {
        let h = try Harness()
        _ = try h.repository.createQuit(habitCategory: .weed)
        try h.panicSnapshotStore.write(PanicSnapshot(quits: [card("Weed")]))

        try await h.repository.eraseEverything()
        // Drain the debounced reload: if any post-erase hook (reload, save observer)
        // wrongly rebuilt the cache, it would reappear here.
        await h.repository.drainPendingWidgetReload()

        #expect(
            !FileManager.default.fileExists(atPath: h.panicSnapshotStore.fileURL.path),
            "nothing after the erase sweep may rewrite the pre-cache — erased means absent until a NEW write era begins"
        )
        #expect(h.panicSnapshotStore.read() == nil)
    }

    // MARK: - quitID selection channel (the parameterless intent's E3.3 seam)

    @Test func test_panicIntent_quitIDChannel_roundTripsThroughAppGroup() throws {
        PanicLaunchFlag.clear()
        defer { PanicLaunchFlag.clear() }
        #expect(PanicLaunchFlag.selectedQuitID() == nil)

        let id = UUID()
        PanicLaunchFlag.set(quitID: id)
        #expect(
            PanicLaunchFlag.selectedQuitID() == id,
            "the selection must persist for the intent → app process hop (E3.3 writes this same key)"
        )

        // The key must live in the App Group suite specifically — that is what makes
        // it visible across the extension/app boundary.
        let groupDefaults = try #require(UserDefaults(suiteName: AppIdentifiers.appGroupID))
        #expect(groupDefaults.string(forKey: PanicLaunchFlag.quitIDKey) == id.uuidString)

        PanicLaunchFlag.clear()
        #expect(
            PanicLaunchFlag.selectedQuitID() == nil,
            "clear() must drop the selection together with the flag — a stale selection would hijack the NEXT panic launch"
        )
    }

    // MARK: - Panic route selection matrix (plan-named; pure resolver)

    @Test func test_panicLaunch_withQuitID_selectsThatQuit() {
        let first = card("Vaping")
        let second = card(nil, discreet: true, motivations: ["sleep"])
        let third = card("Alcohol")
        let snapshot = PanicSnapshot(quits: [first, second, third])

        #expect(
            PanicRouteResolver.resolve(selectedQuitID: second.id, snapshot: snapshot)
                == .breathe(second),
            "a selected quitID must land directly on THAT quit's frame — no picker detour"
        )
    }

    @Test func test_panicLaunch_noQuitSelected_showsQuitPicker() {
        let first = card("Vaping")
        let second = card("Doomscrolling")
        let snapshot = PanicSnapshot(quits: [first, second])

        #expect(
            PanicRouteResolver.resolve(selectedQuitID: nil, snapshot: snapshot)
                == .picker([first, second]),
            "several quits and no selection → the picker, carrying the quits in cache (user) order"
        )
    }

    @Test func test_panicLaunch_singleQuit_skipsPicker() {
        let only = card("Vaping", motivations: ["For my kids"])
        let snapshot = PanicSnapshot(quits: [only])

        #expect(
            PanicRouteResolver.resolve(selectedQuitID: nil, snapshot: snapshot) == .breathe(only),
            "one quit needs no picker — a panicking user gets zero unnecessary taps"
        )
    }

    @Test func test_panicLaunch_zeroQuits_rendersBareBreatheFrame() {
        #expect(
            PanicRouteResolver.resolve(selectedQuitID: nil, snapshot: nil) == .empty,
            "no cache (fresh/erased install) → the bare breathe frame, never a crash or an empty picker"
        )
        #expect(
            PanicRouteResolver.resolve(selectedQuitID: nil, snapshot: PanicSnapshot(quits: [])) == .empty,
            "an empty cache behaves exactly like an absent one"
        )
    }

    @Test func test_panicLaunch_unknownQuitID_fallsBackLikeNoSelection() {
        let first = card("Vaping")
        let second = card("Alcohol")

        #expect(
            PanicRouteResolver.resolve(
                selectedQuitID: UUID(), snapshot: PanicSnapshot(quits: [first, second])
            ) == .picker([first, second]),
            "an unknown id (stale selection, erased quit) degrades to the no-selection behavior"
        )
        #expect(
            PanicRouteResolver.resolve(
                selectedQuitID: UUID(), snapshot: PanicSnapshot(quits: [first])
            ) == .breathe(first)
        )
    }

    // MARK: - Init-order pin (plan-named, scope-adjusted) + deferred launch wiring

    @Test func test_panicLaunch_skipsStoreWorkBeforeFirstFrame() throws {
        // The plan's test_panicLaunch_skipsSDKInitBeforeFirstFrame, scope-adjusted
        // (resume-prompt v2.0): no SDKs exist yet, so the pin is ZERO store/repository
        // work before the panic first frame — and on the panic route, none AFTER it
        // either (the panic scene renders exclusively from the pre-cache, ADR-6).
        let spy = StoreOpenSpy()
        let doubles = try RepoDoubles()
        let provider = RepositoryProvider(
            storeOpener: { try spy.open() },
            makeRepository: { doubles.make($0) }
        )
        #expect(
            spy.opens == 0,
            "constructing the provider happens in UnhookedApp.init — pre-frame — and must open nothing (ADR-6)"
        )

        provider.startIfNeeded(for: .panicPlaceholder)
        #expect(
            spy.opens == 0,
            "the PANIC route never opens the store — pre- or post-frame (E3.1 init-order pin)"
        )
        #expect(provider.repository == nil)
        // E7.1 (R24.2, additive strengthening): the entitlement stack lives
        // strictly INSIDE the guarded normal-route block above the store work
        // — the panic route constructs no adapter, no SDK, no model, ever.
        #expect(
            provider.entitlementModel == nil,
            "the PANIC route never constructs the entitlement stack (E7.1 panic purity)"
        )
        // E7.2 (R25.12, additive strengthening): the Superwall/variant stack
        // rides the SAME guarded block — the panic route holds no assigner
        // and can never reach a Superwall configure (panic surfaces never
        // open the store OR query entitlements, pinned since S24).
        #expect(
            provider.paywallAssigner == nil,
            "the PANIC route never constructs the paywall assigner (E7.2 panic purity)"
        )
    }

    @Test func test_launch_normalRoute_opensStoreOnce_recomputes_andRefreshesPreCache() throws {
        // Seeded duplicate rows prove recomputeDerivedState() ran at launch (the E2.3
        // pass is its observable); the rewritten pre-cache proves the launch refresh
        // ran (heals failed writes, prunes post-erase residue).
        let container = try ModelContainer(
            for: PersistentStore.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        let sharedID = UUID()
        for offset in [0, 5] {
            let row = Quit()
            row.id = sharedID
            row.createdAt = epoch - TimeInterval(offset * day)
            row.startAt = epoch - TimeInterval(offset * day)
            container.mainContext.insert(row)
        }
        try container.mainContext.save()

        let spy = StoreOpenSpy(returning: container)
        let doubles = try RepoDoubles()
        let provider = RepositoryProvider(
            storeOpener: { try spy.open() },
            makeRepository: { doubles.make($0) }
        )

        provider.startIfNeeded(for: .placeholderTabs)

        #expect(spy.opens == 1, "the normal route opens the store exactly once, post-frame")
        let repository = try #require(
            provider.repository,
            "the provider must publish the repository for its E3.2/E4.1 consumers"
        )
        #expect(
            try repository.activeQuits().count == 1,
            "launch must run recomputeDerivedState(): the seeded duplicates fold into one row"
        )
        #expect(
            doubles.panicSnapshotStore.read() != nil,
            "launch must refresh the pre-cache from store truth"
        )
    }

    @Test func test_repositoryProvider_startIsIdempotent() throws {
        let spy = StoreOpenSpy()
        let doubles = try RepoDoubles()
        let provider = RepositoryProvider(
            storeOpener: { try spy.open() },
            makeRepository: { doubles.make($0) }
        )

        provider.startIfNeeded(for: .placeholderTabs)
        let first = provider.repository
        provider.startIfNeeded(for: .placeholderTabs)

        #expect(spy.opens == 1, "start is idempotent — scene-phase churn must not reopen the store")
        #expect(provider.repository === first)
    }

    // MARK: - Real App Group round-trip (the UI seed hook + cold read share this store)

    @Test func test_panicSnapshotStore_appGroupRoundTrip() throws {
        // Pins the PRODUCTION location end to end in the app process: the same
        // `PanicSnapshotStore.appGroup()` the UITEST seed hook writes and the cold
        // panic launch reads. Isolates the file mechanics from any UI-lane failure.
        let store = try #require(
            PanicSnapshotStore.appGroup(),
            "the App Group container must resolve in the app process (E0.2)"
        )
        defer { try? FileManager.default.removeItem(at: store.fileURL) }

        let snapshot = PanicSnapshot(quits: [
            card("Vaping", motivations: ["For my kids"]),
            card(nil, discreet: true, motivations: ["sleep"]),
        ])
        try store.write(snapshot)
        #expect(store.read() == snapshot, "the real container round-trips the cache byte-faithfully")
    }

    // MARK: - Review pins (Session 09 diff review, both 3/3-confirmed)

    @Test func test_launch_nonMutatingLaunch_refreshesStalePreCacheFromStoreTruth() throws {
        // Kills the delete-the-call mutant on RepositoryProvider's
        // `repository.refreshPanicSnapshot()`: the other launch test seeds duplicates,
        // so recomputeDerivedState's OWN didMutate rebuild masks the launch refresh.
        // Here the launch is non-mutating — only the explicit refresh can heal the
        // stale cache (its exact documented purpose: a prior best-effort write that
        // failed, or pre-erase residue, must never survive into a cold panic frame).
        let container = try ModelContainer(
            for: PersistentStore.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        let quit = Quit()
        quit.motivations = ["morning clarity"]
        // E6.2: "clean" now includes a stamped ADR-11 zone — a directly-inserted row
        // with the "" default is a pre-E6.2 row the launch pass legitimately
        // backfills (a mutation), which would mask the refresh this test isolates.
        quit.startTimeZoneIdentifier = TimeZone.current.identifier
        container.mainContext.insert(quit)
        try container.mainContext.save()

        let doubles = try RepoDoubles()
        // Fixture property: this store must be non-mutating under the launch pass,
        // or the test cannot isolate the refresh (the probe shares the container).
        #expect(
            try doubles.make(container).recomputeDerivedState() == false,
            "fixture must not mutate — a single clean quit has nothing to merge or heal"
        )

        // A stale cache from a "previous era": wrong quit, wrong motivations.
        try doubles.panicSnapshotStore.write(PanicSnapshot(quits: [
            card("Vaping", motivations: ["stale, from before"])
        ]))

        let spy = StoreOpenSpy(returning: container)
        let provider = RepositoryProvider(
            storeOpener: { try spy.open() },
            makeRepository: { doubles.make($0) }
        )
        provider.startIfNeeded(for: .placeholderTabs)

        let cached = try #require(doubles.panicSnapshotStore.read())
        #expect(
            cached.quits.map(\.id) == [quit.id]
                && cached.quits.first?.motivations == ["morning clarity"],
            "a NON-mutating launch must still rewrite the pre-cache from store truth — only the explicit launch refresh can have produced this"
        )
    }

    @Test(arguments: [
        (HabitCategory.vape, "Vaping"),
        (HabitCategory.porn, "Porn"),
        (HabitCategory.alcohol, "Alcohol"),
        (HabitCategory.weed, "Weed"),
        (HabitCategory.doomscroll, "Doomscrolling"),
        (HabitCategory.custom, "Your goal"),
    ]) func test_panicPreCache_standardCategoryLabel_isTheExactBrandNoun(
        category: HabitCategory, expected: String
    ) throws {
        // Kills the swapped/wrong-arm mutant in displayLabel(for:): these nouns are
        // what a NON-discreet quit renders in the picker (brand-reviewed, clinical,
        // no shame lexicon) — the discreet/custom-label arms are pinned elsewhere and
        // never reach the switch.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: category)
        let cached = try #require(h.panicSnapshotStore.read())
        #expect(
            cached.quits.first { $0.id == quit.id }?.label == expected,
            "the pre-cache label for a bare \(category.rawValue) quit is the exact brand noun"
        )
    }

    // MARK: - Production clock conformance

    @Test func test_liveClock_readingsAreUsableGuardEvidence() {
        let clock = LiveClock()
        let a = clock.monotonicNow
        let b = clock.monotonicNow

        #expect(a.bootID == b.bootID, "the boot session ID is stable within a process — the guard compares it for equality")
        #expect(a.uptime > 0, "uptime must be a real positive reading (sleep-inclusive by API choice: mach_continuous_time)")
        #expect(b.uptime >= a.uptime, "uptime is monotonic — it can never run backwards")
        #expect(
            abs(clock.now.timeIntervalSince(Date())) < 60,
            "now is the actual current wall clock (the ONE sanctioned production Date() read)"
        )
    }

    // MARK: - E4.1 · pre-cache carries the streak fields the cold slip flow frames on

    @Test func test_panicPreCache_carriesStreakFields_forSlipFraming() throws {
        // E4.1: the cold slip flow computes its forgiveness framing from the pre-cache
        // card's new additive streak fields (Shared/PanicSnapshot; decision record §UI),
        // because the store NEVER opens on that route (E3.1 zero-store pin). So every
        // mutating rebuild must carry startAt + the clock-integrity anchor scalars +
        // the archived best + momentum% as store truth.
        // RED: the stub rebuildPanicSnapshot builds each card with only
        // id/label/discreet/motivations, so all five fields below read nil.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        h.clock.advance(by: TimeInterval(3 * day))
        _ = try h.repository.logSlip(quitID: quit.id, note: nil)

        let cached = try #require(h.panicSnapshotStore.read())
        let slipCard = try #require(cached.quits.first { $0.id == quit.id })

        // startAt = the post-slip current-streak start (the guarded slip instant, equal
        // to the anchor's wallClock by the engine's documented invariant).
        #expect(slipCard.startAt == epoch + TimeInterval(3 * day))
        // The anchor scalars the cold framing guards its elapsed with (raw, not the
        // engine type — Shared stays dependency-free for the widget target).
        #expect(slipCard.anchorBootID == bootA)
        #expect(slipCard.anchorUptime == TimeInterval(50_000 + 3 * day))
        // Archived best: the 3-day streak the slip just banked ("Your best is safe").
        #expect(slipCard.bestStreakSeconds == 3 * day)
        // Momentum is UNCHANGED across a slip in the same tick (ratified S04). A quit
        // that never slipped banks its WHOLE streak on archiving, so clean == tracked
        // ⇒ momentum 1.0 ⇒ 100% — the number the forgiveness screen shows unchanged.
        #expect(
            slipCard.momentumPercent == 100,
            "a fresh quit's momentum stays 100% across the archive (clean days over total days, whole streak banked)"
        )
    }

    @Test func test_panicPreCache_stillExcludesNotesAndFreeText() throws {
        // DECLARED green-from-birth guard (test-suite §7.1 exemption by declaration):
        // extends the §10 note-exclusion pin (test_panicPreCache_excludesSlipNotes) to
        // the E4.1 card SHAPE, which now carries streak SCALARS (startAt/anchor/best/
        // momentum) — all numeric/UUID, never free text. The note still lives ONLY in
        // the store; the sole free text the card may carry stays label + verbatim
        // motivations. Both halves already hold at red (the stub rebuild omits the note
        // and adds no free-text field), so this passes from birth — its value is
        // locking the pre-unlock-readable boundary as the card grows in E4.1.
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .alcohol, customLabel: "Late-night wine")
        quit.motivations = ["be present with my kids", "sleep through the night"]
        h.clock.advance(by: TimeInterval(2 * day))
        _ = try h.repository.logSlip(quitID: quit.id, note: "midnight kitchen slip, talked to J about it")

        // Raw bytes so no decoding step can hide a leak (mirrors the §10 pin's method).
        let data = try #require(
            try? Data(contentsOf: h.panicSnapshotStore.fileURL),
            "the pre-cache file must exist after a slip write (rebuilt on every write)"
        )
        let raw = try #require(String(data: data, encoding: .utf8))
        #expect(!raw.contains("midnight kitchen"), "the slip note stays physically absent even as the card gains streak fields (§10)")
        #expect(!raw.contains("talked to J"), "no fragment of the note may reach the pre-unlock-readable file")
        // The allowed free text still rides the card verbatim — proves the absence
        // checks above are not vacuous and that the streak-carrying card kept the
        // panic-flow render source intact.
        #expect(raw.contains("be present with my kids"))
        #expect(raw.contains("Late-night wine"))

        let decoded = try #require(h.panicSnapshotStore.read())
        let slipCard = try #require(decoded.quits.first { $0.id == quit.id })
        #expect(
            slipCard.motivations == ["be present with my kids", "sleep through the night"],
            "label + motivations remain the ONLY free-text fields on the card — every E4.1 addition is a scalar"
        )
        #expect(slipCard.label == "Late-night wine")
    }

    // MARK: - E9.3 · the eyes-free pacer preference channel (R28.2)

    /// DESIGNED RED (Session 28 manifest R1): the ONE writer persists the preference
    /// and its rebuild stamps the pre-cache ENVELOPE — the cold panic route's only
    /// legal read source (ADR-6: the store never opens on that path). RED because the
    /// red commit's rebuild does not stamp the envelope yet (the field decodes nil ⇒
    /// reads false); GREEN stamps it from AppSettings inside `rebuildPanicSnapshot`.
    @Test func test_hapticOnlyBreathPacer_stampedIntoPreCacheFromSettings() throws {
        let h = try Harness()
        _ = try h.repository.createQuit(habitCategory: .vape)

        try h.repository.setHapticOnlyBreathPacer(true)

        #expect(
            h.repository.hapticOnlyBreathPacer() == true,
            "the setter persists the AppSettings field (the discreetIconId read shape)"
        )
        let snapshot = try #require(
            h.panicSnapshotStore.read(),
            "the setter's rebuild rewrites the pre-cache (an active quit exists)"
        )
        #expect(
            snapshot.hapticOnlyBreathPacer == true,
            "the setter's rebuild must stamp the eyes-free preference onto the pre-cache envelope — the cold panic route reads ONLY this file (ADR-6), so an unstamped envelope strands the preference in the store"
        )
    }
}
