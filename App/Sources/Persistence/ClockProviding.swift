import Foundation
import StreakEngine

/// The one seam through which production code reads time (test-suite §3.1): consumers
/// take readings from a provider, they never call `Date()`/`ProcessInfo` themselves —
/// the conformance is the single sanctioned reader. Main-actor bound like its only
/// consumer (the repository).
@MainActor
protocol ClockProviding {
    /// The wall clock.
    var now: Date { get }
    /// Read-time monotonic evidence for the clock-integrity guard: boot session ID plus
    /// sleep-INCLUSIVE uptime (the engine's documented contract — mach_continuous_time
    /// derived, or device sleep would read as a forward wall jump).
    var monotonicNow: MonotonicNow { get }
}
