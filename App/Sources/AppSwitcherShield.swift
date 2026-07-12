import SwiftUI
import UIKit

/// E6.3 (R22.5) — the app-switcher shield: a dedicated OVERLAY WINDOW above the main
/// window's presentation stack. A SwiftUI overlay on the WindowGroup content cannot
/// cover `.sheet`/`.fullScreenCover` layers (privacy panel MUST-FIX #1 — the
/// warm-panic sheet renders verbatim motivations, exactly what must never reach the
/// app-switcher snapshot); a separate high-level `UIWindow` covers everything the
/// snapshot sees. App-target-only (UIKit; never Shared — the extension cannot compile
/// `UIApplication`).
///
/// Lifecycle: `UnhookedApp` drives `update(covered:)` from its top-level scene-phase
/// observer through the pure `PrivacyOverlayPolicy` (unit-pinned, O1). The window is
/// created lazily on the first cover and then only toggles `isHidden` — no per-event
/// allocation, nothing pre-frame (at cold launch the phase is `.active`, so the first
/// frame never pays for this — ADR-6 untouched).
@MainActor
final class AppSwitcherShield {
    private var window: UIWindow?

    func update(covered: Bool) {
        if covered {
            show()
        } else {
            window?.isHidden = true
        }
    }

    private func show() {
        if window == nil {
            guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first
            else { return }
            let shield = UIWindow(windowScene: scene)
            // Above alerts so no presentation layer outdraws the cover in the
            // switcher snapshot. The explicit rawValue spelling on purpose: the
            // bare `.alert + 1` operator is tutorial-folklore the official docs
            // JSON does not confirm on the modern UIWindow.Level struct, and an
            // unconfirmed form is a build-failure risk under warnings-as-errors
            // (the S21/S22 docs-check gate); `init(rawValue:)` is the documented
            // RawRepresentable requirement.
            shield.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.alert.rawValue + 1)
            shield.rootViewController = UIHostingController(rootView: AppSwitcherPrivacyOverlay())
            shield.isUserInteractionEnabled = false
            window = shield
        }
        window?.isHidden = false
    }
}
