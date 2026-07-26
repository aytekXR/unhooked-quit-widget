import SwiftUI

/// QW-2 (redesign §6.16 / §9.4) — the deliberate-confirm primitive: a destructive
/// action that requires a 600ms press-and-hold, visualized as a Low Sun ring that
/// FILLS while the user holds. Deliberateness without a countdown — the fill
/// measures the user's OWN press; nothing counts down against them (brand rule 4).
///
/// Structural kindness holds even on a destructive control: the chrome is amber
/// (`semantic/caution`), never red; the label rides a caution-on-sunken pair the
/// contrast registry already pins (4.65 L / 10.47 D — `caution text on sunken`),
/// so no new color pair enters the render path.
///
/// Assistive access is a FIRST-CLASS alternative, not a fallback: with VoiceOver
/// or Switch Control running, the control renders as a standard `Button` whose
/// normal double-activation confirms (the redesign §8 "standard double-activation
/// alternative with an explicit hint") — a timed gesture is never a gate for a
/// non-visual user.
struct HoldToConfirmButton: View {
    let label: String
    /// VoiceOver hint for the double-activation branch (DRAFT, founder-owned —
    /// routed through the caller's audited copy table, never authored here).
    let assistiveHint: String
    let accessibilityID: String
    let action: () -> Void

    /// The hold duration — `Theme.motion.calm` (600ms) per the redesign motion
    /// table ("erase hold-fill" rides the calm token).
    private var holdDuration: TimeInterval { Theme.motion.calm }

    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(\.accessibilitySwitchControlEnabled) private var switchControlEnabled
    /// 0…1 fill of the Low Sun ring while the press is held.
    @State private var holdProgress: Double = 0

    var body: some View {
        if voiceOverEnabled || switchControlEnabled {
            // Standard double-activation: a plain Button with the same chrome.
            Button(action: action) { chrome }
                .buttonStyle(HoldToConfirmChromeStyle())
                .accessibilityHint(assistiveHint)
                .accessibilityIdentifier(accessibilityID)
        } else {
            chrome
                .onLongPressGesture(minimumDuration: holdDuration) {
                    holdProgress = 0
                    action()
                } onPressingChanged: { pressing in
                    if pressing {
                        // The fill tracks the press linearly to the 600ms
                        // threshold — information (how far into the hold), not
                        // decoration, so it renders under Reduce Motion too.
                        withAnimation(.linear(duration: holdDuration)) {
                            holdProgress = 1
                        }
                    } else {
                        // Released early: the ring quietly recedes. No failure
                        // state, no warning — the door simply stays open.
                        withAnimation(.easeOut(duration: Theme.motion.quick)) {
                            holdProgress = 0
                        }
                    }
                }
                .accessibilityAddTraits(.isButton)
                .accessibilityHint(assistiveHint)
                .accessibilityIdentifier(accessibilityID)
        }
    }

    /// Shared chrome: caution label on the sunken fill, Low Sun trim ring as the
    /// hold-progress indicator (zero-progress renders no ring — the goldens see a
    /// settled control).
    private var chrome: some View {
        Text(label)
            .font(.body.weight(.semibold))
            .foregroundStyle(Theme.color.caution.color)
            .multilineTextAlignment(.center)
            // 56pt-class target via PADDING, never a height floor (R33.5).
            .padding(.vertical, Theme.space.s5)
            .padding(.horizontal, Theme.space.s4)
            .frame(maxWidth: .infinity)
            .background(
                Theme.color.surfaceSunken.color,
                in: RoundedRectangle(cornerRadius: Theme.radius.m)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radius.m)
                    .trim(from: 0, to: holdProgress)
                    .stroke(
                        Theme.color.caution.color,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
            )
            .contentShape(Rectangle())
    }
}

/// Pressed feedback for the assistive (standard Button) branch: the brandkit
/// press response (scale 0.98), no label dimming (the R32.9 `.plain` trap is
/// avoided by owning the style).
private struct HoldToConfirmChromeStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? Theme.interaction.pressedScale : 1)
    }
}
