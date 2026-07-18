import SwiftUI

/// E6.3 (R22.7) — the ONE settings screen mvp feature 9 names: per-quit discreet
/// toggles + the alternate-icon picker, NOTHING more (no analytics toggle, no erase
/// button, no haptic row — those belong to their own epics). Placeholder-grade chrome
/// like every RootPlaceholderView graft (E4.1 precedent); every string renders from
/// the audited `DiscreetSettingsCopy` table (S1-scanned, DRAFT → operator §3), and NO
/// snapshot golden pins this screen until the founder copy pass (S17-R5 batch point).
///
/// Privacy posture: a discreet quit's row uses the SAME neutral label the dashboard
/// rows use (`SlipCopy.Dashboard.discreetRowLabel` — the privacy panel's P-g
/// amendment: even inside its own settings screen, a discreet quit names no habit).
struct DiscreetSettingsView: View {
    @Environment(RepositoryProvider.self) private var provider: RepositoryProvider?
    @Environment(\.dismiss) private var dismiss
    /// Placeholder-grade re-read driver (the RootPlaceholderView idiom — no
    /// observation plumbing on a graft surface).
    @State private var refreshToken = 0
    /// E7.3 (R26.6) — the win-back row's tap-through (the host owns the ONE
    /// paywall mount). nil hides the row; visibility is ALSO gated by the
    /// live eligibility read — view-gated, never an optional String (R26.9).
    var onWinbackRowTap: (() -> Void)? = nil
    /// E9.1 (R27.10 — the SECOND R22.7 amendment): the safety-resources row's
    /// tap-through (the host owns the ONE resources mount and injects the
    /// `.settings` source). UNCONDITIONAL when wired — resources are always one
    /// tap away (an MVP §7 release-gate row), never eligibility- or
    /// entitlement-gated (unlike the winback row).
    var onResourcesRowTap: (() -> Void)? = nil

    private let copy = DiscreetSettingsCopy.shipping
    private let slipCopy = SlipCopy.loadShipping() ?? .degraded
    private var dashboardCopy: SlipCopy.Dashboard { slipCopy.dashboard ?? .degraded }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                titleHeader
                List {
                    if let repository = provider?.repository {
                        widgetToggles(repository)
                        iconPicker(repository)
                        hapticPacerRow(repository)
                        winbackRow(repository)
                    }
                    resourcesRow()
                }
                // UIR-4b: the List's system-grouped chrome moves onto the Theme layer WITHOUT
                // abandoning List (its native cell accessibility is kept). The scroll's system
                // background is hidden and surface/base shows behind (the VStack backdrop); each
                // Section's cells ride surface/raised; Toggles tint `brand/primary`; header/footer/
                // label text carries explicit Theme tokens (+ `.fixedSize` so long footers grow at AX).
                .scrollContentBackground(.hidden)
                .tint(Theme.color.brandPrimary.color)
                .id(refreshToken)
            }
            .background(Theme.color.surfaceBase.color.ignoresSafeArea())
            // R39.2 (UIR-5c) — the screen title is the free-standing `titleHeader` above the List,
            // NOT a nav-bar LARGE title (which fired `.dynamicType`/`.textClipped` at AX5); the bar
            // carries no title (inline, empty).
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    /// R39.2 — the screen title as a FREE-STANDING, scalable `.largeTitle` `Text` ABOVE the List
    /// (never a nav-bar large title nor a List row — both are height-constrained and clip at
    /// accessibility sizes). `.fixedSize(vertical:)` grants it its full wrapped height; the List
    /// (the flexible sibling) yields the rest.
    private var titleHeader: some View {
        Text(copy.screenTitle)
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(Theme.color.contentPrimary.color)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.space.s4)
            .padding(.top, Theme.space.s3)
            .padding(.bottom, Theme.space.s2)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier("settings.title")
    }

    /// E7.3 (R26.6) — the settings surface of the win-back offer (the plan's
    /// "settings/paywall source" acceptance, in-app only per R26.5): visible
    /// ONLY when a live entitlement model reports `.lapsed` AND the pure
    /// policy says the 7-day window is open. Dormant builds have no
    /// entitlement model, so the row structurally cannot render.
    @ViewBuilder
    private func winbackRow(_ repository: QuitRepository) -> some View {
        if let onWinbackRowTap,
           let entitlement = provider?.entitlementModel,
           repository.winbackEligible(state: entitlement.state) {
            Section {
                Button {
                    dismiss()
                    onWinbackRowTap()
                } label: {
                    Label(copy.winbackRowLabel, systemImage: "tag")
                        .foregroundStyle(Theme.color.contentPrimary.color)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("settings.winback.row")
            }
            .listRowBackground(Theme.color.surfaceRaised.color)
        }
    }

    /// E9.1 (R27.10) — the safety-resources row: mvp feature 11's "one tap from
    /// Settings". Store-free (the screen reads bundled JSON only), so it renders
    /// whenever the host wires it — no repository, no eligibility gate. Same
    /// dismiss-then-hand-off shape as the winback row.
    @ViewBuilder
    private func resourcesRow() -> some View {
        if let onResourcesRowTap {
            Section {
                Button {
                    dismiss()
                    onResourcesRowTap()
                } label: {
                    Label(copy.resourcesRowLabel, systemImage: "lifepreserver")
                        .foregroundStyle(Theme.color.contentPrimary.color)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("settings.resources.row")
            }
            .listRowBackground(Theme.color.surfaceRaised.color)
        }
    }

    @ViewBuilder
    private func widgetToggles(_ repository: QuitRepository) -> some View {
        let quits = (try? repository.activeQuits()) ?? []
        Section {
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
                    Label(rowLabel(quit), systemImage: "eye.slash")
                        .foregroundStyle(Theme.color.contentPrimary.color)
                }
            }
        } header: {
            Text(copy.widgetsHeader)
                .foregroundStyle(Theme.color.contentSecondary.color)
                .fixedSize(horizontal: false, vertical: true) // R39.2: grow at AX, don't clip
                .textCase(nil)
        } footer: {
            Text(copy.widgetsFooter)
                .foregroundStyle(Theme.color.contentSecondary.color)
                .fixedSize(horizontal: false, vertical: true) // R39.2: grow at AX, don't clip
        }
        .listRowBackground(Theme.color.surfaceRaised.color)
    }

    @ViewBuilder
    private func iconPicker(_ repository: QuitRepository) -> some View {
        let current = repository.discreetIconId()
        Section {
            iconRow(title: copy.iconRowDefault, iconID: nil, current: current)
            iconRow(title: copy.iconRowCalendar, iconID: "AppIconCalendar", current: current)
            iconRow(title: copy.iconRowTimer, iconID: "AppIconTimer", current: current)
        } header: {
            Text(copy.iconHeader)
                .foregroundStyle(Theme.color.contentSecondary.color)
                .fixedSize(horizontal: false, vertical: true) // R39.2: grow at AX, don't clip
                .textCase(nil)
        }
        .listRowBackground(Theme.color.surfaceRaised.color)
    }

    /// E9.3 (R28.3 — the THIRD R22.7 amendment): the haptics-only breath-pacer
    /// toggle. A header-less Section (the winback/resources precedent), NEVER
    /// framed as an accommodation — the footer names exactly what the switch does
    /// (the `widgetsFooter` observable-copy rule) as a UNIVERSAL, eyes-free-for-
    /// anyone preference (brandkit §8). The Toggle's text label IS its VoiceOver
    /// label (no icon-only element); the switch state is the native a11y value.
    @ViewBuilder
    private func hapticPacerRow(_ repository: QuitRepository) -> some View {
        Section {
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
                    .foregroundStyle(Theme.color.contentPrimary.color)
            }
        } footer: {
            Text(copy.hapticPacerFooter)
                .foregroundStyle(Theme.color.contentSecondary.color)
                .fixedSize(horizontal: false, vertical: true) // R39.2: grow at AX, don't clip (the longest footer)
        }
        .listRowBackground(Theme.color.surfaceRaised.color)
    }

    private func iconRow(title: String, iconID: String?, current: String?) -> some View {
        Button {
            guard let switcher = provider?.appIconSwitcher else { return }
            Task {
                try? await switcher.select(iconID)
                refreshToken += 1
            }
        } label: {
            HStack {
                Text(title)
                    .foregroundStyle(Theme.color.contentPrimary.color)
                Spacer()
                if current == iconID {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Theme.color.brandPrimary.color)
                        .accessibilityHidden(true)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        // E9.3 (R28.8 / Q(d)#16) — the current-selection checkmark is a11y-hidden
        // and is the ONLY selection signal, so VoiceOver hears the state via the
        // `.isSelected` trait (the quiz-chip precedent; brandkit §8's color-
        // independence rule extends to the a11y tree). TRAIT only — zero pixels.
        .accessibilityAddTraits(current == iconID ? [.isSelected] : [])
    }

    /// The dashboard rows' neutral-identity rule, verbatim (RootPlaceholderView
    /// precedent): a discreet quit's row renders the audited neutral label, never
    /// the habit.
    private func rowLabel(_ quit: Quit) -> String {
        if quit.discreetMode { return dashboardCopy.discreetRowLabel }
        if let custom = quit.customLabel, !custom.isEmpty { return custom }
        return quit.habitCategory.rawValue.capitalized
    }
}

#Preview {
    DiscreetSettingsView()
}
