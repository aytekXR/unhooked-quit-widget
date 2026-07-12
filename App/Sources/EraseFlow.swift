import Foundation

/// E6.3 (R22.4) — the one-tap-erase orchestration seam. The repository owns the DATA
/// erase and can never touch UIApplication; the OS-level alternate-icon state is NOT
/// in the store and survives `eraseEverything()`, so the erase FLOW must also request
/// the primary icon back — or a "fresh install" keeps wearing the Calendar/Timer
/// disguise, betraying the erase promise (privacy panel MUST-FIX). Future erase UI
/// calls THIS, never the repository directly.
@MainActor
struct EraseFlow {
    /// The P0 data erase (`repository.eraseEverything()` in production).
    let erase: () async throws -> Void
    /// The OS icon request (the AppIconSwitcher closure; spy-injected in I2).
    let applyIcon: AppIconSwitcher.ApplyIcon

    /// Runs the erase. Ordering contract (Architect amendment, R22.4): the DATA
    /// erase runs to completion FIRST; the icon reset is BEST-EFFORT after it — an
    /// icon-reset failure must never abort or fail the data erase (`applyIcon(nil)`
    /// is idempotent, and the launch reconciliation heals a lost reset).
    ///
    /// Red-commit surface: API final, the icon-reset call lands with the green
    /// commit (I2 pins it).
    func run() async throws {
        try await erase()
    }
}
