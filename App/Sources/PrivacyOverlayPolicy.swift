import SwiftUI

/// E6.3 (R22.5) — the app-switcher shield's PURE activation policy, I/O-free so the
/// unit lane pins it (O1, the plan-named test). The shield itself is a UIKit overlay
/// window (a WindowGroup-content overlay cannot cover sheets — and the warm-panic
/// sheet renders verbatim motivations); this policy only decides WHEN it shows.
enum PrivacyOverlayPolicy {
    /// Whether the shield covers the app's snapshot surface.
    ///
    /// Contract (pinned by O1 + its twins):
    /// - `phase == .active` ⇒ never (nothing is being snapshotted; also guarantees
    ///   the cold-launch first frame is shield-free — ADR-6's budget untouched).
    /// - otherwise, cover unless discreet-ness is AFFIRMATIVELY known false:
    ///   `anyActiveQuitDiscreet` is TRI-STATE, and `nil` (store not yet open,
    ///   pre-cache unreadable) must COVER — fail-toward-privacy, the merge-fold
    ///   posture; an indeterminate signal exposing motivations is the failure mode
    ///   this exists to close (privacy panel MUST-FIX #2).
    ///
    /// Red-commit surface: deliberately inert (never active) — O1 is the designed
    /// red; the twins (active-phase, affirmative-false) are born-green against it.
    static func isActive(phase: ScenePhase, anyActiveQuitDiscreet: Bool?) -> Bool {
        false
    }
}
