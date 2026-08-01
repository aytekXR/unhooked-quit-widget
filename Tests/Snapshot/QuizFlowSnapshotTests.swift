import SnapshotTesting
import SwiftUI
import Testing
import UIKit
@testable import Ballast

// The final golden batch, part 2 of 2 — the QUIZ, and with it the last surface in
// the app carrying zero goldens. Six: `habit` ×4 axes, `consent` ×2.
//
// WHY THESE TWO STEPS, out of thirteen. `habit` is slot 1, the first question anyone
// ever answers, and the only step that renders the six habit nouns — the strings
// OQ-1 corrected across five surfaces, so a golden here pins that correction in
// pixels. `consent` is slot 3 and is a different KIND (`.consent`, E8.2's own step
// shape rather than a choice list): it is the analytics opt-in, the one screen whose
// wording the privacy story depends on, and the only step that is not a variation on
// "pick from a list". Between them they cover both step shapes the quiz has.
//
// ME-8 (S53) already guaranteed these capture the Waterline field on their FIRST
// mint, with no seam and no re-record: `WaterlineField` takes no clock input, so a
// quiz golden is byte-stable by construction — unlike `WaveTimerView`, which needs
// its freeze seam.
//
// ═══ DETERMINISM: THE HAZARD, AND WHY IT NEEDED NO NEW PRODUCTION CODE ═══
//
// `QuizFlowModel.init` calls `checkpoint.load()`. On the app-standard UserDefaults
// that is exactly right — it is what resumes an abandoned quiz — but in a test it
// means a leftover checkpoint from ANY earlier run would silently resume the fixture
// mid-quiz and shoot the wrong screen. That is the same class as the age gate's
// `Locale.current` read, and it would have been just as invisible: the golden would
// simply be of a different step, and it would look perfectly plausible.
//
// **It needed no seam, because two already exist and they compose.**
//   1. `QuizProgressStore(defaults:)` is injectable — the doc comment says "Injected
//      for tests; production default is the app-standard suite BY DESIGN". Each test
//      gets its own suite, wiped before use, so nothing leaks in or out.
//   2. `QuizFlowEngine.resume(config:progress:)` is the SHIPPING resume path. Seeding
//      that isolated store with a `QuizProgress` pointing at a step id lands the model
//      on that step through production code rather than a test-only back door.
//
// So the thing that was the hazard is also the positioning tool. The `consent`
// fixture is not posed — it is the real engine, resumed, exactly as a returning user
// would meet it.
//
// Geometry and determinism follow the flow neighbours exactly: `.device(config:
// .iPhone13)`, 0.99/0.98, iOS-17 closure-init traits (`UITraitCollection(traitsFrom:)`
// is DEPRECATED and fails under `-warnings-as-errors` — it burned a billed run once).

@MainActor
@Suite(.snapshots(record: .missing))
struct QuizFlowSnapshotTests {

    /// A UserDefaults suite of this test's own, wiped before use. Never `.standard`:
    /// the production store deliberately writes there (R5 storage ruling), so a
    /// snapshot that touched it could both READ another run's checkpoint and LEAVE
    /// one behind for the next.
    private static func isolatedStore(_ name: String) -> QuizProgressStore {
        let suite = "quiz.snapshot.\(name)"
        UserDefaults.standard.removePersistentDomain(forName: suite)
        return QuizProgressStore(defaults: UserDefaults(suiteName: suite) ?? .standard)
    }

    private static func shippingConfig() throws -> QuizConfig {
        try #require(
            QuizConfig.loadShipping(),
            "the audited quizConfig.json must be bundled — these goldens render the REAL question text"
        )
    }

    private func assertAxes(
        _ view: some View,
        axes: [(name: String, dark: Bool, ax5: Bool)],
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        for axis in axes {
            assertSnapshot(
                of: view,
                as: .image(
                    precision: 0.99,
                    perceptualPrecision: 0.98,
                    layout: .device(config: .iPhone13),
                    traits: UITraitCollection { traits in
                        traits.userInterfaceStyle = axis.dark ? .dark : .light
                        traits.preferredContentSizeCategory = axis.ax5
                            ? .accessibilityExtraExtraExtraLarge
                            : .large
                    }
                ),
                named: axis.name,
                fileID: fileID,
                file: filePath,
                testName: testName,
                line: line,
                column: column
            )
        }
    }

    /// Slot 1 — the first question anyone answers, and the only surface rendering all
    /// six habit nouns. Nothing is pre-selected, so this is the step at rest.
    ///
    /// AX5 is an axis here for the same reason it is on the age gate, and that reason
    /// stopped being theoretical this session: the age gate's first AX5 golden found
    /// a collapsed picker that made a required gate impassable (R60.2). The quiz is
    /// the other screen a user cannot route around.
    @Test func snapshot_quiz_habit() throws {
        let model = QuizFlowModel(
            config: try Self.shippingConfig(),
            checkpoint: Self.isolatedStore("habit")
        )
        #expect(model.currentStep?.id == "habit", "a fresh engine must open on slot 1 — if this fails a checkpoint leaked in")
        #expect(model.currentSlot == 1)

        assertAxes(
            QuizFlowView(model: model).frame(maxWidth: .infinity, maxHeight: .infinity),
            axes: [
                ("light", false, false), ("dark", true, false),
                ("light-ax5", false, true), ("dark-ax5", true, true),
            ]
        )
    }

    /// Slot 3 — the analytics consent step, reached through the SHIPPING resume path
    /// rather than posed. This is the screen the whole privacy story rests on: it is
    /// where "analytics are opt-in" stops being a claim in a document and becomes a
    /// thing a user is asked. Worth pinning in pixels for that reason alone.
    @Test func snapshot_quiz_consent() throws {
        let store = Self.isolatedStore("consent")
        // Answering `habit` is what makes `consent` reachable, and seeding the answer
        // through `QuizProgress` means the engine resumes exactly as it would for a
        // user who closed the app after question one.
        store.save(
            QuizProgress(
                currentStepID: "consent",
                answers: [QuizAnswer(stepID: "habit", choiceIDs: ["vape"])]
            )
        )
        let model = QuizFlowModel(config: try Self.shippingConfig(), checkpoint: store)
        #expect(model.currentStep?.id == "consent", "the resume seam must land on slot 3, not the first step")
        #expect(model.currentStep?.kind == .consent, "this must be the consent STEP KIND, not a choice list")

        assertAxes(
            QuizFlowView(model: model).frame(maxWidth: .infinity, maxHeight: .infinity),
            axes: [("light", false, false), ("dark", true, false)]
        )
    }
}
