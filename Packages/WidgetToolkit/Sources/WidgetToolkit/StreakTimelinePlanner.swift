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
        graceWindow: TimeInterval = StreakTimelinePlanner.defaultGraceWindow
    ) -> StreakWidgetTimelinePlan {
        // RED: inert by design (test-suite §7 rule 1 — the failing run is the evidence, and a
        // build failure is not a run). E6.1's green fills this in.
        StreakWidgetTimelinePlan(entries: [], refreshAfter: nil)
    }
}
