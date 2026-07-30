import SnapshotTesting
import SwiftUI
import Testing
import UIKit
@testable import Ballast

// ME-7 (Session 50, redesign §6.11) — the rebuilt Settings screen's goldens.
//
// UIR-4b (S37) minted this suite as `snapshot_settings_resourcesRowOnly`, on the light
// and dark axes only. S50 changes it on two axes of its own, and both are deliberate:
//
//  1. **The AX5 axis is ADDED.** The suite's whole subject is the screen that carried the
//     app's one open accessibility defect — a nav-bar large title and long `List` section
//     footers that clip at accessibility sizes (QW-9 / R39.1 / R39.2). Recording it only
//     at `.large` meant no golden could ever show the clip, or its fix. The confirm-stage
//     erase suite next door already rides the 4-axis set; settings now does too.
//  2. **The fixture wires `onAddWidgetRowTap` as well as `onResourcesRowTap`.** Both are
//     repository-free sections, so both render here — the new *Panic access* card would
//     otherwise have shipped with no pixel coverage at all.
//
// The fixture is still repository-LESS (no `RepositoryProvider`), so the per-quit
// toggles, icon picker, Breathing and Your-plan sections do not render; that is the
// coverage a repository-less fixture affords, and full-section coverage still waits on a
// mock `QuitRepository`. What these four goldens DO pin is exactly what the rebuild
// changed: the free-standing scalable screen title, the themed section cards, and the two
// unconditional rows — at the largest accessibility size, where the old screen failed.
//
// Copy is audited (S22 + the five ME-7 DRAFT deltas). record:.missing → run 1
// writes-then-fails → adopt from the test-outputs artifact → run 2 green. Config matches
// the flow neighbours (.device(config:.iPhone13), precision 0.99/0.98, closure-init
// traits — never the deprecated UITraitCollection(traitsFrom:) that burned run
// 29178893738).

@MainActor
@Suite(.snapshots(record: .missing))
struct SettingsSnapshotTests {
    @Test func snapshot_settings_repositoryFreeSections() {
        let view = DiscreetSettingsView(
            onResourcesRowTap: {},
            onAddWidgetRowTap: {}
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)

        let axes: [(name: String, dark: Bool, ax5: Bool)] = [
            ("light", false, false),
            ("dark", true, false),
            ("light-ax5", false, true),
            ("dark-ax5", true, true),
        ]

        for axis in axes {
            assertSnapshot(
                of: view,
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
                named: axis.name
            )
        }
    }
}
