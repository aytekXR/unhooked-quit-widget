import Foundation

/// The 4-7-8 breath pattern as pure data (implementation-plan E3.2: "pattern model
/// unit test") — built from the shipping script's pacer spec, never hardcoded. All
/// timing math lives here as pure functions of the pattern; the view animates FROM
/// this model and the haptics engine plays it, so both stay dumb renderers.
struct BreathPacerPattern: Equatable, Sendable {
    enum PhaseKind: String, Equatable, Sendable, CaseIterable {
        case inhale, hold, exhale
    }

    /// One timed slice of the pattern (e.g. "round 2's 7-second hold").
    struct Phase: Equatable, Sendable {
        var kind: PhaseKind
        var duration: TimeInterval
        var round: Int
    }

    var inhale: TimeInterval
    var hold: TimeInterval
    var exhale: TimeInterval
    var rounds: Int

    init(inhale: TimeInterval, hold: TimeInterval, exhale: TimeInterval, rounds: Int) {
        self.inhale = inhale
        self.hold = hold
        self.exhale = exhale
        self.rounds = rounds
    }

    /// Field-name mapping from the shipping JSON's pacer spec (inhaleSeconds/…/cycles).
    init(pacer: PanicScript.Pacer) {
        self.init(
            inhale: pacer.inhaleSeconds,
            hold: pacer.holdSeconds,
            exhale: pacer.exhaleSeconds,
            rounds: pacer.cycles
        )
    }

    /// The full timed sequence: (inhale → hold → exhale) × rounds.
    func phases() -> [Phase] {
        [] // red skeleton
    }

    var totalDuration: TimeInterval {
        0 // red skeleton
    }

    /// The phase active `t` seconds into the pattern; `nil` once the pattern is over
    /// (t ≥ totalDuration). Negative t clamps to the first phase — a pacer can never
    /// render "nothing" while it is on screen.
    func phase(at t: TimeInterval) -> Phase? {
        nil // red skeleton
    }
}

/// The haptics seam (test-suite §3.1: "FakeHapticsEngine recording pattern-play calls
/// for logic tests; real CoreHaptics on device tier only"). Protocol double per
/// test-suite §7 rule 8 — never a subclassed SDK type. Main-actor bound like its only
/// callers (the flow model and views).
@MainActor
protocol HapticsPlaying {
    /// Plays the full breath pattern (the pacer's multi-tap rhythm — the brandkit's
    /// one-soft-haptic rule scopes to celebrations, not the pacer).
    func playBreathPattern(_ pattern: BreathPacerPattern)
    /// The single soft celebration tap (brandkit §7: quiet celebration, never confetti).
    func playCelebrationTap()
}
