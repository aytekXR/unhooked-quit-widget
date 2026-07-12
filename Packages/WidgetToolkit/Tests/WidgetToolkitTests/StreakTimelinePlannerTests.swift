import Foundation
import Testing
@testable import WidgetToolkit

// E6.1 — the timeline planner: midnight/DST day rollover, stale-grace, ticking counters.
//
// Day semantics (Session 20 step-0 ruling L1, operator-vetoable): "Day N" is a CALENDAR
// day count that increments at LOCAL MIDNIGHT in the quit's FIXED start timezone —
// implementation-plan E6.1 (`entriesCrossMidnight_incrementDay`), architecture §11
// ("entries only at midnight boundaries"), test-suite §1 scenario 23, and test-suite §3.1
// item 3 ("day boundaries computed in the quit's timezone") all say so. It is deliberately
// NOT StreakEngine's `StreakValue.days` (elapsedSeconds / 86_400), which is a tz-invariant
// DURATION readout feeding milestone math and has no display consumer. The fixed-timezone
// anchor is what keeps the count immune to travel (MVP AC#13): TimeZone.current would let a
// westward flight bump the day number, and ADR-7's monotonic guard cannot see a timezone.
//
// The package is Foundation-only BY RULE (no WidgetKit, no SwiftUI, no StreakEngine): that is
// what keeps the `package-units` CI lane on the free ubuntu runner. Calendar/TimeZone are
// Foundation, and the Linux toolchain carries the real tz database (verified empirically this
// session: the 23-hour spring-forward day, the 25-hour fall-back day, and Lord Howe's
// 30-minute shift all resolve correctly).

// Fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z.
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)

private let newYork = TimeZone(identifier: "America/New_York")!
private let istanbul = TimeZone(identifier: "Europe/Istanbul")! // permanent UTC+3, no DST — the control
/// Springs forward AT midnight (2027-09-05: 00:00 → 01:00), so local 00:00:00 DOES NOT EXIST
/// that day and `startOfDay` lands on 01:00. The zone that breaks duration-based day math.
private let santiago = TimeZone(identifier: "America/Santiago")!

/// A wall-clock instant, spelled as a local date in a named zone. Fixtures read as the user
/// would experience them ("2027-03-14, 10:00, New York"), never as opaque epoch integers.
private func local(
    _ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0,
    in timeZone: TimeZone
) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    return calendar.date(
        from: DateComponents(
            timeZone: timeZone, year: year, month: month, day: day, hour: hour, minute: minute
        )
    )!
}

/// A read-only seam spy: records how often the planner read, and proves BY TYPE that it cannot
/// write (`StreakWidgetStateReading` has exactly one member — there is no write to call).
private final class SpyReader: StreakWidgetStateReading, @unchecked Sendable {
    private(set) var readCount = 0
    private let state: StreakWidgetState?

    init(_ state: StreakWidgetState?) {
        self.state = state
    }

    func read() -> StreakWidgetState? {
        readCount += 1
        return state
    }
}

private func state(
    streakStart: Date,
    timeZone: TimeZone = newYork,
    generatedAt: Date
) -> StreakWidgetState {
    StreakWidgetState(streakStart: streakStart, timeZone: timeZone, generatedAt: generatedAt)
}

@Suite("E6.1 streak timeline planner")
struct StreakTimelinePlannerTests {

    // MARK: - The four plan-named tests (implementation-plan E6.1, verbatim identifiers)

    /// Entries land ON local midnight and the day number goes up by exactly one at each — the
    /// widget must re-render at the boundary, because `Text(timerInterval:)` renders H:MM:SS
    /// with no day component and can never flip "Day 34" to "Day 35" by itself.
    @Test("entries land on local midnight and increment the day by exactly one")
    func test_timeline_entriesCrossMidnight_incrementDay() {
        // Quit started late on 2027-03-01 (New York). Day 1 is 2027-03-01 by the calendar rule.
        let start = local(2027, 3, 1, 22, 40, in: newYork)
        let now = local(2027, 3, 3, 21, 0, in: newYork) // Day 3, three hours before midnight
        let reader = SpyReader(state(streakStart: start, generatedAt: now))

        let plan = StreakTimelinePlanner().plan(reading: reader, now: now, horizonDays: 3)

        // The leading entry is NOW (what the widget shows the moment the timeline loads).
        #expect(plan.entries.first?.date == now)
        #expect(plan.entries.first?.dayNumber == 3)

        // Every entry after the first is a local midnight, and each bumps the day by one.
        let boundaries = Array(plan.entries.dropFirst())
        #expect(boundaries.map(\.date) == [
            local(2027, 3, 4, in: newYork),
            local(2027, 3, 5, in: newYork),
            local(2027, 3, 6, in: newYork),
        ])
        #expect(boundaries.map(\.dayNumber) == [4, 5, 6])

        // The ticker restarts at each boundary: its window is exactly that local day.
        #expect(
            boundaries.first?.tickWindow
                == local(2027, 3, 4, in: newYork)...local(2027, 3, 5, in: newYork)
        )
    }

    /// The spring-forward day is 23 hours long. A naive `startOfDay + 86_400` implementation
    /// puts the boundary an hour LATE (05:00Z instead of 04:00Z) and the widget rolls the day
    /// over an hour after the user's midnight. The fixture deliberately sits INSIDE the 23-hour
    /// day — anchoring it the day before would let the naive implementation pass and prove nothing.
    @Test("a 23-hour spring-forward day still ends at local midnight, and is still one day")
    func test_timeline_dstSpringForward_dayBoundaryCorrect() {
        // US spring-forward 2027: Sunday 2027-03-14, 02:00 EST → 03:00 EDT (offset -5 → -4).
        let start = local(2027, 3, 8, 9, 0, in: newYork)
        let now = local(2027, 3, 14, 10, 0, in: newYork) // inside the 23-hour day
        let reader = SpyReader(state(streakStart: start, generatedAt: now))

        let plan = StreakTimelinePlanner().plan(reading: reader, now: now, horizonDays: 1)

        let boundary = plan.entries.last
        // TRUE next local midnight: 2027-03-15 00:00 EDT == 04:00Z (epoch verified empirically).
        #expect(boundary?.date == local(2027, 3, 15, in: newYork))
        #expect(boundary?.date == Date(timeIntervalSince1970: 1_805_083_200))
        // The naive `startOfDay + 86_400` answer (05:00Z) — pinned as the anti-regression: an
        // implementation that lands here rolls the user's day over an hour late.
        #expect(boundary?.date != Date(timeIntervalSince1970: 1_805_086_800))

        // A 23-hour day is still ONE day: 2027-03-08 is Day 1, so 2027-03-14 is Day 7 and the
        // boundary opens Day 8 — the shortened day must not skip or double-count.
        #expect(plan.entries.first?.dayNumber == 7)
        #expect(boundary?.dayNumber == 8)

        // The day the ticker covers is 23 hours, not 24 — the window is the real local day.
        let springForwardDay = local(2027, 3, 14, in: newYork)...local(2027, 3, 15, in: newYork)
        #expect(plan.entries.first?.tickWindow == springForwardDay)
        #expect(springForwardDay.upperBound.timeIntervalSince(springForwardDay.lowerBound) == 23 * 3_600)
    }

    /// Stale-grace (brandkit item 14: "last-known value keeps ticking via `timerInterval`"):
    /// when nothing has refreshed the state for days, the widget keeps showing the last-known
    /// streak and keeps counting — day boundaries are pure functions of (streakStart, timeZone),
    /// so the count stays CORRECT while stale. It is flagged, never captioned (architecture §9
    /// silent-recover: "Never surface").
    @Test("a stale state still renders the last-known streak, still ticking, flagged not captioned")
    func test_staleGraceEntry_showsLastKnownStreak_ticking() {
        let start = local(2027, 3, 1, 8, 0, in: newYork)
        let generatedAt = local(2027, 3, 3, 9, 0, in: newYork) // last write: Day 3
        let now = local(2027, 3, 6, 15, 0, in: newYork) // three days later, no refresh: Day 6
        let reader = SpyReader(state(streakStart: start, generatedAt: generatedAt))

        let plan = StreakTimelinePlanner().plan(reading: reader, now: now, horizonDays: 1)

        let entry = plan.entries.first
        // The last-known streak KEEPS COUNTING — a stale file does not freeze the day number.
        #expect(entry?.dayNumber == 6)
        // ...and KEEPS TICKING: the ticker window is live, never nil.
        #expect(entry?.tickWindow == local(2027, 3, 6, in: newYork)...local(2027, 3, 7, in: newYork))
        // Flagged so a renderer COULD degrade; carrying no copy, because E6.1 ships no words.
        #expect(entry?.freshness == .staleGrace)

        // A freshly-written state is `.fresh` on the same clock — the flag tracks the write, not the day.
        let fresh = StreakTimelinePlanner().plan(
            reading: SpyReader(state(streakStart: start, generatedAt: now)), now: now, horizonDays: 1
        )
        #expect(fresh.entries.first?.freshness == .fresh)
    }

    /// The provider's ONLY dependency is a read-only seam. Stated honestly (the naive form —
    /// "the widget opens no store at all" — is false: the shipped `PanicLaunchFlag` already
    /// writes App Group defaults from the extension on a panic tap, ADR-6's sanctioned
    /// intent→flag hop). What IS true and pinned here: the planner reads its state through a
    /// seam with no write member (BY TYPE), touches it read-only, and never opens SwiftData.
    @Test("the planner reads its state through a read-only seam and never writes")
    func test_provider_readsStoreReadOnly() {
        let start = local(2027, 3, 1, 8, 0, in: newYork)
        let now = local(2027, 3, 4, 8, 0, in: newYork)
        let reader = SpyReader(state(streakStart: start, generatedAt: now))

        let first = StreakTimelinePlanner().plan(reading: reader, now: now, horizonDays: 2)
        #expect(reader.readCount == 1) // exactly one read per plan — no re-entrant file access

        // Planning is a PURE function of (state, now): the same reader replanned yields the same
        // plan. A planner that mutated anything it read could not satisfy this.
        let second = StreakTimelinePlanner().plan(reading: reader, now: now, horizonDays: 2)
        #expect(reader.readCount == 2)
        #expect(first == second)
    }

    // MARK: - The unavailable state (lead ruling L6 — the adversary's catch)

    /// A nil read (fresh install, or post-erase: the owned App Group file is ABSENT) yields
    /// exactly ONE entry, never `[]`. WidgetKit does not fall back to `placeholder(in:)` on an
    /// empty timeline — it keeps the last rendered pixels, so an empty array after erase would
    /// leave the erased streak on the lock screen, still ticking. And never a fabricated "Day 0".
    @Test("no state on disk yields exactly one unavailable entry — no ticker, never a fabricated day")
    func test_noState_yieldsSingleUnavailableEntry_neverEmptyTimeline_neverFabricatedDay() {
        let reader = SpyReader(nil)
        let now = epoch

        let plan = StreakTimelinePlanner().plan(reading: reader, now: now, horizonDays: 7)

        #expect(plan.entries.count == 1)
        #expect(plan.entries.first?.date == now)
        #expect(plan.entries.first?.kind == .unavailable)
        #expect(plan.entries.first?.tickWindow == nil) // an empty state must not tick
        #expect(plan.entries.first?.dayNumber == nil)  // never "Day 0"
    }

    // MARK: - Day-rule pins (lead ruling L1)

    /// The first calendar day is Day 1 — never Day 0 (and never "back to day 1" as a caption:
    /// test-suite §1 item 13 bans that phrasing, which presupposes the reset day IS Day 1).
    @Test("the day the user quits is Day 1, from the first second")
    func test_dayNumber_startsAtOne_onTheQuitDay() {
        let start = local(2027, 6, 10, 23, 59, in: newYork) // one minute before midnight
        let reader = SpyReader(state(streakStart: start, generatedAt: start))

        let plan = StreakTimelinePlanner().plan(reading: reader, now: start, horizonDays: 1)

        #expect(plan.entries.first?.dayNumber == 1)
        // ...and one minute later it is Day 2: the calendar rule, not a 24-hour rule.
        let afterMidnight = plan.entries.last
        #expect(afterMidnight?.date == local(2027, 6, 11, in: newYork))
        #expect(afterMidnight?.dayNumber == 2)
    }

    /// The day count rides the quit's FIXED timezone, never the device's. A user who flies west
    /// must not gain a day (MVP AC#13: crossing timezones never inflates a streak) — ADR-7's
    /// monotonic guard watches elapsed seconds and cannot see a timezone, so the anchor does it.
    @Test("the day count is anchored to the quit's timezone, so travel cannot inflate it")
    func test_dayNumber_anchoredToQuitTimeZone_travelCannotInflate() {
        // ONE pair of wall-clock instants, read against two different quit timezones. The span
        // ends at 2027-06-04 18:00 in New York but 2027-06-05 01:00 in Istanbul — the same
        // elapsed seconds straddle a different number of local midnights (empirically verified).
        let start = local(2027, 6, 1, 8, 0, in: newYork)
        let now = start.addingTimeInterval(3 * 86_400 + 10 * 3_600)

        let anchoredHome = StreakTimelinePlanner().plan(
            reading: SpyReader(state(streakStart: start, timeZone: newYork, generatedAt: now)),
            now: now, horizonDays: 1
        )
        let anchoredAbroad = StreakTimelinePlanner().plan(
            reading: SpyReader(state(streakStart: start, timeZone: istanbul, generatedAt: now)),
            now: now, horizonDays: 1
        )

        #expect(anchoredHome.entries.first?.dayNumber == 4)
        #expect(anchoredAbroad.entries.first?.dayNumber == 5)
        // That one-day spread IS the hazard: were the planner to read the DEVICE's zone, the New
        // York quitter would gain a day the moment they landed in Istanbul. It cannot — the zone
        // arrives in the state, and `TimeZone.current` appears nowhere in the package.
    }

    // MARK: - Timeline mechanics

    /// The plan asks WidgetKit to come back at the last boundary it planned, so the timeline
    /// refills itself without a write (architecture §11: entries at day boundaries, and the
    /// push-based reload on every write is the FRESHNESS path, not the rollover path).
    @Test("the plan schedules its own refill at the last planned boundary")
    func test_plan_refreshesAtLastBoundary() {
        let start = local(2027, 3, 1, 12, 0, in: newYork)
        let now = local(2027, 3, 2, 12, 0, in: newYork)
        let reader = SpyReader(state(streakStart: start, generatedAt: now))

        let plan = StreakTimelinePlanner().plan(reading: reader, now: now, horizonDays: 4)

        #expect(plan.entries.count == 5) // now + four midnights
        #expect(plan.refreshAfter == plan.entries.last?.date)
    }

    /// The day local midnight DOES NOT EXIST. America/Santiago springs forward at 00:00 on
    /// 2027-09-05, so `startOfDay` for that date is 01:00. A user who quits THAT day gets a
    /// 01:00 origin, and duration-based day math (`dateComponents([.day], from:to:)`, which asks
    /// "how many whole 24-hour days fit") then comes up one hour short of every subsequent day
    /// boundary — the streak would read one day low FOREVER. Ordinal day indices ask "which
    /// calendar day is this" instead, and are immune. Found by an adversarial probe, not by the
    /// four plan-named tests; this pin is why it can never come back.
    @Test("a quit that starts on a day with no local midnight still counts days correctly")
    func test_dayNumber_quitStartedOnDayWithNoLocalMidnight_doesNotUndercountForever() {
        // 2027-09-05, Santiago: the clock jumps 00:00 → 01:00. The user quits at 10:00 that day.
        let start = local(2027, 9, 5, 10, 0, in: santiago)
        // Sanity: this really is a no-midnight day — the fixture is worthless otherwise.
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = santiago
        #expect(calendar.dateComponents([.hour], from: calendar.startOfDay(for: start)).hour == 1)

        // Day 1 is the quit day; each following local day is exactly one more.
        for (offset, expected) in [(0, 1), (1, 2), (2, 3), (5, 6), (30, 31)] {
            let noon = local(2027, 9, 5 + offset, 12, 0, in: santiago)
            let plan = StreakTimelinePlanner().plan(
                reading: SpyReader(state(streakStart: start, timeZone: santiago, generatedAt: noon)),
                now: noon, horizonDays: 1
            )
            #expect(plan.entries.first?.dayNumber == expected)
        }
    }

    // MARK: - The green-critic catches (each reproduced before it was fixed)

    /// A device clock set BACK past the streak's start must never render "Day 0" or a negative
    /// day. The widget's `now` is the raw device clock and the widget runs no clock guard of its
    /// own (ADR-6: the guard runs app-side and corrects `streakStart`, not the widget's `now`),
    /// so this input is reachable from Settings in two taps. Unfloored it rendered "Day -399".
    @Test("a clock rolled back before the streak began still floors at Day 1 — never Day 0")
    func test_dayNumber_clockRolledBackBeforeStreakStart_floorsAtDayOne() {
        let start = local(2027, 6, 10, 12, 0, in: newYork)
        for setback in [1, 5, 400] {
            let now = start.addingTimeInterval(-Double(setback) * 86_400)
            let plan = StreakTimelinePlanner().plan(
                reading: SpyReader(state(streakStart: start, generatedAt: start)),
                now: now, horizonDays: 1
            )
            #expect(plan.entries.first?.dayNumber == 1)
        }
    }

    /// Freshness is judged at each entry's RENDER time, not once at plan time. A plan is rendered
    /// across its whole horizon without re-running, so a plan-time verdict would stamp `.fresh` on
    /// a boundary three days out — leaving the flag permanently `.fresh` in exactly the scenario
    /// stale-grace exists to detect (the write path died and nothing refreshes the state).
    @Test("entries far in the plan's future go stale on their own render date")
    func test_staleGrace_isJudgedPerEntry_notOnceAtPlanTime() {
        let start = local(2027, 3, 1, 9, 0, in: newYork)
        let now = local(2027, 3, 2, 15, 0, in: newYork)
        // The state is written NOW — fresh at plan time, by definition.
        let plan = StreakTimelinePlanner().plan(
            reading: SpyReader(state(streakStart: start, generatedAt: now)),
            now: now, horizonDays: 5
        )

        #expect(plan.entries.first?.freshness == .fresh) // renders immediately: fresh
        // ...but the boundaries beyond the 24h grace render from a state that is by then stale.
        let stale = plan.entries.filter { $0.freshness == .staleGrace }
        #expect(!stale.isEmpty)
        for entry in stale {
            #expect(entry.date.timeIntervalSince(now) > StreakTimelinePlanner.defaultGraceWindow)
        }
        // ...and they still carry a live day number and a live ticker: stale-grace shows the
        // last-known streak STILL COUNTING (brandkit item 14), it does not freeze or blank it.
        #expect(stale.allSatisfy { $0.dayNumber != nil && $0.tickWindow != nil })
    }

    /// `refreshAfter` must be a real future rollover, never `now`. With a zero horizon the last
    /// ENTRY is the `now` entry, and asking WidgetKit to reload at an instant already past means
    /// "reload immediately" — a hot loop against the refresh budget (§11).
    @Test("a zero horizon still schedules its renewal at the next real rollover, never at now")
    func test_zeroHorizon_refreshesAtNextRollover_notImmediately() {
        let start = local(2027, 3, 1, 9, 0, in: newYork)
        let now = local(2027, 3, 2, 15, 0, in: newYork)
        let reader = SpyReader(state(streakStart: start, generatedAt: now))

        for horizon in [0, -1] {
            let plan = StreakTimelinePlanner().plan(reading: reader, now: now, horizonDays: horizon)
            #expect(plan.entries.count == 1)
            #expect(plan.refreshAfter == local(2027, 3, 3, in: newYork))
            #expect(plan.refreshAfter != now)
        }
    }

    /// `TimeZone.autoupdatingCurrent` re-binds itself to whatever device reads it — and it SURVIVES
    /// Codable, so a widget-state.json whose bytes say "America/New_York" would decode to Istanbul
    /// on an Istanbul device, silently defeating the travel-immunity the fixed anchor exists for.
    /// The state pins it to a fixed zone at the door.
    @Test("an autoupdating timezone is pinned to a fixed zone on the way in")
    func test_state_pinsAutoupdatingTimeZone_soPersistenceCannotRebindIt() throws {
        let pinned = StreakWidgetState(
            streakStart: epoch, timeZone: .autoupdatingCurrent, generatedAt: epoch
        )
        #expect(pinned.timeZone == TimeZone(identifier: TimeZone.current.identifier))

        // The encoded bytes must not carry the autoupdating flag — that is what re-binds on read.
        let json = try JSONEncoder().encode(
            StreakWidgetState(streakStart: epoch, timeZone: newYork, generatedAt: epoch)
        )
        let text = try #require(String(data: json, encoding: .utf8))
        #expect(!text.contains("autoupdating"))

        // ...and the state round-trips through JSON with its zone intact (the E6.2 feed depends
        // on exactly this).
        let decoded = try JSONDecoder().decode(StreakWidgetState.self, from: json)
        #expect(decoded.timeZone.identifier == "America/New_York")
    }

    /// A DST-less zone is the control: the boundaries are plain 24-hour steps, proving the
    /// Calendar path does not perturb zones that never shift (Europe/Istanbul has been permanent
    /// UTC+3 since 2016 — the app's own TR market).
    @Test("a DST-less zone rolls over on plain 24-hour steps")
    func test_timeline_dstLessZone_rollsOverEvery24Hours() {
        let start = local(2027, 3, 1, 6, 0, in: istanbul)
        let now = local(2027, 3, 13, 6, 0, in: istanbul)
        let reader = SpyReader(state(streakStart: start, timeZone: istanbul, generatedAt: now))

        let plan = StreakTimelinePlanner().plan(reading: reader, now: now, horizonDays: 2)

        let boundaries = Array(plan.entries.dropFirst())
        #expect(boundaries.count == 2)
        if boundaries.count == 2 {
            #expect(boundaries[1].date.timeIntervalSince(boundaries[0].date) == 86_400)
        }
        #expect(boundaries.map(\.dayNumber) == [14, 15])
    }
}
