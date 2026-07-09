import Foundation

/// Stateless pure-function computation core. Time is ALWAYS a parameter; this type holds
/// no clock and never reads `Date()`/`ProcessInfo`.
// This is the file the strictest coverage bar measures (100% regions) — keep forwarders
// and types out of it.
public struct StreakCalculator: Sendable {
    public init() {}

    private static let secondsPerHour = 3_600
    private static let secondsPerWeek: Decimal = 604_800

    /// Momentum as a fraction 0...1 = cumulative clean ÷ total tracked.
    /// Zero tracked time ⇒ 1.0: nothing tracked yet means nothing wasted (the no-shame
    /// reading). A slip leaves it unchanged in the same tick — the ended streak is
    /// banked whole (the forgiveness differentiator); gaps only enter through consumer
    /// state where tracked history exceeds banked clean time. Negative clean reads as 0;
    /// the ratio is clamped so inconsistent inputs can never leave 0...1.
    public static func momentum(cleanSeconds: Int, totalSeconds: Int) -> Double {
        guard totalSeconds > 0 else { return 1.0 }
        let ratio = Double(max(0, cleanSeconds)) / Double(totalSeconds)
        return min(1.0, max(0.0, ratio))
    }

    /// Money saved, pro-rated from weekly spend by clean time: `weeklySpend × cleanSeconds
    /// ÷ 604_800`, `Decimal` end-to-end, multiply-BEFORE-divide (divide-first turns exact
    /// results like 365d × $87.50 = $4562.50 into repeating decimals). Returned exact and
    /// unrounded — rounding scale is currency-specific, so it belongs to presentation.
    /// Non-positive spend or clean time ⇒ 0 (never negative; free habits are first-class).
    public static func moneySaved(weeklySpend: Decimal, cleanSeconds: Int) -> Decimal {
        guard weeklySpend > 0, cleanSeconds > 0 else { return 0 }
        return weeklySpend * Decimal(cleanSeconds) / secondsPerWeek
    }

    /// First milestone not yet reached at `elapsedSeconds`. Reached ⇔ `elapsedSeconds >=
    /// afterHours × 3600` (the milestone you are exactly AT is earned), so "next" is the
    /// smallest `afterHours` strictly beyond the elapsed time. Sorted defensively — bundled
    /// JSON carries no ordering guarantee. Empty table or all reached ⇒ nil.
    public static func nextMilestone(elapsedSeconds: Int, in table: MilestoneTable) -> Milestone? {
        // Compared in floored hours (equivalent to seconds for the >-boundary, since
        // afterHours is whole): division cannot overflow where `afterHours * 3600` on an
        // untrusted decoded value could trap.
        table.milestones
            .sorted { $0.afterHours < $1.afterHours }
            .first { $0.afterHours > max(0, elapsedSeconds) / secondsPerHour }
    }

    // MARK: Clock-integrity guard

    /// Disagreement between wall clock and monotonic evidence below this is treated as
    /// normal scheduling/rounding noise, not tampering.
    public static let defaultClockTolerance: TimeInterval = 60

    /// Across a reboot, wall-clock credit since the last trusted reading (`lastKnownGood`)
    /// is honored only up to this ceiling; a larger unverifiable gap freezes the elapsed
    /// value at the verified span plus this cap and flags the read. The bound is
    /// per-reboot by nature (a fresh trusted reading in the new boot restores monotonic
    /// verification) — a documented, accepted limitation of reboot-crossing evidence.
    public static let defaultRebootGapCap: TimeInterval = 14 * 86_400

    /// Clock verdict for a read: does the wall clock agree with the monotonic evidence?
    /// `.timezoneShift` names a wall adjustment shaped like a manual traveler correction
    /// (quarter-hour multiple within ±14h); any other beyond-tolerance disagreement — in
    /// EITHER direction, forward fiddling inflates — is `.clockRolledBack`.
    /// `lastKnownGood` is the consumer's last trusted clock reading (persisted outside
    /// the engine); it activates the reboot-crossing checks and is ignored within a boot.
    public static func sanityCheck(
        anchor: MonotonicAnchor,
        now: Date,
        monotonic: MonotonicNow,
        tolerance: TimeInterval = defaultClockTolerance,
        lastKnownGood: MonotonicAnchor? = nil
    ) -> ClockSanity {
        evaluate(
            anchor: anchor, now: now, monotonic: monotonic,
            tolerance: tolerance, lastKnownGood: lastKnownGood
        ).sanity
    }

    /// The freeze-not-inflate elapsed value: within a boot the monotonic uptime
    /// delta is ground truth whenever the wall clock disagrees beyond tolerance — a wall
    /// jump in either direction can neither inflate nor reset the streak. Across a reboot
    /// (bootID mismatch) uptimes are incomparable, so it falls back to the wall clock,
    /// floored at zero (a wall reading before the anchor is a definite rollback).
    /// NOTE for consumers: `uptime` readings must come from a clock that keeps counting
    /// across device sleep (mach_continuous_time / CLOCK_BOOTTIME derived), or sleep time
    /// would read as a forward wall jump.
    public static func conservativeElapsedSeconds(
        anchor: MonotonicAnchor,
        now: Date,
        monotonic: MonotonicNow,
        tolerance: TimeInterval = defaultClockTolerance,
        lastKnownGood: MonotonicAnchor? = nil
    ) -> Int {
        evaluate(
            anchor: anchor, now: now, monotonic: monotonic,
            tolerance: tolerance, lastKnownGood: lastKnownGood
        ).elapsedSeconds
    }

    /// Single shared branch set for verdict + conservative value (one arm inventory under
    /// the 100%-branch bar; the two public faces above stay straight-line).
    private static func evaluate(
        anchor: MonotonicAnchor,
        now: Date,
        monotonic: MonotonicNow,
        tolerance: TimeInterval,
        lastKnownGood: MonotonicAnchor? = nil
    ) -> (sanity: ClockSanity, elapsedSeconds: Int) {
        let wallDelta = now.timeIntervalSince(anchor.wallClock)

        guard monotonic.bootID == anchor.bootID else {
            // Across a reboot the wall delta is trusted UNCAPPED on the high side: the
            // principled cap ADR-7 names needs a persisted last-known-good wall reading,
            // which arrives with the Epic 2 repository (deferral recorded in the Session 03
            // log and carried in resume-prompt.md).
            if wallDelta < -tolerance { return (.clockRolledBack, 0) }
            return (.normal, max(0, Int(wallDelta)))
        }

        let monoDelta = max(0, monotonic.uptime - anchor.uptime)
        let disagreement = wallDelta - monoDelta
        if abs(disagreement) <= tolerance {
            return (.normal, max(0, Int(wallDelta)))
        }

        let magnitude = abs(disagreement)
        let remainder = magnitude.truncatingRemainder(dividingBy: 900)
        let timezoneShaped = magnitude <= 14 * 3_600 + tolerance
            && (remainder <= tolerance || 900 - remainder <= tolerance)
        return (timezoneShaped ? .timezoneShift : .clockRolledBack, Int(monoDelta))
    }

    /// The headline readout, fully derived from the snapshot and an injected `now`.
    /// Money and momentum use CUMULATIVE clean time (`priorCleanSeconds` + current
    /// elapsed), which equals the current streak for a never-slipped goal and stays
    /// correct once `applySlip` populates the prior bank. When both an anchor and a
    /// monotonic reading are present, elapsed time and the verdict come from the
    /// clock-integrity guard (freeze-not-inflate); otherwise the pure wall-clock path runs.
    public static func currentStreak(
        for snapshot: StreakSnapshot,
        now: Date,
        monotonic: MonotonicNow? = nil,
        milestones: MilestoneTable? = nil,
        lastKnownGood: MonotonicAnchor? = nil
    ) -> StreakValue {
        let sanity: ClockSanity
        let elapsed: Int
        if let anchor = snapshot.monotonicAnchor, let reading = monotonic {
            (sanity, elapsed) = evaluate(
                anchor: anchor, now: now, monotonic: reading,
                tolerance: defaultClockTolerance, lastKnownGood: lastKnownGood
            )
        } else {
            sanity = .normal
            elapsed = max(0, Int(now.timeIntervalSince(snapshot.startAt)))
        }
        let clean = max(0, snapshot.priorCleanSeconds) + elapsed
        // The denominator rides the same guarded timeline as the numerator: the historical
        // span (startAt − trackedSince) is a fixed constant immune to `now`, and the live
        // span IS the guarded elapsed. Deriving tracked from the raw `now` would let a
        // rolled-back clock shrink the denominator and inflate momentum (Session 03 review).
        let tracked = max(0, elapsed + Int(snapshot.startAt.timeIntervalSince(snapshot.trackedSince)))
        return StreakValue(
            elapsedSeconds: elapsed,
            moneySaved: moneySaved(weeklySpend: snapshot.weeklySpend, cleanSeconds: clean),
            momentum: momentum(cleanSeconds: clean, totalSeconds: tracked),
            nextMilestone: milestones.flatMap { nextMilestone(elapsedSeconds: elapsed, in: $0) },
            clockSanity: sanity
        )
    }
}
