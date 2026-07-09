import Foundation
import StreakEngine

/// Device-local persistence for the clock guard's last trusted reading — the persisted
/// wall reading the ADR-7 reboot sanity cap needs (carried since Session 03).
///
/// DELIBERATELY not SwiftData: the single product store is CloudKit-mirrored, and a
/// clock reading is device truth — device A's `bootID`/`uptime`/`wallClock` are garbage
/// on device B, so syncing it would corrupt B's cap baseline (`AppSettings` is mirrored,
/// so it may not live there either). App Group defaults keep it shareable with the
/// widget extension later without ever leaving the device.
@MainActor
final class LastKnownGoodStore {
    static let defaultsKey = "e22.lastKnownGoodReading"

    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    func load() -> MonotonicAnchor? {
        nil // E2.2 red sentinel
    }

    func save(_ reading: MonotonicAnchor) {
        // E2.2 red sentinel
    }
}
