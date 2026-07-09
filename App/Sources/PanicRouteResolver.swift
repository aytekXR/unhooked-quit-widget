import Foundation

/// What the panic route renders — resolved PURELY from the pre-cache and the App Group
/// selection channel, never the store (ADR-6: the panic first frame does zero
/// store/repository work; the full flow UI is E3.2).
enum PanicPresentation: Equatable {
    /// One quit's intervention frame: the selected quit, or the only quit there is.
    case breathe(QuitSnapshot)
    /// Several quits and no (or an unknown) selection: a placeholder-grade picker.
    case picker([QuitSnapshot])
    /// No tracked quits (fresh or erased install): the bare breathe frame.
    case empty
}

/// Pure selection matrix, I/O-free so it is unit-testable without UI — the same
/// resolver serves the E3.3 per-widget quitID parameter and any later deep link
/// unchanged (they only change who WRITES the selection).
enum PanicRouteResolver {
    static func resolve(selectedQuitID: UUID?, snapshot: PanicSnapshot?) -> PanicPresentation {
        // E3.1 red skeleton: the selection matrix does not exist yet. `.picker([])` is
        // deliberately wrong for every matrix row so no route test can pass from birth.
        .picker([])
    }
}
