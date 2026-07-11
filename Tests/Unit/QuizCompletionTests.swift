import Foundation
import StreakEngine
import SwiftData
import Testing
@testable import Unhooked

// E5.2 unit lane — quiz completion at the repository seam: `createQuit(from:)`
// maps the profile's answers onto the quit (motivations VERBATIM in user order,
// spend, triggers, goal, custom-only label, reduce-only allowance), inserts and
// links the QuizProfile in ONE save, and rides the existing post-save
// `rebuildPanicSnapshot()` hook so the panic pre-cache carries the user's own
// words (named tests 2/4/5 from implementation-plan.md E5.2). Answers persist
// LOCALLY ONLY: the QuizProfile row + the app-standard checkpoint — never the App
// Group suite, never an analytics payload, never new pre-cache fields.
//
// RED: `createQuit(from:)` deliberately ignores the profile (no mapping, no max-3
// guard, no profile insert/link) — the designed failures are the assertions below.
// Red evidence for this file = the CI run on the red commit (SwiftData is CI-only;
// the pure mapping is Linux-harnessed separately).
//
// Harness/ManualClock/SpyWidgetRefresher/StubCloudSync are the E2.2 conventions,
// copied verbatim from AnalyticsWiringTests (the proven in-memory-container +
// real-PanicSnapshotStore + real-createQuit shape). Fixture epoch is the
// test-suite §3.2 constant.

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
/// directory and an EXPLICIT throwaway App-Group suite so test 2 can assert no
/// quiz content ever lands there.
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
            .appendingPathComponent("e52-completion-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        container = try ModelContainer(
            for: PersistentStore.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        clock = ManualClock()
        analyticsSpy = SpyAnalyticsSink()
        appGroupDefaults = UserDefaults(suiteName: "e52-completion-group-\(UUID().uuidString)")!
        panicSnapshotStore = PanicSnapshotStore(directoryURL: cacheDirectory)
        repository = QuitRepository(
            container: container,
            clock: clock,
            widgetRefresher: SpyWidgetRefresher(),
            lastKnownGoodStore: LastKnownGoodStore(
                defaults: UserDefaults(suiteName: "e52-completion-lkg-\(UUID().uuidString)")!
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

/// Minimal-path canned answers for flow-model-driven completion runs.
private func cannedMinimalAnswer(for stepID: String) -> QuizAnswer? {
    switch stepID {
    case "habit": QuizAnswer(stepID: "habit", choiceIDs: ["vape"])
    case "frequency": QuizAnswer(stepID: "frequency", choiceIDs: ["daily"])
    case "spend": QuizAnswer(stepID: "spend", choiceIDs: [], freeText: "26")
    case "duration": QuizAnswer(stepID: "duration", choiceIDs: ["y1to3"])
    case "triggers": QuizAnswer(stepID: "triggers", choiceIDs: ["stress", "evenings"])
    case "priorAttempts": QuizAnswer(stepID: "priorAttempts", choiceIDs: ["few"])
    case "motivations": QuizAnswer(stepID: "motivations", choiceIDs: ["Energy", "Money"])
    case "effects": QuizAnswer(stepID: "effects", choiceIDs: ["tired"])
    case "goal": QuizAnswer(stepID: "goal", choiceIDs: ["quit"])
    case "commitment": QuizAnswer(stepID: "commitment", choiceIDs: [], freeText: "0.75")
    default: nil
    }
}

@MainActor
@Suite("E5.2 · quiz completion — createQuit(from:) + pre-cache + local-only answers")
struct QuizCompletionTests {

    private func throwawayCheckpoint() -> QuizProgressStore {
        QuizProgressStore(defaults: UserDefaults(suiteName: "e52-cq-ckpt-\(UUID().uuidString)")!)
    }

    private func drive(_ model: QuizFlowModel, answers: (String) -> QuizAnswer?) {
        var hops = 0
        while !model.isComplete, hops < 20 {
            if let step = model.currentStep, let answer = answers(step.id) {
                model.record(answer)
            }
            model.advance()
            hops += 1
        }
    }

    // MARK: - Named test 2 (doc-canonical): answers persist LOCALLY ONLY

    @Test func test_quiz_answersPersistLocallyOnly() throws {
        let harness = try Harness()
        let config = try #require(QuizConfig.loadShipping())
        let model = QuizFlowModel(
            config: config,
            analytics: AnalyticsService(sink: harness.analyticsSpy, isOptedIn: { true }),
            checkpoint: throwawayCheckpoint(),
            variant: "",
            onComplete: { try harness.repository.completeQuiz($0) }
        )
        model.onFirstScreenAppear()
        drive(model, answers: cannedMinimalAnswer(for:))
        #expect(model.isComplete, "the driven quiz must reach completion")

        // (1) The persisted QuizProfile carries the answers, verbatim.
        let fresh = ModelContext(harness.container)
        let profile = try #require(
            try fresh.fetch(FetchDescriptor<QuizProfile>()).first,
            "completion persists exactly one QuizProfile (completion-only insert — an abandoned quiz leaves no synced residue)"
        )
        #expect(profile.answers.contains { $0.stepID == "motivations" && $0.choiceIDs == ["Energy", "Money"] })
        #expect(profile.answers.contains { $0.stepID == "spend" && $0.freeText == "26" })
        #expect(profile.answers.contains { $0.stepID == "triggers" && $0.choiceIDs == ["stress", "evenings"] })

        // (2) Nothing quiz-shaped lands in the App Group suite (§10: readable
        // pre-unlock — the checkpoint is app-standard by design, R5).
        #expect(
            harness.appGroupDefaults.dictionaryRepresentation().keys
                .allSatisfy { !$0.hasPrefix("quiz.") },
            "no quiz key may ever land in the App Group defaults"
        )

        // (3) The pre-cache gains NO answer surface: the card's field set is the
        // sanctioned E3.1/E4.1 shape — no spend, no triggers, no free text, no
        // answers (structural, so a future field can't sneak an answer in).
        let snapshot = try #require(harness.panicSnapshotStore.read())
        let card = try #require(snapshot.quits.first)
        let fieldNames = Mirror(reflecting: card).children.compactMap(\.label)
        for forbidden in ["spend", "trigger", "answer", "freetext", "note"] {
            #expect(
                fieldNames.allSatisfy { !$0.lowercased().contains(forbidden) },
                "the pre-cache card grew a '\(forbidden)'-shaped field — quiz answers must never reach App Group files (§10)"
            )
        }

        // (4) Analytics carried NO answer content — only the two E5.2 events.
        #expect(
            harness.analyticsSpy.received.allSatisfy {
                switch $0 {
                case .onboardingStarted, .quizStepCompleted: true
                default: false
                }
            },
            "the quiz emits only onboarding_started + quiz_step_completed — answer values are unrepresentable (guard b)"
        )
    }

    // MARK: - Named test 4 (doc-canonical): completion creates the quit with
    // motivations + spend (and the whole approved field mapping)

    @Test func test_quizCompletion_createsQuitWithMotivationsAndSpend() throws {
        let harness = try Harness()
        let profile = fixtureProfile([
            QuizAnswer(stepID: "habit", choiceIDs: ["vape"]),
            QuizAnswer(stepID: "motivations", choiceIDs: ["Energy", "Money"]),
            QuizAnswer(stepID: "triggers", choiceIDs: ["stress", "evenings"]),
            QuizAnswer(stepID: "spend", choiceIDs: [], freeText: "26"),
            QuizAnswer(stepID: "goal", choiceIDs: ["reduce"]),
            QuizAnswer(stepID: "allowance", choiceIDs: [], freeText: "4"),
            QuizAnswer(stepID: "customName", choiceIDs: [], freeText: "stray"),
        ])

        let quit = try harness.repository.createQuit(from: profile)

        #expect(quit.habitCategory == .vape)
        #expect(quit.motivations == ["Energy", "Money"], "verbatim, user order — the panic ReasonsView renders these")
        #expect(quit.triggers == ["stress", "evenings"], "stable trigger IDs, local only (E5.3 risk-window input)")
        #expect(quit.weeklySpend == Decimal(26))
        #expect(quit.goalMode == .reduce)
        #expect(quit.weeklyAllowance == 4, "the reduce path captures the weekly allowance (MVP #4, ADR-10)")
        #expect(quit.customLabel == nil, "a stray custom-name answer never lands on a non-custom quit (AC8)")
        #expect(quit.startAt == epoch, "startAt == clock.now — the repository's clock, never Date()")
        #expect(quit.createdAt == epoch)

        // The profile is inserted, linked, and stamped in the SAME save.
        let fresh = ModelContext(harness.container)
        let saved = try #require(
            try fresh.fetch(FetchDescriptor<QuizProfile>()).first,
            "createQuit(from:) inserts the profile alongside the quit"
        )
        #expect(saved.quit?.id == quit.id, "profile.quit links the created quit")
    }

    // MARK: - Named test 5 (doc-canonical): completion writes the motivations
    // pre-cache (the existing post-save rebuild hook carries the user's words)

    @Test func test_quizCompletion_writesMotivationsPreCache() throws {
        let harness = try Harness()
        let profile = fixtureProfile([
            QuizAnswer(stepID: "habit", choiceIDs: ["vape"]),
            QuizAnswer(stepID: "motivations", choiceIDs: ["Energy", "Faith", "Focus"]),
            QuizAnswer(stepID: "spend", choiceIDs: [], freeText: "0"),
            QuizAnswer(stepID: "goal", choiceIDs: ["quit"]),
        ])

        let quit = try harness.repository.createQuit(from: profile)

        let snapshot = try #require(
            harness.panicSnapshotStore.read(),
            "createQuit(from:) must rebuild the pre-cache post-save"
        )
        let card = try #require(snapshot.quits.first { $0.id == quit.id })
        #expect(
            card.motivations == ["Energy", "Faith", "Focus"],
            "verbatim, user order — faith is echoed because the user picked it, never generated (brandkit §1.2)"
        )
    }

    // MARK: - AC12 pin: the degraded config still completes and creates a valid quit

    @Test func test_quizConfig_degradedFallback_stillCompletesAndCreatesQuit() throws {
        let harness = try Harness()
        let model = QuizFlowModel(
            config: .degraded,
            analytics: AnalyticsService(sink: harness.analyticsSpy, isOptedIn: { true }),
            checkpoint: throwawayCheckpoint(),
            variant: "",
            onComplete: { try harness.repository.completeQuiz($0) }
        )
        drive(model) { stepID in
            switch stepID {
            case "habit": QuizAnswer(stepID: "habit", choiceIDs: ["alcohol"])
            case "spend": QuizAnswer(stepID: "spend", choiceIDs: [], freeText: "12")
            case "motivations": QuizAnswer(stepID: "motivations", choiceIDs: ["Focus"])
            case "goal": QuizAnswer(stepID: "goal", choiceIDs: ["quit"])
            default: nil
            }
        }
        #expect(model.isComplete, "a decode failure degrades — it never dead-ends onboarding (§9)")

        let quit = try #require(try harness.repository.activeQuits().first)
        #expect(quit.habitCategory == .alcohol)
        #expect(quit.weeklySpend == Decimal(12))
        #expect(quit.motivations == ["Focus"])
    }

    // MARK: - AC8 pin: the custom habit name never leaves the device (the honest
    // claim — QA F22: stored locally, unrepresentable in analytics, discreet-stripped)

    @Test func test_quiz_customName_neverLeavesDevice() throws {
        let harness = try Harness()
        let profile = fixtureProfile([
            QuizAnswer(stepID: "habit", choiceIDs: ["custom"]),
            QuizAnswer(stepID: "customName", choiceIDs: [], freeText: "my private word"),
            QuizAnswer(stepID: "motivations", choiceIDs: ["Focus"]),
            QuizAnswer(stepID: "spend", choiceIDs: [], freeText: "0"),
            QuizAnswer(stepID: "goal", choiceIDs: ["quit"]),
        ])

        let quit = try harness.repository.createQuit(from: profile)
        #expect(quit.habitCategory == .custom)
        #expect(
            quit.customLabel == "my private word",
            "the user's own name lives on the quit (local + their own iCloud) and nowhere else"
        )

        // Unrepresentable in any analytics payload (custom is the wire ceiling).
        #expect(
            harness.analyticsSpy.received.allSatisfy { event in
                !event.parameters.values.contains { $0.contains("my private word") }
            }
        )

        // Discreet mode strips it from the pre-cache label (§10 — App Group files
        // are readable pre-unlock; discretion is the user's control).
        quit.discreetMode = true
        try harness.container.mainContext.save()
        harness.repository.refreshPanicSnapshot()
        let card = try #require(harness.panicSnapshotStore.read()?.quits.first { $0.id == quit.id })
        #expect(card.label == nil, "discreet strips the label from the snapshot")
    }

    // MARK: - AC6 pin: the max-3 guard is reused and surfaces calmly

    @Test func test_quiz_maxThreeQuits_surfacedCalmly() throws {
        let harness = try Harness()
        for habit in ["vape", "alcohol", "weed"] {
            _ = try harness.repository.createQuit(from: fixtureProfile([
                QuizAnswer(stepID: "habit", choiceIDs: [habit]),
                QuizAnswer(stepID: "goal", choiceIDs: ["quit"]),
            ]))
        }

        #expect(throws: QuitRepository.RepositoryError.activeQuitLimitReached) {
            try harness.repository.createQuit(from: fixtureProfile([
                QuizAnswer(stepID: "habit", choiceIDs: ["doomscroll"]),
                QuizAnswer(stepID: "goal", choiceIDs: ["quit"]),
            ]))
        }
        #expect(
            try harness.repository.activeQuits().count == 3,
            "the fourth create persists NOTHING — the same typed error the UI surfaces calmly (never red, never shame)"
        )
    }
}
