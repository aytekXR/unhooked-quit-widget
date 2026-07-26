import Foundation
import Testing
@testable import Unhooked

// S50 unit lane — the direct-mount coherence lint. Every `UITEST_*` direct mount is TWO
// edits in TWO files, and forgetting the second one fails in the most expensive way this
// project has.
//
// A direct mount is declared in `PostGateRootView` as `private static var uiTest<X>Mount`.
// But `PostGateRootView` sits BEHIND the age gate, so on a FRESH install — which is the
// state of every clean CI simulator, and of any tester's phone — the gate stands in front
// of the mount and the branch is never reached. `AgeGateContainerView.uiTestOnboardingMount`
// is the hook that lets the launch through, and it is a hand-maintained allow-list.
//
// What that costs when it is missed: the audit leg's own gate assertion times out after 15
// seconds and reports *"the UITEST_X direct mount renders ..."*, which reads like the view
// is broken. It is not; the launch never got past the age gate. S50 lost a full billed
// macOS run (`30219477906`) to exactly this on both of its new legs — and the S40 attempt
// that was later reverted (`7d861d5`) had carried the one-line allow-list addition all
// along, so the information existed and was simply not carried forward.
//
// This lint makes that failure free and immediate instead of costing ~25 minutes of billed
// macOS time and a diagnosis. It is deliberately a SOURCE lint rather than a runtime check:
// the coupling is between two `#if DEBUG` static properties in two files, which no runtime
// test can see and no golden can capture.
//
// The contract is self-documenting: **if you name it `uiTest<X>Mount`, its env var must be
// in the allow-list.** `UITEST_PAYWALL` is correctly absent from both this scan and the
// allow-list — it is not a direct mount (it is read by `paywallDebugVariant` and modifies
// the paywall variant AFTER the real quiz→summary drive, so the operator passes the gate by
// hand, exactly as a user does).
//
// Born-green by construction (R31.4): pass-on-real-bytes AND fire-on-mutation were
// reproduced by an executed Linux harness over these exact bytes before this file was
// pushed; the calibration test carries the fire-on-mutation half permanently.
@Suite("S50 · UITEST direct-mount coherence")
struct UITestMountCoherenceTests {
    private static var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    /// Every env var read inside a `private static var uiTest…Mount` body — i.e. every
    /// declared DIRECT mount, and nothing else.
    static func directMountEnvVars(in source: String) -> Set<String> {
        var found: Set<String> = []
        var depth = 0
        var insideMount = false
        for line in source.components(separatedBy: "\n") {
            if !insideMount, line.contains("static var uiTest"), line.contains("Mount"), line.contains("{") {
                insideMount = true
                depth = 0
            }
            guard insideMount else { continue }
            if let name = envVarName(in: line) { found.insert(name) }
            depth += line.filter { $0 == "{" }.count
            depth -= line.filter { $0 == "}" }.count
            if depth <= 0 { insideMount = false }
        }
        return found
    }

    /// Every env var named anywhere in a source string.
    static func allEnvVars(in source: String) -> Set<String> {
        var found: Set<String> = []
        for line in source.components(separatedBy: "\n") {
            if let name = envVarName(in: line) { found.insert(name) }
        }
        return found
    }

    /// `environment["UITEST_FOO"]` -> `UITEST_FOO`. Only UITEST_ keys are of interest.
    private static func envVarName(in line: String) -> String? {
        guard let range = line.range(
            of: #"environment\["UITEST_[A-Z_]+"\]"#, options: .regularExpression
        ) else { return nil }
        let match = String(line[range])
        guard let open = match.firstIndex(of: "\""), let close = match.lastIndex(of: "\""),
              open < close else { return nil }
        return String(match[match.index(after: open)..<close])
    }

    @Test func test_everyDirectMountIsReachableThroughTheAgeGate() throws {
        let postGate = try String(
            contentsOf: Self.repoRoot.appendingPathComponent("App/Sources/Quiz/PostGateRootView.swift"),
            encoding: .utf8
        )
        let ageGate = try String(
            contentsOf: Self.repoRoot.appendingPathComponent("App/Sources/AgeGate/AgeGateContainerView.swift"),
            encoding: .utf8
        )

        let mounts = Self.directMountEnvVars(in: postGate)
        let allowed = Self.allEnvVars(in: ageGate)

        // Non-vacuity: if the scan finds no mounts the parse broke, and an empty set
        // trivially satisfies the subset check below.
        #expect(
            mounts.count >= 6,
            "found only \(mounts.count) direct mounts in PostGateRootView — the scan broke"
        )

        let unreachable = mounts.subtracting(allowed).sorted()
        #expect(
            unreachable.isEmpty,
            """
            these direct mounts are declared in PostGateRootView but are NOT in \
            AgeGateContainerView.uiTestOnboardingMount's allow-list, so on a FRESH install \
            the age gate stands in front of them and the branch is never reached. A UI test \
            gating on them will time out with a message that blames the view. Add each env \
            var to that allow-list:
            \(unreachable.joined(separator: "\n"))
            """
        )
    }

    /// The gate must gate itself: a coherence lint that cannot fire on the exact omission
    /// it was written for is worth nothing.
    @Test func test_calibration_scanFindsMountsAndFiresOnAnOmission() {
        let fakePostGate = """
        private static var uiTestQuizMount: Bool {
            #if DEBUG
            ProcessInfo.processInfo.environment["UITEST_QUIZ"] == "1"
            #else
            false
            #endif
        }

        private static var uiTestNewThingMount: Bool {
            #if DEBUG
            ProcessInfo.processInfo.environment["UITEST_NEW_THING"] == "1"
            #else
            false
            #endif
        }

        // Not a direct mount — read after the real funnel drive, so it needs no hook.
        private static var paywallDebugVariant: PaywallVariant? {
            switch ProcessInfo.processInfo.environment["UITEST_PAYWALL"] {
            case "1": .hard
            default: nil
            }
        }
        """
        let mounts = Self.directMountEnvVars(in: fakePostGate)
        // Both mounts are seen...
        #expect(mounts.contains("UITEST_QUIZ"))
        #expect(mounts.contains("UITEST_NEW_THING"))
        // ...and the non-mount is NOT, which is what makes the contract precise.
        #expect(!mounts.contains("UITEST_PAYWALL"))

        // A partial allow-list must leave the new mount detected as unreachable.
        let partialAllowList = Self.allEnvVars(in: """
        return environment["UITEST_QUIZ"] == "1"
        """)
        #expect(mounts.subtracting(partialAllowList) == ["UITEST_NEW_THING"])
        // A complete allow-list must leave nothing.
        let fullAllowList = Self.allEnvVars(in: """
        return environment["UITEST_QUIZ"] == "1"
            || environment["UITEST_NEW_THING"] == "1"
        """)
        #expect(mounts.subtracting(fullAllowList).isEmpty)
    }
}
