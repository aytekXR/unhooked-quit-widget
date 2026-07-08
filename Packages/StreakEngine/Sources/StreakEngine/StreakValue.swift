import Foundation

/// A fully-derived allowance-adherence readout: how many of the evaluated calendar days
/// stayed at or under the allowance. Derived on demand, never stored — same rule as
/// `StreakValue`, so deliberately not Codable either.
public struct Adherence: Sendable, Equatable, Hashable {
    /// Days whose logged occurrences were at or under the allowance (adherent ≠ abstinent:
    /// a day WITH occurrences still counts — allowance framing, not abstinence framing).
    public let adherentDays: Int
    /// Calendar days evaluated in the window (a DST-transition day counts exactly once).
    public let evaluatedDays: Int

    public init(adherentDays: Int, evaluatedDays: Int) {
        self.adherentDays = adherentDays
        self.evaluatedDays = evaluatedDays
    }
}

/// A fully-derived streak readout — computed on demand, never stored (deliberately not
/// Codable: a persisted derived readout could drift from the inputs it was derived from).
/// `elapsedSeconds` is the single ground truth; `days`/`hours`/`momentumPercent` are
/// computed views so they can never drift from it.
public struct StreakValue: Sendable, Equatable, Hashable {
    /// Current streak length in seconds, clamped >= 0.
    public let elapsedSeconds: Int
    /// Exact, unrounded, >= 0. Rounding scale is currency-specific (USD 2, JPY 0, BHD 3),
    /// so rounding is a presentation concern — the engine stays currency-agnostic.
    public let moneySaved: Decimal
    /// Momentum as a fraction 0...1; see `momentumPercent` for the 0...100 view.
    public let momentum: Double
    public let nextMilestone: Milestone?
    /// The clock-integrity verdict for this read; `.normal` whenever no guard ran.
    public let clockSanity: ClockSanity

    /// Elapsed whole 24-hour blocks (timezone-invariant absolute time: timezone/DST
    /// changes affect display formatting only, never elapsed seconds).
    public var days: Int { elapsedSeconds / 86_400 }
    /// Whole-hour remainder after `days`, 0...23.
    public var hours: Int { (elapsedSeconds % 86_400) / 3_600 }
    /// Momentum as 0...100, for percent-shaped display.
    public var momentumPercent: Double { momentum * 100 }

    public init(
        elapsedSeconds: Int,
        moneySaved: Decimal,
        momentum: Double,
        nextMilestone: Milestone? = nil,
        clockSanity: ClockSanity = .normal
    ) {
        self.elapsedSeconds = max(0, elapsedSeconds)      // streaks never run negative
        self.moneySaved = moneySaved
        self.momentum = min(1.0, max(0.0, momentum))      // fraction stays in 0...1
        self.nextMilestone = nextMilestone
        self.clockSanity = clockSanity
    }
}
