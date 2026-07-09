import Foundation
import Testing
@testable import StreakEngine

// E2.3 — the ADR-7 healing re-anchor (freeze-then-resume), the half deferred from
// Session 06 to exactly this pass. Ratified semantics (Session 07 design panel +
// red-team adjudication):
//   - Heals ONLY the across-reboot over-cap arm (gap since the trusted baseline
//     beyond `defaultRebootGapCap`): the one frozen state that can never recover on
//     its own. Every other arm returns nil — within-boot disputes are monotonic
//     ground truth (and self-heal when the wall re-agrees), timezone shapes are
//     display concerns, the bridge inherits a within-boot verdict, an in-window
//     reboot already reads .normal, a rollback below the verified span recovers as
//     the wall catches up, and without a trusted reading there is nothing verified
//     to resume from.
//   - Mint ("option iii"): startAt' = now − frozen; anchor' = (reading.bootID,
//     reading.uptime − frozen, wallClock: startAt') — anchor.wallClock == startAt
//     preserved, so the next applySlip stamps the REAL now. trackedSince/createdAt
//     are IMMUTABLE (architecture §3 "never resets"; §8 history never shrinks), so
//     post-heal momentum is CONSERVATIVE: the withheld gap stays in the tracked
//     denominator and out of the clean numerator. Honest, not flattering.
//   - Banked fields (priorCleanSeconds/bestStreakSeconds), weeklySpend, pendingUndo
//     pass through untouched — no new append-only exemption.

// Fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z.
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)
private let day = 86_400
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

@Suite("E2.3 healing re-anchor")
struct HealTransitionTests {

    @Test("the over-cap arm re-bases onto the current boot and resumes from the frozen value")
    func test_healFrozenStreak_overCapArm_rebasesAndResumes() {
        let lkg = lkgOnBootA(after: 5 * day)          // last honest sighting: day 5
        let mono = MonotonicNow(bootID: bootB, uptime: 5_000)
        let now = epoch + TimeInterval(35 * day)      // 30d unverifiable gap > cap
        let frozen = 5 * day + cap                    // what the capped arm displays

        let healed = StreakCalculator.healFrozenStreak(
            on: quit, at: now, monotonic: mono, lastKnownGood: lkg
        )
        #expect(healed?.startAt == now - TimeInterval(frozen))
        #expect(healed?.trackedSince == quit.trackedSince, "option (iii): tracking origin never moves")
        #expect(healed?.monotonicAnchor == MonotonicAnchor(
            bootID: bootB, uptime: 5_000 - TimeInterval(frozen),
            wallClock: now - TimeInterval(frozen)
        ))

        guard let healed else { return }
        let atHeal = StreakCalculator.currentStreak(for: healed, now: now, monotonic: mono)
        #expect(atHeal.clockSanity == .normal)
        #expect(atHeal.elapsedSeconds == frozen, "resumes FROM the frozen value, not zero")

        let later = StreakCalculator.currentStreak(
            for: healed,
            now: now + TimeInterval(3 * day),
            monotonic: MonotonicNow(bootID: bootB, uptime: 5_000 + TimeInterval(3 * day))
        )
        #expect(later.clockSanity == .normal)
        #expect(later.elapsedSeconds == frozen + 3 * day, "…and keeps ticking in real time")
    }

    @Test(
        "every arm except across-reboot-over-cap refuses to heal",
        arguments: [
            // (label, now offset from epoch, reading, lastKnownGood)
            ("within-boot rollback: monotonic is ground truth",
             1 * 86_400, MonotonicNow(bootID: bootA, uptime: 50_000 + TimeInterval(3 * 86_400)),
             MonotonicAnchor?.none),
            ("within-boot forward jump: monotonic is ground truth",
             30 * 86_400, MonotonicNow(bootID: bootA, uptime: 50_000 + TimeInterval(3 * 86_400)),
             MonotonicAnchor?.none),
            ("timezone-shaped set (−3h): a display concern, not a frozen streak",
             3 * 86_400 - 3 * 3_600, MonotonicNow(bootID: bootA, uptime: 50_000 + TimeInterval(3 * 86_400)),
             MonotonicAnchor?.none),
            ("bridge, honest: same-boot capture verifies the remainder — nothing frozen",
             25 * 86_400, MonotonicNow(bootID: bootB, uptime: 1_000 + TimeInterval(20 * 86_400)),
             MonotonicAnchor(bootID: bootB, uptime: 1_000, wallClock: epoch + TimeInterval(5 * 86_400))),
            ("bridge, wall fiddled since capture: inherits the within-boot verdict",
             35 * 86_400, MonotonicNow(bootID: bootB, uptime: 1_000 + TimeInterval(2 * 86_400)),
             MonotonicAnchor(bootID: bootB, uptime: 1_000, wallClock: epoch + TimeInterval(5 * 86_400))),
            ("reboot with an in-window gap: already .normal, fully credited",
             8 * 86_400, MonotonicNow(bootID: bootB, uptime: 5_000),
             MonotonicAnchor(bootID: bootA, uptime: 50_000 + TimeInterval(5 * 86_400), wallClock: epoch + TimeInterval(5 * 86_400))),
            ("reboot rollback below the verified span: recovers when the wall is fixed",
             3 * 86_400, MonotonicNow(bootID: bootB, uptime: 5_000),
             MonotonicAnchor(bootID: bootA, uptime: 50_000 + TimeInterval(5 * 86_400), wallClock: epoch + TimeInterval(5 * 86_400))),
            ("reboot without a trusted reading: nothing verified to resume from",
             30 * 86_400, MonotonicNow(bootID: bootB, uptime: 5_000),
             MonotonicAnchor?.none),
        ]
    )
    func test_healFrozenStreak_nonHealableArms_returnNil(
        label: String, nowOffset: Int, reading: MonotonicNow, lkg: MonotonicAnchor?
    ) {
        let healed = StreakCalculator.healFrozenStreak(
            on: quit, at: epoch + TimeInterval(nowOffset), monotonic: reading, lastKnownGood: lkg
        )
        #expect(healed == nil, "\(label)")
    }

    @Test("no anchor, or no reading, means no heal")
    func test_healFrozenStreak_withoutEvidence_returnsNil() {
        let bare = StreakSnapshot(startAt: epoch)
        let now = epoch + TimeInterval(35 * day)
        #expect(StreakCalculator.healFrozenStreak(
            on: bare, at: now,
            monotonic: MonotonicNow(bootID: bootB, uptime: 5_000),
            lastKnownGood: lkgOnBootA(after: 5 * day)
        ) == nil)
        #expect(StreakCalculator.healFrozenStreak(
            on: quit, at: now, monotonic: nil, lastKnownGood: lkgOnBootA(after: 5 * day)
        ) == nil)
    }

    @Test("banked history, spend, tracking origin, and undo bookkeeping pass through untouched")
    func test_healFrozenStreak_preservesBanksAndTracking() {
        let undo = PendingSlipUndo(
            priorStartAt: epoch - TimeInterval(3 * day),
            priorCleanSeconds: 0,
            priorBestStreakSeconds: 0
        )
        let slipped = StreakSnapshot(
            startAt: epoch,
            trackedSince: epoch - TimeInterval(20 * day),
            weeklySpend: 26,
            priorCleanSeconds: 7 * day,
            monotonicAnchor: anchor,
            bestStreakSeconds: 9 * day,
            pendingUndo: undo
        )
        let healed = StreakCalculator.healFrozenStreak(
            on: slipped,
            at: epoch + TimeInterval(35 * day),
            monotonic: MonotonicNow(bootID: bootB, uptime: 5_000),
            lastKnownGood: lkgOnBootA(after: 5 * day)
        )
        #expect(healed != nil)
        #expect(healed?.priorCleanSeconds == 7 * day)
        #expect(healed?.bestStreakSeconds == 9 * day)
        #expect(healed?.weeklySpend == 26)
        #expect(healed?.trackedSince == epoch - TimeInterval(20 * day))
        #expect(healed?.pendingUndo == undo)
    }

    @Test("post-heal momentum is conservative: the withheld gap stays tracked, not clean")
    func test_healFrozenStreak_momentumIsConservative() {
        let lkg = lkgOnBootA(after: 5 * day)
        let mono = MonotonicNow(bootID: bootB, uptime: 5_000)
        let now = epoch + TimeInterval(35 * day)
        let frozen = 5 * day + cap

        guard let healed = StreakCalculator.healFrozenStreak(
            on: quit, at: now, monotonic: mono, lastKnownGood: lkg
        ) else {
            Issue.record("over-cap arm must heal")
            return
        }
        // tracked = elapsed + (startAt' − trackedSince) = the TRUE 35-day span; the
        // 16 unverifiable days count as tracked-but-not-clean. Honest > flattering.
        let atHeal = StreakCalculator.currentStreak(for: healed, now: now, monotonic: mono)
        #expect(atHeal.momentum == Double(frozen) / Double(35 * day))

        // …and climbs back as real clean time accrues.
        let later = StreakCalculator.currentStreak(
            for: healed,
            now: now + TimeInterval(7 * day),
            monotonic: MonotonicNow(bootID: bootB, uptime: 5_000 + TimeInterval(7 * day))
        )
        #expect(later.momentum == Double(frozen + 7 * day) / Double(42 * day))
        #expect(later.momentum > atHeal.momentum)
    }

    @Test("a slip after a heal stays coherent: real slip instant, coherent anchor, .normal reads")
    func test_slipAfterHeal_streakStaysCoherent() {
        let lkg = lkgOnBootA(after: 5 * day)
        let now = epoch + TimeInterval(35 * day)
        let frozen = 5 * day + cap

        guard let healed = StreakCalculator.healFrozenStreak(
            on: quit, at: now, monotonic: MonotonicNow(bootID: bootB, uptime: 5_000),
            lastKnownGood: lkg
        ) else {
            Issue.record("over-cap arm must heal")
            return
        }
        // Five honest days later the user slips. The slip must land on the REAL wall
        // (the healed timeline IS the wall timeline) with a coherent re-anchor — the
        // pin that kills the rejected anchor-only mint, whose stale startAt stamps
        // the slip ~16d in the past and false-flags every read thereafter.
        let slipNow = now + TimeInterval(5 * day)
        let slipMono = MonotonicNow(bootID: bootB, uptime: 5_000 + TimeInterval(5 * day))
        let next = StreakCalculator.applySlip(to: healed, at: slipNow, monotonic: slipMono)

        #expect(next.startAt == slipNow)
        #expect(next.monotonicAnchor?.wallClock == next.startAt)
        #expect(next.priorCleanSeconds == frozen + 5 * day, "the ended streak banks frozen + honest days")

        let after = StreakCalculator.currentStreak(
            for: next,
            now: slipNow + 3_600,
            monotonic: MonotonicNow(bootID: bootB, uptime: 5_000 + TimeInterval(5 * day) + 3_600)
        )
        #expect(after.clockSanity == .normal)
        #expect(after.elapsedSeconds == 3_600)
    }
}

// MARK: - Property test (pinned seed, author-owned draws — same rationale as E1.2/E2.2)

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

@Suite("E2.3 healing re-anchor · property")
struct HealTransitionPropertyTests {

    @Test("healing never inflates: it fires exactly on the over-cap arm and resumes at the frozen value")
    func test_property_healNeverInflates() {
        var rng = SplitMix64(seed: 0x5EED_0E23_2026_0709) // pinned; add failing seeds per test-suite §6.1.5
        for step in 0..<300 {
            let verified = rng.draw(upTo: 30 * day)
            let jump = rng.draw(upTo: 2_000 * day) - 100 * day
            let uptime = TimeInterval(rng.draw(upTo: 10 * day))
            let lkg = lkgOnBootA(after: verified)
            let mono = MonotonicNow(bootID: bootB, uptime: uptime)
            let now = lkg.wallClock + TimeInterval(jump)

            let frozen = StreakCalculator.conservativeElapsedSeconds(
                anchor: anchor, now: now, monotonic: mono, lastKnownGood: lkg
            )
            let healed = StreakCalculator.healFrozenStreak(
                on: quit, at: now, monotonic: mono, lastKnownGood: lkg
            )

            // The heal fires exactly when the unverifiable gap exceeds the cap
            // (bootA lkg + bootB reading by construction: never the bridge arm).
            let overCap = TimeInterval(jump) > StreakCalculator.defaultRebootGapCap
            #expect((healed != nil) == overCap, "step \(step): jump \(jump)")

            guard let healed else { continue }
            let atHeal = StreakCalculator.currentStreak(for: healed, now: now, monotonic: mono)
            #expect(atHeal.clockSanity == .normal, "step \(step)")
            #expect(atHeal.elapsedSeconds == frozen, "step \(step): resumes at the frozen value, never above")

            let delta = TimeInterval(rng.draw(upTo: 5 * day))
            let later = StreakCalculator.currentStreak(
                for: healed, now: now + delta,
                monotonic: MonotonicNow(bootID: bootB, uptime: uptime + delta)
            )
            #expect(
                later.elapsedSeconds == frozen + Int(delta),
                "step \(step): only real time accrues after the heal"
            )
        }
    }
}
