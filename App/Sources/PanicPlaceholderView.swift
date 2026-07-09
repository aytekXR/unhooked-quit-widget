import SwiftUI

/// The panic route's root (E3.1): renders EXCLUSIVELY from the presentation the app
/// resolved pre-frame out of the App Group pre-cache — zero store queries, zero
/// network, zero decorative animation (brandkit §8: breath, not bounce; the <2s
/// budget spends nothing on transitions). Content is placeholder-grade: the real
/// breath pacer / 90s flow is E3.2. The container keeps the `root.panicPlaceholder`
/// anchor whatever it shows, so every route-level smoke (walking skeleton, erase,
/// E0.3 latency harness) discriminates on the ROUTE, not on this epic's content.
struct PanicPlaceholderView: View {
    let presentation: PanicPresentation

    /// Picker choice — in-memory only. Selecting routes to that quit's frame; the
    /// real flow (and any UrgeEvent write) is E3.2's. No store is touched.
    @State private var chosen: QuitSnapshot?

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        case .breathe, .empty:
            BreatheFrame()
        case .picker(let quits):
            PanicQuitPickerView(quits: quits) { chosen = $0 }
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
                .foregroundStyle(.teal)
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
                                .foregroundStyle(.teal)
                                .accessibilityHidden(true)
                            Text(quit.label ?? "Your goal")
                                .font(.body.weight(.medium))
                            Spacer()
                        }
                        .padding(14)
                        .background(.teal.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
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
    PanicPlaceholderView(presentation: .empty)
}

#Preview("Picker") {
    PanicPlaceholderView(presentation: .picker([
        QuitSnapshot(id: UUID(), label: "Vaping", discreet: false, motivations: []),
        QuitSnapshot(id: UUID(), label: nil, discreet: true, motivations: []),
    ]))
}
