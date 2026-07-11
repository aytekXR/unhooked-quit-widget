import Foundation
import StreakEngine
import SwiftData
import Testing
@testable import Unhooked

// E5.3 unit lane — the summary fields at the repository seam: `createQuit(from:)`
// fills the two EXISTING QuizProfile fields (`projectedAnnualSavings` = spend × 52
// Decimal-exact; `predictedRiskWindow` = the highest-precedence trigger TOKEN,
// never a phrase) BEFORE the ONE save — no new field (the CloudKit exact-set is
// pinned here), no second save, and the window derives ONLY from the trigger
// answers (identical triggers ⇒ identical token, whatever else differs). A
// degraded-config completion (no triggers step exists there) stores NO window —
// insufficient data shows nothing, not guesses.
//
// RED: the shipped E5.2 `createQuit(from:)` simply does not fill the two fields
// yet — every fill assertion below fails against unchanged green code (no stub
// needed in this lane); the exact-set and nil-window pins pass at red BY DESIGN
// (guards against a drive-by field or an invented window). Red evidence for this
// file = the CI run on the red commit (SwiftData is CI-only; the pure derivation
// is Linux-harnessed in SummaryDerivationTests).
//
// Harness/ManualClock/SpyWidgetRefresher/StubCloudSync are the E2.2 conventions,
// copied verbatim from QuizCompletionTests (the proven in-memory-container +
// real-createQuit shape). Fixture epoch is the test-suite §3.2 constant.

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

/// The typed-event spy (test-suite §3.1) — file-local copy, the house
/// no-shared-fixtures convention.
@MainActor
private final class SpyAnalyticsSink: AnalyticsSink {
    private(set) var received: [AnalyticsEvent] = []
    func receive(_ event: AnalyticsEvent) { received.append(event) }
}

/// One in-memory store + repository per test, with the pre-cache at a temp
/// directory and an EXPLICIT throwaway App-Group suite (the QuizCompletionTests
/// shape, verbatim).
@MainActor
private struct Harness {
    let container: ModelContainer
    let clock: ManualClock
    let analyticsSpy: SpyAnalyticsSink
    let appGroupDefaults: UserDefaults
    let panicSnapshotStore: PanicSnapshotStore
    let repository: QuitRepository

    init(optedIn: Bool = true) throws {
        let cacheDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("e53-summary-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        container = try ModelContainer(
            for: PersistentStore.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        clock = ManualClock()
        analyticsSpy = SpyAnalyticsSink()
        appGroupDefaults = UserDefaults(suiteName: "e53-summary-group-\(UUID().uuidString)")!
        panicSnapshotStore = PanicSnapshotStore(directoryURL: cacheDirectory)
        repository = QuitRepository(
            container: container,
            clock: clock,
            widgetRefresher: SpyWidgetRefresher(),
            lastKnownGoodStore: LastKnownGoodStore(
                defaults: UserDefaults(suiteName: "e53-summary-lkg-\(UUID().uuidString)")!
            ),
            cloud: StubCloudSync(),
            appGroupDefaults: appGroupDefaults,
            panicSnapshotStore: panicSnapshotStore,
            debounceSleep: { _ in },
            analytics: AnalyticsService(sink: analyticsSpy, isOptedIn: { optedIn })
        )
    }
}

/// A QuizProfile carrying the given answers — built in test code (Tests/ may touch
/// SwiftData types; production assembly stays in `QuitRepository.completeQuiz`).
@MainActor
private func fixtureProfile(_ answers: [QuizAnswer]) -> QuizProfile {
    let profile = QuizProfile()
    profile.answers = answers
    return profile
}

@MainActor
@Suite("E5.3 · summary fields at the repository seam")
struct QuizSummaryPersistenceTests {

    /// The fill pin + the CloudKit exact-set guard: both fields land under the
    /// ONE save, and the field set gains NOTHING (schema drive-by unrepresentable).
    @Test func test_summary_profileFieldsFilledAtCompletion_noNewField() throws {
        let harness = try Harness()
        _ = try harness.repository.createQuit(from: fixtureProfile([
            QuizAnswer(stepID: "habit", choiceIDs: ["vape"]),
            QuizAnswer(stepID: "frequency", choiceIDs: ["daily"]),
            QuizAnswer(stepID: "spend", choiceIDs: [], freeText: "26"),
            QuizAnswer(stepID: "triggers", choiceIDs: ["stress", "evenings"]),
            QuizAnswer(stepID: "motivations", choiceIDs: ["Energy"]),
            QuizAnswer(stepID: "goal", choiceIDs: ["quit"]),
        ]))

        let fresh = ModelContext(harness.container)
        let saved = try #require(
            try fresh.fetch(FetchDescriptor<QuizProfile>()).first,
            "completion persists exactly one QuizProfile"
        )
        #expect(
            saved.projectedAnnualSavings == Decimal(1352),
            "projectedAnnualSavings is filled at completion: 26 × 52, Decimal-exact, under the ONE save"
        )
        #expect(
            saved.predictedRiskWindow == "evenings",
            "predictedRiskWindow stores the winning trigger TOKEN (evenings > stress), never a phrase"
        )

        // Guard (passes at red AND green): the CloudKit exact-set — E5.3 fills, it
        // never adds. A drive-by field flips this before any mirror exists.
        let entity = try #require(
            PersistentStore.schema.entities.first { $0.name == "QuizProfile" },
            "the store schema carries the QuizProfile entity"
        )
        #expect(
            Set(entity.attributes.map(\.name))
                == ["id", "completedAt", "answers", "projectedAnnualSavings", "predictedRiskWindow"],
            "QuizProfile's attribute set is EXACTLY the architecture §3 five — no new field (CloudKit checklist)"
        )
    }

    /// The isolation pin: identical triggers ⇒ identical token, however much the
    /// other answers differ — the window can only see frequency + triggers.
    @Test func test_summary_riskWindow_isolatedFromNonTriggerAnswers() throws {
        let harness = try Harness()
        _ = try harness.repository.createQuit(from: fixtureProfile([
            QuizAnswer(stepID: "habit", choiceIDs: ["vape"]),
            QuizAnswer(stepID: "spend", choiceIDs: [], freeText: "26"),
            QuizAnswer(stepID: "triggers", choiceIDs: ["evenings"]),
            QuizAnswer(stepID: "motivations", choiceIDs: ["Energy"]),
            QuizAnswer(stepID: "goal", choiceIDs: ["quit"]),
        ]))
        _ = try harness.repository.createQuit(from: fixtureProfile([
            QuizAnswer(stepID: "habit", choiceIDs: ["custom"]),
            QuizAnswer(stepID: "customName", choiceIDs: [], freeText: "the loop"),
            QuizAnswer(stepID: "spend", choiceIDs: [], freeText: "99.50"),
            QuizAnswer(stepID: "triggers", choiceIDs: ["evenings"]),
            QuizAnswer(stepID: "motivations", choiceIDs: ["Faith", "Focus"]),
            QuizAnswer(stepID: "goal", choiceIDs: ["reduce"]),
            QuizAnswer(stepID: "allowance", choiceIDs: [], freeText: "4"),
        ]))

        let fresh = ModelContext(harness.container)
        let profiles = try fresh.fetch(FetchDescriptor<QuizProfile>())
        let profileA = try #require(
            profiles.first { $0.answers.contains { $0.stepID == "spend" && $0.freeText == "26" } }
        )
        let profileB = try #require(
            profiles.first { $0.answers.contains { $0.stepID == "spend" && $0.freeText == "99.50" } }
        )
        #expect(
            profileA.predictedRiskWindow == "evenings",
            "profile A's window comes from its trigger answer"
        )
        #expect(
            profileB.predictedRiskWindow == "evenings",
            "profile B's window ignores spend/motivations/name/goal — triggers only"
        )
        // Guard (passes at red AND green): the isolation claim itself.
        #expect(
            profileA.predictedRiskWindow == profileB.predictedRiskWindow,
            "identical triggers ⇒ identical token, whatever else differs"
        )
    }

    /// Decimal exactness survives persistence: a cents-bearing spend stores the
    /// exact product (a Double path drifts and fails this equality).
    @Test func test_summary_decimalSafeSavings_persistsExact() throws {
        let harness = try Harness()
        _ = try harness.repository.createQuit(from: fixtureProfile([
            QuizAnswer(stepID: "habit", choiceIDs: ["alcohol"]),
            QuizAnswer(stepID: "spend", choiceIDs: [], freeText: "9.99"),
            QuizAnswer(stepID: "motivations", choiceIDs: ["Money"]),
            QuizAnswer(stepID: "goal", choiceIDs: ["quit"]),
        ]))

        let fresh = ModelContext(harness.container)
        let saved = try #require(try fresh.fetch(FetchDescriptor<QuizProfile>()).first)
        #expect(
            saved.projectedAnnualSavings == Decimal(string: "519.48")!,
            "9.99 × 52 persists Decimal-exact (519.48) — no floating point in the money path"
        )
    }

    /// The degraded arm: a degraded-config completion (its flow has NO triggers or
    /// frequency step) still fills savings — and stores NO window.
    @Test func test_summary_degradedConfigCompletion_isSummarySafe() throws {
        let harness = try Harness()
        // Exactly the answers a QuizConfig.degraded run produces (habit → spend →
        // motivations → goal; slots 1/5/9/11 — no triggers, no frequency).
        try harness.repository.completeQuiz([
            QuizAnswer(stepID: "habit", choiceIDs: ["alcohol"]),
            QuizAnswer(stepID: "spend", choiceIDs: [], freeText: "12"),
            QuizAnswer(stepID: "motivations", choiceIDs: ["Focus"]),
            QuizAnswer(stepID: "goal", choiceIDs: ["quit"]),
        ])

        let fresh = ModelContext(harness.container)
        let saved = try #require(try fresh.fetch(FetchDescriptor<QuizProfile>()).first)
        #expect(
            saved.projectedAnnualSavings == Decimal(624),
            "the degraded flow still powers the money math: 12 × 52"
        )
        // Guard (passes at red AND green): no trigger data → NO invented window.
        #expect(
            saved.predictedRiskWindow == nil,
            "degraded has no triggers → nil window — insufficient data shows nothing, not guesses"
        )
    }
}
