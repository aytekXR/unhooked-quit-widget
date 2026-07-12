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
    /// E7.2 (R25.5) — the paywall_viewed fire for THIS presentation, built by
    /// `PaywallPresenter.makeFirePaywallViewed` (assignment + source + the
    /// live-only echo baked in). Defaulted inert so every E7.1 call site (and
    /// M24a–e) stays byte-untouched.
    private let firePaywallViewed: () -> Void
    /// E7.2 (R25.6) — the purchase-path completion hand-off. Invoked ONLY
    /// from `purchaseSelectedPlan()`'s adopt (user-initiated; restore NEVER
    /// reaches it) — the conformer fires `purchase` for PAID states only.
    private let onPurchaseCompleted: (Plan, EntitlementState) -> Void
    /// E7.2 (R25.7) — the teaser take: fire teaser_entered + stamp the grant
    /// + dismiss. Single-use per presentation (didTakeTeaser).
    private let onTeaserTaken: () -> Void
    private var didFirePresentation = false
    private var didTakeTeaser = false

    private(set) var phase: Phase = .idle
    /// Annual pre-selected (brandkit §6.8) — the trial-carrying plan leads.
    var selectedPlan: Plan = .annual

    init(
        purchase: @escaping (Plan) async -> PurchaseOutcome,
        restore: @escaping () async -> PurchaseOutcome,
        firePaywallViewed: @escaping () -> Void = {},
        onPurchaseCompleted: @escaping (Plan, EntitlementState) -> Void = { _, _ in },
        onTeaserTaken: @escaping () -> Void = {}
    ) {
        self.purchase = purchase
        self.restore = restore
        self.firePaywallViewed = firePaywallViewed
        self.onPurchaseCompleted = onPurchaseCompleted
        self.onTeaserTaken = onTeaserTaken
    }

    /// The ONE presentation fire-point (R25.5): the mount path calls this
    /// once the screen is up; the guard makes body re-renders and repeat
    /// calls inert (MVP §5 "Paywall rendered" = once per presentation — the
    /// onSummaryAppear didFire precedent).
    func paywallPresented() {
        guard !didFirePresentation else { return }
        didFirePresentation = true
        firePaywallViewed()
    }

    /// The teaser escape's action (R25.7): single-use, fires teaser_entered
    /// through the composition closure (which also stamps the grant), then
    /// the host dismisses.
    func takeTeaser() {
        guard !didTakeTeaser else { return }
        didTakeTeaser = true
        onTeaserTaken()
    }

    func purchaseSelectedPlan() async {
        phase = .working
        adopt(await purchase(selectedPlan), fromPurchasePath: true)
    }

    func restorePurchases() async {
        phase = .working
        adopt(await restore())
    }

    /// `fromPurchasePath` marks a USER-INITIATED purchase completion —
    /// restore shares every phase transition but NEVER the purchase fire
    /// (restore ≠ purchase, R25.6; the conformer additionally fires only
    /// for PAID `.active` states — a trial start is trial_started's moment).
    private func adopt(_ outcome: PurchaseOutcome, fromPurchasePath: Bool = false) {
        switch outcome {
        case .completed(let state):
            // Restore with nothing behind it reports a non-entitled state —
            // the CALM empty surface (subscribe + restore both still live),
            // never the failure banner (a fact is not an error).
            phase = state.isEntitled ? .unlocked : .restoredEmpty
            if fromPurchasePath {
                onPurchaseCompleted(selectedPlan, state)
            }
        case .cancelled:
            // A deliberate cancel returns to the calm idle screen, wordlessly
            // (blame-free; purchases-ios reports it as an outcome, not error).
            phase = .idle
        case .failed:
            phase = .failed
        }
    }
}
