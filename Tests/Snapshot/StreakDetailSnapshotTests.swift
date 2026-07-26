import SnapshotTesting
import SwiftUI
import Testing
import UIKit
@testable import Unhooked

// P2 (redesign §6.17) — Streak Detail's goldens: the milestone catalog's first
// rendered pixels (shipping vape ladder — brand review happens on these
// images), the Ember-lit unlocked rungs, the averted stat line, the private
// notes list, and the discreet variant's numbers-only posture (time-only rows,
// no Ember, no money, no notes). Light + dark × default + AX5 on the active
// screen; the discreet variant rides light + dark (its layout deltas are
// content-level, not type-level).

@MainActor
@Suite(.snapshots(record: .missing))
struct StreakDetailSnapshotTests {

    /// §3.2 fixture epoch: 2026-07-07T12:00:00Z.
    private static let epoch = Date(timeIntervalSince1970: 1_783_425_600)

    private func makeModel(discreet: Bool) -> StreakDetailModel {
        // 8 days in on the shipping vape ladder: 12h/24h/72h/168h unlocked,
        // 336h is the next rung, the rest locked.
        let elapsed = 8 * 86_400
        return StreakDetailModel(
            title: discreet ? StreakDetailCopy.screenTitleDiscreet : "Vaping",
            dayNumber: 9,
            moneySaved: discreet ? 0 : 31,
            currencyCode: "USD",
            momentumFraction: 0.82,
            avertedUrgeCount: 12,
            isDiscreet: discreet,
            isFrozen: false,
            isReduceMode: false,
            milestones: StreakDetailComposer.milestoneRows(
                elapsedSeconds: elapsed,
                milestones: MilestoneCatalog.shipping.milestones(for: .vape)
            ),
            notes: discreet ? [] : [
                ReflectionNote(
                    id: UUID(uuidString: "0E32C0DE-0000-4000-8000-0000000000A1")!,
                    at: Self.epoch - 2 * 86_400,
                    text: "Stress after the standup. Walked it off."
                ),
            ]
        )
    }

    private func assertScreen(
        _ model: StreakDetailModel,
        axes: [(name: String, dark: Bool, ax5: Bool)],
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        for axis in axes {
            assertSnapshot(
                // The content view directly (no NavigationStack): the nav bar
                // is title-free by design — content owns the identity — and
                // the offscreen renderer draws inline bars unrealistically.
                of: StreakDetailView(model: model, onLogSlip: {}),
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

    @Test func snapshot_streakDetail_active() {
        assertScreen(
            makeModel(discreet: false),
            axes: [
                ("light", false, false),
                ("dark", true, false),
                ("light-ax5", false, true),
                ("dark-ax5", true, true),
            ]
        )
    }

    @Test func snapshot_streakDetail_discreet() {
        assertScreen(
            makeModel(discreet: true),
            axes: [
                ("light", false, false),
                ("dark", true, false),
            ]
        )
    }
}
