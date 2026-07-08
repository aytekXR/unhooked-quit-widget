import Foundation
import Testing
@testable import StreakEngine

// Reduce-mode fixtures (test-suite §3.2, the alexAlcoholReduceMode persona shape). All
// instants are pinned UTC epoch seconds with their quit-timezone reading in comments —
// verified against Foundation's tz database before being committed red.

private let pacific = TimeZone(identifier: "America/Los_Angeles")! // UTC−7 in July (PDT)
private let newYork = TimeZone(identifier: "America/New_York")!    // fall-back on 2026-11-01

private let day = 86_400
private let hour = 3_600

/// 2026-07-07 00:00 PDT (07:00 UTC) — a plain 24h local day.
private let jul7StartPT = Date(timeIntervalSince1970: 1_783_407_600)
/// 2026-07-08 00:00 PDT.
private let jul8StartPT = jul7StartPT + TimeInterval(day)

/// One whole local calendar day in the quit's timezone.
private func localDay(startingAt start: Date) -> DateInterval {
    DateInterval(start: start, end: start + TimeInterval(day))
}

// MARK: - E1.4 named tests (implementation-plan E1.4 + the resume prompt's DST test)

@Suite("E1.4 Reduce-mode adherence")
struct AdherenceTests {

    @Test("a day with occurrences under the allowance is adherent")
    func test_reduceMode_dayUnderAllowance_isAdherent() {
        let value = StreakCalculator.adherence(
            for: [jul7StartPT + TimeInterval(9 * hour), jul7StartPT + TimeInterval(20 * hour)],
            in: localDay(startingAt: jul7StartPT),
            allowancePerDay: 3,
            timezone: pacific
        )
        #expect(value == Adherence(adherentDays: 1, evaluatedDays: 1))
    }

    @Test(
        "a day exactly at the allowance is adherent; one over is not",
        arguments: [(3, 1), (4, 0)]
    )
    func test_reduceMode_dayAtAllowance_isAdherent_overIsNot(units: Int, adherentDays: Int) {
        let occurrences = (0..<units).map { jul7StartPT + TimeInterval(10 * hour + $0 * hour) }
        let value = StreakCalculator.adherence(
            for: occurrences,
            in: localDay(startingAt: jul7StartPT),
            allowancePerDay: 3,
            timezone: pacific
        )
        #expect(value.adherentDays == adherentDays)
        #expect(value.evaluatedDays == 1)
    }

    @Test("the day closes in the quit's timezone — a late local evening never bleeds into the next (UTC) day")
    func test_reduceMode_dayCloseUsesQuitTimezone() {
        // 23:30 and 23:45 PDT on Jul 7 — already Jul 8 in UTC (06:30Z/06:45Z). A UTC day
        // close would misfile them; the quit's local day must own them.
        let lateEvening = [
            Date(timeIntervalSince1970: 1_783_492_200), // 2026-07-07 23:30 PDT
            Date(timeIntervalSince1970: 1_783_493_100), // 2026-07-07 23:45 PDT
        ]
        let jul7 = StreakCalculator.adherence(
            for: lateEvening, in: localDay(startingAt: jul7StartPT),
            allowancePerDay: 1, timezone: pacific
        )
        #expect(jul7 == Adherence(adherentDays: 0, evaluatedDays: 1)) // both land on Jul 7: over

        let jul8 = StreakCalculator.adherence(
            for: lateEvening, in: localDay(startingAt: jul8StartPT),
            allowancePerDay: 1, timezone: pacific
        )
        #expect(jul8 == Adherence(adherentDays: 1, evaluatedDays: 1)) // ...and Jul 8 stays clean
    }

    @Test("the Reduce streak counts adherent days, not abstinence — every day has occurrences, six of seven adhere")
    func test_reduceMode_streakCountsAdherentDaysNotAbstinence() {
        // One unit at noon local on each of Jul 6...Jul 12; Jul 9 has two more (3 total).
        let jul6Noon = jul7StartPT - TimeInterval(day) + TimeInterval(12 * hour)
        var occurrences = (0..<7).map { jul6Noon + TimeInterval($0 * day) }
        occurrences += [occurrences[3] + TimeInterval(hour), occurrences[3] + TimeInterval(2 * hour)]

        let week = StreakCalculator.adherence(
            for: occurrences,
            in: DateInterval(start: jul7StartPT - TimeInterval(day), duration: TimeInterval(7 * day)),
            allowancePerDay: 2,
            timezone: pacific
        )
        // Zero abstinent days, yet six adherent ones — the window-end midnight boundary
        // also stays exclusive (7 evaluated days, not 8).
        #expect(week == Adherence(adherentDays: 6, evaluatedDays: 7))
    }

    @Test("a DST fall-back transition day counts exactly once — 25 wall hours, one calendar day")
    func test_reduceMode_dstTransitionDay_countsOnce() {
        // America/New_York, 2026-10-31 00:00 EDT through 2026-11-03 00:00 EST: three
        // calendar days, the middle one (Nov 1) 25h long. Both 01:30 readings — EDT
        // (05:30Z) and the repeated hour's EST (06:30Z) — fold into that single day.
        let window = DateInterval(
            start: Date(timeIntervalSince1970: 1_793_419_200), // 2026-10-31 00:00 EDT
            end: Date(timeIntervalSince1970: 1_793_682_000)    // 2026-11-03 00:00 EST
        )
        let repeatedHour = [
            Date(timeIntervalSince1970: 1_793_511_000), // 2026-11-01 01:30 EDT
            Date(timeIntervalSince1970: 1_793_514_600), // 2026-11-01 01:30 EST (same wall reading, 1h later)
        ]
        let value = StreakCalculator.adherence(
            for: repeatedHour, in: window, allowancePerDay: 1, timezone: newYork
        )
        #expect(value.evaluatedDays == 3)  // Oct 31, Nov 1, Nov 2 — the 25h day is ONE day
        #expect(value.adherentDays == 2)   // both repeated-hour units land on Nov 1: it is over
    }
}

// MARK: - E1.4 adherence boundaries

@Suite("E1.4 adherence boundaries")
struct AdherenceEdgeTests {

    @Test("a zero-duration window evaluates the single day it falls in")
    func test_adherence_zeroDurationWindow_evaluatesItsSingleDay() {
        let value = StreakCalculator.adherence(
            for: [],
            in: DateInterval(start: jul7StartPT + TimeInterval(12 * hour), duration: 0),
            allowancePerDay: 0,
            timezone: pacific
        )
        #expect(value == Adherence(adherentDays: 1, evaluatedDays: 1))
    }

    @Test("a negative allowance clamps to zero — abstinent days adhere, any occurrence breaks")
    func test_adherence_negativeAllowance_clampsToZero() {
        let value = StreakCalculator.adherence(
            for: [jul7StartPT + TimeInterval(12 * hour)],
            in: DateInterval(start: jul7StartPT, duration: TimeInterval(2 * day)),
            allowancePerDay: -1,
            timezone: pacific
        )
        #expect(value == Adherence(adherentDays: 1, evaluatedDays: 2)) // Jul 8 (abstinent) only
    }

    @Test("occurrences outside the evaluated days never affect the verdict")
    func test_adherence_occurrencesOutsideWindowDays_ignored() {
        let value = StreakCalculator.adherence(
            for: [jul7StartPT - TimeInterval(hour), jul8StartPT + TimeInterval(hour)], // Jul 6 & Jul 8
            in: localDay(startingAt: jul7StartPT),
            allowancePerDay: 0,
            timezone: pacific
        )
        #expect(value == Adherence(adherentDays: 1, evaluatedDays: 1))
    }

    @Test("an allowance-zero window is the Quit-mode degenerate case — adherence IS abstinence")
    func test_adherence_zeroAllowance_matchesAbstinence() {
        let value = StreakCalculator.adherence(
            for: [jul7StartPT + TimeInterval(12 * hour)],
            in: DateInterval(start: jul7StartPT, duration: TimeInterval(2 * day)),
            allowancePerDay: 0,
            timezone: pacific
        )
        #expect(value == Adherence(adherentDays: 1, evaluatedDays: 2))
    }
}
