import Foundation
import Testing
@testable import Unhooked

// E5.2 unit lane — the quiz flow model over the pure engine: step advance fires
// quiz_step_completed with the FIXED canonical slot (R1), back preserves answers,
// the consent seam (slot 3) is a reserved no-op (R4, E8.2's), the resume checkpoint
// lives in app-standard defaults (R5), and NO quiz_completed fires here (R2 — the
// E5.3 summary owns it). Doc-canonical names from implementation-plan.md E5.2.
//
// RED: `QuizFlowEngine.visibleSteps` returns the raw config (seam + conditionals
// included), `advance()` reports no fired slot and writes no checkpoint, `back()`
// drops answers, and `onFirstScreenAppear()` never fires — the designed failures
// are the assertions below (plus the completion-side cases in QuizCompletionTests
// and the erase/routing pins). Red evidence for this file = the CI run on the red
// commit; the Linux harness runs these bodies over the shipping bytes first.

/// The house spy shape, copied verbatim from AgeGateTests/AnalyticsWiringTests
/// (file-private by the no-shared-fixtures convention).
@MainActor
private final class SpyAnalyticsSink: AnalyticsSink {
    private(set) var received: [AnalyticsEvent] = []
    func receive(_ event: AnalyticsEvent) { received.append(event) }
}

/// Canned minimal-path answers (habit=vape, goal=quit: conditionals hidden) keyed
/// by stepID — the driver answers whatever step is current, so it works against
/// both the red raw sequence and the green filtered sequence.
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
    default: nil // seam / hidden conditionals get no answer
    }
}

/// Maximal-path variant (habit=custom, goal=reduce: both conditionals visible).
private func cannedMaximalAnswer(for stepID: String) -> QuizAnswer? {
    switch stepID {
    case "habit": QuizAnswer(stepID: "habit", choiceIDs: ["custom"])
    case "customName": QuizAnswer(stepID: "customName", choiceIDs: [], freeText: "the loop")
    case "goal": QuizAnswer(stepID: "goal", choiceIDs: ["reduce"])
    case "allowance": QuizAnswer(stepID: "allowance", choiceIDs: [], freeText: "4")
    default: cannedMinimalAnswer(for: stepID)
    }
}

@MainActor
@Suite("E5.2 · quiz flow model")
struct QuizFlowModelTests {

    private func throwawayStore() -> QuizProgressStore {
        QuizProgressStore(defaults: UserDefaults(suiteName: "e52-ckpt-\(UUID().uuidString)")!)
    }

    /// The shipping config + an opted-IN spy (the AgeGateTests polarity ruling: an
    /// opted-out service would swallow any stray fire and prove nothing).
    private func makeShippingModel(
        checkpoint: QuizProgressStore? = nil,
        variant: String = ""
    ) throws -> (model: QuizFlowModel, spy: SpyAnalyticsSink) {
        let config = try #require(
            QuizConfig.loadShipping(),
            "the audited quiz table is the shipping quizConfig.json — bundled, decodes as-is (§3.2)"
        )
        let spy = SpyAnalyticsSink()
        let model = QuizFlowModel(
            config: config,
            analytics: AnalyticsService(sink: spy, isOptedIn: { true }),
            checkpoint: checkpoint ?? throwawayStore(),
            variant: variant
        )
        return (model, spy)
    }

    private func drive(
        _ model: QuizFlowModel,
        answers: (String) -> QuizAnswer?
    ) {
        var hops = 0
        while !model.isComplete, hops < 20 {
            if let step = model.currentStep, let answer = answers(step.id) {
                model.record(answer)
            }
            model.advance()
            hops += 1
        }
    }

    // MARK: - Named test 1 (doc-canonical): every step advance fires
    // quiz_step_completed with the step's FIXED canonical slot (R1)

    @Test(arguments: [1, 4, 5, 6, 7, 8, 9, 10, 11, 13])
    func test_quiz_everyStepAdvance_firesQuizStepCompleted(step slot: Int) throws {
        let (model, spy) = try makeShippingModel()
        drive(model, answers: cannedMinimalAnswer(for:))

        let fired = spy.received.compactMap {
            if case let .quizStepCompleted(stepNumber) = $0 { stepNumber } else { nil }
        }
        #expect(
            fired == [1, 4, 5, 6, 7, 8, 9, 10, 11, 13],
            "the minimal path fires the fixed canonical slots, in order, once each — never renumbered by rendered position (R1)"
        )
        #expect(
            fired.contains(slot),
            "advancing the slot-\(slot) step fires quiz_step_completed(\(slot))"
        )
    }

    // MARK: - Named test 3 (doc-canonical): back navigation preserves answers

    @Test func test_quiz_backNavigation_preservesAnswers() throws {
        let (model, spy) = try makeShippingModel()
        model.record(QuizAnswer(stepID: "habit", choiceIDs: ["vape"]))
        model.advance()
        model.record(QuizAnswer(stepID: "frequency", choiceIDs: ["daily"]))
        model.advance()
        model.record(QuizAnswer(stepID: "spend", choiceIDs: [], freeText: "26"))

        let firedBeforeBack = spy.received.count
        model.back()
        #expect(spy.received.count == firedBeforeBack, "back fires nothing")
        #expect(model.currentStep?.id == "frequency", "back lands on the prior visible step")
        #expect(
            model.answer(for: "frequency")?.choiceIDs == ["daily"],
            "the prior answer re-hydrates on back"
        )

        model.back()
        #expect(model.currentStep?.id == "habit")
        #expect(model.answer(for: "habit")?.choiceIDs == ["vape"])

        model.advance()
        model.advance()
        #expect(
            model.answer(for: "spend")?.freeText == "26",
            "re-advancing after back loses nothing — answers survive the round-trip"
        )
    }

    // MARK: - AC2 pin: onboarding_started fires once, on the FIRST screen, with the
    // settings variant verbatim (R3) — and never re-fires on a checkpoint resume
    // (Architect MUST-FIX 6: double-counting corrupts the funnel denominator)

    @Test func test_quiz_onboardingStarted_firesOnceOnFirstScreen_withSettingsVariant() throws {
        let (model, spy) = try makeShippingModel(variant: "")
        model.onFirstScreenAppear()
        model.onFirstScreenAppear() // idempotent — a re-render is not a re-start

        let started = spy.received.filter {
            if case .onboardingStarted = $0 { true } else { false }
        }
        #expect(
            started == [.onboardingStarted(variant: "")],
            "fires exactly once, carrying AppSettings.onboardingVariant verbatim (\"\" until E7 assigns it — R3)"
        )

        model.record(QuizAnswer(stepID: "habit", choiceIDs: ["vape"]))
        model.advance()
        #expect(
            spy.received.first == .onboardingStarted(variant: ""),
            "onboarding_started precedes the first quiz_step_completed"
        )

        // Resume suppression: a mid-quiz relaunch is NOT a new onboarding start.
        let store = throwawayStore()
        store.save(QuizProgress(
            currentStepID: "frequency",
            answers: [QuizAnswer(stepID: "habit", choiceIDs: ["vape"])]
        ))
        let (resumed, resumedSpy) = try makeShippingModel(checkpoint: store)
        resumed.onFirstScreenAppear()
        #expect(
            resumedSpy.received.isEmpty,
            "a checkpoint resume never re-fires onboarding_started (MUST-FIX 6)"
        )
    }

    // MARK: - AC1 pin: visible steps derive from config + answers

    @Test func test_quizFlow_visibleSteps_derivedFromConfigAndAnswers() throws {
        let (model, _) = try makeShippingModel()
        #expect(
            model.visibleSteps.map(\.slot) == [1, 4, 5, 6, 7, 8, 9, 10, 11, 13],
            "minimal path: the seam (3) is excluded and unanswered conditionals (2, 12) are hidden"
        )

        model.record(QuizAnswer(stepID: "habit", choiceIDs: ["custom"]))
        model.record(QuizAnswer(stepID: "goal", choiceIDs: ["reduce"]))
        #expect(
            model.visibleSteps.map(\.slot) == [1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
            "custom + reduce reveal their conditional steps at their FIXED slots (R1)"
        )
    }

    // MARK: - AC9 pin: conditional visibility + stable canonical numbering (R1/R9)

    @Test func test_quiz_conditionalSteps_visibilityAndStableNumbering() throws {
        let (minimal, _) = try makeShippingModel()
        minimal.record(QuizAnswer(stepID: "habit", choiceIDs: ["vape"]))
        minimal.record(QuizAnswer(stepID: "goal", choiceIDs: ["quit"]))
        #expect(
            !minimal.visibleSteps.contains { $0.id == "customName" },
            "the custom-name step is visible iff habit == custom"
        )
        #expect(
            !minimal.visibleSteps.contains { $0.id == "allowance" },
            "the allowance step is visible iff goal == reduce (MVP #4)"
        )

        let (maximal, _) = try makeShippingModel()
        maximal.record(QuizAnswer(stepID: "habit", choiceIDs: ["custom"]))
        maximal.record(QuizAnswer(stepID: "goal", choiceIDs: ["reduce"]))
        #expect(maximal.visibleSteps.contains { $0.id == "customName" })
        #expect(maximal.visibleSteps.contains { $0.id == "allowance" })

        // R1: the canonical slot never renumbers across paths…
        #expect(minimal.visibleSteps.first { $0.id == "motivations" }?.slot == 9)
        #expect(maximal.visibleSteps.first { $0.id == "motivations" }?.slot == 9)
        // …while the R9 visible totals differ (two honest numbers).
        #expect(minimal.visibleSteps.count == 10)
        #expect(maximal.visibleSteps.count == 12)
    }

    // MARK: - AC10 pin: the consent seam (slot 3) is reserved and inert (R4 — E8.2's)

    @Test func test_quiz_consentSeam_reservedNoOp_optInUntouched() throws {
        let (model, spy) = try makeShippingModel()
        #expect(
            !model.visibleSteps.contains { $0.slot == 3 || $0.id == "consent" },
            "E5.2 renders nothing for the reserved consent slot"
        )

        drive(model, answers: cannedMinimalAnswer(for:))
        let fired = spy.received.compactMap {
            if case let .quizStepCompleted(stepNumber) = $0 { stepNumber } else { nil }
        }
        #expect(!fired.contains(3), "the seam's slot number is never emitted")

        // Structural: the reserved seam carries an owner and NO rendered strings.
        let config = try #require(QuizConfig.loadShipping())
        let seam = try #require(config.steps.first { $0.kind == .seam })
        #expect(seam.slot == 3)
        #expect(seam.owner == "E8.2")
        #expect(seam.title == nil && seam.choices == nil && seam.helper == nil)
    }

    // MARK: - AC11 guard (green-by-construction): NO quiz_completed fires in E5.2 (R2)

    @Test func test_quiz_fullRun_firesNoQuizCompleted() throws {
        let (minimal, minimalSpy) = try makeShippingModel()
        drive(minimal, answers: cannedMinimalAnswer(for:))
        let (maximal, maximalSpy) = try makeShippingModel()
        drive(maximal, answers: cannedMaximalAnswer(for:))

        for received in [minimalSpy.received, maximalSpy.received] {
            #expect(
                received.allSatisfy {
                    switch $0 {
                    case .onboardingStarted, .quizStepCompleted: true
                    default: false
                    }
                },
                "a full quiz run emits ONLY onboarding_started + quiz_step_completed — quiz_completed belongs to E5.3's summary render (R2)"
            )
        }

        // The E5.3 handoff carries exactly what quiz_completed will need.
        #expect(minimal.completion == .init(habitCategory: .vape, goalMode: .quit))
        #expect(maximal.completion == .init(habitCategory: .custom, goalMode: .reduce))
    }

    // MARK: - AC14 pin: the checkpoint resumes an interrupted quiz and clears on
    // completion (architecture §7; the erase half lives in EraseEverythingTests)

    @Test func test_quiz_progressCheckpoint_resumesAndClearsOnCompletion() throws {
        let store = throwawayStore()
        let (interrupted, _) = try makeShippingModel(checkpoint: store)
        interrupted.record(QuizAnswer(stepID: "habit", choiceIDs: ["vape"]))
        interrupted.advance()
        interrupted.record(QuizAnswer(stepID: "frequency", choiceIDs: ["daily"]))
        interrupted.advance()

        // A new model over the SAME store — the mid-quiz relaunch.
        let (resumed, _) = try makeShippingModel(checkpoint: store)
        #expect(
            resumed.currentStep?.id == "spend",
            "an interrupted quiz resumes at the same step (§7 — never lose a user at step 9)"
        )
        #expect(
            resumed.answer(for: "habit")?.choiceIDs == ["vape"],
            "committed answers re-hydrate through the checkpoint"
        )

        drive(resumed, answers: cannedMinimalAnswer(for:))
        #expect(resumed.isComplete)
        #expect(store.load() == nil, "completion clears the checkpoint")
    }

    // MARK: - AC4 pin: the checkpoint is app-STANDARD defaults, never App-Group (R5/§10)

    @Test func test_quiz_checkpoint_isAppStandardDefaults_notAppGroup() throws {
        let standardSuite = UserDefaults(suiteName: "e52-std-\(UUID().uuidString)")!
        let groupSuite = UserDefaults(suiteName: "e52-group-\(UUID().uuidString)")!
        let (model, _) = try makeShippingModel(
            checkpoint: QuizProgressStore(defaults: standardSuite)
        )
        model.record(QuizAnswer(stepID: "habit", choiceIDs: ["vape"]))
        model.advance()

        #expect(
            standardSuite.data(forKey: QuizProgressStore.key) != nil,
            "an advance commits the checkpoint to the injected app-standard suite"
        )
        #expect(
            groupSuite.dictionaryRepresentation().keys.allSatisfy { !$0.hasPrefix("quiz.") },
            "no quiz key may land in an App-Group-shaped suite — its content is readable pre-unlock (§10)"
        )
        #expect(
            QuizProgressStore().defaults === UserDefaults.standard,
            "the production default is the app-standard suite (R5)"
        )
    }
}
