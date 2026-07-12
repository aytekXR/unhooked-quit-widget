import Foundation
import PaywallKit
import Testing
@testable import Unhooked

// E7.2 (R25.6) — the purchase fire-point: the S24 deferral R24.4 carried BY
// NAME, ruled this session. `purchase` = a USER-INITIATED IN-APP PAID
// completion, and nothing else:
//   - fires ONLY from `purchaseSelectedPlan()`'s completion path with a
//     PAID (`.active`) state — the seam that structurally cannot see a
//     renewal (renewals are SK-side and not client-honest, R24.4);
//   - a `.trial` completion fires NOTHING here — trial_started rides the
//     S24 provider edge; the mutual exclusion keeps MVP §4's ≥8% "trial OR
//     purchase" denominator honest (one conversion, never double-counted);
//   - restore NEVER fires it (recovering an entitlement is not a
//     conversion) — the closure hangs off the purchase path only;
//   - NO dedupe marker by ruling (structurally at-most-once; a marker would
//     suppress an honest re-subscribe after refund/lapse).
// Without this fire-point every MONTHLY conversion (no trial edge) is
// invisible in the funnel — the concrete gap E7.2 closes (PM P4).
//
// RED: `PaywallModel.adopt` never invokes `onPurchaseCompleted` and
// `PaywallPresenter.makeOnPurchaseCompleted` returns an inert closure — the
// fire pins fail by design; the never-fires pins are born-green guards.

/// The house spy shape, copied verbatim from QuizFlowModelTests (file-private
/// by the no-shared-fixtures convention).
@MainActor
private final class SpyAnalyticsSink: AnalyticsSink {
    private(set) var received: [AnalyticsEvent] = []
    func receive(_ event: AnalyticsEvent) { received.append(event) }
}

@MainActor
@Suite("E7.2 · purchase wire")
struct PaywallPurchaseWireTests {
    private func makeModel(
        purchase: @escaping (PaywallModel.Plan) async -> PurchaseOutcome,
        restore: @escaping () async -> PurchaseOutcome = { .failed },
        optedIn: Bool = true
    ) -> (model: PaywallModel, spy: SpyAnalyticsSink) {
        let spy = SpyAnalyticsSink()
        let model = PaywallModel(
            purchase: purchase,
            restore: restore,
            onPurchaseCompleted: PaywallPresenter.makeOnPurchaseCompleted(
                analytics: AnalyticsService(sink: spy, isOptedIn: { optedIn })
            )
        )
        return (model, spy)
    }

    /// Designed-red: a completed MONTHLY purchase (no trial exists on
    /// monthly — MVP §6) fires purchase with the canonical wire id + period.
    @Test func test_purchaseCompletion_monthly_firesPurchaseWithWireProductAndPeriod() async {
        let (model, spy) = makeModel(purchase: { _ in .completed(.active(product: .monthly)) })
        model.selectedPlan = .monthly

        await model.purchaseSelectedPlan()

        #expect(
            spy.received == [.purchase(product: "ballast.monthly", period: .monthly)],
            "a monthly completion is an immediate paid purchase — without this fire the funnel never sees it"
        )
    }

    /// Designed-red: a paid ANNUAL completion (e.g. a re-subscribe after a
    /// lapse — StoreKit grants no second trial) fires with the annual wire
    /// id. Both A/B arms map to product "ballast.annual" — the price arm
    /// rides paywall_viewed.price_test, never purchase.product (R23.6).
    @Test func test_purchaseCompletion_paidAnnual_firesPurchaseAnnual() async {
        let (model, spy) = makeModel(purchase: { _ in .completed(.active(product: .annual)) })
        model.selectedPlan = .annual

        await model.purchaseSelectedPlan()

        #expect(spy.received == [.purchase(product: "ballast.annual", period: .annual)])
    }

    /// Born-green guard (the mutual exclusion): an annual purchase that
    /// starts the 3-DAY TRIAL is a `trial_started`, NOT a `purchase` — the
    /// provider edge owns that fire (S24 R24.6); firing both would inflate
    /// the ≥8% trial-or-purchase denominator.
    @Test func test_purchaseCompletion_trialState_firesNoPurchase() async {
        let (model, spy) = makeModel(purchase: { _ in .completed(.trial(product: .annual)) })

        await model.purchaseSelectedPlan()

        #expect(spy.received.isEmpty,
                "a trial start is trial_started's moment — purchase stays silent (mutual exclusion, R25.6)")
    }

    /// Born-green guard: restore is NOT a purchase — a recovered
    /// entitlement (even a paid, active one) fires nothing on this wire.
    @Test func test_restoreCompletion_firesNoPurchase() async {
        let (model, spy) = makeModel(
            purchase: { _ in .failed },
            restore: { .completed(.active(product: .annual)) }
        )

        await model.restorePurchases()

        #expect(spy.received.isEmpty, "restore ≠ purchase — never a conversion event (R25.6)")
    }

    /// Born-green guard: cancelled / failed / restored-empty outcomes fire
    /// nothing — only a PAID completion is a conversion.
    @Test func test_nonCompletedOutcomes_fireNoPurchase() async {
        for outcome in [PurchaseOutcome.cancelled, .failed, .completed(.never)] {
            let (model, spy) = makeModel(purchase: { _ in outcome })
            await model.purchaseSelectedPlan()
            #expect(spy.received.isEmpty, "\(outcome) is not a conversion")
        }
    }

    /// Born-green guard: the consent gate holds on the purchase wire too —
    /// an opted-out paid completion transmits nothing (ADR-8), while the
    /// purchase itself still unlocks (consent gates analytics, not product).
    @Test func test_purchaseCompletion_optedOut_firesNothing_stillUnlocks() async {
        let (model, spy) = makeModel(
            purchase: { _ in .completed(.active(product: .monthly)) },
            optedIn: false
        )
        model.selectedPlan = .monthly

        await model.purchaseSelectedPlan()

        #expect(spy.received.isEmpty, "zero events before consent")
        #expect(model.phase == .unlocked, "the paid unlock is consent-independent")
    }
}
