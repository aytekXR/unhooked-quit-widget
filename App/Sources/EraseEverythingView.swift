import SwiftUI

/// QW-2 (redesign §5.8 / §6.16) — the erase-everything UI over the FINISHED data
/// layer: the surface `EraseFlow.swift` has awaited since E6.3 ("Future erase UI
/// calls THIS, never the repository directly"). Two stages on one sheet:
///
///   confirm — the copy-doc §11 dialog (title, honest manifest body, amber
///             hold-to-confirm, quiet "Keep my data") — amber, never red; no
///             countdown, no type-to-confirm theater; every string from the
///             audited `DiscreetSettingsCopy` table.
///   done    — the crest-anchored completion frame ("Everything's gone…"),
///             then the fresh age gate via the host's `onErased` hand-off.
///
/// Failure posture: `EraseFlow.run()`'s local erase completes before any
/// fallible remote step (EraseEverythingTests), and erase is re-runnable — a
/// throw simply keeps the confirm stage standing so the hold is immediately
/// retryable. Success is never claimed without the run returning (§13 register:
/// never claim success without durable bytes).
struct EraseEverythingView: View {
    let flow: EraseFlow
    /// Called from the completion frame's quiet door: the host restarts the
    /// normal root over the now-empty store, landing on the fresh age gate.
    let onErased: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var stage: Stage
    @State private var isErasing = false

    /// `startOnCompletionFrame` is the snapshot seam for the DONE stage (the
    /// `StreakDetailView.animateHeader` pattern: an always-present parameter
    /// whose default keeps every live call site byte-identical). The stage enum
    /// stays private — production code can only land here through a completed
    /// `EraseFlow.run()`.
    init(
        flow: EraseFlow,
        onErased: @escaping () -> Void,
        startOnCompletionFrame: Bool = false
    ) {
        self.flow = flow
        self.onErased = onErased
        _stage = State(initialValue: startOnCompletionFrame ? .done : .confirm)
    }

    private let copy = DiscreetSettingsCopy.shipping

    private enum Stage {
        case confirm
        case done
    }

    var body: some View {
        Group {
            switch stage {
            case .confirm: confirmStage
            case .done: completionStage
            }
        }
        .themedScreenSurface()
        // The completion frame's only exit is the quiet door below — a swipe
        // there would strand the session on a dead (erased) repository. The
        // confirm stage stays freely swipe-dismissible: cancel is always the
        // easy path (§6.16).
        .interactiveDismissDisabled(stage == .done || isErasing)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("erase.flow")
    }

    // MARK: - Stage 1 · confirm (copy doc §11, "Erase everything?")

    private var confirmStage: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: Theme.space.s5) {
                    Text(copy.eraseConfirmTitle)
                        .font(.title2.weight(.semibold))
                        .multilineTextAlignment(.center)
                        // S50 (S49 audit §3.4) — the R33.12 item-4 invariant. The
                        // sibling body Text below already carries it.
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("erase.confirm.title")
                    Text(copy.eraseConfirmBody)
                        .font(.body)
                        .foregroundStyle(Theme.color.contentPrimary.color)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, Theme.space.s8)
                .padding(.horizontal, Theme.space.s5)
                .frame(maxWidth: Theme.layout.contentMaxWidth)
                .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)
            // Actions pinned below the scroll (R33.5 / one-hand rule).
            VStack(spacing: Theme.space.s3) {
                HoldToConfirmButton(
                    label: copy.eraseConfirmActionLabel,
                    assistiveHint: copy.eraseAssistiveHint,
                    accessibilityID: "erase.confirm.hold",
                    action: runErase
                )
                .disabled(isErasing)
                Button(copy.eraseCancelLabel) { dismiss() }
                    .buttonStyle(QuietButtonStyle())
                    .accessibilityIdentifier("erase.cancel")
            }
            .padding(.horizontal, Theme.space.s5)
            .padding(.bottom, Theme.space.s5)
            .frame(maxWidth: Theme.layout.contentMaxWidth)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Stage 2 · completion ("Everything's gone.")

    private var completionStage: some View {
        VStack(spacing: 0) {
            Spacer()
            CrestMark()
                .padding(.bottom, Theme.space.s6)
            Text(copy.eraseCompletionBody)
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, Theme.space.s5)
                .accessibilityIdentifier("erase.completion")
            Spacer()
            Button(copy.eraseCompletionDismissLabel) { onErased() }
                .buttonStyle(QuietButtonStyle())
                .accessibilityIdentifier("erase.completion.done")
                .padding(.bottom, Theme.space.s5)
        }
        .frame(maxWidth: Theme.layout.contentMaxWidth)
        .frame(maxWidth: .infinity)
    }

    private func runErase() {
        guard !isErasing else { return }
        isErasing = true
        Task {
            do {
                try await flow.run()
                stage = .done
            } catch {
                // The local erase completed before the fallible remote step
                // threw (EraseEverythingTests ordering pin) and erase is
                // re-runnable — the confirm stage stands and the hold retries.
                // Nothing here ever claims success early.
            }
            isErasing = false
        }
    }
}

/// The crest mark (brand glyph budget #1 — the "surfaced breath" geometry) drawn
/// in-app for the completion frame: the soft circle cresting a thin waterline,
/// on Canvas, zero animation. Decorative — hidden from the a11y tree; the
/// completion line carries the meaning.
private struct CrestMark: View {
    var body: some View {
        ZStack(alignment: .top) {
            Circle()
                .fill(Theme.color.brandPrimary.color)
                .frame(width: 44, height: 44)
            VStack(spacing: 0) {
                Color.clear.frame(height: 36)
                Rectangle()
                    .fill(Theme.color.borderStrong.color)
                    .frame(height: 1)
                // Submerges the circle's lower arc below the waterline.
                Theme.color.surfaceBase.color
            }
        }
        .frame(width: 96, height: 64)
        .accessibilityHidden(true)
    }
}

#Preview {
    EraseEverythingView(
        flow: EraseFlow(erase: {}, applyIcon: { _ in }),
        onErased: {}
    )
}
