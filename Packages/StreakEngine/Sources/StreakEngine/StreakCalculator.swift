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
    /// (bootID mismatch) uptimes are incomparable, so the wall clock is the only witness;
    /// supplying `lastKnownGood` (the consumer's persisted last trusted reading) bounds
    /// it: the span up to the reading is verified, a reading from the current boot
    /// bridges monotonic verification across the reboot, and the unverifiable remainder
    /// is credited only up to `defaultRebootGapCap` — beyond it (or on a rollback below
    /// the reading) the value freezes at what the reading proves, flagged. Without a
    /// reading the fallback is the wall clock floored at zero, unchanged.
    /// NOTE for consumers: `uptime` readings must come from a clock that keeps counting
    /// across device sleep (mach_continuous_time / CLOCK_BOOTTIME derived), or sleep time
    /// would read as a forward wall jump. Refresh `lastKnownGood` ONLY from reads whose
    /// verdict is `.normal` — persisting a disputed wall poisons the baseline.
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
    /// the 100%-branch bar; the two public faces above stay straight-line). `healable`
    /// tags the ONE arm the E2.3 healing re-anchor may act on — the across-reboot
    /// over-cap freeze — so `healFrozenStreak` never re-derives arm logic.
    private static func evaluate(
        anchor: MonotonicAnchor,
        now: Date,
        monotonic: MonotonicNow,
        tolerance: TimeInterval,
        lastKnownGood: MonotonicAnchor? = nil
    ) -> (sanity: ClockSanity, elapsedSeconds: Int, healable: Bool) {
        let wallDelta = now.timeIntervalSince(anchor.wallClock)

        guard monotonic.bootID == anchor.bootID else {
            guard let lkg = lastKnownGood else {
                // No trusted reading: the uncapped wall fallback, unchanged — the cap
                // is opt-in via `lastKnownGood` (pinned by test).
                if wallDelta < -tolerance { return (.clockRolledBack, 0, false) }
                return (.normal, max(0, Int(wallDelta)), false)
            }

            // BRIDGE: the trusted reading shares the CURRENT boot and postdates this
            // anchor, so the reading→now segment re-enters the within-boot guard and
            // INHERITS its verdict — never a hardcoded .normal: consumers refresh the
            // reading only on .normal verdicts, and this is the other half of what
            // keeps a forward-set wall from ever poisoning the baseline.
            if lkg.bootID == monotonic.bootID && lkg.wallClock >= anchor.wallClock {
                let bridged = evaluate(
                    anchor: lkg, now: now, monotonic: monotonic, tolerance: tolerance
                )
                let verifiedPrefix = Int(lkg.wallClock.timeIntervalSince(anchor.wallClock))
                return (bridged.sanity, verifiedPrefix + bridged.elapsedSeconds, false)
            }

            // Capped arm: no monotonic continuity to `now`. The baseline floors at the
            // anchor (a reading that predates this streak proves nothing about it); the
            // gap since the baseline is unverifiable and credited only up to the cap.
            let baseline = max(anchor.wallClock, lkg.wallClock)
            let verified = Int(baseline.timeIntervalSince(anchor.wallClock))
            let gap = now.timeIntervalSince(baseline)
            if gap < -tolerance {
                // Rollback below the trusted reading: freeze at the verified span —
                // not zero; the reading proves at least this much elapsed. Recovers on
                // its own once the wall catches back up, so it is not healable.
                return (.clockRolledBack, verified, false)
            }
            if gap > defaultRebootGapCap {
                // Reboot + huge forward jump: withhold the unverifiable excess, flag.
                // The ONE healable state — frozen forever without a corrective write.
                return (.clockRolledBack, verified + Int(defaultRebootGapCap), true)
            }
            return (.normal, verified + max(0, Int(gap)), false)
        }

        let monoDelta = max(0, monotonic.uptime - anchor.uptime)
        let disagreement = wallDelta - monoDelta
        if abs(disagreement) <= tolerance {
            return (.normal, max(0, Int(wallDelta)), false)
        }

        let magnitude = abs(disagreement)
        let remainder = magnitude.truncatingRemainder(dividingBy: 900)
        let timezoneShaped = magnitude <= 14 * 3_600 + tolerance
            && (remainder <= tolerance || 900 - remainder <= tolerance)
        return (timezoneShaped ? .timezoneShift : .clockRolledBack, Int(monoDelta), false)
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
            (sanity, elapsed, _) = evaluate(
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

    /// The healing re-anchor for a streak frozen by the reboot sanity cap
    /// (freeze-then-resume). When a device returns from a long power-off, the
    /// unverifiable wall gap beyond `defaultRebootGapCap` is withheld and every read
    /// stays frozen and flagged; this transition — meant for a consumer's deliberate,
    /// launch-time recompute pass, never a read — re-bases the streak so counting
    /// RESUMES from the frozen value on the current boot session.
    ///
    /// Heals exactly one state: an across-reboot reading whose gap since the trusted
    /// baseline exceeds `defaultRebootGapCap`. Every other verdict returns `nil`:
    /// within-boot disagreements are monotonic ground truth, timezone shapes are
    /// display concerns, a same-boot trusted capture bridges with uptime proof, an
    /// in-window reboot gap is already fully credited, a rollback below the verified
    /// span recovers once the wall catches up, and without a trusted reading there is
    /// nothing verified to resume from.
    ///
    /// The healed snapshot moves ONLY `startAt` (to `now − frozen`) and
    /// `monotonicAnchor` (to the current boot, back-dated so the guard reads exactly
    /// `frozen` at `now`, with `wallClock == startAt` preserved). The tracking origin
    /// (`trackedSince`), banked history (`priorCleanSeconds`, `bestStreakSeconds`),
    /// spend, and undo bookkeeping pass through untouched — so post-heal momentum is
    /// conservative: the withheld gap remains tracked time that was never credited
    /// as clean.
    public static func healFrozenStreak(
        on snapshot: StreakSnapshot,
        at now: Date,
        monotonic: MonotonicNow? = nil,
        lastKnownGood: MonotonicAnchor? = nil
    ) -> StreakSnapshot? {
        guard let anchor = snapshot.monotonicAnchor, let reading = monotonic else {
            return nil
        }
        let verdict = evaluate(
            anchor: anchor, now: now, monotonic: reading,
            tolerance: defaultClockTolerance, lastKnownGood: lastKnownGood
        )
        guard verdict.healable else { return nil }

        let frozen = verdict.elapsedSeconds
        var healed = snapshot
        // Re-base onto the current boot so counting resumes: the guard measures
        // elapsed from the anchor, so a back-dated (bootID, uptime − frozen,
        // now − frozen) anchor reads exactly `frozen` at `now` and ticks 1:1 with
        // real time from here. startAt rides along (anchor.wallClock == startAt),
        // which keeps the NEXT applySlip's slip instant on the real wall.
        healed.startAt = now - TimeInterval(frozen)
        healed.monotonicAnchor = MonotonicAnchor(
            bootID: reading.bootID,
            uptime: reading.uptime - TimeInterval(frozen),
            wallClock: healed.startAt
        )
        // Tripwire: the minted anchor must read (.normal, frozen) at the heal instant.
        let minted = evaluate(
            anchor: healed.monotonicAnchor!, now: now, monotonic: reading,
            tolerance: defaultClockTolerance
        )
        assert(minted.sanity == .normal && minted.elapsedSeconds == frozen)
        return healed
    }
}
