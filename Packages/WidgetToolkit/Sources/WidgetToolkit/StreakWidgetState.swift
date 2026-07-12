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
