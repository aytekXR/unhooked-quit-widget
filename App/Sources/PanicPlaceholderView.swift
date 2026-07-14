import SwiftUI

/// The panic route's root: renders EXCLUSIVELY from the presentation the app
/// resolved pre-frame out of the App Group pre-cache — zero store queries, zero
/// network, zero decorative animation (brandkit §8: breath, not bounce; the <2s
/// budget spends nothing on transitions). Since E3.2 the content is the REAL ~90s
/// flow (PanicFlowView); the type keeps its historic name and the container keeps
/// the content-stable `root.panicPlaceholder` anchor whatever it shows, so every
/// route-level smoke (walking skeleton, erase, E0.3 latency harness) discriminates
/// on the ROUTE, not on any epic's content.
struct PanicPlaceholderView: View {
    let presentation: PanicPresentation

    /// The launch's TRUE origin (E3.3), captured BEFORE `onAppear` consumes the flag
    /// keys: pre-frame by UnhookedApp on the cold route, `.inApp` from the dashboard
    /// entry. Threaded into every flow mount so `UrgeEvent.source` records the real
    /// entry point.
    let source: PanicSource

    /// E9.3 (R28.2) — the device-global eyes-free pacer preference, read off the
    /// pre-cache ENVELOPE by the mount (UnhookedApp cold / RootPlaceholderView warm +
    /// in-app) and threaded into the flow's model. Defaulted false so #Previews and
    /// every pre-E9.3 mount compile and behave identically; the store never opens here.
    var hapticsOnlyPacer: Bool = false

    /// The shipping flow copy, decoded once per scene (a few-KB bundled read, same
    /// class as the pre-cache read). `nil` — a missing/corrupt bundle resource —
    /// degrades to the E0.3 breathe frame: the panic path never dead-ends (§9).
    private let script = PanicScript.loadShipping()

    /// Picker choice — in-memory only. Selecting a quit ENTERS its flow (E3.2);
    /// no store is touched anywhere on this path.
    @State private var chosen: QuitSnapshot?

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .themedScreenSurface() // UIR-0: surface/base behind the panic route (ADR-6: constant work)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("root.panicPlaceholder")
            .onAppear {
                // The signpost ends on the panic route's FIRST frame, whatever the
                // content shows (E0.3 measurement semantics), and the launch flag +
                // quitID selection are consumed so the next ordinary launch is normal.
                PanicLaunchTrace.endIfActive()
                PanicLaunchFlag.clear()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch effectivePresentation {
        case .breathe(let quit):
            flowOrFallback(quit: quit)
        case .empty:
            flowOrFallback(quit: nil)
        case .picker(let quits):
            PanicQuitPickerView(quits: quits) { chosen = $0 }
        }
    }

    @ViewBuilder
    private func flowOrFallback(quit: QuitSnapshot?) -> some View {
        if let script {
            PanicFlowView(quit: quit, script: script, source: source, hapticsOnlyPacer: hapticsOnlyPacer)
        } else {
            BreatheFrame()
        }
    }

    private var effectivePresentation: PanicPresentation {
        if let chosen { return .breathe(chosen) }
        return presentation
    }
}

/// The bare intervention frame — the E0.3 placeholder content, unchanged.
private struct BreatheFrame: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wind")
                .font(.system(size: 56))
                .foregroundStyle(Theme.color.brandPrimary.color)
                .accessibilityHidden(true)
            Text("You're here. Breathe.")
                .font(.title.weight(.semibold))
                .multilineTextAlignment(.center)
        }
        .padding(20)
    }
}

/// Placeholder-grade quit picker (E3.1): several quits, no selection — one calm tap
/// to the right frame. Brandkit-compliant even as a placeholder: no red anywhere,
/// coach-not-judge copy, SF Symbols only; a discreet quit arrives with its label
/// already stripped (§10), so it shows a neutral title.
private struct PanicQuitPickerView: View {
    let quits: [QuitSnapshot]
    let onSelect: (QuitSnapshot) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Which one needs you right now?")
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)
            VStack(spacing: 12) {
                ForEach(quits, id: \.id) { quit in
                    Button {
                        onSelect(quit)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "circle.dashed")
                                .foregroundStyle(Theme.color.brandPrimary.color)
                                .accessibilityHidden(true)
                            Text(quit.label ?? "Your goal")
                                .font(.body.weight(.medium))
                            Spacer()
                        }
                        .padding(14)
                        .background(Theme.color.brandPrimary.color.opacity(Theme.alpha.selectionTint), in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("panic.quitPicker.row.\(quit.id.uuidString)")
                }
            }
        }
        .padding(20)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("panic.quitPicker")
    }
}

#Preview("Breathe") {
    PanicPlaceholderView(presentation: .empty, source: .lockscreenWidget)
}

#Preview("Picker") {
    PanicPlaceholderView(presentation: .picker([
        QuitSnapshot(id: UUID(), label: "Vaping", discreet: false, motivations: []),
        QuitSnapshot(id: UUID(), label: nil, discreet: true, motivations: []),
    ]), source: .lockscreenWidget)
}
