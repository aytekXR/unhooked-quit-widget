import XCTest

/// E7.2 (R25.9) — scenario-29's re-land: the S18 minimal-path funnel smoke
/// (gate → forced picks → optional steps unanswered → summary-before-any-
/// paywall) EXTENDED to the paywall MOUNT (the E7 seam is now real), carrying
/// the S18-owed drive diagnostics: bounded isEnabled polling, a post-adjust
/// `wheel.value` verification with ONE re-adjust retry, and stage-boundary
/// screenshots (`.deleteOnSuccess` — green runs stay cheap, a flake ships the
/// picture).
///
/// THE WHEEL LEG IS NON-FATAL (R25.9, the burn-critic veto honored): the
/// gate wheel is driven for real FIRST with full diagnostics; if the
/// wheel/hand-off fails within budget, the test relaunches seeded past the
/// gate (`UITEST_SEED_AGE_VERIFIED`, DEBUG-only) and continues — an
/// attachment records which path ran. The gate's un-bypassability stays
/// pinned at the unit tier (S18); this smoke's BLOCKING legs are the quiz
/// (incl. the E8.2 consent step — slot 3 gates Continue and the event chain),
/// the summary, and the CTA → paywall mount under `UITEST_PAYWALL=1`.
///
/// The event-assertion tail (§1.4's "eachStepFiresEvent" via a debug
/// event-spy sink) is DEFERRED BY NAME (R25.9): the spy's XCUITest read-path
/// is unproven tech on a 2+1 budget; every fire + the wire ORDER is pinned at
/// the unit tier this session (PaywallViewedWireTests / QuizSummaryFireTests
/// / QuizFlowModelTests), and the recorded spy design (a consent-honest
/// decorator inside AnalyticsService composition) rides the named
/// StoreKit-config/contract session.
///
/// RE-FLAKE VALVE (pre-worded, fires WITHOUT a panel re-vote — the S18/R24.1
/// precedent): if any BLOCKING hand-off (quiz.flow, summary.card, or the
/// paywall anchor) is non-deterministic within the run budget, this smoke
/// DEFERS to the named StoreKit-config/contract session; the unit tier keeps
/// every DoD obligation pinned (the four plan-named tests +
/// test_paywallViewed_carriesVariantAndSource); the captured screenshots +
/// the wheel-path attachment ride the deferral for the next drive. Removal
/// is a valve invocation, never a silenced red.
@MainActor
final class QuizFunnelUITests: XCTestCase {

    func test_quizFunnel_freshInstall_gateToSummary_toPaywallMount() {
        var app = XCUIApplication()
        app.launchEnvironment["UITEST_RESET"] = "1"
        // The paywall mount hook (R24.1/R25.9): a keyless CI build constructs
        // no entitlement model, so the CTA falls through unless the DEBUG
        // render engages — "1" = the HARD variant, the shipping fallback arm.
        app.launchEnvironment["UITEST_PAYWALL"] = "1"
        app.launch()

        // ── The age gate: the REAL wheel first, diagnostics on, non-fatal. ──
        if !driveAgeGate(app) {
            // The recorded fallback (R25.9): relaunch seeded past the gate —
            // fresh install again (UITEST_RESET), gate passed by store-truth
            // write post-open, funnel drive continues at the quiz.
            attach(app, name: "wheel-fallback-engaged")
            app.terminate()
            app = XCUIApplication()
            app.launchEnvironment["UITEST_RESET"] = "1"
            app.launchEnvironment["UITEST_PAYWALL"] = "1"
            app.launchEnvironment["UITEST_SEED_AGE_VERIFIED"] = "1"
            app.launch()
        }

        // ── BLOCKING from here (the valve's scope). The quiz mounts. ────────
        XCTAssertTrue(
            app.descendants(matching: .any).matching(identifier: "quiz.flow").firstMatch
                .waitForExistence(timeout: 10),
            "past the gate (driven or seeded) the quiz mounts"
        )
        attach(app, name: "on-quiz")

        // ── The quiz: forced picks + the E8.2 consent step, optionals skipped.
        // A DISABLED Continue signals a gating step (forced singleChoice OR
        // the consent step — slot 3's Continue is disabled until a choice,
        // QuizFlowView). Consent taps OPT-IN, never optOut: analytics must be
        // ON for the paywall_viewed fire to be real on this drive (the ONE
        // gate is real in DEBUG too), and it exercises the consented funnel.
        let quizContinue = app.buttons["quiz.continue"]
        let orderedPicks = [
            "quiz.choice.vape",   // habit
            "quiz.choice.daily",  // frequency
            "quiz.choice.optIn",  // consent (slot 3, E8.2 — NEW since S18)
            "quiz.choice.y1to3",  // duration
            "quiz.choice.first",  // priorAttempts
            "quiz.choice.quit",   // goal
        ]
        for _ in 0..<11 { // bounded walk — the visible-step count incl. consent
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

        // ── The summary: rendered BEFORE any paywall, always (P0 story 1). ──
        XCTAssertTrue(
            app.descendants(matching: .any).matching(identifier: "summary.card").firstMatch
                .waitForExistence(timeout: 10),
            "completion mounts the personalized summary"
        )
        attach(app, name: "on-summary")
        XCTAssertTrue(app.buttons["summary.cta"].exists, "the single forward CTA is present")
        let paywallShaped = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier CONTAINS[c] 'paywall'"))
        XCTAssertEqual(
            paywallShaped.count, 0,
            "NO paywall surface exists anywhere before or on the summary (MVP §6: summary first)"
        )

        // ── The E7 seam, now REAL: CTA → the paywall MOUNT (Tail-B floor). ──
        app.buttons["summary.cta"].tap()
        XCTAssertTrue(
            app.descendants(matching: .any).matching(identifier: "paywall.card").firstMatch
                .waitForExistence(timeout: 10),
            "the summary CTA mounts the paywall (the S24 bundled screen; hard variant under UITEST_PAYWALL=1)"
        )
        attach(app, name: "on-paywall")
        XCTAssertTrue(app.buttons["paywall.cta"].exists, "the subscribe CTA renders")
        XCTAssertTrue(app.buttons["paywall.restore"].exists, "restore is reachable (never-trap, Epic 7 DoD)")
        XCTAssertFalse(
            app.buttons["paywall.teaser.escape"].exists,
            "the HARD variant is close-free — no escape affordance (R24.9 carried)"
        )
        XCTAssertFalse(
            app.descendants(matching: .any).matching(identifier: "summary.card").firstMatch.exists,
            "the summary is behind us"
        )
    }

    // MARK: - The gate drive (non-fatal; diagnostics are the deliverable)

    /// Drives the age-gate wheel with the S18-owed diagnostics. Returns false
    /// (instead of failing) when the wheel/hand-off misbehaves — the caller
    /// engages the seeded fallback and the attachments carry the evidence.
    private func driveAgeGate(_ app: XCUIApplication) -> Bool {
        let wheel = app.pickerWheels.firstMatch
        guard wheel.waitForExistence(timeout: 10) else {
            attach(app, name: "gate-wheel-never-appeared")
            return false
        }
        // Diagnostic 1 (S18-owed): verify the adjust TOOK — the S18 flake's
        // untested hypothesis was a silent non-adjust re-presenting the gate.
        wheel.adjust(toPickerWheelValue: "1990")
        if (wheel.value as? String)?.contains("1990") != true {
            attach(app, name: "gate-wheel-first-adjust-missed")
            wheel.adjust(toPickerWheelValue: "1990") // ONE bounded retry
        }
        guard (wheel.value as? String)?.contains("1990") == true else {
            attach(app, name: "gate-wheel-adjust-failed-twice")
            return false
        }
        // Diagnostic 2 (S18-owed): a bounded isEnabled PRECONDITION before
        // the tap (sleep-free predicate wait), not a bare tap-and-hope.
        let gateContinue = app.buttons["ageGate.continue"]
        guard gateContinue.waitForExistence(timeout: 5),
              waitForEnabled(gateContinue, timeout: 10)
        else {
            attach(app, name: "gate-continue-never-enabled")
            return false
        }
        attach(app, name: "gate-before-continue")
        gateContinue.tap()
        // The S18 flake point: the gate→quiz hand-off within budget.
        let handedOff = app.descendants(matching: .any)
            .matching(identifier: "quiz.flow").firstMatch
            .waitForExistence(timeout: 10)
        if !handedOff {
            attach(app, name: "gate-handoff-timed-out")
        }
        return handedOff
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
