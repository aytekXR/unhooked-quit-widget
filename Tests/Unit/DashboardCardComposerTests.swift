import Foundation
import StreakEngine
import Testing
import WidgetToolkit
@testable import Unhooked

/// UIR-2 (Session 34) unit lane — the dashboard's pure display derivations.
///
/// Two facts carry the card's correctness and both are pinned here (and rehearsed on the
/// free Linux box before any billed run — pure Foundation/StreakEngine, no SwiftData):
///
///  1. **"Day N" is the ADR-11 calendar day, NOT 24h blocks.** A streak that started
///     before the user's local midnight is on Day 2 the next morning even though 24h have
///     not elapsed — `StreakValue.days + 1` would say Day 1. The noon-anchor formula is
///     the exact one the widget's `StreakTimelinePlanner` uses, so the in-app card and the
///     lock-screen widget can never disagree (the drift-guard test proves it).
///  2. **The milestone bar omits rather than fabricates.** No ladder or every rung climbed
///     ⇒ `nil` (no bar), never a full bar for an earned ladder.
@Suite("UIR-2 · DashboardCardComposer")
struct DashboardCardComposerTests {
    private static let nyID = "America/New_York"

    private static func ny(_ y: Int, _ mo: Int, _ d: Int, _ h: Int, _ mi: Int) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: nyID)!
        return cal.date(from: DateComponents(year: y, month: mo, day: d, hour: h, minute: mi))!
    }

    // MARK: - calendarDayNumber (ADR-11)

    @Test func test_dayNumber_sameCalendarDay_isDayOne() {
        let start = Self.ny(2025, 7, 14, 8, 0)
        let now = Self.ny(2025, 7, 14, 20, 0) // same NY day, 12h later
        #expect(DashboardCardComposer.calendarDayNumber(startAt: start, timeZoneIdentifier: Self.nyID, now: now) == 1)
    }

    /// THE ADR-11 case: started Tuesday 11pm, it is Wednesday 8am — 9 hours elapsed, but
    /// one calendar boundary crossed. Calendar day = 2; `StreakValue.days + 1` would be 1.
    @Test func test_dayNumber_startedBeforeLocalMidnight_isDayTwoNextMorning() {
        let start = Self.ny(2025, 7, 15, 23, 0)
        let now = Self.ny(2025, 7, 16, 8, 0)
        let calendarDay = DashboardCardComposer.calendarDayNumber(
            startAt: start, timeZoneIdentifier: Self.nyID, now: now
        )
        #expect(calendarDay == 2, "one calendar boundary crossed ⇒ Day 2")
        // The 24h-block reading (StreakValue.days + 1) would be Day 1 — the bug ADR-11 forbids.
        let elapsed = Int(now.timeIntervalSince(start))
        #expect(elapsed / 86_400 + 1 == 1, "24h-blocks would say Day 1 — this is why the dashboard never uses it")
    }

    @Test func test_dayNumber_matchesTheWidgetFixture_dayThirtyFour() {
        // The exact StreakWidgetSnapshotTests fixture: start 2025-06-11T18:30-04, render
        // 2025-07-14T14:30-04 ⇒ Day 34.
        let start = Date(timeIntervalSince1970: 1_749_681_000)
        let now = Date(timeIntervalSince1970: 1_752_517_800)
        #expect(
            DashboardCardComposer.calendarDayNumber(startAt: start, timeZoneIdentifier: Self.nyID, now: now) == 34
        )
    }

    @Test func test_dayNumber_neverBelowOne_evenIfClockRolledBack() {
        let start = Self.ny(2025, 7, 14, 8, 0)
        let now = Self.ny(2025, 7, 10, 8, 0) // "now" earlier than start (rolled-back clock)
        #expect(DashboardCardComposer.calendarDayNumber(startAt: start, timeZoneIdentifier: Self.nyID, now: now) == 1)
    }

    @Test func test_dayNumber_emptyTimeZoneIdentifier_fallsBackWithoutCrashing() {
        // Pre-E6.2 rows carry "" until the launch backfill; TimeZone(identifier: "") fails
        // and the composer falls back to the device zone (never traps, never returns 0).
        let start = Date(timeIntervalSince1970: 1_749_681_000)
        let now = Date(timeIntervalSince1970: 1_752_517_800)
        let day = DashboardCardComposer.calendarDayNumber(startAt: start, timeZoneIdentifier: "", now: now)
        #expect(day >= 1)
    }

    /// Drift guard: the composer's "Day N" must equal the widget planner's `dayNumber` for
    /// the same inputs — the two surfaces share ADR-11's meaning, so they must never
    /// disagree. Covers a same-day, a next-morning-before-midnight, and the DST
    /// spring-forward day (a 23-hour day, 2025-03-09 in NY).
    @Test func test_dayNumber_matchesTheWidgetPlanner_acrossBoundaries() {
        let cases: [(start: Date, now: Date)] = [
            (Self.ny(2025, 7, 14, 8, 0), Self.ny(2025, 7, 14, 20, 0)),
            (Self.ny(2025, 7, 15, 23, 0), Self.ny(2025, 7, 16, 8, 0)),
            (Self.ny(2025, 3, 8, 23, 0), Self.ny(2025, 3, 9, 10, 0)), // DST spring-forward
            (Date(timeIntervalSince1970: 1_749_681_000), Date(timeIntervalSince1970: 1_752_517_800)),
        ]
        let zone = TimeZone(identifier: Self.nyID)!
        for (start, now) in cases {
            let reader = FixedStateReader(
                state: StreakWidgetState(streakStart: start, timeZone: zone, generatedAt: now)
            )
            let plannerDay = StreakTimelinePlanner()
                .plan(reading: reader, now: now, horizonDays: 0)
                .entries.first?.dayNumber
            let composerDay = DashboardCardComposer.calendarDayNumber(
                startAt: start, timeZoneIdentifier: Self.nyID, now: now
            )
            #expect(plannerDay == composerDay, "dashboard Day N must match the widget planner's dayNumber")
        }
    }

    // MARK: - milestoneProgress

    @Test func test_milestoneProgress_noLadder_isNil() {
        #expect(DashboardCardComposer.milestoneProgress(elapsedSeconds: 3_600, milestoneHours: []) == nil)
    }

    @Test func test_milestoneProgress_midLadder_isTheFractionTowardTheNextRung() {
        // 6 hours in, next rung is 12h ⇒ 0.5.
        let progress = DashboardCardComposer.milestoneProgress(
            elapsedSeconds: 6 * 3_600, milestoneHours: [12, 24, 72]
        )
        #expect(progress == 0.5)
    }

    @Test func test_milestoneProgress_exactlyAtARung_advancesToTheNext() {
        // Exactly 12h: the 12h rung is earned, so "next" is 24h ⇒ 12/24 = 0.5.
        let progress = DashboardCardComposer.milestoneProgress(
            elapsedSeconds: 12 * 3_600, milestoneHours: [12, 24, 72]
        )
        #expect(progress == 0.5)
    }

    @Test func test_milestoneProgress_allRungsClimbed_isNil_notAFullBar() {
        // Past the last rung: omit the bar (never fabricate a full target).
        #expect(DashboardCardComposer.milestoneProgress(elapsedSeconds: 100 * 3_600, milestoneHours: [12, 24, 72]) == nil)
    }
}

/// A trivial `StreakWidgetStateReading` for the drift-guard test — hands the planner a
/// fixed state (the production seam is a file read; here it is an in-memory value).
private struct FixedStateReader: StreakWidgetStateReading {
    let state: StreakWidgetState?
    func read() -> StreakWidgetState? { state }
}
