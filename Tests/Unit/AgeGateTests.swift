import Foundation
import SwiftData
import Testing
@testable import Unhooked

// E5.1 unit lane — the age gate is the app's FIRST screen (feasibility condition #6;
// roadmap "Minors in category"): birth-year entry, under-17 blocked to resources,
// only a boolean stored. Doc-canonical names from implementation-plan.md E5.1; the
// third is the Session 16 step-0 re-spec (`test_ageGate_firesNoAnalyticsEvents`):
// the plan's `age_gate_blocked` event is NOT an MVP §5 row and is structurally
// unfireable — consent lives POST-gate and is hardwired false until E8.2 — so the
// whole surface pins ZERO analytics instead (PM §5 + Architect step-0 ruling; a
// blocked minor is never marked).
//
// RED: `AgeGate.evaluate` routes every year onward, `AgeGateResources.blocked`
// returns an empty surface, and `AgeGateRouting.firstScreen` ignores the flag — the
// designed failures are the boundary/resources/routing assertions below plus the
// repository persist pin (QuitRepositoryTests): 7 failing cases, all inside E5.1
// tests, zero collateral to the existing 162. T2 (schema pin), T3 (zero-fire), the
// picker-range pin, and the lexicon scan are green-by-construction guards.
// Red evidence for this file = the CI run on the red commit.

/// The house spy shape, copied verbatim from AnalyticsEventTests (file-private
/// there by the no-shared-fixtures convention).
@MainActor
private final class SpyAnalyticsSink: AnalyticsSink {
    private(set) var received: [AnalyticsEvent] = []
    func receive(_ event: AnalyticsEvent) { received.append(event) }
}

@MainActor
@Suite("E5.1 · age gate")
struct AgeGateTests {

    // MARK: - T1 (doc-canonical): under-17 blocks AND the blocked surface IS resources

    @Test func test_ageGate_under17_blocksAndShowsResources() throws {
        // Blocks — the conservative boundary (PM §4, operator-vetoable): a year
        // difference of exactly 17 could still be a 16-year-old (birthday pending),
        // and "could be under 17" blocks.
        #expect(AgeGate.evaluate(birthYear: 2010, currentYear: 2026) == .blocked)
        #expect(AgeGate.evaluate(birthYear: 2009, currentYear: 2026) == .blocked)

        // …and shows resources: a blocked user LANDS on the region's verified
        // category-agnostic lines — never an empty wall, never an invented number.
        let blocked = AgeGateResources.blocked(region: "US")
        #expect(!blocked.rows.isEmpty, "a blocked minor lands ON resources, not a dead end")
        #expect(
            blocked.rows.contains { $0.dialString == "988" },
            "the US verified appliesTo-all line (988) is the guaranteed floor"
        )
        #expect(blocked.emergencyNote == "In immediate danger? Call 911.")

        // Every rendered number exists verbatim in the shipping directory.
        let shipping = try #require(
            HelplineDirectory.loadShipping(),
            "the shipping helplines.json must be bundled and decode as-is (§3.2)"
        )
        let usDials = Set(shipping.regions["US"]?.resources.map(\.dialString) ?? [])
        for row in blocked.rows {
            #expect(usDials.contains(row.dialString), "numbers render verbatim — never invented")
        }

        // TR: the verified appliesTo-all set (112 today; ALO 182 joins the moment
        // the operator's official-source check flips its `verified` flag).
        let turkish = AgeGateResources.blocked(region: "TR")
        #expect(turkish.rows.contains { $0.dialString == "112" })
    }

    /// The duty-of-care selection pin: an unverified number may NEVER render to a
    /// blocked minor (the directory's own `_meta` ruling — it deliberately EXCLUDED
    /// an unverified line rather than ship it). Operator-vetoable, Session 16.
    @Test func test_ageGate_blockedSurface_neverShowsUnverifiedNumbers() throws {
        let shipping = try #require(HelplineDirectory.loadShipping())
        for region in shipping.regions.keys {
            let verifiedDials = Set(
                shipping.regions[region]?.resources
                    .filter { $0.verified == true }
                    .map(\.dialString) ?? []
            )
            for row in AgeGateResources.blocked(region: region, directory: shipping).rows {
                #expect(
                    verifiedDials.contains(row.dialString),
                    "\(region): \(row.dialString) is not operator-verified — it may not face a blocked minor"
                )
            }
        }
    }

    // MARK: - The §4 boundary table, pinned (worked example at currentYear 2026)

    @Test(arguments: [
        (birthYear: 2008, expected: AgeGateDecision.pass), // min possible age 17 → pass
        (birthYear: 2009, expected: AgeGateDecision.blocked), // could be 16 → blocked
        (birthYear: 2010, expected: AgeGateDecision.blocked), // 16 at most → blocked
        (birthYear: 2026, expected: AgeGateDecision.blocked), // age 0 → blocked
    ])
    func test_ageGateDecision_boundaryTable(_ testCase: (birthYear: Int, expected: AgeGateDecision)) {
        #expect(AgeGate.evaluate(birthYear: testCase.birthYear, currentYear: 2026) == testCase.expected)
    }

    // MARK: - AC5: un-bypassability, the pre-gate half (the full navigation XCUITest
    // is Epic-5 DoD and rides E5.2's quiz — QA §4 ruling)

    @Test func test_ageGate_under17_neverRoutesToContent() {
        let currentYear = 2026
        for birthYear in (currentYear - 17)...currentYear {
            #expect(
                AgeGate.evaluate(birthYear: birthYear, currentYear: currentYear) == .blocked,
                "\(birthYear): a year that cannot prove 17+ must never pass"
            )
        }
    }

    @Test func test_ageGate_normalRoot_showsGateWhenNotPassed() {
        #expect(
            AgeGateRouting.firstScreen(ageGatePassed: false) == .ageGate,
            "fail-closed: habit content is reachable ONLY through a store-truth true"
        )
        #expect(AgeGateRouting.firstScreen(ageGatePassed: true) == .onward)
    }

    // MARK: - T2 (doc-canonical): the birth year is NEVER persisted

    @Test func test_ageGate_birthYearNeverPersisted() throws {
        let appSettings = try #require(
            PersistentStore.schema.entities.first { $0.name == "AppSettings" }
        )
        let attributeNames = Set(appSettings.attributes.map(\.name))
        #expect(
            attributeNames == [
                "analyticsOptIn", "discreetIconId", "hapticOnlyBreathPacer",
                "onboardingVariant", "teaserExpiresAt", "paywallVariantAssigned",
                "ageGatePassed", "lapseObservedAt", "alcoholNoticeShownAt",
            ],
            "AppSettings gains ONLY the ageGatePassed boolean — the birth year is a transient input, never a row (lapseObservedAt joined E7.3, R26.1 §7-approved — the win-back observed-lapse stamp; alcoholNoticeShownAt joined E9.1, R27.5 §7-approved — the alcohol-notice once-shown stamp)"
        )
        // Independent privacy pin: nothing age/birth/year-shaped may join later.
        // (Bare "age" is deliberately absent — it is a substring of the sanctioned
        // ageGatePassed; the exact-set equality above already forbids other fields.)
        for name in attributeNames {
            let lowered = name.lowercased()
            for forbidden in ["birth", "year", "dob", "born"] {
                #expect(
                    !lowered.contains(forbidden),
                    "\(name) is birth/year-shaped — only the yes/no answer may persist"
                )
            }
        }
        #expect(appSettings.relationships.isEmpty)
    }

    // MARK: - T3 (step-0 re-spec): the ENTIRE surface fires zero analytics

    @Test func test_ageGate_firesNoAnalyticsEvents() {
        let spy = SpyAnalyticsSink()
        // Opted-IN on purpose (Architect MUST-FIX #2): an opted-out service would
        // swallow any stray fire at the ADR-8 consent gate and prove nothing.
        let analytics = AnalyticsService(sink: spy, isOptedIn: { true })
        let model = AgeGateModel(analytics: analytics, currentYear: 2026)

        model.submit(birthYear: 2010) // blocked branch
        model.goBackToEntry()
        model.submit(birthYear: 2000) // passed branch

        #expect(
            spy.received.isEmpty,
            "the age gate transmits nothing on either branch — a blocked minor is never marked; a pass fires no gate event (onboarding_started belongs to E5.2's first quiz screen)"
        )
    }

    // MARK: - Picker range (PM §4: no future years, 120-year floor)

    @Test func test_ageGate_selectableYears_excludeFutureYears() {
        let years = AgeGateModel.selectableYears(currentYear: 2026)
        #expect(years.upperBound == 2026, "future years are unselectable")
        #expect(years.lowerBound == 1906)
    }
}
