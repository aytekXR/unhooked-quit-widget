import XCTest

/// E0.3 panic-latency spike harness (doc-canonical test name, implementation-plan E0.3).
///
/// This test is ALLOWED TO FAIL initially — it *is* the spike question. It runs only
/// on a physical device (simulator numbers lie about cold launch; test-suite §1.5)
/// and is executed by the operator per docs/spike-panic-latency.md. It graduates to
/// a permanent CI gate in E3.1 with the threshold the spike verdict sets.
///
/// Measurement caveat (documented in the spike doc): XCUITest cannot tap a real
/// lock-screen widget. This harness measures process-launch → panic-frame-visible
/// with the panic route forced, which is the app-owned share of the ADR-6 budget.
/// The full lock-to-intervention number (including the OS's intent→launch phase)
/// is measured manually with Instruments signposts (subsystem
/// "com.beyondkaira.ballast", category "PanicLaunch", interval "PanicColdLaunch").
@MainActor
final class PanicLatencyDeviceTests: XCTestCase {
    func test_panicColdLaunch_signpost_under2000ms() throws {
        #if targetEnvironment(simulator)
        throw XCTSkip(
            "E0.3 spike is physical-device-only (operator-run). See docs/spike-panic-latency.md."
        )
        #else
        var samplesMS: [Double] = []
        for iteration in 1...10 {
            let app = XCUIApplication()
            app.terminate()
            // Give the OS a moment to tear the process down between iterations.
            Thread.sleep(forTimeInterval: 2.0)

            app.launchEnvironment["FORCE_PANIC_ROUTE"] = "1"
            let start = Date()
            app.launch()
            let visible = app.descendants(matching: .any)
                .matching(identifier: "root.panicPlaceholder")
                .firstMatch
                .waitForExistence(timeout: 5)
            let elapsedMS = Date().timeIntervalSince(start) * 1000
            XCTAssertTrue(visible, "Iteration \(iteration): panic placeholder never appeared")
            samplesMS.append(elapsedMS)
        }

        let sorted = samplesMS.sorted()
        let p90 = sorted[8] // 9th of 10 — p90 per test-suite §1.5 test 37
        // Record every sample so the operator can transcribe them into the spike doc.
        print("PANIC-LATENCY SAMPLES (ms): \(samplesMS.map { String(format: "%.0f", $0) }.joined(separator: ", "))")
        print("PANIC-LATENCY P90 (ms): \(String(format: "%.0f", p90))")
        XCTAssertLessThan(
            p90, 2000,
            "p90 lock-to-intervention must be <2.0s cold (MVP §7 product gate; spike verdict decides copy)"
        )
        #endif
    }
}
