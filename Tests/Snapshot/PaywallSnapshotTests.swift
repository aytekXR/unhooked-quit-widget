import SnapshotTesting
import SwiftUI
import Testing
import UIKit
@testable import Ballast

// ME-9 (redesign §6.6) — the paywall's first goldens. The surface has had ZERO
// since it was built: `docs/golden-batch.md` deferred them under R33.2 ("don't
// mint goldens for draft copy"), and that block lifted when the operator's §3
// copy pass closed `paywallCopy.json` in 46B (`3a10442`, three string edits —
// `copy-pass-checklist.md` row B).
//
// The fixture is the `debugPaywallDirectMount` shape verbatim
// (`PostGateRootView.swift:655`): `PaywallPresentation.make(copy:variant:source:)`
// + `PaywallModel(purchase:restore:)`. It needs NO production seam and touches
// ZERO RevenueCat symbols — `PaywallView` is a pure renderer over injected data,
// so the live key changes nothing about what these capture.
//
// Geometry + determinism follow the flow neighbours exactly (.device(config:
// .iPhone13), 0.99/0.98, iOS-17 closure-init traits).
//
// THREE CASES, and the third is the one worth reading.
//
// 1/2. `hard` and `teaser` — the two shipping variants. They differ only in the
//      footer: the teaser arm composes the quiet escape + its note, the hard arm
//      composes neither (close-free, R24.9). Both carry the new §6.6 Waterline
//      band, which is why light/dark is the axis that matters here: the band is a
//      6% tint of `brand/primary` over `surface/base`, and those two tokens are
//      the pair that inverts between appearances.
//
// 3.   `failed` — and this closes a gap ME-9's own scoping called unclosable.
//      The roadmap row states "nothing here renders the failure banner in any
//      golden or audit mount — only a harness can check that composite". That is
//      true of a fixture built at rest, because `PaywallModel.phase` starts
//      `.idle` and is `private(set)`. It is NOT true if the fixture DRIVES the
//      real path: `purchase: { _ in .failed }` is already the debug mount's own
//      closure, so one `await model.purchaseSelectedPlan()` walks
//      `phase = .working → adopt(.failed) → phase = .failed` through shipping
//      code and the banner renders. No seam, no test-only initializer, and the
//      app's ONE remaining unfloored translucent fill is now pinned in pixels as
//      well as in the contrast harness.
//
// AX5 is deliberately not an axis here. The band is a fraction of the SCREEN, so
// it captures identically at every content size, and the paywall's Dynamic-Type
// behaviour is already gated by `test_a11yAudit_paywall_noViolations` (the full
// 7-type audit, incl. `.dynamicType` and `.textClipped`) plus
// `OnboardingLayoutLintTests`, whose scope includes `App/Sources/Monetization`.

@MainActor
@Suite(.snapshots(record: .missing))
struct PaywallSnapshotTests {

    private func makeView(variant: PaywallVariant) throws -> PaywallView {
        let copy = try #require(
            PaywallCopy.loadShipping(),
            "the audited paywallCopy.json must be bundled — the goldens render the REAL headline, plan titles and disclosure"
        )
        return PaywallView(
            data: PaywallPresentation.make(copy: copy, variant: variant, source: .onboarding),
            model: PaywallModel(purchase: { _ in .failed }, restore: { .failed }),
            onUnlocked: {}
        )
    }

    private func assertAxes(
        _ view: PaywallView,
        axes: [(name: String, dark: Bool, ax5: Bool)] = [("light", false, false), ("dark", true, false)],
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

    /// The shipping default: the close-free hard wall, annual pre-selected with the
    /// positive-green trial badge on its deliberately NEUTRAL sunken capsule.
    @Test func snapshot_paywall_hard() throws {
        assertAxes(try makeView(variant: .hard))
    }

    /// The teaser arm — identical above the fold, plus the quiet escape and its
    /// honest "what this does" note below the CTA (§1.1 no-dark-patterns).
    @Test func snapshot_paywall_teaser() throws {
        assertAxes(try makeView(variant: .teaser))
    }

    /// The never-trap failure surface, driven through the SHIPPING path rather
    /// than posed. `themedCautionCard` carries an opaque `surface/base` floor
    /// beneath its tint (ME-9), so the composite that renders is the composite
    /// `Theme.contrastPairs` measured.
    ///
    /// **This pair is why the suite exists.** Its FIRST recording (run
    /// `30506301044`) showed a ~4px sliver of the amber card and no "Try again",
    /// because `statusSurface` was the last child inside the `ScrollView` — R58.1.
    /// S59 pinned it; these goldens are the proof.
    ///
    /// **AX5 is an axis HERE and nowhere else in this suite, and it is answering a
    /// specific question rather than adding coverage for its own sake.** Pinning a
    /// surface moves it into a zone that cannot scroll, so the thing worth knowing
    /// is whether the banner plus the CTA plus the escapes still FIT at the largest
    /// text size. Two extra PNGs answer that in pixels; no amount of reasoning does.
    @Test func snapshot_paywall_failed() async throws {
        let view = try makeView(variant: .hard)
        await view.model.purchaseSelectedPlan()
        #expect(view.model.phase == .failed, "the fixture must actually reach the failure phase — a posed golden proves nothing")
        assertAxes(view, axes: [
            ("light", false, false), ("dark", true, false),
            ("light-ax5", false, true), ("dark-ax5", true, true),
        ])
    }
}
