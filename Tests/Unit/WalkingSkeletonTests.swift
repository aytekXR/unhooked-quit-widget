import Foundation
import PaywallKit
import StreakEngine
import Testing
import WidgetToolkit
@testable import Unhooked

/// E0.1–E0.3 unit lane. Test names are the doc-canonical ones from
/// implementation-plan.md Epic 0 — keep them verbatim.
@Suite("Epic 0 · walking skeleton")
struct WalkingSkeletonTests {
    // MARK: E0.1 — pipeline proof

    /// Placeholder that proves the Swift Testing unit lane executes in CI (E0.1).
    @Test func test_ci_runsSwiftTesting() {
        #expect(Bool(true), "Swift Testing unit lane is alive")
    }

    // MARK: E0.2 — targets, App Group, package wiring

    /// The app and widget extension must derive the same App Group container from the
    /// same shared constant, and the container must be writable (E0.2).
    @Test func test_appGroup_containerURL_isSharedBetweenTargets() throws {
        let container = try #require(
            AppIdentifiers.appGroupContainerURL,
            "App Group container must resolve from the shared AppIdentifiers constant"
        )

        // Writable sentinel — proves this is a real container path, not a guess.
        let sentinel = container.appendingPathComponent("e02-sentinel-\(UUID().uuidString).txt")
        try "walking-skeleton".write(to: sentinel, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: sentinel) }
        #expect(FileManager.default.fileExists(atPath: sentinel.path))

        // Both targets compile Shared/Sources — identical derivation means identical URL.
        let widgetSideDerivation = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: AppIdentifiers.appGroupID)
        #expect(container == widgetSideDerivation)
    }

    /// All three portfolio stub packages link into the app target and expose their
    /// entry points (E0.2).
    @Test func test_packages_linkAndExposeEntryPoints() {
        #expect(StreakEngine.version == "0.0.1-skeleton")
        #expect(WidgetToolkit.version == "0.0.1-skeleton")
        #expect(PaywallKit.version == "0.0.1-skeleton")
    }

    // MARK: E0.3 — panic launch path

    /// The widget-extension intent signals the app through App Group defaults; the
    /// flag logic lives in shared code so both targets agree on key and suite (E0.3).
    @Test func test_panicIntent_setsLaunchFlag_inAppGroupDefaults() throws {
        PanicLaunchFlag.clear()
        #expect(!PanicLaunchFlag.isSet())

        PanicLaunchFlag.set()
        #expect(PanicLaunchFlag.isSet(), "set() must persist the flag")

        // The flag must live in the App Group suite specifically — that is what makes
        // it visible across the extension/app process boundary.
        let groupDefaults = try #require(UserDefaults(suiteName: AppIdentifiers.appGroupID))
        #expect(groupDefaults.bool(forKey: PanicLaunchFlag.key))

        PanicLaunchFlag.clear()
        #expect(!PanicLaunchFlag.isSet())
    }

    /// Panic launches must skip the tab hierarchy and build the bare panic root (ADR-6).
    @Test func test_sceneRoot_whenPanicFlagSet_buildsPanicPlaceholderNotTabs() {
        #expect(LaunchRouter.resolveRoot(panicFlagIsSet: true) == .panicPlaceholder)
        #expect(LaunchRouter.resolveRoot(panicFlagIsSet: false) == .placeholderTabs)
    }
}
