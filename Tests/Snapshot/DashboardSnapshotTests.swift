import SnapshotTesting
import SwiftUI
import Testing
import UIKit
@testable import Unhooked

// UIR-2 (Session 34) — the dashboard card's golden matrix. The real `StreakDashboardCard`
// is rendered over a HAND-BUILT `StreakCardModel` value (no store, no SwiftData, no
// clock read reaches any render — every number is a fixed constant), inside a top-aligned
// screen container on `surface/base`.
//
// Matrix (8 goldens): the ACTIVE card across the full 4-axis flow-neighbor set (light,
// dark, light-ax5, dark-ax5), plus one golden each for the DISCREET (light+dark), FROZEN
// (light) and REDUCE (light) states — enough to pin every render branch the card carries
// (the ring omission + full-width column at AX sizes; the discreet money/label drop + the
// neutral ring; the frozen neutral ring; the reduce path).
//
// Geometry + determinism follow the flow neighbors EXACTLY (PanicFlowSnapshotTests /
// SlipFlowSnapshotTests): `.device(config: .iPhone13)` (the dashboard is a full-screen
// surface, NOT a widget canvas — never `.fixed`), precision 0.99 / perceptualPrecision
// 0.98, and the per-axis overrides via the iOS-17+ `UITraitCollection { … }` closure-init
// form. `UITraitCollection(traitsFrom:)` is DEPRECATED and errors under
// -warnings-as-errors — that exact mistake burned billed CI run 29178893738 on the widget
// suite, so it is never used here.
//
// References are recorded ON CI (`record: .missing` fails-while-writing on the RED run;
// the Linux dev box cannot render), retrieved from the `test-outputs` artifact, and
// committed — the §3.3 re-record discipline applies from then on.

@MainActor
@Suite(.snapshots(record: .missing))
struct DashboardSnapshotTests {

    // MARK: - Fixtures (fixed constants — no wall-clock read reaches any render)

    /// Active card: Day 34, $412 saved, momentum 82%, 45% toward the next milestone.
    private static let active = StreakCardModel(
        dayNumber: 34,
        moneySaved: 412,
        currencyCode: "USD",
        momentumFraction: 0.82,
        milestoneProgress: 0.45,
        isDiscreet: false,
        isReduceMode: false,
        isFrozen: false
    )

    private static let discreet = StreakCardModel(
        dayNumber: 34,
        moneySaved: 412,
        currencyCode: "USD",
        momentumFraction: 0.82,
        milestoneProgress: 0.45,
        isDiscreet: true,
        isReduceMode: false,
        isFrozen: false
    )

    private static let frozen = StreakCardModel(
        dayNumber: 34,
        moneySaved: 412,
        currencyCode: "USD",
        momentumFraction: 0.82,
        milestoneProgress: 0.45,
        isDiscreet: false,
        isReduceMode: false,
        isFrozen: true
    )

    private static let reduce = StreakCardModel(
        dayNumber: 34,
        moneySaved: 412,
        currencyCode: "USD",
        momentumFraction: 0.82,
        milestoneProgress: 0.45,
        isDiscreet: false,
        isReduceMode: true,
        isFrozen: false
    )

    // MARK: - Axes

    private typealias Axis = (name: String, dark: Bool, ax5: Bool)

    private static let lightDark: [Axis] = [
        ("light", false, false),
        ("dark", true, false),
    ]

    /// The full 4-axis full-screen set — light/dark × normal/AX5 (the flow-neighbor block).
    private static let lightDarkAX5: [Axis] = [
        ("light", false, false),
        ("dark", true, false),
        ("light-ax5", false, true),
        ("dark-ax5", true, true),
    ]

    /// Renders one card model over its axis list in a top-aligned screen container.
    private func assertCard(
        _ model: StreakCardModel,
        axes: [Axis],
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        let view = VStack(spacing: 0) {
            StreakDashboardCard(model: model, accessibilityID: "dashboard.card.fixture")
            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .themedScreenSurface()

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
                named: axis.name,
                fileID: fileID,
                file: filePath,
                testName: testName,
                line: line,
                column: column
            )
        }
    }

    // MARK: - The matrix

    @Test func snapshot_dashboardCard_active() {
        assertCard(Self.active, axes: Self.lightDarkAX5)
    }

    @Test func snapshot_dashboardCard_discreet() {
        // Money section + "next milestone" label dropped; ring goes neutral.
        assertCard(Self.discreet, axes: Self.lightDark)
    }

    @Test func snapshot_dashboardCard_frozen() {
        // Neutral ring + neutral momentum figure; numbers still render (frozen, not zero).
        assertCard(Self.frozen, axes: [("light", false, false)])
    }

    @Test func snapshot_dashboardCard_reduce() {
        // Reduce goal renders the same card today (adherence framing is §3-blocked).
        assertCard(Self.reduce, axes: [("light", false, false)])
    }
}
