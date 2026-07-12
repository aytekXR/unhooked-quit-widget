import Foundation

/// One rendered moment of a streak widget. Deliberately string-free: E6.1 ships rollover/stale
/// LOGIC (implementation-plan acceptance: "only templates live in the app"), so the entry carries
/// numbers and windows, never copy. The family templates that turn `dayNumber` into "Day 34" and
/// `tickWindow` into `Text(timerInterval:)` are E6.2's, and the discreet variants E6.3's.
public struct StreakWidgetEntry: Sendable, Equatable, Hashable {
    /// What this entry is able to say. `unavailable` exists because a nil read must still produce
    /// ONE entry: WidgetKit does not fall back to `placeholder(in:)` on an empty timeline — it
    /// keeps the last rendered pixels, so an empty array after an erase would leave the erased
    /// streak on the lock screen, still ticking.
    public enum Kind: Sendable, Equatable, Hashable {
        case streak
        case unavailable
    }

    /// How current the underlying state is. A flag, never a caption: a stale widget is a
    /// silent-recover condition (architecture §9 — "Never surface"), and §11 accepts staleness
    /// of ≤60s as normal. The last-known value keeps ticking regardless (brandkit item 14).
    public enum Freshness: Sendable, Equatable, Hashable {
        case fresh
        case staleGrace
    }

    /// When WidgetKit should render this entry.
    public var date: Date
    public var kind: Kind
    /// 1-based calendar day of the streak, in the quit's fixed timezone. `nil` iff `unavailable`
    /// — an absent state renders no number at all, never a fabricated "Day 0".
    public var dayNumber: Int?
    /// The local day this entry sits in, as a closed range — the exact interval a template hands
    /// to `Text(timerInterval:)`. `nil` iff `unavailable` (an empty state must not tick). On a
    /// DST day this window is genuinely 23 or 25 hours long, which is the point.
    public var tickWindow: ClosedRange<Date>?
    public var freshness: Freshness

    public init(
        date: Date,
        kind: Kind,
        dayNumber: Int?,
        tickWindow: ClosedRange<Date>?,
        freshness: Freshness
    ) {
        self.date = date
        self.kind = kind
        self.dayNumber = dayNumber
        self.tickWindow = tickWindow
        self.freshness = freshness
    }
}

/// A planned timeline: the entries plus the instant WidgetKit should come back for more.
public struct StreakWidgetTimelinePlan: Sendable, Equatable, Hashable {
    public var entries: [StreakWidgetEntry]
    /// The refill point — the last boundary planned, so the timeline renews itself without a
    /// write. (The push-based `reloadTimelines` on every write is the FRESHNESS path, §11; this
    /// is the ROLLOVER path, and the two are independent.)
    public var refreshAfter: Date?

    public init(entries: [StreakWidgetEntry], refreshAfter: Date?) {
        self.entries = entries
        self.refreshAfter = refreshAfter
    }
}

/// E6.1's core: a stateless, pure planner. Reads the widget state through a read-only seam, and
/// turns it into entries at LOCAL MIDNIGHT boundaries in the quit's fixed timezone.
///
/// Foundation-only BY RULE — no WidgetKit, no SwiftUI, no StreakEngine. That is what keeps the
/// `package-units` CI lane on the free ubuntu runner (a WidgetKit import would force it onto the
/// macOS runner at 10x). `Calendar`/`TimeZone` are Foundation and Linux carries the real tz
/// database, so DST is testable for free.
///
/// The planner reads NO clock: `now` is injected, exactly as StreakEngine's core takes its
/// readings from the consumer (test-suite §3.1 — the clock is the most important seam in this
/// product).
public struct StreakTimelinePlanner: Sendable {
    /// How long a state may go unrefreshed before its entries are flagged `.staleGrace`.
    /// Generous on purpose: §11's freshness promise is ≤60s via push reload, so a state older
    /// than a full day means the push path failed — a silent-recover condition, not a user error.
    public static let defaultGraceWindow: TimeInterval = 86_400

    public init() {}

    public func plan(
        reading reader: some StreakWidgetStateReading,
        now: Date,
        horizonDays: Int,
        milestones: [Date] = [],
        graceWindow: TimeInterval = StreakTimelinePlanner.defaultGraceWindow
    ) -> StreakWidgetTimelinePlan {
        // Exactly one read per plan — the seam is a file read in production, and a re-entrant
        // read could observe a half-written state mid-rebuild.
        guard let state = reader.read() else {
            // No state on disk (fresh install, or post-erase: the owned App Group file is
            // ABSENT). ONE entry, never an empty timeline — WidgetKit does not fall back to
            // `placeholder(in:)` when a timeline has no entries; it keeps the last rendered
            // pixels. An empty array after an erase would strand the erased streak on the lock
            // screen, still ticking. No ticker, and no day number: never a fabricated "Day 0".
            return StreakWidgetTimelinePlan(
                entries: [
                    StreakWidgetEntry(
                        date: now,
                        kind: .unavailable,
                        dayNumber: nil,
                        tickWindow: nil,
                        freshness: .fresh
                    )
                ],
                refreshAfter: nil
            )
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = state.timeZone // the quit's zone, never the device's

        // The entry that renders immediately, then one per local midnight across the horizon.
        // `nextDate(after:matching:)` walks the real calendar, so a 23-hour spring-forward day
        // ends at the user's true midnight — an implementation that added 86_400 seconds would
        // roll the day over an hour late (pinned in test_timeline_dstSpringForward_dayBoundaryCorrect).
        var entries = [entry(at: now, state: state, calendar: calendar, graceWindow: graceWindow)]
        var boundaries: [Date] = []
        var cursor = now
        for _ in 0..<max(0, horizonDays) {
            guard let midnight = calendar.nextDate(
                after: cursor,
                matching: DateComponents(hour: 0, minute: 0, second: 0),
                matchingPolicy: .nextTime,
                repeatedTimePolicy: .first,
                direction: .forward
            ) else { break }
            entries.append(
                entry(at: midnight, state: state, calendar: calendar, graceWindow: graceWindow)
            )
            boundaries.append(midnight)
            cursor = midnight
        }

        // Come back at the last BOUNDARY planned, so the timeline refills itself without a write.
        // Never `entries.last` — with a zero horizon that is the `now` entry, and asking WidgetKit
        // to reload at a moment already past means "reload immediately", burning the refresh budget
        // (§11) in a hot loop. With no boundary planned, fall back to the next real rollover so the
        // timeline still renews when the day actually turns.
        // (The push-based reload on every write is the FRESHNESS path, §11 — independent of this.)
        let renewal = boundaries.last ?? calendar.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime,
            repeatedTimePolicy: .first,
            direction: .forward
        )
        return StreakWidgetTimelinePlan(entries: entries, refreshAfter: renewal)
    }

    /// One entry: the day number and the local-day ticker window at `date`.
    private func entry(
        at date: Date,
        state: StreakWidgetState,
        calendar: Calendar,
        graceWindow: TimeInterval
    ) -> StreakWidgetEntry {
        // Freshness is judged at the moment the entry RENDERS, not at the moment the plan was
        // built. A plan is written once and then rendered for its whole horizon without re-running
        // (WidgetKit only comes back at `refreshAfter`), so stamping one plan-time verdict on
        // every entry would mark a boundary three days out as `.fresh` even as it renders from a
        // state three days stale — leaving the flag permanently `.fresh` in exactly the scenario
        // it exists to detect: the write path died and nothing is refreshing the state.
        let freshness: StreakWidgetEntry.Freshness =
            date.timeIntervalSince(state.generatedAt) > graceWindow ? .staleGrace : .fresh
        let dayStart = calendar.startOfDay(for: date)
        // The day the user quits is Day 1, from its first second — so the count is the number of
        // local days crossed, plus one. (test-suite §1 item 13 bans "back to day 1" as shame
        // copy, which presupposes the reset day IS Day 1.)
        let daysCrossed = daysBetween(state.streakStart, and: date, calendar: calendar)

        // The window a template hands to `Text(timerInterval:)`. It is the REAL local day, so on
        // a DST day it is genuinely 23 or 25 hours long — which is what keeps the ticker in step
        // with the wall clock the user is looking at.
        let nextMidnight = calendar.nextDate(
            after: dayStart,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime,
            repeatedTimePolicy: .first,
            direction: .forward
        )

        return StreakWidgetEntry(
            date: date,
            kind: .streak,
            // Floored at Day 1. The widget's `now` is the raw device clock and the widget runs no
            // clock-integrity guard of its own (ADR-6 — the guard runs app-side, and it corrects
            // `streakStart`, not the widget's `now`), so a user who sets their date backwards
            // hands this function a `now` BEFORE the streak began. Unfloored, that renders
            // "Day 0" or "Day -399" — the very fabrication `Kind.unavailable` exists to prevent.
            // Flooring is also the honest direction: a streak can never read as less than its
            // first day (ADR-7's freeze-not-inflate discipline, applied to the display side).
            dayNumber: max(1, daysCrossed + 1),
            tickWindow: nextMidnight.map { dayStart...$0 },
            freshness: freshness
        )
    }

    /// Whole local days between two instants — counted by anchoring each to NOON of its own
    /// calendar day and differencing those.
    ///
    /// The two obvious spellings are both wrong, and each was caught by an empirical probe rather
    /// than by reasoning:
    /// - `dateComponents([.day], from: startOfDay(a), to: startOfDay(b))` measures whole-day
    ///   DURATIONS. In zones that spring forward AT midnight (America/Santiago 2027-09-05,
    ///   America/Havana), local 00:00 does not exist and `startOfDay` yields 01:00 — so a user who
    ///   quit on such a day is measured from a 01:00 origin, falls an hour short of every later
    ///   day boundary, and reads ONE DAY LOW FOREVER.
    /// - `ordinality(of: .day, in: .era, ...)` returns the PREVIOUS day's ordinal when handed an
    ///   exact-midnight instant on Linux Foundation — and every boundary entry is exactly that.
    ///
    /// Noon is the fixed point that survives both: it exists on every date in every zone (no DST
    /// shift comes close to 12 hours) and it is never a boundary instant. Verified across
    /// New York, Santiago, Havana, Lord Howe (30-min shift), Istanbul (no DST), Kiritimati
    /// (UTC+14) and Chatham (UTC+12:45) — 400 consecutive day boundaries each, zero breaks.
    private func daysBetween(_ start: Date, and end: Date, calendar: Calendar) -> Int {
        func noon(of date: Date) -> Date? {
            let day = calendar.dateComponents([.year, .month, .day], from: date)
            return calendar.date(
                from: DateComponents(year: day.year, month: day.month, day: day.day, hour: 12)
            )
        }
        guard let startNoon = noon(of: start), let endNoon = noon(of: end) else { return 0 }
        return calendar.dateComponents([.day], from: startNoon, to: endNoon).day ?? 0
    }
}
