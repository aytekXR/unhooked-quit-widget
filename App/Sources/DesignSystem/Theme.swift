import Foundation

/// UIR-0 (Session 32) — the single source of truth for the app's visual tokens
/// (tokens-v2; roadmap §2.5 "a Theme layer in code"). STATIC NAMESPACE by ruling
/// R32.1: one theme ships, so environment injection buys nothing and would put a
/// lookup on the panic path's first frame (ADR-6). Pure Foundation — see
/// `ColorToken.swift` for the data-first design.
///
/// Growth discipline (the R31.6 pin philosophy): adding a color token is a
/// deliberate THREE-place edit — the static token, `allColorTokens`, and (for any
/// pair it renders in) `contrastPairs`. `ThemeContrastTests` pins the registry
/// key-set and every declared pair's WCAG ratio, so a token that skips the
/// registry or a pair that dips below threshold fails the unit lane.
enum Theme {
    // MARK: - Color tokens (tokens-v2 §color; light/dark verified pairs)

    enum color {
        // Brand
        static let brandPrimary = ColorToken(name: "brand/primary", lightRGB: 0x0C6F65, darkRGB: 0x4CC8B9)
        static let brandOnPrimary = ColorToken(name: "brand/onPrimary", lightRGB: 0xFFFFFF, darkRGB: 0x08302B)
        static let brandPrimaryPressed = ColorToken(name: "brand/primaryPressed", lightRGB: 0x0A5F57, darkRGB: 0x6ADACB)
        static let brandSecondary = ColorToken(name: "brand/secondary", lightRGB: 0x5262BC, darkRGB: 0x93A0E8)
        /// Streak flame / milestone glyphs ONLY — never buttons, never text
        /// (decorative-size exemption; tokens-v2 exempt list).
        static let accentFlame = ColorToken(name: "brand/accentFlame", lightRGB: 0xE8833A, darkRGB: 0xF29D5C)

        // Semantic
        static let positive = ColorToken(name: "semantic/positive", lightRGB: 0x2C774B, darkRGB: 0x6FCE97)
        /// ALL warnings AND all errors — amber, never red (brandkit §2 hard rule).
        static let caution = ColorToken(name: "semantic/caution", lightRGB: 0x8C6100, darkRGB: 0xE5B84B)
        static let info = ColorToken(name: "semantic/info", lightRGB: 0x3D6C9E, darkRGB: 0x8FB6E0)
        /// Frozen streak — neutral gray; a frozen streak is not a problem state.
        static let paused = ColorToken(name: "semantic/paused", lightRGB: 0x6E7681, darkRGB: 0x9AA3AD)

        // Surfaces
        static let surfaceBase = ColorToken(name: "surface/base", lightRGB: 0xF7F6F3, darkRGB: 0x121417)
        static let surfaceRaised = ColorToken(name: "surface/raised", lightRGB: 0xFFFFFF, darkRGB: 0x1C1F24)
        static let surfaceSunken = ColorToken(name: "surface/sunken", lightRGB: 0xEEECE7, darkRGB: 0x0B0D0F)
        static let surfaceOverlay = ColorToken(name: "surface/overlay", lightRGB: 0xFFFFFF, darkRGB: 0x22262C)

        // Content
        static let contentPrimary = ColorToken(name: "content/primary", lightRGB: 0x1A1D21, darkRGB: 0xF2F1EE)
        static let contentSecondary = ColorToken(name: "content/secondary", lightRGB: 0x565D66, darkRGB: 0xA8AFB8)
        /// Large text / large glyphs ONLY (3:1 tier) — never body copy.
        static let contentTertiary = ColorToken(name: "content/tertiary", lightRGB: 0x80868E, darkRGB: 0x6E757E)

        // Borders
        /// Decorative 1px separators — WCAG 1.4.11-exempt BY DESIGN (documented in
        /// tokens-v2 exempt list); where a boundary conveys state use borderStrong.
        static let borderHairline = ColorToken(name: "border/hairline", lightRGB: 0xE2E0DB, darkRGB: 0x2B3036)
        static let borderStrong = ColorToken(name: "border/strong", lightRGB: 0x80868E, darkRGB: 0x6E757E)
    }

    /// Registry — the machine-enumerable token set (explicit, not Mirror: statics
    /// are not instance-mirrored; ruling R32.1). Key-set pinned by the unit lane.
    static let allColorTokens: [ColorToken] = [
        color.brandPrimary, color.brandOnPrimary, color.brandPrimaryPressed,
        color.brandSecondary, color.accentFlame,
        color.positive, color.caution, color.info, color.paused,
        color.surfaceBase, color.surfaceRaised, color.surfaceSunken, color.surfaceOverlay,
        color.contentPrimary, color.contentSecondary, color.contentTertiary,
        color.borderHairline, color.borderStrong,
    ]

    // MARK: - Interaction constants (tokens-v2 §interaction)

    /// Translucent-fill alphas the UI composites over a surface. Declared here so
    /// the contrast registry can compute the EFFECTIVE composite color for every
    /// tinted background the app renders (never eyeballed).
    enum alpha {
        /// Selection / tinted-row fill: primary @ 12% over a surface.
        static let selectionTint = 0.12
        /// The caution notice card's fill: caution @ 10% over a surface.
        static let cautionTint = 0.10
        /// Modal dimming scrim: black @ 55% (uipro 40–60% rule; 55% is the LIGHT
        /// white-on-scrim 4.5:1 floor — 50% computes 4.22, fails).
        static let scrim = 0.55
        /// The pacer bloom's resting ring fill (decorative, a11y-hidden).
        static let bloomFill = 0.28
        static let bloomRing = 0.25
        static let bloomTick = 0.35
    }

    // MARK: - Contrast registry (tokens-v2 §acceptance)

    /// A foreground/background pair the app actually renders, with the WCAG
    /// threshold that governs it. `backgroundAlpha`/`backgroundBase` express a
    /// translucent fill composited over its backing surface, so the harness
    /// computes the pair against the EFFECTIVE rendered color.
    struct ContrastPair: Sendable {
        let note: String
        let foreground: ColorToken
        let background: ColorToken
        /// When non-nil, `background` renders at this alpha over `backgroundBase`.
        let backgroundAlpha: Double?
        let backgroundBase: ColorToken?
        /// 4.5 = WCAG normal text; 3.0 = large text / non-text UI (1.4.11).
        let threshold: Double

        init(
            _ note: String,
            fg: ColorToken,
            bg: ColorToken,
            bgAlpha: Double? = nil,
            bgBase: ColorToken? = nil,
            threshold: Double
        ) {
            self.note = note
            self.foreground = fg
            self.background = bg
            self.backgroundAlpha = bgAlpha
            self.backgroundBase = bgBase
            self.threshold = threshold
        }
    }

    /// Every gating pair the swapped surfaces render (both modes are checked).
    /// This IS the R28.13 closure-by-construction mechanism: the audit's
    /// `.contrast` class stays green because these numbers cannot regress
    /// without failing the unit lane first.
    static let contrastPairs: [ContrastPair] = [
        // Filled primary buttons (panic exits, slip log, quiz continue, summary CTA)
        ContrastPair("onPrimary label on primary fill", fg: color.brandOnPrimary, bg: color.brandPrimary, threshold: 4.5),
        ContrastPair("onPrimary label on pressed fill", fg: color.brandOnPrimary, bg: color.brandPrimaryPressed, threshold: 4.5),
        // Primary-as-text (resources link, undo button, notice actions, echoes)
        ContrastPair("primary text on base", fg: color.brandPrimary, bg: color.surfaceBase, threshold: 4.5),
        ContrastPair("primary text on raised", fg: color.brandPrimary, bg: color.surfaceRaised, threshold: 4.5),
        ContrastPair("primary text on sunken", fg: color.brandPrimary, bg: color.surfaceSunken, threshold: 4.5),
        // Body content on every surface
        ContrastPair("content primary on base", fg: color.contentPrimary, bg: color.surfaceBase, threshold: 4.5),
        ContrastPair("content primary on raised", fg: color.contentPrimary, bg: color.surfaceRaised, threshold: 4.5),
        ContrastPair("content primary on sunken", fg: color.contentPrimary, bg: color.surfaceSunken, threshold: 4.5),
        ContrastPair("content secondary on base", fg: color.contentSecondary, bg: color.surfaceBase, threshold: 4.5),
        ContrastPair("content secondary on raised", fg: color.contentSecondary, bg: color.surfaceRaised, threshold: 4.5),
        // Also the ghost-disabled button label (contentSecondary on sunken — R32.3)
        ContrastPair("content secondary on sunken", fg: color.contentSecondary, bg: color.surfaceSunken, threshold: 4.5),
        // Large-only tertiary (3:1 tier — never body copy)
        ContrastPair("content tertiary (large) on base", fg: color.contentTertiary, bg: color.surfaceBase, threshold: 3.0),
        ContrastPair("content tertiary (large) on sunken", fg: color.contentTertiary, bg: color.surfaceSunken, threshold: 3.0),
        // Semantic text
        ContrastPair("caution text on base", fg: color.caution, bg: color.surfaceBase, threshold: 4.5),
        ContrastPair("caution text on raised", fg: color.caution, bg: color.surfaceRaised, threshold: 4.5),
        ContrastPair("positive text on base", fg: color.positive, bg: color.surfaceBase, threshold: 4.5),
        ContrastPair("positive text on raised", fg: color.positive, bg: color.surfaceRaised, threshold: 4.5),
        // The paywall trial badge (positive text on a NEUTRAL sunken capsule —
        // a positive-on-positive-tint composition computes 4.29, sub-threshold,
        // so the badge fill is sunken by ruling R32.3) and sunken-row semantics.
        ContrastPair("positive text on sunken", fg: color.positive, bg: color.surfaceSunken, threshold: 4.5),
        ContrastPair("caution text on sunken", fg: color.caution, bg: color.surfaceSunken, threshold: 4.5),
        ContrastPair("info text on raised", fg: color.info, bg: color.surfaceRaised, threshold: 4.5),
        ContrastPair("paused (large) on raised", fg: color.paused, bg: color.surfaceRaised, threshold: 3.0),
        // Momentum / progress (brand secondary as text and as a 1.4.11 fill)
        ContrastPair("secondary text on base", fg: color.brandSecondary, bg: color.surfaceBase, threshold: 4.5),
        // UIR-2: the dashboard card's active momentum figure (brand/secondary text on the
        // raised card surface). 5.48 L / 6.64 D — comfortable normal-text pass.
        ContrastPair("secondary text on raised", fg: color.brandSecondary, bg: color.surfaceRaised, threshold: 4.5),
        ContrastPair("secondary fill vs sunken track (UI)", fg: color.brandSecondary, bg: color.surfaceSunken, threshold: 3.0),
        // Tinted fills, composited to their EFFECTIVE color first
        ContrastPair(
            "content primary on selection tint (primary@12% over base)",
            fg: color.contentPrimary, bg: color.brandPrimary,
            bgAlpha: alpha.selectionTint, bgBase: color.surfaceBase, threshold: 4.5
        ),
        ContrastPair(
            "content secondary on caution tint (caution@10% over base)",
            fg: color.contentSecondary, bg: color.caution,
            bgAlpha: alpha.cautionTint, bgBase: color.surfaceBase, threshold: 4.5
        ),
        ContrastPair(
            "content primary on caution tint (caution@10% over base)",
            fg: color.contentPrimary, bg: color.caution,
            bgAlpha: alpha.cautionTint, bgBase: color.surfaceBase, threshold: 4.5
        ),
        ContrastPair(
            "primary action text on caution tint (caution@10% over base)",
            fg: color.brandPrimary, bg: color.caution,
            bgAlpha: alpha.cautionTint, bgBase: color.surfaceBase, threshold: 4.5
        ),
        ContrastPair(
            "primary action text on selection tint (primary@12% over base)",
            fg: color.brandPrimary, bg: color.brandPrimary,
            bgAlpha: alpha.selectionTint, bgBase: color.surfaceBase, threshold: 4.5
        ),
        // UIR-4: the paywall plan card's price subhead (content/secondary) on the SELECTED
        // card (primary@12% over base). 5.07 L / 6.41 D — machine-verified before pinning.
        ContrastPair(
            "content secondary on selection tint (primary@12% over base) — paywall plan card price",
            fg: color.contentSecondary, bg: color.brandPrimary,
            bgAlpha: alpha.selectionTint, bgBase: color.surfaceBase, threshold: 4.5
        ),
        // Component boundaries that convey state (1.4.11)
        ContrastPair("strong border vs base (UI)", fg: color.borderStrong, bg: color.surfaceBase, threshold: 3.0),
        ContrastPair("primary ring / glyph vs base (UI)", fg: color.brandPrimary, bg: color.surfaceBase, threshold: 3.0),
    ]
}
