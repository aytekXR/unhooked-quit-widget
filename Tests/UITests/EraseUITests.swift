import XCTest

/// E2.4 UI-smoke lane. Doc-canonical test name from implementation-plan.md E2.4.
///
/// Scope note (resume-prompt v1.9): onboarding does not exist yet — the fresh-install
/// root placeholder (`root.placeholder`) is exactly where onboarding mounts in E5, so
/// the pin is route-level: after an erase, the app lands on the fresh-install root and
/// NEVER on the panic route. The discriminator is real erased state: the launch hook
/// (`UITEST_SEED_PANIC_THEN_ERASE`) seeds a pending panic launch flag in the App Group
/// and then runs the production local-erase helper — if erase fails to clear App Group
/// state, the seeded flag routes this very launch to the panic placeholder and the
/// test fails.
///
/// Load-bearing map (spec-review ruling, Session 08): launch A's `root.placeholder`
/// assertion is the SOLE route-level red/green discriminator in this smoke — do not
/// soften it. Launch B cannot discriminate (a panic-route launch A would itself clear
/// the flag via the placeholder's onAppear), so B is a fresh-relaunch durability
/// sanity check only. File-set/defaults/witness deletion proofs live in the unit lane
/// (EraseEverythingTests) — those are the real erase pins.
@MainActor
final class EraseUITests: XCTestCase {
    func test_erase_appRelaunch_startsAtOnboarding() {
        // Launch A: seed a panic flag, then erase, then route — erased state must
        // resolve to the fresh-install root, not the seeded panic route.
        let app = XCUIApplication()
        app.launchEnvironment["UITEST_SEED_PANIC_THEN_ERASE"] = "1"
        app.launch()
        let root = app.descendants(matching: .any)
            .matching(identifier: "root.placeholder")
            .firstMatch
        XCTAssertTrue(
            root.waitForExistence(timeout: 15),
            "Erased state must land on the fresh-install root — a surviving panic flag means erase did not clear App Group state (E2.4)"
        )
        app.terminate()

        // Launch B: a plain relaunch of the erased install = fresh install (§10:
        // "relaunch state = fresh install"), on the root where onboarding mounts.
        let relaunch = XCUIApplication()
        relaunch.launch()
        let freshRoot = relaunch.descendants(matching: .any)
            .matching(identifier: "root.placeholder")
            .firstMatch
        XCTAssertTrue(
            freshRoot.waitForExistence(timeout: 15),
            "Relaunch after erase must start at the fresh-install (onboarding) root"
        )
        XCTAssertFalse(
            relaunch.descendants(matching: .any)
                .matching(identifier: "root.panicPlaceholder").firstMatch.exists,
            "No erased artifact may route a fresh install into the panic path"
        )
    }
}
