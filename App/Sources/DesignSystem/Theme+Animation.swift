import SwiftUI

/// The `motion/calm` easing split, decided ONCE at the token layer (brandkit §7).
/// The 600ms duration serves two distinct jobs with two curves:
///
/// - **Entrance reveals** — something appearing over its settled frame (the
///   summary hero, the streak-detail header, the milestone rise, the ring
///   sweep) — start fast: `easeOut`. An easeInOut start delays the first
///   frames of the exact moment the user is watching.
/// - **State↔state crossfades** — one frame replacing another (the panic/slip
///   stage switches) — keep `easeInOut`: symmetric, breath-like.
///
/// Reduce Motion: both collapse to the 200ms `motion/quick` crossfade (§7).
extension Theme.motion {
    /// Entrance reveal at `motion/calm`, easeOut; `motion/quick` under Reduce
    /// Motion. Callers still own their RM environment read — this helper only
    /// owns the curve/duration pairing so no call site restates the choice.
    static func entrance(reduceMotion: Bool) -> Animation {
        .easeOut(duration: reduceMotion ? quick : calm)
    }
}
