import SnapshotTesting
import SwiftUI
import Testing
import UIKit
@testable import Ballast

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
//
// ME-4 (S54) re-records all four and adds a second case. What moved: the
// full-bleed `WaterlineField` backdrop, the 16→24pt card radius, the Moss
// numeral, "/year" promoted to `.title2`, the `WaterlineRule` horizon under the
// figure with 32pt clearspace bracketing the stage, the risk window in its own
// sunken well, and motivations at `.title2`.
//
// Two riders worth stating, because both were checked rather than assumed:
//
// 1. **The field renders in an offscreen snapshot.** It is a `Canvas`, and the
//    question "does Canvas draw in an image snapshot" is the kind of claim that
//    otherwise costs a billed run to answer. It does not need one: the adopted
//    `PanicFlowSnapshotTests.snapshot_timerStep` goldens already render
//    `WaveTimerView`'s Canvas crest. Precedent, on disk.
// 2. **No freeze seam is needed.** `WaterlineField` takes no clock input at all
//    (no `TimelineView`, no `Date`), which is exactly why ME-8 built it that way —
//    unlike the wave timer above, which needs `pauseDate`. A golden containing the
//    field is byte-stable by construction.
//
// The NEW case is the zero-spend state. UX blueprint §6.5 names it ("zero-spend
// users see the risk-window + motivations composition with no money block — never
// '$0'") and ME-4 restructured it: `heroStage` now branches, so the absent variant
// renders the reframe plus the horizon rule and NO caption. Nothing pinned that
// branch before, and AC4 — no fabricated "~$0/year" — is a product rule worth a
// golden. Two axes rather than four: the branch is a composition change, not a
// Dynamic-Type one, and the AX5 behaviour it would exercise is already pinned by
// the four full-data axes.

@MainActor
@Suite(.snapshots(record: .missing))
struct QuizSummarySnapshotTests {

    private func makeView(savings: Decimal = 1350) throws -> QuizSummaryView {
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
                    savings: savings,
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

    /// AC4 / §6.5's zero-spend state. `savings: 0` drives
    /// `SummaryFormatter.savingsDisplay` to nil, so `heroParts` is nil and the card
    /// renders the `savingsAbsent` reframe instead of a figure — the branch that
    /// exists so the screen never shows a fabricated "~$0/year".
    ///
    /// Deliberately built through the SHIPPING formatter rather than by handing the
    /// view a nil `savingsLine`: the point is to pin that a zero spend PRODUCES the
    /// absent variant, which a hand-built fixture would assume rather than prove.
    @Test func snapshot_summaryCard_savingsAbsent() throws {
        let view = try makeView(savings: 0)
        let axes: [(name: String, dark: Bool)] = [("light", false), ("dark", true)]
        for axis in axes {
            assertSnapshot(
                of: view,
                as: .image(
                    precision: 0.99,
                    perceptualPrecision: 0.98,
                    layout: .device(config: .iPhone13),
                    traits: UITraitCollection { traits in
                        traits.userInterfaceStyle = axis.dark ? .dark : .light
                        traits.preferredContentSizeCategory = .large
                    }
                ),
                named: axis.name
            )
        }
    }
}
