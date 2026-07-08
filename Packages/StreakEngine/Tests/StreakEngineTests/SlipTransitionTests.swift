import Foundation
import Testing
@testable import StreakEngine

// Fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z.
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)
private let day = 86_400
private let hour = 3_600

private let bootA = UUID(uuidString: "0B00071D-A000-4000-8000-000000000001")!

/// Anchor captured at the fixture streak's start: uptime 50 000 s into boot A.
private let anchor = MonotonicAnchor(bootID: bootA, uptime: 50_000, wallClock: epoch)

/// Monotonic evidence after `truth` seconds of real time within boot A.
private func monoAfter(_ truth: Int) -> MonotonicNow {
    MonotonicNow(bootID: bootA, uptime: 50_000 + TimeInterval(truth))
}

/// Test-suite §1.1 fixture 4's shape: a 34-day current streak on top of banked history —
/// 10 clean days archived out of 12 tracked before this streak began (a 2-day gap, so
/// momentum is genuinely partial and any accidental reset to 0% or 100% is visible).
private let jakeDay34 = QuitSnapshot(
    startAt: epoch,
    trackedSince: epoch - TimeInterval(12 * day),
    weeklySpend: Decimal(string: "26")!,
    priorCleanSeconds: 10 * day,
    monotonicAnchor: anchor,
    bestStreakSeconds: 10 * day
)

// MARK: - E1.3 named tests (implementation-plan E1.3 — the six, verbatim)

@Suite("E1.3 slip archiving and 10-minute undo")
struct SlipTransitionTests {

    @Test("a slip archives the current streak into best when it exceeds the old best")
    func test_slip_archivesToBest_whenCurrentExceedsBest() {
        let slipAt = epoch + TimeInterval(34 * day)
        let after = StreakCalculator.applySlip(to: jakeDay34, at: slipAt, monotonic: monoAfter(34 * day))

        #expect(after.bestStreakSeconds == 34 * day)   // 34d current beats the 10d best
        #expect(after.startAt == slipAt)               // the counter restarts at the slip
        let restarted = StreakCalculator.currentStreak(for: after, now: slipAt, monotonic: monoAfter(34 * day))
        #expect(restarted.elapsedSeconds == 0)
        #expect(after.pendingUndo != nil)              // reversible for the next 10 minutes
    }

    @Test("a slip banks the ended streak — cumulative clean seconds are preserved, not reset")
    func test_slip_preservesTotalCleanSeconds() {
        let slipAt = epoch + TimeInterval(34 * day)
        let totalCleanBefore = jakeDay34.priorCleanSeconds + 34 * day // 44 clean days

        let after = StreakCalculator.applySlip(to: jakeDay34, at: slipAt, monotonic: monoAfter(34 * day))

        #expect(after.priorCleanSeconds == totalCleanBefore) // banked, current restarts at 0
        #expect(after.trackedSince == jakeDay34.trackedSince)
        // The user-visible face of the same total: money saved is identical in the same tick.
        let moneyBefore = StreakCalculator.currentStreak(for: jakeDay34, now: slipAt, monotonic: monoAfter(34 * day)).moneySaved
        let moneyAfter = StreakCalculator.currentStreak(for: after, now: slipAt, monotonic: monoAfter(34 * day)).moneySaved
        #expect(moneyAfter == moneyBefore)
    }

    @Test("momentum survives a slip with partial credit — unchanged in the same tick, never reset")
    func test_momentum_survivesSlip_partialCredit() {
        // 44 clean days over 46 tracked days at the slip tick: momentum 44/46 ≈ 95.7%.
        let slipAt = epoch + TimeInterval(34 * day)
        let before = StreakCalculator.currentStreak(for: jakeDay34, now: slipAt, monotonic: monoAfter(34 * day))
        #expect(before.momentum == Double(44 * day) / Double(46 * day))

        let after = StreakCalculator.applySlip(to: jakeDay34, at: slipAt, monotonic: monoAfter(34 * day))
        let atTick = StreakCalculator.currentStreak(for: after, now: slipAt, monotonic: monoAfter(34 * day))
        #expect(atTick.momentum == before.momentum)    // the forgiveness differentiator
        #expect(atTick.momentum > 0.0 && atTick.momentum < 1.0) // partial credit, not a reset

        // Ten clean days later momentum has recovered ground: 54/56 tracked-clean days.
        let later = StreakCalculator.currentStreak(
            for: after,
            now: slipAt + TimeInterval(10 * day),
            monotonic: monoAfter(44 * day)
        )
        #expect(later.momentum == Double(54 * day) / Double(56 * day))
    }

    @Test(
        "undo within ten minutes restores the exact prior state, boundary-inclusive",
        arguments: [60, 600] // one minute in; the final second of the window
    )
    func test_undo_within10Minutes_restoresExactPriorState(elapsed: Int) {
        let slipAt = epoch + TimeInterval(34 * day)
        let after = StreakCalculator.applySlip(to: jakeDay34, at: slipAt, monotonic: monoAfter(34 * day))

        let restored = StreakCalculator.undoSlip(
            on: after,
            at: slipAt + TimeInterval(elapsed),
            monotonic: monoAfter(34 * day + elapsed)
        )
        #expect(restored == jakeDay34) // EXACT: every field, whole-struct equality
    }

    @Test("undo at ten minutes plus one second returns nil — the slip is final")
    func test_undo_at10MinutesPlus1Second_returnsNil() {
        let slipAt = epoch + TimeInterval(34 * day)
        let after = StreakCalculator.applySlip(to: jakeDay34, at: slipAt, monotonic: monoAfter(34 * day))

        let expired = StreakCalculator.undoSlip(
            on: after,
            at: slipAt + TimeInterval(601),
            monotonic: monoAfter(34 * day + 601)
        )
        #expect(expired == nil)
    }

    @Test("best streak and banked clean time never decrease across any slip sequence")
    func test_bestStreak_neverDecreases_afterAnySlipSequence() {
        var rng = SplitMix64(seed: 0x5EED_0E13_2026_0708) // pinned; add failing seeds per test-suite §6.1.5
        var quit = QuitSnapshot(startAt: epoch, weeklySpend: Decimal(string: "26")!)
        var now = epoch

        for step in 0..<200 {
            now += TimeInterval(rng.draw(upTo: 2 * day))
            let elapsed = max(0, Int(now.timeIntervalSince(quit.startAt)))
            let derivedCleanBefore = quit.priorCleanSeconds + elapsed

            guard rng.draw(upTo: 2) == 0 else { continue } // ~1/3 of steps slip

            let before = quit
            quit = StreakCalculator.applySlip(to: quit, at: now)

            #expect(quit.bestStreakSeconds >= before.bestStreakSeconds, "step \(step): best decreased")
            #expect(quit.bestStreakSeconds == max(before.bestStreakSeconds, elapsed), "step \(step): best missed the archive")
            #expect(quit.priorCleanSeconds >= before.priorCleanSeconds, "step \(step): banked clean decreased")
            #expect(quit.priorCleanSeconds == derivedCleanBefore, "step \(step): cumulative clean not preserved")
            #expect(StreakCalculator.appendOnlyViolations(from: before, to: quit).isEmpty, "step \(step)")
        }
    }
}

// MARK: - E1.3 transition branches and boundaries

@Suite("E1.3 slip and undo boundaries")
struct SlipTransitionEdgeTests {

    @Test("a slip shorter than the best leaves best untouched but still banks the clean time")
    func test_slip_currentBelowBest_keepsBest_banksClean() {
        let slipAt = epoch + TimeInterval(5 * day)
        let after = StreakCalculator.applySlip(to: jakeDay34, at: slipAt, monotonic: monoAfter(5 * day))
        #expect(after.bestStreakSeconds == 10 * day)          // 5d does not beat 10d
        #expect(after.priorCleanSeconds == 15 * day)          // ...but the 5d are not lost
        #expect(after.weeklySpend == jakeDay34.weeklySpend)   // untouched fields carry over
        #expect(after.trackedSince == jakeDay34.trackedSince)
    }

    @Test("a slip under a rolled-back wall clock archives the guarded monotonic truth, not the lie")
    func test_slip_underClockRollback_banksMonotonicTruth() {
        // 34 days of monotonic truth; the wall clock has been dragged back to day 4.
        let wallNow = epoch + TimeInterval(4 * day)
        let after = StreakCalculator.applySlip(to: jakeDay34, at: wallNow, monotonic: monoAfter(34 * day))
        #expect(after.bestStreakSeconds == 34 * day)
        #expect(after.priorCleanSeconds == 44 * day)
    }

    @Test("momentum is unchanged across a slip even under a rolled-back wall clock — the new start rides the guarded timeline")
    func test_momentum_unchangedAcrossSlip_underClockRollback() {
        // Review finding (Session 04): applySlip stamped startAt with the raw wall `now`
        // while banking the GUARDED elapsed — a rollback at slip time collapsed the
        // denominator's historical span (startAt − trackedSince) and pinned momentum at
        // 100% forever: the Session 03 inflation class, reintroduced at the slip boundary.
        let wallNow = epoch + TimeInterval(4 * day) // dragged back; monotonic truth is 34d
        let before = StreakCalculator.currentStreak(for: jakeDay34, now: wallNow, monotonic: monoAfter(34 * day))
        #expect(before.momentum == Double(44 * day) / Double(46 * day))

        let after = StreakCalculator.applySlip(to: jakeDay34, at: wallNow, monotonic: monoAfter(34 * day))
        // The new streak starts at the HONEST slip instant (old start + guarded elapsed),
        // not the lied wall reading — and the anchor rides the same timeline, keeping the
        // documented anchor.wallClock == startAt expectation.
        #expect(after.startAt == epoch + TimeInterval(34 * day))
        #expect(after.monotonicAnchor?.wallClock == after.startAt)

        let atTick = StreakCalculator.currentStreak(for: after, now: wallNow, monotonic: monoAfter(34 * day))
        #expect(atTick.momentum == before.momentum) // 44/46, not a clamped 1.0

        // Six honest days after the user fixes the clock: 50 clean of 52 tracked days —
        // the denominator was never corrupted, so the readout heals with the clock.
        let corrected = StreakCalculator.currentStreak(
            for: after, now: epoch + TimeInterval(40 * day), monotonic: monoAfter(40 * day)
        )
        #expect(corrected.clockSanity == .normal)
        #expect(corrected.momentum == Double(50 * day) / Double(52 * day))
    }

    @Test("a slip re-anchors from the reading when present, and clears a stale anchor when not")
    func test_slip_reanchorsFromReading_clearsAnchorWithoutOne() {
        let slipAt = epoch + TimeInterval(34 * day)

        let anchored = StreakCalculator.applySlip(to: jakeDay34, at: slipAt, monotonic: monoAfter(34 * day))
        #expect(anchored.monotonicAnchor == MonotonicAnchor(
            bootID: bootA, uptime: 50_000 + TimeInterval(34 * day), wallClock: slipAt
        ))

        // No reading ⇒ no honest anchor for the NEW streak exists; keeping the old one
        // would make the guard measure the new streak from the old start (inflation).
        let unanchored = StreakCalculator.applySlip(to: jakeDay34, at: slipAt)
        #expect(unanchored.monotonicAnchor == nil)
    }

    @Test("a slip timed before the streak start (no evidence) banks zero, never negative")
    func test_slip_nowBeforeStart_noEvidence_banksZero() {
        let quit = QuitSnapshot(startAt: epoch, weeklySpend: Decimal(string: "26")!, priorCleanSeconds: 3 * day)
        let after = StreakCalculator.applySlip(to: quit, at: epoch - TimeInterval(hour))
        #expect(after.priorCleanSeconds == 3 * day)           // +0, not −3600
        #expect(after.bestStreakSeconds == 0)
        #expect(after.startAt == quit.startAt)                // the start never moves backward
        #expect(after.weeklySpend == quit.weeklySpend)
        #expect(after.trackedSince == quit.trackedSince)
    }

    @Test("undo with no slip pending returns nil")
    func test_undo_withoutPendingSlip_returnsNil() {
        #expect(StreakCalculator.undoSlip(on: jakeDay34, at: epoch + TimeInterval(day)) == nil)
    }

    @Test(
        "without monotonic evidence the undo window is measured on the wall clock, same boundary",
        arguments: [(600, true), (601, false)]
    )
    func test_undo_wallClockWindow_boundaryExact(elapsed: Int, restores: Bool) {
        let noAnchor = QuitSnapshot(
            startAt: epoch,
            trackedSince: epoch - TimeInterval(12 * day),
            weeklySpend: Decimal(string: "26")!,
            priorCleanSeconds: 10 * day,
            bestStreakSeconds: 10 * day
        )
        let slipAt = epoch + TimeInterval(34 * day)
        let after = StreakCalculator.applySlip(to: noAnchor, at: slipAt)

        let restored = StreakCalculator.undoSlip(on: after, at: slipAt + TimeInterval(elapsed))
        #expect((restored != nil) == restores)
        if restores { #expect(restored == noAnchor) }
    }

    @Test("the undo window rides the guarded timeline — clock fiddling can neither stretch nor burn it")
    func test_undo_windowMeasuredByGuardedTime() {
        let slipAt = epoch + TimeInterval(34 * day)
        let after = StreakCalculator.applySlip(to: jakeDay34, at: slipAt, monotonic: monoAfter(34 * day))

        // 11 real minutes passed; the wall clock was dragged back to +1 minute. Expired.
        let stretched = StreakCalculator.undoSlip(
            on: after, at: slipAt + TimeInterval(60), monotonic: monoAfter(34 * day + 660)
        )
        #expect(stretched == nil)

        // 5 real minutes passed; the wall clock was pushed to +15 minutes. Still open.
        let burned = StreakCalculator.undoSlip(
            on: after, at: slipAt + TimeInterval(900), monotonic: monoAfter(34 * day + 300)
        )
        #expect(burned == jakeDay34)
    }

    @Test(
        "a reboot during the undo window falls back to the wall clock, same boundary",
        arguments: [(30, true), (700, false)]
    )
    func test_undo_acrossReboot_fallsBackToWallClock(wallElapsed: Int, restores: Bool) {
        let slipAt = epoch + TimeInterval(34 * day)
        let after = StreakCalculator.applySlip(to: jakeDay34, at: slipAt, monotonic: monoAfter(34 * day))

        // The slip anchor's bootID no longer matches: uptimes are incomparable, so the
        // window is measured on the sanity-floored wall clock (E1.2 reboot semantics).
        let rebooted = MonotonicNow(
            bootID: UUID(uuidString: "0B00071D-B000-4000-8000-000000000002")!, uptime: 40
        )
        let restored = StreakCalculator.undoSlip(
            on: after, at: slipAt + TimeInterval(wallElapsed), monotonic: rebooted
        )
        #expect((restored != nil) == restores)
        if restores { #expect(restored == jakeDay34) }
    }

    @Test("a negative banked history heals to zero on the way into the bank — never compounds")
    func test_slip_negativePriorClean_healsToZeroBeforeBanking() {
        // Representable via the public init (malformed consumer state); the slip banks
        // max(0, prior) + elapsed so corruption cannot survive an archive.
        let corrupt = QuitSnapshot(startAt: epoch, priorCleanSeconds: -3_600)
        let after = StreakCalculator.applySlip(to: corrupt, at: epoch + TimeInterval(2 * hour))
        #expect(after.priorCleanSeconds == 2 * hour)
        #expect(after.bestStreakSeconds == 2 * hour)
    }

    @Test("a wall clock rolled behind the slip without evidence reads as zero elapsed — window open")
    func test_undo_wallBeforeSlip_noEvidence_clampsToOpenWindow() {
        let slipAt = epoch + TimeInterval(34 * day)
        let after = StreakCalculator.applySlip(to: jakeDay34, at: slipAt)
        // Accepted asymmetry: with no monotonic evidence a rollback cannot be told apart
        // from a fast undo; freeze-not-inflate favors letting the user keep their streak.
        let restored = StreakCalculator.undoSlip(on: after, at: slipAt - TimeInterval(hour))
        #expect(restored == jakeDay34)
    }

    @Test("a second slip finalizes the first — undo then restores the state just before the second")
    func test_undo_afterSecondSlip_restoresPreSecondState_firstIsFinal() {
        let firstAt = epoch + TimeInterval(10 * day)
        let afterFirst = StreakCalculator.applySlip(to: jakeDay34, at: firstAt, monotonic: monoAfter(10 * day))
        let secondAt = firstAt + TimeInterval(300)
        let afterSecond = StreakCalculator.applySlip(to: afterFirst, at: secondAt, monotonic: monoAfter(10 * day + 300))

        let restored = StreakCalculator.undoSlip(
            on: afterSecond, at: secondAt + TimeInterval(60), monotonic: monoAfter(10 * day + 360)
        )
        // The first slip's own undo bookkeeping was finalized by the second slip, so the
        // restored state is the pre-second state with no further undo available.
        var preSecondFinalized = afterFirst
        preSecondFinalized.pendingUndo = nil
        #expect(restored == preSecondFinalized)
        #expect(restored.map { StreakCalculator.undoSlip(on: $0, at: secondAt + TimeInterval(120)) } == .some(nil))
    }
}

// MARK: - E1.3 append-only invariant (architecture §8's sync rule — monotonically
// non-decreasing counters — enforced per test-suite §1.1 item 7: "any code path that would
// decrease them asserts in debug". The pure detector IS the asserted path, tested directly
// with violating transitions; undoSlip is the one sanctioned exemption — §9 rule 3.)

@Suite("E1.3 append-only invariant detector")
struct AppendOnlyInvariantTests {

    @Test("a transition that lowers a monotonic field is named as a violation")
    func test_appendOnlyViolations_namesEachLoweredField() {
        var lowered = jakeDay34
        lowered.bestStreakSeconds -= 1
        lowered.priorCleanSeconds -= 1
        let violations = StreakCalculator.appendOnlyViolations(from: jakeDay34, to: lowered)
        #expect(violations.contains { $0.contains("bestStreakSeconds") })
        #expect(violations.contains { $0.contains("priorCleanSeconds") })
    }

    @Test("a transition that moves the tracking epoch is named as a violation")
    func test_appendOnlyViolations_namesMovedTrackedSince() {
        var moved = jakeDay34
        moved.trackedSince += TimeInterval(day)
        let violations = StreakCalculator.appendOnlyViolations(from: jakeDay34, to: moved)
        #expect(violations.contains { $0.contains("trackedSince") })
    }

    @Test("a legitimate slip transition raises no violation — the debug assertion stays quiet")
    func test_appendOnlyViolations_emptyForLegitimateSlip() {
        let after = StreakCalculator.applySlip(
            to: jakeDay34, at: epoch + TimeInterval(34 * day), monotonic: monoAfter(34 * day)
        )
        #expect(StreakCalculator.appendOnlyViolations(from: jakeDay34, to: after).isEmpty)
    }

    @Test("undo is the sanctioned exemption — the detector WOULD flag it, which is why undoSlip never runs it")
    func test_appendOnlyViolations_wouldFlagUndo_theSanctionedExemption() {
        let slipAt = epoch + TimeInterval(34 * day)
        let after = StreakCalculator.applySlip(to: jakeDay34, at: slipAt, monotonic: monoAfter(34 * day))
        let restored = StreakCalculator.undoSlip(
            on: after, at: slipAt + TimeInterval(60), monotonic: monoAfter(34 * day + 60)
        )

        // The restoration legitimately lowers the banked fields (architecture §9 rule 3:
        // undo, not delete-then-restore) — so the applySlip-only assertion scope is
        // load-bearing, not accidental.
        let violations = StreakCalculator.appendOnlyViolations(from: after, to: restored!)
        #expect(violations.contains { $0.contains("bestStreakSeconds") })
        #expect(violations.contains { $0.contains("priorCleanSeconds") })
    }
}

// MARK: - Deterministic generator (same author-owned scheme as the E1.2 property test:
// pinned seed, modulo draws — Int.random's algorithm is not pinned across toolchains)

private struct SplitMix64 {
    var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    /// Uniform-enough draw in 0...bound (modulo bias is immaterial for a fuzz corpus).
    mutating func draw(upTo bound: Int) -> Int {
        Int(next() % UInt64(bound + 1))
    }
}
