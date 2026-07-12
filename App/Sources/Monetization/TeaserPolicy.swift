import Foundation

/// E7.2 (R25.7) — the pure teaser-grant arithmetic. The teaser is a
/// 24-HOUR WALL-CLOCK DURATION ("1 day of access", MVP §6) — deliberately
/// NOT ADR-11's noon-anchored calendar day: that rule is scoped to the
/// displayed "Day N" streak count, and calendar-anchoring a teaser taken at
/// 23:00 would expire it within the hour (dishonest). An absolute-Date
/// comparison is timezone-invariant by construction — proven, not assumed,
/// by the ×3-zone harness run (UTC/Berlin/Kiritimati; the QA clock-adjacent
/// gate).
///
/// No ambient clock anywhere (`Date()`/`ProcessInfo` are banned in
/// production code): `now` is always injected — the repository stamps via
/// its `ClockProviding`, the routing layer passes the same reading through.
///
/// RED (Session 25): inert — the grant math fails by design until green.
enum TeaserPolicy {
    /// The grant length: one day, as a duration (86_400 wall-clock seconds).
    static let grantDuration: TimeInterval = 86_400

    /// The expiry instant for a teaser taken at `now`.
    static func expiry(from now: Date) -> Date {
        now
    }

    /// `nil` = no teaser was ever taken ⇒ never expired (the gate simply
    /// isn't in play); a stamped teaser is expired from the exact boundary
    /// instant onward (`now >= expiresAt`).
    static func isExpired(_ expiresAt: Date?, now: Date) -> Bool {
        false
    }
}
