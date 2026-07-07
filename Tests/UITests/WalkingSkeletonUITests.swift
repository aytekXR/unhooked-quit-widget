import XCTest

/// E0.1 UI-smoke lane. Doc-canonical test name from implementation-plan.md E0.1.
@MainActor
final class WalkingSkeletonUITests: XCTestCase {
    /// The app must launch to a root view carrying accessibility id `root.placeholder`.
    func test_walkingSkeleton_appLaunches() {
        let app = XCUIApplication()
        app.launch()

        let root = app.descendants(matching: .any)
            .matching(identifier: "root.placeholder")
            .firstMatch
        XCTAssertTrue(
            root.waitForExistence(timeout: 15),
            "App must reach a root view with accessibility id 'root.placeholder' (E0.1)"
        )
    }

    /// Panic route smoke: forcing the panic route must land on the bare panic
    /// placeholder, not the normal root (ADR-6 scene routing, E0.3 harness).
    func test_panicRoute_landsOnPanicPlaceholder() {
        let app = XCUIApplication()
        app.launchEnvironment["FORCE_PANIC_ROUTE"] = "1"
        app.launch()

        let panicRoot = app.descendants(matching: .any)
            .matching(identifier: "root.panicPlaceholder")
            .firstMatch
        XCTAssertTrue(
            panicRoot.waitForExistence(timeout: 15),
            "Panic launches must build the panic placeholder as root (ADR-6)"
        )
        XCTAssertFalse(
            app.descendants(matching: .any).matching(identifier: "root.placeholder").firstMatch.exists,
            "Panic route must skip the normal tab/root hierarchy"
        )
    }
}
