import SwiftUI

/// UIR-0 — brandkit §6.1 PrimaryButton as a themed primitive. BUILT, NOT ADOPTED:
/// screens keep their hand-rolled buttons (with swapped color tokens) through
/// UIR-0 and migrate here surface-by-surface in UIR-1…4 (ruling R32.2).
///
/// States (brandkit §6.1, contrast-registry-backed):
/// - default: `brand/primary` pill, `brand/onPrimary` label (≥6.0:1 L / 7.0:1 D)
/// - pressed: `brand/primaryPressed` + scale 0.98 (≥7.5:1)
/// - disabled: the GHOST treatment — `surface/sunken` fill + `content/secondary`
///   label (5.64:1 L / 8.80:1 D). Deliberately NOT brandkit v1.0's "40% opacity":
///   an opacity-dimmed teal fill under a light label computes 1.4–3.1:1 at every
///   alpha, and while WCAG exempts inactive controls, Apple's `.contrast` audit
///   behavior on them is undocumented — the ghost form is safe even if audited
///   (tokens-v2 ruling R32.3; a11y only strengthens, roadmap §2.5).
/// - loading: inline spinner replaces the label, width locked (the label keeps
///   layout, hidden, so the button never resizes mid-request).
struct PrimaryButton: View {
    let title: String
    var isLoading = false
    /// 44 global floor; panic/slip surfaces pass `Theme.touch.panicTarget`.
    var minHeight: CGFloat = Theme.touch.minTarget
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(.body.weight(.semibold))
                    .opacity(isLoading ? 0 : 1) // width lock: the label keeps its layout
                if isLoading {
                    ProgressView()
                        .tint(Theme.color.brandOnPrimary.color)
                }
            }
            .frame(maxWidth: .infinity, minHeight: minHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(isLoading) // a request in flight is not re-tappable (brandkit §6.1)
    }
}

/// The style half — reusable on any Button that needs the primary-pill chrome.
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(
                isEnabled
                    ? Theme.color.brandOnPrimary.color
                    : Theme.color.contentSecondary.color
            )
            .background(fill(pressed: configuration.isPressed), in: Capsule())
            .scaleEffect(configuration.isPressed ? Theme.interaction.pressedScale : 1)
            .animation(.easeOut(duration: Theme.motion.quick), value: configuration.isPressed)
    }

    private func fill(pressed: Bool) -> Color {
        guard isEnabled else { return Theme.color.surfaceSunken.color }
        return (pressed ? Theme.color.brandPrimaryPressed : Theme.color.brandPrimary).color
    }
}
