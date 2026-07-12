import Foundation
import Testing
@testable import WidgetToolkit

// E6.2 — milestone-crossing timeline entries + the decode-side timezone pin.
//
// E6.1 planned entries only at LOCAL MIDNIGHT boundaries (StreakTimelinePlannerTests). A
// medium widget also shows a milestone bar/count, which changes at a milestone crossing that
// may fall at ANY hour — mid-afternoon, or next to a DST discontinuity — not just at midnight.
// So E6.2 grows `plan(...)` a `milestones: [Date]` param: caller-computed crossing instants,
// interleaved and de-duplicated with the midnight boundaries and folded into `refreshAfter`, so
// an entry EXISTS at each crossing and the template re-renders there. The entries carry no
// milestone DATA (the template computes the bar from the DTO at `entry.date` — step-0 R1/R4):
// this file only pins WHERE the entries land and WHEN the timeline refills.
//
// Every fixture instant below was derived with a scratch Foundation harness against the Linux tz
// database BEFORE it was written down (the Session 20 practice) — the DST-adjacent epochs are
// additionally pinned as literals, exactly as the neighbor's spring-forward test does.

private let newYork = TimeZone(identifier: "America/New_York")!
/// Springs forward AT midnight (2027-09-05: 00:00 → 01:00): local 00:00 does not exist, so the
/// day boundary lands at 01:00 -03. The zone that proves a crossing is placed at its exact epoch
/// even when the surrounding midnight is DST-shifted.
private let santiago = TimeZone(identifier: "America/Santiago")!

/// A wall-clock instant, spelled as a local date in a named zone — fixtures read as the user
/// experiences them, never as opaque epoch integers (matches StreakTimelinePlannerTests).
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

/// A read-only seam spy (copied from StreakTimelinePlannerTests): proves BY TYPE the planner
/// cannot write, and records how often it read.
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

@Suite("E6.2 milestone-crossing timeline entries")
struct StreakMilestoneCrossingTests {

    // MARK: - P1: crossings land at their exact instants

    /// A caller-computed milestone crossing at an ordinary afternoon hour — nowhere near a
    /// midnight — must produce an entry AT that exact instant, so the medium's milestone bar
    /// refreshes when the milestone is actually crossed, not at the following midnight.
    @Test("a mid-day milestone crossing produces an entry at that exact instant")
    func test_milestoneCrossing_midDayNewYork_producesEntryAtExactInstant() {
        let start = local(2027, 3, 1, 22, 40, in: newYork) // Day 1
        let now = local(2027, 3, 2, 9, 0, in: newYork)     // Day 2 morning
        let reader = SpyReader(state(streakStart: start, generatedAt: now))

        // 14:30 local on Day 3 — between the 03-03 and 03-04 midnights, on no boundary.
        let crossing = local(2027, 3, 3, 14, 30, in: newYork)
        let plan = StreakTimelinePlanner().plan(
            reading: reader, now: now, horizonDays: 3, milestones: [crossing]
        )

        let crossingEntry = plan.entries.first { $0.date == crossing }
        #expect(crossingEntry != nil) // the crossing produced an entry at all
        // ...at its exact epoch (2027-03-03 14:30 EST), not snapped to a midnight.
        #expect(crossingEntry?.date == Date(timeIntervalSince1970: 1_804_102_200))
        #expect(crossingEntry?.kind == .streak)
        #expect(crossingEntry?.dayNumber == 3)
        // It sits inside Day 3's local window, so the template's ticker still spans the whole day.
        #expect(
            crossingEntry?.tickWindow
                == local(2027, 3, 3, in: newYork)...local(2027, 3, 4, in: newYork)
        )
    }

    /// Santiago springs forward 2027-09-05 00:00 → 01:00, so local 00:00 does not exist and the
    /// day boundary is DST-shifted to 01:00 -03. A caller-computed crossing at 02:00 — one real
    /// hour past that boundary — must be placed at its TRUE epoch, never collapsed onto the shifted
    /// midnight and never shifted by the missing hour. Found via a DST-boundary probe, like the
    /// neighbor's spring-forward day-boundary test.
    @Test("a milestone crossing next to a spring-forward midnight lands at its exact instant")
    func test_milestoneCrossing_adjacentToSantiagoSpringForwardMidnight_exactInstant() {
        let start = local(2027, 9, 1, 10, 0, in: santiago) // Day 1
        let now = local(2027, 9, 4, 12, 0, in: santiago)   // Day 4
        let reader = SpyReader(state(streakStart: start, timeZone: santiago, generatedAt: now))

        let boundary = local(2027, 9, 5, 1, 0, in: santiago) // the DST-shifted day boundary (01:00)
        let crossing = local(2027, 9, 5, 2, 0, in: santiago) // one real hour later
        let plan = StreakTimelinePlanner().plan(
            reading: reader, now: now, horizonDays: 3, milestones: [crossing]
        )

        let crossingEntry = plan.entries.first { $0.date == crossing }
        #expect(crossingEntry != nil)
        // Exactly 2027-09-05 02:00 -03 — the real epoch, not the DST-shifted midnight's.
        #expect(crossingEntry?.date == Date(timeIntervalSince1970: 1_820_120_400))
        #expect(crossingEntry?.date != boundary) // distinct from the 01:00 boundary, not snapped
        #expect(crossingEntry?.dayNumber == 5)
    }

    // MARK: - P2: a crossing on a boundary is one entry, not two

    /// When a milestone crossing coincides EXACTLY with a midnight boundary the two must fuse into
    /// a single entry — a naive interleave that appends the crossing unconditionally would render
    /// the same instant twice (wasting a timeline slot and confusing `refreshAfter`). A distinct
    /// mid-day crossing rides along to prove the crossings were actually honored, not merely dropped.
    @Test("a milestone crossing that coincides with a midnight boundary is not double-counted")
    func test_milestoneCrossing_onMidnightBoundary_producesOneEntryNotTwo() {
        let start = local(2027, 3, 1, 12, 0, in: newYork) // Day 1
        let now = local(2027, 3, 2, 12, 0, in: newYork)   // Day 2
        let reader = SpyReader(state(streakStart: start, generatedAt: now))

        let midnight = local(2027, 3, 3, in: newYork)       // a real day boundary in the horizon
        let midDay = local(2027, 3, 3, 14, 0, in: newYork)  // a distinct mid-day crossing
        let plan = StreakTimelinePlanner().plan(
            reading: reader, now: now, horizonDays: 2,
            milestones: [midnight, midDay] // one ON the boundary, one between boundaries
        )

        // The crossing that lands ON the 03-03 boundary must NOT create a second entry there.
        #expect(plan.entries.filter { $0.date == midnight }.count == 1)
        // ...and the whole set is exactly now + both midnights + the one mid-day crossing, in order.
        #expect(plan.entries.map(\.date) == [
            now,
            midnight,
            midDay,
            local(2027, 3, 4, in: newYork),
        ])
    }

    // MARK: - P3: a crossing past the horizon becomes the refresh point

    /// `refreshAfter` is the LAST planned boundary so the timeline refills itself. A milestone
    /// crossing that falls AFTER the last midnight in the horizon extends that boundary — the
    /// timeline must come back at the crossing, not at the earlier midnight, and (the E6.1 rule)
    /// never at `now`, which would mean "reload immediately" and burn the refresh budget.
    @Test("a milestone crossing beyond the last midnight becomes the refresh point, never now")
    func test_milestoneCrossing_beyondLastMidnight_setsRefreshAfterToTheCrossing() {
        let start = local(2027, 3, 1, 12, 0, in: newYork)
        let now = local(2027, 3, 2, 12, 0, in: newYork)
        let reader = SpyReader(state(streakStart: start, generatedAt: now))

        // Horizon 2 plans midnights 03-03 and 03-04 (the last). The crossing sits AFTER 03-04 00:00.
        let lastMidnight = local(2027, 3, 4, in: newYork)
        let crossing = local(2027, 3, 4, 15, 0, in: newYork)
        let plan = StreakTimelinePlanner().plan(
            reading: reader, now: now, horizonDays: 2, milestones: [crossing]
        )

        #expect(plan.refreshAfter == crossing)      // refill at the crossing, the last boundary
        #expect(plan.refreshAfter != lastMidnight)  // not the earlier last midnight
        #expect(plan.refreshAfter != now)           // and never `now` — the hot-loop rule holds
        #expect(plan.entries.last?.date == crossing) // an entry exists there to be rendered
    }

    // MARK: - P4: the empty default is behavior-preserving (born-green regression companion)

    /// The new `milestones:` param defaults to `[]`, and an empty list must leave the plan bit-for-bit
    /// identical to the pre-param plan — no phantom entries, same `refreshAfter`. Green-from-birth:
    /// on the red commit the param is inert so this already holds; it exists to keep the empty path
    /// pinned once green starts interleaving crossings.
    @Test("empty milestones leave the plan identical to the pre-param plan")
    func test_emptyMilestones_planIdenticalToBaseline() {
        let start = local(2027, 3, 1, 12, 0, in: newYork)
        let now = local(2027, 3, 2, 12, 0, in: newYork)

        let baseline = StreakTimelinePlanner().plan(
            reading: SpyReader(state(streakStart: start, generatedAt: now)),
            now: now, horizonDays: 4 // default milestones
        )
        let withEmpty = StreakTimelinePlanner().plan(
            reading: SpyReader(state(streakStart: start, generatedAt: now)),
            now: now, horizonDays: 4, milestones: []
        )

        #expect(withEmpty == baseline)
        // ...and it is exactly the pre-param shape: now + four midnights, refill at the last one.
        #expect(withEmpty.entries.count == 5)
        #expect(withEmpty.entries.last?.date == local(2027, 3, 6, in: newYork))
        #expect(withEmpty.refreshAfter == withEmpty.entries.last?.date)
    }
}

@Suite("E6.2 widget-state decode timezone pin")
struct StreakWidgetStateDecodePinTests {

    // MARK: - P5: the decode door re-pins the timezone

    /// The memberwise `init` pins `TimeZone.autoupdatingCurrent` to a fixed zone, but Codable's
    /// SYNTHESIZED `init(from:)` decodes the timezone straight from JSON and BYPASSES that pin —
    /// and the `autoupdating` flag SURVIVES Codable (reproduced against the shipping type on Linux:
    /// `{"identifier":"Europe/Berlin","autoupdating":true}` decodes back to `.autoupdatingCurrent`).
    /// So a widget-state.json written by any future producer that skips the guarding init would
    /// decode to the DEVICE's current zone on read, silently defeating the travel-immunity the whole
    /// type exists to provide. The decode door must re-pin too (an explicit `init(from:)` routing
    /// through the identifier). Expected RED on the current type (synthesized decode).
    @Test("decoding a state whose bytes carry an autoupdating flag still yields a fixed zone")
    func test_decode_autoupdatingTimeZoneInBytes_yieldsFixedZone_notDeviceCurrent() throws {
        // Bytes an unguarded producer could write: the identifier names Berlin, but the
        // `autoupdating` flag makes a synthesized decoder re-bind the zone to whatever reads it.
        let json = #"{"streakStart":0,"timeZone":{"identifier":"Europe/Berlin","autoupdating":true},"generatedAt":0}"#
        let decoded = try JSONDecoder().decode(
            StreakWidgetState.self, from: #require(json.data(using: .utf8))
        )

        // The decoded zone must be a FIXED zone, never the autoupdating singleton that re-binds on
        // read. (`fixed == .autoupdatingCurrent` is always false and `autoupdating ==
        // .autoupdatingCurrent` always true, so this distinguishes them on ANY device's tz.)
        #expect(decoded.timeZone != TimeZone.autoupdatingCurrent)
        // ...and it is exactly the zone the bytes named, pinned to a stable identifier.
        #expect(decoded.timeZone == TimeZone(identifier: "Europe/Berlin"))
    }
}
