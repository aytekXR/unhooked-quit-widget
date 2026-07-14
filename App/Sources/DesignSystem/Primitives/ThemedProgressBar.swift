import SwiftUI

/// UIR-0 — the thin progress track (brandkit §6.4's quiz bar, generalized) as a
/// themed primitive (BUILT, NOT ADOPTED — ruling R32.2). `brand/secondary` fill
/// on the `surface/sunken` track: momentum/progress is indigo so streak (teal)
/// and momentum (indigo) are never confused (brandkit §2.1); fill-vs-track is
/// 1.4.11-clean (4.64:1 L / 7.82:1 D, registry-pinned).
///
/// VISUAL ONLY: accessibility semantics (the 44pt announcement element, labels,
/// `accessibilityRespondsToUserInteraction(false)`) stay with the consuming
/// screen — the quiz's R28.13 hit-region treatment is the reference shape.
struct ThemedProgressBar: View {
    /// 0...1 (values outside clamp).
    let fraction: Double
    var trackHeight: CGFloat = 4

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Theme.color.surfaceSunken.color)
                Capsule()
                    .fill(Theme.color.brandSecondary.color)
                    .frame(width: max(8, proxy.size.width * min(max(fraction, 0), 1)))
            }
        }
        .frame(height: trackHeight)
    }
}
