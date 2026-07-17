import Foundation
import Testing
@testable import Unhooked

/// UIR-2 (Session 34) unit lane — the dashboard copy discipline gate.
///
/// UIR moves pixels, never words (roadmap §2.5). This suite proves the two facts that
/// keep the dashboard copy-byte-identical: the two audited labels stay byte-identical to
/// their `StreakWidgetStyle` origin (a §3 edit to one can never silently diverge the
/// other), and every §3-blocked slot stays EMPTY until the operator's founder pass signs
/// it — the instant one gains a value without that sign-off, the unit lane fails.
@Suite("UIR-2 · DashboardCopy discipline")
struct DashboardCopyTests {
    @Test func test_savedLabel_isByteIdenticalToStreakWidgetStyle() {
        #expect(DashboardCopy.savedLabel == StreakWidgetStyle.shipping.savedLabel)
        #expect(DashboardCopy.savedLabel == "saved")
    }

    @Test func test_milestoneLabel_isByteIdenticalToStreakWidgetStyle() {
        #expect(DashboardCopy.milestoneLabel == StreakWidgetStyle.shipping.milestoneLabel)
        #expect(DashboardCopy.milestoneLabel == "next milestone")
    }

    /// Every §3-blocked slot must be empty pre-pass. A non-empty value here means a new
    /// user-facing string reached the dashboard without the operator's §3 sign-off — the
    /// exact thing UIR is forbidden from doing. The view guards each with a non-empty
    /// check, so an empty slot renders nothing (never an empty `Text`).
    @Test func test_everyBlockedSlot_isEmptyUntilTheFounderPass() {
        #expect(DashboardCopy.frozenTooltip.isEmpty, "frozenTooltip must be empty until §3 signs it")
        #expect(DashboardCopy.emptyStateHeading.isEmpty, "emptyStateHeading must be empty until §3 signs it")
        #expect(DashboardCopy.emptyStateCTA.isEmpty, "emptyStateCTA must be empty until §3 signs it")
        #expect(DashboardCopy.reduceModeFraming.isEmpty, "reduceModeFraming must be empty until §3 signs it")
        #expect(
            DashboardCopy.composedLabel(dayNumber: 34, moneyText: "$412", momentumPercent: 82).isEmpty,
            "the composed VoiceOver sentence must be empty until §3 signs the framing template"
        )
    }
}
