import SnapshotTesting
import StreakEngine
import SwiftUI
import Testing
import UIKit
@testable import Unhooked

// E3.2 — the snapshot lane's first REAL image matrix (it has been a render-free
// smoke since E0.1). Per-step panic screens, light + dark × default + AX5 Dynamic
// Type (test-suite §3.3's bar — AX5 supersedes the plan's looser "XXL"; brandkit's
// release gate is the largest accessibility size), plus the discreet and
// haptics-only variants. Geometry is pinned in-test via ViewImageConfig (.iPhone13)
// so the booted simulator only supplies the OS runtime; perceptual tolerance is
// §3.3's 1% (antialiasing), applied per pixel with a 99% pixel floor.
//
// References are recorded ON CI (`record: .missing` fails-while-writing on first
// run; the Linux dev box cannot render), retrieved from the `test-outputs` artifact,
// and committed — the §3.3 re-record discipline applies from then on.

@MainActor
@Suite(.snapshots(record: .missing))
struct PanicFlowSnapshotTests {

    // MARK: - Fixtures (stable IDs and content — snapshots must be byte-reproducible)

    private static let quitID = UUID(uuidString: "0E32C0DE-0000-4000-8000-000000000001")!

    private func shippingScript() throws -> PanicScript {
        try #require(
            PanicScript.loadShipping(),
            "the shipping panicScript.json must be bundled — the goldens render the REAL copy (brand review happens on these images)"
        )
    }

    private func makeModel(
        discreet: Bool = false,
        hapticsOnlyPacer: Bool = false,
        motivations: [String] = ["For my kids", "money for the trip", "breathe easier"]
    ) throws -> PanicFlowModel {
        let quit = QuitSnapshot(
            id: Self.quitID,
            label: discreet ? nil : "Vaping",
            discreet: discreet,
            motivations: motivations
        )
        return PanicFlowModel(
            quit: quit,
            script: try shippingScript(),
            source: .lockscreenWidget,
            hapticsOnlyPacer: hapticsOnlyPacer,
            clock: SnapshotFrozenClock(),
            haptics: NoopHaptics(),
            buffer: nil,
            onSlipRoute: { _ in }
        )
    }

    /// The §3.3 axes for one screen: light + dark × default + AX5.
    private func assertPanicScreen(
        _ model: PanicFlowModel,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        let axes: [(name: String, dark: Bool, ax5: Bool)] = [
            ("light", false, false),
            ("dark", true, false),
            ("light-ax5", false, true),
            ("dark-ax5", true, true),
        ]
        for axis in axes {
            assertSnapshot(
                of: PanicFlowView(model: model),
                as: .image(
                    precision: 0.99,
                    perceptualPrecision: 0.98,
                    layout: .device(config: .iPhone13),
                    traits: UITraitCollection { traits in
                        traits.userInterfaceStyle = axis.dark ? .dark : .light
                        traits.preferredContentSizeCategory = axis.ax5
                            ? .accessibilityExtraExtraExtraLarge
                            : .large
                    }
                ),
                named: axis.name,
                fileID: fileID,
                file: filePath,
                testName: testName,
                line: line,
                column: column
            )
        }
    }

    // MARK: - Per-step matrix (implementation-plan E3.2: "snapshot tests per step")

    @Test func snapshot_breathStep() throws {
        try assertPanicScreen(makeModel())
    }

    @Test func snapshot_breathStep_hapticsOnly() throws {
        // Haptics-only: static instruction + progress ticks, no bloom (brandkit §6.10).
        try assertPanicScreen(makeModel(hapticsOnlyPacer: true))
    }

    @Test func snapshot_breathStep_discreet() throws {
        // Discreet entry: "Take a moment." + zero habit context anywhere on screen.
        try assertPanicScreen(makeModel(discreet: true))
    }

    @Test func snapshot_timerStep() throws {
        let model = try makeModel()
        model.skip()
        assertPanicScreen(model)
    }

    @Test func snapshot_reasonsStep() throws {
        // The user's own words at type/panicReason — the largest text in the app.
        let model = try makeModel()
        model.skip()
        model.skip()
        assertPanicScreen(model)
    }

    @Test func snapshot_reasonsStep_emptyFallback() throws {
        // No captured motivations → the script's fallback line, never a blank screen.
        let model = try makeModel(motivations: [])
        model.skip()
        model.skip()
        assertPanicScreen(model)
    }

    @Test func snapshot_redirectStep() throws {
        let model = try makeModel()
        model.skip()
        model.skip()
        model.skip()
        assertPanicScreen(model)
    }

    @Test func snapshot_exitsStep() throws {
        let model = try makeModel()
        for _ in 0..<4 { model.skip() }
        assertPanicScreen(model)
    }

    @Test func snapshot_exitsStep_discreet() throws {
        // Discreet exits: "Done" / "Log it" — zero habit context.
        let model = try makeModel(discreet: true)
        for _ in 0..<4 { model.skip() }
        assertPanicScreen(model)
    }

    @Test func snapshot_celebration() throws {
        // The quiet averted celebration: confirmation copy, no confetti, no streak hero.
        let model = try makeModel()
        for _ in 0..<4 { model.skip() }
        model.exitUrgePassed()
        assertPanicScreen(model)
    }
}

/// Frozen clock for deterministic renders (no wall reads on the snapshot path).
@MainActor
private final class SnapshotFrozenClock: ClockProviding {
    let now = Date(timeIntervalSince1970: 1_783_425_600) // 2026-07-07T12:00:00Z (§3.2 epoch)
    let monotonicNow = MonotonicNow(
        bootID: UUID(uuidString: "0B00071D-A000-4000-8000-000000000001")!,
        uptime: 50_000
    )
}

@MainActor
private final class NoopHaptics: HapticsPlaying {
    func playBreathPattern(_ pattern: BreathPacerPattern) {}
    func playCelebrationTap() {}
}
