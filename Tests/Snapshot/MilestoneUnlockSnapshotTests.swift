import SnapshotTesting
import StreakEngine
import SwiftUI
import Testing
import UIKit
@testable import Unhooked

// ME-3 (S51, redesign §6.20) — the milestone unlock card's goldens. This is a brand moment
// (the crest's waterline rise, Ember's sanctioned second spend, quiet pride rather than a
// trophy), so brand review needs pixels.
//
// The card renders over a VALUE fixture — a `MilestoneRowModel` — with no repository and no
// store, which is the `StreakDashboardCard` pattern that makes a surface both golden-able
// and audit-able. Bodies are the REAL catalog's shape, hedge marker included.
//
// `animateOnAppear` is left at its default `false`, so these capture the SETTLED card: the
// crest sits above its waterline and opacity is 1, byte-identical to the animated draw's
// final frame (the `StreakRing` contract, R34.4). No mid-animation frame can be captured,
// and a future motion change moves no golden. The motion itself is device-eyeball work.
//
// Matrix: the normal variant rides the full 4-axis set — it carries the most text of any
// card in the app (catalog body + the signed not-medical-care hedge), so AX5 is where it
// would break. The discreet variant rides light + dark: it is deliberately short (time-only
// title + one line), and its whole point is what it does NOT render.

@MainActor
@Suite(.snapshots(record: .missing))
struct MilestoneUnlockSnapshotTests {

    private typealias Axis = (name: String, dark: Bool, ax5: Bool)

    /// A rung with the real catalog's shape: a worded title and a hedged experiential
    /// body. 72h is the rung a backdated "I stopped five days ago" quit lands on, which is
    /// the case the derivation was designed around.
    private static let row = MilestoneRowModel(
        afterHours: 72,
        title: "Three days",
        body: "Three days in. This is commonly reported as the toughest window — and you are through it.",
        state: .unlocked
    )

    private func makeView(discreet: Bool) -> some View {
        // Wrapped in a ScrollView because HOME is a ScrollView: at AX5 this card is
        // taller than the device frame, and an unscrolled fixture captured a MIDDLE
        // SLICE — crest, title and both actions all cut off — which pins nothing and
        // would churn on any copy edit. Anchored at the top, the golden shows the
        // elements most likely to clip and stays stable. R33.12 item 4: content scrolls.
        ScrollView(.vertical) {
            MilestoneUnlockCard(
                row: Self.row,
                isDiscreet: discreet,
                onDone: {},
                onSeeAll: {}
            )
            .padding(Theme.space.s5)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .themedScreenSurface()
    }

    private func assertCard(
        discreet: Bool,
        axes: [Axis],
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        for axis in axes {
            assertSnapshot(
                of: makeView(discreet: discreet),
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

    @Test func snapshot_milestoneUnlock() {
        assertCard(
            discreet: false,
            axes: [
                ("light", false, false),
                ("dark", true, false),
                ("light-ax5", false, true),
                ("dark-ax5", true, true),
            ]
        )
    }

    /// The shoulder test, in pixels: no crest, no eyebrow, no Ember flame — a neutral
    /// checkmark, the rung's DURATION instead of the worded title, and the copy-doc §9 line
    /// instead of the experiential body. No not-medical-care hedge either, because there is
    /// no medical-adjacent claim on this variant to hedge.
    @Test func snapshot_milestoneUnlock_discreet() {
        assertCard(
            discreet: true,
            axes: [
                ("light", false, false),
                ("dark", true, false),
            ]
        )
    }
}
