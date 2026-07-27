import SwiftUI

/// ME-4 (Session 54) — the **waterline hairline**: the Waterline system's signature
/// reduced to a single rule, for use *on a card* rather than behind one.
///
/// Creative inventory §2 names it as the reusable mark — "hairline divider under
/// hero numbers, the summary card's horizon" — and §7 RATIONS it to exactly three
/// places: under the summary hero, under the dashboard's Day N hero, and above the
/// panic exit actions. Everywhere else the plain `border/hairline` stays. ME-4
/// spends the first of the three; the other two are not this session's, and the
/// ration is the point ("ration it or it becomes wallpaper").
///
/// **It is deliberately NOT Foam, and that is a correction to the spec rather than
/// a shortcut.** Creative §2 specifies the waterline as white Foam, but every
/// instance it specifies is drawn over the field's own DARK bands. This rule sits
/// on `surface/raised`, which is `#FFFFFF` in light mode — Foam there is a white
/// line on a white card, i.e. nothing at all. "Luminous" is therefore rendered as
/// the brand's own light: `brand/primary` blooming at the centre and feathering to
/// clear at both ends, which reads as a horizon in BOTH appearances (`#0C6F65` on
/// white, `#4CC8B9` on `#1C1F24`) and keeps the rule on the Theme layer instead of
/// smuggling a raw monochrome into a screen file.
///
/// **No `ContrastPair`, on purpose.** This replaces a hairline and conveys no state,
/// so it is the same class as `border/hairline` — which `Theme` declares
/// "WCAG 1.4.11-exempt BY DESIGN". Registering a decorative divider would claim a
/// guarantee about information it does not carry. It is hidden from assistive
/// technology for the same reason: the hairline it replaces already is.
struct WaterlineRule: View {
    /// "1–2pt at UI scale" (creative §2). The default matches `WaterlineField`'s
    /// own stroke so the two read as one system.
    var height: CGFloat = 1.5
    /// Peak opacity at the centre of the bloom. Inside creative §2's 25–92% range,
    /// at the quiet end — this sits under the single most important number on the
    /// screen and must not compete with it.
    var intensity: Double = 0.55

    var body: some View {
        Capsule()
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: Theme.color.brandPrimary.color.opacity(0), location: 0),
                        .init(color: Theme.color.brandPrimary.color.opacity(intensity), location: 0.5),
                        .init(color: Theme.color.brandPrimary.color.opacity(0), location: 1),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: height)
            .accessibilityHidden(true)
    }
}
