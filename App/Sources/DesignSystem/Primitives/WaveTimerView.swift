import SwiftUI

/// P2 (redesign §6.8 / §9.4 / §11) — `WaveTimerView`: the panic timer step's
/// live horizon. One wave crest that swells and settles along the slow
/// ~15-minute curve (the `wave` motion token: ambient, sub-1Hz feel,
/// breath-modulated), teal on Canvas — the therapeutic claim "urges crest and
/// pass" made visible. Nothing here counts down: the crest RISES and PASSES,
/// and after it settles the water keeps a calm resting ripple (the wave never
/// "expires").
///
/// Hard rules honored:
/// - ZERO entry animation: this view mounts only on the timer step, after the
///   pacer — never the panic entry frame. Its initial render (startedAt ==
///   nil) is a PAUSED phase-zero frame (golden-deterministic, the
///   BreathBloomView precedent).
/// - Reduce Motion → the crest as a STATIC composition with a slow opacity
///   breath (§8): the wave shape freezes at its resting form; only opacity
///   moves, at the same 19s breath period.
/// - Decorative and `accessibilityHidden` — the step's words + the count-up
///   line carry all meaning (the wave is omitted entirely at AX sizes by the
///   caller, the StreakRing precedent).
struct WaveTimerView: View {
    /// When the ride began (`PanicFlowModel.timerStartedAt`); nil = paused
    /// phase zero.
    let startedAt: Date?
    let reduceMotion: Bool
    /// Freezes the crest at one instant for deterministic goldens (the
    /// `StreakWidgetView.pauseDate` precedent); production passes nil.
    var pauseDate: Date? = nil

    /// The therapeutic claim's curve: the crest peaks at ~7.5 min and settles
    /// by ~15 (the "usually within about 15 minutes" instruction, as motion).
    private static let crestDuration: TimeInterval = 15 * 60
    /// The 4-7-8 pacer's full cycle — the wave breathes at the breath period.
    private static let breathPeriod: TimeInterval = 19

    var body: some View {
        TimelineView(.animation(paused: startedAt == nil || pauseDate != nil)) { context in
            let reference = pauseDate ?? context.date
            let elapsed = startedAt.map { max(0, reference.timeIntervalSince($0)) } ?? 0
            Canvas { canvasContext, size in
                draw(in: &canvasContext, size: size, elapsed: elapsed)
            }
        }
        .frame(height: 160)
        .frame(maxWidth: Theme.layout.contentMaxWidth)
        .accessibilityHidden(true)
    }

    // MARK: - The drawing (pure math over elapsed ride time)

    private func draw(in context: inout GraphicsContext, size: CGSize, elapsed: TimeInterval) {
        let waterline = size.height * 0.62
        let amplitude = crestAmplitude(elapsed: elapsed) * (waterline - size.height * 0.08)
        let breath = breathPhase(elapsed: elapsed)

        // Reduce Motion: freeze the SHAPE at its resting form; breathe opacity.
        let shapeAmplitude = reduceMotion ? restingAmplitude * (waterline - size.height * 0.08) : amplitude
        let fillOpacity = reduceMotion
            ? Theme.alpha.bloomFill * (0.75 + 0.25 * breath)
            : Theme.alpha.bloomFill
        let lineOpacity = reduceMotion
            ? Theme.alpha.bloomRing + 0.35 * breath
            : Theme.alpha.bloomRing + 0.35

        let surface = surfacePath(size: size, waterline: waterline, amplitude: shapeAmplitude)

        // The water: the region under the surface, teal at the bloom fill alpha.
        var water = surface
        water.addLine(to: CGPoint(x: size.width, y: size.height))
        water.addLine(to: CGPoint(x: 0, y: size.height))
        water.closeSubpath()
        context.fill(water, with: .color(Theme.color.brandPrimary.color.opacity(fillOpacity)))

        // The luminous waterline: the surface stroked, brightest at the crest.
        context.stroke(
            surface,
            with: .color(Theme.color.brandPrimary.color.opacity(lineOpacity)),
            style: StrokeStyle(lineWidth: 2, lineCap: .round)
        )
    }

    /// The surface: a flat waterline carrying one centered crest bump (a
    /// gaussian — one soft light-form, §9.6's restraint; no texture, no foam).
    private func surfacePath(size: CGSize, waterline: CGFloat, amplitude: CGFloat) -> Path {
        var path = Path()
        let sigma = size.width * 0.16
        let center = size.width / 2
        let steps = 72
        for index in 0...steps {
            let x = size.width * CGFloat(index) / CGFloat(steps)
            let offset = (x - center) / sigma
            let y = waterline - amplitude * exp(-offset * offset / 2)
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }

    /// The water's calm resting rise — the wave is alive from the first frame
    /// and after it passes (never a dead flat line, never a growing threat).
    private var restingAmplitude: Double { 0.14 }

    /// Crest envelope over the ride: rises from resting, peaks mid-curve,
    /// settles back to resting by ~15 min and STAYS settled — it passed. The
    /// breath modulation keeps the settled water gently moving (sub-1Hz).
    private func crestAmplitude(elapsed: TimeInterval) -> Double {
        let progress = min(max(elapsed / Self.crestDuration, 0), 1)
        let envelope = sin(progress * .pi) // 0 → 1 (at 7.5 min) → 0 (at 15)
        let breath = breathPhase(elapsed: elapsed) // 0...1 at the breath period
        return restingAmplitude + 0.72 * envelope + 0.06 * breath * (0.25 + envelope)
    }

    /// 0...1 sinusoid at the 4-7-8 cycle's 19s period — breath-synced motion.
    private func breathPhase(elapsed: TimeInterval) -> Double {
        (sin(elapsed * 2 * .pi / Self.breathPeriod) + 1) / 2
    }
}
