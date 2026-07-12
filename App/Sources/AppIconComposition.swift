import UIKit

/// E6.3 (R22.3) — the ONE place `UIApplication`'s alternate-icon API is touched.
/// App-target-only by hard constraint: `UIApplication.shared` is
/// extension-unavailable and `Shared/Sources` compiles into the widget extension
/// (Session 22 burn-critic rank 1 — a reference there is a compile error for every
/// target). Everything else goes through the `AppIconSwitcher` seam's injected
/// closure, so the unit lane never needs this file.
@MainActor
enum AppIconComposition {
    /// The live apply closure for `AppIconSwitcher`/`EraseFlow`: guards
    /// `supportsAlternateIcons` (a quiet no-op where switching is unsupported —
    /// Architect amendment, R22.4), `nil` restores the primary icon. iOS shows its
    /// own system confirmation alert on programmatic icon changes; that is platform
    /// behavior, not ours to suppress.
    static func makeLiveApply() -> AppIconSwitcher.ApplyIcon {
        { iconID in
            try await Self.apply(iconID)
        }
    }

    /// The OS-truth read for the launch reconciliation (R22.4, reset-only direction).
    static var currentAlternateIconName: String? {
        UIApplication.shared.alternateIconName
    }

    private static func apply(_ iconID: String?) async throws {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        try await UIApplication.shared.setAlternateIconName(iconID)
    }
}
