import XCTest

/// E3.1 UI-smoke lane: the panic route resolves its content from the App Group
/// pre-cache — never the store (ADR-6). A seeded multi-quit snapshot with no
/// selection must land on the quit picker (placeholder-grade; the real flow UI is
/// E3.2). This is the one smoke that exercises the real wiring end to end:
/// seed hook → snapshot read in `UnhookedApp.init` → resolver → picker rendering.
/// The selection matrix itself is pinned at the unit tier (PanicPathTests).
@MainActor
final class PanicRouteUITests: XCTestCase {
    func test_panicRoute_seededSnapshot_showsQuitPicker() {
        let app = XCUIApplication()
        app.launchEnvironment["FORCE_PANIC_ROUTE"] = "1"
        app.launchEnvironment["UITEST_SEED_PANIC_SNAPSHOT"] = "1"
        app.launch()

        let picker = app.descendants(matching: .any)
            .matching(identifier: "panic.quitPicker")
            .firstMatch
        XCTAssertTrue(
            picker.waitForExistence(timeout: 15),
            "A panic launch with several cached quits and no selection must show the quit picker (E3.1)"
        )
        XCTAssertFalse(
            app.descendants(matching: .any)
                .matching(identifier: "root.placeholder").firstMatch.exists,
            "The picker renders inside the panic route — never the normal hierarchy (ADR-6)"
        )
    }
}
