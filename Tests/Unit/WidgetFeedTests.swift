import Foundation
import StreakEngine
import SwiftData
import Testing
@testable import Unhooked

// E6.2 unit lane — the APP HALF of the streak widget feed: the repository's
// widget-state.json writer (field set + §10 absence + guard-honest streakStart),
// the ADR-11 startTimeZoneIdentifier stamp/backfill, the erase sweep's new owned
// file, the zero-active-quits divergence, and the widget quit selector's seam.
// Red evidence for this file = the CI run on the red commit (session-rules app-lane
// mechanics): the writer is unwired at red (rebuildPanicSnapshot writes ONLY
// panic-snapshot.json), NO creator stamps the timezone, and eraseLocalArtifacts does
// not yet own widget-state.json — so A1–A4/E1/E4 fail honestly; A5-shaped born-green
// pins (E2 sibling-survives, C1 selector) guard the boundaries they land on.
//
// This lane CANNOT run locally (it needs the simulator/SwiftData); its evidence is the
// parse-gate + the predicted red manifest. Every fixture instant is a fixed literal
// (test-suite §3.1: no production Date() in fixtures).

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
/// EraseEverythingTests' pin); the erase pins here only need the local half to run.
@MainActor
private final class StubCloudSync: CloudSyncControlling {
    func accountStatus() async -> CloudAccountStatus { .available }
    func deleteAllPrivateZones() async throws {}
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

/// One in-memory store + repository per test, zero cross-test state; the pre-cache and
/// widget-feed stores share ONE per-test temp directory standing in for the App Group
/// root (the repository derives its widgetStateStore from that same directory).
@MainActor
private struct Harness {
    let container: ModelContainer
    let clock: ManualClock
    let spy: SpyWidgetRefresher
    let lkgStore: LastKnownGoodStore
    let appGroupDefaults: UserDefaults
    let snapshotDirectory: URL
    let panicSnapshotStore: PanicSnapshotStore
    /// A reader/writer pointed at the SAME directory the repository writes its feed to
    /// (widgetStateStore is derived from the pre-cache directory) — so seeding here IS
    /// seeding the repository's owned file, and reading here reads what it wrote.
    let widgetStore: WidgetStateStore
    let repository: QuitRepository

    init() throws {
        container = try ModelContainer(
            for: PersistentStore.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        clock = ManualClock()
        spy = SpyWidgetRefresher()
        lkgStore = LastKnownGoodStore(
            defaults: UserDefaults(suiteName: "e62-lkg-\(UUID().uuidString)")!
        )
        appGroupDefaults = UserDefaults(suiteName: "e62-group-\(UUID().uuidString)")!
        snapshotDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("e62-snap-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: snapshotDirectory, withIntermediateDirectories: true)
        panicSnapshotStore = PanicSnapshotStore(directoryURL: snapshotDirectory)
        widgetStore = WidgetStateStore(directoryURL: snapshotDirectory)
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
}

@MainActor
@Suite("E6.2 · widget feed (the app half)")
struct WidgetFeedTests {

    // MARK: - A1 · the writer writes the ruled field set (raw top-level + per-quit keys)

    @Test func test_widgetStateFile_afterMutatingWrite_carriesExactlyTheRuledKeySet() throws {
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape, weeklySpend: 26)
        h.clock.advance(by: TimeInterval(day))
        _ = try h.repository.logUrgeEvent(quitID: quit.id, source: .inApp, outcome: .averted)

        // Asserted over the RAW JSON bytes (JSONSerialization), not a decode round-trip:
        // a decode step would silently tolerate an extra key the encoder emitted.
        let data = try #require(
            try? Data(contentsOf: h.widgetStore.fileURL),
            "widget-state.json must exist after a mutating write — the repository rebuilds it on every write like the panic pre-cache (unwired at red: rebuildPanicSnapshot writes only panic-snapshot.json)"
        )
        let top = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(
            Set(top.keys) == Set(["schemaVersion", "generatedAt", "quits"]),
            "the feed's top level is exactly {schemaVersion, generatedAt, quits} — nothing more (an extra top-level key is a §10 leak)"
        )
        let quits = try #require(top["quits"] as? [[String: Any]])
        let firstQuit = try #require(quits.first, "one active quit ⇒ one card in the feed")
        #expect(
            Set(firstQuit.keys) == Set([
                "id", "streakStart", "timeZoneIdentifier", "weeklySpend", "currencyCode",
                "bankedCleanSeconds", "momentumPercent", "milestoneHours",
            ]),
            "each card carries EXACTLY the ruled per-quit key set (R1) — no habitCategory, no label, no motivations, no slip data, no discreet flag"
        )
    }

    // MARK: - A2 · absence: the produced bytes carry no habit leak, no forbidden key name

    @Test func test_widgetStateBytes_carryNoHabitLeak_norForbiddenKeyNames() throws {
        let h = try Harness()
        // Seed the store with habit-identifying content that MUST NOT reach the
        // pre-unlock-readable feed: a leak-y label + verbatim motivations (both live in
        // the store and the panic pre-cache; the widget feed omits them entirely).
        let quit = try h.repository.createQuit(habitCategory: .vape, customLabel: "porn at night", weeklySpend: 26)
        quit.motivations = ["stop vaping for good", "no more alcohol"]
        // A known-safe fixed zone so the scan never trips on a geographic tz identifier.
        quit.startTimeZoneIdentifier = "America/New_York"
        h.clock.advance(by: TimeInterval(day))
        _ = try h.repository.logUrgeEvent(quitID: quit.id, source: .inApp, outcome: .averted)

        let data = try #require(
            try? Data(contentsOf: h.widgetStore.fileURL),
            "widget-state.json must exist after a mutating write (unwired at red)"
        )
        let raw = try #require(String(data: data, encoding: .utf8))

        // Non-vacuity: the feed carries real content, so the absence checks below are
        // not passing over an empty/absent file (the §10 raw-bytes discipline).
        #expect(raw.contains(quit.id.uuidString), "the feed carries the quit id — the absence scan is not vacuous")
        #expect(raw.contains("USD"), "the feed carries the currency — real content, not a blank file")

        let lowered = raw.lowercased()
        // Habit-leak lexicon (the PanicEntryPointTests precedent, curated to habit NOUNS
        // that cannot collide with the feed's structural keys — "quit" is excluded
        // because the feed IS a list of `quits` by design).
        for token in ["vape", "vaping", "porn", "alcohol", "weed", "doomscroll", "smoke", "drink", "sober", "addiction", "relapse"] {
            #expect(
                !lowered.contains(token),
                "widget-state.json is readable pre-unlock (§10) — no habit noun may appear in its bytes: '\(token)'"
            )
        }
        // Forbidden KEY NAMES (the ruled absence set): the store carries these fields, the
        // feed must not name any of them.
        for key in ["label", "motivations", "habitcategory", "notes", "discreet"] {
            #expect(
                !lowered.contains(key),
                "the forbidden key name '\(key)' must be physically absent from the widget feed (R1 absence set)"
            )
        }
    }

    // MARK: - A3 · uncorrected read ⇒ the written streakStart is the STORED startAt, exactly

    @Test func test_widgetStreakStart_onUncorrectedRead_equalsStoredStartAt_subSecond() throws {
        let h = try Harness()
        // A sub-second creation instant: startAt = epoch + 0.25s. The reconstruct-from-
        // elapsed path (used ONLY on a guard-corrected read) would lose the fraction; an
        // uncorrected read must write the stored startAt byte-for-byte.
        h.clock.advance(by: 0.25)
        let quit = try h.repository.createQuit(habitCategory: .vape, weeklySpend: 26)
        h.clock.advance(by: TimeInterval(2 * day)) // ordinary honest time (no rollback)
        _ = try h.repository.logUrgeEvent(quitID: quit.id, source: .inApp, outcome: .averted)

        let feed = try #require(
            h.widgetStore.read(),
            "the feed must exist after a mutating write (unwired at red)"
        )
        let card = try #require(feed.quits.first)
        #expect(
            card.streakStart == quit.startAt,
            "an uncorrected (.normal) read writes the STORE's startAt exactly — sub-second fidelity distinguishes it from a now−elapsed reconstruction (R3)"
        )
    }

    // MARK: - A4 · the ADR-11 fixed zone: stamped at BOTH creators, backfilled once,
    //             never empty in the feed

    @Test func test_createQuit_stampsStartTimeZoneIdentifier_atCreation() throws {
        let h = try Harness()
        let quit = try h.repository.createQuit(habitCategory: .vape)
        #expect(
            quit.startTimeZoneIdentifier == TimeZone.current.identifier,
            "createQuit(...) stamps the quit's FIXED day-boundary zone at creation (ADR-11) — unstamped (\"\") at red"
        )
    }

    @Test func test_createQuitFromProfile_stampsStartTimeZoneIdentifier_atCreation() throws {
        let h = try Harness()
        // The quiz creator (the second create path); its answers map through the proven
        // Linux-verified draft (a habit + spend + goal is a complete minimal profile,
        // per QuizCompletionTests).
        let profile = QuizProfile()
        profile.answers = [
            QuizAnswer(stepID: "habit", choiceIDs: ["vape"]),
            QuizAnswer(stepID: "spend", choiceIDs: [], freeText: "26"),
            QuizAnswer(stepID: "goal", choiceIDs: ["quit"]),
        ]

        let quit = try h.repository.createQuit(from: profile)

        #expect(
            quit.startTimeZoneIdentifier == TimeZone.current.identifier,
            "createQuit(from:) stamps the fixed zone too — BOTH creators pinned (R2); unstamped (\"\") at red"
        )
    }

    @Test func test_launchPass_backfillsEmptyStartTimeZone_andNeverWritesEmptyToFeed() throws {
        let h = try Harness()
        // A pre-E6.2 row: startTimeZoneIdentifier defaults to "" (no creator stamped it).
        let legacy = Quit()
        legacy.habitCategory = .vape
        legacy.startAt = epoch - TimeInterval(2 * day)
        legacy.createdAt = epoch - TimeInterval(2 * day)
        legacy.monotonicAnchor = coherentAnchor(startAt: epoch - TimeInterval(2 * day))
        h.container.mainContext.insert(legacy)
        try h.container.mainContext.save()
        #expect(legacy.startTimeZoneIdentifier == "", "seeded: a pre-E6.2 row awaiting its one-time backfill")

        _ = try h.repository.recomputeDerivedState() // the launch derived-state pass (RepositoryProvider.startIfNeeded)

        // Fresh context: the backfill must be DURABLE, not an in-memory echo.
        let fresh = ModelContext(h.container)
        let legacyID = legacy.id
        let healed = try #require(
            try fresh.fetch(FetchDescriptor<Quit>(predicate: #Predicate { $0.id == legacyID })).first
        )
        #expect(
            healed.startTimeZoneIdentifier == TimeZone.current.identifier,
            "the launch derived-state pass backfills the FIXED zone once (ADR-11) — a pre-E6.2 row gains a real zone, never stays \"\" (no backfill at red)"
        )
        // …and the feed that same pass writes never ships an empty identifier (the
        // writer's defensive TimeZone.current fallback + the backfill together).
        if let feed = h.widgetStore.read(), let card = feed.quits.first {
            #expect(
                !card.timeZoneIdentifier.isEmpty,
                "the pre-unlock feed must never carry an empty zone identifier"
            )
        }
    }

    // MARK: - C1 · the widget quit selector lists ACTIVE quits only (plan-named, R5)

    @Test func test_widgetConfiguration_quitSelector_listsActiveQuitsOnly() async throws {
        let h = try Harness()
        let a = try h.repository.createQuit(habitCategory: .vape)
        let b = try h.repository.createQuit(habitCategory: .porn)
        let c = try h.repository.createQuit(habitCategory: .alcohol)
        c.isArchived = true
        try h.container.mainContext.save()
        h.repository.refreshPanicSnapshot() // rebuild the pre-cache the selector reads

        // The widget's per-widget binding reuses PanicQuitEntity/PanicQuitQuery over the
        // panic pre-cache (R5 — the brand-safe label lives there; the widget feed stays
        // label-free). The pre-cache is built from activeQuits(), so the archived quit
        // never surfaces as a selectable widget target.
        let query = PanicQuitQuery(store: h.panicSnapshotStore)
        let suggested = try await query.suggestedEntities()

        #expect(
            suggested.map(\.id) == [a.id, b.id],
            "the quit selector offers exactly the two active quits, in the repository's total order — the archived quit is never a bindable widget target"
        )
    }

    // MARK: - E1/E2/E4 · erase & the zero-active-quits divergence (R3/R11)

    @Test func test_erase_removesWidgetStateFile() async throws {
        let h = try Harness()
        _ = try h.repository.createQuit(habitCategory: .vape)
        // Seed the owned file directly so the pin is independent of the write hook.
        try h.widgetStore.write(WidgetFeed(generatedAt: epoch, quits: []))
        #expect(FileManager.default.fileExists(atPath: h.widgetStore.fileURL.path), "seeded")

        try await h.repository.eraseEverything()

        #expect(
            !FileManager.default.fileExists(atPath: h.widgetStore.fileURL.path),
            "erase must remove the owned widget-state.json — a pre-unlock-readable App Group artifact joins the sweep in its landing session (R11); not in eraseLocalArtifacts' owned set at red"
        )
    }

    @Test func test_erase_scopedToOwnedFiles_unrelatedWidgetSiblingSurvives() async throws {
        let h = try Harness()
        _ = try h.repository.createQuit(habitCategory: .vape)
        try h.widgetStore.write(WidgetFeed(generatedAt: epoch, quits: []))
        let sibling = h.snapshotDirectory.appendingPathComponent("unrelated-widget-sibling.json")
        try Data("not ours".utf8).write(to: sibling)

        try await h.repository.eraseEverything()

        #expect(
            FileManager.default.fileExists(atPath: sibling.path),
            "the sweep is an owned FILE SET, never a directory (E2.4 scope pin) — an unrelated App Group file survives"
        )
    }

    @Test func test_launchRefresh_zeroActiveQuits_removesWidgetFile_panicFilePresentEmpty() throws {
        let h = try Harness()
        // No quits. Seed a stale widget feed (a prior tracking era) directly.
        try h.widgetStore.write(WidgetFeed(generatedAt: epoch, quits: [Self.fixtureCard]))
        #expect(FileManager.default.fileExists(atPath: h.widgetStore.fileURL.path), "seeded")

        h.repository.refreshPanicSnapshot() // the launch rebuild pass (store truth)

        #expect(
            !FileManager.default.fileExists(atPath: h.widgetStore.fileURL.path),
            "zero active quits ⇒ the widget feed is REMOVED (a nil read ⇒ ONE .unavailable entry clears the lock screen) — a present-empty feed would strand the erased streak's last pixels (R3); the file survives at red"
        )
        #expect(
            FileManager.default.fileExists(atPath: h.panicSnapshotStore.fileURL.path),
            "the deliberate divergence: the panic pre-cache is written present-empty while the widget feed must be ABSENT"
        )
    }

    /// A minimal feed card for the seed above (content is immaterial to a file-presence
    /// pin; a fixed literal instant per test-suite §3.1).
    private static let fixtureCard = WidgetQuitState(
        id: UUID(uuidString: "0B00071D-C4D0-4000-8000-0000000000A1")!,
        streakStart: epoch,
        timeZoneIdentifier: "America/New_York",
        weeklySpend: "26",
        currencyCode: "USD",
        bankedCleanSeconds: 0,
        momentumPercent: 50,
        milestoneHours: [24]
    )
}
