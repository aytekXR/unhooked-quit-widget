import SnapshotTesting
import SwiftUI
import Testing
import UIKit
@testable import Ballast

// The final golden batch, part 1 of 2 — the AGE GATE, the app's first screen and
// (with the quiz) one of the last two surfaces carrying zero goldens.
//
// WHY THIS SURFACE HAD NONE UNTIL NOW. `docs/golden-batch.md` deferred it under
// R33.2 ("don't mint goldens for draft copy") and then under the redesign's own
// Phase-4 sequencing. The copy block lifted when the operator closed the §3 pass in
// 46B; the sequencing block is what QW-6 would still move, and the operator's
// explicit ordering is "submittable ASAP", which puts the batch ahead of QW-6.
// Minting now is therefore deliberate: QW-6 will re-record these two entry pairs
// when the crest lands, and that is a two-PNG diff rather than a mystery.
//
// BOTH FIXTURES ARE DETERMINISTIC BY CONSTRUCTION, and neither needed a new seam
// invented for it:
//
//   ENTRY   `AgeGateModel(currentYear:)` takes a plain Int. Production derives it
//           from `LiveClock` at the composition root (`AgeGateContainerView:167`),
//           never `Date()` inside the model — Architect MUST-FIX #4 — so pinning
//           2026 here is using the seam that already exists, not adding one.
//           The wheel is stable too: `AgeGateView.yearPicker` composes an explicit
//           `Text("—").tag(Int?.none)` placeholder and the model pre-selects
//           nothing (PM §4, "the gate never nudges"), so the resting position is a
//           property of the view rather than of whatever the picker defaults to.
//
//   BLOCKED `AgeGateBlockedView.init(model:blocked:)` — the ONE production seam this
//           batch required, added in the same commit as this file and mirroring
//           `SafetyResourcesView.init(data:)` deliberately rather than inventing a
//           shape. The production `init(model:)` reads `Locale.current` to resolve
//           the region, which is snapshot-hostile: **CI pins no locale or timezone
//           for the snapshot lane**, so a runner whose region drifted would
//           re-render a SAFETY screen's helpline rows and fail a golden for a reason
//           that has nothing to do with the code.
//
// ⚠️ THE ONE THING TO EYEBALL BEFORE ADOPTING, carried from the banked S48 plan:
// the wheel renders **121** rows (`(currentYear - 120)...currentYear`, inclusive —
// the plan's "122" is off by one, counted here rather than quoted) and a UIKit
// picker inside a snapshot host does not always populate synchronously. **Do not
// adopt a blank wheel, or one showing only its centre row.** A correct entry golden
// shows "—" resting at centre with 2026 and earlier years below it.
//
// Geometry and determinism follow the flow neighbours exactly: `.device(config:
// .iPhone13)`, 0.99/0.98, iOS-17 closure-init traits (`UITraitCollection(traitsFrom:)`
// is DEPRECATED and fails under `-warnings-as-errors` — it burned a billed run once).

@MainActor
@Suite(.snapshots(record: .missing))
struct AgeGateSnapshotTests {

    /// Pinned, not derived. Any year works — the surface renders a range, not a date
    /// — but a literal keeps the golden stable across the calendar rolling over.
    private static let pinnedYear = 2026

    /// Hand-built and locale-fixed, on the `ResourcesSnapshotTests` precedent. It is
    /// deliberately NOT `AgeGateResources.blocked(region:bundle:)`: composing from the
    /// shipping directory would re-introduce exactly the dependency the seam exists to
    /// remove, and would also silently re-shoot this golden the day the operator
    /// verifies a new helpline row.
    private static let blockedFixture = AgeGateBlocked(
        emergencyNote: "If you or someone else is in immediate danger, call emergency services first.",
        rows: [
            HelplineRow(
                name: "988 Suicide & Crisis Lifeline",
                descr: "Free, confidential support, 24/7.",
                phoneDisplay: "988",
                dialString: "988"
            ),
        ]
    )

    private func assertAxes(
        _ view: some View,
        axes: [(name: String, dark: Bool, ax5: Bool)],
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
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

    /// The year-entry surface at rest — nothing selected, so the CTA is disabled and
    /// the wheel sits on its placeholder. That resting state IS the product decision
    /// (PM §4: no passing year is ever pre-selected), so it is the state worth pinning.
    ///
    /// AX5 is an axis here because this screen is the one place a Dynamic-Type failure
    /// is unrecoverable: it is the first screen, and a user who cannot read it cannot
    /// get past it. `OnboardingLayoutLintTests` and the audit leg both cover it at
    /// default size; only a golden covers it at the largest.
    @Test func snapshot_ageGate_entry() {
        let model = AgeGateModel(currentYear: Self.pinnedYear)
        #expect(model.selectedBirthYear == nil, "the gate must never pre-select a year — PM §4")
        #expect(model.selectableYears.count == 121, "the wheel's range is 121 inclusive values, not the plan's 122")

        assertAxes(
            AgeGateView(model: model).frame(maxWidth: .infinity, maxHeight: .infinity),
            axes: [
                ("light", false, false), ("dark", true, false),
                ("light-ax5", false, true), ("dark-ax5", true, true),
            ]
        )
    }

    /// The under-17 surface — a calm resources screen, never a wall. The contract this
    /// pins in pixels is the Session 16 brand sign-off: ZERO red anywhere, the teal
    /// emphasis belonging to the phone number alone, and no warning glyph.
    @Test func snapshot_ageGate_blocked() {
        #expect(!Self.blockedFixture.rows.isEmpty, "the fixture must carry a helpline row — an empty blocked screen proves nothing")
        let model = AgeGateModel(currentYear: Self.pinnedYear)

        assertAxes(
            AgeGateBlockedView(model: model, blocked: Self.blockedFixture)
                .frame(maxWidth: .infinity, maxHeight: .infinity),
            axes: [("light", false, false), ("dark", true, false)]
        )
    }
}
