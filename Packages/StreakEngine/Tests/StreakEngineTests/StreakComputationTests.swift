import Foundation
import Testing
@testable import StreakEngine

// Shared fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z, a fixed constant so
// every recorded value is reproducible. The engine never reads a clock — `now` is always
// injected relative to this epoch.
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)

private let day = 86_400
private let hour = 3_600
private let week = 604_800

/// Deliberately unsorted (bundled JSON carries no ordering guarantee): 24h, 72h, 168h.
private let table = MilestoneTable(
    category: "fixture",
    milestones: [
        Milestone(afterHours: 72, title: "Three days", body: "Commonly reported: steadier."),
        Milestone(afterHours: 24, title: "One day", body: "Commonly reported: first reset."),
        Milestone(afterHours: 168, title: "One week", body: "Commonly reported: momentum."),
    ]
)

// MARK: - E1.1 named tests (implementation-plan E1.1 — the five, verbatim)

@Suite("E1.1 streak computation from anchors")
struct StreakComputationTests {

    @Test(
        "streak reads whole days plus an hour remainder from the start anchor",
        arguments: [
            // (elapsed seconds, expected days, expected remainder hours)
            (34 * day + 5 * hour + 20 * 60, 34, 5),   // 34d 5h 20m → 34d 5h
            (2 * hour, 0, 2),                         // sub-day streak
            (day - 1, 0, 23),                         // one second short of a day
            (day, 1, 0),                              // exact day boundary
        ]
    )
    func test_streak_daysAndHours_fromStartAnchor(elapsed: Int, days: Int, hours: Int) {
        let quit = QuitSnapshot(startAt: epoch)
        let value = StreakCalculator.currentStreak(for: quit, now: epoch + TimeInterval(elapsed))
        #expect(value.elapsedSeconds == elapsed)
        #expect(value.days == days)
        #expect(value.hours == hours)
    }

    @Test(
        "money saved pro-rates weekly spend over clean time, Decimal-exact",
        arguments: [
            // (weekly spend, clean seconds, expected) — multiply-before-divide keeps these
            // exact; $87.50 × 365d is test-suite §1.1's decimal-safety fixture (= $4562.50,
            // no Double drift).
            ("87.50", 365 * 86_400, "4562.5"),
            ("26", 604_800, "26"),          // exactly one week saves one week's spend
            ("10", 302_400, "5"),           // half a week saves half the spend
        ]
    )
    func test_moneySaved_weeklySpendProRata(spend: String, cleanSeconds: Int, expected: String) {
        let saved = StreakCalculator.moneySaved(
            weeklySpend: Decimal(string: spend)!,
            cleanSeconds: cleanSeconds
        )
        #expect(saved == Decimal(string: expected)!)
    }

    @Test("momentum is cumulative clean over total tracked, exposed as a percent")
    func test_momentum_cleanOverTotal_asPercent() {
        // Standalone primitive: fraction 0...1 per architecture §5.1.
        #expect(StreakCalculator.momentum(cleanSeconds: 75 * day, totalSeconds: 100 * day) == 0.75)

        // Through currentStreak: 100 tracked days, 45 banked clean days + 30-day current
        // streak = 75 clean days → 75%.
        let now = epoch + TimeInterval(100 * day)
        let quit = QuitSnapshot(
            startAt: epoch + TimeInterval(70 * day),
            trackedSince: epoch,
            priorCleanSeconds: 45 * day
        )
        let value = StreakCalculator.currentStreak(for: quit, now: now)
        #expect(value.momentum == 0.75)
        #expect(value.momentumPercent == 75.0)
    }

    @Test(
        "next milestone is the first unreached entry, boundary-inclusive reached",
        arguments: [
            // (elapsed hours, expected afterHours; nil = all reached)
            (0, 24),          // nothing reached yet → first entry
            (30, 72),         // 24h reached → next is 72h
            (72, 168),        // exactly AT 72h counts as reached → next is 168h
            (200, nil),       // beyond the last → nil
        ] as [(Int, Int?)]
    )
    func test_nextMilestone_selectsFirstUnreached(elapsedHours: Int, expected: Int?) {
        let next = StreakCalculator.nextMilestone(elapsedSeconds: elapsedHours * hour, in: table)
        #expect(next?.afterHours == expected)
    }

    @Test("a fresh start reads zero seconds, zero money, full momentum, no milestone")
    func test_streak_zeroSecondsAfterFreshStart() {
        let quit = QuitSnapshot(startAt: epoch, weeklySpend: Decimal(string: "26")!)
        let value = StreakCalculator.currentStreak(for: quit, now: epoch)
        #expect(value.elapsedSeconds == 0)
        #expect(value.days == 0)
        #expect(value.hours == 0)
        #expect(value.moneySaved == 0)
        #expect(value.momentum == 1.0)     // nothing tracked yet ⇒ nothing wasted (no-shame)
        #expect(value.momentumPercent == 100.0)
        #expect(value.nextMilestone == nil)
        #expect(value.clockSanity == .normal)
    }
}

// MARK: - E1.1 branch coverage (the five named tests alone don't reach every guard arm;
// the DoD demands 100% branch coverage on StreakCalculator.swift)

@Suite("E1.1 computation guard branches")
struct StreakComputationEdgeTests {

    @Test("momentum with zero tracked time is fully clean")
    func test_momentum_zeroTracked_isFullyClean() {
        #expect(StreakCalculator.momentum(cleanSeconds: 0, totalSeconds: 0) == 1.0)
    }

    @Test("momentum clamps clean time exceeding tracked time to 100%")
    func test_momentum_cleanBeyondTotal_clampsToFull() {
        #expect(StreakCalculator.momentum(cleanSeconds: 200, totalSeconds: 100) == 1.0)
    }

    @Test("momentum reads negative clean time as zero")
    func test_momentum_negativeClean_readsAsZero() {
        #expect(StreakCalculator.momentum(cleanSeconds: -5, totalSeconds: 100) == 0.0)
    }

    @Test("money saved is zero for non-positive spend", arguments: ["0", "-5"])
    func test_moneySaved_nonPositiveSpend_isZero(spend: String) {
        let saved = StreakCalculator.moneySaved(
            weeklySpend: Decimal(string: spend)!,
            cleanSeconds: 604_800
        )
        #expect(saved == 0)
    }

    @Test("money saved is zero for non-positive clean time", arguments: [0, -300])
    func test_moneySaved_nonPositiveCleanTime_isZero(cleanSeconds: Int) {
        let saved = StreakCalculator.moneySaved(
            weeklySpend: Decimal(string: "26")!,
            cleanSeconds: cleanSeconds
        )
        #expect(saved == 0)
    }

    @Test("next milestone on an empty table is nil")
    func test_nextMilestone_emptyTable_isNil() {
        let next = StreakCalculator.nextMilestone(elapsedSeconds: 0, in: .empty)
        #expect(next == nil)
    }

    @Test("a now before the start anchor clamps to a zero streak, never negative")
    func test_currentStreak_nowBeforeStart_clampsToZero() {
        let quit = QuitSnapshot(startAt: epoch, weeklySpend: Decimal(string: "26")!)
        let value = StreakCalculator.currentStreak(for: quit, now: epoch - 3_600)
        #expect(value.elapsedSeconds == 0)
        #expect(value.moneySaved == 0)
        #expect(value.momentum == 1.0)
    }

    @Test("currentStreak carries the next milestone when a table is supplied")
    func test_currentStreak_withTable_carriesNextMilestone() {
        let quit = QuitSnapshot(startAt: epoch)
        let value = StreakCalculator.currentStreak(
            for: quit,
            now: epoch + TimeInterval(30 * hour),
            milestones: table
        )
        #expect(value.nextMilestone?.afterHours == 72)
    }

    @Test("currentStreak money uses cumulative clean seconds, not just the current streak")
    func test_currentStreak_moneyUsesCumulativeCleanSeconds() {
        // One banked clean week + one current-streak week at $26/wk ⇒ $52.
        let quit = QuitSnapshot(
            startAt: epoch,
            trackedSince: epoch - TimeInterval(3 * week), // slips happened before startAt
            weeklySpend: Decimal(string: "26")!,
            priorCleanSeconds: week
        )
        let value = StreakCalculator.currentStreak(for: quit, now: epoch + TimeInterval(week))
        #expect(value.moneySaved == Decimal(string: "52")!)
    }
}

// MARK: - DI seam contract (test-suite §3: view models inject `any StreakCalculating`)

@Suite("StreakCalculating seam")
struct StreakCalculatingSeamTests {

    @Test("the injected instance seam agrees with the static computation core")
    func test_instanceSeam_agreesWithStaticCore() {
        let calculator: any StreakCalculating = StreakCalculator()
        let quit = QuitSnapshot(startAt: epoch, weeklySpend: Decimal(string: "26")!)
        let now = epoch + TimeInterval(30 * hour)

        #expect(calculator.currentStreak(for: quit, now: now)
            == StreakCalculator.currentStreak(for: quit, now: now))
        #expect(calculator.currentStreak(for: quit, now: now, monotonic: nil, milestones: table)
            == StreakCalculator.currentStreak(for: quit, now: now, milestones: table))
        #expect(calculator.momentum(cleanSeconds: 1, totalSeconds: 2)
            == StreakCalculator.momentum(cleanSeconds: 1, totalSeconds: 2))
        #expect(calculator.moneySaved(weeklySpend: Decimal(string: "26")!, cleanSeconds: week)
            == StreakCalculator.moneySaved(weeklySpend: Decimal(string: "26")!, cleanSeconds: week))
        #expect(calculator.nextMilestone(elapsedSeconds: 0, in: table)
            == StreakCalculator.nextMilestone(elapsedSeconds: 0, in: table))
    }
}
