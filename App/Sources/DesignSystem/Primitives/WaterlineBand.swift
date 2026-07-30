import SwiftUI

/// ME-9 (Session 58) — the **Waterline band**: `WaterlineField` cropped to a
/// fraction of its container measured from the top, and feathered out at the
/// lower edge so the crop has no visible cut line. UX blueprint §6.6 asks the
/// paywall for "a Waterline backdrop (subdued, ≤ top third)"; creative §2 also
/// wants field crops on the empty states and the milestone cards, so the second
/// and third consumers already exist on paper.
///
/// **Why it is a primitive and not four lines inside `PaywallView`.** The feather
/// is a gradient mask, and a mask needs a monochrome. `ThemeSourceLintTests` bans
/// `Color.black` / `Color.white` everywhere in `App/Sources` *except*
/// `DesignSystem/` — which is exactly the boundary this file sits on: colour is
/// defined here and consumed everywhere else.
///
/// **The band is a CONTRAST decision before it is a composition one, and the
/// number that governs it is not the one this session inherited.** ME-9's scoping
/// concluded "confine the field to the top third and neither translucent fill is
/// ever involved". Measured, that is FALSE for this screen: `PaywallView`'s plan
/// cards live inside a `ScrollView`, and the crop is measured against the SCREEN
/// — so a scrolled card travels up into the band. Light `primary action text on
/// selection tint` computes 4.716 with no field and **4.387 under one, against
/// its 4.5 floor**. The band alone is therefore not the guarantee; the opaque
/// `surface/base` floors pinned under the two tinted fills are (ME-4's
/// `AlcoholNoticeCard` pattern, generalised). With those in place every scroll
/// position is safe to **0.1640** — 2.7× the field's standard 0.06 and clear of
/// its 0.08 hard ceiling. The band is then a composition choice, freely made.
///
/// Measured with a harness that compiles the shipping bytes of `ColorToken` /
/// `Theme` / `ThemeMetrics` / `ContrastMath` and parses `WaterlineField`'s
/// constants out of its source, and that reproduces S54's published quiz /
/// summary / every-registered-pair ceilings (0.0934 / 0.0695 / 0.0391) before
/// being trusted with new numbers.
///
/// **§6.6's "55% scrim floor before any text overlays" is deliberately NOT
/// implemented literally, and the reason is measured rather than aesthetic.**
/// `Theme.alpha.scrim` is 55% BLACK, and its own declaration says it is the
/// LIGHT white-on-scrim 4.5:1 floor — i.e. it is sized for white text over a
/// full-strength image. There is no full-strength image here: the field is a 6%
/// tint with 2.7× headroom. Applying the clause literally would drop light-mode
/// `content/primary` from 15.650:1 to **3.351:1** and `content/secondary` from
/// 6.162:1 to **1.320:1** — the scrim written to protect the text is what would
/// break it. The clause's INTENT (text over the backdrop stays legible) is met by
/// the solve above, with the margin stated as a number.
struct WaterlineBand: View {
    /// 0 = day, 1 = night — handed straight to the field. The paywall follows the
    /// summary in the funnel and the summary ships `progress: 1`, so continuing at
    /// 1 is what creative §4's "one continuous horizon, not thirteen paintings"
    /// asks for: the horizon does not reset between the payoff and the offer.
    var progress: Double = 1

    /// Fraction of the container's height the band occupies, measured from the
    /// top. §6.6: "subdued, ≤ top third".
    var heightFraction: CGFloat = 1.0 / 3.0

    /// Fraction of the BAND over which the field fades to nothing at its lower
    /// edge. A hard crop would read as a rectangle of tint; the field's own bloom
    /// is feathered by construction and this keeps the crop consistent with it.
    var featherFraction: CGFloat = 0.45

    /// Passed through so a consumer can dim the band. The field hard-clamps it to
    /// `WaterlineField.opacityCeiling` in its own `body`, which no caller can undo.
    var maxOpacity: Double = WaterlineField.standardOpacity

    var body: some View {
        GeometryReader { proxy in
            WaterlineField(progress: progress, maxOpacity: maxOpacity)
                .frame(height: max(proxy.size.height * heightFraction, 0))
                .mask(alignment: .top) {
                    // A mask reads the ALPHA channel only, so the colour is
                    // arbitrary; black is the conventional opaque choice. Both
                    // `mask(alignment:_:)` (iOS 15.0) and
                    // `LinearGradient(stops:startPoint:endPoint:)` (iOS 13.0) were
                    // verified present and undeprecated against Apple's docs JSON
                    // before this file was written — neither has an in-repo
                    // precedent, so both are new-API surface.
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color.black, location: 0),
                            Gradient.Stop(color: Color.black, location: 1 - featherFraction),
                            Gradient.Stop(color: Color.black.opacity(0), location: 1),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        // The field already declares both; restating them here means a band that
        // ever grows a second layer cannot become reachable by an assistive
        // technology or by a touch.
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }
}
