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
///
/// ME-8 (Session 53) adds `field`: an OPTIONAL decorative layer drawn between the
/// `surface/base` backdrop and the content column (the Waterline field, §9.6).
/// Three notes on why it is shaped this way:
///
/// - **It must live INSIDE the scaffold.** `themedScreenSurface()` paints an OPAQUE
///   `surface/base`, so a caller applying `.background(field)` from outside would
///   render it underneath and see nothing. The layer has to be inserted above the
///   backdrop and below the content, which only the scaffold can do.
/// - **It is opt-IN, and that is a spec requirement, not a preference.** Creative
///   §2 BANS the field from widgets, the panic path's first frame, every discreet
///   surface, and the app-switcher shield. A field that arrived automatically for
///   all five current consumers would violate that by default; `nil` means the four
///   non-quiz callers are untouched.
/// - **`nil` takes the byte-identical original path.** The no-field branch calls
///   `themedScreenSurface()` exactly as before rather than an equivalent-looking
///   ZStack, so the 12 existing goldens on scaffold-based screens (8 widget-adoption
///   + 4 quiz-summary) cannot move. "Structurally equivalent" is the kind of claim
///   that costs a billed run to disprove; taking the same code path costs nothing.
///
/// `AnyView` is deliberate over a fourth generic parameter. A generic would be
/// marginally cheaper at runtime for a layer that redraws only on step change, and
/// would cost a default-less `field:` in the primary init — which forces surgery on
/// the constrained convenience extension and puts all five call sites' overload
/// resolution at risk. None of that is checkable on this project's Linux box
/// (`swiftc -parse` is syntax only), so it would be verified by a billed macOS run.
/// One defaulted parameter changes no existing call site at all.
struct OnboardingScaffold<Header: View, Content: View, Actions: View>: View {
    /// Identity of the CONTENT currently on show (the quiz passes its step id). When
    /// it changes, the ScrollView is rebuilt — so a new question opens at the TOP
    /// instead of inheriting the previous question's scroll offset, and the step's
    /// transient `@State` resets with it. The header and the action bar keep STABLE
    /// identity across the change, so the progress bar still ANIMATES its fill rather
    /// than jumping. (Screens with a single, unchanging content view leave it nil.)
    private let contentID: String?
    /// ME-8: the decorative backdrop layer. `nil` on every surface the Waterline
    /// spec bans it from — which is all four non-quiz consumers today.
    private let field: AnyView?
    private let header: () -> Header
    private let content: () -> Content
    private let actions: () -> Actions

    /// Declared explicitly (not left to the memberwise init) so the result-builder
    /// attribute is unambiguously on the PARAMETERS: the quiz passes an `if let`
    /// into `content`, which only compiles under a `@ViewBuilder` parameter.
    init(
        contentID: String? = nil,
        field: AnyView? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder actions: @escaping () -> Actions
    ) {
        self.contentID = contentID
        self.field = field
        self.header = header
        self.content = content
        self.actions = actions
    }

    var body: some View {
        if let field {
            // The field branch reproduces `themedScreenSurface()`'s own two
            // modifiers (fill the screen, then paint the backdrop) with the
            // decorative layer composited over the backdrop inside the SAME
            // background slot — so the content column's layout is untouched and
            // only the backdrop gained a tint.
            column
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    ZStack {
                        Theme.color.surfaceBase.color
                        field
                    }
                    .ignoresSafeArea()
                )
        } else {
            column.themedScreenSurface()
        }
    }

    /// The content column — identical in both branches, so a field can never
    /// change the measure, the scroll behaviour, or the pinned action zone.
    private var column: some View {
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
    }
}

extension OnboardingScaffold where Header == EmptyView {
    /// ME-4 (S54) forwards `field:` here too. The slot existed only on the PRIMARY
    /// init, and the quiz summary — the field's second consumer — is a header-less
    /// screen, so it reaches the scaffold through THIS init and could not have
    /// passed a field at all. Defaulted to `nil`, so the age gate, the blocked
    /// screen and the widget moment keep the byte-identical no-field path.
    init(
        field: AnyView? = nil,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder actions: @escaping () -> Actions
    ) {
        self.init(field: field, header: { EmptyView() }, content: content, actions: actions)
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
