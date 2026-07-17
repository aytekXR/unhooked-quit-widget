import SnapshotTesting
import SwiftUI
import Testing
import UIKit
@testable import Unhooked

// UIR-4 (Session 36) — the resources screen's golden matrix. The real `SafetyResourcesView`
// is rendered over a HAND-BUILT, LOCALE-FIXED `SafetyResourcesViewData` via the test-internal
// `init(data:)` — so a CI simulator locale change can never move the golden (the production
// `init(source:)` reads `Locale.current` + the shipping directory, which is snapshot-hostile).
// Copy is audited (S27); this is a legitimate mint (the S34 dashboard precedent). record:.missing
// → run 1 writes-then-fails → adopt from the test-outputs artifact → run 2 green. Config matches
// the flow neighbors exactly (.device(config:.iPhone13), precision 0.99/0.98, closure-init traits).

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
