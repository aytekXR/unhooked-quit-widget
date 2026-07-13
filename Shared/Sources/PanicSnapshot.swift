import Foundation

/// One quit's card inside the panic pre-cache. Content is MINIMIZED (architecture §10:
/// App Group snapshot files are readable pre-unlock): identity, a display label, the
/// discreet flag, and the user's verbatim motivations — the render source for the
/// panic flow (E3.2 reasons step). No slip notes, no timestamps, no anchors, no money
/// math: those live in the store and join as additive Codable fields under
/// `schemaVersion` when their named consumers (E3.2 flow, E6 widgets) arrive.
struct QuitSnapshot: Codable, Sendable, Equatable {
    var id: UUID
    /// Brand-safe display label. `nil` when the quit is discreet — §10: "Discreet mode
    /// further strips labels from snapshots" (renderers show a neutral title instead).
    var label: String?
    var discreet: Bool
    /// The user's own words, VERBATIM and in user order (they render unedited in the
    /// panic flow; the dedupe merge already preserves this order end to end).
    var motivations: [String]

    // E4.1 additive streak fields (architecture §3's PanicSnapshot sketch names them;
    // their first consumer is the cold slip flow's forgiveness framing). All optional
    // under the SAME schemaVersion: a pre-E4.1 cache decodes with them nil and the
    // framing degrades to the no-numbers copy — never a stale or invented number.
    // Raw scalars, not engine types (Shared stays dependency-free for the widget
    // target); the anchor's wallClock == startAt by the engine's documented invariant.
    var startAt: Date?
    var anchorBootID: UUID?
    var anchorUptime: TimeInterval?
    var bestStreakSeconds: Int?
    var momentumPercent: Int?
}

/// The panic pre-cache (architecture §4/ADR-6): plain Codable JSON in the App Group,
/// atomically rewritten by the repository after every mutating write, and the ONLY
/// thing the cold panic route reads before SwiftData/SDKs initialize (§11 budget).
struct PanicSnapshot: Codable, Sendable, Equatable {
    static let currentSchemaVersion = 1

    var schemaVersion: Int = PanicSnapshot.currentSchemaVersion
    var quits: [QuitSnapshot]
    // E9.3 additive (R28.2): the device-global eyes-free pacer preference, stamped
    // ENVELOPE-level (never per-card — it is not a quit attribute) from AppSettings
    // by the repository rebuild, so the cold panic route selects the haptics-only
    // pacer without opening the store (ADR-6). Optional under the SAME schemaVersion
    // (the E4.1 additive rule): a pre-E9.3 cache decodes with it nil and the flow
    // keeps the visual pacer — never a decode failure on the panic path. §10: a
    // render-necessary, content-free accessibility Bool — the `discreet` flag's
    // admissibility class, not an entitlement/teaser/winback bit (R28.2, vetoable).
    var hapticOnlyBreathPacer: Bool?
}

/// Reader/writer for `panic-snapshot.json`. Lives in Shared (compiled into both
/// targets) because the widget extension becomes a reader in E6; pure Foundation —
/// no SwiftData, no clock reads. Injected-location pattern per the LastKnownGoodStore
/// precedent: tests point it at a throwaway temp directory, production at the App
/// Group container root.
struct PanicSnapshotStore: Sendable {
    static let fileName = "panic-snapshot.json"

    /// The one file this store owns — also the erase sweep's owned-file-set entry
    /// (E2.4 scope pin: erase removes owned FILES, never a directory).
    let fileURL: URL

    init(directoryURL: URL) {
        fileURL = directoryURL.appendingPathComponent(Self.fileName, isDirectory: false)
    }

    /// Production location: the App Group container root (architecture §4 diagram).
    static func appGroup() -> PanicSnapshotStore? {
        AppIdentifiers.appGroupContainerURL.map(PanicSnapshotStore.init(directoryURL:))
    }

    /// Atomic whole-file rewrite — the panic route must never observe a torn cache.
    /// Self-healing about its parent directory (mirrors the PersistentStore
    /// precedent): the first cache write must succeed even if nothing else has
    /// touched the location yet.
    func write(_ snapshot: PanicSnapshot) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true
        )
        try JSONEncoder().encode(snapshot).write(to: fileURL, options: .atomic)
    }

    /// Synchronous read for the thin launch path. A missing file, undecodable bytes,
    /// or a foreign `schemaVersion` all read as "no cache" — the route degrades to the
    /// bare breathe frame, never to stale or misdecoded content.
    func read() -> PanicSnapshot? {
        guard let data = try? Data(contentsOf: fileURL),
              let snapshot = try? JSONDecoder().decode(PanicSnapshot.self, from: data),
              snapshot.schemaVersion == PanicSnapshot.currentSchemaVersion
        else { return nil }
        return snapshot
    }
}
