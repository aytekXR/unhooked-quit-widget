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

    var body: some View {
        VStack(spacing: 24) {
            skeleton
            panicEntry
            if let repository = provider?.repository {
                storeSlipSurface(repository)
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
                            copy: SlipCopy.loadShipping() ?? .degraded,
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
            Text("Slip logged. Undo?")
                .font(.subheadline.weight(.medium))
            Button {
                _ = try? repository.undoSlip(slipID: slipID)
                refreshToken += 1
            } label: {
                Label("Undo", systemImage: "arrow.uturn.backward.circle")
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

    /// A neutral, habit-context-free row title (discreet rows never name the habit).
    private func rowLabel(_ quit: Quit) -> String {
        if quit.discreetMode { return "Tracked goal" }
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
