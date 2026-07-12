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
    /// Placeholder-grade re-read driver (the RootPlaceholderView idiom — no
    /// observation plumbing on a graft surface).
    @State private var refreshToken = 0

    private let copy = DiscreetSettingsCopy.shipping
    private let slipCopy = SlipCopy.loadShipping() ?? .degraded
    private var dashboardCopy: SlipCopy.Dashboard { slipCopy.dashboard ?? .degraded }

    var body: some View {
        NavigationStack {
            List {
                if let repository = provider?.repository {
                    widgetToggles(repository)
                    iconPicker(repository)
                }
            }
            .id(refreshToken)
            .navigationTitle(copy.screenTitle)
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
                }
            }
        } header: {
            Text(copy.widgetsHeader)
        } footer: {
            Text(copy.widgetsFooter)
        }
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
        }
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
                    .foregroundStyle(.primary)
                Spacer()
                if current == iconID {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.teal)
                        .accessibilityHidden(true)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
