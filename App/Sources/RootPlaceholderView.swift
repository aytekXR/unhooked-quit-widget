import SwiftUI

/// Normal-launch root for the walking skeleton. Real tabs (dashboard/settings) arrive
/// with their epics; this view exists so E0.1's UI smoke has a stable anchor.
///
/// E4.1 grafts a DELIBERATELY placeholder-grade store-backed slip entry onto it (no
/// quit-creation UI exists yet, so no XCUITest pins this surface — the store slip route
/// is unit-pinned this session): a minimal active-quit list where each row opens the
/// store-route slip flow, a pending-undo banner sourced from the repository, and the
/// scene-phase finalize sweep (architecture §7 — no timers). The store is reached only
/// through the environment `RepositoryProvider`, which is nil until the normal route's
/// post-frame deferred start completes.
///
/// Copy/style constraints honored even in placeholders: no red anywhere (brandkit §2
/// hard rule), no habit-naming or shame lexicon, SF Symbols only.
struct RootPlaceholderView: View {
    @Environment(RepositoryProvider.self) private var provider: RepositoryProvider?
    @Environment(\.scenePhase) private var scenePhase
    @State private var presentation: SlipPresentation?
    /// Bumped after a mutating slip action to re-read the pending-undo banner source
    /// (placeholder-grade: no observation plumbing on this throwaway surface yet).
    @State private var refreshToken = 0
    @State private var inAppPanic: InAppPanicPresentation?
    /// A panic launch that landed while the app was already running (control/widget
    /// tap on a warm app) — the init-time root decision can't see it, so this surface
    /// consumes it: on scene activation (extension wrote the flag while we were
    /// suspended) and on the in-process signal (iOS ran `perform()` in OUR process).
    @State private var warmPanic: WarmPanicPresentation?
    /// E6.3 — the discreet-settings sheet (mvp feature 9's "one settings screen").
    @State private var showsDiscreetSettings = false
    /// E7.3 (R26.6) — the settings win-back row's tap-through: the host
    /// (PostGateRootView) owns the ONE paywall mount, so the row dismisses
    /// the sheet and hands off here. nil (the default) hides the row —
    /// dormant builds and non-hosts never show it.
    var onWinbackRowTap: (() -> Void)? = nil

    /// E4.2: every slip string this surface renders comes from the ONE audited table
    /// (implementation-plan §E4.2), never a view-inline literal — byte-identical to
    /// the E4.1-shipped strings, so nothing rendered changes.
    private let slipCopy = SlipCopy.loadShipping() ?? .degraded
    private var dashboardCopy: SlipCopy.Dashboard { slipCopy.dashboard ?? .degraded }

    var body: some View {
        VStack(spacing: 24) {
            skeleton
            panicEntry
            if let repository = provider?.repository {
                storeSlipSurface(repository)
                settingsEntry
            }
        }
        .padding(20)
        .onChange(of: scenePhase) { _, phase in
            // Sweep the undo window on scene-phase transitions (architecture §7:
            // scene-phase driven, never a background timer). Idempotent.
            if phase == .active || phase == .background {
                _ = provider?.repository?.finalizePendingSlips()
                refreshToken += 1
            }
            if phase == .active {
                presentWarmPanicIfRequested()
            }
        }
        .onReceive(
            NotificationCenter.default
                .publisher(for: PanicLaunchFlag.warmLaunchRequested)
                .receive(on: DispatchQueue.main)
        ) { _ in
            presentWarmPanicIfRequested()
        }
        .sheet(item: $warmPanic) { item in
            // A sheet, not a fullScreenCover (the in-app panic entry precedent): the
            // flow's celebration exit has no dismiss affordance, so the mount must
            // stay swipe-dismissible. The mounted view consumes the flag keys in its
            // onAppear, exactly like the cold route.
            PanicPlaceholderView(presentation: item.presentation, source: item.source)
        }
        .sheet(item: $presentation) { presented in
            SlipFlowView(
                model: presented.model,
                clock: LiveClock(),
                onDismiss: {
                    presentation = nil
                    refreshToken += 1
                }
            )
        }
    }

    /// The E0.1 anchor + walking-skeleton copy — pinned by WalkingSkeletonUITests /
    /// WalkingSkeletonTests, kept byte-for-byte.
    private var skeleton: some View {
        VStack(spacing: 12) {
            Image(systemName: "circle.dashed")
                .font(.largeTitle)
                .foregroundStyle(.teal)
                .accessibilityHidden(true)
            Text("Walking skeleton")
                .font(.title2.weight(.semibold))
            Text("Nothing here yet — features arrive epic by epic.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("root.placeholder")
    }

    /// In-app panic entry (E3.3 — the fourth `PanicSource`). Placeholder-grade like the
    /// slip surface, but available PRE-store by design: it composes from the PRE-CACHE
    /// via `InAppPanicEntry` (one panic composition path — ADR-6: a panic surface never
    /// opens the store, even when the store is warm), attributes `.inApp`, and presents
    /// as a sheet (swipe-dismissable; the real dashboard PanicEntryButton chrome is E5+
    /// work). Brandkit Component 3 semantics: 56pt target, teal, wind glyph + "Panic".
    /// Idempotent warm-panic gate: mounts the panic route when a launch flag is
    /// pending and nothing panic-shaped is already up. Reads the pre-cache on the
    /// same terms as the cold route (ADR-6 — never the store).
    private func presentWarmPanicIfRequested() {
        guard !WarmPanicEntry.isHostingUnitTests else { return }
        guard warmPanic == nil, inAppPanic == nil else { return }
        guard let resolved = WarmPanicEntry.resolve(
            snapshot: PanicSnapshotStore.appGroup()?.read()
        ) else { return }
        warmPanic = resolved
    }

    private var panicEntry: some View {
        Button {
            inAppPanic = InAppPanicPresentation(
                presentation: InAppPanicEntry.presentation(
                    snapshot: PanicSnapshotStore.appGroup()?.read()
                )
            )
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "wind")
                    .accessibilityHidden(true)
                Text("Panic")
                    .font(.body.weight(.semibold))
                Spacer()
            }
            .foregroundStyle(.teal)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(.teal.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("root.panicEntry")
        .sheet(item: $inAppPanic) { item in
            PanicPlaceholderView(presentation: item.presentation, source: InAppPanicEntry.source)
        }
    }

    @ViewBuilder
    private func storeSlipSurface(_ repository: QuitRepository) -> some View {
        // Read on this render pass — placeholder-grade (refreshToken forces re-read).
        let pending = (try? repository.pendingUndoSlip()) ?? nil
        let quits = (try? repository.activeQuits()) ?? []

        VStack(spacing: 12) {
            if let pending {
                pendingUndoBanner(repository, slip: pending)
            }
            ForEach(quits, id: \.id) { quit in
                Button {
                    presentation = SlipPresentation(
                        model: SlipFlowModel(
                            route: .store(repository: repository, quitID: quit.id),
                            copy: slipCopy,
                            clock: LiveClock()
                        )
                    )
                } label: {
                    HStack {
                        Text(rowLabel(quit))
                            .font(.body.weight(.medium))
                        Spacer()
                        Image(systemName: "arrow.uturn.backward.circle")
                            .foregroundStyle(.teal)
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(.teal.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .id(refreshToken)
    }

    private func pendingUndoBanner(_ repository: QuitRepository, slip: Slip) -> some View {
        let slipID = slip.id
        return VStack(spacing: 10) {
            Text(dashboardCopy.pendingBanner)
                .font(.subheadline.weight(.medium))
            Button {
                _ = try? repository.undoSlip(slipID: slipID)
                refreshToken += 1
            } label: {
                Label(dashboardCopy.undoLabel, systemImage: "arrow.uturn.backward.circle")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.teal)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        // NEUTRAL — secondary fill, never amber/red (same as the slip flow's banner).
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    /// E6.3 — the discreet-settings entry point (R22.7: a graft like the slip
    /// surface, store-gated because both its halves persist through the repository).
    /// Neutral secondary chrome — settings is not a call to action. The sheet
    /// inherits the environment, and the app-switcher shield covers it like every
    /// sheet (it is a separate high-level window).
    private var settingsEntry: some View {
        Button {
            showsDiscreetSettings = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "gearshape")
                    .accessibilityHidden(true)
                Text(DiscreetSettingsCopy.shipping.screenTitle)
                    .font(.body.weight(.medium))
                Spacer()
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(DiscreetSettingsCopy.shipping.settingsEntryAccessibilityLabel)
        .accessibilityIdentifier("root.settingsEntry")
        .sheet(isPresented: $showsDiscreetSettings) {
            DiscreetSettingsView(onWinbackRowTap: onWinbackRowTap)
        }
    }

    /// A neutral, habit-context-free row title (discreet rows never name the habit;
    /// the discreet label comes from the audited table like every other slip string).
    private func rowLabel(_ quit: Quit) -> String {
        if quit.discreetMode { return dashboardCopy.discreetRowLabel }
        if let custom = quit.customLabel, !custom.isEmpty { return custom }
        return quit.habitCategory.rawValue.capitalized
    }
}

/// Identifiable wrapper so the store-route slip flow presents through `.sheet(item:)`
/// (the model itself carries no stable presentation id).
private struct SlipPresentation: Identifiable {
    let id = UUID()
    let model: SlipFlowModel
}

/// Identifiable wrapper for the in-app panic mount (`PanicPresentation` carries no id).
private struct InAppPanicPresentation: Identifiable {
    let id = UUID()
    let presentation: PanicPresentation
}

#Preview {
    RootPlaceholderView()
}
