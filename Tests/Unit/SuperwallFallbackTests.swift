import Foundation
import PaywallKit
import Testing
@testable import Unhooked

// E7.2 (R25.1/R25.2/R25.3) — the DORMANT Superwall gate + the ADR-4
// de-integration insurance. The composition is the
// `MonetizationCompositionTests` twin: closures injected so this file never
// imports SuperwallKit — the live wiring passes `Superwall.configure` and
// the real adapter; these tests pass counters. The docs-verified stake
// (SuperwallKit 4.16.1 tagged source): configure ALONE fetches remote
// config, mints a persisted anonymous identity, and can post install
// attribution — "key absent ⇒ configure count 0" is a privacy pin, not
// bookkeeping.
//
// One of the four plan-named E7.2 tests lives here VERBATIM:
// `test_superwallRemoved_paywallKitFallbackRendersHardVariant` — labeled
// born-green BY DESIGN (the S24 bundled paywall ALREADY is the hard
// variant; the pin is the PERMANENT removability contract, the M24b shape:
// if any future session forks the presentation, this is the test that
// keeps the Superwall-less render whole).
//
// RED: `PaywallPresentationComposition.makeAssigner` is inert (always the
// bundled assigner, configure never invoked) and
// `SuperwallPlacement.variant(forSuperwallVariantID:)` ignores its mapping —
// the key-present arm and the mapping pin fail by design until green.

/// File-private assigner stand-in (the no-shared-fixtures convention): the
/// composition must vend exactly what `makeAdapter` builds on the live arm.
private struct ScriptedVariantAssigner: VariantAssigning {
    let scripted: PaywallAssignment
    func assignment(for _: String) async -> PaywallAssignment { scripted }
}

@MainActor
@Suite("E7.2 · Superwall dormant gate + de-integration fallback")
struct SuperwallFallbackTests {
    /// Plan-named (born-green at red — the permanent ADR-4 removability
    /// pin): with Superwall removed/keyless/unreachable, the composition
    /// vends the bundled assigner, the assignment is the HARD control arm,
    /// and the S24 bundled paywall renders it — close-free (no teaser
    /// escape), $29.99 control price, every 3.1.1 disclosure intact
    /// (test-suite §4.4: "degrades to the built-in default paywall").
    @Test func test_superwallRemoved_paywallKitFallbackRendersHardVariant() async {
        let assigner = PaywallPresentationComposition.makeAssigner(
            apiKey: "",
            configureSuperwall: {},
            makeAdapter: { ScriptedVariantAssigner(scripted: .init(variant: .teaser, priceTest: .annual3999)) }
        )
        let assignment = await assigner.assignment(for: SuperwallPlacement.postSummary)

        #expect(assignment == PaywallAssignment(variant: .hard, priceTest: .annual2999),
                "the fallback IS the hard control arm — deterministic, never the $39.99 Superwall-only arm")

        let data = PaywallPresentation.make(
            copy: .degraded, variant: assignment.variant, source: .onboarding
        )
        #expect(data.teaserEscape == nil, "the hard variant is close-free (R24.9 carried)")
        #expect(data.expiryEyebrow == nil)
        #expect(data.priceAnnualLine.contains("$29.99") && !data.priceAnnualLine.contains("$39.99"))
        #expect(data.autoRenewDisclosure.contains("renews automatically"),
                "de-integration never sheds a 3.1.2(c) disclosure")
        #expect(data.restoreLabel == "Restore purchases")
    }

    /// Born-green guard (the shipping posture): the empty key vends the
    /// bundled assigner and NEVER touches the configure closure — zero SDK
    /// init, zero network, no identity minted (R25.2).
    @Test func test_dormantSuperwallKey_absent_zeroConfigure_bundledAssigner() async {
        var configureCount = 0
        var adapterCount = 0

        let assigner = PaywallPresentationComposition.makeAssigner(
            apiKey: "",
            configureSuperwall: { configureCount += 1 },
            makeAdapter: {
                adapterCount += 1
                return ScriptedVariantAssigner(scripted: .init(variant: .teaser, priceTest: .annual3999))
            }
        )

        #expect(configureCount == 0, "DORMANT: Superwall is never configured — configure alone phones home")
        #expect(adapterCount == 0, "DORMANT: the adapter is never even constructed")
        let assignment = await assigner.assignment(for: SuperwallPlacement.postSummary)
        #expect(assignment.variant == .hard)
    }

    /// Designed-red: a present key configures Superwall exactly once and
    /// vends the adapter — the operator's deliberate act flips the lane
    /// (the M10 twin).
    @Test func test_superwallKey_present_configuresOnce_buildsAdapter() async {
        var configureCount = 0
        var adapterCount = 0
        let scripted = PaywallAssignment(variant: .teaser, priceTest: .annual3999)

        let assigner = PaywallPresentationComposition.makeAssigner(
            apiKey: "pk_test_key",
            configureSuperwall: { configureCount += 1 },
            makeAdapter: { adapterCount += 1; return ScriptedVariantAssigner(scripted: scripted) }
        )

        #expect(configureCount == 1, "the ONE configure call, made before the adapter exists")
        #expect(adapterCount == 1)
        let assignment = await assigner.assignment(for: SuperwallPlacement.postSummary)
        #expect(assignment == scripted, "the live arm vends exactly what makeAdapter built")
    }

    /// Designed-red: the dashboard variant-id mapping — a known id maps to
    /// its semantic label; unmapped/absent ids default to `.hard` (the
    /// control arm; the unknown-SKU grace precedent, R24.3). The live
    /// extraction keypath is `experiment?.variant.id` (docs-verified) — the
    /// mapping is where the operator's opaque dashboard ids become the
    /// audited {teaser, hard} wire domain.
    @Test func test_superwallVariantMapping_mapsKnownID_defaultsHardOtherwise() {
        let mapping: [String: PaywallVariant] = ["v_teaser_a": .teaser, "v_hard_ctl": .hard]

        #expect(SuperwallPlacement.variant(forSuperwallVariantID: "v_teaser_a", mapping: mapping) == .teaser)
        #expect(SuperwallPlacement.variant(forSuperwallVariantID: "v_hard_ctl", mapping: mapping) == .hard)
        #expect(SuperwallPlacement.variant(forSuperwallVariantID: "v_unknown", mapping: mapping) == .hard,
                "an unmapped id resolves to the control arm — config gaps honor the grace direction")
        #expect(SuperwallPlacement.variant(forSuperwallVariantID: nil, mapping: mapping) == .hard)
        #expect(SuperwallPlacement.variantMapping.isEmpty,
                "the shipping mapping is EMPTY until the operator builds the dashboard experiment (§8)")
    }
}
