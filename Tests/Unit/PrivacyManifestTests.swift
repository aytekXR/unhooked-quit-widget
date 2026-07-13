import Foundation
import Testing
@testable import Unhooked

// R30.6 unit lane — the PrivacyInfo.xcprivacy presence/key-set pins (Session 31).
//
// Apple's per-executable rule (docs, fetched 2026-07-14): "For each executable or
// dynamic library in an app that uses a required reason API, the bundle that includes
// the executable or dynamic library needs to include a privacy manifest file that
// reports the API." Both of our executables use one:
// - APP: UserDefaults via `.standard` (TrialAnalyticsDedupeStore/QuizProgressStore/
//   UnhookedApp erase sweep → CA92.1) AND via the App-Group suite (launch paths,
//   panic witness, repository, PanicLaunchFlag → 1C8F.1).
// - WIDGET .appex: App-Group UserDefaults ONLY, reached via Shared/PanicLaunchFlag
//   from the extension-side panic intents → 1C8F.1 alone; CA92.1 must NEVER appear
//   in the widget manifest (no `.standard` compiles into that executable).
//
// Pin shape (S31 STEP-0, the R30.2 lineage):
// - BORN-GREEN in the same commit as the manifests, with the "gate gates itself"
//   calibration below (fire/pass fixtures) + the pre-push Linux rehearsal over the
//   exact shipping bytes ×3 host timezones — the designed red's only unique product
//   (fires-on-absence) is fully reproduced there for free.
// - The APP manifest is read from the BUILT BUNDLE (`Bundle.main`) — a repo-tree
//   read would go false-green on authored-but-unbundled, the exact rejection class
//   R30.6 exists to prevent.
// - The WIDGET manifest cannot be seen by app-host Bundle.main (the S30
//   CFBundleDisplayName lesson; the fragile builtInPlugInsURL traversal stays
//   rejected). Its pins are: the authored repo-tree bytes (via #filePath — the
//   host-filesystem mechanics the snapshot lane already relies on) + the project.yml
//   wiring entry. The "did the .appex actually bundle it" residual is closed by CI
//   building the .appex from that wiring, not by this unit pin — stated honestly.
// - Key-SET semantics throughout (the standing JSON-pin rule, plist analog): exact
//   top-level key set (an unexpected key is App Store Connect's invalid-manifest
//   rejection class), exact {category → reason-set} map, exact collected-row map.
//   Adding any manifest key later is a deliberate two-place edit (manifest + pin).
// - The collected-data half mirrors docs/app-privacy-label.md's three LIVE rows
//   (R30.4 lockstep; re-derives with the label — incl. if counsel repicks the OQ-2
//   Health taxonomy). The widget's collected half is honestly EMPTY (the widget can
//   never fire analytics, standing rule).

@Suite("R30.6 · privacy manifest pins")
struct PrivacyManifestTests {

    // MARK: - The docs-verbatim expectations (spellings fetched 2026-07-14)

    private static let expectedTopLevelKeys: Set<String> = [
        "NSPrivacyTracking",
        "NSPrivacyCollectedDataTypes",
        "NSPrivacyAccessedAPITypes",
    ]

    private static let userDefaultsCategory = "NSPrivacyAccessedAPICategoryUserDefaults"

    private static let appAccessedExpectation: [String: Set<String>] = [
        "NSPrivacyAccessedAPICategoryUserDefaults": ["CA92.1", "1C8F.1"],
    ]
    private static let widgetAccessedExpectation: [String: Set<String>] = [
        "NSPrivacyAccessedAPICategoryUserDefaults": ["1C8F.1"],
    ]

    private struct CollectedRow: Equatable {
        let linked: Bool
        let tracking: Bool
        let purposes: Set<String>
    }

    private static let appCollectedExpectation: [String: CollectedRow] = [
        "NSPrivacyCollectedDataTypeProductInteraction":
            CollectedRow(linked: false, tracking: false,
                         purposes: ["NSPrivacyCollectedDataTypePurposeAnalytics"]),
        "NSPrivacyCollectedDataTypeHealth":
            CollectedRow(linked: false, tracking: false,
                         purposes: ["NSPrivacyCollectedDataTypePurposeAnalytics"]),
        "NSPrivacyCollectedDataTypePurchaseHistory":
            CollectedRow(linked: false, tracking: false,
                         purposes: ["NSPrivacyCollectedDataTypePurposeAppFunctionality",
                                    "NSPrivacyCollectedDataTypePurposeAnalytics"]),
    ]

    // MARK: - Pure extractors (no assertions inside — the calibration pins below
    // must be able to observe a detection WITHOUT failing the test)

    /// nil when the accessed-API array is missing or any entry violates the
    /// documented dictionary shape (exact per-entry key set, non-empty reasons).
    private static func accessedAPIMap(of root: [String: Any]) -> [String: Set<String>]? {
        guard let entries = root["NSPrivacyAccessedAPITypes"] as? [[String: Any]] else { return nil }
        var map: [String: Set<String>] = [:]
        for entry in entries {
            guard Set(entry.keys) == ["NSPrivacyAccessedAPIType", "NSPrivacyAccessedAPITypeReasons"],
                  let category = entry["NSPrivacyAccessedAPIType"] as? String,
                  let reasons = entry["NSPrivacyAccessedAPITypeReasons"] as? [String],
                  !reasons.isEmpty
            else { return nil }
            map[category] = Set(reasons)
        }
        return map
    }

    /// nil when the collected-data array is missing or any row violates the
    /// documented dictionary shape (exact per-row key set, non-empty purposes).
    private static func collectedRowMap(of root: [String: Any]) -> [String: CollectedRow]? {
        guard let entries = root["NSPrivacyCollectedDataTypes"] as? [[String: Any]] else { return nil }
        var rows: [String: CollectedRow] = [:]
        for entry in entries {
            guard Set(entry.keys) == ["NSPrivacyCollectedDataType",
                                      "NSPrivacyCollectedDataTypeLinked",
                                      "NSPrivacyCollectedDataTypeTracking",
                                      "NSPrivacyCollectedDataTypePurposes"],
                  let type = entry["NSPrivacyCollectedDataType"] as? String,
                  let linked = entry["NSPrivacyCollectedDataTypeLinked"] as? Bool,
                  let tracking = entry["NSPrivacyCollectedDataTypeTracking"] as? Bool,
                  let purposes = entry["NSPrivacyCollectedDataTypePurposes"] as? [String],
                  !purposes.isEmpty
            else { return nil }
            rows[type] = CollectedRow(linked: linked, tracking: tracking, purposes: Set(purposes))
        }
        return rows
    }

    private static func manifestRoot(from data: Data) throws -> [String: Any] {
        try #require(
            try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
                as? [String: Any],
            "the manifest must decode to a top-level plist dictionary"
        )
    }

    /// Repo root from this file's compile-time path (Tests/Unit/<file> → up 3) —
    /// the same host-filesystem reach the snapshot lane's golden files use.
    private static var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    // MARK: - The APP manifest: read what actually SHIPS

    @Test func test_appManifest_shipsAtBundleRoot_withTheVerifiedKeySets() throws {
        let url = try #require(
            Bundle.main.url(forResource: "PrivacyInfo", withExtension: "xcprivacy"),
            "PrivacyInfo.xcprivacy must ship at the app bundle root — Apple rejects required-reason-API apps without it (R30.6)"
        )
        let root = try Self.manifestRoot(from: Data(contentsOf: url))

        #expect(
            Set(root.keys) == Self.expectedTopLevelKeys,
            "the app manifest's top-level key set drifted — an unexpected key is ASC's invalid-manifest rejection class; a new key is a deliberate two-place edit (manifest + this pin)"
        )
        #expect(root["NSPrivacyTracking"] as? Bool == false, "NSPrivacyTracking is FALSE, always — no ATT surface exists")

        let accessed = try #require(Self.accessedAPIMap(of: root), "the accessed-API array must hold the documented entry shape")
        #expect(
            accessed == Self.appAccessedExpectation,
            "the app executable's verified reason set is UserDefaults [CA92.1 app-standard, 1C8F.1 App-Group] — exactly, nothing else (S31 sweep)"
        )

        let collected = try #require(Self.collectedRowMap(of: root), "the collected-data array must hold the documented row shape")
        #expect(
            collected == Self.appCollectedExpectation,
            "the collected-data half mirrors docs/app-privacy-label.md's three LIVE rows (R30.4 lockstep) — it re-derives with the label, never independently"
        )
    }

    // MARK: - The WIDGET manifest: authored bytes + wiring (Bundle.main cannot see the .appex)

    @Test func test_widgetManifest_authoredBytes_are1C8F1Only_andWiredIntoTheAppexTarget() throws {
        let manifestURL = Self.repoRoot
            .appendingPathComponent("Widgets/Resources/PrivacyInfo.xcprivacy")
        let data = try #require(
            try? Data(contentsOf: manifestURL),
            "the widget .appex needs its OWN manifest — its executable reaches App-Group UserDefaults via Shared/PanicLaunchFlag (R30.6)"
        )
        let root = try Self.manifestRoot(from: data)

        #expect(Set(root.keys) == Self.expectedTopLevelKeys, "the widget manifest's top-level key set drifted")
        #expect(root["NSPrivacyTracking"] as? Bool == false, "NSPrivacyTracking is FALSE, always")

        let accessed = try #require(Self.accessedAPIMap(of: root), "the accessed-API array must hold the documented entry shape")
        #expect(
            accessed == Self.widgetAccessedExpectation,
            "the widget executable's verified reason set is UserDefaults [1C8F.1] — exactly"
        )
        #expect(
            accessed[Self.userDefaultsCategory]?.contains("CA92.1") == false,
            "CA92.1 must NEVER enter the widget manifest — no .standard compiles into the .appex; copying the app's reason set would mis-state what this executable does"
        )

        let collected = try #require(Self.collectedRowMap(of: root), "the collected-data array must decode (empty is the expected state)")
        #expect(collected.isEmpty, "the widget collects NOTHING — it can never fire analytics (standing rule)")

        // The wiring half: the project.yml entry is what lands the file at the
        // .appex bundle root (the S30 project.yml-rehearsal precedent — no fragile
        // builtInPlugInsURL traversal). CI's xcodegen+build closes the residual.
        let yml = try #require(
            try? String(contentsOf: Self.repoRoot.appendingPathComponent("project.yml"), encoding: .utf8),
            "project.yml must be readable from the repo tree"
        )
        let widgetBlockStart = try #require(yml.range(of: "\n  UnhookedWidgets:\n"), "the widget target block must exist")
        let widgetBlockEnd = try #require(yml.range(of: "\n  UnhookedTests:\n"), "the tests target block bounds the widget block")
        let widgetBlock = yml[widgetBlockStart.upperBound..<widgetBlockEnd.lowerBound]

        let pathEntry = try #require(
            widgetBlock.range(of: "- path: Widgets/Resources/PrivacyInfo.xcprivacy"),
            "the widget manifest must be wired into the UnhookedWidgets target"
        )
        let window = widgetBlock[pathEntry.upperBound...].prefix(80)
        #expect(
            window.contains("buildPhase: resources"),
            "the widget manifest entry must carry buildPhase: resources — it is a resource, not a source"
        )

        let appBlockStart = try #require(yml.range(of: "\n  Unhooked:\n"), "the app target block must exist")
        let appBlock = yml[appBlockStart.upperBound..<widgetBlockStart.lowerBound]
        #expect(
            appBlock.contains("- path: App/Resources/PrivacyInfo.xcprivacy"),
            "the app manifest must be wired into the Unhooked target (Bundle.main above proves it LANDS; this pins the wiring source)"
        )
    }

    // MARK: - The gate gates itself (fire/pass calibration — the R30.2 shape)

    @Test func test_manifestPins_gateThemselves() throws {
        // PASS: the exact expected shapes report clean.
        let goodAccessed: [String: Any] = ["NSPrivacyAccessedAPITypes": [
            ["NSPrivacyAccessedAPIType": Self.userDefaultsCategory,
             "NSPrivacyAccessedAPITypeReasons": ["CA92.1", "1C8F.1"]] as [String: Any],
        ]]
        #expect(Self.accessedAPIMap(of: goodAccessed) == Self.appAccessedExpectation)

        // FIRE: a missing accessed-API array is a detected miss, never a silent pass.
        #expect(Self.accessedAPIMap(of: [:]) == nil)

        // FIRE: an entry with an unexpected key (ASC's invalid class) is detected.
        let extraKeyEntry: [String: Any] = ["NSPrivacyAccessedAPITypes": [
            ["NSPrivacyAccessedAPIType": Self.userDefaultsCategory,
             "NSPrivacyAccessedAPITypeReasons": ["1C8F.1"],
             "NSPrivacyAccessedAPITypeSurprise": true] as [String: Any],
        ]]
        #expect(Self.accessedAPIMap(of: extraKeyEntry) == nil)

        // FIRE: an empty reason array is a detected shape violation.
        let emptyReasons: [String: Any] = ["NSPrivacyAccessedAPITypes": [
            ["NSPrivacyAccessedAPIType": Self.userDefaultsCategory,
             "NSPrivacyAccessedAPITypeReasons": [String]()] as [String: Any],
        ]]
        #expect(Self.accessedAPIMap(of: emptyReasons) == nil)

        // FIRE: the widget expectation refuses the app's reason set (CA92.1 leak).
        let leakedCA92: [String: Any] = ["NSPrivacyAccessedAPITypes": [
            ["NSPrivacyAccessedAPIType": Self.userDefaultsCategory,
             "NSPrivacyAccessedAPITypeReasons": ["CA92.1", "1C8F.1"]] as [String: Any],
        ]]
        #expect(Self.accessedAPIMap(of: leakedCA92) != Self.widgetAccessedExpectation)

        // PASS: a well-shaped collected row round-trips.
        let goodCollected: [String: Any] = ["NSPrivacyCollectedDataTypes": [
            ["NSPrivacyCollectedDataType": "NSPrivacyCollectedDataTypeProductInteraction",
             "NSPrivacyCollectedDataTypeLinked": false,
             "NSPrivacyCollectedDataTypeTracking": false,
             "NSPrivacyCollectedDataTypePurposes": ["NSPrivacyCollectedDataTypePurposeAnalytics"]] as [String: Any],
        ]]
        #expect(Self.collectedRowMap(of: goodCollected)?.count == 1)

        // FIRE: a collected row missing its purposes is detected.
        let missingPurposes: [String: Any] = ["NSPrivacyCollectedDataTypes": [
            ["NSPrivacyCollectedDataType": "NSPrivacyCollectedDataTypeProductInteraction",
             "NSPrivacyCollectedDataTypeLinked": false,
             "NSPrivacyCollectedDataTypeTracking": false] as [String: Any],
        ]]
        #expect(Self.collectedRowMap(of: missingPurposes) == nil)

        // FIRE: the top-level key-set pin rejects an unauthored (even Apple-valid)
        // key — adding one is a deliberate two-place edit, never a drive-by.
        let extraTopLevel: Set<String> = Self.expectedTopLevelKeys.union(["NSPrivacyTrackingDomains"])
        #expect(extraTopLevel != Self.expectedTopLevelKeys)
    }
}
