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
///
/// RED (Session 25): every factory returns an inert closure — the wire pins
/// fail by design until green.
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
        {}
    }

    /// The teaser take (R25.7): fire `teaser_entered` (the affordance only
    /// exists on the teaser arm, so the variant is structurally `"teaser"`),
    /// then stamp the grant via the repository's injected-clock write.
    static func makeOnTeaserTaken(
        analytics: AnalyticsService,
        enterTeaser: @escaping () -> Void
    ) -> () -> Void {
        {}
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
    static func makeOnPurchaseCompleted(
        analytics: AnalyticsService
    ) -> (PaywallModel.Plan, EntitlementState) -> Void {
        { _, _ in }
    }
}
