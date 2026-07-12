import Foundation
import PaywallKit
import Testing
@testable import Unhooked

// E7.3 (R26.7/R26.8) — the win-back fire-points over the presenter seams
// (the PaywallPurchaseWireTests shape: spy sink, house types, ZERO RC/SW
// symbols — standing rule #9):
//   - SHOWN: `winback_shown(offer:)` FIRST, then the composed
//     paywall_viewed closure (`source: .winback`) — surface-scoped →
//     universal, once per presentation via the model's didFire guard.
//     Intentional dual-funnel (offer-scoped redemption rate WITHOUT a
//     source join + the unified paywall funnel WITH one) — honest only
//     under strict source segmentation (R26.7, recorded).
//   - CONVERTED: a PAID `.active` completion on the win-back surface fires
//     `winback_converted(offer:)` then `purchase(ballast.annual, annual)` —
//     BOTH (different funnels; no mutual exclusion, no dedupe). A win-back
//     re-subscribe is paid, never a trial — the `.active` guard keeps
//     R25.6's trial ⊕ purchase exclusion intact for free.
//   - The `offer` value-domain is the single ASC promotional-offer id
//     `winback_annual` (R26.8; the discount rides the SAME `ballast.annual`
//     SKU, so `purchase.product` stays inside the audited domain).
//
// RED: `makeFireWinbackShown` returns an inert closure and
// `makeOnPurchaseCompleted` ignores `winbackOfferID` — the fire pins fail
// by design; the consent-gate and value-domain pins are born-green guards.

/// The house spy shape, copied verbatim from QuizFlowModelTests (file-private
/// by the no-shared-fixtures convention).
@MainActor
private final class SpyAnalyticsSink: AnalyticsSink {
    private(set) var received: [AnalyticsEvent] = []
    func receive(_ event: AnalyticsEvent) { received.append(event) }
}

@MainActor
@Suite("E7.3 · win-back wire")
struct WinbackWireTests {
    private func makeService(optedIn: Bool = true) -> (service: AnalyticsService, spy: SpyAnalyticsSink) {
        let spy = SpyAnalyticsSink()
        return (AnalyticsService(sink: spy, isOptedIn: { optedIn }), spy)
    }

    private func makeWinbackModel(
        purchase: @escaping (PaywallModel.Plan) async -> PurchaseOutcome,
        optedIn: Bool = true
    ) -> (model: PaywallModel, spy: SpyAnalyticsSink) {
        let (service, spy) = makeService(optedIn: optedIn)
        let model = PaywallModel(
            purchase: purchase,
            restore: { .failed },
            onPurchaseCompleted: PaywallPresenter.makeOnPurchaseCompleted(
                analytics: service,
                winbackOfferID: ProductCatalog.winbackOfferID
            )
        )
        return (model, spy)
    }

    /// Plan-named (designed-red): a PAID annual completion on the win-back
    /// surface fires BOTH the offer-scoped redemption node and the universal
    /// revenue node, in the pinned surface→universal order. "WinbackAnnual"
    /// in the plan's name is the SCENARIO — the product value stays the
    /// audited `ballast.annual` (the offer is a discounted price on the SAME
    /// SKU, R26.2), and the win-back specificity lives on
    /// `winback_converted.offer` alone.
    @Test func test_winbackPurchase_firesPurchaseWinbackAnnual() async {
        let (model, spy) = makeWinbackModel(purchase: { _ in .completed(.active(product: .annual)) })
        model.selectedPlan = .annual

        await model.purchaseSelectedPlan()

        #expect(
            spy.received == [
                .winbackConverted(offer: "winback_annual"),
                .purchase(product: "ballast.annual", period: .annual),
            ],
            "a win-back conversion is a redemption AND a purchase — suppressing either under-counts (R26.7)"
        )
    }

    /// Designed-red: the impression dual fire — `winback_shown` FIRST, then
    /// the composed paywall_viewed closure with `source: .winback`. One
    /// factory, one presentation moment (the v1 surface IS the paywall), so
    /// the model's single didFire guard covers both.
    @Test func test_winbackShown_firesBeforePaywallViewed_sourceWinback() {
        let (service, spy) = makeService()
        let fire = PaywallPresenter.makeFireWinbackShown(
            offer: ProductCatalog.winbackOfferID,
            analytics: service,
            firePaywallViewed: PaywallPresenter.makeFirePaywallViewed(
                assignment: PaywallAssignment(variant: .hard, priceTest: .annual2999),
                source: .winback,
                analytics: service
            )
        )

        fire()

        #expect(
            spy.received == [
                .winbackShown(offer: "winback_annual"),
                .paywallViewed(variant: "hard", priceTest: .annual2999, source: .winback),
            ],
            "the offer-scoped impression leads, the universal paywall funnel follows with source segmentation (R26.7)"
        )
    }

    /// Born-green guard: the consent gate holds on the win-back impression
    /// wire — an opted-out presentation transmits nothing (ADR-8).
    @Test func test_winbackShown_optedOut_firesNothing() {
        let (service, spy) = makeService(optedIn: false)
        let fire = PaywallPresenter.makeFireWinbackShown(
            offer: ProductCatalog.winbackOfferID,
            analytics: service,
            firePaywallViewed: PaywallPresenter.makeFirePaywallViewed(
                assignment: PaywallAssignment(variant: .hard, priceTest: .annual2999),
                source: .winback,
                analytics: service
            )
        )

        fire()

        #expect(spy.received.isEmpty, "zero events before consent")
    }

    /// Born-green guard: the consent gate holds on the conversion wire too —
    /// the paid unlock is consent-independent, the events are not.
    @Test func test_winbackConverted_optedOut_firesNothing() async {
        let (model, spy) = makeWinbackModel(
            purchase: { _ in .completed(.active(product: .annual)) },
            optedIn: false
        )
        model.selectedPlan = .annual

        await model.purchaseSelectedPlan()

        #expect(spy.received.isEmpty, "zero events before consent")
        #expect(model.phase == .unlocked, "the paid unlock is consent-independent")
    }

    /// Born-green guard (the R25.6 mutual exclusion, extended): a TRIAL
    /// completion on a winback-configured closure still fires NOTHING —
    /// trial_started rides the provider edge; a win-back can never mint a
    /// second trial anyway (StoreKit grants one per account), so any trial
    /// state reaching this closure fires neither event.
    @Test func test_winbackTrialCompletion_firesNothing() async {
        let (model, spy) = makeWinbackModel(purchase: { _ in .completed(.trial(product: .annual)) })

        await model.purchaseSelectedPlan()

        #expect(spy.received.isEmpty, "the .active guard keeps trial ⊕ purchase exclusion intact on the winback surface")
    }

    /// Born-green data pins (R26.8): the closed value-domains — the ASC
    /// promotional-offer id, the Superwall placement id, and the analytics
    /// source raw value are three separate namespaces that happen to align;
    /// each is pinned so a rename of one can never silently drift another.
    @Test func test_winbackWireValueDomains_areFixed() {
        #expect(ProductCatalog.winbackOfferID == "winback_annual",
                "the offer id is the ASC promotional-offer identifier — no price in the id (R24.5/R26.8)")
        #expect(ProductCatalog.annualWinbackDisplayPrice == "$14.99",
                "50% of the $29.99 control — the composed line's dormant display constant")
        #expect(SuperwallPlacement.winback == "winback",
                "architecture §5.2's second register(placement:) id")
        #expect(PaywallSource.winback.rawValue == "winback",
                "the paywall_viewed source segment (mvp §5)")
    }
}
