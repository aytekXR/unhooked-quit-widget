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

    @ViewBuilder private var content: some View {
        if let model, !model.isComplete {
            QuizFlowView(model: model)
        } else {
            // A quit already exists, the quiz just completed, or the store is
            // still opening — the placeholder root (it carries its own anchor and
            // the skeleton is habit-free, so every state here is calm and safe).
            RootPlaceholderView()
        }
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
