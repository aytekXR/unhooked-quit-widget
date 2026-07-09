import Foundation
import Observation
import SwiftData

/// Post-first-frame owner of the persistent graph (E3.1, ADR-6): the app's ONE path
/// from "a frame is on screen" to "the store is open, the repository exists, and the
/// launch-time derived-state pass has run". Lives in App/Sources/Persistence because
/// it imports SwiftData (the sole-importer lint allowlists exactly this directory);
/// `UnhookedApp` references the type without the import and calls `startIfNeeded(for:)`
/// from the root view's post-frame hook — never from `init`.
///
/// E3.1 RED SKELETON (pass-from-birth discipline, Session 08): deliberately wrong —
/// opens the store EAGERLY at init and again on every start call, on every route, and
/// never builds the repository or runs the launch pass. The init-order pins must fail
/// against this before the green step inverts it.
@MainActor
@Observable
final class RepositoryProvider {
    /// Published for future consumers (E3.2 panic flow, E4.1 slip flow) via the
    /// SwiftUI environment; `nil` until the normal route's deferred start completes.
    private(set) var repository: QuitRepository?

    private let storeOpener: () throws -> ModelContainer
    private let makeRepository: @MainActor (ModelContainer) -> QuitRepository

    init(
        storeOpener: @escaping () throws -> ModelContainer = { try PersistentStore.makeContainer() },
        makeRepository: @escaping @MainActor (ModelContainer) -> QuitRepository
    ) {
        self.storeOpener = storeOpener
        self.makeRepository = makeRepository
        _ = try? storeOpener() // red: pre-frame store work, the exact thing ADR-6 bans
    }

    /// Idempotent deferred start, called from the root view's `.task` (after the first
    /// frame is committed). Route-aware by contract: the panic route must do ZERO
    /// store/repository work here — pre- or post-frame (E3.1 init-order pin).
    func startIfNeeded(for root: RootKind) {
        _ = try? storeOpener() // red: re-opens on every call and ignores the route
    }
}
