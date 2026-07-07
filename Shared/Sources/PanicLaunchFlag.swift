import Foundation

/// The pre-launch signal from the widget-extension `OpenPanicIntent` to the app:
/// the intent sets this flag in App Group `UserDefaults` *before* the app opens, and
/// the app's thin launch path reads it before building the app graph (ADR-6).
///
/// This deliberately avoids any dependency on SwiftData, the network, or SDK init —
/// the panic path must render before all of them (architecture §11 budget table).
enum PanicLaunchFlag {
    /// Key inside the App Group defaults suite. Stable across targets.
    static let key = "panic.launch.requested"

    static func set() {
        // E0.3 red state: not implemented yet — test_panicIntent_setsLaunchFlag_inAppGroupDefaults
        // is expected to fail until the walking-skeleton implementation commit.
    }

    static func isSet() -> Bool {
        false
    }

    static func clear() {
        // Not implemented yet (see set()).
    }
}
