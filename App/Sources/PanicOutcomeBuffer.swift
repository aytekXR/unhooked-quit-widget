import Foundation

/// One panic-flow outcome, exactly as the flow knew it at exit time (architecture §9
/// rule 2). `at` is the TRUE exit instant (the flow's injected clock) — the flush
/// preserves it so §12.4 insights aggregate on real urge timing, never on whenever
/// the next launch happened to run. `id` is the dedupe key end to end: the flushed
/// `UrgeEvent` adopts it, which is what makes a crash between save and clear replay
/// safely instead of double-counting.
struct PanicOutcomeDraft: Codable, Equatable, Sendable {
    var id: UUID = UUID()
    /// `nil` for a zero-quit panic (fresh/erased install breathing on the bare frame).
    var quitID: UUID?
    var source: PanicSource
    var outcome: UrgeOutcome
    var stepsReached: [PanicStep]
    var at: Date
}

/// The §9-rule-2 panic write buffer: an append-only NDJSON file in the App Group —
/// the durable half of "a crash between panic exit and flush loses nothing". The
/// panic scene appends (it may never open the store, E3.1 spy pin); the repository
/// flushes on the normal route's deferred start and clears only after a successful
/// commit. Pure Foundation, zero persistence-framework dependencies; injected-location
/// pattern per the PanicSnapshotStore precedent (tests point it at a temp directory).
///
/// One JSON object per line: a crash mid-append can tear only the LAST line, and the
/// reader drops any undecodable line — earlier outcomes always survive intact.
struct PanicOutcomeBuffer: Sendable {
    static let fileName = "panic-outcomes.ndjson"

    /// The one file this buffer owns — also the erase sweep's owned-file-set entry
    /// (E2.4 scope pin: erase removes owned FILES, never a directory).
    let fileURL: URL

    init(directoryURL: URL) {
        fileURL = directoryURL.appendingPathComponent(Self.fileName, isDirectory: false)
    }

    /// Production location: the App Group container root, beside panic-snapshot.json.
    static func appGroup() -> PanicOutcomeBuffer? {
        AppIdentifiers.appGroupContainerURL.map(PanicOutcomeBuffer.init(directoryURL:))
    }

    /// Appends one outcome as a single NDJSON line. E3.2 red skeleton: not implemented.
    func append(_ draft: PanicOutcomeDraft) throws {
        // red skeleton — the durable append lands with the green commit
    }

    /// Every decodable buffered outcome, in append order. A torn tail line (crash
    /// mid-append) or foreign bytes decode as nothing and are skipped — earlier
    /// outcomes must never be hostage to the newest write.
    func drafts() -> [PanicOutcomeDraft] {
        [] // red skeleton
    }

    /// Removes the buffer file. Missing file = nothing to do (erase and post-flush
    /// consume share this).
    func clear() throws {
        // red skeleton
    }
}
