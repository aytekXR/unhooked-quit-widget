import SwiftUI

/// UIR-0 — the card/notice containers (brandkit §5 elevation + §6.15) as themed
/// primitives (BUILT, NOT ADOPTED — ruling R32.2).
extension View {
    /// Level-0 card: `surface/raised` fill, `radius/m`, hairline border (dark
    /// mode relies on surface-tone steps, not shadows — brandkit §5).
    ///
    /// ME-4 (S54) adds the radius parameter, DEFAULTED to `radius/m` so all
    /// thirteen existing call sites are byte-identical and no card golden can
    /// move. Only the quiz summary passes `radius/l` — UX blueprint §6.5 asks the
    /// payoff card, and only it, for 24pt. The alternative (changing the constant
    /// here) would have re-radiused every card in the app to satisfy one screen.
    func themedCard(cornerRadius: CGFloat = Theme.radius.m) -> some View {
        self
            .background(
                Theme.color.surfaceRaised.color,
                in: RoundedRectangle(cornerRadius: cornerRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Theme.color.borderHairline.color, lineWidth: 1)
            )
    }

    /// The calm amber caution container (brandkit §6.15; the alcohol notice's
    /// shape): `semantic/caution` at 10% over the surface, `radius/m`. Content
    /// on it is registry-pinned (content/primary 13.7:1, content/secondary
    /// 5.4:1, primary actions 4.9:1). NEVER red — amber is the ceiling.
    func themedCautionCard() -> some View {
        background(
            Theme.color.caution.color.opacity(Theme.alpha.cautionTint),
            in: RoundedRectangle(cornerRadius: Theme.radius.m)
        )
    }

    /// Selection/tinted-row fill (`brand/primary` @ 12% over the surface) — the
    /// panic-entry row / slip-row chrome. Text on it uses `content/primary`
    /// (13.2:1) or `brand/primary` (4.7:1, registry-pinned TIGHT — never
    /// `brand/primary` text on this tint at sizes below `type/body`).
    func themedSelectionTint(cornerRadius: CGFloat = 14) -> some View {
        background(
            Theme.color.brandPrimary.color.opacity(Theme.alpha.selectionTint),
            in: RoundedRectangle(cornerRadius: cornerRadius)
        )
    }
}
