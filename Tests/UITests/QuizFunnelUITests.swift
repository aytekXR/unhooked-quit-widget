import XCTest

/// S29 (R29.2) — scenario-29's re-land, diagnosis-corrected (the artifact of run
/// 29205964725, parsed on the Linux box): the S25 "gate→quiz hand-off hang"
/// NEVER EXISTED on the driven leg — the quiz was fully mounted and interactive
/// at timeout (quiz.progress "Step 1 of 11", all six habit chips, the disabled
/// Continue, screenshot-confirmed); the smoke failed only because it waited on
/// `quiz.flow`, a nested `.contain` CONTAINER identifier that never surfaces to
/// XCUITest (the Session-09 lesson this file's ancestor violated — the same
/// lesson A11yAuditUITests:214 anchors `quiz.continue` for). Every blocking
/// wait below anchors on artifact-PROVEN surfacing elements:
/// quiz.flow → quiz.continue · summary.card → summary.cta · paywall.card →
/// paywall.cta.
///
/// THE SEEDED FALLBACK IS RETIRED (R29.2): the S25 seeded relaunch genuinely
/// stalled — `RepositoryProvider.startIfNeeded` sets `started = true` BEFORE
/// its do-block and swallows a store-open throw with NO retry, so the
/// terminate→relaunch+UITEST_RESET race leaves the repository nil forever (the
/// circle.dashed screen; a REAL latent defect, deferred BY NAME — R29.4). The
/// `UITEST_SEED_AGE_VERIFIED` hook stays landed and inert for a future driven
/// session. The S28 `UITEST_QUIZ` direct mount is NOT this smoke's vehicle: its
/// pure-composition quiz carries `.disabled` analytics and no completion seam —
/// the funnel events and the summary are unreachable on that path BY DESIGN.
///
/// TAIL-A (test-suite §1.4 "eachStepFiresEvent") rides the a11y read bridge:
/// `UITEST_EVENT_SPY=1` arms the consent-honest DebugEventSpySink decorator
/// (R25.9/Architect-P6, unit-pinned in DebugEventSpyTests) and the hidden
/// `debug.eventSpy` element exposes the ordered post-consent wire names. The
/// expected sequence is authored from the PINS, not the doc string
/// (QuizFlowModelTests:110 — the minimal path's visible slots; S19-R1 — slots
/// 1–2 + onboarding_started fire pre-consent and are gate-swallowed; slot 12
/// is quit-path-conditional and never renders here; 14 is the summary, not a
/// step event): quiz_step_completed 3,4,5,6,7,8,9,10,11,13 → quiz_completed →
/// paywall_viewed.
///
/// ── SCENARIO-29 RE-LAND · PRE-WORDED VALVE v2 (fires WITHOUT a re-vote) ────
/// This smoke rides the GREEN run only (audit-style, first-run-is-evidence —
/// R28.6). If it fails its ONE allowed CI run (the a11y-bridge XCUITest READ
/// path is the unproven half — R25.9), it is REMOVED in the same session's
/// contingency commit WITH the failed run's test-outputs artifact as the
/// diagnosis input; Tail-A stays fully unit-pinned (DebugEventSpyTests), the
/// mount chain stays covered by the unit routing pins + the a11y-audit quiz
/// leg, and the UITEST_QUIZ / UITEST_PAYWALL / UITEST_EVENT_SPY hooks stay
/// landed and DEBUG-inert for the next attempt. No DoD obligation goes unmet.
/// DEFERRED BY NAME with this valve: (a) nothing — the driven gate leg is IN;
/// (b) the startIfNeeded no-retry repair (R29.4, a §9-owner decision);
/// (c) the goldens batch (operator §3-gated, unchanged).
/// ───────────────────────────────────────────────────────────────────────────
@MainActor
final class QuizFunnelUITests: XCTestCase {

    func test_quizFunnel_freshInstall_gateToSummary_toPaywallMount() {
        let app = XCUIApplication()
        app.launchEnvironment["UITEST_RESET"] = "1"
        // The paywall mount hook (R24.1/R25.9): a keyless CI build constructs
        // no entitlement model, so the CTA falls through unless the DEBUG
        // render engages — "1" = the HARD variant, the shipping fallback arm.
        app.launchEnvironment["UITEST_PAYWALL"] = "1"
        // Tail-A: arm the consent-honest spy + its bridge (R29.5; DEBUG-inert
        // hook, the UITEST_* family).
        app.launchEnvironment["UITEST_EVENT_SPY"] = "1"
        app.launch()

        // ── The age gate, driven for REAL (artifact-rehabilitated: the wheel
        // adjust + tap were PROVEN working in run 29205964725; S18-owed
        // diagnostics kept). ─────────────────────────────────────────────────
        let wheel = app.pickerWheels.firstMatch
        XCTAssertTrue(wheel.waitForExistence(timeout: 10), "the age gate renders first (E5.1)")
        wheel.adjust(toPickerWheelValue: "1990")
        if (wheel.value as? String)?.contains("1990") != true {
            attach(app, name: "gate-wheel-first-adjust-missed")
            wheel.adjust(toPickerWheelValue: "1990") // ONE bounded retry (S18-owed)
        }
        XCTAssertTrue(
            (wheel.value as? String)?.contains("1990") == true,
            "the wheel adjust took (verified value, one retry — the S25-proven drive)"
        )
        let gateContinue = app.buttons["ageGate.continue"]
        XCTAssertTrue(gateContinue.waitForExistence(timeout: 5), "the gate CTA exists")
        XCTAssertTrue(
            waitForEnabled(gateContinue, timeout: 10),
            "the gate CTA enables after a valid year (bounded, sleep-free)"
        )
        attach(app, name: "gate-before-continue")
        gateContinue.tap()

        // ── The hand-off, RE-ANCHORED (the LEG-1 fix): quiz.continue is the
        // real element anchor — quiz.flow never surfaces (Session 09). ───────
        let quizContinue = app.buttons["quiz.continue"]
        XCTAssertTrue(
            quizContinue.waitForExistence(timeout: 15),
            "past the gate the quiz mounts — anchored on the surfacing Continue button, not the dead container id"
        )
        attach(app, name: "on-quiz")

        // ── The quiz: forced picks + the E8.2 consent step, optionals skipped.
        // Consent taps OPT-IN (slot 3, write-at-tap): it unlocks the gate so
        // the funnel fires are real on this drive, and it exercises the
        // consented funnel (S25's load-bearing catch — the S18 file predated
        // the consent step and would hang there). Chip ids are unique to their
        // steps (shipping quizConfig), so first-existing-hittable is exact.
        let orderedPicks = [
            "quiz.choice.vape",   // habit (slot 1)
            "quiz.choice.optIn",  // consent (slot 3, E8.2)
            "quiz.choice.daily",  // frequency (slot 4)
            "quiz.choice.y1to3",  // duration (slot 6)
            "quiz.choice.first",  // priorAttempts (slot 8)
            "quiz.choice.quit",   // goal (slot 11)
        ]
        for _ in 0..<11 { // the visible-step count on this path (13 slots − 2 hidden conditionals)
            guard quizContinue.waitForExistence(timeout: 5) else { break }
            if !quizContinue.isEnabled {
                for chipID in orderedPicks {
                    let chip = app.buttons[chipID]
                    if chip.exists && chip.isHittable {
                        chip.tap()
                        break
                    }
                }
            }
            XCTAssertTrue(quizContinue.isEnabled, "Continue is tappable after the forced pick")
            quizContinue.tap()
        }

        // ── The summary, RE-ANCHORED on its surfacing CTA (summary.card is a
        // nested container — Session 09). Rendered BEFORE any paywall, always
        // (P0 story 1). ──────────────────────────────────────────────────────
        let summaryCTA = app.buttons["summary.cta"]
        XCTAssertTrue(
            summaryCTA.waitForExistence(timeout: 10),
            "completion mounts the personalized summary — its forward CTA surfaces"
        )
        attach(app, name: "on-summary")
        let paywallShaped = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier CONTAINS[c] 'paywall'"))
        XCTAssertEqual(
            paywallShaped.count, 0,
            "NO paywall surface exists anywhere before or on the summary (MVP §6: summary first)"
        )

        // ── Tail-A read #1 (pre-CTA): the consent-honest funnel through the
        // summary — slots 3…13 (12 is quit-path-hidden; 1 + onboarding_started
        // fired pre-consent and were gate-swallowed), then the summary's
        // quiz_completed. Authored from the pins (QuizFlowModelTests:110,
        // S19-R1) — the doc's "1…14" names the canonical DOMAIN, not the
        // observable sequence. ───────────────────────────────────────────────
        let bridge = app.descendants(matching: .any)
            .matching(identifier: "debug.eventSpy").firstMatch
        XCTAssertTrue(
            bridge.waitForExistence(timeout: 5),
            "the armed spy exposes its bridge element (R29.5 — the unproven READ half's first evidence)"
        )
        let expectedThroughSummary = [
            "quiz_step_completed:3", "quiz_step_completed:4", "quiz_step_completed:5",
            "quiz_step_completed:6", "quiz_step_completed:7", "quiz_step_completed:8",
            "quiz_step_completed:9", "quiz_step_completed:10", "quiz_step_completed:11",
            "quiz_step_completed:13", "quiz_completed",
        ].joined(separator: ",")
        XCTAssertEqual(
            bridge.value as? String, expectedThroughSummary,
            "eachStepFiresEvent, consent-honest half 1: the post-consent slots fire in order, once each, and the summary fires quiz_completed"
        )

        // ── The E7 seam: CTA → the paywall MOUNT (Tail-B), RE-ANCHORED on the
        // surfacing subscribe CTA (paywall.card is a nested container). ──────
        summaryCTA.tap()
        let paywallCTA = app.buttons["paywall.cta"]
        XCTAssertTrue(
            paywallCTA.waitForExistence(timeout: 10),
            "the summary CTA mounts the paywall (the S24 bundled screen; hard variant under UITEST_PAYWALL=1)"
        )
        attach(app, name: "on-paywall")
        XCTAssertTrue(app.buttons["paywall.restore"].exists, "restore is reachable (never-trap, Epic 7 DoD)")
        XCTAssertFalse(
            app.buttons["paywall.teaser.escape"].exists,
            "the HARD variant is close-free — no escape affordance (R24.9 carried)"
        )
        XCTAssertFalse(summaryCTA.exists, "the summary is behind us")

        // ── Tail-A read #2 (post-mount): the presentation fire lands last —
        // the debug render fires the REAL consent-gated paywall_viewed
        // (PostGateRootView.presentDebugPaywall; R25.5). ─────────────────────
        XCTAssertEqual(
            bridge.value as? String, expectedThroughSummary + ",paywall_viewed",
            "eachStepFiresEvent, half 2: the paywall mount appends exactly one paywall_viewed"
        )
    }

    /// Bounded, sleep-free enabled-wait (the §7-sanctioned idiom).
    private func waitForEnabled(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "isEnabled == true"), object: element
        )
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    /// Stage-boundary screenshot, deleted on success (cheap green runs; a
    /// flake ships the picture — the S18-owed diagnostic).
    private func attach(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .deleteOnSuccess
        add(attachment)
    }
}
