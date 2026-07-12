import Foundation
import PaywallKit

/// E7.1 — the pure summary-CTA routing decision (the `QuizGateRouting`
/// precedent: decisions are pure enums the unit tier pins; views stay thin).
/// `PostGateRootView` consults this ONLY when a live `EntitlementModel`
/// exists — dormant builds never reach it and fall to the dashboard (R24.2),
/// so the M1 loop is untouched until the operator's key lands.
enum PostSummaryDestination: Equatable, Sendable {
    /// Not entitled (never/lapsed): the hard-ish paywall (MVP §6 — nothing
    /// past the summary without trial/purchase; the teaser escape is E7.2's).
    case paywall
    /// Trial or active: straight to the dashboard — an entitled user must
    /// never meet the paywall on the onboarding path.
    case dashboard
}

enum PaywallRouting {
    static func postSummaryDestination(state: EntitlementState) -> PostSummaryDestination {
        state.isEntitled ? .dashboard : .paywall
    }
}
