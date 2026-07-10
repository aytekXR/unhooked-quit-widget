import Foundation

/// The in-app panic entry point's composition seam (E3.3) — the fourth `PanicSource`.
/// Pure and I/O-free (the PanicRouteResolver precedent) so the unit lane can pin it:
/// the dashboard button reads the PRE-CACHE (one panic composition path, ADR-6 — the
/// panic surface never opens the store even when the store is warm) and mounts
/// `PanicPlaceholderView(presentation:source:)` with these values.
enum InAppPanicEntry {
    /// The TRUE origin an in-app launch lands on the flow.
    static let source: PanicSource = .lockscreenWidget // red-stub: green returns .inApp

    /// What the in-app mount shows, resolved from the pre-cache exactly like the cold
    /// route (no selection — the picker/single-quit/empty matrix is the resolver's).
    static func presentation(snapshot: PanicSnapshot?) -> PanicPresentation {
        PanicRouteResolver.resolve(selectedQuitID: nil, snapshot: snapshot)
    }
}
