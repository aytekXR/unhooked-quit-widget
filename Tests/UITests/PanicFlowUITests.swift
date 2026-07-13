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
        //
        // S29 drive hardening (run 29273795616, artifact-diagnosed — R29.10):
        // a synthesized tap can be SWALLOWED when it lands mid step-transition.
        // The run-2 flake's failure-time hierarchies prove the class: after the
        // second skip "succeeded", the app was still ON the timer step, and
        // every later wait ran exactly one step behind while the flow advanced
        // correctly on every tap that landed. The drive gains the S25 wheel
        // discipline — verify the tap TOOK; if the PREVIOUS step is provably
        // still on screen, ONE bounded re-tap with evidence attached. The
        // guard makes a double-advance impossible (the re-tap fires only when
        // the previous title still exists) and every assertion is unchanged.
        let skip = app.buttons["panic.flow.skip"]
        var previous = "breath"
        for step in ["timer", "reasons", "redirect"] {
            XCTAssertTrue(skip.waitForExistence(timeout: 10), "each step offers its skip affordance")
            skip.tap()
            if !app.staticTexts["panic.flow.step.\(step).title"].waitForExistence(timeout: 10),
               app.staticTexts["panic.flow.step.\(previous).title"].exists {
                attach(app, name: "skip-tap-swallowed-on-\(previous)")
                skip.tap() // ONE bounded re-tap (the S25 wheel-retry shape)
            }
            XCTAssertTrue(
                app.staticTexts["panic.flow.step.\(step).title"].waitForExistence(timeout: 10),
                "skip must advance to the \(step) step"
            )
            previous = step
        }
        skip.tap() // redirect → exits
        let averted = app.buttons["panic.flow.exit.averted"]
        if !averted.waitForExistence(timeout: 10),
           app.staticTexts["panic.flow.step.redirect.title"].exists {
            attach(app, name: "skip-tap-swallowed-on-redirect")
            skip.tap() // ONE bounded re-tap
        }
        XCTAssertTrue(
            averted.waitForExistence(timeout: 10),
            "the exit states must offer 'urge passed' (PRD §6.4 step 5)"
        )
        averted.tap()

        let celebration = app.staticTexts["panic.flow.celebration.copy"]
        if !celebration.waitForExistence(timeout: 10), averted.exists {
            attach(app, name: "averted-tap-swallowed-on-exits")
            averted.tap() // ONE bounded re-tap (same class, same guard)
        }
        XCTAssertTrue(
            celebration.waitForExistence(timeout: 10),
            "urge passed must land on the quiet celebration (the averted confirmation copy)"
        )
        XCTAssertFalse(
            app.descendants(matching: .any)
                .matching(identifier: "root.placeholder").firstMatch.exists,
            "the whole flow stays inside the panic route — never the normal hierarchy (ADR-6)"
        )
    }

    /// Stage-boundary screenshot, deleted on success (the S18-owed diagnostic
    /// shape; fires only when a swallowed-tap retry engages).
    private func attach(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .deleteOnSuccess
        add(attachment)
    }
}
