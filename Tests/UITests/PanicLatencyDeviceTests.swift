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
    /// S48 — the CONTROL the spike never had, and without which its number cannot
    /// be read.
    ///
    /// The first real device run (iPhone 17 Pro Max, Debug) produced samples
    /// 2467–2505 ms with the single first-launch outlier at 6609 — nine samples
    /// inside a 38 ms band. Cold-launch work does not have 38 ms of variance;
    /// a hard floor with near-zero spread is the signature of a FIXED COST, and
    /// the fixed cost is inside the measurement window: `XCUIApplication.launch()`
    /// is not a bare process spawn, it also performs XCTest's automation-session
    /// attach and accessibility/quiescence handshake before it returns.
    ///
    /// So the headline number is `harness overhead + app work`, and the spike
    /// question is only about app work. This control measures a NORMAL launch
    /// (no `FORCE_PANIC_ROUTE`) through the byte-identical harness, so the fixed
    /// term cancels: the panic path's true cost is `panic − normal`.
    ///
    /// It asserts nothing. It exists so the operator (and E3.1, which graduates
    /// this file into a permanent CI gate) reads a real delta rather than a
    /// number dominated by XCTest. Gating CI on the raw figure would pin the
    /// harness's own latency, not the product's.
    func test_normalColdLaunch_controlBaseline_forPanicDelta() throws {
        #if targetEnvironment(simulator)
        throw XCTSkip(
            "E0.3 spike is physical-device-only (operator-run). See docs/spike-panic-latency.md."
        )
        #else
        var samplesMS: [Double] = []
        for iteration in 1...10 {
            let app = XCUIApplication()
            app.terminate()
            Thread.sleep(forTimeInterval: 2.0)

            // The ONE difference from the panic run: no FORCE_PANIC_ROUTE.
            let start = Date()
            app.launch()
            // Wait on the app's FIRST frame rather than a specific screen: the
            // post-gate route depends on persisted state, so keying on any one
            // identifier would measure a different thing on a seeded device than
            // on a fresh one. `any element exists` is the earliest honest
            // "the app is on screen" signal, and it is the same signal the panic
            // run waits for — one identifier deeper.
            let visible = app.descendants(matching: .any)
                .firstMatch
                .waitForExistence(timeout: 5)
            let elapsedMS = Date().timeIntervalSince(start) * 1000
            XCTAssertTrue(visible, "Iteration \(iteration): the app never presented a first frame")
            samplesMS.append(elapsedMS)
        }

        let sorted = samplesMS.sorted()
        print("CONTROL-LAUNCH SAMPLES (ms): \(samplesMS.map { String(format: "%.0f", $0) }.joined(separator: ", "))")
        print("CONTROL-LAUNCH P90 (ms): \(String(format: "%.0f", sorted[8]))")
        print("CONTROL-LAUNCH MIN (ms): \(String(format: "%.0f", sorted[0]))")
        #endif
    }

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
