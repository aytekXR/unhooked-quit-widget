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
        guard let data = defaults.data(forKey: Self.defaultsKey) else { return nil }
        return try? JSONDecoder().decode(MonotonicAnchor.self, from: data)
    }

    func save(_ reading: MonotonicAnchor) {
        guard let data = try? JSONEncoder().encode(reading) else { return }
        defaults.set(data, forKey: Self.defaultsKey)
    }
}
