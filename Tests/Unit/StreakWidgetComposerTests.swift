import Foundation
import Testing
import WidgetToolkit
@testable import Unhooked

// E6.2 unit lane — the provider's testable core: StreakWidgetComposer selects ONE quit
// from the feed, maps it onto WidgetToolkit's domain-neutral planner state (in the
// quit's FIXED zone), computes milestone-crossing instants, and plans the timeline.
// It lives in Shared so this lane can pin it (the WidgetKit provider is a ~5-line shim
// over it — test-suite §2 "TimelineProviders tested" is met here, R5).
//
// Red evidence for this file = the CI run on the red commit: StreakWidgetComposer.compose
// is INERT at red (always the single .unavailable plan, quit == nil), so the streak/day/
// crossing pins (C2-positive, H1, H2, H4) fail honestly; the unavailable-shaped pins
// (C2-vanished twin, H3) are green-from-birth twins that the stub coincidentally
// satisfies and the real selection/mapping logic must keep satisfying.
//
// This lane CANNOT run locally (it @testable-imports the app module); its evidence is
// the parse-gate + the predicted manifest. Every instant is a fixed literal, computed
// empirically against the real tz database (test-suite §3.1: no production Date()).

// NY instants (America/New_York) — derived in a Linux scratch harness replicating the
// planner's noon-anchored day rule against the real tz database:
//   2026-01-01 12:00 EST  = 1_767_286_800   2026-01-08 12:00 EST = 1_767_891_600
//   2026-01-05 23:30 EST  = 1_767_673_800   (the SAME instant is 2026-01-06 in UTC)
private let janFirstNoonNY = Date(timeIntervalSince1970: 1_767_286_800)
private let janEighthNoonNY = Date(timeIntervalSince1970: 1_767_891_600)
private let janFifthLateNY = Date(timeIntervalSince1970: 1_767_673_800)

/// A rich feed card. Domain-relevant fields (spend/momentum) are present but immaterial
/// to timing pins; the FIXED zone and streakStart are what the day rule consumes.
private func card(
    id: UUID = UUID(),
    streakStart: Date,
    timeZoneIdentifier: String = "America/New_York",
    milestoneHours: [Int] = []
) -> WidgetQuitState {
    WidgetQuitState(
        id: id,
        streakStart: streakStart,
        timeZoneIdentifier: timeZoneIdentifier,
        weeklySpend: "26",
        currencyCode: "USD",
        bankedCleanSeconds: 0,
        momentumPercent: 50,
        milestoneHours: milestoneHours
    )
}

@Suite("E6.2 · streak widget composer (read → select → map → plan)")
struct StreakWidgetComposerTests {

    // MARK: - C2 · per-widget binding by UUID (no cross-contamination, R5)

    @Test func test_compose_configuredIDPresent_streakPlan_dayNumberFollowsADR11() {
        let configured = UUID()
        let feed = WidgetFeed(generatedAt: janEighthNoonNY, quits: [
            card(streakStart: janFirstNoonNY),                 // decoy at position 0
            card(id: configured, streakStart: janFirstNoonNY), // the configured quit
        ])

        let composition = StreakWidgetComposer.compose(
            feed: feed, configuredQuitID: configured, now: janEighthNoonNY, horizonDays: 1
        )

        #expect(composition.quit?.id == configured, "the configured UUID binds by id, never by position (the decoy at index 0 is not chosen)")
        #expect(composition.plan.entries.first?.kind == .streak)
        #expect(
            composition.plan.entries.first?.dayNumber == 8,
            "Day 8 = the ADR-11 calendar day in the quit's fixed America/New_York zone (2026-01-01 → 2026-01-08, noon-anchored)"
        )
    }

    @Test func test_compose_configuredIDVanished_isExactlyOneUnavailableEntry_noQuit() {
        // The green-from-birth twin of the pin above: a configured id no longer in the
        // feed must degrade to unavailable, never silently repoint at a different habit.
        let feed = WidgetFeed(generatedAt: janEighthNoonNY, quits: [
            card(streakStart: janFirstNoonNY),
            card(streakStart: janFirstNoonNY),
        ])

        let composition = StreakWidgetComposer.compose(
            feed: feed, configuredQuitID: UUID(), now: janEighthNoonNY, horizonDays: 1
        )

        #expect(composition.plan.entries.count == 1)
        #expect(
            composition.plan.entries.first?.kind == .unavailable,
            "a configured id no longer in the feed ⇒ unavailable — an erased/archived quit must never repoint a widget at another habit (mvp feature 5)"
        )
        #expect(composition.quit == nil, "no quit backs an unavailable plan — the templates render no habit content")
    }

    // MARK: - H1 · the unconfigured default (deterministic first quit)

    @Test func test_compose_nilConfiguredID_selectsFirstQuit_streakPlan() {
        let firstID = UUID()
        let feed = WidgetFeed(generatedAt: janEighthNoonNY, quits: [
            card(id: firstID, streakStart: janFirstNoonNY),
            card(streakStart: janFirstNoonNY),
        ])

        let composition = StreakWidgetComposer.compose(
            feed: feed, configuredQuitID: nil, now: janEighthNoonNY, horizonDays: 1
        )

        #expect(
            composition.quit?.id == firstID,
            "no configuration ⇒ the feed's first quit in the repository's total order — the deterministic experience for a freshly-added widget (R5)"
        )
        #expect(composition.plan.entries.first?.kind == .streak)
    }

    // MARK: - H2 · the day rolls in the quit's FIXED zone, never the rendering zone

    @Test func test_compose_dayRollsInQuitsFixedZone_notTheRenderingZone() {
        let configured = UUID()
        let feed = WidgetFeed(generatedAt: janFifthLateNY, quits: [
            card(id: configured, streakStart: janFirstNoonNY, timeZoneIdentifier: "America/New_York"),
        ])

        let composition = StreakWidgetComposer.compose(
            feed: feed, configuredQuitID: configured, now: janFifthLateNY, horizonDays: 1
        )

        #expect(
            composition.plan.entries.first?.dayNumber == 5,
            "Day 5 = the day at `now` in the quit's FIXED America/New_York zone; the SAME instant is 2026-01-06 in UTC (Day 6) — the day must never roll on the device/UTC boundary (ADR-11)"
        )
    }

    // MARK: - H3 · an invalid zone identifier ⇒ unavailable, never a device-zone guess

    @Test func test_compose_invalidTimeZoneIdentifier_isUnavailable_neverAGuess() {
        // The green-from-birth twin of H2: an unconstructable TimeZone(identifier:) has no
        // valid day boundary, so the composer must bail to unavailable rather than fall
        // back to the device zone (which would defeat the travel-immunity of the pin above).
        let configured = UUID()
        let feed = WidgetFeed(generatedAt: janEighthNoonNY, quits: [
            card(id: configured, streakStart: janFirstNoonNY, timeZoneIdentifier: "Not/AZone"),
        ])

        let composition = StreakWidgetComposer.compose(
            feed: feed, configuredQuitID: configured, now: janEighthNoonNY, horizonDays: 1
        )

        #expect(composition.plan.entries.count == 1)
        #expect(
            composition.plan.entries.first?.kind == .unavailable,
            "an unconstructable TimeZone(identifier:) ⇒ unavailable, never a device-zone guess"
        )
    }

    // MARK: - H4 · the composer feeds milestone crossings to the planner

    @Test func test_compose_passesMilestoneCrossingsToPlanner_entryAtStartPlus24h() {
        // now fixed; streakStart = now − 1h (so the [24h] rung is < 24h ahead, inside a
        // 2-day horizon). The composer computes crossing = streakStart + 24h and hands it
        // to the planner, which must emit an entry AT that instant so medium's bar/count
        // refreshes when the milestone lands (R4).
        let now = Date(timeIntervalSince1970: 1_781_539_200)
        let start = Date(timeIntervalSince1970: 1_781_535_600) // now − 1h
        let crossing = Date(timeIntervalSince1970: 1_781_622_000) // start + 24h
        let configured = UUID()
        let feed = WidgetFeed(generatedAt: now, quits: [
            card(id: configured, streakStart: start, timeZoneIdentifier: "America/New_York", milestoneHours: [24]),
        ])

        let composition = StreakWidgetComposer.compose(
            feed: feed, configuredQuitID: configured, now: now, horizonDays: 2
        )

        #expect(
            composition.plan.entries.contains { $0.date == crossing },
            "the composer computes crossing instants (streakStart + hours) and feeds them to the planner, so an entry EXISTS at start+24h — the composer→planner crossing wiring (R4)"
        )
    }
}
