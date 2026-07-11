import Foundation
import Testing
@testable import Unhooked

// Warm-launch regression lane — the two halves of the "Control Center tap does
// nothing" device finding (first real-device tap of the control family; the E0.3
// spike verified REGISTRATION only, its results table stayed pending):
//
//   1. TARGET MEMBERSHIP: the control/widget intents were compiled ONLY into the
//      widget extension, and iOS will not open the app for a control whose
//      `openAppWhenRun` intent isn't available to the app process. The compile-time
//      pin below is the regression test: this file builds against target Unhooked
//      (UnhookedTests links the app target only — the constraint PanicEntryPointTests
//      documents), so these references FAIL TO COMPILE if either intent ever moves
//      back out of the app target.
//   2. WARM CONSUMPTION: the app read the launch flag only in `UnhookedApp.init`
//      (ADR-6 cold route), so a panic launch landing on a RUNNING app was never
//      consumed. `WarmPanicEntry.resolve` is the post-frame gate; its pins are below.
//
// UserDefaults hygiene: identical to PanicEntryPointTests — the flag pins sweep the
// process-global App Group suite at entry AND in `defer`, and each body is fully
// synchronous on the main actor so the pins cannot interleave on the shared suite.

/// The pre-cache card fixture (per convention: each panic unit file owns its
/// file-private fixtures — no cross-file coupling).
private func card(
    _ label: String?,
    id: UUID = UUID(),
    discreet: Bool = false,
    motivations: [String] = []
) -> QuitSnapshot {
    QuitSnapshot(id: id, label: label, discreet: discreet, motivations: motivations)
}

/// Lock-guarded capture box for the notification observer (its block is @Sendable
/// under complete strict concurrency, so no mutable local can cross into it).
private final class SignalProbe: @unchecked Sendable {
    private let lock = NSLock()
    private var _flagAtSignal = false

    var flagAtSignal: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _flagAtSignal
    }

    func record(_ value: Bool) {
        lock.lock()
        defer { lock.unlock() }
        _flagAtSignal = value
    }
}

@MainActor
@Suite("Panic warm-launch matrix (control-family device fix)")
struct PanicWarmLaunchTests {

    // MARK: - Target membership (the compile-time half)

    /// The control-family intent must be a member of BOTH the app and widget-extension
    /// targets: iOS opens the app for a control tap only when the `openAppWhenRun`
    /// intent is available in the app's process. Referencing the type here is the
    /// regression pin (extension-only membership = this file stops compiling); the
    /// runtime expectations pin the launch contract itself.
    @Test func test_controlIntent_isAppTargetMember_andOpensApp() {
        #expect(
            OpenPanicControlIntent.openAppWhenRun,
            "a control tap must LAUNCH the app — without openAppWhenRun the intent runs headless and the full-screen reset never appears"
        )
        #expect(
            !OpenPanicControlIntent.isDiscoverable,
            "the discreet 'Reset' control rides this intent — a Shortcuts gallery action titled 'Panic' would out what it hides (§10)"
        )
    }

    /// Same membership pin for the lock-screen widget intent — it rides the identical
    /// openAppWhenRun launch mechanism and was equally extension-only before the fix.
    @Test func test_widgetIntent_isAppTargetMember_andOpensApp() {
        #expect(
            OpenPanicIntent.openAppWhenRun,
            "the lock-screen widget button must LAUNCH the app — same mechanism, same membership requirement as the control"
        )
    }

    // MARK: - Warm consumption gate

    /// A pending launch flag resolves to a mount: presentation from the SAME resolver
    /// the cold route uses, source read back verbatim — a warm Control Center launch
    /// must attribute `.controlCenter` exactly like a cold one.
    @Test func test_warmPanicEntry_flagSet_resolvesMountWithTrueSource() {
        PanicLaunchFlag.clear()
        defer { PanicLaunchFlag.clear() }

        let chosen = card("Vaping", motivations: ["For my kids"])
        PanicLaunchFlag.set(source: .controlCenter, quitID: chosen.id)

        let resolved = WarmPanicEntry.resolve(snapshot: PanicSnapshot(quits: [chosen]))

        #expect(
            resolved?.presentation == .breathe(chosen),
            "the warm gate resolves through PanicRouteResolver on the pre-cache — the quit selection written by perform() lands on ITS flow, exactly like cold"
        )
        #expect(
            resolved?.source == .controlCenter,
            "the TRUE origin survives the warm hop — a warm control launch that attributed anything else would resurrect the .lockscreenWidget fiction E3.3 killed"
        )
    }

    /// No pending flag, no mount: the gate must be a strict no-op on ordinary scene
    /// activations (every foreground pass through the dashboard hits it).
    @Test func test_warmPanicEntry_noFlag_resolvesNil() {
        PanicLaunchFlag.clear()
        defer { PanicLaunchFlag.clear() }

        #expect(
            WarmPanicEntry.resolve(snapshot: PanicSnapshot(quits: [card("Vaping")])) == nil,
            "without a pending launch flag the warm gate stays silent — scene activation alone must never mount the panic route"
        )
    }

    /// perform() posts the in-process signal AFTER the flag write, so an app-process
    /// intent run (the app-alive case iOS routes in-process) leaves the gate a
    /// complete launch instruction to consume the moment the signal lands.
    @Test func test_controlIntent_perform_armsFlagBeforeSignal() async throws {
        PanicLaunchFlag.clear()
        defer { PanicLaunchFlag.clear() }

        let probe = SignalProbe()
        let observer = NotificationCenter.default.addObserver(
            forName: PanicLaunchFlag.warmLaunchRequested, object: nil, queue: nil
        ) { _ in
            probe.record(PanicLaunchFlag.isSet())
        }
        defer { NotificationCenter.default.removeObserver(observer) }

        _ = try await OpenPanicControlIntent().perform()

        #expect(
            probe.flagAtSignal,
            "the flag must be armed BEFORE the warm signal posts — a signal that outruns its flag is a tap that does nothing, the exact device bug"
        )
        #expect(
            PanicLaunchFlag.launchSource() == .controlCenter,
            "the control intent's perform() writes its TRUE source on the same hop (existing E3.3 behavior, unweakened by the signal)"
        )
    }
}
