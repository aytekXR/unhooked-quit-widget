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

    /// Selection channel for the panic route (E3.1): which quit the intervention is
    /// for. The widget intent stays parameterless until E3.3 — that epic's per-quit
    /// `@Parameter` (and any later deep link) writes this same key; the app-side
    /// resolver already consumes it.
    static let quitIDKey = "panic.launch.quitID"

    private static var groupDefaults: UserDefaults? {
        UserDefaults(suiteName: AppIdentifiers.appGroupID)
    }

    static func set() {
        groupDefaults?.set(true, forKey: key)
    }

    static func set(quitID: UUID) {
        groupDefaults?.set(quitID.uuidString, forKey: quitIDKey)
    }

    static func isSet() -> Bool {
        groupDefaults?.bool(forKey: key) ?? false
    }

    static func selectedQuitID() -> UUID? {
        (groupDefaults?.string(forKey: quitIDKey)).flatMap(UUID.init(uuidString:))
    }

    /// Consumes BOTH keys: a stale selection surviving the flag would hijack the
    /// next panic launch onto the wrong quit.
    static func clear() {
        groupDefaults?.removeObject(forKey: key)
        groupDefaults?.removeObject(forKey: quitIDKey)
    }
}
