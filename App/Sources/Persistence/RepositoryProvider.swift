import Foundation
import Observation
import PaywallKit
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
    /// E6.3 (R22.5) — the shield policy's TRI-STATE input on the normal route:
    /// `nil` (indeterminate — store not yet open, or a read failure) must read as
    /// "cover" (fail-toward-privacy); the policy only skips the cover on an
    /// AFFIRMATIVE `false`. Refreshed on start and after every discreet toggle.
    private(set) var discreetAnyActive: Bool?
    /// E6.3 (R22.3) — the composed alternate-icon seam (persist → repository;
    /// apply → the ONE UIApplication touch point; fire → the consent-gated
    /// service). `nil` until the deferred start completes, like `repository`.
    private(set) var appIconSwitcher: AppIconSwitcher?
    /// E7.1 (R24.2) — the app-wide entitlement model. `nil` while DORMANT (no
    /// operator RC key) — which IS the summary-CTA fall-through guarantee —
    /// and nil on the panic route forever (constructed only in the deferred
    /// start's live branch, post-frame, normal route). In-memory only (R23.3):
    /// this property is the whole app-side "entitlement store".
    private(set) var entitlementModel: EntitlementModel?
    /// E7.2 (R25.2) — the variant assigner behind the paywall presentation.
    /// Constructed ONLY alongside the entitlement model (the monetization
    /// vertical wakes as a unit — an assigner without an entitlement gate
    /// has no consumer), so it is nil while DORMANT and nil on the panic
    /// route forever (R25.12). With the Superwall key absent it is the
    /// bundled hard-arm assigner; `Superwall.configure` is never called.
    private(set) var paywallAssigner: (any VariantAssigning)?

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
            // E6.3 — the shield's discreet signal (fail-toward-privacy: a read
            // failure leaves nil = cover) + the composed icon seam. Strong captures
            // are cycle-free: the repository never references the switcher.
            discreetAnyActive = (try? repository.activeQuits())?.contains { $0.discreetMode }
            let switcher = AppIconSwitcher(
                persist: { try repository.setDiscreetIconId($0) },
                apply: AppIconComposition.makeLiveApply(),
                fireIconEnabled: {
                    repository.analyticsService.fire(.discreetModeEnabled(component: .icon))
                }
            )
            appIconSwitcher = switcher
            // R22.4 launch reconciliation, RESET-ONLY: an OS alternate icon that
            // outlived its persisted selection (a lost erase-path reset) heals to
            // primary; a persisted selection is never re-applied (no unprompted
            // system alert at launch).
            if AppIconReconciler.reconcile(
                osAlternateIconName: AppIconComposition.currentAlternateIconName,
                persistedIconID: repository.discreetIconId()
            ) == .resetToPrimary {
                Task { try? await switcher.resetToPrimary() }
            }
            // E7.1 (R24.2) — the DORMANT gate, the TelemetryDeck double-gate's
            // sibling: with no operator key NOTHING below exists — no
            // `Purchases.configure` (which alone fires network + persists an
            // anonymous ID, docs-verified 5.80.3), no adapter, no model — and
            // the summary CTA falls through to the dashboard. Live: configure
            // exactly once (post-frame, normal route only), the adapter behind
            // PaywallKit's caching provider, the consent-gated trial_started
            // sink (R24.6), and the erase→reset late-bind (R24.7 — the
            // ConsentReader precedent: the sink needs the repository's
            // analytics, so the entitlement stack builds AFTER the repository).
            let apiKey = RevenueCatConfiguration.revenueCatAPIKey
            if !apiKey.isEmpty {
                let source = MonetizationComposition.makeEntitlementSource(
                    apiKey: apiKey,
                    configureRevenueCat: { RevenueCatEntitlementSource.configure(apiKey: apiKey) },
                    makeAdapter: { RevenueCatEntitlementSource() }
                )
                let entitlementProvider = CachingEntitlementProvider(
                    source: source,
                    events: TrialStartedAnalyticsSink(
                        analytics: repository.analyticsService,
                        dedupe: TrialAnalyticsDedupeStore()
                    )
                )
                repository.bindEntitlementReset { try await entitlementProvider.reset() }
                let model = EntitlementModel(provider: entitlementProvider)
                entitlementModel = model
                Task { await model.refresh() }
                // E7.2 (R25.2) — the Superwall DORMANT gate, the RC gate's
                // twin: with the Superwall key EMPTY this vends the bundled
                // hard-arm assigner and `Superwall.configure` is NEVER
                // called (configure alone fetches remote config + mints an
                // anonymous identity — docs-verified 4.16.1). The Superwall
                // key only matters once THIS RC-keyed branch runs: the
                // monetization vertical wakes as a unit (operator-expected
                // §8 orders the two keys).
                let superwallKey = SuperwallConfiguration.superwallAPIKey
                paywallAssigner = PaywallPresentationComposition.makeAssigner(
                    apiKey: superwallKey,
                    configureSuperwall: { SuperwallVariantAssigner.configure(apiKey: superwallKey) },
                    makeAdapter: { SuperwallVariantAssigner() }
                )
            }
        } catch {
            // §9 blocking class: a store that cannot open (or recompute) leaves the
            // repository nil and the placeholder UI standing. The full-screen
            // recovery flow (CloudKit re-hydration → offer erase-and-restart) is a
            // later epic's deliberate feature — nothing to silently retry here.
        }
    }

    /// E6.3 — re-reads the discreet-any signal after a toggle (the settings screen
    /// calls this beside `setDiscreetMode`; erase paths recompute on next launch).
    func refreshDiscreetSignal() {
        guard let repository else { return }
        discreetAnyActive = (try? repository.activeQuits())?.contains { $0.discreetMode }
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
        // The ADR-8 double gate: consent now reads the STORED choice live (E8.2 —
        // `AppSettings.analyticsOptIn`, written only by the quiz's consent step,
        // default OFF, fail-closed), AND the transport stays Noop until the
        // operator drops the TelemetryDeck app ID (operator-expected §8). Zero
        // events before consent, by construction.
        let appID = AnalyticsConfiguration.telemetryDeckAppID
        let sink: any AnalyticsSink
        if appID.isEmpty {
            sink = NoopAnalyticsSink()
        } else {
            sink = TelemetryDeckSink(appID: appID)
        }
        // The consent closure needs the repository, but the service is a
        // repository constructor arg — the late-bound holder breaks the cycle.
        // Fail-closed default until the reference lands; `isOptedIn` is only ever
        // evaluated lazily inside fire(), post-frame, so the one-statement gap
        // between construction and binding is unreachable.
        let consent = ConsentReader()
        let repository = QuitRepository(
            container: container,
            clock: LiveClock(),
            widgetRefresher: LiveWidgetRefresher(),
            lastKnownGoodStore: LastKnownGoodStore(defaults: groupDefaults),
            cloud: LocalOnlyCloudSync(),
            appGroupDefaults: groupDefaults,
            panicSnapshotStore: PanicSnapshotStore.appGroup()!,
            analytics: AnalyticsService(sink: sink, isOptedIn: { consent.read() })
        )
        // weak: the repository owns the service whose closure owns this reader —
        // a strong reference back would cycle.
        consent.read = { [weak repository] in repository?.isAnalyticsOptedIn() ?? false }
        return repository
    }
}

/// E8.2 — the composition root's late-bound consent read (see `liveRepository`).
/// The repository's `isAnalyticsOptedIn()` stays the ONE AppSettings read
/// authority; this holder only defers the reference, never forks the read.
private final class ConsentReader {
    var read: () -> Bool = { false }
}
