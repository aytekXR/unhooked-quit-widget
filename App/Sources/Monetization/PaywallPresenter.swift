import Foundation
import PaywallKit

/// E7.2 (R25.5/R25.6/R25.7) — the presentation seam's closure factory: the
/// ONE place the paywall analytics fires are composed, so BOTH mount paths
/// (the live entitlement gate and the DEBUG `UITEST_PAYWALL` render) route
/// through identical, consent-gated wiring — a smoke tail that isn't true
/// for release builds would be a lie (the QA Demand-A rule).
///
/// Pure closure assembly over `AnalyticsService` (Foundation-only,
/// Linux-harnessable); the SwiftUI remap only ever passes these into
/// `PaywallModel`. Fire sites NEVER live in view bodies (a re-render must
/// not re-fire) and NEVER in the Darwin-only RC/Superwall files (QA's
/// harnessability veto).
@MainActor
enum PaywallPresenter {
    /// The paywall_viewed fire for ONE presentation: (live path only) echo
    /// the assignment into `AppSettings.paywallVariantAssigned` FIRST, then
    /// fire through the ONE consent gate (R25.5: assign → echo → fire).
    /// `echoAssignment` is nil on the bundled/debug paths — dormant builds
    /// never write the echo (the honest test-suite §4.4 reading).
    static func makeFirePaywallViewed(
        assignment: PaywallAssignment,
        source: PaywallSource,
        analytics: AnalyticsService,
        echoAssignment: ((String) -> Void)? = nil
    ) -> () -> Void {
        {
            echoAssignment?(assignment.variant.rawValue)
            analytics.fire(.paywallViewed(
                variant: assignment.variant.rawValue,
                priceTest: assignment.priceTest,
                source: source
            ))
        }
    }

    /// The teaser take (R25.7): fire `teaser_entered` (the affordance only
    /// exists on the teaser arm, so the variant is structurally `"teaser"`),
    /// then stamp the grant via the repository's injected-clock write. The
    /// stamp is consent-INDEPENDENT (the gate swallows the event, never the
    /// product behavior — a decliner's teaser day is as real as anyone's).
    static func makeOnTeaserTaken(
        analytics: AnalyticsService,
        enterTeaser: @escaping () -> Void
    ) -> () -> Void {
        {
            analytics.fire(.teaserEntered(variant: PaywallVariant.teaser.rawValue))
            enterTeaser()
        }
    }

    /// E7.3 (R26.7) — the win-back impression fire for ONE presentation:
    /// `winback_shown(offer:)` (the offer-scoped funnel node) FIRST, then
    /// the composed paywall_viewed closure (the universal node with
    /// `source: .winback`) — surface-scoped → universal, the pinned order.
    /// Both ride the model's single didFire presentation guard, so the
    /// dual-funnel co-fires exactly once per presentation (honest ONLY
    /// under strict source segmentation — recorded, R26.7).
    static func makeFireWinbackShown(
        offer: String,
        analytics: AnalyticsService,
        firePaywallViewed: @escaping () -> Void
    ) -> () -> Void {
        {
            analytics.fire(.winbackShown(offer: offer))
            firePaywallViewed()
        }
    }

    /// The purchase-completion fire (R25.6): `purchase` is a USER-INITIATED
    /// IN-APP PAID completion — fires ONLY when the completed state is
    /// `.active` (paid). A `.trial` completion fires NOTHING here
    /// (trial_started rides the S24 provider edge — the mutual exclusion
    /// that keeps MVP §4's "trial OR purchase" denominator honest); restore
    /// never reaches this closure at all (it hangs off the purchase path
    /// only). No dedupe marker by ruling: the fire is structurally
    /// at-most-once per completed purchase, and a marker would suppress an
    /// honest re-subscribe.
    ///
    /// E7.3 (R26.7): `winbackOfferID` non-nil marks the WIN-BACK surface's
    /// completion — a paid `.active` completion then ALSO fires
    /// `winback_converted(offer:)` BEFORE `purchase` (different funnels; no
    /// mutual exclusion, no dedupe — suppressing either would under-count).
    /// A win-back re-subscribe is PAID, never a trial, so the `.active`
    /// guard keeps R25.6's trial ⊕ purchase exclusion intact for free.
    static func makeOnPurchaseCompleted(
        analytics: AnalyticsService,
        winbackOfferID: String? = nil
    ) -> (PaywallModel.Plan, EntitlementState) -> Void {
        { plan, state in
            guard case .active = state else { return }
            if let winbackOfferID {
                analytics.fire(.winbackConverted(offer: winbackOfferID))
            }
            let product: Product = switch plan {
            case .monthly: .monthly
            case .annual: .annual
            }
            let period: SubscriptionPeriod = switch plan {
            case .monthly: .monthly
            case .annual: .annual
            }
            analytics.fire(.purchase(
                product: ProductCatalog.wireProductID(for: product),
                period: period
            ))
        }
    }
}
