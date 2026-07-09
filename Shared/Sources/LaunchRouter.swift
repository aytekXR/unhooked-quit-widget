import Foundation

/// Which root the scene builds. The panic route must skip the normal tab hierarchy
/// entirely — the intervention renders before anything else initializes (ADR-6).
enum RootKind: Equatable, Sendable {
    /// Normal launch: the walking-skeleton placeholder root (tabs arrive with real features).
    case placeholderTabs
    /// Panic launch: bare full-screen panic placeholder, no tab hierarchy.
    case panicPlaceholder
}

/// Pure launch-route decision, kept I/O-free so it is unit-testable without UI.
enum LaunchRouter {
    static func resolveRoot(panicFlagIsSet: Bool) -> RootKind {
        panicFlagIsSet ? .panicPlaceholder : .placeholderTabs
    }
}

extension RootKind {
    /// ADR-6 gate (E3.1): only the normal root may ever load the persistent graph —
    /// the panic route renders exclusively from the App Group pre-cache, pre- AND
    /// post-frame. `RepositoryProvider.startIfNeeded(for:)` refuses any route that
    /// answers false here.
    var loadsPersistentGraph: Bool { self == .placeholderTabs }
}
