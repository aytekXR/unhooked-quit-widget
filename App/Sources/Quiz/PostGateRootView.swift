import SwiftUI

/// E5.2 — what the age-gate container mounts once the gate passes (Architect
/// MUST-FIX 8): the pure `QuizGateRouting` decision over store truth. No active
/// quit → the onboarding quiz (content is reachable ONLY through gate → quiz →
/// quit — the Epic-5 DoD un-bypassability seam); a quit exists → the dashboard
/// placeholder. Completion flips the published handoff and this view re-routes.
///
/// Composition (MUST-FIX 7): the QuizProfile is assembled by the repository —
/// this view hands the model `repository.completeQuiz` and
/// `repository.setAnalyticsOptIn` as injected callbacks and never touches
/// SwiftData itself. Production analytics is the repository-VENDED live service
/// (E8.2): its gate reads the stored consent on every fire, so an opt-in made at
/// the slot-3 step governs this same run's later events (the summary's
/// quiz_completed included). The view never constructs a sink or a consent read
/// — that is composition-root work. The transport stays dormant until the
/// operator's app ID (§8, the double gate's second half).
struct PostGateRootView: View {
    @Environment(RepositoryProvider.self) private var provider: RepositoryProvider?
    @State private var model: QuizFlowModel?
    /// E7.1 — non-nil mounts the bundled default paywall over the summary
    /// seam (set ONLY by the CTA remap below; the paywall never appears on
    /// any other route, and the panic route never reaches this view at all).
    @State private var paywall: PaywallModel?

    /// The UITEST_RESET-hook precedent (S18): a DEBUG-only launch-env switch,
    /// inert in every release build BY CONSTRUCTION.
    private static var paywallDebugOverride: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["UITEST_PAYWALL"] == "1"
        #else
        false
        #endif
    }

    var body: some View {
        ZStack {
            content
        }
        .task { makeModelIfNeeded() }
        .onChange(of: provider?.repository == nil) { _, _ in
            makeModelIfNeeded()
        }
    }

    /// The three-way completion seam (E5.3, Architect Q2) — mirrors the pure
    /// `QuizGateRouting.postGateScreen(hasActiveQuit:quizComplete:)` decision the
    /// unit tier pins: an in-session completion mounts the SUMMARY (P0 story 1 —
    /// before anything else; quiz_completed's canonical render surface). The CTA
    /// dismiss sets `model = nil`, which is one-way by construction — after
    /// completion a quit exists, so `makeModelIfNeeded` never rebuilds, and a
    /// relaunch lands on the dashboard (summary-once; a conservative funnel
    /// undercount, never a re-fire).
    @ViewBuilder private var content: some View {
        if let paywall {
            PaywallView(
                data: PaywallPresentation.make(copy: PaywallCopy.loadShipping() ?? .degraded),
                model: paywall,
                onUnlocked: {
                    // Entitled (purchase or restore) — fall through to the
                    // dashboard; the entitlement model already adopted the
                    // post-purchase state via the action's completed outcome.
                    self.paywall = nil
                    self.model = nil
                }
            )
        } else if let model {
            if model.isComplete {
                QuizSummaryView(
                    model: model,
                    data: summaryData(),
                    onContinue: {
                        // AC8 — the NAMED paywall seam, REMAPPED by E7.1
                        // (R24.2): a LIVE entitlement model (operator RC key
                        // present) gates the hard-ish wall; DORMANT or
                        // already-entitled falls through to the dashboard
                        // exactly as before this session — no tester is ever
                        // trapped on a build whose purchases cannot work.
                        if let entitlement = provider?.entitlementModel,
                           PaywallRouting.postSummaryDestination(state: entitlement.state) == .paywall {
                            paywall = PaywallModel(
                                purchase: { await RevenueCatPurchaser.purchase(plan: $0) },
                                restore: { await RevenueCatPurchaser.restore() }
                            )
                        } else if Self.paywallDebugOverride {
                            // R24.1: the DEBUG-only render path (UITEST_PAYWALL=1)
                            // — the operator's Xcode review substitute for the
                            // deferred goldens, and E7.2's future smoke hook.
                            // Inert actions exercise the never-trap surface.
                            paywall = PaywallModel(
                                purchase: { _ in .failed },
                                restore: { .failed }
                            )
                        } else {
                            self.model = nil
                        }
                    }
                )
            } else {
                QuizFlowView(model: model)
            }
        } else {
            // A quit already exists (or the store is still opening) — the
            // placeholder root (it carries its own anchor and the skeleton is
            // habit-free, so every state here is calm and safe).
            RootPlaceholderView()
        }
    }

    /// Display inputs from persisted truth (Architect MUST-FIX 6): the profile's
    /// filled fields + the quit's stored currencyCode + verbatim motivations —
    /// no ambient Locale read for the currency (digit grouping alone follows the
    /// device). A missing repository/profile degrades to the dignified absent
    /// card, never a dead end.
    private func summaryData() -> SummaryViewData {
        SummaryPresentation.make(
            inputs: provider?.repository?.latestSummaryInputs()
                ?? QuizSummaryInputs(savings: 0, currencyCode: "USD", riskToken: nil, motivations: []),
            copy: SummaryCopy.loadShipping() ?? .degraded
        )
    }

    /// Builds the quiz model once the repository publishes and ONLY when the
    /// routing decision says onboarding is due — an install with a quit never
    /// constructs quiz state (mirrors AgeGateContainerView.makeModelIfNeeded).
    private func makeModelIfNeeded() {
        guard model == nil,
              let repository = provider?.repository,
              QuizGateRouting.postGateScreen(
                  hasActiveQuit: ((try? repository.activeQuits())?.isEmpty == false)
              ) == .quiz
        else { return }
        model = QuizFlowModel(
            config: QuizConfig.loadShipping() ?? .degraded,
            analytics: repository.analyticsService,
            checkpoint: QuizProgressStore(),
            variant: repository.onboardingVariant(),
            onComplete: { [weak repository] answers in
                guard let repository else { return }
                try repository.completeQuiz(answers)
            },
            // try? is the safe direction (the age-gate persistPass precedent): a
            // failed save keeps the durable value OFF — fail-closed, never a
            // silently-open gate.
            persistConsent: { [weak repository] optedIn in
                try? repository?.setAnalyticsOptIn(optedIn)
            }
        )
    }
}
