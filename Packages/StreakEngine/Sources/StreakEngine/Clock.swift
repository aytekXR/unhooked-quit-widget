import Foundation

// The time seam (E1's most important design act — ADR-7, test-suite §3.1).
// The engine NEVER reads a clock: `Date()` and `ProcessInfo.systemUptime` are banned in
// package code. Consumers capture these values (their `ClockProvider` per test-suite §3.1
// lives app/test-side — it PRODUCES readings; the pure core only consumes them).

/// The monotonic anchor captured when a streak starts and persisted with it (architecture
/// §9 rule 4 / ADR-7: boot session ID + system uptime + wall clock at anchor). The engine
/// only ever consumes it; the consumer records all three at one instant.
public struct MonotonicAnchor: Sendable, Equatable, Hashable, Codable {
    /// Boot session the anchor was taken in. Compared for EQUALITY only: readings whose
    /// `bootID`s differ straddle a reboot, so their uptimes are not comparable (the E1.2
    /// guard falls back to wall-clock sanity). The engine never mints one.
    public var bootID: UUID
    /// System uptime at anchor time — seconds since boot, monotonic, immune to wall-clock
    /// edits. `TimeInterval` (not `Duration`): Codable-clean for the CloudKit anchor blob
    /// and homogeneous with `Date` deltas, so wall-vs-monotonic compares are conversion-free.
    public var uptime: TimeInterval
    /// Absolute wall clock at anchor time — the past reference the guard cross-checks.
    public var wallClock: Date

    public init(bootID: UUID, uptime: TimeInterval, wallClock: Date) {
        self.bootID = bootID
        self.uptime = uptime
        self.wallClock = wallClock
    }
}

/// Read-time monotonic evidence, supplied alongside the plain `now: Date`. It carries no
/// wall clock of its own — `now` IS the wall clock; this is only the tamper-resistant
/// uptime cross-check the E1.2 guard needs. Omitted (`nil`) in E1.1, so no guard runs.
public struct MonotonicNow: Sendable, Equatable, Hashable, Codable {
    public var bootID: UUID
    public var uptime: TimeInterval

    public init(bootID: UUID, uptime: TimeInterval) {
        self.bootID = bootID
        self.uptime = uptime
    }
}

/// Clock-integrity verdict. Defined now as a seam type so `StreakValue.clockSanity` exists
/// from E1.1 and the E1.2 guard populates it with zero struct churn. Cases named by
/// implementation-plan E1.2. Always `.normal` until the guard lands.
public enum ClockSanity: String, Sendable, Equatable, Hashable, Codable, CaseIterable {
    case normal
    case clockRolledBack
    case timezoneShift
}
