import SnapshotTesting
import StreakEngine
import SwiftUI
import Testing
import UIKit
@testable import Unhooked

// E4.1 — the slip flow's snapshot matrix, mirroring PanicFlowSnapshotTests exactly
// (test-suite §3.3: light + dark × default + AX5 Dynamic Type; per-pixel 1% tolerance
// on a 99% pixel floor; geometry pinned via ViewImageConfig(.iPhone13) so the booted
// simulator only supplies the OS runtime). The forgiveness screen is where the brand's
// "a slip is data, not a verdict" copy lives, so the goldens render the SHIPPING
// slipCopy.json (brand review happens on these images).
//
// References are recorded ON CI (`record: .missing` fails-while-writing on first run;
// the Linux dev box cannot render), retrieved from the `test-outputs` artifact, and
// committed — the §3.3 re-record discipline applies from then on.
//
// Determinism: a frozen clock, stable fixture UUIDs, a throwaway temp-dir buffer, and
// the undo banner's phase-zero latch (SlipFlowView's `.task`-set `started`, which never
// runs during a synchronous snapshot capture — the BreathBloom `startedAt == nil`
// precedent) so the banner renders unconditionally-live at the frozen date.

@MainActor
@Suite(.snapshots(record: .missing))
struct SlipFlowSnapshotTests {

    // MARK: - Fixtures (stable IDs and content — snapshots must be byte-reproducible)

    private static let quitID = UUID(uuidString: "0E32C0DE-0000-4000-8000-0000000005A1")!
    private static let epoch = Date(timeIntervalSince1970: 1_783_425_600) // 2026-07-07T12:00:00Z
    private static let day = 86_400
    private static let baseUptime: TimeInterval = 5_000_000 // ~57.8d headroom over the streaks below
    private static let bootA = UUID(uuidString: "0B00071D-A000-4000-8000-000000000001")!

    private func shippingCopy() throws -> SlipCopy {
        try #require(
            SlipCopy.loadShipping(),
            "the shipping slipCopy.json must be bundled — the goldens render the REAL forgiveness copy"
        )
    }

    /// A pre-cache card with the E4.1 additive streak fields populated (the framing
    /// source). Legacy/degraded cards pass the additive fields nil.
    private func card(
        discreet: Bool = false,
        motivations: [String] = ["family"],
        startAt: Date? = epoch,
        anchorUptime: TimeInterval? = baseUptime,
        bestStreakSeconds: Int? = 0,
        momentumPercent: Int? = nil
    ) -> QuitSnapshot {
        QuitSnapshot(
            id: Self.quitID,
            label: discreet ? nil : "Vaping",
            discreet: discreet,
            motivations: motivations,
            startAt: startAt,
            anchorBootID: startAt == nil ? nil : Self.bootA,
            anchorUptime: anchorUptime,
            bestStreakSeconds: bestStreakSeconds,
            momentumPercent: momentumPercent
        )
    }

    private func makeTempDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("e41-slip-snap-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    /// A cold-route SlipFlowModel over a REAL buffer + witness in throwaway locations and
    /// a frozen clock (the store never opens on this route). `forceAppendFailure` points
    /// the buffer at an existing FILE so every append throws — the retry-note fixture.
    private func makeCold(
        card: QuitSnapshot,
        copy: SlipCopy,
        forceAppendFailure: Bool = false
    ) throws -> SlipFlowModel {
        let dir = try makeTempDir()
        let bufferDirectory: URL
        if forceAppendFailure {
            let occupied = dir.appendingPathComponent("occupied", isDirectory: false)
            try Data().write(to: occupied)
            bufferDirectory = occupied
        } else {
            bufferDirectory = dir
        }
        let buffer = PanicOutcomeBuffer(directoryURL: bufferDirectory)
        let witness = LastKnownGoodStore(defaults: UserDefaults(suiteName: "e41-snap-lkg-\(UUID().uuidString)")!)
        return SlipFlowModel(
            route: .cold(
                handoff: PanicSlipHandoff(quitID: card.id, source: .lockscreenWidget, stepsReached: []),
                card: card,
                buffer: buffer,
                witnessStore: witness
            ),
            copy: copy,
            clock: SnapshotFrozenClock()
        )
    }

    /// The §3.3 axes for one screen: light + dark × default + AX5.
    private func assertSlipScreen(
        _ model: SlipFlowModel,
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
                of: SlipFlowView(model: model, clock: SnapshotFrozenClock()),
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

    // MARK: - Confirm stage

    @Test func snapshot_confirmStage() throws {
        // Tap 1: "Log a slip?" — confirm + "Not now", zero-shame body.
        try assertSlipScreen(makeCold(card: card(), copy: shippingCopy()))
    }

    @Test func snapshot_confirmStage_retryNote() throws {
        // A failed durable write keeps the confirm stage with the calm retry note
        // (§9 rule 1: "Logged." is never claimed without durable bytes). Never red.
        let model = try makeCold(card: card(), copy: shippingCopy(), forceAppendFailure: true)
        model.confirm()
        assertSlipScreen(model)
    }

    @Test func snapshot_confirmStage_discreet() throws {
        // A discreet card carries zero habit context (the strings already carry none).
        try assertSlipScreen(makeCold(card: card(discreet: true), copy: shippingCopy()))
    }

    // MARK: - Logged (forgiveness) stage

    @Test func snapshot_loggedStage_bestAndMomentum() throws {
        // A 3-day streak archived under a 10-day best, momentum unchanged at 42% — the
        // full forgiveness screen + neutral undo banner + motivation echo (SF Pro).
        let model = try makeCold(
            card: card(
                startAt: Self.epoch - TimeInterval(3 * Self.day),
                anchorUptime: Self.baseUptime - TimeInterval(3 * Self.day),
                bestStreakSeconds: 10 * Self.day,
                momentumPercent: 42
            ),
            copy: shippingCopy()
        )
        model.confirm()
        assertSlipScreen(model)
    }

    @Test func snapshot_loggedStage_degradedNoBest() throws {
        // A stale pre-E4.1 cache (additive fields nil): best 0 → the no-best copy,
        // momentum nil → no number invented, no motivation echo.
        let model = try makeCold(
            card: card(motivations: [], startAt: nil, anchorUptime: nil, bestStreakSeconds: nil),
            copy: shippingCopy()
        )
        model.confirm()
        assertSlipScreen(model)
    }

    // MARK: - Undone stage

    @Test func snapshot_undoneStage() throws {
        // In-window undo → "Undone. Your streak is right where it was."
        let model = try makeCold(card: card(), copy: shippingCopy())
        model.confirm()
        model.undo() // still inside the window (the frozen clock never advanced)
        assertSlipScreen(model)
    }
}

/// Frozen clock for deterministic renders (no wall reads on the snapshot path). Uptime
/// carries multi-day headroom so a multi-day streak's anchor stays physical.
@MainActor
private final class SnapshotFrozenClock: ClockProviding {
    let now = Date(timeIntervalSince1970: 1_783_425_600) // 2026-07-07T12:00:00Z (§3.2 epoch)
    let monotonicNow = MonotonicNow(
        bootID: UUID(uuidString: "0B00071D-A000-4000-8000-000000000001")!,
        uptime: 5_000_000
    )
}
