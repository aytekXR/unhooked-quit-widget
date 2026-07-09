import Foundation
import Testing
@testable import StreakEngine

// E2.2 — the ADR-7 reboot high-side sanity cap (the gap carried since Session 03).
// A reboot makes uptimes incomparable, so the wall clock was trusted UNCAPPED upward;
// with the consumer's persisted last-known-good reading (`lastKnownGood`) the engine can
// now bound the unverifiable gap. Ratified semantics (Session 06 design panel):
//   - `lastKnownGood == nil` reproduces today's behavior byte-for-byte (opt-in cap).
//   - Same-boot LKG (bridge): the LKG→now segment re-enters the within-boot guard and
//     INHERITS its verdict — never a hardcoded `.normal` (LKG-poison prevention).
//   - Otherwise: verified span = LKG.wallClock − anchor.wallClock (baseline floored at
//     the anchor); the unverifiable gap since the baseline is credited in full up to
//     `defaultRebootGapCap`, frozen + flagged beyond it; a rollback below the baseline
//     freezes at the verified span (not zero) and flags.

// Fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z.
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)
private let day = 86_400
private let hour = 3_600
private let cap = Int(StreakCalculator.defaultRebootGapCap)

private let bootA = UUID(uuidString: "0B00071D-A000-4000-8000-000000000001")!
private let bootB = UUID(uuidString: "0B00071D-B000-4000-8000-000000000002")!

/// Anchor captured at streak start on boot A: uptime 50 000 s, wall clock at the epoch.
private let anchor = MonotonicAnchor(bootID: bootA, uptime: 50_000, wallClock: epoch)
private let quit = StreakSnapshot(startAt: epoch, monotonicAnchor: anchor)

/// A trusted consumer capture on boot A, `verified` seconds after the anchor.
private func lkgOnBootA(after verified: Int) -> MonotonicAnchor {
    MonotonicAnchor(
        bootID: bootA,
        uptime: 50_000 + TimeInterval(verified),
        wallClock: epoch + TimeInterval(verified)
    )
}

@Suite("E2.2 reboot sanity cap")
struct RebootCapTests {

    @Test("reboot + huge forward wall jump must NOT read normal or inflate — frozen at verified + cap")
    func test_rebootForwardJump_beyondCap_freezesAtVerifiedPlusCap() {
        let lkg = lkgOnBootA(after: 5 * day)          // last honest sighting: day 5
        let mono = MonotonicNow(bootID: bootB, uptime: 5_000)
        let now = epoch + TimeInterval(1_000 * day)   // wall claims day 1000

        #expect(
            StreakCalculator.sanityCheck(
                anchor: anchor, now: now, monotonic: mono, lastKnownGood: lkg
            ) == .clockRolledBack
        )
        #expect(
            StreakCalculator.conservativeElapsedSeconds(
                anchor: anchor, now: now, monotonic: mono, lastKnownGood: lkg
            ) == 5 * day + cap
        )

        let value = StreakCalculator.currentStreak(
            for: quit, now: now, monotonic: mono, lastKnownGood: lkg
        )
        #expect(value.clockSanity == .clockRolledBack)
        #expect(value.elapsedSeconds == 5 * day + cap)
    }

    @Test(
        "the unverifiable gap is credited exactly to the cap and frozen one second beyond",
        arguments: [
            // (gap seconds since the LKG, expected verdict, expected elapsed)
            (3 * 86_400, ClockSanity.normal, 8 * 86_400),                      // honest reboot: full credit
            (Int(StreakCalculator.defaultRebootGapCap), ClockSanity.normal,
             5 * 86_400 + Int(StreakCalculator.defaultRebootGapCap)),          // exactly AT the cap: full credit
            (Int(StreakCalculator.defaultRebootGapCap) + 1, ClockSanity.clockRolledBack,
             5 * 86_400 + Int(StreakCalculator.defaultRebootGapCap)),          // one second beyond: frozen
        ]
    )
    func test_rebootGapCapBoundary_isExact(gap: Int, verdict: ClockSanity, elapsed: Int) {
        let lkg = lkgOnBootA(after: 5 * day)
        let mono = MonotonicNow(bootID: bootB, uptime: 5_000)
        let now = lkg.wallClock + TimeInterval(gap)

        #expect(StreakCalculator.sanityCheck(anchor: anchor, now: now, monotonic: mono, lastKnownGood: lkg) == verdict)
        #expect(StreakCalculator.conservativeElapsedSeconds(anchor: anchor, now: now, monotonic: mono, lastKnownGood: lkg) == elapsed)
    }

    @Test(
        "a wall reading behind the last trusted reading freezes at the verified span, not zero",
        arguments: [
            // (gap seconds since the LKG, expected verdict) — elapsed always the verified 5d
            (-60, ClockSanity.normal),            // within tolerance: noise, no credit beyond verified
            (-61, ClockSanity.clockRolledBack),   // one second beyond: flagged rollback
            (-2 * 3_600, ClockSanity.clockRolledBack),  // clear rollback since the LKG
            (-6 * 86_400, ClockSanity.clockRolledBack), // LKG.wallClock in now's future (pre-anchor wall)
        ]
    )
    func test_rebootRollbackSinceLastKnownGood_freezesAtVerifiedSpan(gap: Int, verdict: ClockSanity) {
        let lkg = lkgOnBootA(after: 5 * day)
        let mono = MonotonicNow(bootID: bootB, uptime: 5_000)
        let now = lkg.wallClock + TimeInterval(gap)

        #expect(StreakCalculator.sanityCheck(anchor: anchor, now: now, monotonic: mono, lastKnownGood: lkg) == verdict)
        #expect(StreakCalculator.conservativeElapsedSeconds(anchor: anchor, now: now, monotonic: mono, lastKnownGood: lkg) == 5 * day)
    }

    @Test("a same-boot trusted capture bridges the reboot: the remainder is uptime-verified and uncapped")
    func test_rebootBridge_sameBootCapture_verifiesRemainderViaUptime() {
        // Captured 5d in on boot B, 1 000 s after that boot. 20 days of honest uptime
        // later (a gap the cap would have frozen) the bridge credits it in full: the
        // remainder is monotonic ground truth, not an unverifiable wall claim.
        let lkgB = MonotonicAnchor(bootID: bootB, uptime: 1_000, wallClock: epoch + TimeInterval(5 * day))
        let mono = MonotonicNow(bootID: bootB, uptime: 1_000 + TimeInterval(20 * day))
        let now = epoch + TimeInterval(25 * day)

        #expect(StreakCalculator.sanityCheck(anchor: anchor, now: now, monotonic: mono, lastKnownGood: lkgB) == .normal)
        #expect(StreakCalculator.conservativeElapsedSeconds(anchor: anchor, now: now, monotonic: mono, lastKnownGood: lkgB) == 25 * day)
    }

    @Test(
        "wall fiddling after the bridge capture inherits the within-boot verdict — never normal, never credited",
        arguments: [
            // (wall offset from the honest epoch+7d instant, expected verdict)
            (28 * 86_400, ClockSanity.clockRolledBack),      // forward-set beyond the bridge's uptime
            (-(2 * 86_400 + 3_600), ClockSanity.clockRolledBack), // rolled back behind the capture
            (-3 * 3_600, ClockSanity.timezoneShift),         // a −3h traveler-shaped set
        ]
    )
    func test_rebootBridge_wallFiddleSinceCapture_inheritsWithinBootVerdict(offset: Int, verdict: ClockSanity) {
        let lkgB = MonotonicAnchor(bootID: bootB, uptime: 1_000, wallClock: epoch + TimeInterval(5 * day))
        let mono = MonotonicNow(bootID: bootB, uptime: 1_000 + TimeInterval(2 * day)) // truth: 2d since capture
        let now = epoch + TimeInterval(7 * day + offset)

        #expect(StreakCalculator.sanityCheck(anchor: anchor, now: now, monotonic: mono, lastKnownGood: lkgB) == verdict)
        // The remainder freezes at the uptime truth in every fiddle case: 5d verified + 2d.
        #expect(StreakCalculator.conservativeElapsedSeconds(anchor: anchor, now: now, monotonic: mono, lastKnownGood: lkgB) == 7 * day)
    }

    @Test("a same-boot capture at exactly the anchor's wall instant still bridges (the gate is inclusive)")
    func test_rebootBridge_captureAtAnchorInstant_bridges() {
        // Boundary pin (review): the bridge gate is `>=`. A `>` mutant — or a cap
        // applied to the bridge — would freeze this 20-day uptime-verified remainder
        // at the 14-day cap instead of crediting it in full.
        let lkgB = MonotonicAnchor(bootID: bootB, uptime: 1_000, wallClock: epoch)
        let mono = MonotonicNow(bootID: bootB, uptime: 1_000 + TimeInterval(20 * day))
        let now = epoch + TimeInterval(20 * day)

        #expect(StreakCalculator.sanityCheck(anchor: anchor, now: now, monotonic: mono, lastKnownGood: lkgB) == .normal)
        #expect(StreakCalculator.conservativeElapsedSeconds(anchor: anchor, now: now, monotonic: mono, lastKnownGood: lkgB) == 20 * day)
    }

    @Test("a trusted reading older than this streak's anchor cannot bridge — the cap measures from the anchor")
    func test_staleLastKnownGood_predatingAnchor_capsFromAnchor() {
        // Post-slip re-anchor at day 10; the LKG still holds the day-5 capture. The stale
        // reading proves nothing about THIS streak, so the baseline floors at the anchor.
        let reAnchor = MonotonicAnchor(bootID: bootA, uptime: 60_000, wallClock: epoch + TimeInterval(10 * day))
        let staleLkg = lkgOnBootA(after: 5 * day)
        let mono = MonotonicNow(bootID: bootB, uptime: 5_000)
        let now = epoch + TimeInterval(10 * day + 20 * day) // 20d gap from the anchor > cap

        #expect(StreakCalculator.sanityCheck(anchor: reAnchor, now: now, monotonic: mono, lastKnownGood: staleLkg) == .clockRolledBack)
        #expect(StreakCalculator.conservativeElapsedSeconds(anchor: reAnchor, now: now, monotonic: mono, lastKnownGood: staleLkg) == cap)
    }

    @Test("a same-boot-as-reading capture older than the anchor cannot bridge either")
    func test_staleSameBootCapture_predatingAnchor_fallsToCappedArm() {
        // Corrupt-adjacent combination: the capture shares the reading's boot but claims a
        // wall BEFORE this streak's anchor. The bridge gate refuses it; the capped arm
        // measures from the anchor.
        let staleLkgB = MonotonicAnchor(bootID: bootB, uptime: 100, wallClock: epoch - TimeInterval(day))
        let mono = MonotonicNow(bootID: bootB, uptime: 5_000)
        let now = epoch + TimeInterval(20 * day)

        #expect(StreakCalculator.sanityCheck(anchor: anchor, now: now, monotonic: mono, lastKnownGood: staleLkgB) == .clockRolledBack)
        #expect(StreakCalculator.conservativeElapsedSeconds(anchor: anchor, now: now, monotonic: mono, lastKnownGood: staleLkgB) == cap)
    }

    @Test(
        "without a last-known-good reading the reboot path reproduces the uncapped wall behavior exactly",
        arguments: [
            // The existing E1.2 pins, driven explicitly through the new parameter's nil path.
            (10 * 86_400, ClockSanity.normal, 10 * 86_400),
            (-3_600, ClockSanity.clockRolledBack, 0),
        ]
    )
    func test_reboot_missingLastKnownGood_reproducesUncappedWallBehavior(
        wallElapsed: Int, verdict: ClockSanity, elapsed: Int
    ) {
        let now = epoch + TimeInterval(wallElapsed)
        let mono = MonotonicNow(bootID: bootB, uptime: 5_000)

        #expect(StreakCalculator.sanityCheck(anchor: anchor, now: now, monotonic: mono, lastKnownGood: nil) == verdict)
        #expect(StreakCalculator.conservativeElapsedSeconds(anchor: anchor, now: now, monotonic: mono, lastKnownGood: nil) == elapsed)
    }
}

// MARK: - Property test (pinned seed, author-owned draws — same rationale as E1.2's)

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

    mutating func draw(upTo bound: Int) -> Int {
        Int(next() % UInt64(bound + 1))
    }
}

@Suite("E2.2 reboot-cap property")
struct RebootCapPropertyTests {

    @Test("under any seeded post-reboot wall jump the display never exceeds the verified span plus the cap")
    func test_property_rebootGapNeverInflates_underLastKnownGood() {
        var rng = SplitMix64(seed: 0x5EED_0E22_2026_0709) // pinned; add failing seeds per test-suite §6.1.5
        for step in 0..<300 {
            let verified = rng.draw(upTo: 30 * day)
            let jump = rng.draw(upTo: 2_000 * day) - 100 * day // rollbacks and huge forward jumps
            let lkg = lkgOnBootA(after: verified)
            let mono = MonotonicNow(bootID: bootB, uptime: TimeInterval(rng.draw(upTo: 10 * day)))
            let now = lkg.wallClock + TimeInterval(jump)

            let display = StreakCalculator.conservativeElapsedSeconds(
                anchor: anchor, now: now, monotonic: mono, lastKnownGood: lkg
            )
            #expect(display >= verified, "step \(step): display \(display) fell below verified \(verified)")
            #expect(
                display <= verified + cap,
                "step \(step): verified \(verified), jump \(jump), display \(display) exceeds verified + cap"
            )

            let verdict = StreakCalculator.sanityCheck(
                anchor: anchor, now: now, monotonic: mono, lastKnownGood: lkg
            )
            if verdict == .normal {
                #expect(
                    display == verified + max(0, jump),
                    "step \(step): a normal verdict must credit the wall in full"
                )
            }
        }
    }
}

// MARK: - Slip/undo inheritance (the carried "undoSlip inherits the same fallback" pin)

@Suite("E2.2 reboot cap · slip/undo inheritance")
struct RebootCapSlipUndoTests {

    @Test("a slip across a reboot + huge forward jump banks the capped truth, not the inflated wall")
    func test_applySlip_acrossRebootForwardJump_banksCappedTruth() {
        let lkg = lkgOnBootA(after: 5 * day)
        let mono = MonotonicNow(bootID: bootB, uptime: 5_000)
        let now = epoch + TimeInterval(1_000 * day)

        let next = StreakCalculator.applySlip(to: quit, at: now, monotonic: mono, lastKnownGood: lkg)
        let ended = 5 * day + cap
        #expect(next.bestStreakSeconds == ended)      // the append-only bank holds the capped truth
        #expect(next.priorCleanSeconds == ended)
        #expect(next.startAt == epoch + TimeInterval(ended)) // guarded slip instant, not the jumped wall
        #expect(next.monotonicAnchor == MonotonicAnchor(
            bootID: bootB, uptime: 5_000, wallClock: epoch + TimeInterval(ended)
        ))
    }

    /// Post-slip snapshot: re-anchored at the slip instant (the epoch) with an open undo.
    private static let slipped = StreakSnapshot(
        startAt: epoch,
        trackedSince: epoch - TimeInterval(3 * 86_400),
        priorCleanSeconds: 3 * 86_400,
        monotonicAnchor: anchor,
        bestStreakSeconds: 3 * 86_400,
        pendingUndo: PendingSlipUndo(
            priorStartAt: epoch - TimeInterval(3 * 86_400),
            priorCleanSeconds: 0,
            priorBestStreakSeconds: 0,
            priorMonotonicAnchor: MonotonicAnchor(
                bootID: bootA, uptime: 50_000 - TimeInterval(3 * 86_400),
                wallClock: epoch - TimeInterval(3 * 86_400)
            )
        )
    )

    @Test("a rollback across a reboot cannot resurrect an undo window the trusted reading proves expired")
    func test_undoSlip_rebootRollback_windowStaysClosed_whenVerifiablyExpired() {
        // The device saw a trusted reading 700 s after the slip — the 600 s window is
        // verifiably over. A reboot + rolled-back wall claiming "only 100 s passed" must
        // not reopen it (today's floored-wall fallback wrongly restores here).
        let lkg = lkgOnBootA(after: 700)
        let mono = MonotonicNow(bootID: bootB, uptime: 50)
        let now = epoch + 100

        #expect(StreakCalculator.undoSlip(on: Self.slipped, at: now, monotonic: mono, lastKnownGood: lkg) == nil)
    }

    @Test("an honest reboot inside the window leaves undo available — the cap only withholds the unverifiable excess")
    func test_undoSlip_honestRebootInsideWindow_staysOpen() {
        // Trusted reading at the slip instant, reboot, reopened 30 s later per the wall:
        // gap 30 s ≤ cap ⇒ full credit ⇒ still inside the 600 s window.
        let lkg = lkgOnBootA(after: 0)
        let mono = MonotonicNow(bootID: bootB, uptime: 20)
        let now = epoch + 30

        let restored = StreakCalculator.undoSlip(on: Self.slipped, at: now, monotonic: mono, lastKnownGood: lkg)
        #expect(restored != nil)
        #expect(restored?.startAt == epoch - TimeInterval(3 * 86_400))
        #expect(restored?.bestStreakSeconds == 0)
        #expect(restored?.pendingUndo == nil)
    }

    @Test("beyond the cap the frozen elapsed still closes the undo window — the cap cannot be exploited to reopen it")
    func test_undoSlip_rebootForwardJumpBeyondCap_windowStaysClosed() {
        let lkg = lkgOnBootA(after: 0)
        let mono = MonotonicNow(bootID: bootB, uptime: 20)
        let now = epoch + TimeInterval(1_000 * day)

        #expect(StreakCalculator.undoSlip(on: Self.slipped, at: now, monotonic: mono, lastKnownGood: lkg) == nil)
    }
}
