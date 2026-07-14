import XCTest

/// E9.3 (R28.6) UI-smoke lane (scenario 33, the a11y-audit family):
/// `try app.performAccessibilityAudit()` over the three named flows, delivered
/// as the plan-named family. The plan/test-suite name a single
/// `test_a11yAudit_quizPanicSlip_noViolations`; it is split here into three
/// per-leg funcs (the R26.8 rename precedent) that TOGETHER honor that name and
/// TAKE scenario 33's ONE slot — the named-test cap stays 8 named / 12 hard, no
/// slot minted. The split is structural, not cosmetic: it lets the safety legs
/// and the quiz leg carry different flake postures (below).
///
/// Rule-11 posture (test-suite §7 rule 11): `test_a11yAudit_panicFlow_noViolations`
/// and `test_a11yAudit_slipFlow_noViolations` are SAFETY legs — they may NEVER
/// be quarantined, valved, or suppressed; a flake there halts merges until fixed
/// (a real a11y regression on the crisis/slip path is a real finding, fixed in
/// the contingency, never deferred). `test_a11yAudit_quizFlow_noViolations` is
/// NOT a rule-11 safety path (the onboarding funnel — not crisis/age-gate/
/// alcohol-notice/shame-copy/resources) and carries the pre-worded valve, quoted
/// verbatim from RULINGS-R28 (R28.6):
///   "the quiz leg may move to non-blocking with an issue opened IFF it flakes
///   on a documented OS-dependent audit class, suppressed class named in-code,
///   binding subset (missing-label/hit-region/element-detection/
///   sufficient-element-description) stays live."
///
/// API (docs-verifier): `performAccessibilityAudit(for:_:)` lives on
/// `XCUIApplication` (framework XCUIAutomation), NOT `XCUIDevice` — test-suite.md:91's
/// "XCUIDevice" phrasing is documentation drift, not a spec. NO issue handler —
/// the handler's true/false return semantics are docs-unconfirmed; any in-scope
/// issue fails. The audit is iOS-17+ / XCUIAutomation and the deployment floor
/// is iOS 26, so there is NO `#available` guard (a dead guard is banned).
///
/// AUDIT SCOPE (R28.13 → UIR-0/Session 32, the one sanctioned direction change):
/// every leg audits `Self.auditTypes` = all confirmed types EXCEPT
/// {.dynamicType, .textClipped}. **`.contrast` is RESTORED (R32.3)** — UIR-0's
/// tokens-v2 palette swap closed the S28 contrast findings BY CONSTRUCTION:
/// every fg/bg pair the audited frames render is registered in
/// `Theme.contrastPairs` and pinned ≥ its WCAG threshold by the unit lane's
/// `ThemeContrastTests`, so a palette regression fails unit BEFORE it could
/// fire here on a rule-11 safety leg. The TWO remaining exclusions are
/// LAYOUT-BOUND (type-scaling growth/clipping — the S28 artifact's
/// .dynamicType/.textClipped set): they ride their surfaces' structural
/// sessions (quiz → UIR-1, slip → UIR-2, panic incl. the AX5 entry-title
/// truncation → UIR-3) and may only shrink from here (the gate only GROWS:
/// restoring a class means deleting it from the exclusion AND fixing what
/// fires). The in-scope set keeps the binding classes live on every leg —
/// element detection, hit regions, labels/descriptions, traits, contrast —
/// which is what rule 11 protects on the safety legs.
///
/// Drive paths — audit LOW-FUZZ frames ONLY (no TimelineView, no live animation;
/// the breath pacer's bloom + haptics ticks are `.accessibilityHidden`, but its
/// frame animates, so the pacer is NEVER audited):
///  - panic/slip: the PROVEN seeded cold route (FORCE_PANIC_ROUTE +
///    UITEST_SEED_PANIC_SNAPSHOT), mirroring PanicFlowUITests/SlipFlowUITests'
///    launch/seed/picker/skip mechanics exactly. Panic audits the redirect +
///    exits frames; slip audits the confirm + logged/forgiveness frames.
///  - quiz: the NEW `#if DEBUG` UITEST_QUIZ direct mount (over the shipping
///    config, `.disabled` analytics) — NEVER the scenario-29 gate→quiz hand-off,
///    and NEVER the S25 seeded-gate path either (UITEST_SEED_AGE_VERIFIED's leg
///    stalled on CI waiting for the repository publish — the zero-button tree).
///    The switch lives at BOTH levels (AgeGateContainerView forwards, then
///    PostGateRootView renders the quiz), so launch→audited-frame is pure view
///    composition: no repository publish, no gate model, no store read. The
///    test-lane mount bypasses the gate SCREEN in DEBUG only; the gate's
///    un-bypassability stays unit-pinned (S18) and release builds compile the
///    switch out.
///
/// Assertions target REAL elements only (buttons, static texts) — nested
/// container identifiers are not reliably exposed to XCUITest (the Session 09
/// lesson): each leg gates on a real BUTTON before it audits, with bounded
/// `waitForExistence` (never a sleep) so every audit is reached deterministically.
@MainActor
final class A11yAuditUITests: XCTestCase {
    /// R28.13 → R32.3 — the in-scope audit classes: the FULL iOS member set
    /// EXCEPT the two LAYOUT-BOUND classes deferred BY NAME with run
    /// 29262073722's artifact as the finding ledger (see the file header;
    /// `.contrast` restored in UIR-0 — the tokens-v2 palette closes it by
    /// construction, unit-pinned in ThemeContrastTests). Per-member PLATFORM
    /// availability is docs-JSON-verified (the run-29264641853 burn lesson:
    /// `.action`/`.parentChild` EXIST but are macOS-14-only — existence on the
    /// type is not availability on the platform; every member below is iOS 17.0).
    private static let auditTypes: XCUIAccessibilityAuditType = [
        .contrast, .elementDetection, .hitRegion, .sufficientElementDescription, .trait,
    ]

    /// SAFETY leg (rule 11 — NEVER quarantined/valved/suppressed). Drives the
    /// seeded cold panic route to its static frames and audits the redirect frame
    /// and the exits frame — both low-fuzz (no TimelineView); the animating breath
    /// pacer is never audited.
    func test_a11yAudit_panicFlow_noViolations() throws {
        let app = XCUIApplication()
        app.launchEnvironment["FORCE_PANIC_ROUTE"] = "1"
        app.launchEnvironment["UITEST_SEED_PANIC_SNAPSHOT"] = "1"
        app.launch()

        // Reach the flow exactly as the E3.2 panic smoke does: the seeded picker
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

        // Audit the redirect frame (static redirect buttons — no TimelineView).
        // Gate on a real INTERACTIVE element of the frame, not just the title Text:
        // a settled option button is the cleaner "the 600ms stage fade is done"
        // signal before the audit snapshots the tree (dry-run strengthen, R28.6).
        XCTAssertTrue(
            app.buttons["panic.flow.redirect.option.water"].waitForExistence(timeout: 10),
            "the redirect menu renders its shipping options before the audit runs"
        )
        try app.performAccessibilityAudit(for: Self.auditTypes)

        skip.tap() // redirect → exits

        // The exits frame — anchored on its real 'urge passed' button (the
        // container id would not surface; Session 09). Audit it (static buttons,
        // the low-fuzz exit frame).
        let averted = app.buttons["panic.flow.exit.averted"]
        XCTAssertTrue(
            averted.waitForExistence(timeout: 10),
            "the exit states must offer 'urge passed' (PRD §6.4 step 5)"
        )
        try app.performAccessibilityAudit(for: Self.auditTypes)
    }

    /// SAFETY leg (rule 11 — NEVER quarantined/valved/suppressed). Continues the
    /// seeded route through the two-tap slip flow and audits the confirm frame and
    /// the logged/forgiveness frame — both static (no TimelineView).
    func test_a11yAudit_slipFlow_noViolations() throws {
        let app = XCUIApplication()
        app.launchEnvironment["FORCE_PANIC_ROUTE"] = "1"
        app.launchEnvironment["UITEST_SEED_PANIC_SNAPSHOT"] = "1"
        app.launch()

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

        // Tap 'I slipped' — hands off to the slip route (PanicFlowModel.exitSlipped).
        let slipped = app.buttons["panic.flow.exit.slipped"]
        XCTAssertTrue(
            slipped.waitForExistence(timeout: 10),
            "the exit states must offer 'I slipped' (PRD §6.4 step 5)"
        )
        slipped.tap()

        // The slip confirm frame — gated on its real 'Log it' button (the
        // slip.flow.confirm container id would not surface; Session 09). Audit it
        // (static confirm/cancel buttons — no TimelineView).
        let confirmLog = app.buttons["slip.flow.confirm.log"]
        XCTAssertTrue(
            confirmLog.waitForExistence(timeout: 15),
            "tapping 'I slipped' must open the slip flow's confirm stage — its 'Log it' button"
        )
        try app.performAccessibilityAudit(for: Self.auditTypes)

        confirmLog.tap()

        // The logged/forgiveness frame — gated on the real 10-minute undo button.
        // Audit it (static logged copy + undo — no TimelineView).
        let undo = app.buttons["slip.flow.undo"]
        XCTAssertTrue(
            undo.waitForExistence(timeout: 15),
            "the forgiveness screen must offer the 10-minute undo"
        )
        try app.performAccessibilityAudit(for: Self.auditTypes)
    }

    /// The quiz leg — NOT a rule-11 safety path (the onboarding funnel). It is
    /// valve-eligible: the pre-worded R28.6 valve in this file's header binds it.
    /// Driven through the DEBUG UITEST_QUIZ direct mount ALONE (never the
    /// scenario-29 hand-off, never the S25 seeded gate): the two-level switch
    /// makes launch→quiz pure view composition, so no seed, no reset, and no
    /// store state can stall it. Audits the FIRST quiz step (a singleChoice —
    /// no keyboard, low-fuzz).
    func test_a11yAudit_quizFlow_noViolations() throws {
        let app = XCUIApplication()
        app.launchEnvironment["UITEST_QUIZ"] = "1"
        app.launch()

        // The quiz.continue button is the real element anchor (the quiz.flow
        // container id would not surface; Session 09) — its existence proves the
        // first step rendered.
        let continueButton = app.buttons["quiz.continue"]
        XCTAssertTrue(
            continueButton.waitForExistence(timeout: 15),
            "the UITEST_QUIZ direct mount lands on the first quiz step (a singleChoice — no keyboard)"
        )
        try app.performAccessibilityAudit(for: Self.auditTypes)
    }
}
