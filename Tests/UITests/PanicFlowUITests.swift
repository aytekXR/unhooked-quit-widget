import XCTest

/// E3.2 UI-smoke lane: the real panic flow end to end on the seeded cold route —
/// picker → breath pacer → skip through every step → "urge passed" → quiet
/// celebration. One smoke, real wiring (seed hook → resolver → flow model → exit);
/// step/exit semantics are pinned at the unit tier (PanicFlowTests), the visuals in
/// the snapshot lane.
///
/// Assertions target REAL elements only (buttons, static texts) — nested
/// `.contain` container identifiers are not reliably exposed to XCUITest (the
/// Session 09 lesson; run 29043512846 re-proved it on this exact screen: the skip
/// BUTTON was found while the step CONTAINER id never surfaced).
@MainActor
final class PanicFlowUITests: XCTestCase {
    func test_panicFlow_skipThroughSteps_exitUrgePassed_celebrates() {
        let app = XCUIApplication()
        app.launchEnvironment["FORCE_PANIC_ROUTE"] = "1"
        app.launchEnvironment["UITEST_SEED_PANIC_SNAPSHOT"] = "1"
        app.launch()

        // Two seeded quits, no selection → picker. Choosing one ENTERS the flow.
        let rows = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'panic.quitPicker.row.'")
        )
        XCTAssertTrue(
            rows.firstMatch.waitForExistence(timeout: 15),
            "the seeded multi-quit snapshot must land on the picker first (E3.1 behavior, unchanged)"
        )
        rows.firstMatch.tap()

        // The flow opens ON the pacer (PRD §6.4: the first frame is the pacer).
        XCTAssertTrue(
            app.staticTexts["panic.flow.step.breath.title"].waitForExistence(timeout: 15),
            "choosing a quit must open the real E3.2 flow at the breath step"
        )

        // Every step is skippable; four skips land on the exit states.
        let skip = app.buttons["panic.flow.skip"]
        for step in ["timer", "reasons", "redirect"] {
            XCTAssertTrue(skip.waitForExistence(timeout: 10), "each step offers its skip affordance")
            skip.tap()
            XCTAssertTrue(
                app.staticTexts["panic.flow.step.\(step).title"].waitForExistence(timeout: 10),
                "skip must advance to the \(step) step"
            )
        }
        skip.tap() // redirect → exits

        let averted = app.buttons["panic.flow.exit.averted"]
        XCTAssertTrue(
            averted.waitForExistence(timeout: 10),
            "the exit states must offer 'urge passed' (PRD §6.4 step 5)"
        )
        averted.tap()

        XCTAssertTrue(
            app.staticTexts["panic.flow.celebration.copy"].waitForExistence(timeout: 10),
            "urge passed must land on the quiet celebration (the averted confirmation copy)"
        )
        XCTAssertFalse(
            app.descendants(matching: .any)
                .matching(identifier: "root.placeholder").firstMatch.exists,
            "the whole flow stays inside the panic route — never the normal hierarchy (ADR-6)"
        )
    }
}
