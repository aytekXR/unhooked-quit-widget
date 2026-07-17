import XCTest

/// E9.3 (R28.6) UI-smoke lane (scenario 33, the a11y-audit family):
/// `try app.performAccessibilityAudit()` over the named flows, delivered as a
/// family. The plan/test-suite name a single `test_a11yAudit_quizPanicSlip_noViolations`;
/// it is split here into per-leg funcs (the R26.8 rename precedent) that TOGETHER
/// honor that name and TAKE scenario 33's ONE slot — the named-test cap stays
/// 8 named / 12 hard, no slot minted. The split is structural, not cosmetic: it
/// lets the safety legs and the onboarding legs carry different flake postures
/// AND (UIR-1) different AUDIT SETS.
///
/// Rule-11 posture (test-suite §7 rule 11): `test_a11yAudit_panicFlow_noViolations`,
/// `test_a11yAudit_slipFlow_noViolations` and (NEW, UIR-1)
/// `test_a11yAudit_ageGate_noViolations` are SAFETY legs — they may NEVER be
/// quarantined, valved, or suppressed; a flake there halts merges until fixed. The
/// age gate is named in rule 11's safety category BY NAME (it is the un-bypassable
/// minor-protection surface, and its blocked screen carries live helpline numbers —
/// the one screen a minor in trouble actually reads).
/// `test_a11yAudit_quizFlow_noViolations` and (NEW, UIR-1)
/// `test_a11yAudit_summary_noViolations` are NOT rule-11 paths (the onboarding
/// funnel) and carry the pre-worded valve, quoted verbatim from RULINGS-R28 (R28.6):
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
/// ── AUDIT SCOPE — ONE FULL SET, ALL LEGS (UIR-3, R35; was a UIR-1 per-leg split) ──
/// The exclusion list may only SHRINK (R32.3), and UIR-3 shrinks it to ZERO. The
/// UIR-1 split existed because `.dynamicType`/`.textClipped` are LAYOUT-bound and the
/// S28 ledger (run 29262073722 — the one full-set execution) named exactly which
/// elements fired: the 4 panic redirect-menu rows and the slip forgiveness frame fired
/// `.dynamicType` (a 56pt minHeight floor near the label's accessibility-size height,
/// in a non-scrollable bounded container). Those were UIR-3's frames — now REBUILT
/// (padding-for-floor + scrolling stages), so the panic and slip legs join the
/// onboarding legs on the FULL set and `safetyAuditTypes` is deleted. The QUIZ leg
/// fired ZERO of either class in that same run; UIR-1 paid that debt. `.contrast`
/// stays live on EVERY leg (restored in UIR-0/R32.3, held by `ThemeContrastTests`'
/// registry pin, which fails the unit lane before a palette regression could reach a
/// safety leg here).
///
/// Drive paths — audit LOW-FUZZ frames ONLY (no TimelineView, no live animation;
/// the breath pacer's bloom + haptics ticks are `.accessibilityHidden`, but its
/// frame animates, so the pacer is NEVER audited):
///  - panic/slip: the PROVEN seeded cold route (FORCE_PANIC_ROUTE +
///    UITEST_SEED_PANIC_SNAPSHOT), mirroring PanicFlowUITests/SlipFlowUITests'
///    launch/seed/picker/skip mechanics exactly.
///  - age gate: the REAL first-launch surface (UITEST_RESET — a fresh install lands
///    on the gate; the funnel smoke's proven mount). No DEBUG hook exists or is
///    needed: the gate IS the app's first screen. The blocked frame is reached the
///    way a real minor reaches it — the wheel, a failing year, Continue.
///  - quiz: the DEBUG UITEST_QUIZ direct mount (over the shipping config,
///    `.disabled` analytics) — NEVER the scenario-29 gate→quiz hand-off.
///  - summary: the NEW DEBUG UITEST_SUMMARY direct mount (UITEST_QUIZ's precedent):
///    the real `QuizSummaryView` over the shipping copy table and a representative
///    fixture, `.disabled` analytics, no repository, no store. Release-inert BY
///    CONSTRUCTION (`#if DEBUG`).
///
/// Assertions target REAL elements only (buttons, static texts) — nested
/// container identifiers are not reliably exposed to XCUITest (the Session 09
/// lesson): each leg gates on a real element before it audits, with bounded
/// `waitForExistence` (never a sleep) so every audit is reached deterministically.
@MainActor
final class A11yAuditUITests: XCTestCase {
    /// The FULL member set — every leg's set now (UIR-3, R34→R35). `.dynamicType` and
    /// `.textClipped` INCLUDED. UIR-1 gave this to the onboarding legs; **UIR-3 gives
    /// it to the panic and slip legs too, closing the R28.13 exclusion list to ZERO** —
    /// `safetyAuditTypes` (the old EXCEPT-the-two-layout-classes set) is deleted, having
    /// zero callers after UIR-3 rebuilt those frames (every 56pt panic/slip target now
    /// rides PADDING, never a minHeight floor, and the non-scrolling stages scroll).
    /// Per-member PLATFORM availability is docs-JSON-verified (the run-29264641853 burn
    /// lesson: `.action`/`.parentChild` EXIST but are macOS-14-only — existence on the
    /// type is not availability on the platform; every member below is iOS 17.0).
    private static let onboardingAuditTypes: XCUIAccessibilityAuditType = [
        .contrast, .dynamicType, .elementDetection, .hitRegion,
        .sufficientElementDescription, .textClipped, .trait,
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
        try app.performAccessibilityAudit(for: Self.onboardingAuditTypes)

        skip.tap() // redirect → exits

        // The exits frame — anchored on its real 'urge passed' button (the
        // container id would not surface; Session 09). Audit it (static buttons,
        // the low-fuzz exit frame).
        let averted = app.buttons["panic.flow.exit.averted"]
        XCTAssertTrue(
            averted.waitForExistence(timeout: 10),
            "the exit states must offer 'urge passed' (PRD §6.4 step 5)"
        )
        try app.performAccessibilityAudit(for: Self.onboardingAuditTypes)
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
        try app.performAccessibilityAudit(for: Self.onboardingAuditTypes)

        confirmLog.tap()

        // The logged/forgiveness frame — gated on the real 10-minute undo button.
        // Audit it (static logged copy + undo — no TimelineView).
        let undo = app.buttons["slip.flow.undo"]
        XCTAssertTrue(
            undo.waitForExistence(timeout: 15),
            "the forgiveness screen must offer the 10-minute undo"
        )
        try app.performAccessibilityAudit(for: Self.onboardingAuditTypes)
    }

    /// SAFETY leg (rule 11 — NEW in UIR-1, NEVER quarantined/valved/suppressed).
    /// The age gate is the app's FIRST screen and its un-bypassable minor-protection
    /// surface; the blocked frame it routes a minor to carries live helpline numbers.
    /// Both frames now run the FULL audit set.
    ///
    /// No DEBUG mount: a fresh install (UITEST_RESET — the funnel smoke's proven
    /// launch) lands on the real gate, and the blocked frame is reached the way a
    /// real under-17 user reaches it — the wheel, a failing year, Continue. The
    /// wheel drive is the S29 artifact-rehabilitated one (adjust → VERIFY the value
    /// took → one bounded retry; R29.10: every step of a multi-step drive verifies
    /// that its tap/adjust actually took).
    func test_a11yAudit_ageGate_noViolations() throws {
        let app = XCUIApplication()
        app.launchEnvironment["UITEST_RESET"] = "1"
        app.launch()

        // ── Frame 1: the year-entry screen (the app's first frame). ───────────
        let gateContinue = app.buttons["ageGate.continue"]
        XCTAssertTrue(
            gateContinue.waitForExistence(timeout: 20),
            "a fresh install lands on the age gate — its Continue is the real element anchor"
        )
        try app.performAccessibilityAudit(for: Self.onboardingAuditTypes)

        // ── Drive to frame 2: a year that FAILS the 17+ boundary. ─────────────
        let minorYear = Self.minorBirthYear
        let wheel = app.pickerWheels.firstMatch
        XCTAssertTrue(wheel.waitForExistence(timeout: 10), "the gate renders its year wheel")
        wheel.adjust(toPickerWheelValue: minorYear)
        if (wheel.value as? String)?.contains(minorYear) != true {
            wheel.adjust(toPickerWheelValue: minorYear) // ONE bounded retry (the S18-owed drive)
        }
        XCTAssertTrue(
            (wheel.value as? String)?.contains(minorYear) == true,
            "the wheel adjust took (verified value, one retry — the S25-proven drive)"
        )
        XCTAssertTrue(
            gateContinue.isEnabled,
            "an explicit year selection enables the gate CTA (the ghost-disabled state lifts)"
        )
        gateContinue.tap()

        // ── Frame 2: the blocked resources screen (helpline cards + the calm exit).
        let goBack = app.buttons["ageGate.blocked.goBack"]
        XCTAssertTrue(
            goBack.waitForExistence(timeout: 15),
            "an under-17 year routes to the calm blocked screen — never a dead end, never app content"
        )
        try app.performAccessibilityAudit(for: Self.onboardingAuditTypes)
    }

    /// The quiz leg — NOT a rule-11 safety path (the onboarding funnel). It is
    /// valve-eligible: the pre-worded R28.6 valve in this file's header binds it.
    /// Driven through the DEBUG UITEST_QUIZ direct mount ALONE (never the
    /// scenario-29 hand-off, never the S25 seeded gate): the two-level switch
    /// makes launch→quiz pure view composition, so no seed, no reset, and no
    /// store state can stall it.
    ///
    /// UIR-1: runs the FULL set (`.dynamicType`/`.textClipped` RESTORED — the debt
    /// R32.3 assigned to this session) and audits TWO frames: the first step (a
    /// singleChoice — chips, no keyboard) and the CONSENT step, which is the very
    /// next visible step (habit = slot 1, consent = slot 3; the customName step
    /// between them renders only when habit == custom). The consent frame is the
    /// one place the funnel asks for something rather than offering it — E8.2's
    /// equal-choice rule means both options are peer chips, so it must audit clean.
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
        try app.performAccessibilityAudit(for: Self.onboardingAuditTypes)

        // Drive ONE step, verifying each tap took (R29.10): pick a habit, which
        // enables Continue (the single-choice gate), then advance to consent.
        let habit = app.buttons["quiz.choice.vape"]
        XCTAssertTrue(habit.waitForExistence(timeout: 10), "the habit step offers its shipping chips")
        habit.tap()
        XCTAssertTrue(
            continueButton.isEnabled,
            "the chip tap TOOK — a single-choice pick lifts Continue out of its ghost-disabled state"
        )
        continueButton.tap()

        // The consent step (E8.2, slot 3) — anchored on its real opt-in chip.
        let optIn = app.buttons["quiz.choice.optIn"]
        XCTAssertTrue(
            optIn.waitForExistence(timeout: 10),
            "advancing from the habit step lands on the consent step (slot 3, the next visible step)"
        )
        try app.performAccessibilityAudit(for: Self.onboardingAuditTypes)
    }

    /// The summary leg — NOT a rule-11 safety path (the onboarding funnel);
    /// valve-eligible on the quiz leg's pre-worded R28.6 terms.
    ///
    /// NEW in UIR-1, and the reason it matters: brandkit §6.7 calls this "the most
    /// designed single screen in the app", and its hero numeral shipped as a FIXED
    /// 56pt font with `.minimumScaleFactor(0.5)` — a figure that does not respond to
    /// Dynamic Type at all and then shrinks rather than reflows. UIR-1 rebuilds it
    /// (`@ScaledMetric` + a cap + a `ViewThatFits` layout ladder) and this leg holds
    /// it to that forever, on the FULL audit set.
    ///
    /// Mounted through the DEBUG UITEST_SUMMARY switch (the UITEST_QUIZ precedent):
    /// the real view over the shipping copy table + a representative fixture,
    /// `.disabled` analytics, no repository, no store. Release-inert BY CONSTRUCTION.
    func test_a11yAudit_summary_noViolations() throws {
        let app = XCUIApplication()
        app.launchEnvironment["UITEST_SUMMARY"] = "1"
        app.launch()

        // The forward CTA is the summary's real surfacing element (summary.card is
        // a nested container — Session 09).
        let cta = app.buttons["summary.cta"]
        XCTAssertTrue(
            cta.waitForExistence(timeout: 15),
            "the UITEST_SUMMARY direct mount renders the payoff screen — its forward CTA surfaces"
        )
        // The hero must be the money figure variant, not the absent-savings reframe:
        // auditing the degraded card would silently skip the numeral this leg exists
        // to protect.
        //
        // Queried across ALL element types, not `staticTexts`: the id rides a block
        // that `.accessibilityElement(children: .ignore)` COLLAPSES into one element,
        // and a collapsed SwiftUI group surfaces to XCUITest as `.other`, not as a
        // static text. Run 29303961082 proved it — the hero rendered (the audit
        // screenshotted "~$1,350") while this assertion, then written against
        // `staticTexts`, failed. The lesson is Session 09's, again: never assume the
        // element TYPE an identifier lands on.
        let hero = app.descendants(matching: .any)["summary.savings"]
        XCTAssertTrue(
            hero.waitForExistence(timeout: 5),
            "the fixture renders the SAVINGS hero (the variant whose Dynamic-Type behaviour UIR-1 fixed)"
        )
        try app.performAccessibilityAudit(for: Self.onboardingAuditTypes)
    }

    /// The dashboard leg — NEW in UIR-2. NOT a rule-11 safety path (it carries no minor
    /// protection and no live helpline numbers), so it takes the R28.6 onboarding-leg
    /// posture and the FULL `onboardingAuditTypes` set (the exclusion list only shrinks,
    /// R32.3). This is the surface's FIRST audit, and per the S33 rule its ledger is
    /// produced by RUNNING it — NO issue handler is pre-added on a prediction (two
    /// reviewers were refuted by the run last session).
    ///
    /// Mounted through the DEBUG UITEST_DASHBOARD switch: the real `StreakDashboardCard`
    /// over a fixture value model, inside a ScrollView (the real card's scroll-plus-grow
    /// contract), `.disabled`/no analytics, no repository, no store. Release-inert BY
    /// CONSTRUCTION.
    func test_a11yAudit_dashboard_noViolations() throws {
        let app = XCUIApplication()
        app.launchEnvironment["UITEST_DASHBOARD"] = "1"
        app.launch()

        // R33.13: the card collapses to a `.accessibilityElement(children: .contain)`
        // group, which surfaces to XCUITest as `.other`, never `.staticText`/`.button` —
        // query descendants(matching: .any).
        let card = app.descendants(matching: .any)["dashboard.card.fixture"]
        XCTAssertTrue(
            card.waitForExistence(timeout: 15),
            "the UITEST_DASHBOARD direct mount renders the StreakDashboardCard fixture"
        )
        try app.performAccessibilityAudit(for: Self.onboardingAuditTypes)
    }

    /// The resources leg — NEW in UIR-4. Rule-11-ADJACENT (a post-gate helpline surface
    /// for consented adults — NOT the un-bypassable minor-protection age-gate blocked
    /// screen), so it takes the R28.6 onboarding-leg posture and the FULL set. First audit
    /// of this surface: NO issue handler is pre-added (the run produces the ledger, S33).
    /// Pre-conditions landed in the SAME commit: the DIAL link at the 44pt floor with a
    /// descriptive "Call <name>" label (R33.10), and the `.quaternary` fill → `themedCard`.
    ///
    /// Mounted through the DEBUG UITEST_RESOURCES switch (the UITEST_DASHBOARD precedent):
    /// the real `SafetyResourcesView` (store-free), `.disabled` analytics. Release-inert.
    func test_a11yAudit_resources_noViolations() throws {
        let app = XCUIApplication()
        app.launchEnvironment["UITEST_RESOURCES"] = "1"
        app.launch()

        // Gate on the title Text (a real `.contain` CHILD that surfaces), NOT the
        // full-screen `resources.screen` container id — a full-screen `.contain`
        // container does not surface as a queryable element (run 29618554339 proved it:
        // the view rendered — its "Call <name>" links were in the tree — but the
        // container id never surfaced). Queried across all types for robustness.
        let title = app.descendants(matching: .any)["resources.title"]
        XCTAssertTrue(
            title.waitForExistence(timeout: 15),
            "the UITEST_RESOURCES direct mount renders SafetyResourcesView"
        )
        try app.performAccessibilityAudit(for: Self.onboardingAuditTypes)
    }

    /// A birth year that is unambiguously under 17 on any run date (the gate's
    /// conservative boundary works in whole years; 5 years ago can never pass).
    private static var minorBirthYear: String {
        String(Calendar.current.component(.year, from: Date()) - 5)
    }
}
