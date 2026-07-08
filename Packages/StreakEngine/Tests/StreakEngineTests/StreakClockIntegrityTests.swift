import Foundation
import Testing
@testable import StreakEngine

// Fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z.
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)
private let day = 86_400
private let hour = 3_600

// One boot session for the whole file; a second one to simulate reboots. The engine only
// compares bootIDs for equality, so the literal values are arbitrary-but-pinned.
private let bootA = UUID(uuidString: "0B00071D-A000-4000-8000-000000000001")!
private let bootB = UUID(uuidString: "0B00071D-B000-4000-8000-000000000002")!

/// Anchor captured at streak start: uptime 50 000 s into boot A, wall clock at the epoch.
private let anchor = MonotonicAnchor(bootID: bootA, uptime: 50_000, wallClock: epoch)
private let quit = QuitSnapshot(startAt: epoch, monotonicAnchor: anchor)

/// Monotonic evidence after `truth` seconds of real time within boot A.
private func monoAfter(_ truth: Int) -> MonotonicNow {
    MonotonicNow(bootID: bootA, uptime: 50_000 + TimeInterval(truth))
}

// MARK: - E1.2 named tests (implementation-plan E1.2 — the five, verbatim)

@Suite("E1.2 clock-integrity guard")
struct StreakClockIntegrityTests {

    @Test(
        "a rolled-back wall clock freezes the streak at the monotonic truth — never inflates, never resets",
        arguments: [259_200, 7_650] // 3 days (a TZ-impossible magnitude) and an arbitrary non-TZ-shaped rollback
    )
    func test_clockSetBackward_streakFreezes_neverInflates(setback: Int) {
        let truth = 3 * day
        let now = epoch + TimeInterval(truth - setback) // user drags the clock backward
        let mono = monoAfter(truth)

        #expect(StreakCalculator.sanityCheck(anchor: anchor, now: now, monotonic: mono) == .clockRolledBack)

        let frozen = StreakCalculator.conservativeElapsedSeconds(anchor: anchor, now: now, monotonic: mono)
        #expect(frozen == truth)          // exactly the pre-rollback value: frozen, not reset
        #expect(frozen <= truth)          // and never inflated beyond the monotonic truth

        let value = StreakCalculator.currentStreak(for: quit, now: now, monotonic: mono)
        #expect(value.elapsedSeconds == truth)
        #expect(value.days == 3)
        #expect(value.clockSanity == .clockRolledBack)
    }

    @Test("after a rollback freeze, a recovered wall clock resumes counting from the anchor with no discontinuity")
    func test_clockSetBackward_thenRecovers_streakResumesFromAnchor() {
        // Phase 1 — day 3, clock dragged back to the anchor instant: frozen at 3 days.
        let rolledBack = StreakCalculator.currentStreak(for: quit, now: epoch, monotonic: monoAfter(3 * day))
        #expect(rolledBack.elapsedSeconds == 3 * day)
        #expect(rolledBack.clockSanity == .clockRolledBack)

        // Phase 2 — one real day later the user fixes the clock: normal counting resumes
        // from the same anchor, exactly one day ahead of the frozen value.
        let recovered = StreakCalculator.currentStreak(
            for: quit,
            now: epoch + TimeInterval(4 * day),
            monotonic: monoAfter(4 * day)
        )
        #expect(recovered.clockSanity == .normal)
        #expect(recovered.elapsedSeconds == 4 * day)
        #expect(recovered.elapsedSeconds - rolledBack.elapsedSeconds == day) // no jump, no reset
    }

    @Test("westward travel never adds a day — neither a manual −3h clock set nor a pure timezone change")
    func test_timezoneTravel_westward_doesNotAddADay() {
        let truth = 30 * day

        // Traveler with auto-time OFF lands 3h west and sets the clock back by hand.
        // TZ-shaped (quarter-hour multiple, ≤14h), so the verdict names it, and elapsed
        // holds the monotonic truth: still exactly day 30.
        let manual = StreakCalculator.currentStreak(
            for: quit,
            now: epoch + TimeInterval(truth - 3 * hour),
            monotonic: monoAfter(truth)
        )
        #expect(manual.clockSanity == .timezoneShift)
        #expect(manual.elapsedSeconds == truth)
        #expect(manual.days == 30)

        // Auto-time traveler: the timezone changes, the absolute wall clock does not.
        // Elapsed seconds are timezone-invariant (ADR-7: display formatting only).
        let auto = StreakCalculator.currentStreak(
            for: quit,
            now: epoch + TimeInterval(truth),
            monotonic: monoAfter(truth)
        )
        #expect(auto.clockSanity == .normal)
        #expect(auto.days == 30)
    }

    @Test("eastward travel never loses (or skips) a day — a +3h clock set cannot fake a day boundary")
    func test_timezoneTravel_eastward_doesNotLoseADay() {
        // 29d 23h of truth: one hour short of day 30. A +3h eastward clock set would push
        // the wall reading past the day-30 boundary (a skipped milestone / inflated day).
        let truth = 29 * day + 23 * hour
        let value = StreakCalculator.currentStreak(
            for: quit,
            now: epoch + TimeInterval(truth + 3 * hour),
            monotonic: monoAfter(truth)
        )
        #expect(value.clockSanity == .timezoneShift)
        #expect(value.elapsedSeconds == truth)   // not inflated by the forward set
        #expect(value.days == 29)                // the 30-day boundary is not faked...
        #expect(value.hours == 23)               // ...and the honest 23h remainder is kept
    }

    @Test(
        "a changed bootID makes uptimes incomparable — falls back to sanity-floored wall clock",
        arguments: [
            // (wall elapsed seconds, expected verdict, expected elapsed)
            (10 * 86_400, ClockSanity.normal, 10 * 86_400), // trust the wall across a reboot
            (-3_600, ClockSanity.clockRolledBack, 0),       // wall before anchor: floor at zero
        ]
    )
    func test_rebootChangesBootID_fallsBackToWallClockSanity(
        wallElapsed: Int, verdict: ClockSanity, elapsed: Int
    ) {
        let now = epoch + TimeInterval(wallElapsed)
        let mono = MonotonicNow(bootID: bootB, uptime: 5_000) // fresh boot, small uptime

        #expect(StreakCalculator.sanityCheck(anchor: anchor, now: now, monotonic: mono) == verdict)
        #expect(StreakCalculator.conservativeElapsedSeconds(anchor: anchor, now: now, monotonic: mono) == elapsed)
    }
}

// MARK: - E1.2 guard branches and boundaries

@Suite("E1.2 guard boundaries")
struct StreakClockIntegrityEdgeTests {

    @Test("disagreement exactly at tolerance is normal; one second beyond is not")
    func test_toleranceBoundary_isInclusive() {
        let truth = 5 * day

        let atTolerance = epoch + TimeInterval(truth - 60)
        #expect(StreakCalculator.sanityCheck(anchor: anchor, now: atTolerance, monotonic: monoAfter(truth)) == .normal)
        #expect(StreakCalculator.conservativeElapsedSeconds(anchor: anchor, now: atTolerance, monotonic: monoAfter(truth)) == truth - 60)

        let beyondTolerance = epoch + TimeInterval(truth - 61)
        #expect(StreakCalculator.sanityCheck(anchor: anchor, now: beyondTolerance, monotonic: monoAfter(truth)) == .clockRolledBack)
        #expect(StreakCalculator.conservativeElapsedSeconds(anchor: anchor, now: beyondTolerance, monotonic: monoAfter(truth)) == truth)
    }

    @Test("a near-quarter-hour adjustment classifies as a timezone shift, not tampering")
    func test_nearQuarterHourAdjustment_readsAsTimezoneShift() {
        let truth = 5 * day
        let now = epoch + TimeInterval(truth - 899) // 1s shy of a 15-minute step
        #expect(StreakCalculator.sanityCheck(anchor: anchor, now: now, monotonic: monoAfter(truth)) == .timezoneShift)
        #expect(StreakCalculator.conservativeElapsedSeconds(anchor: anchor, now: now, monotonic: monoAfter(truth)) == truth)
    }

    @Test("an anchored quit read without monotonic evidence falls back to the plain wall clock")
    func test_currentStreak_anchoredQuitWithoutReading_usesWallClock() {
        let value = StreakCalculator.currentStreak(for: quit, now: epoch + TimeInterval(day))
        #expect(value.elapsedSeconds == day)
        #expect(value.clockSanity == .normal)
    }

    @Test("momentum's denominator rides the guarded timeline — a rolled-back clock cannot inflate momentum")
    func test_momentum_doesNotInflate_underClockRollback() {
        // Review finding (Session 03): `tracked` derived from the raw `now` shrinks under a
        // rollback while the guarded numerator stays frozen, inflating clean ÷ tracked.
        // 100 tracked days of history (50 banked clean), 50 days of guarded current streak:
        // honest momentum = (50d + 50d) ÷ 150d = 2/3 — and it must read 2/3 even when the
        // wall clock is dragged 40 days backward.
        let history = QuitSnapshot(
            startAt: epoch,
            trackedSince: epoch - TimeInterval(100 * day),
            priorCleanSeconds: 50 * day,
            monotonicAnchor: anchor
        )
        let truth = 50 * day
        let honest = StreakCalculator.currentStreak(
            for: history, now: epoch + TimeInterval(truth), monotonic: monoAfter(truth)
        )
        #expect(honest.momentum == 2.0 / 3.0)

        let rolledBack = StreakCalculator.currentStreak(
            for: history, now: epoch + TimeInterval(10 * day), monotonic: monoAfter(truth)
        )
        #expect(rolledBack.clockSanity == .clockRolledBack)
        #expect(rolledBack.momentum == honest.momentum) // frozen, not inflated
    }
}

// MARK: - E1.2 property test (implementation-plan: seeded generator, no external dependency)

/// Deterministic SplitMix64 so every run replays the identical perturbation sequence
/// (test-suite §1.1: "seeded randomized TimeAnchor sequences"; §6.1.5: pinned seeds).
private struct SplitMix64: RandomNumberGenerator {
    var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

@Suite("E1.2 clock-noise property")
struct StreakClockNoisePropertyTests {

    @Test("under any seeded wall-clock noise the displayed streak stays within tolerance of the monotonic truth")
    func test_property_streakMonotonicUnderClockNoise() {
        var rng = SplitMix64(seed: 0x5EED_0E12_2026_0707) // pinned; add failing seeds per test-suite §6.1.5
        var truth = 0

        for step in 0..<300 {
            truth += Int.random(in: 0...86_400, using: &rng)
            let noise = Int.random(in: -259_200...259_200, using: &rng)
            let mono = monoAfter(truth)
            let now = epoch + TimeInterval(truth + noise)

            let display = StreakCalculator.conservativeElapsedSeconds(anchor: anchor, now: now, monotonic: mono)
            #expect(
                abs(display - truth) <= 60,
                "step \(step): truth \(truth), noise \(noise), display \(display)"
            )

            let verdict = StreakCalculator.sanityCheck(anchor: anchor, now: now, monotonic: mono)
            if abs(noise) > 60 {
                #expect(verdict != .normal, "step \(step): noise \(noise) must not read as normal")
            } else {
                #expect(verdict == .normal, "step \(step): noise \(noise) is within tolerance")
            }
        }
    }
}
