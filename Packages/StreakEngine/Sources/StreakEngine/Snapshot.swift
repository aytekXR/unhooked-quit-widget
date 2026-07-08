import Foundation

/// The minimal, domain-neutral inputs the engine needs — no habit category, motivations,
/// labels, or currency codes (those live in the consuming app's richer DTO, which maps onto
/// this at the call site; architecture §14: Vigil/Vakit/Keeper consume this unchanged).
/// Hand-written public init with every non-essential field defaulted, so later epics can
/// add trailing defaulted fields without breaking any call site.
public struct QuitSnapshot: Sendable, Equatable, Hashable, Codable {
    /// Wall-clock start of the CURRENT streak; basis for elapsed days/hours.
    public var startAt: Date
    /// Wall-clock start of ALL tracking (never reset by a slip); the momentum denominator.
    /// Defaults to `startAt` for a fresh, never-slipped goal.
    public var trackedSince: Date
    /// Spend per 7 days for money-saved math. 0 allowed (free habits, Reduce mode,
    /// money-less consumers such as a prayer-streak app).
    public var weeklySpend: Decimal
    /// Clean seconds banked in PRIOR streaks (before `startAt`); the cumulative numerator
    /// base for momentum/money. 0 for a fresh goal; E1.3 populates it on slip archiving.
    public var priorCleanSeconds: Int
    /// Persisted anchor for the E1.2 clock guard. `nil` ⇒ guard disabled ⇒ pure wall-clock.
    /// Captured at the CURRENT streak's start: its `wallClock` is expected to equal
    /// `startAt` (the guard measures elapsed from the anchor, not from `startAt`).
    public var monotonicAnchor: MonotonicAnchor?

    public init(
        startAt: Date,
        trackedSince: Date? = nil,
        weeklySpend: Decimal = 0,
        priorCleanSeconds: Int = 0,
        monotonicAnchor: MonotonicAnchor? = nil
    ) {
        self.startAt = startAt
        self.trackedSince = trackedSince ?? startAt
        self.weeklySpend = weeklySpend
        self.priorCleanSeconds = priorCleanSeconds
        self.monotonicAnchor = monotonicAnchor
    }
}

/// One milestone entry. Codable because consumers load these from bundled, versioned JSON
/// (ADR-9) and hand the decoded table to the engine.
public struct Milestone: Sendable, Equatable, Hashable, Codable {
    /// Hours since the current streak's start at which this milestone is reached.
    public var afterHours: Int
    public var title: String
    public var body: String

    public init(afterHours: Int, title: String, body: String) {
        self.afterHours = afterHours
        self.title = title
        self.body = body
    }
}

/// A milestone table for one context. `category` is a neutral lookup label only — the
/// engine never branches on it. Defaulted so fixtures need not supply it.
public struct MilestoneTable: Sendable, Equatable, Hashable, Codable {
    public var category: String
    public var milestones: [Milestone]

    public static let empty = MilestoneTable(milestones: [])

    public init(category: String = "", milestones: [Milestone]) {
        self.category = category
        self.milestones = milestones
    }
}
