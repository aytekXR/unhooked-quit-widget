import CoreHaptics
import Foundation

/// CoreHaptics-backed production engine (bootstrap code, coverage-exempt per
/// test-suite §2; pattern-correctness assertions are device-tier — test 40). The
/// actual engine work is deferred through a Task hop so the panic path's first
/// frame spends nothing on it (§11); no haptics hardware (simulator) → silent no-op.
@MainActor
final class LiveHapticsEngine: HapticsPlaying {
    private var engine: CHHapticEngine?

    func playBreathPattern(_ pattern: BreathPacerPattern) {
        Task { @MainActor in
            self.play(events: Self.breathEvents(for: pattern))
        }
    }

    func playCelebrationTap() {
        Task { @MainActor in
            self.play(events: [CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3),
                ],
                relativeTime: 0
            )])
        }
    }

    private func play(events: [CHHapticEvent]) {
        guard let engine = preparedEngine(),
              let pattern = try? CHHapticPattern(events: events, parameters: []),
              let player = try? engine.makePlayer(with: pattern)
        else { return }
        try? player.start(atTime: CHHapticTimeImmediate)
    }

    private func preparedEngine() -> CHHapticEngine? {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return nil }
        if let engine { return engine }
        guard let created = try? CHHapticEngine() else { return nil }
        try? created.start()
        engine = created
        return created
    }

    /// The 4-7-8 rhythm as haptic events, timed from the same pure pattern the
    /// bloom renders: a rising continuous swell on inhale, one gentle tick at the
    /// hold, a softer falling swell on exhale. (The one-soft-haptic brand rule
    /// scopes to celebrations — the pacer legitimately carries the full rhythm.)
    private static func breathEvents(for pattern: BreathPacerPattern) -> [CHHapticEvent] {
        var events: [CHHapticEvent] = []
        var t: TimeInterval = 0
        for phase in pattern.phases() {
            switch phase.kind {
            case .inhale:
                events.append(CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.55),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.35),
                    ],
                    relativeTime: t,
                    duration: phase.duration
                ))
            case .hold:
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.25),
                    ],
                    relativeTime: t
                ))
            case .exhale:
                events.append(CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2),
                    ],
                    relativeTime: t,
                    duration: phase.duration
                ))
            }
            t += phase.duration
        }
        return events
    }
}
