import Foundation

/// UIR-0 (Session 32) — the design-token data layer (tokens-v2, the brandkit §2
/// addendum). PURE FOUNDATION by ruling R32.1: hex values live here as DATA
/// (0xRRGGBB), never as `Color`/`UIColor`, so the WCAG contrast harness
/// (`ThemeContrastTests` + the Linux scratch rehearsal) computes ratios off the
/// exact shipping bytes with zero UIKit. SwiftUI derivation lives in
/// `ColorToken+Color.swift` (the sole UIKit-touching half).
///
/// Every value is machine-verified — `docs/design/tokens-v2.md` carries the full
/// computed acceptance table. Five LIGHT hexes deliberately drift from brandkit
/// §2's prose (its claimed ratios were never machine-checked; these are the
/// minimal hue-preserving corrections that clear WCAG with margin — R32.7).
/// DARK canon passes as written, zero changes.
struct ColorToken: Sendable, Hashable {
    /// tokens-v2 name, e.g. "brand/primary" — the key the contrast registry and
    /// docs table share.
    let name: String
    /// 0xRRGGBB, light appearance.
    let lightRGB: UInt32
    /// 0xRRGGBB, dark appearance.
    let darkRGB: UInt32
}

extension ColorToken {
    /// sRGB components in 0...1 for the given appearance — the contrast math's
    /// input shape.
    func rgb(dark: Bool) -> (r: Double, g: Double, b: Double) {
        let value = dark ? darkRGB : lightRGB
        return (
            Double((value >> 16) & 0xFF) / 255.0,
            Double((value >> 8) & 0xFF) / 255.0,
            Double(value & 0xFF) / 255.0
        )
    }
}
