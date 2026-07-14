import SwiftUI

/// UIR-0 — brandkit §6.5 AnswerChip/TriggerChip as a themed primitive (BUILT,
/// NOT ADOPTED — ruling R32.2; the quiz's hand-rolled chips migrate in UIR-1).
/// Pill (`radius/full` per brandkit §6.5 — the v1 screens' 14pt rounding is a
/// known drift the UIR-1 migration closes). Selected = `brand/primary` fill +
/// `brand/onPrimary` content (6.0:1 L / 7.0:1 D — scheme-aware, closing the
/// dark-mode white-on-teal 1.99:1 defect); unselected = `surface/sunken` fill +
/// `content/primary` (14.3:1). Selection ALWAYS carries the checkmark glyph the
/// caller renders — never color alone (brandkit §8); this style styles, the
/// label carries the glyph.
struct AnswerChipStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(
                (isSelected ? Theme.color.brandOnPrimary : Theme.color.contentPrimary).color
            )
            .padding(.horizontal, Theme.space.s4)
            .padding(.vertical, Theme.space.s3)
            .frame(maxWidth: .infinity, minHeight: Theme.touch.minTarget)
            .background(
                (isSelected ? Theme.color.brandPrimary : Theme.color.surfaceSunken).color,
                in: Capsule()
            )
            .contentShape(Capsule())
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: Theme.motion.instant), value: configuration.isPressed)
    }
}
