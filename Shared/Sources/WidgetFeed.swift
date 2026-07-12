import Foundation

/// One quit's widget-renderable state — the app half of the E6.2 widget feed. This is
/// the RICH app DTO that maps ONTO WidgetToolkit's deliberately domain-neutral
/// 3-field `StreakWidgetState` (the planner's input); the family templates read the
/// extra fields (money, momentum, milestone ladder) directly at render time.
///
/// §10 privacy gate (Session 21 step-0, Architect-ruled): `widget-state.json` is an
/// App Group file, readable PRE-UNLOCK, so the ABSENCE set is the point — NO habit
/// category, NO label of any kind, NO motivations, NO slip data or timestamps, NO
/// anchors, NO discreet flag (nothing renders habit-differently until E6.3; the flag
/// joins additively under the same schemaVersion when its consumer exists). Every
/// field below earns its place by a family that renders it (brandkit item 14).
struct WidgetQuitState: Codable, Sendable, Equatable {
    var id: UUID
    /// The guard-corrected origin of the CURRENT streak (ADR-7 runs app-side at write
    /// time; the widget never re-derives it and runs no guard of its own — ADR-6).
    var streakStart: Date
    /// The quit's FIXED day-boundary zone identifier (ADR-11) — a String, never a raw
    /// `TimeZone`: explicit `TimeZone(identifier:)` construction on read structurally
    /// closes the decode path that lets `.autoupdatingCurrent` survive Codable
    /// (Session 20 defect class; reproduced again by this session's panel).
    var timeZoneIdentifier: String
    /// Weekly spend in MAJOR currency units as a plain decimal string ("26.50") —
    /// `Decimal` JSON round-trips losslessly as a string on Linux AND Darwin, where a
    /// raw Decimal JSON number can drift (panel-verified). Empty/unparseable reads as
    /// "no spend" and money simply does not render (free habits are first-class).
    var weeklySpend: String
    var currencyCode: String
    /// Banked clean seconds from PRIOR streaks (`Quit.totalCleanSeconds`, BANKED-only).
    /// Money saved renders from banked + current-streak elapsed — the same
    /// `StreakCalculator.moneySaved` formula every app surface uses.
    var bankedCleanSeconds: Int
    /// Momentum 0...100 as stored at write time (the same guarded read the dashboard
    /// shows). Rewritten on every mutating write; staleness bounded by the §11
    /// freshness path.
    var momentumPercent: Int
    /// The quit's milestone ladder as elapsed-hour offsets ONLY — titles and bodies
    /// are copy and NEVER enter this pre-unlock-readable file. Feeds the systemMedium
    /// milestone bar and the planner's milestone-crossing entries. (The ladder's
    /// single-bit category signal — only vape carries a 12h rung — is an accepted,
    /// recorded trade-off.)
    var milestoneHours: [Int]
}

/// The widget feed (architecture §3/§7/ADR-6): plain Codable JSON in the App Group,
/// atomically rewritten by the repository after every mutating write. Widgets are pure
/// functions of this file plus self-ticking date-relative text.
struct WidgetFeed: Codable, Sendable, Equatable {
    static let currentSchemaVersion = 1

    var schemaVersion: Int = WidgetFeed.currentSchemaVersion
    /// When the app last rewrote this state — the only freshness signal a stateless
    /// provider can have (§11); the basis of the planner's stale-grace.
    var generatedAt: Date
    /// Active quits in the repository's total order (sortIndex, id). Widgets BIND BY
    /// `id`, never by position (mvp feature 5: no cross-contamination) — the order
    /// here is cosmetic, not addressable.
    var quits: [WidgetQuitState]
}

/// Reader/writer for `widget-state.json`. Lives in Shared (compiled into both targets:
/// the app owns the writer, the widget extension owns the read path); pure Foundation.
/// Injected-location per the PanicSnapshotStore precedent.
struct WidgetStateStore: Sendable {
    static let fileName = "widget-state.json"

    /// The one file this store owns — also the erase sweep's owned-file-set entry
    /// (E3.1 standing rule: a new App Group artifact joins erase in its landing
    /// session, in all three enumeration sites, same commit).
    let fileURL: URL

    init(directoryURL: URL) {
        fileURL = directoryURL.appendingPathComponent(Self.fileName, isDirectory: false)
    }

    /// Production location: the App Group container root (architecture §4 diagram).
    static func appGroup() -> WidgetStateStore? {
        AppIdentifiers.appGroupContainerURL.map(WidgetStateStore.init(directoryURL:))
    }

    /// Atomic whole-file rewrite — a widget render must never observe a torn feed.
    func write(_ feed: WidgetFeed) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true
        )
        try JSONEncoder().encode(feed).write(to: fileURL, options: .atomic)
    }

    /// A missing file, undecodable bytes, or a foreign `schemaVersion` all read as
    /// "no feed" — the planner then emits its single `.unavailable` entry, never a
    /// stale or fabricated number.
    func read() -> WidgetFeed? {
        guard let data = try? Data(contentsOf: fileURL),
              let feed = try? JSONDecoder().decode(WidgetFeed.self, from: data),
              feed.schemaVersion == WidgetFeed.currentSchemaVersion
        else { return nil }
        return feed
    }

    /// Deletes the feed. ZERO ACTIVE QUITS ⇒ the file is REMOVED, never written
    /// present-empty — a deliberate divergence from the panic pre-cache: the planner's
    /// nil-read ⇒ one `.unavailable` entry is what clears an erased streak off the
    /// lock screen (WidgetKit keeps the last rendered pixels on an empty timeline).
    func remove() throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
}
