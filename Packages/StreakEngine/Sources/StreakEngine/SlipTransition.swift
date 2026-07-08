import Foundation

// E1.3 — slip archiving, momentum preservation, 10-minute undo. Pure value-in/value-out
// transitions over `StreakSnapshot`; time is always injected (`at:` + optional monotonic
// evidence), never read. Separate file from StreakCalculator.swift so each computation
// file carries its own 100%-branch bar.
extension StreakCalculator {

    /// The undo window (implementation-plan E1.3 / MVP feature #6): a slip is reversible
    /// for exactly this many seconds after it is applied, boundary-inclusive.
    public static let undoWindowSeconds = 600

    /// Archives the current streak into `bestStreakSeconds`, banks its clean time into
    /// `priorCleanSeconds` (cumulative totals are preserved — the momentum numerator and
    /// denominator both carry across the slip unchanged in the same tick), restarts the
    /// counter at `now`, and records the undo bookkeeping.
    public static func applySlip(
        to snapshot: StreakSnapshot,
        at now: Date,
        monotonic: MonotonicNow? = nil
    ) -> StreakSnapshot {
        let ended = guardedElapsedSeconds(of: snapshot, at: now, monotonic: monotonic)
        // The slip instant on the goal's OWN guarded timeline: under a rolled-back wall
        // clock the raw `now` is a lie — stamping it into startAt would shrink the
        // momentum denominator's historical span (startAt − trackedSince) and inflate
        // momentum for the life of the new streak (Session 04 review finding; same class
        // as Session 03's denominator fix). Old start + guarded elapsed is honest in
        // every branch, and never moves the start backward.
        let slipInstant = snapshot.startAt + TimeInterval(ended)
        var next = snapshot
        next.startAt = slipInstant
        // Banked history heals to zero on the way in: a malformed negative bank must not
        // survive an archive (the detector below still holds — max(0, x) + ended >= x).
        next.priorCleanSeconds = max(0, snapshot.priorCleanSeconds) + ended
        next.bestStreakSeconds = max(snapshot.bestStreakSeconds, ended)
        // Re-anchor the NEW streak from the reading — wallClock rides the guarded instant
        // (the documented anchor.wallClock == startAt expectation). With no reading there
        // is no honest anchor: the stale one would measure from the old start.
        next.monotonicAnchor = monotonic.map {
            MonotonicAnchor(bootID: $0.bootID, uptime: $0.uptime, wallClock: slipInstant)
        }
        // A newer slip replaces (finalizes) any still-open undo: one reversible slip at a
        // time (architecture §9 rule 3), so only the overwritten values are recorded.
        next.pendingUndo = PendingSlipUndo(
            priorStartAt: snapshot.startAt,
            priorCleanSeconds: snapshot.priorCleanSeconds,
            priorBestStreakSeconds: snapshot.bestStreakSeconds,
            priorMonotonicAnchor: snapshot.monotonicAnchor
        )
        assert(Self.appendOnlyViolations(from: snapshot, to: next).isEmpty)
        return next
    }

    /// Restores the exact pre-slip state while the undo window is open; `nil` once it has
    /// closed (or when there is no slip pending). The window measures injected time only.
    public static func undoSlip(
        on snapshot: StreakSnapshot,
        at now: Date,
        monotonic: MonotonicNow? = nil
    ) -> StreakSnapshot? {
        guard let undo = snapshot.pendingUndo else { return nil }
        // `startAt`/`monotonicAnchor` were re-set at the slip instant, so elapsed-since-
        // slip IS the goal's own guarded elapsed: clock fiddling can neither stretch nor
        // burn the window when evidence is present. Without evidence a rollback reads as
        // zero (window stays open) — freeze-not-inflate favors the user's streak.
        guard guardedElapsedSeconds(of: snapshot, at: now, monotonic: monotonic) <= undoWindowSeconds else {
            return nil
        }
        // Debug tripwire: the bookkeeping can only record values a slip later raised.
        assert(undo.priorBestStreakSeconds <= snapshot.bestStreakSeconds)
        assert(undo.priorCleanSeconds <= snapshot.priorCleanSeconds)
        return StreakSnapshot(
            startAt: undo.priorStartAt,
            trackedSince: snapshot.trackedSince,
            weeklySpend: snapshot.weeklySpend,
            priorCleanSeconds: undo.priorCleanSeconds,
            monotonicAnchor: undo.priorMonotonicAnchor,
            bestStreakSeconds: undo.priorBestStreakSeconds,
            pendingUndo: nil // consumed; any older slip's undo was already finalized
        )
    }

    /// Pure detector behind the append-only debug assertion (test-suite §1.1 item 7:
    /// "any code path that would decrease them asserts in debug"): names every invariant
    /// a slip transition would violate. `applySlip` asserts it returns empty; `undoSlip`
    /// is the sanctioned exemption (§9 rule 3) and never runs it.
    static func appendOnlyViolations(from old: StreakSnapshot, to new: StreakSnapshot) -> [String] {
        var violations: [String] = []
        if new.bestStreakSeconds < old.bestStreakSeconds {
            violations.append("bestStreakSeconds decreased \(old.bestStreakSeconds) → \(new.bestStreakSeconds)")
        }
        if new.priorCleanSeconds < old.priorCleanSeconds {
            violations.append("priorCleanSeconds decreased \(old.priorCleanSeconds) → \(new.priorCleanSeconds)")
        }
        if new.trackedSince != old.trackedSince {
            violations.append("trackedSince moved \(old.trackedSince) → \(new.trackedSince)")
        }
        return violations
    }

    /// One elapsed-seconds rule for both transitions: the E1.2 guard whenever an anchor
    /// and a reading are both present, the zero-floored wall clock otherwise — the same
    /// timeline `currentStreak` displays, so archives and windows can never disagree
    /// with what the user sees.
    private static func guardedElapsedSeconds(
        of snapshot: StreakSnapshot,
        at now: Date,
        monotonic: MonotonicNow?
    ) -> Int {
        if let anchor = snapshot.monotonicAnchor, let reading = monotonic {
            return conservativeElapsedSeconds(anchor: anchor, now: now, monotonic: reading)
        }
        return max(0, Int(now.timeIntervalSince(snapshot.startAt)))
    }
}
