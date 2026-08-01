import SnapshotTesting
import SwiftUI
import Testing
import UIKit
@testable import Ballast

// UIR-4 (Session 36) — the resources screen's golden matrix. The real `SafetyResourcesView`
// is rendered over a HAND-BUILT, LOCALE-FIXED `SafetyResourcesViewData` via the test-internal
// `init(data:)` — so a CI simulator locale change can never move the golden (the production
// `init(source:)` reads `Locale.current` + the shipping directory, which is snapshot-hostile).
// Copy is audited (S27); this is a legitimate mint (the S34 dashboard precedent). record:.missing
// → run 1 writes-then-fails → adopt from the test-outputs artifact → run 2 green. Config matches
// the flow neighbors exactly (.device(config:.iPhone13), precision 0.99/0.98, closure-init traits).
//
// ═══ S61 — THE AX5 AXIS, AND WHY IT WAS MISSING FOR TWENTY-FIVE SESSIONS ═══
//
// This suite was minted in UIR-4 with a light/dark PAIR and `.large` hard-coded.
// Every suite minted since carries the four-axis matrix, so counting the 16
// snapshot suites (rather than trusting the golden total) turns up exactly one
// holdout: this one. Combined with `test_a11yAudit_resources_noViolations`
// mounting at the DEFAULT content size, `SafetyResourcesView` had ZERO AX5
// coverage in EITHER lane — the only surface in the app that was blind twice.
//
// That matters more here than the count suggests. This screen is what a slip flow
// and the settings row hand a user in trouble: helpline rows, each ending in a
// `tel:` `Link` whose tappable area is held at the 44pt floor by
// `.frame(minHeight: Theme.touch.minTarget)` with a `Text` inside it that grows
// with Dynamic Type. That is the same ingredient list as R60.2 — a fixed floor and
// a growing sibling in one container — and nothing had ever rendered it at AX5.
//
// The existing `light`/`dark` names are UNCHANGED, so the two adopted PNGs cannot
// move; only `light-ax5`/`dark-ax5` are new. The AX5 audit leg lands in the same
// commit, because a golden pins composition and the audit reads the tree, and this
// surface needed both.

@MainActor
@Suite(.snapshots(record: .missing))
struct ResourcesSnapshotTests {
    private static let fixture = SafetyResourcesViewData(
        title: "Support",
        intro: "Free, confidential help lines.",
        footerDisclaimer: "In an emergency, call your local emergency services first.",
        emergencyNote: "If you or someone else is in immediate danger, call emergency services first.",
        rows: [
            HelplineRow(
                name: "Crisis Support Line",
                descr: "Free, confidential support.",
                phoneDisplay: "988",
                dialString: "988"
            ),
        ],
        source: .settings
    )

    @Test func snapshot_resources_usRows() {
        #expect(Self.fixture.rows.count > 0, "the fixture must carry at least one helpline row")
        let view = SafetyResourcesView(data: Self.fixture)
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
