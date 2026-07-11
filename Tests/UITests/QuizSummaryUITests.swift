import XCTest

/// E5.3 — the scenario-29 partial (QA ruling e, Session 18, operator-vetoable):
/// the Epic-5 DoD's "XCUITest runs the full quiz→summary path", minimal
/// single-tap form — gate (wheel to a passing year) → the five forced
/// singleChoice picks → Continue through everything optional UNANSWERED (so the
/// summary exercises its absent-variants live) → the summary renders BEFORE any
/// paywall surface → the CTA falls to the placeholder dashboard (the named E7
/// seam's this-session behavior). The paywall tail stays E7's; if this drive
/// proves non-deterministic it DEFERS to the E7 session per the recorded valve.
/// Assertions on anchors/text only (the Session 09 lesson — never `.contain`
/// containers); route anchors via `descendants(matching: .any)` (the
/// WalkingSkeleton idiom — element type stays unpinned).
@MainActor
final class QuizSummaryUITests: XCTestCase {

    func test_minimalPath_gateToQuiz_toSummary_beforeAnyPaywall_thenDashboard() {
        let app = XCUIApplication()
        // Self-isolation in the shared CI simulator (green critic F1): this test
        // both REQUIRES a fresh install (the gate wheel) and leaves a real quit
        // behind — the reset hook makes it order-independent as the UITest suite
        // grows (E6/E7 smokes are imminent).
        app.launchEnvironment["UITEST_RESET"] = "1"
        app.launch()

        // ── The age gate: wheel to a passing year, continue. ────────────────
        let wheel = app.pickerWheels.firstMatch
        XCTAssertTrue(
            wheel.waitForExistence(timeout: 10),
            "fresh launch lands on the age gate's year wheel"
        )
        wheel.adjust(toPickerWheelValue: "1990")
        let gateContinue = app.buttons["ageGate.continue"]
        XCTAssertTrue(gateContinue.waitForExistence(timeout: 5))
        gateContinue.tap()

        // ── The quiz: forced picks tapped, everything else skipped. ─────────
        // Path (habit=vape, goal=quit — conditionals hidden) has 10 visible
        // steps. A DISABLED Continue is the forced-singleChoice signal (the
        // quiz never nudges; only singleChoice steps gate the button) — tap the
        // path's one on-screen chip, then Continue. Optional steps (spend,
        // triggers, motivations, effects, commitment) continue unanswered, so
        // the summary renders its absent-variants live.
        let quizContinue = app.buttons["quiz.continue"]
        let orderedPicks = [
            "quiz.choice.vape",   // habit
            "quiz.choice.daily",  // frequency
            "quiz.choice.y1to3",  // duration
            "quiz.choice.first",  // priorAttempts
            "quiz.choice.quit",   // goal
        ]
        XCTAssertTrue(
            app.descendants(matching: .any).matching(identifier: "quiz.flow").firstMatch
                .waitForExistence(timeout: 10),
            "a passing year lands on the quiz"
        )
        for _ in 0..<10 { // bounded walk — exactly the visible-step count
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
        XCTAssertTrue(app.buttons["summary.cta"].exists, "the single forward CTA is present")
        XCTAssertFalse(
            app.descendants(matching: .any).matching(identifier: "quiz.flow").firstMatch.exists,
            "the quiz is behind us"
        )
        let paywallShaped = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier CONTAINS[c] 'paywall'"))
        XCTAssertEqual(
            paywallShaped.count, 0,
            "NO paywall surface exists anywhere before or on the summary (E7's)"
        )

        // ── The named seam, this session: CTA → the placeholder dashboard. ──
        app.buttons["summary.cta"].tap()
        XCTAssertTrue(
            app.buttons["root.panicEntry"].waitForExistence(timeout: 10),
            "the seam falls to the placeholder dashboard (E7 remaps it to the paywall)"
        )
    }
}
