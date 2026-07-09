import XCTest

/// E4.1 UI-smoke lane (Session 11, the slot-32 E2E shape): the REAL two-tap slip flow
/// on the cold panic route, end to end — panic exits step → "I slipped" (tap 1) → the
/// slip flow's confirm stage → "Log it" (tap 2) → the forgiveness screen with the live
/// 10-minute undo. One smoke, real wiring (seed hook → resolver → panic flow →
/// `onSlipRoute` → `SlipFlowModel.cold` → forgiveness), mirroring PanicFlowUITests'
/// launch/seed/skip mechanics exactly.
///
/// Why the cold route is the whole E2E this session: it needs no store-backed quit. The
/// decision record sanctions even a nil-quit cold slip (an unattributed outcome), so a
/// seeded picker card drives the flow deterministically and the confirm/logged/undo
/// shape is identical whether the slip is attributed or not (the store-half difference
/// is only WHERE the write lands).
///
/// Assertions target REAL elements only (buttons, static texts) — nested `.contain`
/// container identifiers are not reliably exposed to XCUITest (the Session 09 lesson,
/// re-proved on this exact panic screen: the skip BUTTON surfaced while the step
/// CONTAINER id never did). So the confirm stage is gated on its real
/// `slip.flow.confirm.log` BUTTON, never the `slip.flow.confirm` container id; the
/// forgiveness undo on the real `slip.flow.undo` button; `slip.flow.logged` /
/// `slip.flow.undoBanner` are queried type-agnostically (green places them on real text
/// elements — the `panic.flow.celebration.copy` precedent — not bare containers).
///
/// DEFERRED (Session 11 ledger): the dashboard half,
/// `test_slipFlow_completesInTwoTaps_fromDashboard`, waits on fixture seeding
/// (`-uiTestScenario`) — there is no quit-creation UI yet, so no XCUITest can reach a
/// store-backed slip entry. The store-route two-tap flow is pinned at the unit tier
/// this session; its XCUITest lands the session the seeding harness does.
@MainActor
final class SlipFlowUITests: XCTestCase {
    func test_panicExitISlipped_slipFlowTwoTaps_loggedShown_undoAvailable() {
        let app = XCUIApplication()
        app.launchEnvironment["FORCE_PANIC_ROUTE"] = "1"
        app.launchEnvironment["UITEST_SEED_PANIC_SNAPSHOT"] = "1"
        app.launch()

        // Reach the exits step exactly as the E3.2 panic smoke does: the seeded picker
        // → choose a quit → the flow opens on the pacer → skip every step.
        let rows = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'panic.quitPicker.row.'")
        )
        XCTAssertTrue(
            rows.firstMatch.waitForExistence(timeout: 15),
            "the seeded multi-quit snapshot lands on the picker first (E3.1 behavior, unchanged)"
        )
        rows.firstMatch.tap()

        XCTAssertTrue(
            app.staticTexts["panic.flow.step.breath.title"].waitForExistence(timeout: 15),
            "choosing a quit opens the E3.2 panic flow at the breath step"
        )
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

        // Tap 1 — "I slipped" hands off to the slip route (PanicFlowModel.exitSlipped).
        let slipped = app.buttons["panic.flow.exit.slipped"]
        XCTAssertTrue(
            slipped.waitForExistence(timeout: 10),
            "the exit states must offer 'I slipped' (PRD §6.4 step 5)"
        )
        slipped.tap()

        // DESIGNED RED FAILURE — the gate. At the red commit the production panic view
        // still routes the slip handoff to SlipRoutePlaceholderView
        // (`panic.flow.slipPlaceholder`); the real slip flow is not attached
        // (production init passes `onSlipRoute: { _ in }`), so its confirm stage never
        // appears and its "Log it" button never exists. Green attaches the real
        // `onSlipRoute` → the cold `SlipFlowModel` confirm stage. Gated on the stage's
        // real BUTTON (the `slip.flow.confirm` container id would not surface — Session
        // 09). A guard-return keeps this the SOLE, clean designed failure — never a
        // downstream `.tap()` on a missing element (red-spec rule 2: designed
        // assertion, never a crash).
        let confirmLog = app.buttons["slip.flow.confirm.log"]
        guard confirmLog.waitForExistence(timeout: 15) else {
            XCTFail("tapping 'I slipped' must open the slip flow's confirm stage — its 'Log it' button")
            return
        }

        // Tap 2 — "Log it": the one cold write boundary (buffer append + fsync), only
        // then the forgiveness screen (durable-first; "Logged." is never claimed
        // without durable bytes, §9 rule 1).
        confirmLog.tap()

        // The forgiveness screen: "Logged." + the live 10-minute undo. The undo BUTTON
        // (real element) is the load-bearing proof the flow completed and the window is
        // open; its hittability is the "undo available" assertion (mvp feature #3).
        let undo = app.buttons["slip.flow.undo"]
        XCTAssertTrue(
            undo.waitForExistence(timeout: 15),
            "the forgiveness screen must offer the 10-minute undo"
        )
        XCTAssertTrue(undo.isHittable, "the undo affordance is live within the window")

        // The forgiveness confirmation copy and its calm neutral undo banner (real text
        // elements — the `panic.flow.celebration.copy` precedent).
        XCTAssertTrue(
            app.descendants(matching: .any)
                .matching(identifier: "slip.flow.logged").firstMatch.exists,
            "the forgiveness confirmation ('Logged.') must be shown"
        )
        XCTAssertTrue(
            app.descendants(matching: .any)
                .matching(identifier: "slip.flow.undoBanner").firstMatch.exists,
            "the calm undo banner hosts the undo affordance"
        )

        // The placeholder dead end is gone: green replaced SlipRoutePlaceholderView with
        // the real flow, so its identifier must not exist anywhere anymore.
        XCTAssertFalse(
            app.descendants(matching: .any)
                .matching(identifier: "panic.flow.slipPlaceholder").firstMatch.exists,
            "the real slip flow replaced the panic.flow.slipPlaceholder dead end (E4.1)"
        )
    }
}
