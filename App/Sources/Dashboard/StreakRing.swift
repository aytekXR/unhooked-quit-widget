import SwiftUI

/// UIR-2 (Session 34) — the momentum ring (brandkit §4.1 custom-glyph budget #3;
/// tokens-v2 §6 spec). A circular arc: `brand/secondary` stroke on a `surface/sunken`
/// track, 6pt round-capped, filled to the momentum fraction. Momentum is INDIGO so a
/// teal streak and an indigo momentum are never confused (brandkit §2.1).
///
/// Always `.accessibilityHidden(true)` — the card is the single semantic unit and the
/// momentum figure is spoken by its own `Text` node (tokens-v2 §6). Discreet OR frozen
/// renders both arcs in `semantic/paused`: the fill vanishes into the track (a uniform
/// neutral circle) — a shoulder-surfer defense in discreet mode (R22.2) and a calm,
/// non-alarm treatment for a frozen streak (brandkit §2: a frozen streak is not a
/// problem state).
///
/// **R33.12 compliance:** the 6pt `lineWidth` is a `StrokeStyle` parameter on a `Circle`
/// (a Shape), never a `.font(.system(size:))` on a `Text` — Apple's `.dynamicType`
/// audit scans text nodes for a type-metric contract and does not scan Shape strokes
/// (proven on run 29303961082, where the ring passed the full set). No `Theme.type`
/// glyph token is used here; those are for decorative SF-Symbol `Image`s only.
///
/// **Motion:** the ring renders SETTLED (drawn straight to `fraction`). The
/// motion/calm appear animation (tokens-v2 §6) is deferred to UIR-5 (the motion
/// session) — a settled ring is byte-identical to an animated one at rest, so adding
/// the appear animation later does not move this surface's goldens, and rendering
/// settled keeps the snapshot lane deterministic (no mid-animation frame capture).
struct StreakRing: View {
    /// Momentum fill fraction; clamped to 0...1 at the draw.
    let fraction: Double
    var isDiscreet: Bool = false
    var isFrozen: Bool = false

    var body: some View {
        ZStack {
            // Track — the full circle beneath the fill arc.
            Circle()
                .stroke(trackColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
            // Fill — trimmed to the fraction, rotated so 0 begins at 12 o'clock.
            Circle()
                .trim(from: 0, to: min(max(fraction, 0), 1))
                .stroke(strokeColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .accessibilityHidden(true)
    }

    /// Indigo momentum in the active state; neutral gray when discreet or frozen (the
    /// fill vanishes into the track). Contrast pair: `secondary fill vs sunken track`
    /// 4.64 L / 7.82 D and `paused (large) on raised` — both 1.4.11-clean non-text UI.
    private var strokeColor: Color {
        (isDiscreet || isFrozen) ? Theme.color.paused.color : Theme.color.brandSecondary.color
    }

    private var trackColor: Color {
        (isDiscreet || isFrozen) ? Theme.color.paused.color : Theme.color.surfaceSunken.color
    }
}
