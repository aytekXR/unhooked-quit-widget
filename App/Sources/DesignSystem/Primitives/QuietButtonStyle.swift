import SwiftUI

/// UIR-0 — brandkit §6.2 QuietButton as a themed primitive (BUILT, NOT ADOPTED —
/// ruling R32.2). The escape hatch: "Skip", "Not now", "Restore purchases".
/// Always `type/body` at full size (the transparent-pricing stance means the
/// quiet path is never hidden or shrunk), `content/secondary` (6.2:1 L / 8.3:1 D
/// on base), full-width ≥44pt target, pressed = quick opacity dip (no layout
/// motion — brandkit §7 stable interaction states).
struct QuietButtonStyle: ButtonStyle {
    /// 44 global floor; panic/slip surfaces pass `Theme.touch.panicTarget`.
    var minHeight: CGFloat = Theme.touch.minTarget

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .foregroundStyle(Theme.color.contentSecondary.color)
            .frame(maxWidth: .infinity, minHeight: minHeight)
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.6 : 1)
            .animation(.easeOut(duration: Theme.motion.quick), value: configuration.isPressed)
    }
}
