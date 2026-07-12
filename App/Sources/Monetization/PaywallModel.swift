import Foundation
import Observation
import PaywallKit

/// One purchase/restore attempt's outcome, as the model sees it — the
/// injected-action seam the unit tier scripts (test-suite §3.1: doubles
/// conform to house seams, never SDK types). The live actions are built in
/// the single RC-importing file on the operator-keyed path only.
enum PurchaseOutcome: Equatable, Sendable {
    /// StoreKit confirmed; the post-purchase provider state rides along so
    /// the model can reflect entitlement without a second round-trip.
    case completed(EntitlementState)
    /// The user backed out of the payment sheet — NOT a failure surface
    /// (purchases-ios reports `userCancelled`, not an error; showing the
    /// failure banner for a deliberate cancel would read as blame).
    case cancelled
    /// Anything else — the never-trap failure surface (Epic 7 DoD: retry AND
    /// restore both reachable, always).
    case failed
}

/// The paywall screen's flow model (R24.10): plan selection + the
/// purchase/restore actions + the never-trap failure phase. Thin BY RULE —
/// entitlement truth lives in `EntitlementModel`; this model owns only the
/// screen's own moment.
@MainActor
@Observable
final class PaywallModel {
    enum Phase: Equatable, Sendable {
        case idle
        case working
        /// The never-trap surface: `retryCta` + `restoreLabel` both render
        /// (pinned — a failure may never strand a user mid-onboarding).
        case failed
        case restoredEmpty
        case unlocked
    }

    enum Plan: Equatable, Sendable {
        case monthly
        case annual
    }

    private let purchase: (Plan) async -> PurchaseOutcome
    private let restore: () async -> PurchaseOutcome

    private(set) var phase: Phase = .idle
    /// Annual pre-selected (brandkit §6.8) — the trial-carrying plan leads.
    var selectedPlan: Plan = .annual

    init(
        purchase: @escaping (Plan) async -> PurchaseOutcome,
        restore: @escaping () async -> PurchaseOutcome
    ) {
        self.purchase = purchase
        self.restore = restore
    }

    func purchaseSelectedPlan() async {
        phase = .working
        adopt(await purchase(selectedPlan))
    }

    func restorePurchases() async {
        phase = .working
        adopt(await restore())
    }

    private func adopt(_ outcome: PurchaseOutcome) {
        switch outcome {
        case .completed(let state):
            // Restore with nothing behind it reports a non-entitled state —
            // the CALM empty surface (subscribe + restore both still live),
            // never the failure banner (a fact is not an error).
            phase = state.isEntitled ? .unlocked : .restoredEmpty
        case .cancelled:
            // A deliberate cancel returns to the calm idle screen, wordlessly
            // (blame-free; purchases-ios reports it as an outcome, not error).
            phase = .idle
        case .failed:
            phase = .failed
        }
    }
}
