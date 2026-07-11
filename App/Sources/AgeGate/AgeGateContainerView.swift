import SwiftUI

/// E5.1 — the normal route's ROOT: the age gate stands ABOVE all habit content
/// (Architect §3a, Session 16), so E5.2's replacement of the placeholder inherits
/// the gate for free. Fail-closed at every step: while the store opens (post-frame
/// `startIfNeeded`) a neutral non-habit frame shows; once the repository publishes,
/// the pure `AgeGateRouting.firstScreen` decision stands until a store-truth
/// `ageGatePassed` (or the in-session pass transition the Architect sanctioned —
/// the durable Bool is the record, the local phase drives the frame).
///
/// The panic route NEVER mounts this container (ADR-6): pre-gate the panic
/// pre-cache is empty by construction, so that route renders only the bare
/// breathe frame — zero habit content, pinned by the existing resolver tests.
///
/// Carries the route-level `root.placeholder` anchor in every state — the smoke
/// lane discriminates normal-root vs panic-root, and this container IS the normal
/// root now (the fresh-install root "where onboarding mounts", per the E2.4 smoke's
/// own scope note; the age gate is onboarding's first screen). `RootPlaceholderView`'s
/// skeleton keeps its own byte-pinned anchor untouched.
struct AgeGateContainerView: View {
    @Environment(RepositoryProvider.self) private var provider: RepositoryProvider?
    @State private var model: AgeGateModel?

    var body: some View {
        ZStack {
            content
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("root.placeholder")
        .task { makeModelIfNeeded() }
        .onChange(of: provider?.repository == nil) { _, _ in
            makeModelIfNeeded()
        }
    }

    @ViewBuilder private var content: some View {
        if let model {
            switch model.phase {
            case .entry:
                AgeGateView(model: model)
            case .blocked:
                AgeGateBlockedView(model: model)
            case .passed:
                // E5.2: the passed branch mounts the post-gate router (quiz until a
                // quit exists, then the placeholder root) — new content inherits the
                // gate for free, exactly as this container was designed.
                PostGateRootView()
            }
        } else if let repository = provider?.repository,
                  AgeGateRouting.firstScreen(ageGatePassed: repository.isAgeGatePassed()) == .onward {
            // A previously-passed install: no model is ever built, content mounts
            // directly from store truth.
            PostGateRootView()
        } else {
            // Store still opening — neutral, non-habit, no premature pass
            // (Architect MUST-FIX #7). Brand rules hold even here: no red,
            // SF Symbols only, zero habit lexicon.
            VStack(spacing: 12) {
                Image(systemName: "circle.dashed")
                    .font(.largeTitle)
                    .foregroundStyle(.teal)
                    .accessibilityHidden(true)
            }
            .padding(20)
        }
    }

    /// Builds the gate's flow model once the repository publishes and only when the
    /// gate is actually unpassed — a passed install never constructs gate state.
    /// `currentYear` derives from LiveClock (the one sanctioned Date() reader) at
    /// composition time — never a bare Date() (Architect MUST-FIX #4).
    private func makeModelIfNeeded() {
        guard model == nil,
              let repository = provider?.repository,
              AgeGateRouting.firstScreen(ageGatePassed: repository.isAgeGatePassed()) == .ageGate
        else { return }
        let currentYear = Calendar.current.component(.year, from: LiveClock().now)
        model = AgeGateModel(
            analytics: .disabled,
            currentYear: currentYear,
            // try? is the safe direction: a failed save keeps the durable flag
            // false, so the worst case is a re-ask on the next launch — never a
            // silently-open gate.
            persistPass: { [weak repository] in try? repository?.markAgeGatePassed() }
        )
    }
}
