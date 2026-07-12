import Foundation
import Testing
@testable import Unhooked

// E7.3 (R26.9) — the win-back copy + composition pins (the PaywallCopyTests
// composition shape, Foundation-only, Linux-harnessable):
//   - the four winback copy fields are STORED NON-OPTIONAL strings (the
//     Mirror lexicon walk scans them automatically with their 23 siblings;
//     the floor bump rides PaywallCopyTests);
//   - `source == .winback` composes the WinbackOfferData block — offer
//     line, the TWO-price mechanics line (discounted AND renewal — the
//     3.1.2(c)-grade disclosure), reassurance, and the dismiss (R26.6: an
//     OFFER is dismissible; the walls stay close-free);
//   - every OTHER source composes NO winback block, and the winback source
//     composes NO teaser escape (fork isolation);
//   - all standing 3.1.1 disclosures survive the fork (additive, never a
//     displacement).
//
// RED: `PaywallPresentation.make` composes `winbackOffer: nil`
// unconditionally (inert fork) — the winback-composition pins fail by
// design; the isolation and copy-presence pins are born-green guards.

@MainActor
@Suite("E7.3 · win-back copy + composition")
struct WinbackCompositionTests {
    /// Born-green (the copy fields land with this red commit as inert data —
    /// the R25.8 shape): the four winback strings exist, non-empty, in the
    /// degraded fallback AND the settings row label in its table.
    @Test func test_paywallCopy_winbackStrings_presentAndNonEmpty() {
        let copy = PaywallCopy.degraded
        for (label, value) in [
            ("winbackOfferLine", copy.winbackOfferLine),
            ("winbackMechanicsLineFmt", copy.winbackMechanicsLineFmt),
            ("winbackReassurance", copy.winbackReassurance),
            ("winbackDismissLabel", copy.winbackDismissLabel),
        ] {
            #expect(!value.isEmpty, "\(label) must ship non-empty — a String? child would dodge the Mirror walk (R25.8)")
        }
        #expect(copy.winbackMechanicsLineFmt.components(separatedBy: "%@").count == 3,
                "the mechanics line carries exactly TWO %@ slots — discounted AND renewal price (R26.9)")
        #expect(!DiscreetSettingsCopy.shipping.winbackRowLabel.isEmpty,
                "the settings-row label ships non-empty (view-gated visibility, never an optional String)")
    }

    /// Designed-red: the `.winback` source composes the offer block AND
    /// keeps every standing guideline-3.1.1 disclosure — the discount is
    /// additive, never a displacement.
    @Test func test_paywallComposed_winbackVariant_carriesOfferAndAllDisclosures() throws {
        let data = PaywallPresentation.make(copy: .degraded, variant: .hard, source: .winback)

        let offer = try #require(data.winbackOffer, "source .winback must compose the offer block (R26.9)")
        #expect(!offer.offerLine.isEmpty)
        #expect(!offer.reassurance.isEmpty)
        #expect(offer.dismissLabel == PaywallCopy.degraded.winbackDismissLabel,
                "the dismiss affordance rides the offer — an OFFER never traps (R26.6)")
        #expect(!data.autoRenewDisclosure.isEmpty, "3.1.1 disclosures survive the fork")
        #expect(!data.restoreLabel.isEmpty, "restore stays reachable on the offer surface")
        #expect(!data.termsLabel.isEmpty && !data.privacyLabel.isEmpty)
    }

    /// Designed-red: the composed mechanics line binds BOTH catalog prices —
    /// the discounted first year AND the standard renewal — in one line
    /// (the 3.1.2(c) precedent applied to discounts; prices are never copy
    /// literals, R24.5).
    @Test func test_winbackMechanicsLine_carriesDiscountedAndRenewalPrice() throws {
        let data = PaywallPresentation.make(copy: .degraded, variant: .hard, source: .winback)

        let offer = try #require(data.winbackOffer, "source .winback must compose the offer block")
        #expect(offer.mechanicsLine.contains(ProductCatalog.annualWinbackDisplayPrice),
                "the discounted first-year price renders from the catalog constant")
        #expect(offer.mechanicsLine.contains(ProductCatalog.annualControlDisplayPrice),
                "the renewal price renders beside it — the discount's 3.1.2(c) disclosure")
        #expect(!offer.mechanicsLine.contains("%@"), "both slots bound — no template residue")
    }

    /// Born-green guard (permanent): every non-winback source composes NO
    /// winback block — the offer exists on exactly one surface.
    @Test func test_paywallComposed_nonWinbackSources_composeNoWinbackOffer() {
        for source in [PaywallSource.onboarding, .settings, .teaserExpiry] {
            let data = PaywallPresentation.make(copy: .degraded, variant: .hard, source: source)
            #expect(data.winbackOffer == nil, "source \(source.rawValue) must not compose the offer block")
        }
    }

    /// Designed-red (the fork-isolation pin): the winback source composes
    /// NO teaser escape — one surface, one affordance set. Today's teaser
    /// fork keys on `variant == .teaser && source != .teaserExpiry`, which
    /// would co-compose the escape onto a (teaser, winback) presentation;
    /// green tightens the condition to exclude `.winback` (existing
    /// onboarding/settings escape behavior is untouched).
    @Test func test_paywallComposed_winbackSource_composesNoTeaserEscape() {
        let winback = PaywallPresentation.make(copy: .degraded, variant: .teaser, source: .winback)
        #expect(winback.teaserEscape == nil,
                "the winback surface never co-composes the teaser escape (fork isolation, R26.9)")
    }
}
