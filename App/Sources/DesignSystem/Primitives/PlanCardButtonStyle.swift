import SwiftUI

/// UIR-4 — a minimal pass-through `ButtonStyle` for the paywall's plan-selection cards
/// (brandkit §6.8). The card's own background and checkmark glyph encode the selected
/// state, so the style adds only a pressed-scale feedback (brandkit §7 stable
/// interaction states) and — crucially — SUPPRESSES `.plain`'s ghost-disabled opacity
/// dimming. Plan cards are always enabled today, so R32.9 cannot fire; this closes the
/// structural risk window permanently (a future payment-state guard could disable a card,
/// and `.buttonStyle(.plain)` would then dim its label sub-WCAG). It never dims a label —
/// it renders exactly what the card's tokens say.
struct PlanCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? Theme.interaction.pressedScale : 1)
            .animation(.easeOut(duration: Theme.motion.quick), value: configuration.isPressed)
    }
}
