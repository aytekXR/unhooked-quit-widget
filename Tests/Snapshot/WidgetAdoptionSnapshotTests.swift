import SnapshotTesting
import SwiftUI
import Testing
import UIKit
@testable import Unhooked

// ME-1 (redesign §6.15) — the widget-adoption moment's goldens: the shipping
// copy table over a deterministic fixture feed, light + dark × default + AX5
// (the house §3.3 axes). The discreet variant proves the preview's honesty
// contract in pixels: a discreet quit previews the discreet widget (no money,
// no habit context) because the frame renders the TRUE feed. The handshake
// suite is nil on every mount, so detection/fire are structurally inert and
// the render is byte-reproducible.

@MainActor
@Suite(.snapshots(record: .missing))
struct WidgetAdoptionSnapshotTests {

    /// §3.2 fixture epoch: 2026-07-07T12:00:00Z.
    private static let epoch = Date(timeIntervalSince1970: 1_783_425_600)
    private static let quitID = UUID(uuidString: "0E32C0DE-0000-4000-8000-000000000001")!

    private func makeView(discreet: Bool) throws -> WidgetAdoptionView {
        let copy = try #require(
            WidgetMomentCopy.loadShipping(),
            "the shipping widgetMomentCopy.json must be bundled — the goldens render the REAL copy (brand review happens on these images)"
        )
        return WidgetAdoptionView(
            copy: copy,
            feed: WidgetFeed(
                generatedAt: Self.epoch,
                quits: [
                    WidgetQuitState(
                        id: Self.quitID,
                        streakStart: Self.epoch - 3_600, // Day 1, one hour in
                        timeZoneIdentifier: "America/New_York",
                        weeklySpend: "26.50",
                        currencyCode: "USD",
                        bankedCleanSeconds: 0,
                        momentumPercent: 100,
                        milestoneHours: [12, 24, 72],
                        discreet: discreet ? true : nil
                    ),
                ]
            ),
            now: Self.epoch,
            analytics: .disabled,
            handshakeDefaults: nil,
            onContinue: {}
        )
    }

    /// The §3.3 axes for one screen: light + dark × default + AX5.
    private func assertScreen(
        _ view: WidgetAdoptionView,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
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
                named: axis.name,
                fileID: fileID,
                file: filePath,
                testName: testName,
                line: line,
                column: column
            )
        }
    }

    @Test func snapshot_widgetMoment() throws {
        try assertScreen(makeView(discreet: false))
    }

    @Test func snapshot_widgetMoment_discreet() throws {
        // The preview obeys the lexicon rules BY CONSTRUCTION: the discreet
        // feed renders the Reset variant, money dropped — provable in pixels.
        try assertScreen(makeView(discreet: true))
    }
}
