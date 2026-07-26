import SnapshotTesting
import SwiftUI
import Testing
import UIKit
@testable import Unhooked

// P3 (redesign §5.8 / §6.16, QW-2) — the erase-everything surface's goldens,
// recorded the wave after the surface landed with none: this is the trust
// screen (the honest manifest, the AMBER hold-to-confirm — amber, never red —
// and the quiet "Keep my data" as the easy path), so brand review needs pixels.
//
// Both stages render over an inert `EraseFlow(erase: {}, applyIcon: { _ in })`
// (the #Preview fixture — nothing runs during capture; the hold is never
// driven). The DONE stage mounts through the `startOnCompletionFrame` init
// seam (the StreakDetailView.animateHeader pattern) since the stage enum is
// private by design. HoldToConfirmButton at zero progress renders no ring —
// deterministic by construction. Geometry + determinism follow the flow
// neighbors exactly (.device(config: .iPhone13), 0.99/0.98, iOS-17
// closure-init traits).
//
// Matrix: confirm rides the full 4-axis set (it carries the copy-doc §11
// dialog and the pinned action stack); the completion frame — one line over
// the CrestMark glyph — rides light + dark.

@MainActor
@Suite(.snapshots(record: .missing))
struct EraseEverythingSnapshotTests {

    private typealias Axis = (name: String, dark: Bool, ax5: Bool)

    private func makeView(done: Bool = false) -> EraseEverythingView {
        EraseEverythingView(
            flow: EraseFlow(erase: {}, applyIcon: { _ in }),
            onErased: {},
            startOnCompletionFrame: done
        )
    }

    private func assertStage(
        done: Bool,
        axes: [Axis],
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        for axis in axes {
            assertSnapshot(
                of: makeView(done: done),
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

    @Test func snapshot_eraseConfirm() {
        assertStage(
            done: false,
            axes: [
                ("light", false, false),
                ("dark", true, false),
                ("light-ax5", false, true),
                ("dark-ax5", true, true),
            ]
        )
    }

    @Test func snapshot_eraseCompletion() {
        assertStage(
            done: true,
            axes: [
                ("light", false, false),
                ("dark", true, false),
            ]
        )
    }
}
