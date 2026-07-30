import Foundation
import Testing
@testable import Ballast

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

    /// QW-4 — the panic entry's label pair stays byte-identical to the Control
    /// Center control pair (`PanicControlStyle`): "Panic"/"Reset" is ONE
    /// cross-surface vocabulary (copy doc §6), and a future edit to either
    /// surface must be a deliberate two-place change, never a silent divergence.
    @Test func test_panicEntryLabels_areByteIdenticalToPanicControlStyle() {
        #expect(DashboardCopy.panicEntryLabel == PanicControlStyle.standard.title)
        #expect(DashboardCopy.panicEntryLabel == "Panic")
        #expect(DashboardCopy.panicEntryDiscreetLabel == PanicControlStyle.discreet.title)
        #expect(DashboardCopy.panicEntryDiscreetLabel == "Reset")
    }

    /// QW-4 — the support lines carry the copy doc §6 bytes verbatim: hedged
    /// ("About"), urgency-free, and the discreet line habit-context-free.
    ///
    /// S50 (S49 audit §3.2) — the discreet line is now CROSS-PINNED to the panic script,
    /// not just literal-pinned. `DashboardCopy.panicEntryDiscreetSupportLine`'s own
    /// docstring claims it is "byte-identical to the panic script's discreet entry title
    /// — one phrase, both surfaces", and nothing enforced that: editing
    /// `panicScript.json` would redden `PanicFlowTests` while leaving the dashboard
    /// button silently divergent. The sibling `panicEntryDiscreetLabel` test above
    /// already does both (cross-pin to `PanicControlStyle.discreet.title` AND literal);
    /// this now matches it.
    @Test func test_panicEntrySupportLines_carryTheSignedBytes() throws {
        let script = try #require(
            PanicScript.loadShipping(),
            "the shipping panicScript.json must bundle and decode for the cross-pin"
        )
        #expect(DashboardCopy.panicEntryDiscreetSupportLine == script.entryTitleDiscreet)
        #expect(DashboardCopy.panicEntrySupportLine == "One tap. About 90 seconds.")
        #expect(DashboardCopy.panicEntryDiscreetSupportLine == "Take a moment.")
    }

    /// P2 — the Home shell's title carries the copy doc §6 byte (DRAFT,
    /// operator-instructed, founder pass pending): habit-neutral,
    /// shoulder-safe, one title for every state. The habit-leak scan makes the
    /// disguise-safety machine-checked.
    @Test func test_screenTitle_isTheDraftByte_andHabitNeutral() {
        #expect(DashboardCopy.screenTitle == "Today")
        let leak = [
            "vape", "vaping", "porn", "alcohol", "weed", "doomscroll",
            "smoke", "drink", "sober", "quit", "addiction", "relapse", "habit",
            "ballast",
        ]
        for term in leak {
            #expect(
                !DashboardCopy.screenTitle.lowercased().contains(term),
                "the Home title must stay shoulder- and disguise-safe — never '\(term)'"
            )
        }
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
