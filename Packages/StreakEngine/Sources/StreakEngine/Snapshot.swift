import Foundation

/// The minimal, domain-neutral inputs the engine needs — no habit category, motivations,
/// labels, or currency codes (those live in the consuming app's richer model, which maps
/// onto this at the call site, so any streak-tracking consumer uses it unchanged).
/// Hand-written public init with every non-essential field defaulted, so later versions
/// can add trailing defaulted fields without breaking any call site.
public struct StreakSnapshot: Sendable, Equatable, Hashable, Codable {
    /// Wall-clock start of the CURRENT streak; basis for elapsed days/hours.
    public var startAt: Date
    /// Wall-clock start of ALL tracking (never reset by a slip); the momentum denominator.
    /// Defaults to `startAt` for a fresh, never-slipped goal.
    public var trackedSince: Date
    /// Spend per 7 days for money-saved math. 0 allowed (free habits, allowance-mode
    /// goals, money-less consumers such as a prayer-streak app).
    public var weeklySpend: Decimal
    /// Clean seconds banked in PRIOR streaks (before `startAt`); the cumulative numerator
    /// base for momentum/money. 0 for a fresh goal; `applySlip` banks into it on archiving.
    public var priorCleanSeconds: Int
    /// Persisted anchor for the clock-integrity guard. `nil` ⇒ guard off ⇒ pure wall-clock.
    /// Captured at the CURRENT streak's start: its `wallClock` is expected to equal
    /// `startAt` (the guard measures elapsed from the anchor, not from `startAt`).
    public var monotonicAnchor: MonotonicAnchor?
    /// Longest COMPLETED (archived) streak, in seconds — populated by `applySlip`.
    /// Append-only: no engine operation except a sanctioned `undoSlip` may lower it. The
    /// live current streak can exceed it; it is archived on the next slip.
    public var bestStreakSeconds: Int
    /// Bookkeeping for the 10-minute slip undo. Non-nil while the most recent slip is
    /// still reversible; `undoSlip` consumes it, a newer slip replaces (finalizes) it.
    public var pendingUndo: PendingSlipUndo?

    public init(
        startAt: Date,
        trackedSince: Date? = nil,
        weeklySpend: Decimal = 0,
        priorCleanSeconds: Int = 0,
        monotonicAnchor: MonotonicAnchor? = nil,
        bestStreakSeconds: Int = 0,
        pendingUndo: PendingSlipUndo? = nil
    ) {
        self.startAt = startAt
        self.trackedSince = trackedSince ?? startAt
        self.weeklySpend = weeklySpend
        self.priorCleanSeconds = priorCleanSeconds
        self.monotonicAnchor = monotonicAnchor
        self.bestStreakSeconds = bestStreakSeconds
        self.pendingUndo = pendingUndo
    }
}

/// The exact pre-slip values `applySlip` overwrites, kept so `undoSlip` can restore them
/// deterministically within the window — undo restores recorded values, it never
/// reconstructs them ("undo, not delete-then-restore").
/// Only fields the slip mutates are recorded — `trackedSince`/`weeklySpend` never change.
public struct PendingSlipUndo: Sendable, Equatable, Hashable, Codable {
    public var priorStartAt: Date
    public var priorCleanSeconds: Int
    public var priorBestStreakSeconds: Int
    public var priorMonotonicAnchor: MonotonicAnchor?

    public init(
        priorStartAt: Date,
        priorCleanSeconds: Int,
        priorBestStreakSeconds: Int,
        priorMonotonicAnchor: MonotonicAnchor? = nil
    ) {
        self.priorStartAt = priorStartAt
        self.priorCleanSeconds = priorCleanSeconds
        self.priorBestStreakSeconds = priorBestStreakSeconds
        self.priorMonotonicAnchor = priorMonotonicAnchor
    }
}

/// One milestone entry. Codable because consumers load these from bundled, versioned JSON
/// and hand the decoded table to the engine.
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
