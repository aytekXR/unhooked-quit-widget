import Foundation
import StreakEngine
import SwiftData
import Testing
@testable import Ballast

// P2 (redesign §6.17) unit lane — Streak Detail's pure derivations + copy
// discipline. The milestone timeline is the 43 dormant catalog bodies' first
// renderer, so the row-state math (boundary-inclusive unlock, exactly one
// `next`, no missed states representable) and the DRAFT copy statics both get
// pinned here, with the house shame + habit-leak lexicons over every string
// the screen can render.

@Suite("P2 · Streak Detail composer + copy")
struct StreakDetailTests {

    private func ladder(_ hours: [Int]) -> [Milestone] {
        hours.map { Milestone(afterHours: $0, title: "t\($0)", body: "b\($0)") }
    }

    // MARK: - Row-state math

    @Test func test_milestoneRows_boundaryInclusive_singleNext_restLocked() {
        let rows = StreakDetailComposer.milestoneRows(
            elapsedSeconds: 24 * 3_600, // exactly AT the 24h rung — earned
            milestones: ladder([12, 24, 72, 168])
        )
        #expect(rows.map(\.state) == [
            .unlocked,
            .unlocked, // boundary-inclusive: exactly-at is earned (engine semantics)
            .next(progress: Double(24 * 3_600) / Double(72 * 3_600)),
            .locked,
        ])
        // Ascending regardless of input order; identity is the boundary hour.
        #expect(rows.map(\.afterHours) == [12, 24, 72, 168])
    }

    @Test func test_milestoneRows_unsortedCatalog_sortsAscending() {
        let rows = StreakDetailComposer.milestoneRows(
            elapsedSeconds: 0,
            milestones: ladder([168, 12, 72])
        )
        #expect(rows.map(\.afterHours) == [12, 72, 168])
        #expect(rows.first?.state == .next(progress: 0))
    }

    @Test func test_milestoneRows_fullyClimbedLadder_isAllUnlocked_neverFabricatesANext() {
        let rows = StreakDetailComposer.milestoneRows(
            elapsedSeconds: 10_000 * 3_600,
            milestones: ladder([12, 24])
        )
        #expect(rows.allSatisfy { $0.state == .unlocked })
    }

    @Test func test_milestoneRows_negativeElapsed_clampsToZero() {
        let rows = StreakDetailComposer.milestoneRows(
            elapsedSeconds: -50, milestones: ladder([12])
        )
        #expect(rows.first?.state == .next(progress: 0))
    }

    @Test func test_shippingCatalog_rendersFullLadders_inAppOnly() {
        // The catalog accessor feeds Streak Detail titles+bodies (in-app);
        // hours(for:) stays the widget feed's ceiling. Same source, same order.
        let catalog = MilestoneCatalog.shipping
        let full = catalog.milestones(for: .vape)
        #expect(!full.isEmpty, "the shipping vape ladder must decode")
        #expect(full.map(\.afterHours) == catalog.hours(for: .vape))
        #expect(full.allSatisfy { !$0.title.isEmpty && !$0.body.isEmpty })
    }

    @Test func test_durationText_isNonEmpty_forEveryShippingRung() {
        for category in HabitCategory.allCases {
            for hours in MilestoneCatalog.shipping.hours(for: category) {
                #expect(!StreakDetailComposer.durationText(afterHours: hours).isEmpty)
            }
        }
    }

    // MARK: - The notes read (store truth → the private notes list)

    /// `reflectionNotes(for:)` surfaces only non-empty notes, newest first —
    /// the written-but-never-resurfaced notes' first reader (§5.4).
    @MainActor
    @Test func test_reflectionNotes_nonEmptyOnly_newestFirst() throws {
        let cacheDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("p2-detail-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        let container = try ModelContainer(
            for: PersistentStore.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        let clock = StepClock()
        let repository = QuitRepository(
            container: container,
            clock: clock,
            widgetRefresher: NoopRefresher(),
            lastKnownGoodStore: LastKnownGoodStore(
                defaults: UserDefaults(suiteName: "p2-detail-lkg-\(UUID().uuidString)")!
            ),
            cloud: NoopCloud(),
            appGroupDefaults: UserDefaults(suiteName: "p2-detail-group-\(UUID().uuidString)")!,
            panicSnapshotStore: PanicSnapshotStore(directoryURL: cacheDirectory),
            debounceSleep: { _ in }
        )

        let quit = try repository.createQuit(habitCategory: .vape)
        clock.advance(by: 60)
        try repository.logSlip(quitID: quit.id, note: "first note")
        clock.advance(by: 60)
        try repository.logSlip(quitID: quit.id, note: nil) // no note — never surfaces
        clock.advance(by: 60)
        try repository.logSlip(quitID: quit.id, note: "") // empty — never surfaces
        clock.advance(by: 60)
        try repository.logSlip(quitID: quit.id, note: "second note")

        let notes = try repository.reflectionNotes(for: quit.id)
        #expect(notes.count == 2)
        #expect(notes.map(\.text) == ["second note", "first note"])
        #expect(notes[0].at >= notes[1].at)
    }

    @MainActor
    private final class NoopRefresher: WidgetRefreshing {
        func reloadAllTimelines() {}
    }

    /// Manual clock (test-suite §3.1): wall + monotonic move only when told —
    /// note ordering must never ride sub-second `Date()` luck.
    @MainActor
    private final class StepClock: ClockProviding {
        var now = Date(timeIntervalSince1970: 1_783_425_600)
        var monotonicNow = MonotonicNow(
            bootID: UUID(uuidString: "0B00071D-A000-4000-8000-000000000001")!,
            uptime: 50_000
        )

        func advance(by seconds: TimeInterval) {
            now += seconds
            monotonicNow.uptime += seconds
        }
    }

    @MainActor
    private final class NoopCloud: CloudSyncControlling {
        func accountStatus() async -> CloudAccountStatus { .unavailable }
        func deleteAllPrivateZones() async throws {}
    }

    // MARK: - Copy discipline (DRAFT statics; shame + leak scans)

    /// Cross-surface byte pins: one vocabulary, never silent divergence.
    @Test func test_discreetVocabulary_isByteIdenticalAcrossSurfaces() throws {
        let slipCopy = try #require(SlipCopy.loadShipping())
        let dashboard = try #require(slipCopy.dashboard)
        #expect(StreakDetailCopy.screenTitleDiscreet == dashboard.discreetRowLabel)
        #expect(StreakDetailCopy.screenTitleDiscreet == "Tracked goal")

        let script = try #require(PanicScript.loadShipping())
        let slippedExit = try #require(script.exit("slipped"))
        #expect(StreakDetailCopy.logSlipLabelDiscreet == slippedExit.labelDiscreet)
        #expect(StreakDetailCopy.logSlipLabelDiscreet == "Log it")
    }

    /// The averted line matches the copy-doc §6 bytes (singular + plural).
    @Test func test_avertedLine_carriesTheDraftBytes() {
        #expect(StreakDetailCopy.avertedLine(count: 1) == "1 urge surfed and counting.")
        #expect(StreakDetailCopy.avertedLine(count: 12) == "12 urges surfed and counting.")
    }

    /// Every string the screen can render, against the house shame lexicon
    /// (SlipLexiconTests' list verbatim — grow-only) — including a sample of
    /// the composed averted/locked lines.
    @Test func test_streakDetailStrings_containNoShameLexicon() {
        let shameSubstrings: [String] = [
            "failed", "failure", "failing", "blew it", "gave in",
            "ruined", "wasted", "thrown away", "you lost", "lost your streak",
            "back to day", "back to zero", "back to square one", "day zero",
            "start over", "from scratch", "reset to zero",
            "broke", "broken", "streak is over", "streak is gone", "streak is lost",
            "shame", "guilt", "weak", "willpower", "disappoint", "let yourself down",
            "relapse", "temptation", "purity", "clean slate", "sober up",
            "recover", "treatment",
        ]
        let corpus = [
            StreakDetailCopy.screenTitleDiscreet,
            StreakDetailCopy.milestonesTitle,
            StreakDetailCopy.milestoneLockedPrefix,
            StreakDetailCopy.momentumLabel,
            StreakDetailCopy.momentumExplainer,
            StreakDetailCopy.notesHeader,
            StreakDetailCopy.logSlipLabel,
            StreakDetailCopy.logSlipLabelDiscreet,
            StreakDetailCopy.avertedLine(count: 1),
            StreakDetailCopy.avertedLine(count: 12),
        ]
        #expect(corpus.count >= 10, "the scanned corpus collapsed — the scan would be vacuous")
        for string in corpus {
            let lowered = string.lowercased()
            for banned in shameSubstrings {
                #expect(
                    !lowered.contains(banned),
                    "forbidden lexicon '\(banned)' must never appear on Streak Detail: \(string)"
                )
            }
        }
    }

    /// The DISCREET-rendered strings carry zero habit context (the standard
    /// habit-leak list) — a family member may read this screen over a shoulder.
    @Test func test_discreetRenderedStrings_carryNoHabitLeak() {
        let leak = [
            "vape", "vaping", "porn", "alcohol", "weed", "doomscroll",
            "smoke", "drink", "sober", "quit", "addiction", "relapse", "habit",
        ]
        var corpus = [
            StreakDetailCopy.screenTitleDiscreet,
            StreakDetailCopy.logSlipLabelDiscreet,
            StreakDetailCopy.momentumLabel,
            StreakDetailCopy.momentumExplainer,
            StreakDetailCopy.milestoneLockedPrefix,
        ]
        // Discreet rows render time-only text — scan a representative spread.
        for hours in [12, 24, 168, 720, 8_760] {
            corpus.append(StreakDetailComposer.durationText(afterHours: hours))
        }
        for string in corpus {
            let lowered = string.lowercased()
            for banned in leak {
                #expect(
                    !lowered.contains(banned),
                    "the discreet Streak Detail must not leak '\(banned)': \(string)"
                )
            }
        }
    }
}
