import Foundation
import StreakEngine

/// Device-local persistence for the clock guard's conservative WITNESS — a provable
/// lower bound on elapsed real time, the persisted reading the ADR-7 reboot sanity cap
/// measures from (carried since Session 03; redefined from "last trusted wall reading"
/// to witness semantics in Session 07 — see `QuitRepository.refreshLastKnownGood` for
/// the three advance paths and their bounds).
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

    /// Removes the witness entirely — one-tap erase only (E2.4). A fresh install has
    /// no witness, and a stale one would poison the NEXT tracking era: after an erase
    /// the first created quit re-anchors at the current wall, and the witness chain
    /// re-establishes through the ordinary Session 06/07 advance paths.
    func clear() {
        defaults.removeObject(forKey: Self.defaultsKey)
    }
}
