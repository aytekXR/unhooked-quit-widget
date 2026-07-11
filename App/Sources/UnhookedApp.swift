import OSLog
import SwiftUI

/// Walking-skeleton app entry point (E0.1–E0.3).
///
/// The launch path is deliberately thin (ADR-6): the root decision is made from the
/// App Group panic flag *before* the app graph is built, and nothing else (SwiftData,
/// RevenueCat, Superwall, analytics) initializes on this path — those SDKs arrive in
/// later epics and must stay off the pre-frame path (architecture §11).
@main
struct UnhookedApp: App {
    private let rootKind: RootKind
    private let panicPresentation: PanicPresentation
    private let panicSource: PanicSource
    /// Constructed pre-frame but does ZERO work until `startIfNeeded` (pinned by the
    /// PanicPathTests init-order spy); published to future consumers via environment.
    private let provider = RepositoryProvider()

    init() {
        PanicLaunchTrace.begin()
        // UI-test hook (E2.4 smoke, coverage-exempt scaffolding like FORCE_PANIC_ROUTE
        // below): seeds a panic launch flag, then runs the REAL local-erase helper —
        // the route resolution just after is the observable: erased state must land on
        // the fresh-install root, never the panic route. No SwiftData import here; the
        // helper only touches files + defaults (the sole-importer lint stays honest).
        if ProcessInfo.processInfo.environment["UITEST_SEED_PANIC_THEN_ERASE"] == "1",
           let groupDefaults = UserDefaults(suiteName: AppIdentifiers.appGroupID) {
            PanicLaunchFlag.set()
            try? QuitRepository.eraseLocalArtifacts(
                storeURLs: (try? PersistentStore.storeURL()).map { [$0] } ?? [],
                appGroupFileURLs: [
                    PanicSnapshotStore.appGroup()?.fileURL,
                    PanicOutcomeBuffer.appGroup()?.fileURL, // E3.2: mirrors eraseEverything's owned set
                ].compactMap { $0 },
                appGroupDefaults: groupDefaults
            )
        }
        // UI-test hook (E5.3 smoke, coverage-exempt scaffolding like the hooks above):
        // resets to a FRESH INSTALL before route resolution — the summary smoke
        // drives gate → quiz → quit and must be self-isolating in the shared CI
        // simulator (order-independence: it both REQUIRES a fresh install and
        // leaves a real quit behind). Same artifact set eraseEverything owns
        // locally, PLUS the app-standard quiz checkpoint (its sanctioned home is
        // outside the App Group by design — R5).
        if ProcessInfo.processInfo.environment["UITEST_RESET"] == "1",
           let groupDefaults = UserDefaults(suiteName: AppIdentifiers.appGroupID) {
            try? QuitRepository.eraseLocalArtifacts(
                storeURLs: (try? PersistentStore.storeURL()).map { [$0] } ?? [],
                appGroupFileURLs: [
                    PanicSnapshotStore.appGroup()?.fileURL,
                    PanicOutcomeBuffer.appGroup()?.fileURL,
                ].compactMap { $0 },
                appGroupDefaults: groupDefaults
            )
            UserDefaults.standard.removeObject(forKey: QuizProgressStore.key)
        }
        // UI-test hook (E3.1 smoke, coverage-exempt scaffolding like the hooks above):
        // seeds a two-quit panic snapshot into the App Group so the panic-route smoke
        // can assert picker resolution before any store or onboarding exists.
        if ProcessInfo.processInfo.environment["UITEST_SEED_PANIC_SNAPSHOT"] == "1",
           let snapshotStore = PanicSnapshotStore.appGroup() {
            try? snapshotStore.write(PanicSnapshot(quits: [
                QuitSnapshot(id: UUID(), label: "Vaping", discreet: false, motivations: ["For my kids"]),
                QuitSnapshot(id: UUID(), label: nil, discreet: true, motivations: ["Sleep better"]),
            ]))
        }
        // UI-test hook: lets XCUITest exercise the panic route without a widget tap.
        let forcedPanic = ProcessInfo.processInfo.environment["FORCE_PANIC_ROUTE"] == "1"
        rootKind = LaunchRouter.resolveRoot(panicFlagIsSet: forcedPanic || PanicLaunchFlag.isSet())
        // The panic branch resolves its content HERE, pre-frame, from the App Group
        // pre-cache alone — a few-KB synchronous JSON read, inside the §11 ≤200ms
        // content budget. The normal branch reads nothing.
        panicPresentation = rootKind == .panicPlaceholder
            ? PanicRouteResolver.resolve(
                selectedQuitID: PanicLaunchFlag.selectedQuitID(),
                snapshot: PanicSnapshotStore.appGroup()?.read()
            )
            : .empty
        // The launch's TRUE origin (E3.3), captured pre-frame on the same read — the
        // placeholder's onAppear consumes all flag keys. A flag with no source is a
        // legacy/pre-E3.3 writer (or the FORCE_PANIC_ROUTE test hook) and keeps the
        // historic lock-screen default; every shipping entry point writes one now.
        panicSource = rootKind == .panicPlaceholder
            ? (PanicLaunchFlag.launchSource() ?? .lockscreenWidget)
            : .lockscreenWidget
    }

    var body: some Scene {
        WindowGroup {
            switch rootKind {
            case .placeholderTabs:
                // E5.1: the age-gate container IS the normal root — it hosts
                // RootPlaceholderView only past a store-truth `ageGatePassed`
                // (fail-closed; feasibility condition #6: no habit content
                // reachable pre-gate). The panic branch below never mounts it.
                AgeGateContainerView()
                    .environment(provider)
                    // Post-first-frame by construction: `.task` runs after the frame
                    // commits — the ONE sanctioned path to store open + the launch
                    // derived-state pass (ADR-6). The provider is ALSO route-aware,
                    // so a mis-wired panic branch could still never open the store.
                    .task { provider.startIfNeeded(for: rootKind) }
            case .panicPlaceholder:
                PanicPlaceholderView(presentation: panicPresentation, source: panicSource)
            }
        }
    }
}

/// Signpost interval for the lock-to-intervention measurement (E0.3 spike; graduates
/// to a permanent CI gate in E3.1). Interval: app init → panic placeholder first appear.
@MainActor
enum PanicLaunchTrace {
    static let signposter = OSSignposter(subsystem: AppIdentifiers.loggingSubsystem, category: "PanicLaunch")
    private static var state: OSSignpostIntervalState?

    static func begin() {
        state = signposter.beginInterval("PanicColdLaunch")
    }

    static func endIfActive() {
        guard let state else { return }
        signposter.endInterval("PanicColdLaunch", state)
        Self.state = nil
    }
}
