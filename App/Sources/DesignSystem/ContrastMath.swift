import Foundation

/// UIR-0 — WCAG 2.1 contrast math over the token DATA (pure Foundation; ruling
/// R32.1). This is the shipping half of the R28.13 closure-by-construction gate:
/// `ThemeContrastTests` runs these exact bytes over `Theme.contrastPairs` in the
/// unit lane, and the pre-push Linux scratch rehearsal compiles this same file —
/// pass on the real tokens, fire on mutation (the R31.4 evidence shape).
enum ContrastMath {
    /// WCAG 2.1 relative luminance of an sRGB color (components 0...1).
    static func relativeLuminance(_ rgb: (r: Double, g: Double, b: Double)) -> Double {
        func linearize(_ channel: Double) -> Double {
            channel <= 0.04045 ? channel / 12.92 : pow((channel + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linearize(rgb.r) + 0.7152 * linearize(rgb.g) + 0.0722 * linearize(rgb.b)
    }

    /// WCAG contrast ratio between two opaque colors — (Lhi + 0.05) / (Llo + 0.05),
    /// symmetric, range 1...21.
    static func contrastRatio(
        _ a: (r: Double, g: Double, b: Double),
        _ b: (r: Double, g: Double, b: Double)
    ) -> Double {
        let la = relativeLuminance(a)
        let lb = relativeLuminance(b)
        let (hi, lo) = la >= lb ? (la, lb) : (lb, la)
        return (hi + 0.05) / (lo + 0.05)
    }

    /// Source-over alpha compositing: `top` at `alpha` over the opaque `base` —
    /// the EFFECTIVE color a translucent fill actually renders.
    static func composite(
        _ top: (r: Double, g: Double, b: Double),
        alpha: Double,
        over base: (r: Double, g: Double, b: Double)
    ) -> (r: Double, g: Double, b: Double) {
        (
            alpha * top.r + (1 - alpha) * base.r,
            alpha * top.g + (1 - alpha) * base.g,
            alpha * top.b + (1 - alpha) * base.b
        )
    }

    /// The ratio a registered pair renders at in the given appearance, with any
    /// translucent background composited to its effective color first.
    static func ratio(for pair: Theme.ContrastPair, dark: Bool) -> Double {
        let foreground = pair.foreground.rgb(dark: dark)
        var background = pair.background.rgb(dark: dark)
        if let alpha = pair.backgroundAlpha, let base = pair.backgroundBase {
            background = composite(background, alpha: alpha, over: base.rgb(dark: dark))
        }
        return contrastRatio(foreground, background)
    }
}
