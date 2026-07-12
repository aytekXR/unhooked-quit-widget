import Foundation
import PaywallKit
import Testing
@testable import Unhooked

// E7.1 app half (Session 24) — the paywall flow model's never-trap pins
// (Epic 7 DoD: "paywall never traps a user — failure paths always offer
// retry + restore"; R24.10). The purchase/restore actions are injected and
// scripted (test-suite §3.1: doubles conform to house seams, never SDK
// types) — the live RC-backed actions arrive with green's single
// RC-importing file and only ever run on the operator-keyed path.
//
// RED: `PaywallModel`'s actions are inert (the phase never leaves .idle) —
// the failure/unlock/restore pins below fail by design until green.

@MainActor
@Suite("E7.1 · paywall model (never-trap)")
struct PaywallModelTests {
    /// M24 (designed-red): a failed purchase lands on the FAILED surface —
    /// the phase whose rendering carries BOTH `retryCta` and `restoreLabel`
    /// (string-presence pinned in PaywallCopyTests; the phase is the seam).
    @Test func test_paywallModel_purchaseFailure_landsOnFailedSurface_neverTraps() async {
        let model = PaywallModel(
            purchase: { _ in .failed },
            restore: { .failed }
        )

        await model.purchaseSelectedPlan()

        #expect(model.phase == .failed, "a failure must surface retry + restore — never a dead end")
    }

    /// M24b (born-green at red — the inert model coincidentally stays .idle;
    /// kept as the permanent cancel-arm pin): a deliberate cancel is NOT a
    /// failure surface — purchases-ios reports userCancelled as an outcome,
    /// and showing the failure banner for it would read as blame.
    @Test func test_paywallModel_userCancel_isNotAFailureSurface() async {
        let model = PaywallModel(
            purchase: { _ in .cancelled },
            restore: { .cancelled }
        )

        await model.purchaseSelectedPlan()

        #expect(model.phase == .idle, "cancel returns to the calm idle screen, wordlessly")
    }

    /// M24c (designed-red): a completed, entitled purchase unlocks — the
    /// phase the CTA seam reads to hand off to the dashboard.
    @Test func test_paywallModel_completedPurchase_unlocks() async {
        let model = PaywallModel(
            purchase: { _ in .completed(.trial(product: .annual)) },
            restore: { .failed }
        )

        await model.purchaseSelectedPlan()

        #expect(model.phase == .unlocked)
    }

    /// M24d (designed-red): restore with nothing to restore is CALM and
    /// recoverable (restoreEmpty copy; subscribe + restore both still live) —
    /// not the failure surface, never a dead end.
    @Test func test_paywallModel_restoreFindsNothing_staysRecoverable() async {
        let model = PaywallModel(
            purchase: { _ in .failed },
            restore: { .completed(.never) }
        )

        await model.restorePurchases()

        #expect(model.phase == .restoredEmpty)
    }

    /// M24e (designed-red): a successful restore of a live entitlement
    /// unlocks — restore is reachable in EVERY state (Epic 7 DoD) and its
    /// happy path must hand off exactly like a purchase.
    @Test func test_paywallModel_restoreRecoversEntitlement_unlocks() async {
        let model = PaywallModel(
            purchase: { _ in .failed },
            restore: { .completed(.active(product: .annual)) }
        )

        await model.restorePurchases()

        #expect(model.phase == .unlocked)
    }

    /// Born-green: annual (the trial-carrying plan) is pre-selected —
    /// brandkit §6.8's recorded default.
    @Test func test_paywallModel_annualPlanIsPreselected() {
        let model = PaywallModel(purchase: { _ in .failed }, restore: { .failed })
        #expect(model.selectedPlan == .annual)
    }
}
