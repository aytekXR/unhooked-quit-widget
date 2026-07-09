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
                appGroupDefaults: groupDefaults
            )
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
    }

    var body: some Scene {
        WindowGroup {
            switch rootKind {
            case .placeholderTabs:
                RootPlaceholderView()
            case .panicPlaceholder:
                PanicPlaceholderView()
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
