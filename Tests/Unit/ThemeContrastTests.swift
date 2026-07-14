import Foundation
import Testing
@testable import Unhooked

// UIR-0 (Session 32) unit lane — the R28.13 closure-by-construction gate.
//
// The S28 audit (run 29262073722) enumerated sub-WCAG teal-button/secondary-text
// contrast across the goldened panic/slip surfaces; UIR-0 closes the class by
// swapping every view onto the tokens-v2 palette and PINNING the palette here:
// every fg/bg pair the swapped surfaces render is registered in
// `Theme.contrastPairs` with its WCAG threshold, and this suite computes the
// actual ratio (translucent fills composited to their EFFECTIVE color first)
// over the exact shipping token bytes. A token edit that dips any pair below
// threshold fails the unit lane BEFORE the a11y audit's restored `.contrast`
// class could ever fire on a rule-11 safety leg.
//
// Born-green (R31.4 valve): the designed red's entire evidence value —
// fires-on-violation — is reproduced free below (the calibration fixtures) and
// in the pre-push Linux scratch rehearsal over these same files (pass on real
// bytes; fire on a mutated token); the green run's own results prove execution.
//
// Registry discipline (the R31.6 pin philosophy): the token key-SET is pinned
// exactly — adding a color token is a deliberate two-place edit (token +
// registry, and a third for any pair it renders in).
@Suite("UIR-0 · tokens-v2 contrast registry")
struct ThemeContrastTests {
    // MARK: - The gate itself

    @Test func test_everyRegisteredPair_meetsItsWCAGThreshold_bothAppearances() {
        for pair in Theme.contrastPairs {
            for dark in [false, true] {
                let ratio = ContrastMath.ratio(for: pair, dark: dark)
                #expect(
                    ratio >= pair.threshold,
                    """
                    tokens-v2 regression: '\(pair.note)' computes \(ratio) in \
                    \(dark ? "dark" : "light") mode — below its \(pair.threshold):1 \
                    WCAG threshold. The palette must stay WCAG-clean BY CONSTRUCTION \
                    (R28.13); fix the token, never this assertion.
                    """
                )
            }
        }
    }

    /// The registry can only GROW (the R28.13 exclusion-list direction rule,
    /// inverted: pairs are protection, and protection never shrinks silently).
    @Test func test_contrastRegistry_neverShrinks() {
        #expect(
            Theme.contrastPairs.count >= 28,
            "the contrast registry lost pairs — removing a pair removes protection; the floor only rises"
        )
    }

    // MARK: - Token key-set pin (exact-set semantics)

    @Test func test_colorTokenRegistry_isTheExactAuthoredSet() {
        let names = Theme.allColorTokens.map(\.name)
        #expect(
            Set(names).count == names.count,
            "duplicate token names — every token name must be unique (the docs table joins on it)"
        )
        #expect(
            Set(names) == [
                "brand/primary", "brand/onPrimary", "brand/primaryPressed",
                "brand/secondary", "brand/accentFlame",
                "semantic/positive", "semantic/caution", "semantic/info", "semantic/paused",
                "surface/base", "surface/raised", "surface/sunken", "surface/overlay",
                "content/primary", "content/secondary", "content/tertiary",
                "border/hairline", "border/strong",
            ],
            "the color-token key set drifted — growing the palette is a deliberate two-place edit (token + this pin), and docs/design/tokens-v2.md re-derives with it"
        )
    }

    /// Every pair references registered tokens — a pair over an unregistered
    /// token would dodge the key-set pin.
    @Test func test_everyPair_referencesRegisteredTokens() {
        let registered = Set(Theme.allColorTokens.map(\.name))
        for pair in Theme.contrastPairs {
            #expect(registered.contains(pair.foreground.name), "unregistered fg in '\(pair.note)'")
            #expect(registered.contains(pair.background.name), "unregistered bg in '\(pair.note)'")
            if let base = pair.backgroundBase {
                #expect(registered.contains(base.name), "unregistered bg base in '\(pair.note)'")
            }
            #expect(
                pair.threshold == 4.5 || pair.threshold == 3.0,
                "'\(pair.note)': thresholds are WCAG's two tiers only — 4.5 (normal text) or 3.0 (large/UI)"
            )
        }
    }

    // MARK: - Gate-gates-itself calibration (the math FIRES on violations)

    @Test func test_calibration_wcagAnchors() {
        let white = (r: 1.0, g: 1.0, b: 1.0)
        let black = (r: 0.0, g: 0.0, b: 0.0)
        let ratio = ContrastMath.contrastRatio(white, black)
        #expect(abs(ratio - 21.0) < 0.001, "white/black must compute exactly 21:1 — the WCAG anchor")
        #expect(
            abs(ContrastMath.contrastRatio(white, white) - 1.0) < 0.001,
            "identical colors must compute exactly 1:1"
        )
        // Symmetry: the ratio never depends on which color is 'foreground'.
        let teal = Theme.color.brandPrimary.rgb(dark: false)
        #expect(
            abs(ContrastMath.contrastRatio(white, teal) - ContrastMath.contrastRatio(teal, white)) < 0.000001,
            "contrast must be symmetric"
        )
    }

    /// A deliberately failing fixture proves the gate is non-vacuous: the exact
    /// pre-UIR-0 defect (S28's white-on-system-teal button, #FFFFFF on #30B0C7)
    /// must compute BELOW 4.5 — if the math ever stops firing on the shape this
    /// gate exists to prevent, this test fails first.
    @Test func test_calibration_theS28TealButtonDefect_stillComputesAsAViolation() {
        let systemTealLight = ColorToken(name: "fixture/systemTeal", lightRGB: 0x30B0C7, darkRGB: 0x40C8E0)
        let white = ColorToken(name: "fixture/white", lightRGB: 0xFFFFFF, darkRGB: 0xFFFFFF)
        let pair = Theme.ContrastPair(
            "S28 defect fixture — white on system teal",
            fg: white, bg: systemTealLight, threshold: 4.5
        )
        let light = ContrastMath.ratio(for: pair, dark: false)
        #expect(light < 4.5, "the S28 defect fixture must FIRE (computed \(light)) — a gate that passes its own violation is vacuous")
    }

    /// Alpha compositing calibration: 50% black over white is the exact mid-gray,
    /// and compositing at alpha 1 is the top color itself.
    @Test func test_calibration_alphaCompositing() {
        let white = (r: 1.0, g: 1.0, b: 1.0)
        let black = (r: 0.0, g: 0.0, b: 0.0)
        let mid = ContrastMath.composite(black, alpha: 0.5, over: white)
        #expect(abs(mid.r - 0.5) < 0.001 && abs(mid.g - 0.5) < 0.001 && abs(mid.b - 0.5) < 0.001)
        let opaque = ContrastMath.composite(black, alpha: 1.0, over: white)
        #expect(opaque.r == 0 && opaque.g == 0 && opaque.b == 0)
    }

    // MARK: - Documented scrim floor (tokens-v2 §interaction)

    @Test func test_scrimAlpha_holdsTheWhiteOnScrimFloor() {
        // White text over the scrim composited on the LIGHT base is the worst
        // case (dark base trivially passes). 55% is the floor: 50% computes 4.22.
        let base = Theme.color.surfaceBase.rgb(dark: false)
        let scrimmed = ContrastMath.composite((r: 0, g: 0, b: 0), alpha: Theme.alpha.scrim, over: base)
        let ratio = ContrastMath.contrastRatio((r: 1, g: 1, b: 1), scrimmed)
        #expect(
            ratio >= 4.5,
            "white-on-scrim computes \(ratio) — the scrim alpha must keep sheet chrome legible (uipro 40–60% rule, floor-calibrated at 55%)"
        )
    }
}
