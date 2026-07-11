import Foundation
import Testing
@testable import Unhooked

// E8.2 unit lane — the consent step at the reserved slot-3 seam, PURE tier: the
// shipping quizConfig renders consent at its FIXED canonical slot (between 2 and
// 4, no renumbering — R1), the stored opt-in gates fire() LIVE (an opt-in made AT
// the consent step governs events fired LATER in the same quiz run, including the
// summary's quiz_completed), a decline transmits nothing ever, the consent choice
// is never a QuizAnswer and never enters the checkpoint (step-0 ruling c), the
// pre-consent surfaces fire nothing (MVP §5: "fire nothing before the analytics
// opt-in choice"), and checkpoint resume lands ON an unanswered consent step /
// PAST an answered one (step-0 ruling d). Step-0 ruling (a): the consent step
// EMITS quiz_step_completed(3) — post-choice, gate-dropped for decliners, zero
// special-casing (PM+Architect, Session 19; operator-vetoable).
//
// RED: `QuizFlowEngine.visibleSteps` still filters the slot-3 seam, so the
// designed failures are consent-absence assertion misses — no stub is needed in
// this file (existing APIs only). Red evidence for this file = the CI run on the
// red commit; the Linux harness runs these bodies over the exact shipping bytes
// first (QuizFlowModel + the real AnalyticsService compile on the Linux
// toolchain — the Session 18 lane).

/// The house spy shape, copied verbatim from QuizSummaryFireTests (file-private
/// by the no-shared-fixtures convention).
@MainActor
private final class SpyAnalyticsSink: AnalyticsSink {
    private(set) var received: [AnalyticsEvent] = []
    func receive(_ event: AnalyticsEvent) { received.append(event) }
}

/// A mutable opt-in backing the tests flip mid-drive — the pure-tier stand-in for
/// the stored `AppSettings.analyticsOptIn` the live closure will read (the same
/// late-bound reference shape the composition root uses).
private final class OptInFlag {
    var isOn = false
}

/// Canned minimal-path answers (habit=vape, goal=quit: conditionals hidden) keyed
/// by stepID — copied from QuizFlowModelTests; consent deliberately gets NO answer
/// (it is never a QuizAnswer — ruling c; at the model tier advance passes it).
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
    default: nil // consent / hidden conditionals get no answer
    }
}

@MainActor
@Suite("E8.2 · consent gate — slot-3 render + live opt-in gate")
struct ConsentGateTests {

    private func throwawayStore() -> QuizProgressStore {
        QuizProgressStore(defaults: UserDefaults(suiteName: "e82-gate-\(UUID().uuidString)")!)
    }

    /// The shipping config over a spy whose gate reads the mutable flag LIVE —
    /// each fire() re-reads it, exactly like the production closure over
    /// `AppSettings.analyticsOptIn`.
    private func makeShippingModel(
        flag: OptInFlag,
        checkpoint: QuizProgressStore? = nil
    ) throws -> (model: QuizFlowModel, spy: SpyAnalyticsSink) {
        let config = try #require(
            QuizConfig.loadShipping(),
            "the audited quiz table is the shipping quizConfig.json — bundled, decodes as-is (§3.2)"
        )
        let spy = SpyAnalyticsSink()
        let model = QuizFlowModel(
            config: config,
            analytics: AnalyticsService(sink: spy, isOptedIn: { flag.isOn }),
            checkpoint: checkpoint ?? throwawayStore()
        )
        return (model, spy)
    }

    /// Drives to completion; when the CONSENT step is current, sets the flag to
    /// `consentPick` before advancing — modelling tap-choice-then-Continue with
    /// the write-at-tap ordering (the value lands BEFORE the slot-3 fire).
    private func drive(
        _ model: QuizFlowModel,
        flag: OptInFlag,
        consentPick: Bool
    ) {
        var hops = 0
        while !model.isComplete, hops < 25 {
            if let step = model.currentStep {
                if step.id == "consent" {
                    flag.isOn = consentPick
                }
                if let answer = cannedMinimalAnswer(for: step.id) {
                    model.record(answer)
                }
            }
            model.advance()
            hops += 1
        }
    }

    /// Drives until the given step is current (or completion) without answering
    /// or advancing past it.
    private func drive(_ model: QuizFlowModel, until stepID: String) {
        var hops = 0
        while !model.isComplete, model.currentStep?.id != stepID, hops < 25 {
            if let step = model.currentStep, let answer = cannedMinimalAnswer(for: step.id) {
                model.record(answer)
            }
            model.advance()
            hops += 1
        }
    }

    // MARK: - Resume-prompt pin: slot 3 renders between slots 2 and 4 with NO
    // renumbering (fixed canonical ordinals, R1)

    @Test func test_consentStep_rendersAtSlot3_betweenSlots2and4_nonCustom() throws {
        let flag = OptInFlag()
        let (model, _) = try makeShippingModel(flag: flag)
        model.record(QuizAnswer(stepID: "habit", choiceIDs: ["vape"]))

        #expect(
            model.visibleSteps.map(\.id).prefix(3) == ["habit", "consent", "frequency"],
            "non-custom path: consent renders as the visible second step (slot 2's conditional stays hidden)"
        )
        #expect(
            model.visibleSteps.map(\.slot).prefix(3) == [1, 3, 4],
            "fixed canonical ordinals — rendering the reserved slot never renumbers its neighbors (R1)"
        )

        model.advance() // past habit — consent becomes current
        #expect(model.currentStep?.id == "consent")
        #expect(model.currentSlot == 3, "the analytics number is the FIXED slot")
        #expect(
            model.progressPosition == (2, 11),
            "the progress number is the VISIBLE position — two honest numbers (R9); the total grew by one, expected"
        )
    }

    @Test func test_consentStep_rendersAtSlot3_afterCustomName_customPath() throws {
        let flag = OptInFlag()
        let (model, _) = try makeShippingModel(flag: flag)
        model.record(QuizAnswer(stepID: "habit", choiceIDs: ["custom"]))

        #expect(
            model.visibleSteps.map(\.id).prefix(4) == ["habit", "customName", "consent", "frequency"],
            "custom path: consent renders after the revealed conditional slot 2"
        )
        #expect(
            model.visibleSteps.first { $0.id == "consent" }?.slot == 3,
            "consent keeps its fixed ordinal on every path (R1)"
        )
    }

    // MARK: - Step-0 (a) pin: advancing past consent EMITS quiz_step_completed(3)
    // — post-choice, through the generic gate, no special-casing

    @Test func test_advancingPastConsent_firesQuizStepCompleted3_optedIn() throws {
        let flag = OptInFlag()
        flag.isOn = true // opted in from the start — isolates the emission question
        let (model, spy) = try makeShippingModel(flag: flag)
        drive(model, flag: flag, consentPick: true)

        let fired = spy.received.compactMap {
            if case let .quizStepCompleted(stepNumber) = $0 { stepNumber } else { nil }
        }
        #expect(fired.contains(3), "the rendered consent step emits its fixed slot (step-0 a: EMIT)")
        #expect(
            fired.prefix(3) == [1, 3, 4],
            "the consenting funnel is contiguous from the gate on — 1 → 3 → 4, nothing renumbers"
        )
    }

    // MARK: - Resume-prompt pin: the stored opt-in gates fire() LIVE — an opt-in
    // made AT the consent step reaches the SAME-RUN summary fire

    @Test func test_optInAtConsent_summaryQuizCompletedReachesSink_liveGate() throws {
        let flag = OptInFlag() // off — the fresh-install default
        let (model, spy) = try makeShippingModel(flag: flag)
        model.onFirstScreenAppear() // pre-consent: gate-dropped
        drive(model, flag: flag, consentPick: true)

        #expect(model.isComplete, "the driven quiz must reach completion")
        model.onSummaryAppear()
        #expect(
            spy.received.contains { $0.kind == .quizCompleted },
            "an opt-in made at the consent step governs the LATER same-run summary fire — the live-gate property the hardwired {false}/.disabled could never satisfy"
        )
    }

    /// Zero-fire guard (passes at red AND green): a decline transmits nothing,
    /// across the whole quiz + summary, forever until changed.
    @Test func test_declineAtConsent_transmitsNothingEver() throws {
        let flag = OptInFlag()
        let (model, spy) = try makeShippingModel(flag: flag)
        model.onFirstScreenAppear()
        drive(model, flag: flag, consentPick: false)

        model.onSummaryAppear()
        #expect(
            spy.received.isEmpty,
            "declined: zero events reach the sink from the entire run — quiz, steps, summary"
        )
    }

    // MARK: - Step-0 (c) pin: the consent choice is a device setting — never a
    // QuizAnswer, never a checkpoint byte

    @Test func test_consentChoice_neverLandsInCheckpointAnswers() throws {
        let flag = OptInFlag()
        flag.isOn = true
        let store = throwawayStore()
        let (model, _) = try makeShippingModel(flag: flag, checkpoint: store)
        drive(model, until: "frequency") // past where consent renders

        let checkpointed = store.load()?.answers ?? []
        #expect(
            !checkpointed.contains { $0.stepID == "consent" },
            "the checkpoint may not carry the consent choice (ruling c — it is AppSettings' truth, not quiz progress)"
        )
        #expect(
            model.answer(for: "consent") == nil,
            "consent is never recorded as a QuizAnswer — the engine's answer map must stay consent-free"
        )
    }

    // MARK: - MVP §5 pin (guard, passes at red AND green): fire NOTHING before
    // the opt-in choice — onboarding_started and the pre-consent slots included

    @Test func test_preConsentSurfaces_fireNothing_onboardingStartedDropped() throws {
        let flag = OptInFlag() // off until the choice — the §5 default
        let (model, spy) = try makeShippingModel(flag: flag)
        model.onFirstScreenAppear() // would fire onboarding_started if the gate were open
        drive(model, until: "consent")

        #expect(
            spy.received.isEmpty,
            "MVP §5: nothing fires before the opt-in choice — onboarding_started and slots 1–2 are gate-dropped for everyone"
        )
    }

    // MARK: - Step-0 (d) pins: checkpoint resume around slot 3

    @Test func test_resume_onConsent_landsOnConsent_freshDecision() throws {
        let store = throwawayStore()
        store.save(QuizProgress(
            currentStepID: "consent",
            answers: [QuizAnswer(stepID: "habit", choiceIDs: ["vape"])]
        ))
        let flag = OptInFlag()
        let (model, _) = try makeShippingModel(flag: flag, checkpoint: store)
        #expect(
            model.currentStep?.id == "consent",
            "a user killed ON the consent step resumes ON it — never skip-forget an unanswered consent (ruling d)"
        )
    }

    /// Guard (passes at red AND green): a user who advanced past consent resumes
    /// past it — the choice lives in AppSettings, not the checkpoint, so resume
    /// never re-asks.
    @Test func test_resume_pastConsent_landsPastIt_neverReAsks() throws {
        let store = throwawayStore()
        store.save(QuizProgress(
            currentStepID: "frequency",
            answers: [QuizAnswer(stepID: "habit", choiceIDs: ["vape"])]
        ))
        let flag = OptInFlag()
        let (model, _) = try makeShippingModel(flag: flag, checkpoint: store)
        #expect(model.currentStep?.id == "frequency", "resume lands on the saved step")
        #expect(model.currentStep?.id != "consent", "an answered consent is never re-asked (ruling d)")
    }

    // MARK: - Architect Q4 ruling pin (guard, passes at red AND green): the
    // degraded emergency config carries NO consent step — its users simply never
    // opt in (fail-closed = default-off, the privacy-safe divergence)

    @Test func test_degradedConfig_hasNoConsentStep_soDegradedUsersStayOptedOut() throws {
        #expect(
            !QuizConfig.degraded.steps.contains { $0.id == "consent" },
            "degraded (a rare decode-failure fallback) has no consent step — recorded ruling, not drift"
        )
        let flag = OptInFlag()
        let spy = SpyAnalyticsSink()
        let model = QuizFlowModel(
            config: .degraded,
            analytics: AnalyticsService(sink: spy, isOptedIn: { flag.isOn }),
            checkpoint: throwawayStore()
        )
        #expect(
            model.visibleSteps.map(\.id) == ["habit", "spend", "motivations", "goal"],
            "the degraded path stays exactly its four steps — unmeasured, default-off, safe"
        )
    }
}
