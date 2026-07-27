import SwiftUI

/// ME-8 (Session 53) — the **Waterline field**: the brand's second visual move and
/// the cure for the one-template sameness the redesign blueprint names (§9.6,
/// creative inventory §2). A reusable design-system primitive, not per-screen art:
/// the quiz is its first consumer, and ME-4 (summary backdrop), ME-9 (paywall) and
/// the future empty states spend the same component.
///
/// **Exactly three ingredients** (creative §2, obeyed literally):
/// 1. Two flat bands of the Horizon Gradient — Harbor Teal sky over Dusk Indigo
///    water. Two bands, never more; the seam is one long low sine, never a diagonal.
/// 2. One soft light-form — a single radial bloom at the crest. One per composition
///    is the ceiling.
/// 3. A thin luminous waterline over the band seam.
/// No outlines (this is a fill system), no texture (in-app fields are perfectly
/// flat — the ≤3% grain is a marketing-canvas-only allowance), no hot colors.
///
/// **`progress` is the whole state machine.** 0 = day, 1 = night. It does two things
/// at once, which is why one scalar is enough: the waterline RISES (the water claims
/// more of the frame) and the bloom SURFACES (the crest grows from nothing). That is
/// creative §4's "one continuous horizon, not thirteen paintings" — the emotional
/// twin of the progress bar, advancing as the user answers.
///
/// **DETERMINISTIC BY CONSTRUCTION — this is a deliberate departure worth reading.**
/// The obvious build is `TimelineView(.animation)` with a phase off `context.date`,
/// the way `WaveTimerView` does it. That would have been wrong here for three
/// independent reasons, any one sufficient:
/// - **Nothing asks for it.** Blueprint §6.3 and creative §4 both specify a field
///   whose state advances with *quiz progress*. A continuous sine loop is unrequested
///   motion on the most-traversed surface in the app.
/// - **It would poison every future golden.** This view takes NO time input at all,
///   so a snapshot of any quiz step is byte-stable forever. `WaveTimerView` needs a
///   `pauseDate` seam precisely because it is time-driven; a field that never reads
///   the clock needs no seam, and the deferred final golden batch inherits that free.
/// - **The panic path's budget is the house rule** (ADR-6): a full-screen Canvas
///   redrawing at display rate behind thirteen quiz steps is real battery for zero
///   specified benefit.
/// The only motion is the *transition between* progress states, and that belongs to
/// the caller — `QuizFlowView` animates it at `motion/standard` and drops it under
/// Reduce Motion.
///
/// **Colours ride `Theme`, so dark mode is free and the contrast registry is
/// untouched.** `brandPrimary` IS Harbor Teal and `brandSecondary` IS Dusk Indigo
/// (tokens-v2 §color), and both already carry their dark-mode counterparts
/// (`#4CC8B9` / `#93A0E8` — exactly the night accents creative §2 asks for). So this
/// file adds NO `ColorToken`: `allColorTokens` stays 18 and `contrastPairs` stays 32,
/// and `ThemeContrastTests` is undisturbed. That is correct rather than merely
/// convenient — a decorative layer that never carries text has no WCAG pair to pin,
/// and inventing one would claim a guarantee nothing renders against.
///
/// **Why it is safe to sit behind body copy at all:** the field composites at a
/// measured-safe `maxOpacity` over `surface/base`, is `accessibilityHidden`, and
/// takes no hits — so the registered pairs stay true because the field TINTS the
/// backdrop rather than becoming it. That safety is not assumed: see the opacity
/// contract below, where the spec's own "≤12%" is shown to break WCAG for this
/// palette and the real ceiling is derived instead. The clamp lives in `body`, not
/// in a comment, so no caller can undo it.
struct WaterlineField: View {
    /// 0 = day (teal-dominant, water low, no crest), 1 = night (indigo-dominant,
    /// water high, crest fully surfaced). Clamped internally — a caller that hands
    /// over an out-of-range fraction gets the nearest valid field, never a
    /// mis-drawn one.
    let progress: Double

    /// This instance's opacity ceiling. Hard-clamped to `opacityCeiling` in `body`.
    var maxOpacity: Double = WaterlineField.standardOpacity

    // MARK: - Opacity contract — DERIVED FROM WCAG, NOT FROM THE SPEC PROSE

    /// **Creative §4 says "≤12% opacity behind content". That number is unsafe for
    /// this palette, and the check that found it is worth repeating before anyone
    /// raises these constants.** Composite every band and light-form this view can
    /// draw over `surface/base`, then re-measure every token the onboarding
    /// surfaces render on that backdrop. At 12% the field pushes dark-mode
    /// `content/tertiary` over the waterline stroke to **2.63:1 against its 3.0
    /// floor** — a real WCAG failure, invisible to a golden (which only proves the
    /// pixels did not move) and reachable by Apple's `.contrast` audit.
    ///
    /// The binding pair is not the one you would guess, either: below ~9% the
    /// constraint stops being tertiary and becomes **light-mode `caution` on the
    /// water band** — the quiz's save-retry note — which the field drags from
    /// 5.08:1 down toward 4.5. So both ends of the palette are governed, and the
    /// numbers below are the measured safe set, each with headroom:
    ///
    /// | weight | margin over threshold | binding pair |
    /// |---|---|---|
    /// | keyboard 0.045 | 1.064× | light caution on water, 4.79 |
    /// | standard 0.060 | 1.044× | light caution on water, 4.70 |
    /// | ceiling 0.080 | 1.018× | light caution on water, 4.58 |
    ///
    /// `opacityCeiling` is enforced in `body`, not documented and trusted, so a
    /// future caller cannot open a contrast hole by passing a bolder number.
    ///
    /// **S54 CORRECTION — this comment used to claim the ceiling was "the highest
    /// value at which EVERY registered pair still passes". That was overstated, and
    /// the correction is the same lesson this file already teaches, turned on its
    /// own number.** Re-measured in ME-4 by compositing every band over
    /// `surface/base` and re-running all 32 pairs: the true figure for EVERY
    /// registered pair is **0.0391**, not 0.08. The three that break above it are
    /// all **doubly translucent** — a tinted fill (`caution@10%`, `primary@12%`)
    /// composited over a base the field has ALREADY tinted, so the field compounds
    /// through a second layer, and those pairs start with the least headroom in the
    /// registry (4.90 and 4.83 untinted). S53 measured the pairs whose background
    /// IS `surface/base`, which is why they were missed.
    ///
    /// **The shipped values are nevertheless correct, because the governing claim is
    /// per-surface, not universal.** Measured against what each consumer actually
    /// renders behind the field:
    ///
    /// | surface | exposed pairs | true ceiling | ships at |
    /// |---|---|---|---|
    /// | quiz (ME-8) | 7 — all opaque chips/wells, no tint | **0.0934** | 0.06 / 0.045 |
    /// | summary (ME-4) | 3 — the alcohol notice's caution tint | **0.0695** | 0.06 |
    ///
    /// So 0.08 stays: it is safe for both live consumers, and lowering it to 0.0391
    /// would dim the quiz for a hazard the quiz does not have. What a new consumer
    /// owes is the check, not the constant: **before putting a field behind any
    /// TRANSLUCENT fill, re-measure that fill's pairs over the tinted base.** ME-4's
    /// own answer was to remove the exposure structurally rather than document it —
    /// `AlcoholNoticeCard` now pins an opaque `surface/base` beneath its tint, so the
    /// registered composite is the one that renders whatever sits behind the card.
    /// That matters because nothing in CI can catch this class: no golden renders
    /// that card, and the summary audit mount does not construct one.
    ///
    /// The default field weight.
    static let standardOpacity: Double = 0.06
    /// Keyboard steps yield to the input well (creative §4, steps 2 / 5: "field
    /// dims under keyboard"). The typed value is the subject there, not the field.
    static let keyboardOpacity: Double = 0.045
    /// The measured hard ceiling. NOT the spec's 12% — see the table above.
    static let opacityCeiling: Double = 0.08

    var body: some View {
        Canvas { canvasContext, size in
            draw(in: &canvasContext, size: size)
        }
        .opacity(min(max(maxOpacity, 0), Self.opacityCeiling))
        // Decorative in the strict sense: it carries no information that the
        // words on the screen do not already carry, so it is hidden from every
        // assistive technology rather than described to it.
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }

    // MARK: - The drawing (pure geometry over `progress` — no clock, no randomness)

    private func draw(in context: inout GraphicsContext, size: CGSize) {
        let t = Self.clamped(progress)
        let waterlineY = size.height * Self.lerp(Self.dayWaterline, Self.nightWaterline, t)
        // Creative §2: "amplitude ≤4% of canvas height, one crest visible."
        let amplitude = size.height * Self.crestAmplitudeRatio
        let surface = surfacePath(size: size, waterlineY: waterlineY, amplitude: amplitude)

        // Band 1 — the sky. Fills the whole frame; the water is drawn over its
        // lower part, so the seam is the sine and nothing has to be clipped.
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .color(Theme.color.brandPrimary.color.opacity(Self.skyWeight))
        )

        // Band 2 — the water, the region beneath the sine.
        var water = surface
        water.addLine(to: CGPoint(x: size.width, y: size.height))
        water.addLine(to: CGPoint(x: 0, y: size.height))
        water.closeSubpath()
        context.fill(
            water,
            with: .color(Theme.color.brandSecondary.color.opacity(Self.waterWeight))
        )

        // The one light-form — a soft radial bloom at the crest, surfacing as the
        // quiz advances (creative §4: the crest is "absent at the start, fully
        // surfaced at the summary"). Feathered by construction: the gradient's
        // outer stop is fully clear, so there is no edge to see.
        let crest = CGPoint(x: size.width / 2, y: waterlineY - amplitude)
        let bloomRadius = size.width * Self.bloomRadiusRatio
        context.fill(
            Path(ellipseIn: CGRect(
                x: crest.x - bloomRadius,
                y: crest.y - bloomRadius,
                width: bloomRadius * 2,
                height: bloomRadius * 2
            )),
            with: .radialGradient(
                Gradient(colors: [
                    Self.foam.opacity(Self.bloomCoreOpacity * t),
                    Self.foam.opacity(0),
                ]),
                center: crest,
                startRadius: 0,
                endRadius: bloomRadius
            )
        )

        // The waterline itself — the reusable signature (creative §2). Luminous,
        // round-capped, never dark-on-light.
        context.stroke(
            surface,
            with: .color(Self.foam.opacity(Self.waterlineOpacity)),
            style: StrokeStyle(lineWidth: Self.waterlineWidth, lineCap: .round)
        )
    }

    /// The band seam: a single smooth crest peaking at centre and meeting both
    /// edges flat. Half a sine period is what "one crest visible" means — a full
    /// period would put a trough on screen and read as a wave, not a horizon.
    private func surfacePath(size: CGSize, waterlineY: CGFloat, amplitude: CGFloat) -> Path {
        var path = Path()
        let steps = Self.pathResolution
        for index in 0...steps {
            let fraction = Double(index) / Double(steps)
            let x = size.width * fraction
            let y = waterlineY - amplitude * sin(.pi * fraction)
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }

    // MARK: - Constants

    /// Foam (creative §2: `#FFFFFF` at 25–92% opacity, feathered edges). It is a
    /// deliberate NON-token: illustration ingredients are not UI colours, and
    /// promoting Foam to `allColorTokens` would oblige `contrastPairs` entries for
    /// a layer that never renders text. The `ThemeSourceLintTests` ban on raw
    /// monochromes scopes `App/Sources` *excluding* `DesignSystem/` for exactly
    /// this reason — colour is defined here and consumed everywhere else.
    private static let foam = Color.white

    /// Where the waterline sits at day (low — sky dominant) and at night (high —
    /// the water has risen). Fractions of canvas height.
    private static let dayWaterline: Double = 0.66
    private static let nightWaterline: Double = 0.42

    /// Creative §2 caps the sine at 4% of canvas height.
    private static let crestAmplitudeRatio: CGFloat = 0.04

    /// Relative band weights BEFORE the instance's `maxOpacity` is applied. The two
    /// differ so the composition survives the grayscale test (creative §2) — value
    /// structure carries the image, not hue.
    private static let skyWeight: Double = 0.55
    private static let waterWeight: Double = 1.0

    private static let bloomRadiusRatio: CGFloat = 0.42
    /// Inside creative §2's 25–92% Foam range, and chosen at the low end BECAUSE
    /// of the contrast solve above: at 0.75 the bloom core was the binding pair in
    /// dark mode (tertiary 2.99 vs 3.0). 0.55 moves the constraint back onto the
    /// water band, where the ceiling already governs it.
    private static let bloomCoreOpacity: Double = 0.55
    private static let waterlineOpacity: Double = 0.60
    /// "1–2pt at UI scale" (creative §2).
    private static let waterlineWidth: CGFloat = 1.5

    /// Sample count for the seam. 96 keeps the curve smooth at any device width
    /// while staying a fixed, cheap cost — the path is rebuilt only when
    /// `progress` changes, never per frame.
    private static let pathResolution = 96

    private static func clamped(_ value: Double) -> Double { min(max(value, 0), 1) }
    private static func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double { a + (b - a) * t }
}
