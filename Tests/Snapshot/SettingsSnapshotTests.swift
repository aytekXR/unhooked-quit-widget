import SnapshotTesting
import SwiftUI
import Testing
import UIKit
@testable import Unhooked

// UIR-4b (Session 37) — the settings screen's golden. `DiscreetSettingsView` is rendered
// over a MINIMAL fixture (`onResourcesRowTap: {}`, no `RepositoryProvider`): without a
// repository the per-quit toggles / icon picker / haptic-pacer / winback sections do not
// render, so the golden shows the navigation title + the resources row on the
// UIR-4b-themed List (surface/base backdrop, a surface/raised cell). This is the coverage
// a repository-less fixture affords; full-section coverage waits for a mock QuitRepository.
// Copy is audited (S22) — a legitimate mint (the S34 dashboard precedent). record:.missing
// → run 1 writes-then-fails → adopt from the test-outputs artifact → run 2 green. Config
// matches the flow neighbors (.device(config:.iPhone13), precision 0.99/0.98, closure-init
// traits — never the deprecated UITraitCollection(traitsFrom:) that burned run 29178893738).

@MainActor
@Suite(.snapshots(record: .missing))
struct SettingsSnapshotTests {
    @Test func snapshot_settings_resourcesRowOnly() {
        let view = DiscreetSettingsView(onResourcesRowTap: {})
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        for (name, dark) in [("light", false), ("dark", true)] {
            assertSnapshot(
                of: view,
                as: .image(
                    precision: 0.99,
                    perceptualPrecision: 0.98,
                    layout: .device(config: .iPhone13),
                    traits: UITraitCollection { traits in
                        traits.userInterfaceStyle = dark ? .dark : .light
                        traits.preferredContentSizeCategory = .large
                    }
                ),
                named: name
            )
        }
    }
}
