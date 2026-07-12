import Foundation

/// E6.3 (R22.3/R22.4) — the alternate-app-icon seam. Lives in App/Sources ON PURPOSE:
/// `UIApplication.shared` is extension-unavailable, and `Shared/Sources` compiles into
/// the widget extension — a switcher there is a hard compile error for every target
/// (Session 22 burn-critic rank 1, reproduced; the S21 file-granular class). The
/// UIKit-touching apply closure is CONSTRUCTED at the composition root; this type only
/// stores it, so the unit lane spies it (I1/I2/I4) without ever importing UIKit.
@MainActor
final class AppIconSwitcher {
    /// The OS-level icon request: `nil` restores the primary icon. The LIVE closure
    /// (composition root) guards `supportsAlternateIcons` and calls
    /// `setAlternateIconName`; tests inject a spy.
    typealias ApplyIcon = @Sendable (String?) async throws -> Void

    private let persist: (String?) throws -> Void
    private let apply: ApplyIcon
    private let fireIconEnabled: () -> Void

    /// - Parameters:
    ///   - persist: durable write of `AppSettings.discreetIconId` (repository seam).
    ///   - apply: the OS icon request (see `ApplyIcon`).
    ///   - fireIconEnabled: emits `discreet_mode_enabled(component: .icon)` through
    ///     the ONE consent-gated service — called on a NON-nil selection only
    ///     (enable-only semantics, mvp §5 row; R22.6).
    init(
        persist: @escaping (String?) throws -> Void,
        apply: @escaping ApplyIcon,
        fireIconEnabled: @escaping () -> Void
    ) {
        self.persist = persist
        self.apply = apply
        self.fireIconEnabled = fireIconEnabled
    }

    /// Selects an alternate icon (`nil` = back to primary): persists the choice
    /// durably AT the tap (the `setAnalyticsOptIn` at-the-tap precedent), then
    /// requests the OS swap; fires `.icon` on NON-nil selections only (enable-only —
    /// picking "Default" back fires nothing, I5).
    func select(_ iconID: String?) async throws {
        try persist(iconID)
        try await apply(iconID)
        if iconID != nil {
            fireIconEnabled()
        }
    }

    /// Erase-path reset (R22.4): best-effort primary-icon request, sequenced by the
    /// erase flow AFTER the data erase completes. Idempotent — `nil` over primary is
    /// a no-op at the OS layer. Deliberately does NOT persist: the erase has already
    /// wiped the AppSettings row, and a persist here would re-insert one post-erase.
    func resetToPrimary() async throws {
        try await apply(nil)
    }
}

/// E6.3 (R22.4) — launch-time reconciliation between the OS-level icon state (which
/// SURVIVES a store wipe) and the persisted selection (which does not): a "fresh
/// install" must never still wear a discreet disguise if the erase-path reset was
/// lost. RESET-ONLY direction — this never re-applies a discreet icon (an unprompted
/// system icon-change alert at launch is the wrong surprise, and primary is the
/// privacy-safe direction).
enum AppIconReconciler {
    enum Action: Equatable {
        case none
        case resetToPrimary
    }

    static func reconcile(osAlternateIconName: String?, persistedIconID: String?) -> Action {
        osAlternateIconName != nil && persistedIconID == nil ? .resetToPrimary : .none
    }
}
