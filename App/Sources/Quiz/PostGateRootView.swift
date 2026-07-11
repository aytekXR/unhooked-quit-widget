import SwiftUI

/// E5.2 — what the age-gate container mounts once the gate passes (Architect
/// MUST-FIX 8): the pure `QuizGateRouting` decision over store truth. No active
/// quit → the onboarding quiz (content is reachable ONLY through gate → quiz →
/// quit — the Epic-5 DoD un-bypassability seam); a quit exists → the dashboard
/// placeholder. Completion flips the published handoff and this view re-routes.
///
/// Composition (MUST-FIX 7): the QuizProfile is assembled by the repository —
/// this view hands the model `repository.completeQuiz` as a method reference and
/// never touches SwiftData itself. Production analytics is `.disabled` (the
/// AgeGateModel precedent; consent is hardwired OFF until E8.2) — the fire-points
/// are live and spy-proven, the transport is not.
struct PostGateRootView: View {
    @Environment(RepositoryProvider.self) private var provider: RepositoryProvider?
    @State private var model: QuizFlowModel?

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
        if let model {
            if model.isComplete {
                QuizSummaryView(
                    model: model,
                    data: summaryData(),
                    onContinue: {
                        // AC8 — the NAMED paywall seam: E7 remaps this dismiss to
                        // PaywallView; this session it falls to the placeholder
                        // dashboard below.
                        self.model = nil
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
            analytics: .disabled,
            checkpoint: QuizProgressStore(),
            variant: repository.onboardingVariant(),
            onComplete: { [weak repository] answers in
                guard let repository else { return }
                try repository.completeQuiz(answers)
            }
        )
    }
}
