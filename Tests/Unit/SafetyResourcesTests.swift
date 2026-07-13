import Foundation
import Testing
@testable import Unhooked

// E9.1 unit lane — the safety layer's plan-named pins (implementation-plan §E9.1,
// mvp feature 11): the post-gate resources screen's composition, the GLOBAL region
// fallback, the alcohol-notice once-policy, the resources_viewed wire, and the
// helplines schema gate. Static-content fixtures are the SHIPPING bundled files,
// never copies (test-suite §3.2 names the helpline-region tests explicitly).
//
// RED (R27.14): the sibling selection/policy/model seams land INERT — rows() returns
// [], region() keeps the E5.1 unmapped→US semantics, shouldShow() returns false,
// viewed() fires nothing, and helplines.json has no GLOBAL region yet — so the four
// designed tests fail for exactly those reasons (8 predicted issues) and flip green
// when the seams go live. Never a crash, never a compile error.
//
// The S16 split, documented (R27.3): the AGE-GATE resources surface fires ZERO
// analytics on both branches (marking a blocked minor is privacy-adverse — the
// standing `test_ageGate_firesNoAnalyticsEvents` pin, untouched). THIS surface is
// reached by a consented, age-passed adult and fires `resources_viewed(source)` —
// the fire lives ONLY in the new post-gate view's model, never in AgeGate code.
// The source domain is CLOSED {settings, slip_flow}; the alcohol notice's
// "See resources" hand-off passes a nil source and fires nothing BY RULING (R27.4 —
// out-of-domain is honest-by-omission, not an undercount of the defined metric).

/// The proven spy shape (PaywallViewedWireTests/AnalyticsEventTests, file-private
/// by house rule — never a shared fixture).
@MainActor
private final class SpyAnalyticsSink: AnalyticsSink {
    private(set) var received: [AnalyticsEvent] = []
    func receive(_ event: AnalyticsEvent) { received.append(event) }
}

@MainActor
@Suite("E9.1 · safety resources")
struct SafetyResourcesTests {

    private func shippingDirectory() throws -> HelplineDirectory {
        try #require(
            HelplineDirectory.loadShipping(),
            "the shipping helplines.json must be bundled and decode AS-IS (§3.2)"
        )
    }

    private func shippingSafetyCopy() throws -> SafetyCopy {
        try #require(
            SafetyCopy.loadShipping(),
            "the shipping safetyCopy.json must be bundled and decode AS-IS (§3.2)"
        )
    }

    // MARK: - Plan-named test 1 · one-tap reachability (composition)

    /// "One tap from Settings and every slip flow" (mvp feature 11) — pinned at the
    /// composition tier (the house one-tap idiom: pure presentation + identifier
    /// presence in view code; the UI smoke stays frozen). Each entry point composes
    /// the SAME screen with its own injected source; a non-empty verified row set
    /// for the resolved region is what "reachable" delivers.
    @Test func test_resources_reachableFromSettingsAndSlipFlow_oneTap() throws {
        let directory = try shippingDirectory()
        let copy = try shippingSafetyCopy()
        let usLocale = Locale(identifier: "en_US")

        let fromSettings = SafetyResourcesPresentation.make(
            source: .settings, locale: usLocale, directory: directory, copy: copy
        )
        let fromSlipFlow = SafetyResourcesPresentation.make(
            source: .slipFlow, locale: usLocale, directory: directory, copy: copy
        )

        // The injected origin travels verbatim — the fork is the source, never the view.
        #expect(fromSettings.source == .settings)
        #expect(fromSlipFlow.source == .slipFlow)

        // DESIGNED RED ×2: the inert selection returns no rows — a US user must see
        // the verified US lines (988, SAMHSA, quitline, NAMI) from either entry.
        #expect(
            !fromSettings.rows.isEmpty,
            "the settings entry must surface the resolved region's verified helplines"
        )
        #expect(
            !fromSlipFlow.rows.isEmpty,
            "the slip-flow entry must surface the resolved region's verified helplines"
        )

        // Copy passthrough + the calm emergency note render on both (born-green).
        #expect(!fromSettings.title.isEmpty)
        #expect(!fromSettings.emergencyNote.isEmpty)
        #expect(fromSettings.footerDisclaimer?.isEmpty == false)
    }

    // MARK: - Plan-named test 2 · region fallback to GLOBAL

    /// R27.7: an unmapped device region reads the number-free GLOBAL bucket — never
    /// US numbers dressed as local resources. Asserts region RESOLUTION plus the
    /// GLOBAL region's decodable calm floor, never rendered unverified rows.
    @Test func test_helplines_regionFallbackToGlobal() throws {
        let directory = try shippingDirectory()

        // DESIGNED RED 1: the inert seam keeps the E5.1 unmapped→US semantics.
        #expect(
            SafetyResourcesSelection.region(for: Locale(identifier: "fr_FR"), in: directory) == "GLOBAL",
            "an unmapped region must fall back to GLOBAL on the post-gate screen (R27.7)"
        )

        // DESIGNED RED 2: the shipping directory must carry the GLOBAL bucket with
        // its calm local-emergency guidance (absent until green).
        #expect(
            directory.regions["GLOBAL"]?.emergencyNote.isEmpty == false,
            "helplines.json must ship a GLOBAL region with a calm emergency note (R27.7)"
        )

        // Mapped regions keep resolving to themselves (born-green — the E5.1
        // age-gate fallback stays unmapped→US on ITS surface, untouched by ruling).
        #expect(SafetyResourcesSelection.region(for: Locale(identifier: "en_US"), in: directory) == "US")
        #expect(SafetyResourcesSelection.region(for: Locale(identifier: "tr_TR"), in: directory) == "TR")
    }

    // MARK: - Plan-named test 3 · the alcohol notice once-policy

    /// R27.6: alcohol ANY goal mode (the reduce persona faces the same abrupt-
    /// cessation risk), once EVER app-wide. Pure policy — the AppSettings stamp
    /// and its erase sweep are pinned beside the field when it lands (green).
    @Test func test_alcoholNotice_shownOnceOnAlcoholQuitCreation() {
        // DESIGNED RED ×2: the inert policy never shows.
        #expect(
            AlcoholNoticePolicy.shouldShow(habitCategory: .alcohol, goalMode: .quit, alreadyShown: false),
            "a first alcohol QUIT goal must meet the withdrawal-danger notice (mvp feature 11)"
        )
        #expect(
            AlcoholNoticePolicy.shouldShow(habitCategory: .alcohol, goalMode: .reduce, alreadyShown: false),
            "a first alcohol REDUCE goal must meet the notice too (R27.6 — the Alex persona)"
        )

        // Once means once; other categories never trigger it (born-green at inert-false).
        #expect(!AlcoholNoticePolicy.shouldShow(habitCategory: .alcohol, goalMode: .quit, alreadyShown: true))
        #expect(!AlcoholNoticePolicy.shouldShow(habitCategory: .vape, goalMode: .quit, alreadyShown: false))
        #expect(!AlcoholNoticePolicy.shouldShow(habitCategory: .custom, goalMode: .reduce, alreadyShown: false))
    }

    // MARK: - Plan-named test 4 · the resources_viewed wire

    /// R27.3: once per PRESENTATION through the consent gate, source injected by the
    /// mount. Called twice per source — SwiftUI can re-run onAppear, and exactly one
    /// honest fire must survive.
    @Test func test_resourcesViewed_firesWithSource() throws {
        for source in ResourcesSource.allCases {
            let spy = SpyAnalyticsSink()
            let model = SafetyResourcesModel(
                analytics: AnalyticsService(sink: spy, isOptedIn: { true })
            )
            model.viewed(source)
            model.viewed(source)
            // DESIGNED RED ×2 (one per source): the inert model fires nothing.
            #expect(
                spy.received == [.resourcesViewed(source: source)],
                "one presentation = exactly one resources_viewed(\(source.rawValue)) fire"
            )
        }

        // The out-of-domain notice path fires NOTHING (R27.4 — nil source).
        let noticeSpy = SpyAnalyticsSink()
        let noticeModel = SafetyResourcesModel(
            analytics: AnalyticsService(sink: noticeSpy, isOptedIn: { true })
        )
        noticeModel.viewed(nil)
        #expect(noticeSpy.received.isEmpty, "the alcohol-notice hand-off is out of the closed source domain")

        // Consent gate (ADR-8): opted-out transmits nothing, ever.
        let gatedSpy = SpyAnalyticsSink()
        let gatedModel = SafetyResourcesModel(
            analytics: AnalyticsService(sink: gatedSpy, isOptedIn: { false })
        )
        gatedModel.viewed(.settings)
        #expect(gatedSpy.received.isEmpty)

        // The S16 inverse guard (R27.3): the age-gate blocked surface composes with
        // ZERO analytics coupling — a blocked minor is never marked — while THIS
        // surface (above) fires. The standing age-gate zero-fire pin stays untouched.
        let directory = try shippingDirectory()
        let blockedSpy = SpyAnalyticsSink()
        _ = AgeGateResources.blocked(region: "US", directory: directory)
        #expect(blockedSpy.received.isEmpty)
    }

    // MARK: - Plan-named test 5 · helplines schema (key-SET semantics, shipping bytes)

    /// JSONSerialization key-SET pins over the SHIPPING file — never byte equality,
    /// never a copy (§3.2). Superset-tolerant on the region set so green's GLOBAL
    /// addition is a strengthen, not an edit.
    @Test func test_helplinesJSON_matchesSchema() throws {
        let url = try #require(
            Bundle.main.url(forResource: "helplines", withExtension: "json"),
            "the shipping helplines.json must be bundled"
        )
        let root = try #require(
            try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any]
        )
        #expect(Set(root.keys) == ["_meta", "regions"], "top level: the audit note + the directory")

        let regions = try #require(root["regions"] as? [String: Any])
        let regionKeys = Set(regions.keys)
        #expect(regionKeys.isSuperset(of: ["US", "TR"]), "US and TR are the launch regions")

        let requiredRowKeys: Set<String> = [
            "id", "appliesTo", "name", "descr", "phoneDisplay", "dialString", "verified",
        ]
        let allowedRowKeys = requiredRowKeys.union([
            "altPhoneDisplay", "altDialString", "hours", "url", "textNote",
            "domesticOnly", "hoursVerified", "verifyNote",
        ])

        for key in regionKeys {
            let region = try #require(regions[key] as? [String: Any], "region \(key) must be an object")
            #expect(Set(region.keys) == ["displayName", "emergencyNote", "resources"], "region \(key)")
            #expect((region["displayName"] as? String)?.isEmpty == false)
            #expect((region["emergencyNote"] as? String)?.isEmpty == false)

            let rows = try #require(region["resources"] as? [[String: Any]], "region \(key) rows")
            for row in rows {
                let keys = Set(row.keys)
                #expect(keys.isSuperset(of: requiredRowKeys), "row \(row["id"] ?? "?") in \(key)")
                #expect(allowedRowKeys.isSuperset(of: keys), "unknown key in row \(row["id"] ?? "?")")
                #expect((row["id"] as? String)?.isEmpty == false)
                #expect((row["name"] as? String)?.isEmpty == false)
                #expect((row["descr"] as? String)?.isEmpty == false)
                #expect((row["phoneDisplay"] as? String)?.isEmpty == false)
                #expect((row["dialString"] as? String)?.isEmpty == false)
                #expect((row["appliesTo"] as? [String])?.isEmpty == false)
                #expect(row["verified"] is Bool, "verified must be an explicit Bool on every row")
            }
        }
    }

    // MARK: - Born-green duty-of-care guards

    /// The S15 wiring-session discipline: the closed wire domain, pinned.
    @Test func test_resourcesSource_wireValues_exactDomain() {
        #expect(Set(ResourcesSource.allCases.map(\.rawValue)) == ["settings", "slip_flow"])
    }

    /// Rule #12's post-gate twin of the S16 pin: an unverified number never renders
    /// on this surface either — a row joins only when the operator flips its flag.
    @Test func test_resourcesSelection_neverSurfacesUnverifiedRows() {
        let directory = HelplineDirectory(regions: [
            "US": HelplineDirectory.Region(
                displayName: "United States",
                emergencyNote: "In immediate danger? Call 911.",
                resources: [
                    HelplineDirectory.Helpline(
                        id: "fx_verified", appliesTo: ["all"], name: "Verified Line",
                        descr: "A verified line.", phoneDisplay: "988", dialString: "988",
                        verified: true
                    ),
                    HelplineDirectory.Helpline(
                        id: "fx_unverified", appliesTo: ["all"], name: "Unverified Line",
                        descr: "Awaiting the operator's official-source check.",
                        phoneDisplay: "000", dialString: "000",
                        verified: false
                    ),
                    HelplineDirectory.Helpline(
                        id: "fx_flagless", appliesTo: ["all"], name: "Flagless Line",
                        descr: "Absent reads as not verified.",
                        phoneDisplay: "111", dialString: "111",
                        verified: nil
                    ),
                ]
            ),
        ])
        let rows = SafetyResourcesSelection.rows(region: "US", in: directory)
        #expect(!rows.contains { $0.name == "Unverified Line" })
        #expect(!rows.contains { $0.name == "Flagless Line" })
    }
}
