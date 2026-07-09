import Darwin
import Foundation
import StreakEngine

/// Production `ClockProviding` conformance — THE one sanctioned reader of the wall
/// clock and monotonic evidence (test-suite §3.1: `Date()`/`ProcessInfo` are banned in
/// production code; every consumer goes through the seam, and this conformance is the
/// single place the seam touches the real clocks).
///
/// API choices (resume-prompt v2.0 item 1):
///  - uptime = `mach_continuous_time()`, which keeps counting across device SLEEP —
///    the engine's documented contract. `ProcessInfo.systemUptime`/`mach_absolute_time`
///    pause during sleep, so an overnight doze would read as a forward wall jump and
///    freeze honest streaks (banned for that reason, not just style).
///  - bootID = the `kern.bootsessionuuid` sysctl, a per-boot UUID the guard compares
///    for equality (uptimes are only comparable within one boot session).
/// This file never compiles on the Linux dev box (app-target code builds in CI only);
/// `swiftc -parse` needs no `#if` guards because parsing resolves no imports/symbols.
@MainActor
struct LiveClock: ClockProviding {
    /// Read once per instance: the boot session cannot change under a live process
    /// (a reboot kills it), so re-reading the sysctl per tick would buy nothing.
    private let bootID = LiveClock.readBootSessionUUID()

    var now: Date { Date() }

    var monotonicNow: MonotonicNow {
        MonotonicNow(bootID: bootID, uptime: Self.continuousUptimeSeconds())
    }

    /// Sleep-inclusive seconds since boot. Overflow headroom: at the arm64 timebase
    /// (125/3, 24 MHz ticks) the numerator would need ~190 years of uptime to wrap.
    private static func continuousUptimeSeconds() -> TimeInterval {
        var timebase = mach_timebase_info_data_t()
        mach_timebase_info(&timebase)
        let nanoseconds = mach_continuous_time() * UInt64(timebase.numer) / UInt64(timebase.denom)
        return TimeInterval(nanoseconds) / 1_000_000_000
    }

    /// Falls back to a fresh random UUID when the sysctl is unreadable (never observed
    /// on iOS): the guard then treats the reading as a foreign boot and takes the
    /// wall-sanity path with the ADR-7 cap — conservative (freeze-not-inflate), never
    /// an inflation channel, consistent with the witness discipline.
    private static func readBootSessionUUID() -> UUID {
        var size = 0
        guard sysctlbyname("kern.bootsessionuuid", nil, &size, nil, 0) == 0, size > 0 else {
            return UUID()
        }
        var buffer = [UInt8](repeating: 0, count: size)
        guard sysctlbyname("kern.bootsessionuuid", &buffer, &size, nil, 0) == 0 else {
            return UUID()
        }
        // The sysctl returns a NUL-terminated C string; decode up to the terminator
        // (String(cString:) is deprecated under the current SDK's warnings-as-errors).
        let text = String(decoding: buffer.prefix(while: { $0 != 0 }), as: UTF8.self)
        return UUID(uuidString: text) ?? UUID()
    }
}
