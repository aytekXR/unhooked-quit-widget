import SnapshotTesting
import SwiftUI
import Testing
import UIKit
@testable import Unhooked

// P3 (redesign §6.5 / QW copy deltas) — the summary card's goldens, recorded the
// wave AFTER its strings changed so the re-record discipline has pixels to hold:
// wave 1 landed the CTA ("Start your streak") and the footer signature ("Steady
// beats perfect." on secondary ink under the 48pt hairline), and this screen —
// "the most designed single screen in the app" — had no golden at all.
//
// The suite renders the SHIPPING summaryCopy.json over the debug-mount fixture
// (savings 1350 USD, "evenings" risk window, two motivations) with an INERT
// model (`analytics: .disabled` — `onSummaryAppear()` during capture reaches no
// sink). `animateReveal: false` is the StreakDetailView.animateHeader seam: the
// card renders revealed on frame zero, never depending on `.onAppear` inside
// the offscreen renderer. Geometry + determinism follow the flow neighbors
// exactly (.device(config: .iPhone13), 0.99/0.98, iOS-17 closure-init traits).
//
// The full 4-axis matrix pins the two wave-1 strings in both palettes AND the
// brandkit §8 stacked-hero rule at AX5 (the figure and "/year" stack; the
// layout, not the glyph, gives way).

@MainActor
@Suite(.snapshots(record: .missing))
struct QuizSummarySnapshotTests {

    private func makeView() throws -> QuizSummaryView {
        let copy = try #require(
            SummaryCopy.loadShipping(),
            "the audited summaryCopy.json must be bundled — the goldens render the REAL CTA + footer signature"
        )
        let config = try #require(
            QuizConfig.loadShipping(),
            "the audited quizConfig.json must be bundled"
        )
        return QuizSummaryView(
            model: QuizFlowModel(config: config, analytics: .disabled),
            data: SummaryPresentation.make(
                inputs: QuizSummaryInputs(
                    savings: 1350,
                    currencyCode: "USD",
                    riskToken: "evenings",
                    motivations: ["Energy", "Money"]
                ),
                copy: copy,
                // Pinned, never `.current`: the hero renders the formatter's
                // separator ("~$1,350"), and the booted simulator's region must
                // not leak into the golden (the first record on this box came
                // out "~$1.350" — a tr_TR-style separator).
                locale: Locale(identifier: "en_US")
            ),
            onContinue: {},
            animateReveal: false
        )
    }

    @Test func snapshot_summaryCard() throws {
        let view = try makeView()
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
