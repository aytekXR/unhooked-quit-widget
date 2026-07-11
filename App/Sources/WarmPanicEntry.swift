import Foundation

/// The warm-launch panic entry point's composition seam — the gap the init-time root
/// decision (ADR-6) cannot cover: a control/widget panic launch that lands while the
/// app is ALREADY running. With the intents compiled into both targets, iOS runs
/// `perform()` in the app's own process when the app is alive, and merely foregrounds
/// us when it ran in the extension — either way `UnhookedApp.init` never re-runs, so
/// the flag must be consumed post-frame. Pure and I/O-free except the flag read (the
/// InAppPanicEntry precedent) so the unit lane can pin it.
enum WarmPanicEntry {
    /// True when the app is standing in as the UNIT-TEST HOST (XCTest is loaded in
    /// the process). The unit lane owns the App Group flag keys (set/clear + defer
    /// hygiene, PanicEntryPointTests) — a live warm listener in the host would race
    /// it, consuming a test's half-asserted flag through the mounted route's
    /// onAppear sweep. Coverage-exempt scaffolding, like the UITEST_* hooks.
    static let isHostingUnitTests = NSClassFromString("XCTestCase") != nil

    /// Resolves what a pending warm panic launch should present, or nil when no panic
    /// launch is pending. Reads the SAME flag keys the cold route reads pre-frame;
    /// the mounted `PanicPlaceholderView.onAppear` consumes them, exactly like cold.
    static func resolve(snapshot: PanicSnapshot?) -> WarmPanicPresentation? {
        guard PanicLaunchFlag.isSet() else { return nil }
        return WarmPanicPresentation(
            presentation: PanicRouteResolver.resolve(
                selectedQuitID: PanicLaunchFlag.selectedQuitID(),
                snapshot: snapshot
            ),
            source: PanicLaunchFlag.launchSource() ?? .lockscreenWidget
        )
    }
}

/// Sheet-item wrapper (the InAppPanicPresentation precedent), carrying the TRUE
/// source captured before `onAppear` sweeps the flag keys.
struct WarmPanicPresentation: Identifiable {
    let id = UUID()
    let presentation: PanicPresentation
    let source: PanicSource
}
