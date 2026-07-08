import Foundation

// E1.3 — slip archiving, momentum preservation, 10-minute undo. Pure value-in/value-out
// transitions over `QuitSnapshot`; time is always injected (`at:` + optional monotonic
// evidence), never read. Separate file from StreakCalculator.swift so each computation
// file carries its own 100%-branch bar.
extension StreakCalculator {

    /// The undo window (implementation-plan E1.3 / MVP feature #6): a slip is reversible
    /// for exactly this many seconds after it is applied, boundary-inclusive.
    public static let undoWindowSeconds = 600

    /// Archives the current streak into `bestStreakSeconds`, banks its clean time into
    /// `priorCleanSeconds` (cumulative totals are preserved — the momentum numerator and
    /// denominator both carry across the slip unchanged in the same tick), restarts the
    /// counter at `now`, and records the undo bookkeeping.
    public static func applySlip(
        to quit: QuitSnapshot,
        at now: Date,
        monotonic: MonotonicNow? = nil
    ) -> QuitSnapshot {
        // Sentinel (red): archives nothing, banks nothing, forgets the history.
        QuitSnapshot(startAt: now)
    }

    /// Restores the exact pre-slip state while the undo window is open; `nil` once it has
    /// closed (or when there is no slip pending). The window measures injected time only.
    public static func undoSlip(
        on quit: QuitSnapshot,
        at now: Date,
        monotonic: MonotonicNow? = nil
    ) -> QuitSnapshot? {
        // Sentinel (red): never restores, never expires.
        quit
    }

    /// Pure detector behind the §9 rule-3 debug assertion: names every append-only
    /// invariant a slip transition would violate. `applySlip` asserts it returns empty.
    static func appendOnlyViolations(from old: QuitSnapshot, to new: QuitSnapshot) -> [String] {
        // Sentinel (red): cries wolf, names nothing.
        ["sentinel: not yet implemented"]
    }
}
