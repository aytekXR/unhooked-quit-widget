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
