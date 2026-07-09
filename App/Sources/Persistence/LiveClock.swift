import Foundation
import StreakEngine

/// Production `ClockProviding` conformance — THE one sanctioned reader of the wall
/// clock and monotonic evidence (test-suite §3.1: `Date()`/`ProcessInfo` are banned in
/// production code; every consumer goes through the seam, and this conformance is the
/// single place the seam touches the real clocks).
///
/// E3.1 RED SKELETON: returns sentinel readings that fail every clock assertion by
/// design (pass-from-birth discipline). The real readers — `mach_continuous_time`
/// (sleep-INCLUSIVE uptime, the engine's documented contract) and the
/// `kern.bootsessionuuid` sysctl (per-boot session UUID) — are the green step.
@MainActor
struct LiveClock: ClockProviding {
    var now: Date { .distantPast }

    var monotonicNow: MonotonicNow {
        MonotonicNow(bootID: UUID(), uptime: -1)
    }
}
