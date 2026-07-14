import SwiftUI

/// UIR-1 (Session 33) — the onboarding screen shell. Every onboarding surface has
/// the same skeleton, and that skeleton is the Dynamic-Type fix ITSELF, not a
/// styling choice:
///
/// - **Content SCROLLS.** The S28 audit's `.dynamicType` findings (run
///   29262073722: 4 panic redirect rows + the slip forgiveness body) all sit in
///   NON-scrollable, height-bounded containers — at accessibility sizes the parent
///   has no room to give and the text is predicted clipped. Every element that
///   fired lives outside a ScrollView; every quiz element that PASSED lives inside
///   one. The scaffold makes "the text can always grow" structural.
/// - **Actions are PINNED, never scrolled away** (brandkit §5 one-hand rule:
///   primary actions in the lower 60%; "quiz Continue is a bottom-pinned bar").
///   The action zone sits OUTSIDE the ScrollView, so a control the user needs is
///   never below the fold — and, for the age gate, so the wheel picker keeps its
///   own scroll gesture instead of fighting an ancestor's.
/// - **The measure is capped** at `Theme.layout.contentMaxWidth` (brandkit §5),
///   which keeps body copy near the ~34ch conversational line length and makes
///   every screen iPad-safe without a second layout.
///
/// `header` is the always-visible top slot (the quiz's progress bar). It is
/// EmptyView by default — use `init(content:actions:)` on screens without one.
struct OnboardingScaffold<Header: View, Content: View, Actions: View>: View {
    /// Identity of the CONTENT currently on show (the quiz passes its step id). When
    /// it changes, the ScrollView is rebuilt — so a new question opens at the TOP
    /// instead of inheriting the previous question's scroll offset, and the step's
    /// transient `@State` resets with it. The header and the action bar keep STABLE
    /// identity across the change, so the progress bar still ANIMATES its fill rather
    /// than jumping. (Screens with a single, unchanging content view leave it nil.)
    private let contentID: String?
    private let header: () -> Header
    private let content: () -> Content
    private let actions: () -> Actions

    /// Declared explicitly (not left to the memberwise init) so the result-builder
    /// attribute is unambiguously on the PARAMETERS: the quiz passes an `if let`
    /// into `content`, which only compiles under a `@ViewBuilder` parameter.
    init(
        contentID: String? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder actions: @escaping () -> Actions
    ) {
        self.contentID = contentID
        self.header = header
        self.content = content
        self.actions = actions
    }

    var body: some View {
        VStack(spacing: Theme.space.s5) {
            header()
                .measured()

            ScrollView {
                content()
                    .measured()
                    .padding(.top, Theme.space.s2)
                    .padding(.bottom, Theme.space.s4)
            }
            .scrollBounceBehavior(.basedOnSize)
            .id(contentID)

            actions()
                .measured()
        }
        .padding(.horizontal, Theme.space.s5)
        .padding(.top, Theme.space.s4)
        .padding(.bottom, Theme.space.s5)
        .themedScreenSurface()
    }
}

extension OnboardingScaffold where Header == EmptyView {
    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder actions: @escaping () -> Actions
    ) {
        self.init(header: { EmptyView() }, content: content, actions: actions)
    }
}

private extension View {
    /// The brandkit §5 measure: centre a single column that never exceeds the
    /// content max-width, while still filling narrow screens edge-to-edge.
    func measured() -> some View {
        frame(maxWidth: Theme.layout.contentMaxWidth)
            .frame(maxWidth: .infinity)
    }
}
