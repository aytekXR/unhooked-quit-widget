import SnapshotTesting
import StreakEngine
import SwiftUI
import Testing
import UIKit
@testable import Unhooked

// E6.3 (O2, R22.9) — the app-switcher privacy overlay's snapshot suite. The FINAL
// `AppSwitcherPrivacyOverlay` is a zero-content, theme-aware `surface/base` fill
// (light #F7F6F3 / dark #121417); the golden's whole job is to PIN that neutral card
// so a brand crest, a wordmark, or a fixed wrong-theme neutral can never regress into
// it — the disguise depends on the switcher chrome reading as an ordinary empty app.
// Two goldens: light + dark. Nothing ticks, so no `pauseDate` and no frozen clock —
// the fill is a pure function of `colorScheme`.
//
// No UITest covers this surface (O2 manifest note): the shield is raised on a
// `ScenePhase` transition away from `.active`, and ScenePhase is NOT drivable from a
// UITest harness — we do not fabricate a scene-phase change we cannot actually observe
// (the S18 restraint). The policy that decides WHEN to raise it
// (`PrivacyOverlayPolicy.isActive`) is unit-pinned separately; this suite pins only
// what the raised shield LOOKS like.
//
// Geometry is pinned in-test via `ViewImageConfig(.iPhone13)` exactly as the flow
// neighbors do; references are recorded ON CI (`record: .missing` fails-while-writing
// on the RED run; the Linux dev box cannot render), retrieved from the `test-outputs`
// artifact, and committed — the §3.3 re-record discipline applies from then on.

@MainActor
@Suite(.snapshots(record: .missing))
struct PrivacyOverlaySnapshotTests {

    @Test func snapshot_privacyOverlay() {
        // The full-screen shield: theme-matched surface/base fill, zero content. Light +
        // dark only — no Dynamic Type axis (there is no text to scale).
        let axes: [(name: String, dark: Bool)] = [
            ("light", false),
            ("dark", true),
        ]
        for axis in axes {
            assertSnapshot(
                of: AppSwitcherPrivacyOverlay(),
                as: .image(
                    precision: 0.99,
                    perceptualPrecision: 0.98,
                    layout: .device(config: .iPhone13),
                    traits: UITraitCollection { traits in
                        traits.userInterfaceStyle = axis.dark ? .dark : .light
                    }
                ),
                named: axis.name
            )
        }
    }
}
