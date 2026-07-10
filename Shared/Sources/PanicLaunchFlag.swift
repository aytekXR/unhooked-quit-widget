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
    /// for. The per-quit `@Parameter` (E3.3, and any later deep link) writes this same
    /// key; the app-side resolver already consumes it.
    static let quitIDKey = "panic.launch.quitID"

    /// The launch's TRUE origin (E3.3). The per-source entry points write this on the
    /// SAME App Group hop as the flag and the selection; the app reads it pre-frame and
    /// threads it into the panic flow so `UrgeEvent.source` records the real entry point
    /// (retiring the `.lockscreenWidget` fiction). A stale value survives nothing —
    /// clear() sweeps it with the other two keys.
    static let sourceKey = "panic.launch.source"

    private static var groupDefaults: UserDefaults? {
        UserDefaults(suiteName: AppIdentifiers.appGroupID)
    }

    static func set() {
        groupDefaults?.set(true, forKey: key)
    }

    static func set(quitID: UUID) {
        groupDefaults?.set(quitID.uuidString, forKey: quitIDKey)
    }

    /// Writes the requested flag, the source, and (when present) the quit selection as
    /// ONE launch instruction — the per-source entry points (E3.3) call this.
    static func set(source: PanicSource, quitID: UUID? = nil) {
        // E3.3 red stub: the WRITER half is real (the round-trip pin fails on the
        // read-back, not vacuously, and the clear-sweep pin has a physical key to find),
        // but `launchSource()` — the reader half — is not implemented yet.
        groupDefaults?.set(true, forKey: key)
        groupDefaults?.set(source.rawValue, forKey: sourceKey)
        if let quitID {
            groupDefaults?.set(quitID.uuidString, forKey: quitIDKey)
        }
    }

    static func isSet() -> Bool {
        groupDefaults?.bool(forKey: key) ?? false
    }

    static func selectedQuitID() -> UUID? {
        (groupDefaults?.string(forKey: quitIDKey)).flatMap(UUID.init(uuidString:))
    }

    /// The launch's true origin, read back for the app's pre-frame capture.
    static func launchSource() -> PanicSource? {
        // E3.3 red stub: the reader half is unimplemented — always nil. The green commit
        // reads `sourceKey` back through `PanicSource(rawValue:)`.
        nil
    }

    /// Consumes BOTH keys: a stale selection surviving the flag would hijack the
    /// next panic launch onto the wrong quit.
    static func clear() {
        // E3.3 red stub: clear() does NOT yet sweep `sourceKey` — the green commit adds
        // that third removal (a stale source would mis-attribute the next launch).
        groupDefaults?.removeObject(forKey: key)
        groupDefaults?.removeObject(forKey: quitIDKey)
    }
}
