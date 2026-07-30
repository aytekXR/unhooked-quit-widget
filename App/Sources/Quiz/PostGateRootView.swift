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
    /// seam (set ONLY by the CTA remap + the R25.7 teaser-expiry re-entry
    /// below; the paywall never appears on any other route, and the panic
    /// route never reaches this view at all).
    @State private var paywall: PaywallModel?
    /// E7.2 — the composed screen data for the CURRENT presentation (the
    /// variant/source fork happens at present time, so the data is stashed
    /// with the model rather than recomposed in `body`).
    @State private var paywallData: PaywallViewData?
    /// E7.3 (R26.6, vetoable cadence): the win-back auto-present fires at
    /// most ONCE PER PROCESS — in-memory only, no persistence; the settings
    /// row is the persistent path back to the offer. Teaser-expiry
    /// re-presents keep their E7.2 cadence (unguarded).
    @State private var didAutoPresentWinback = false
    /// ME-1 (redesign §5.1/§6.15) — the widget-adoption moment, mounted once per
    /// funnel completion, immediately post-entitlement-resolution: after the
    /// ONBOARDING paywall resolves (unlocked or teaser taken) on live-key
    /// builds, straight after the summary CTA on dormant ones. In-memory only —
    /// the summary itself is summary-once by construction, so this can never
    /// re-prompt on a later launch; the persistent re-entry is the Settings
    /// panic-access row (ME-7's rebuilt Settings, deferred).
    @State private var showsWidgetAdoption = false
    /// ME-1 — which surface the mounted paywall was presented FOR: only the
    /// `.onboarding` presentation routes into the adoption moment on dismissal
    /// (win-back and teaser-expiry re-presents return to the dashboard as
    /// before). Set beside `paywallData`, cleared in `dismissPaywall`.
    @State private var presentedPaywallSource: PaywallSource?
    /// S46 (operator §3) — the alcohol withdrawal notice on the SUMMARY, the
    /// screen every completer meets BEFORE the paywall. Same once-per-process
    /// consideration latch as the dashboard mount (`RootPlaceholderView`); the
    /// durable once-guarantee is the `recordAlcoholNoticeShown()` stamp, so
    /// whichever mount fires first permanently closes the other.
    @State private var didConsiderAlcoholNotice = false
    @State private var showsAlcoholNotice = false
    /// The notice's "See resources" hand-off. `SafetyResourcesView` is store-free
    /// by construction, so the summary can present it without the dashboard's
    /// repository-gated subtree. Nil source = out-of-domain open, fires nothing (R27.4).
    @State private var showsResources = false
    @Environment(\.scenePhase) private var scenePhase

    /// E9.1 — the notice copy, fail-SAFE (R27.6): a missing table or section still
    /// renders the plain calm caution, never silently nothing.
    private let alcoholNoticeCopy = SafetyCopy.loadShipping()?.alcoholWithdrawalNotice
        ?? SafetyCopy.AlcoholNotice.degraded

    /// The UITEST_RESET-hook precedent (S18): a DEBUG-only launch-env switch,
    /// inert in every release build BY CONSTRUCTION. E7.2 (R25.9): `1` keeps
    /// the S24 behavior (the HARD render — back-compat for the operator's
    /// review path), `teaser` renders the teaser variant — the operator's
    /// both-variant eyeball path while the goldens ride the founder-copy
    /// batch.
    private static var paywallDebugVariant: PaywallVariant? {
        #if DEBUG
        switch ProcessInfo.processInfo.environment["UITEST_PAYWALL"] {
        case "1": .hard
        case "teaser": .teaser
        default: nil
        }
        #else
        nil
        #endif
    }

    /// E9.3 (R28.6) — the a11y-audit quiz-leg mount, on the UITEST_PAYWALL
    /// precedent above: a DEBUG-only launch-env switch, inert in every release
    /// build BY CONSTRUCTION. `1` force-mounts the real quiz over the shipping
    /// config with `.disabled` analytics, bypassing the routing gate +
    /// repository + `makeModelIfNeeded` chain so `performAccessibilityAudit`
    /// reaches a representative first step deterministically — NEVER the
    /// scenario-29 gate→quiz hand-off. A TEST-LANE mount only: it opens no path
    /// to habit content in any shipping build (the gate un-bypassability seam
    /// stays pinned at the unit tier, S18), and the age gate ABOVE this view is
    /// never bypassed — only the post-gate routing decision is.
    private static var uiTestQuizMount: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["UITEST_QUIZ"] == "1"
        #else
        false
        #endif
    }

    /// UIR-1 (R33.4) — the a11y-audit SUMMARY leg's mount, on the UITEST_QUIZ
    /// precedent above: a DEBUG-only launch-env switch, inert in every release build
    /// BY CONSTRUCTION. The summary is the one onboarding surface no drive can reach
    /// deterministically without completing the whole quiz (11 steps, two of them
    /// keyboard-bound), and it is the surface whose Dynamic-Type behaviour UIR-1
    /// rebuilt — so the audit needs a mount, exactly as the quiz leg did.
    ///
    /// It opens NO path to habit content: it renders the payoff SCREEN over the
    /// shipping copy table and a fixture, with `.disabled` analytics (so the
    /// summary's quiz_completed fire is structurally impossible — the model has no
    /// completion handoff either), no repository, no store, and a no-op forward
    /// seam. The gate's un-bypassability stays unit-pinned (S18).
    private static var uiTestSummaryMount: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["UITEST_SUMMARY"] == "1"
        #else
        false
        #endif
    }

    /// UIR-2 (R34) — the a11y-audit DASHBOARD leg's mount, on the UITEST_SUMMARY
    /// precedent above: a DEBUG-only launch-env switch, inert in every release build BY
    /// CONSTRUCTION. The dashboard is the surface UIR-2 built, and it is reachable in
    /// production only after gate → quiz → quit creation, so the audit needs a direct
    /// mount exactly as the summary leg did. It renders a single fixture
    /// `StreakDashboardCard` (a value model — no repository, no store, no `Quit`), so it
    /// opens NO path to habit content and fires nothing.
    private static var uiTestDashboardMount: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["UITEST_DASHBOARD"] == "1"
        #else
        false
        #endif
    }

    /// UIR-4 (R36) — the a11y-audit RESOURCES leg's mount, on the UITEST_DASHBOARD
    /// precedent: a DEBUG-only launch-env switch, inert in every release build BY
    /// CONSTRUCTION. Renders the real `SafetyResourcesView` (store-free by construction)
    /// with `.disabled` analytics so the audit reaches the helpline surface — including
    /// the R33.10-corrected DIAL link — deterministically.
    private static var uiTestResourcesMount: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["UITEST_RESOURCES"] == "1"
        #else
        false
        #endif
    }

    /// UIR-5 (R38) — the a11y-audit PAYWALL leg's direct mount (the UITEST_PAYWALL=1 gate
    /// needs the whole quiz→summary→CTA drive; this switch mounts the hard-variant paywall
    /// straight over a fixture with INERT `.failed` purchase/restore closures — no store
    /// path, no echo). DEBUG-only, release-inert BY CONSTRUCTION.
    private static var uiTestPaywallDirectMount: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["UITEST_PAYWALL_DIRECT"] == "1"
        #else
        false
        #endif
    }

    /// ME-1 — the a11y-audit/operator-eyeball WIDGET-MOMENT direct mount, on the
    /// UITEST_SUMMARY precedent: a DEBUG-only launch-env switch, inert in every
    /// release build BY CONSTRUCTION. The adoption screen is reachable in
    /// production only through the whole funnel, so the audit needs a mount. It
    /// renders the real view over the shipping copy table and a deterministic
    /// fixture feed, with `.disabled` analytics and NO handshake suite — it
    /// opens no path to habit content and fires nothing.
    private static var uiTestWidgetMomentMount: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["UITEST_WIDGET_MOMENT"] == "1"
        #else
        false
        #endif
    }

    /// ME-7 (S50) — the a11y-audit SETTINGS leg's mount, on the UITEST_RESOURCES
    /// precedent: a DEBUG-only launch-env switch, inert in every release build BY
    /// CONSTRUCTION.
    ///
    /// This leg existed and was reverted THREE times (S38 `3053b06`/`513edcb`,
    /// S39 `0a4bcda`/`56eb13d`, S40 `7d861d5`/`52eafa6`) because the screen it audited
    /// could not pass inside a `List`. ME-7 removed the `List`, so it comes back.
    ///
    /// SCOPE, stated so it is never overclaimed: the mount injects no
    /// `RepositoryProvider`, so only the two repository-FREE sections render — *Panic
    /// access* and *Support & resources*. Those two happen to carry the free-standing
    /// screen title (R39.1) and the "Support & resources" row that defeated five S40
    /// runs, which is the coverage that matters most here. The per-quit toggles, icon
    /// picker, Breathing caption (R39.2) and Your-plan row are NOT in this render;
    /// `SettingsSourceLintTests` is what holds their invariant instead.
    private static var uiTestSettingsMount: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["UITEST_SETTINGS"] == "1"
        #else
        false
        #endif
    }

    /// S50 (S49 audit §1) — the a11y-audit ERASE-CONFIRM leg's mount. The erase surface
    /// was the S49 audit's HIGH finding AND its structural lesson: erase is not one of
    /// the audited surfaces, so no CI lane could ever have caught the defect. It is a
    /// DIRECT mount because the settings erase row is repository-gated, so no
    /// `UITEST_*` settings render can reach the sheet.
    ///
    /// Inert by construction: the `EraseFlow` closures are no-ops, so the audit can
    /// never destroy data even if something drove the hold — the `#Preview` /
    /// `EraseEverythingSnapshotTests` fixture, verbatim.
    private static var uiTestEraseMount: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["UITEST_ERASE_FLOW"] == "1"
        #else
        false
        #endif
    }

    /// ME-3 (S51) — the a11y-audit MILESTONE-UNLOCK leg's mount. The card is reachable in
    /// production only by actually crossing a rung, so the audit needs a direct mount, and
    /// it is a new surface carrying more text than any other card (the catalog body plus
    /// the signed not-medical-care hedge) — exactly the shape S50 proved goes unchecked
    /// otherwise. Remember this env var is TWO edits: it also belongs in
    /// `AgeGateContainerView.uiTestOnboardingMount`'s allow-list, or the leg times out on a
    /// fresh install blaming the view (`UITestMountCoherenceTests` enforces it).
    private static var uiTestMilestoneUnlockMount: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["UITEST_MILESTONE_UNLOCK"] == "1"
        #else
        false
        #endif
    }

    var body: some View {
        ZStack {
            content
        }
        .overlay(alignment: .bottomTrailing) { debugEventSpyBridge }
        .task { makeModelIfNeeded() }
        .onChange(of: provider?.repository == nil) { _, _ in
            makeModelIfNeeded()
        }
        // S46 — the notice's resources hand-off, mounted at this level so the
        // SUMMARY can reach it (the dashboard keeps its own identical mount).
        .sheet(isPresented: $showsResources) {
            SafetyResourcesView(
                source: nil,
                analytics: provider?.repository?.analyticsService ?? .disabled
            )
        }
    }

    /// S46 (operator §3) — the summary's once-per-process notice consideration,
    /// mirroring `RootPlaceholderView.considerAlcoholNotice`: stamps AT DISPLAY
    /// through the ONE writer and latches so a re-render never re-presents. A
    /// failed stamp write is the silent-recover class — the card still shows now,
    /// and a fail-open re-show later errs toward showing a safety notice.
    private func considerAlcoholNotice() {
        guard !didConsiderAlcoholNotice else { return }
        guard let repository = provider?.repository else { return }
        didConsiderAlcoholNotice = true
        guard repository.shouldShowAlcoholNotice() else { return }
        try? repository.recordAlcoholNoticeShown()
        showsAlcoholNotice = true
    }

    /// The slot handed to `QuizSummaryView` — nil unless this completer is due
    /// the notice, so every non-alcohol summary renders exactly as before.
    private var alcoholNoticeSlot: AlcoholNoticeSlot? {
        guard showsAlcoholNotice else { return nil }
        return AlcoholNoticeSlot(
            copy: alcoholNoticeCopy,
            onDismiss: { showsAlcoholNotice = false },
            onSeeResources: { showsResources = true }
        )
    }

    /// S29 (R29.5) — the event spy's a11y READ bridge: a visually-inert 1×1
    /// LEAF element (never a `.contain` container — the Session-09 lesson)
    /// whose accessibilityValue is the spy's ordered wire-name list. It sits
    /// on the post-gate ZStack, OUTSIDE `content`, so it survives every
    /// branch of the funnel (quiz → summary → paywall, all in-place content
    /// swaps). Exists ONLY when the spy env var arms it (DEBUG builds; the
    /// a11y-audit legs never arm it, so the audits never meet an unlabeled
    /// stray) — release compiles it out entirely.
    @ViewBuilder private var debugEventSpyBridge: some View {
        #if DEBUG
        if DebugEventSpySink.isArmed,
           let spy = provider?.repository?.analyticsService.sink as? DebugEventSpySink {
            Color.clear
                .frame(width: 1, height: 1)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Debug event spy")
                .accessibilityValue(spy.accessibilityBridgeValue)
                .accessibilityIdentifier("debug.eventSpy")
        }
        #endif
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
        if Self.uiTestQuizMount {
            // R28.6 — the a11y-audit quiz leg's direct mount: the real quiz over
            // the shipping config (`.disabled` analytics), skipping the routing
            // gate/store/`makeModelIfNeeded` chain so the audit reaches a
            // representative first step (a singleChoice, no keyboard) without the
            // scenario-29 hand-off. Inert in release BY CONSTRUCTION.
            QuizFlowView(model: QuizFlowModel(
                config: QuizConfig.loadShipping() ?? .degraded,
                analytics: .disabled
            ))
        } else if Self.uiTestSummaryMount {
            debugSummaryMount
        } else if Self.uiTestDashboardMount {
            debugDashboardMount
        } else if Self.uiTestResourcesMount {
            debugResourcesMount
        } else if Self.uiTestPaywallDirectMount {
            debugPaywallDirectMount
        } else if Self.uiTestWidgetMomentMount {
            debugWidgetMomentMount
        } else if Self.uiTestSettingsMount {
            debugSettingsMount
        } else if Self.uiTestMilestoneUnlockMount {
            debugMilestoneUnlockMount
        } else if Self.uiTestEraseMount {
            debugEraseMount
        } else if let paywall, let paywallData {
            PaywallView(
                data: paywallData,
                model: paywall,
                onUnlocked: {
                    // Entitled (purchase or restore) — fall through immediately:
                    // the user just paid, nothing should stand between them and
                    // the app. ME-1: the ONBOARDING route continues into the
                    // widget-adoption moment (post-entitlement-resolution, §5.1);
                    // every other presentation returns to the dashboard as before.
                    let fromOnboarding = presentedPaywallSource == .onboarding
                    dismissPaywall()
                    if fromOnboarding { showsWidgetAdoption = true }
                    // R46.2 FIX (S48). The comment that used to sit here claimed
                    // "the entitlement model already adopted the post-purchase
                    // state" — it did not. `PaywallModel.purchase`/`restore` call
                    // `RevenueCatPurchaser` statically and never touch
                    // `EntitlementModel`, and `makeOnPurchaseCompleted` receives
                    // the fresh `EntitlementState` only to fire analytics with it
                    // and drop it. So `entitlementModel.state` stayed frozen at
                    // its launch value for the whole session, against its own
                    // documented contract ("refresh on construction, after
                    // purchase/restore, and on foreground").
                    //
                    // The user-visible harm: the win-back settings row is gated on
                    // that state, so someone who JUST subscribed kept seeing "See
                    // your plan options" and could be walked back into the
                    // half-price offer. Not a double charge — StoreKit refuses a
                    // second purchase of an active subscription — but a paying
                    // subscriber repeatedly handed a purchase sheet is a support
                    // burden and a 3.1.2 smell.
                    //
                    // Dismiss first, refresh after: the refresh is a network
                    // round trip and `@Observable` re-renders the row when it
                    // lands, so correctness costs no perceived latency.
                    Task { await provider?.entitlementModel?.refresh() }
                },
                onTeaserDismiss: {
                    // R25.7: the take already fired teaser_entered + stamped
                    // the grant (single-use); the day of access begins here.
                    // ME-1: the onboarding teaser-take is entitlement-resolution
                    // too — the adoption moment follows (never on the
                    // teaser-EXPIRY re-present, whose source is .teaserExpiry).
                    let fromOnboarding = presentedPaywallSource == .onboarding
                    dismissPaywall()
                    if fromOnboarding { showsWidgetAdoption = true }
                },
                onWinbackDismiss: {
                    // R26.6: the offer never traps — "Not now" returns to
                    // the dashboard, wordlessly (no event fires).
                    dismissPaywall()
                }
            )
        } else if showsWidgetAdoption {
            // ME-1 — the widget-adoption moment (§6.15): the funnel's
            // post-entitlement step. The preview renders the TRUE App Group
            // feed (the repository's launch/summary writes already produced
            // it), the analytics service is the ONE repository-vended gated
            // facade, and the continue seam lands on the dashboard branch.
            WidgetAdoptionView(
                copy: WidgetMomentCopy.loadShipping() ?? .degraded,
                feed: WidgetStateStore.appGroup()?.read(),
                now: LiveClock().now,
                analytics: provider?.repository?.analyticsService ?? .disabled,
                onContinue: { showsWidgetAdoption = false }
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
                            Task { await presentLivePaywall(source: .onboarding) }
                        } else if let debugVariant = Self.paywallDebugVariant {
                            // R24.1/R25.9: the DEBUG-only render path
                            // (UITEST_PAYWALL=1|teaser) — the operator's Xcode
                            // review substitute for the deferred goldens and
                            // the scenario-29 smoke's mount hook. Inert
                            // purchase actions exercise the never-trap
                            // surface; the presentation fire is REAL (through
                            // the ONE consent gate, echo-free — the smoke's
                            // event tail stays true for release builds).
                            presentDebugPaywall(variant: debugVariant)
                        } else {
                            // ME-1 (§5.1): dormant builds resolve entitlement by
                            // fall-through — the adoption moment mounts here, and
                            // its own continue lands on the dashboard.
                            self.model = nil
                            showsWidgetAdoption = true
                        }
                    },
                    alcoholNotice: alcoholNoticeSlot
                )
                // S46 — consider the notice as the summary appears, i.e. BEFORE
                // the CTA can route a non-converter into the hard paywall.
                .onAppear { considerAlcoholNotice() }
            } else {
                QuizFlowView(model: model)
            }
        } else {
            // A quit already exists (or the store is still opening) — the
            // placeholder root (it carries its own anchor and the skeleton is
            // habit-free, so every state here is calm and safe).
            // E7.2 (R25.7): this dashboard branch is the teaser re-entry
            // surface — evaluated on appear and on foreground return, ONLY
            // when a live entitlement model exists (dormant builds never
            // re-present; E9's real dashboard inherits this rule —
            // binding-on-future-surfaces). Expiry is SILENT: the wall simply
            // returns at the next qualifying entry (no countdown, §6.8).
            // E7.3 (R26.6): the same gate now also slots the win-back OFFER
            // (entitled > winback > teaser-expiry; auto-present once per
            // process, dismissible), and the settings row is the persistent
            // second surface.
            // ME-9 (S58): the *Your plan* row hands its OWN source up —
            // `.winback` for an eligible lapsed subscriber (which swaps in the
            // signed promotional-offer purchase path), `.settings` for a
            // never-paid user (the standard plans). See
            // `PaywallRouting.planRowSource`.
            RootPlaceholderView(onPlanRowTap: { source in
                Task { await presentLivePaywall(source: source) }
            })
                .task { checkPaywallReentry() }
                .onChange(of: scenePhase) { _, phase in
                    guard phase == .active else { return }
                    // R46.2 FIX (S48) — the SECOND half. `checkPaywallReentry`
                    // reads `entitlementModel.state`, and before this the only
                    // `refresh()` in the app ran once at launch
                    // (`RepositoryProvider`), so every foreground re-evaluated a
                    // launch-time snapshot. A trial that lapsed mid-session kept
                    // full access until the next COLD launch — which, for an app
                    // people leave resident for days, can be a long time.
                    //
                    // Refresh first, then decide: the whole point of this hook is
                    // to notice an entitlement CHANGE that happened while the app
                    // was away, and asking the question against stale data cannot
                    // do that.
                    Task {
                        await provider?.entitlementModel?.refresh()
                        checkPaywallReentry()
                    }
                }
        }
    }

    /// R33.4 — the summary leg's frame, compiled out of release ENTIRELY (not merely
    /// unreachable). It renders the REAL view through the REAL assembler
    /// (`SummaryPresentation.make`), so the audited frame is the shipping one: savings
    /// hero + risk-window line + motivation echo, the three blocks whose layout UIR-1
    /// changed.
    ///
    /// What the fixture supplies is exactly what a USER supplies in production — never
    /// copy: the savings NUMBER, the currency, the risk-window TOKEN (which
    /// `SummaryCopy.phrase(forToken:)` resolves to the shipping phrase), and the
    /// user's own motivation WORDS. The two motivation words here are lifted verbatim
    /// from `quizConfig.json`'s motivations step (choice labels "Energy" / "Money") —
    /// an audited table, so no string on this frame is authored here. Every framing
    /// string (eyebrow, caption, intro, CTA) comes from `summaryCopy.json` as always.
    @ViewBuilder private var debugSummaryMount: some View {
        #if DEBUG
        QuizSummaryView(
            model: QuizFlowModel(
                config: QuizConfig.loadShipping() ?? .degraded,
                analytics: .disabled
            ),
            data: SummaryPresentation.make(
                inputs: QuizSummaryInputs(
                    savings: 1350,
                    currencyCode: "USD",
                    riskToken: "evenings",
                    motivations: ["Energy", "Money"]
                ),
                copy: SummaryCopy.loadShipping() ?? .degraded
            ),
            onContinue: {}
        )
        #else
        EmptyView()
        #endif
    }

    /// R34 — the dashboard leg's frame, compiled out of release ENTIRELY. Renders one
    /// `StreakDashboardCard` over a deterministic fixture value model (active,
    /// non-discreet, non-frozen) inside a `ScrollView`, so the audit exercises the same
    /// scroll-plus-grow contract a real card sits in (R33.5). The fixture carries no copy
    /// — every number is ADR-11 data — and touches no store; the mount fires nothing.
    @ViewBuilder private var debugDashboardMount: some View {
        #if DEBUG
        ScrollView(.vertical) {
            StreakDashboardCard(
                model: StreakCardModel(
                    dayNumber: 34,
                    moneySaved: 412,
                    currencyCode: "USD",
                    momentumFraction: 0.82,
                    milestoneProgress: 0.45,
                    isDiscreet: false,
                    isReduceMode: false,
                    isFrozen: false
                ),
                accessibilityID: "dashboard.card.fixture"
            )
            .padding(Theme.space.s5)
        }
        .themedScreenSurface()
        #else
        EmptyView()
        #endif
    }

    /// ME-1 — the widget-moment leg's frame, compiled out of release ENTIRELY.
    /// The real view over the shipping copy table and a deterministic fixture
    /// feed (pure ADR-11 data — a Day-1 quit with a small spend), `.disabled`
    /// analytics, and a nil handshake suite so detection/fire are structurally
    /// inert. No habit content: the feed is label-free by design (§10).
    @ViewBuilder private var debugWidgetMomentMount: some View {
        #if DEBUG
        WidgetAdoptionView(
            copy: WidgetMomentCopy.loadShipping() ?? .degraded,
            feed: WidgetFeed(
                generatedAt: Date(timeIntervalSince1970: 1_783_425_600),
                quits: [
                    WidgetQuitState(
                        id: UUID(uuidString: "0E32C0DE-0000-4000-8000-000000000001")!,
                        streakStart: Date(timeIntervalSince1970: 1_783_425_600 - 3_600),
                        timeZoneIdentifier: "America/New_York",
                        weeklySpend: "26.50",
                        currencyCode: "USD",
                        bankedCleanSeconds: 0,
                        momentumPercent: 100,
                        milestoneHours: [12, 24, 72],
                        discreet: nil
                    ),
                ]
            ),
            now: Date(timeIntervalSince1970: 1_783_425_600),
            analytics: .disabled,
            handshakeDefaults: nil,
            onContinue: {}
        )
        #else
        EmptyView()
        #endif
    }

    /// R36 — the resources leg's frame, compiled out of release ENTIRELY. Renders the
    /// real `SafetyResourcesView` (store-free) with `.disabled` analytics; the `.settings`
    /// source fires nothing on this inert mount.
    @ViewBuilder private var debugResourcesMount: some View {
        #if DEBUG
        SafetyResourcesView(source: .settings, analytics: .disabled)
        #else
        EmptyView()
        #endif
    }

    /// ME-7 (S50) — the settings leg's frame, compiled out of release ENTIRELY. The real
    /// rebuilt `DiscreetSettingsView`. BOTH repository-free closures are wired: with only
    /// `onResourcesRowTap` the *Panic access* section does not render at all, and the leg
    /// would audit one row — the shape the three reverted attempts had. Every hand-off is
    /// a no-op, so the mount opens no path to habit content and fires nothing.
    @ViewBuilder private var debugSettingsMount: some View {
        #if DEBUG
        DiscreetSettingsView(onResourcesRowTap: {}, onAddWidgetRowTap: {})
        #else
        EmptyView()
        #endif
    }

    /// ME-3 (S51) — the milestone-unlock leg's frame, compiled out of release ENTIRELY.
    /// A value fixture, no repository and no store, so it opens no path to habit content and
    /// fires nothing. `animateOnAppear` stays default-false: the audit reads a SETTLED card,
    /// never a mid-rise frame, which is the same contract the goldens rely on.
    @ViewBuilder private var debugMilestoneUnlockMount: some View {
        #if DEBUG
        // In a ScrollView, matching Home: at accessibility sizes this card exceeds the
        // device frame, and the audit should read the shape production renders.
        ScrollView(.vertical) {
            MilestoneUnlockCard(
                row: MilestoneRowModel(
                    afterHours: 72,
                    title: "Three days",
                    body: "Three days in. This is commonly reported as the toughest window — and you are through it.",
                    state: .unlocked
                ),
                isDiscreet: false,
                onDone: {},
                onSeeAll: {}
            )
            .padding(Theme.space.s5)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .themedScreenSurface()
        #else
        EmptyView()
        #endif
    }

    /// S50 (S49 §1) — the erase-confirm leg's frame, compiled out of release ENTIRELY.
    /// The real `EraseEverythingView` on its confirm stage (`startOnCompletionFrame`
    /// defaults to `false`) over an inert `EraseFlow` whose closures do nothing: the
    /// `EraseEverythingSnapshotTests` fixture verbatim. No data write, no icon reset, no
    /// repository — an audit run cannot erase anything.
    @ViewBuilder private var debugEraseMount: some View {
        #if DEBUG
        EraseEverythingView(
            flow: EraseFlow(erase: {}, applyIcon: { _ in }),
            onErased: {}
        )
        #else
        EmptyView()
        #endif
    }

    /// R38 — the paywall leg's frame, compiled out of release. The real hard-variant
    /// `PaywallView` over the shipping copy table + a fixture, with INERT `.failed`
    /// purchase/restore closures (no store path, no echo write, no grant). Draft copy is
    /// irrelevant to an a11y audit (it checks the tree, mints no golden).
    @ViewBuilder private var debugPaywallDirectMount: some View {
        #if DEBUG
        PaywallView(
            data: PaywallPresentation.make(
                copy: PaywallCopy.loadShipping() ?? .degraded,
                variant: .hard,
                source: .onboarding
            ),
            model: PaywallModel(purchase: { _ in .failed }, restore: { .failed }),
            onUnlocked: {}
        )
        #else
        EmptyView()
        #endif
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

    // MARK: - E7.2 paywall presentation (R25.5/R25.7/R25.9)

    /// The LIVE presentation (operator RC key present, not entitled): await
    /// the sticky assignment (bundled hard-arm while the Superwall key is
    /// empty), compose the variant's screen, wire the echo (live-only), the
    /// consent-gated fires, the RC purchase/restore actions, and the teaser
    /// grant write. The await is genuine (the live adapter reaches
    /// Superwall's config); the bundled assigner answers immediately.
    private func presentLivePaywall(source: PaywallSource) async {
        guard let repository = provider?.repository else {
            self.model = nil
            return
        }
        let assigner = provider?.paywallAssigner ?? BundledVariantAssigner()
        // E7.3 (R26.8): the win-back surface registers its OWN placement id
        // (architecture §5.2's second `register(placement:)`).
        let placement = source == .winback ? SuperwallPlacement.winback : SuperwallPlacement.postSummary
        let assignment = await assigner.assignment(for: placement)
        let analytics = repository.analyticsService
        // S48 — the LIVE path binds StoreKit's localized prices. This is the
        // only call site that does: the debug render and every test keep the
        // catalog constants via the parameter's default, exactly as before.
        // `displayPrices()` fails soft per field, so a slow or unreachable
        // store degrades to the constants rather than blocking the wall.
        paywallData = PaywallPresentation.make(
            copy: PaywallCopy.loadShipping() ?? .degraded,
            variant: assignment.variant,
            source: source,
            prices: await RevenueCatPurchaser.displayPrices()
        )
        presentedPaywallSource = source // ME-1: onboarding-only adoption routing
        let firePaywallViewed = PaywallPresenter.makeFirePaywallViewed(
            assignment: assignment,
            source: source,
            analytics: analytics,
            // The echo is the LIVE assignment's mirror (§4.4) — written
            // only here; the debug path passes nil (R25.5).
            echoAssignment: { try? repository.setPaywallVariantAssigned($0) }
        )
        paywall = PaywallModel(
            // S29 (R29.6): the winback surface purchases through the SIGNED
            // promotional-offer path (the plan argument is moot — the offer
            // is always the discounted control annual); every other source
            // keeps the standard purchase. Keyless builds never compose this
            // closure (the live path is entitlement-model-gated above).
            purchase: source == .winback
                ? { _ in await RevenueCatPurchaser.purchaseWinback() }
                : { await RevenueCatPurchaser.purchase(plan: $0) },
            restore: { await RevenueCatPurchaser.restore() },
            // E7.3 (R26.7): the win-back presentation co-fires the
            // offer-scoped impression BEFORE the universal one, through the
            // model's single didFire guard (surface-scoped → universal).
            firePaywallViewed: source == .winback
                ? PaywallPresenter.makeFireWinbackShown(
                    offer: ProductCatalog.winbackOfferID,
                    analytics: analytics,
                    firePaywallViewed: firePaywallViewed
                )
                : firePaywallViewed,
            onPurchaseCompleted: PaywallPresenter.makeOnPurchaseCompleted(
                analytics: analytics,
                winbackOfferID: source == .winback ? ProductCatalog.winbackOfferID : nil
            ),
            onTeaserTaken: PaywallPresenter.makeOnTeaserTaken(
                analytics: analytics,
                enterTeaser: { try? repository.enterTeaser() }
            )
        )
    }

    /// The DEBUG render (UITEST_PAYWALL=1|teaser): inert purchase actions,
    /// NO echo (dormant never writes it), NO grant write — but the
    /// presentation fire is real and consent-gated, so the smoke's asserted
    /// event chain is exactly what release users produce.
    private func presentDebugPaywall(variant: PaywallVariant) {
        let assignment = PaywallAssignment(variant: variant, priceTest: .annual2999)
        let analytics = provider?.repository?.analyticsService ?? .disabled
        paywallData = PaywallPresentation.make(
            copy: PaywallCopy.loadShipping() ?? .degraded,
            variant: variant,
            source: .onboarding
        )
        presentedPaywallSource = .onboarding // ME-1: same routing as the live path
        paywall = PaywallModel(
            purchase: { _ in .failed },
            restore: { .failed },
            firePaywallViewed: PaywallPresenter.makeFirePaywallViewed(
                assignment: assignment,
                source: .onboarding,
                analytics: analytics,
                echoAssignment: nil
            )
        )
    }

    /// E7.2 (R25.7) + E7.3 (R26.6): the re-entry gate — live-model builds
    /// only, via the repository's own clock (`paywallReentry` — production
    /// code never reads an ambient Date). A teaser expiry re-presents the
    /// HARD form + eyebrow (single-use escape, unguarded cadence); a
    /// win-back eligibility presents the dismissible OFFER at most once per
    /// process (the in-memory guard — the settings row is the persistent
    /// path back).
    private func checkPaywallReentry() {
        guard paywall == nil,
              let entitlement = provider?.entitlementModel,
              let repository = provider?.repository,
              case .paywall(let source) = repository.paywallReentry(state: entitlement.state)
        else { return }
        if source == .winback {
            guard !didAutoPresentWinback else { return }
            didAutoPresentWinback = true
        }
        Task { await presentLivePaywall(source: source) }
    }

    private func dismissPaywall() {
        paywall = nil
        paywallData = nil
        presentedPaywallSource = nil
        model = nil
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
