import Foundation

/// ME-1 (redesign §6.15) — the widget-adoption app-group handshake: the ONE
/// detection channel for "the user actually added a widget", and therefore the
/// `widget_added` fire point's source of truth.
///
/// WRITER: the widget extension's timeline provider, from `timeline(for:in:)` —
/// a call WidgetKit makes only for an ADDED widget instance (the gallery
/// preview renders `placeholder(in:)`/`snapshot`, which never touch this — a
/// browse must never read as an add). One presence-only defaults key per
/// family, written once: later timeline refills are structural no-ops, and the
/// stamp keeps the ADD-time discreet flag (the state `widget_added` reports).
///
/// READER: the app, which turns each un-acknowledged stamp into at most one
/// consent-gated `widget_added` fire and acknowledges it either way — ADR-8:
/// consent-off means the event never existed; it is not parked for a later
/// opt-in (the fire-and-forget posture every other seam has).
///
/// PRIVACY (§10): the stamps carry a family wire name and one bool — no habit
/// category, no label, no timestamp. They live in the App Group DEFAULTS, so
/// the erase sweep's remove-every-key pass (`QuitRepository.eraseLocalArtifacts`)
/// clears them with zero new enumeration sites (erased = a fresh tracking era
/// whose adds may fire again — deliberate, the trial-dedupe precedent).
///
/// The PanicLaunchFlag shape (enum + static functions over the group suite)
/// because the extension calls it under complete concurrency; every function
/// takes an injectable suite so the unit lane runs on throwaway defaults.
enum WidgetAdoptionHandshake {
    /// Key prefix for "this family rendered a real timeline at least once";
    /// the value is the ADD-time discreet flag.
    static let renderedKeyPrefix = "widgetAdoption.rendered."
    /// Key prefix for "the app already consumed this family's stamp".
    static let acknowledgedKeyPrefix = "widgetAdoption.acknowledged."

    /// The production suite — nil off-device/misprovisioned, and every call
    /// degrades to a calm no-op (the PanicLaunchFlag posture).
    static var groupDefaults: UserDefaults? {
        UserDefaults(suiteName: AppIdentifiers.appGroupID)
    }

    /// One rendered-but-unacknowledged stamp, app-side.
    struct PendingAdoption: Equatable, Sendable {
        /// The MVP §5 `widget_added.kind` wire value, verbatim — the app maps it
        /// with `WidgetKind(rawValue:)`, no second table.
        var kindWireName: String
        var discreet: Bool
    }

    /// The family's audited wire name (MVP §5 kind values, byte-identical to
    /// the app-side `WidgetKind` rawValues — pinned by WidgetAdoptionTests).
    /// Exhaustive: a new family cannot ship without choosing its wire value.
    static func wireName(for family: StreakWidgetFamily) -> String {
        switch family {
        case .rectangular: "panic_rect"
        case .circular: "circular"
        case .inline: "inline"
        case .small: "home_s"
        case .medium: "home_m"
        }
    }

    /// EXTENSION side — stamp the family's first real timeline render.
    /// Write-once by construction: an existing stamp is never touched, so
    /// refills neither churn the suite nor rewrite the ADD-time discreet flag.
    static func recordFirstRender(
        family: StreakWidgetFamily,
        discreet: Bool,
        in defaults: UserDefaults? = WidgetAdoptionHandshake.groupDefaults
    ) {
        guard let defaults else { return }
        let key = renderedKeyPrefix + wireName(for: family)
        guard defaults.object(forKey: key) == nil else { return }
        defaults.set(discreet, forKey: key)
    }

    /// APP side — every rendered-but-unacknowledged stamp, in the stable
    /// family-enum order (deterministic fire order for tests and transports).
    static func pending(
        in defaults: UserDefaults? = WidgetAdoptionHandshake.groupDefaults
    ) -> [PendingAdoption] {
        guard let defaults else { return [] }
        return StreakWidgetFamily.allCases.compactMap { family in
            let name = wireName(for: family)
            guard let discreet = defaults.object(forKey: renderedKeyPrefix + name) as? Bool,
                  !defaults.bool(forKey: acknowledgedKeyPrefix + name)
            else { return nil }
            return PendingAdoption(kindWireName: name, discreet: discreet)
        }
    }

    /// APP side — marks one stamp consumed (fired or consent-swallowed alike).
    static func acknowledge(
        _ kindWireName: String,
        in defaults: UserDefaults? = WidgetAdoptionHandshake.groupDefaults
    ) {
        defaults?.set(true, forKey: acknowledgedKeyPrefix + kindWireName)
    }

    /// The adoption screen's "it's really on the lock screen" detection: any
    /// family has rendered at least once (acknowledged or not — detection is
    /// about the widget existing, not about analytics bookkeeping).
    static func hasAnyRender(
        in defaults: UserDefaults? = WidgetAdoptionHandshake.groupDefaults
    ) -> Bool {
        guard let defaults else { return false }
        return StreakWidgetFamily.allCases.contains { family in
            defaults.object(forKey: renderedKeyPrefix + wireName(for: family)) != nil
        }
    }
}
