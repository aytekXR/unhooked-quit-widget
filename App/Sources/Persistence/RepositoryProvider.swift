import Foundation
import Observation
import SwiftData

/// Post-first-frame owner of the persistent graph (E3.1, ADR-6): the app's ONE path
/// from "a frame is on screen" to "the store is open, the repository exists, and the
/// launch-time derived-state pass has run". Lives in App/Sources/Persistence because
/// it imports SwiftData (the sole-importer lint allowlists exactly this directory);
/// `UnhookedApp` references the type without the import and calls `startIfNeeded(for:)`
/// from the root view's `.task` — which runs after the first frame commits — never
/// from `init` (constructing the provider does zero work, pinned by the init-order
/// spy in PanicPathTests).
@MainActor
@Observable
final class RepositoryProvider {
    /// Published for consumers (E3.2 panic flow, E4.1 slip flow) via the SwiftUI
    /// environment; `nil` until the normal route's deferred start completes.
    private(set) var repository: QuitRepository?

    private let storeOpener: () throws -> ModelContainer
    private let makeRepository: @MainActor (ModelContainer) -> QuitRepository
    private var started = false

    init(
        storeOpener: @escaping () throws -> ModelContainer = { try PersistentStore.makeContainer() },
        makeRepository: @escaping @MainActor (ModelContainer) -> QuitRepository = { RepositoryProvider.liveRepository($0) }
    ) {
        self.storeOpener = storeOpener
        self.makeRepository = makeRepository
    }

    /// Idempotent deferred start. Route-aware by contract, not just by wiring: the
    /// panic route does ZERO store/repository work here — pre- or post-frame (E3.1
    /// init-order pin) — so even a mis-attached `.task` on the panic branch could
    /// never put SwiftData on that path.
    func startIfNeeded(for root: RootKind) {
        guard root.loadsPersistentGraph, !started else { return }
        started = true
        do {
            let container = try storeOpener() // the launch's FIRST store work — post-frame
            let repository = makeRepository(container)
            // The launch-time derived-state pass (E2.3, architecture §8): dedupe
            // merge, ADR-7 heal, bounded witness restart — then the §9-rule-2 panic
            // write-buffer flush (E3.2; non-throwing silent-recover, so a flush
            // failure can never strand the launch or skip the publish below), then
            // a pre-cache refresh from store truth (heals a failed best-effort
            // write; prunes pre-erase residue; folds just-flushed outcomes in).
            try repository.recomputeDerivedState()
            repository.flushPanicOutcomes()
            repository.refreshPanicSnapshot()
            self.repository = repository
        } catch {
            // §9 blocking class: a store that cannot open (or recompute) leaves the
            // repository nil and the placeholder UI standing. The full-screen
            // recovery flow (CloudKit re-hydration → offer erase-and-restart) is a
            // later epic's deliberate feature — nothing to silently retry here.
        }
    }

    /// Production composition root — the ONE place the real clock, WidgetCenter,
    /// App Group witness suite, and pre-cache location are constructed (bootstrap
    /// code, coverage-exempt per test-suite §2). The force-unwraps are provably safe
    /// in this call sequence: `storeOpener` succeeded first, and
    /// `PersistentStore.storeURL()` already throws `appGroupUnavailable` when the
    /// App Group container is broken — and a silent fallback suite would misplace
    /// the clock WITNESS, which corrupts the cap discipline far worse than a loud
    /// crash at the composition root would.
    static func liveRepository(_ container: ModelContainer) -> QuitRepository {
        let groupDefaults = UserDefaults(suiteName: AppIdentifiers.appGroupID)!
        // The ADR-8 double gate, both halves deliberately closed in E8.1: consent
        // is hardwired false until E8.2's consent step ships the stored opt-in
        // (its named tests own the default-OFF storage semantics), AND the
        // transport stays Noop until the operator drops the TelemetryDeck app ID
        // (operator-expected §8). Zero events before consent, by construction.
        let appID = AnalyticsConfiguration.telemetryDeckAppID
        let sink: any AnalyticsSink
        if appID.isEmpty {
            sink = NoopAnalyticsSink()
        } else {
            sink = TelemetryDeckSink(appID: appID)
        }
        return QuitRepository(
            container: container,
            clock: LiveClock(),
            widgetRefresher: LiveWidgetRefresher(),
            lastKnownGoodStore: LastKnownGoodStore(defaults: groupDefaults),
            cloud: LocalOnlyCloudSync(),
            appGroupDefaults: groupDefaults,
            panicSnapshotStore: PanicSnapshotStore.appGroup()!,
            analytics: AnalyticsService(sink: sink, isOptedIn: { false })
        )
    }
}
