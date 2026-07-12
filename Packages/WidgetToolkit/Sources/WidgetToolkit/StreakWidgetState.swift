import Foundation

/// What a streak widget needs to know, and nothing else (architecture §10: App Group snapshot
/// files are readable PRE-UNLOCK, so their content is minimized). Domain-neutral by design —
/// this is a portfolio package (§14), so it names no habit, no label, no money and no identity:
/// a prayer-streak or a training-streak consumer uses it unchanged.
///
/// The three fields are exactly what the day rule and the ticker need:
/// - `streakStart` — the guard-corrected origin of the CURRENT streak. The producing app runs
///   StreakEngine's clock-integrity guard at write time and hands over the corrected instant;
///   the widget never re-derives it, never sees a raw anchor, and runs no guard of its own
///   (ADR-6: widgets read only snapshots).
/// - `timeZone` — the quit's FIXED day-boundary zone (test-suite §3.1 item 3: "day boundaries
///   computed in the quit's timezone"). Never the device's: `TimeZone.current` is an unguarded
///   one-tap Settings input, and a westward flight would silently bump the day number.
/// - `generatedAt` — when the app last rewrote this state. The only freshness signal a stateless
///   provider can have (§11), and the basis of stale-grace.
public struct StreakWidgetState: Sendable, Equatable, Hashable, Codable {
    public var streakStart: Date
    public var timeZone: TimeZone
    public var generatedAt: Date

    public init(streakStart: Date, timeZone: TimeZone, generatedAt: Date) {
        self.streakStart = streakStart
        // PINNED to a fixed zone at the door. `TimeZone.autoupdatingCurrent` re-binds itself to
        // whatever device reads it — and it SURVIVES Codable: a widget-state.json whose bytes say
        // "America/New_York" decodes to Istanbul on a device in Istanbul, silently defeating the
        // travel-immunity this whole type exists to provide. Re-resolving through the identifier
        // strips the autoupdating behavior and stabilizes the encoded JSON.
        self.timeZone = TimeZone(identifier: timeZone.identifier) ?? timeZone
        self.generatedAt = generatedAt
    }

    /// E6.2: the DECODE door re-pins too. Codable's synthesized `init(from:)` assigns the decoded
    /// timezone directly, BYPASSING the memberwise pin above — and the `autoupdating` flag
    /// survives Foundation's Codable representation, so bytes written by any producer that skipped
    /// the guarding init would decode to the READING device's zone. The identifier STRING is
    /// decoded and resolved directly: decoding `TimeZone.self` first would materialize
    /// `.autoupdatingCurrent`, whose `.identifier` already IS the reading device's zone — a
    /// re-pin through it binds to the wrong zone with no error (green-critic reproduction,
    /// TZ=UTC vs a Berlin host). Bytes whose identifier names no real zone are a decode error —
    /// the reader degrades to no-state, never to a guessed boundary.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let zoneContainer = try container.nestedContainer(keyedBy: TimeZoneCodingKeys.self, forKey: .timeZone)
        let identifier = try zoneContainer.decode(String.self, forKey: .identifier)
        guard let zone = TimeZone(identifier: identifier) else {
            throw DecodingError.dataCorruptedError(
                forKey: .identifier,
                in: zoneContainer,
                debugDescription: "unknown timezone identifier '\(identifier)'"
            )
        }
        self.init(
            streakStart: try container.decode(Date.self, forKey: .streakStart),
            timeZone: zone,
            generatedAt: try container.decode(Date.self, forKey: .generatedAt)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case streakStart, timeZone, generatedAt
    }

    /// Foundation's own TimeZone Codable shape: `{"identifier": "..."}`.
    private enum TimeZoneCodingKeys: String, CodingKey {
        case identifier
    }
}

/// The planner's ONLY dependency, and it is read-only BY TYPE: there is no write member to call.
/// The producing app owns the writer; the widget extension owns a reader conforming to this
/// (E6.2 lands `widget-state.json` and its store on the `PanicSnapshotStore` precedent).
///
/// `nil` means "no state on disk" — a fresh install, or a post-erase device where the owned App
/// Group file is ABSENT. It never means "zero streak": see `StreakWidgetEntry.Kind.unavailable`.
public protocol StreakWidgetStateReading: Sendable {
    func read() -> StreakWidgetState?
}
