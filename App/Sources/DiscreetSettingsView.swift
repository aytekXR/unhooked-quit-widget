import SwiftUI

/// ME-7 (redesign §6.11) — **the Settings screen**, rebuilt off the system `List` onto
/// the Theme layer with the canonical section order: *Panic access* → *Discreet Mode* →
/// *Privacy & Data* → *Breathing* → *Your plan* → *Support & resources*. Settings order
/// restates product values, which is why panic access comes before admin.
///
/// This retires, BY CONSTRUCTION, the one open a11y defect in the app (QW-9 / R39.1 /
/// R39.2) that three sessions and seven billed CI runs could not fix from inside a
/// `List`:
///
///   * **R39.1** — the nav-bar LARGE title fired `.dynamicType` "partially unsupported"
///     + `.textClipped` at AX5. There is now no nav-bar title at all: the screen title is
///     a free-standing scalable `Text` in the scrolling content (the `StreakDetailView`
///     precedent — "no second rendering of the same word"), carrying `.isHeader` so
///     VoiceOver's heading rotor still finds it.
///   * **R39.2** — long `Section(footer:)` text clipped because iOS caps that slot's
///     height. There is no `List`, so there is no `footer:` slot: every explanatory line
///     is an ordinary in-content `Text` that grows. `SettingsSourceLintTests` makes the
///     regression unwritable rather than merely absent.
///   * **The "Support & resources" row** — a `Button` whose wrapping title fought
///     Dynamic Type across five S40 runs (`Label` truncated; `HStack{Image;Text}` read
///     "partially unsupported"; a plain `Text` passed but was not a Button). Every one of
///     those failures happened inside a height-capped List ROW — which is why the short
///     `iconRow` labels passed in the same screen while the longer resources label did
///     not. Outside the List a row is free to grow, and `settingsRow` below is the
///     known-passing `iconRow` geometry (text leading, hidden glyph trailing) with the
///     height floor replaced by growing PADDING.
///
/// Every string renders from the audited `DiscreetSettingsCopy` table. The five ME-7
/// copy deltas are DRAFT on the §0 founder pass; every S46-final byte is verbatim.
///
/// Privacy posture (unchanged): a discreet quit's row uses the SAME neutral label the
/// dashboard rows use (`SlipCopy.Dashboard.discreetRowLabel` — the privacy panel's P-g
/// amendment: even inside its own settings screen, a discreet quit names no habit).
struct DiscreetSettingsView: View {
    @Environment(RepositoryProvider.self) private var provider: RepositoryProvider?
    @Environment(\.dismiss) private var dismiss
    /// Placeholder-grade re-read driver (the RootPlaceholderView idiom — no
    /// observation plumbing on a graft surface).
    @State private var refreshToken = 0
    /// E7.3 (R26.6) — the *Your plan* row's tap-through (the host owns the ONE
    /// paywall mount). nil hides the row; visibility is ALSO gated by the
    /// live eligibility read — view-gated, never an optional String (R26.9).
    ///
    /// ME-9 (S58): it now carries the SOURCE. The view is what decides which
    /// case it is looking at, so it is what says which paywall to open; letting
    /// the host re-derive that would put the same question in two places and
    /// let the row's visibility and its destination drift apart.
    var onPlanRowTap: ((PaywallSource) -> Void)? = nil
    /// E9.1 (R27.10 — the SECOND R22.7 amendment): the safety-resources row's
    /// tap-through (the host owns the ONE resources mount and injects the
    /// `.settings` source). UNCONDITIONAL when wired — resources are always one
    /// tap away (an MVP §7 release-gate row), never eligibility- or
    /// entitlement-gated (unlike the winback row).
    var onResourcesRowTap: (() -> Void)? = nil
    /// ME-7 — the *Panic access* section's re-entry into the ME-1 widget-adoption
    /// moment (the host owns the ONE adoption mount, exactly as it owns the paywall
    /// and resources mounts). nil hides the section; the redesign's promise that the
    /// adoption screen is "re-enterable from Settings forever" is this closure.
    var onAddWidgetRowTap: (() -> Void)? = nil
    /// QW-2 — the erase confirm sheet (mounted over this sheet; the completion
    /// frame's door hands off to `onErased`).
    @State private var showsErase = false
    /// QW-2 — the post-erase hand-off: the host restarts the normal root over
    /// the fresh (empty) store, landing on the fresh age gate. nil hides the
    /// erase row — a host that cannot restart must not offer the erase.
    var onErased: (() -> Void)? = nil

    private let copy = DiscreetSettingsCopy.shipping
    private let slipCopy = SlipCopy.loadShipping() ?? .degraded
    private var dashboardCopy: SlipCopy.Dashboard { slipCopy.dashboard ?? .degraded }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: Theme.space.s6) {
                    titleHeader
                    panicAccessSection
                    if let repository = provider?.repository {
                        discreetModeSection(repository)
                        privacyDataSection
                        breathingSection(repository)
                        yourPlanSection(repository)
                    }
                    resourcesSection
                }
                .frame(maxWidth: Theme.layout.contentMaxWidth, alignment: .leading)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Theme.space.s5)
                .padding(.vertical, Theme.space.s4)
                // The placeholder-grade re-read: invalidating the content subtree is
                // what republishes a just-written toggle / icon selection.
                .id(refreshToken)
            }
            .scrollBounceBehavior(.basedOnSize)
            .themedScreenSurface()
            // R39.1 — the bar carries NO title. `titleHeader` below is the sole
            // rendering of the screen's name, so nothing announces twice and the
            // system large title's AX5 clip cannot be inherited. The sheet keeps its
            // swipe-to-dismiss exactly as before (no toolbar affordance is added or
            // removed by ME-7).
            .navigationBarTitleDisplayMode(.inline)
            .tint(Theme.color.brandPrimary.color)
            // QW-2 — the erase confirm sheet (over this sheet). Composed here,
            // at the screen level: `EraseFlow` gets the repository's data erase
            // and the switcher's erase-path icon reset (R22.4 — best-effort,
            // AFTER the data erase, never a persist).
            .sheet(isPresented: $showsErase) {
                if let repository = provider?.repository {
                    let switcher = provider?.appIconSwitcher
                    EraseEverythingView(
                        flow: EraseFlow(
                            erase: { try await repository.eraseEverything() },
                            applyIcon: { _ in try await switcher?.resetToPrimary() }
                        ),
                        onErased: {
                            // The host restarts the root onto the fresh age
                            // gate; both sheets fall with this subtree.
                            onErased?()
                        }
                    )
                }
            }
        }
    }

    // MARK: - Screen title (R39.1)

    /// R39.1 — the screen title as a FREE-STANDING, scalable `.largeTitle` `Text` inside
    /// the scrolling content, never a nav-bar large title nor a `List` row (both are
    /// height-constrained and clip at accessibility sizes). `.fixedSize(vertical:)` grants
    /// it its full wrapped height; the ScrollView yields the rest. `.isHeader` restores
    /// the VoiceOver heading-rotor semantics the system large title used to provide —
    /// without it, a screen title is just another static text to a rotor user.
    private var titleHeader: some View {
        Text(copy.screenTitle)
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(Theme.color.contentPrimary.color)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier("settings.title")
    }

    // MARK: - Section 1 · Panic access (ME-7 / ME-1 re-entry)

    /// ME-7 (redesign §6.11) — the FIRST section: the widget-adoption moment is
    /// re-enterable forever. Hidden when the host wires no adoption mount, so the
    /// snapshot fixture and any host that cannot present it render exactly as before.
    @ViewBuilder
    private var panicAccessSection: some View {
        if let onAddWidgetRowTap {
            sectionCard(header: copy.panicAccessSectionHeader) {
                settingsRow(
                    label: copy.widgetAdoptionRowLabel,
                    systemImage: "lock.iphone",
                    ink: Theme.color.contentPrimary,
                    identifier: "settings.widgetAdoption.row"
                ) {
                    dismiss()
                    onAddWidgetRowTap()
                }
            }
        }
    }

    // MARK: - Section 2 · Discreet Mode (per-quit toggles + the icon picker)

    /// ME-7 — the feature keeps its own name as a SECTION. The per-quit toggle label
    /// stays the QUIT's label (or the neutral `discreetRowLabel` when discreet): with up
    /// to three concurrent quits, one shared action label would render three
    /// indistinguishable switches, and the neutral-identity rule is a privacy-panel
    /// amendment, not a style choice. The observable-copy footer says what the switch does.
    @ViewBuilder
    private func discreetModeSection(_ repository: QuitRepository) -> some View {
        let quits = (try? repository.activeQuits()) ?? []
        let currentIcon = repository.discreetIconId()
        sectionCard(header: copy.discreetModeSectionHeader) {
            ForEach(quits, id: \.id) { quit in
                Toggle(isOn: Binding(
                    get: { quit.discreetMode },
                    set: { enabled in
                        // The ONE writer (R22.7): save → rebuild BOTH caches →
                        // widget reload; fires .widget on the OFF→ON edge only.
                        try? repository.setDiscreetMode(quitID: quit.id, enabled: enabled)
                        provider?.refreshDiscreetSignal()
                        refreshToken += 1
                    }
                )) {
                    Text(rowLabel(quit))
                        .font(.body)
                        .foregroundStyle(Theme.color.contentPrimary.color)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, Theme.space.s1)
            }
            captionText(copy.widgetsFooter)
            iconPickerBlock(currentIcon)
        }
    }

    /// The alternate-icon picker, a sub-block of the Discreet Mode section (the disguise
    /// IS discreet mode). Its sub-header rides `content/secondary` — a registered pair.
    @ViewBuilder
    private func iconPickerBlock(_ current: String?) -> some View {
        Text(copy.iconHeader)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Theme.color.contentSecondary.color)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
            .padding(.top, Theme.space.s2)
        iconRow(title: copy.iconRowDefault, iconID: nil, current: current)
        iconRow(title: copy.iconRowCalendar, iconID: "AppIconCalendar", current: current)
        iconRow(title: copy.iconRowTimer, iconID: "AppIconTimer", current: current)
    }

    // MARK: - Section 3 · Privacy & Data (the erase row)

    /// ME-7 (redesign §6.11) — the erase row's home. QW-8's consent toggle and §6.22's
    /// "what leaves this device" screen join this section when they land; neither ships
    /// in S50. Hidden when the host cannot restart the root after an erase.
    @ViewBuilder
    private var privacyDataSection: some View {
        if onErased != nil {
            sectionCard(header: copy.privacyDataSectionHeader) {
                // QW-2 (redesign §5.8) — amber label + trash glyph, the sanctioned erase
                // vocabulary (§9.5 "trash paired with amber copy"). Amber, never red. The
                // row never calls the repository: it opens the hold-to-confirm sheet.
                settingsRow(
                    label: copy.eraseRowLabel,
                    systemImage: "trash",
                    ink: Theme.color.caution,
                    identifier: "settings.erase.row"
                ) {
                    showsErase = true
                }
            }
        }
    }

    // MARK: - Section 4 · Breathing (the haptics-only pacer)

    /// E9.3 (R28.3 — the THIRD R22.7 amendment): the haptics-only breath-pacer toggle,
    /// NEVER framed as an accommodation — the caption names exactly what the switch does
    /// (the `widgetsFooter` observable-copy rule) as a UNIVERSAL, eyes-free-for-anyone
    /// preference (brandkit §8). The Toggle's text label IS its VoiceOver label (no
    /// icon-only element); the switch state is the native a11y value.
    ///
    /// R39.2 — this caption is the long string that clipped in the `List`'s `footer:`
    /// slot. It is now an ordinary in-content `Text` with `.fixedSize`, so it grows.
    @ViewBuilder
    private func breathingSection(_ repository: QuitRepository) -> some View {
        sectionCard(header: copy.breathingSectionHeader) {
            Toggle(isOn: Binding(
                get: { repository.hapticOnlyBreathPacer() },
                set: { enabled in
                    // The ONE writer (R28.3): save → rebuild the panic pre-cache
                    // envelope; NO widget reload, NO analytics (no MVP §5 row for
                    // an accessibility preference). The discreet-toggle error
                    // posture (try?) and the same re-read token.
                    try? repository.setHapticOnlyBreathPacer(enabled)
                    refreshToken += 1
                }
            )) {
                Text(copy.hapticPacerRowLabel)
                    .font(.body)
                    .foregroundStyle(Theme.color.contentPrimary.color)
                    .fixedSize(horizontal: false, vertical: true)
            }
            captionText(copy.hapticPacerFooter)
        }
    }

    // MARK: - Section 5 · Your plan

    /// E7.3 (R26.6) — the settings surface of the win-back offer (the plan's
    /// "settings/paywall source" acceptance, in-app only per R26.5).
    ///
    /// ME-9 (S58, §6.11) widens it. The section used to render ONLY for a lapsed
    /// user inside the win-back window, so §6.11's third clause — "plan options
    /// for never-paid users" — had no surface at all: someone who declined the
    /// onboarding wall could not reach the plans again from anywhere in the app.
    /// `PaywallRouting.planRowSource` now owns the whole decision (which is a
    /// pure, unit-pinned function rather than a condition inlined in a view), and
    /// it returns the SOURCE, so the row's visibility and the paywall it opens
    /// can never disagree. An entitled user still gets no row.
    ///
    /// This needs NO new copy: `winbackRowLabel` is already the generic
    /// "See your plan options", which is exactly what §6.11 asks for and reads
    /// correctly for both cases. Dormant builds have no entitlement model, so the
    /// row structurally cannot render — which is also why the section carries no
    /// header of its own (an empty "Your plan" card would be the common case, and
    /// its header byte is not drafted).
    ///
    /// The a11y identifier stays `settings.winback.row` deliberately: it is the
    /// row's stable handle, nothing else in the repo references it, and churning
    /// a test-facing identifier buys nothing.
    @ViewBuilder
    private func yourPlanSection(_ repository: QuitRepository) -> some View {
        if let onPlanRowTap,
           let entitlement = provider?.entitlementModel,
           let source = PaywallRouting.planRowSource(
               state: entitlement.state,
               winbackEligible: repository.winbackEligible(state: entitlement.state)
           ) {
            sectionCard(header: nil) {
                settingsRow(
                    label: copy.winbackRowLabel,
                    systemImage: "tag",
                    ink: Theme.color.contentPrimary,
                    identifier: "settings.winback.row"
                ) {
                    dismiss()
                    onPlanRowTap(source)
                }
            }
        }
    }

    // MARK: - Section 6 · Support & resources

    /// E9.1 (R27.10) — the safety-resources row: mvp feature 11's "one tap from
    /// Settings". Store-free (the screen reads bundled JSON only), so it renders
    /// whenever the host wires it — no repository, no eligibility gate. Same
    /// dismiss-then-hand-off shape as the winback row. No header: the row's own label
    /// is the section name, and a card whose header repeated it would announce twice.
    @ViewBuilder
    private var resourcesSection: some View {
        if let onResourcesRowTap {
            sectionCard(header: nil) {
                settingsRow(
                    label: copy.resourcesRowLabel,
                    systemImage: "lifepreserver",
                    ink: Theme.color.contentPrimary,
                    identifier: "settings.resources.row"
                ) {
                    dismiss()
                    onResourcesRowTap()
                }
            }
        }
    }

    // MARK: - Shared shapes

    /// The section container: a level-0 `themedCard` over `surface/raised`, with an
    /// optional `.isHeader` title. Both ink tokens used inside are already registered
    /// pairs on raised (`content/primary`, `content/secondary`), so ME-7 introduces no
    /// new `Theme.contrastPairs` entry.
    @ViewBuilder
    private func sectionCard<Content: View>(
        header: String?,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Theme.space.s3) {
            if let header {
                Text(header)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Theme.color.contentPrimary.color)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
            }
            content()
        }
        .padding(Theme.space.s4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .themedCard()
    }

    /// R39.2 — the explanatory line that used to live in a `List` `footer:` slot. An
    /// ordinary `Text` with `.fixedSize` in a scrolling column: it grows at every
    /// accessibility size instead of being capped by a slot iOS controls.
    private func captionText(_ string: String) -> some View {
        Text(string)
            .font(.subheadline)
            .foregroundStyle(Theme.color.contentSecondary.color)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// The settings row: a full-width `Button` in the geometry that PASSED the S40 audits
    /// on this screen (`iconRow` — text leading, decorative glyph trailing and
    /// a11y-hidden, `contentShape` for the whole row), with two deliberate changes:
    ///
    ///   * the 44pt target comes from growing PADDING, never a `minHeight` floor — the
    ///     UIR-3 mechanism (a floor around text caps it at accessibility sizes);
    ///   * `PlanCardButtonStyle` rather than `.buttonStyle(.plain)`, because `.plain`
    ///     dims a disabled label sub-WCAG (R32.9) and `QuietButtonStyle` would impose
    ///     both its own `minHeight` floor and its own ink on the label.
    ///
    /// The glyph is sized by a TEXT STYLE, not a point value, so it co-scales with the
    /// label — the "Dynamic Type partially unsupported" reading the S40 runs hit came
    /// from elements that did not grow together.
    private func settingsRow(
        label: String,
        systemImage: String,
        ink: ColorToken,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(alignment: .firstTextBaseline, spacing: Theme.space.s3) {
                Text(label)
                    .font(.body)
                    .foregroundStyle(ink.color)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: systemImage)
                    .font(.body)
                    .foregroundStyle(ink.color)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, Theme.space.s3)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlanCardButtonStyle())
        .accessibilityIdentifier(identifier)
    }

    /// The icon-picker row — unchanged geometry from the shape that PASSED every S40
    /// audit, moved off `.buttonStyle(.plain)` (R32.9) and given the padding-based
    /// target. E9.3 (R28.8 / Q(d)#16): the current-selection checkmark is a11y-hidden and
    /// is the ONLY selection signal, so VoiceOver hears the state via the `.isSelected`
    /// trait (the quiz-chip precedent; brandkit §8's color-independence rule extends to
    /// the a11y tree). TRAIT only — zero pixels.
    private func iconRow(title: String, iconID: String?, current: String?) -> some View {
        Button {
            guard let switcher = provider?.appIconSwitcher else { return }
            Task {
                try? await switcher.select(iconID)
                refreshToken += 1
            }
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: Theme.space.s3) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(Theme.color.contentPrimary.color)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if current == iconID {
                    Image(systemName: "checkmark")
                        .font(.body)
                        .foregroundStyle(Theme.color.brandPrimary.color)
                        .accessibilityHidden(true)
                }
            }
            .padding(.vertical, Theme.space.s3)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlanCardButtonStyle())
        .accessibilityAddTraits(current == iconID ? [.isSelected] : [])
    }

    /// The dashboard rows' neutral-identity rule, verbatim (RootPlaceholderView
    /// precedent): a discreet quit's row renders the audited neutral label, never
    /// the habit.
    private func rowLabel(_ quit: Quit) -> String {
        if quit.discreetMode { return dashboardCopy.discreetRowLabel }
        if let custom = quit.customLabel, !custom.isEmpty { return custom }
        // S46 (operator §3): same `rawValue.capitalized` fix as the dashboard —
        // the two rowLabel helpers must never drift from `displayNoun` again.
        return quit.habitCategory.displayNoun
    }
}

#Preview {
    DiscreetSettingsView()
}
