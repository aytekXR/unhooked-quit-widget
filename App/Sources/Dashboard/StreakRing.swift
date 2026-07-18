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
/// **Motion (UIR-5c):** the ring can play a `motion/calm` (0.6s ease-out) APPEAR
/// animation — the fill sweeps 0→`fraction`. It is OPT-IN: only the live dashboard
/// (`RootPlaceholderView`) passes `animateOnAppear: true`. The DEFAULT is `false`, where
/// the fill draws STRAIGHT to `fraction` (`shownFraction` reads `fraction` directly, NOT
/// the `@State`), byte-identical to the pre-motion draw — so the snapshot fixtures and the
/// audit mount capture a SETTLED ring, this surface's goldens do not move, and no
/// mid-animation frame is ever captured. The animation itself renders only at runtime, so
/// it carries an operator DEVICE-EYEBALL flag (a golden cannot verify motion).
struct StreakRing: View {
    /// Momentum fill fraction; clamped to 0...1 at the draw.
    let fraction: Double
    var isDiscreet: Bool = false
    var isFrozen: Bool = false
    /// Opt-in appear animation (live dashboard only). Off ⇒ settled draw (goldens/audit).
    var animateOnAppear: Bool = false
    /// Drives the animated sweep; UNUSED when `animateOnAppear` is false (the draw reads
    /// `fraction` directly then), so it can never leave the settled fill stale.
    @State private var drawnFraction: Double = 0

    /// Settled draw reads `fraction` (always current); animated draw reads the `@State`.
    private var shownFraction: Double {
        min(max(animateOnAppear ? drawnFraction : fraction, 0), 1)
    }

    var body: some View {
        ZStack {
            // Track — the full circle beneath the fill arc.
            Circle()
                .stroke(trackColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
            // Fill — trimmed to the (settled or animating) fraction, rotated so 0 begins at 12 o'clock.
            Circle()
                .trim(from: 0, to: shownFraction)
                .stroke(strokeColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .accessibilityHidden(true)
        .onAppear {
            guard animateOnAppear else { return }
            withAnimation(.easeOut(duration: Theme.motion.calm)) { drawnFraction = fraction }
        }
        .onChange(of: fraction) { _, newValue in
            // A live momentum update sweeps to the new value (same calm curve); the
            // settled path ignores this (it reads `fraction` directly).
            guard animateOnAppear else { return }
            withAnimation(.easeOut(duration: Theme.motion.calm)) { drawnFraction = newValue }
        }
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
