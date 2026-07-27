import Foundation
import StreakEngine
import Testing
@testable import Unhooked

// ME-3 (S51) unit lane — the unlock moment's two testable halves: the DERIVATION
// (`StreakDetailComposer.newlyUnlockedMilestone`, pure) and the COPY table's lexicon.
//
// The derivation was proven before push by an executed Linux harness over the real
// `milestones.json` ladder — 21 checks including the backdated-quit case and idempotence —
// because `Tests/Unit` is an Xcode target and cannot run on the Linux box (it
// `@testable import`s the app). These tests carry that evidence permanently on CI.

@Suite("ME-3 · milestone unlock derivation")
struct MilestoneUnlockDerivationTests {
    /// The real vape ladder's shape (12h → 1y), so the fixtures exercise the shipped
    /// spacing rather than a convenient one.
    private static let ladder: [Milestone] = [12, 24, 72, 168, 336, 720, 2160, 8760].map {
        Milestone(afterHours: $0, title: "T\($0)", body: "B\($0)")
    }
    private static let hour = 3_600

    @Test func test_nothingCrossed_yieldsNoMoment() {
        #expect(StreakDetailComposer.newlyUnlockedMilestone(
            elapsedSeconds: 0, milestones: Self.ladder, seenHours: []
        ) == nil)
        // One second before the first rung is still not the first rung.
        #expect(StreakDetailComposer.newlyUnlockedMilestone(
            elapsedSeconds: 12 * Self.hour - 1, milestones: Self.ladder, seenHours: []
        ) == nil)
    }

    /// Boundary-INCLUSIVE, matching `milestoneRows`' ratified StreakEngine semantics: the
    /// instant you are AT a rung, you have earned it.
    @Test func test_theExactBoundaryInstantEarnsTheRung() throws {
        let unlock = try #require(StreakDetailComposer.newlyUnlockedMilestone(
            elapsedSeconds: 12 * Self.hour, milestones: Self.ladder, seenHours: []
        ))
        #expect(unlock.row.afterHours == 12)
    }

    /// The steady state — one rung crossed since the last visit. Here "highest" and
    /// "lowest" agree, which is why the highest rule costs nothing in the common case.
    @Test func test_steadyState_oneRungSinceLastVisit() throws {
        let unlock = try #require(StreakDetailComposer.newlyUnlockedMilestone(
            elapsedSeconds: 24 * Self.hour, milestones: Self.ladder, seenHours: [12]
        ))
        #expect(unlock.row.afterHours == 24)
        #expect(unlock.hoursToStamp == [12, 24])
    }

    /// **The case the design exists for.** The quiz asks when the user stopped, so
    /// "I quit five days ago" backdates `startAt` and lands them past three rungs at once.
    /// Celebrating the LOWEST would greet them with a twelve-hour marker days behind where
    /// they are, then hand them one stale card per visit until the backlog drained.
    @Test func test_backdatedQuit_celebratesTheHighestRung_andStampsTheBacklog() throws {
        let unlock = try #require(StreakDetailComposer.newlyUnlockedMilestone(
            elapsedSeconds: 120 * Self.hour, milestones: Self.ladder, seenHours: []
        ))
        #expect(unlock.row.afterHours == 72, "the rung they are standing on, not the first one")
        #expect(unlock.row.afterHours != 12, "the stale-card bug")
        #expect(unlock.hoursToStamp == [12, 24, 72], "every crossed rung retires at once")
    }

    /// Once stamped, the same state is silent — the card is a moment, not a banner.
    @Test func test_afterStamping_theSameStateIsSilent() {
        let seen = [12, 24, 72]
        #expect(StreakDetailComposer.newlyUnlockedMilestone(
            elapsedSeconds: 120 * Self.hour, milestones: Self.ladder, seenHours: seen
        ) == nil)
        #expect(StreakDetailComposer.newlyUnlockedMilestone(
            elapsedSeconds: 120 * Self.hour + 1, milestones: Self.ladder, seenHours: seen
        ) == nil)
    }

    @Test func test_theNextRungAfterACatchUpFiresExactlyOnce() throws {
        let seen = [12, 24, 72]
        let unlock = try #require(StreakDetailComposer.newlyUnlockedMilestone(
            elapsedSeconds: 168 * Self.hour, milestones: Self.ladder, seenHours: seen
        ))
        #expect(unlock.row.afterHours == 168)
        #expect(StreakDetailComposer.newlyUnlockedMilestone(
            elapsedSeconds: 168 * Self.hour, milestones: Self.ladder, seenHours: seen + [168]
        ) == nil)
    }

    /// Degenerate inputs must be quiet, never trapping — a card is never worth a crash.
    @Test func test_degenerateInputsAreQuiet() {
        #expect(StreakDetailComposer.newlyUnlockedMilestone(
            elapsedSeconds: 999 * Self.hour, milestones: [], seenHours: []
        ) == nil)
        #expect(StreakDetailComposer.newlyUnlockedMilestone(
            elapsedSeconds: -5_000, milestones: Self.ladder, seenHours: []
        ) == nil)
        // A stamp for a rung that no longer exists in the ladder is harmless.
        #expect(StreakDetailComposer.newlyUnlockedMilestone(
            elapsedSeconds: 12 * Self.hour, milestones: Self.ladder, seenHours: [99_999]
        )?.row.afterHours == 12)
        // Ladder order is the composer's job, not the caller's.
        #expect(StreakDetailComposer.newlyUnlockedMilestone(
            elapsedSeconds: 120 * Self.hour, milestones: Self.ladder.reversed(), seenHours: []
        )?.row.afterHours == 72)
    }

    /// The celebrated row carries the SHIPPING catalog's bytes, hedge marker included.
    /// The marker's case and position vary across the catalog ("Commonly reported around
    /// now:" vs "This is commonly reported as…"), which is exactly why the card renders
    /// the body verbatim and never strips or re-prefixes it.
    @Test func test_everyShippedBodyCarriesTheHedgeMarker() throws {
        let catalog = try #require(MilestoneCatalog.loadShipping())
        var checked = 0
        for category in HabitCategory.allCases {
            for milestone in catalog.milestones(for: category) {
                checked += 1
                #expect(
                    milestone.body.lowercased().contains("commonly reported"),
                    "\(category)/\(milestone.afterHours)h lost its hedge marker: \(milestone.body)"
                )
            }
        }
        #expect(checked >= 40, "walked only \(checked) bodies — the catalog shrank implausibly")
    }
}

// MARK: - The copy table's lexicon

@Suite("ME-3 · milestone unlock copy")
struct MilestoneUnlockCopyTests {
    /// The STANDARD habit-leak lexicon (the `DiscreetSettingsCopyTests` list, verbatim).
    /// This card can appear on a screen someone else is looking at, so the shoulder test
    /// applies to every byte.
    private static let leakSubstrings: [String] = [
        "vape", "vaping", "porn", "alcohol", "weed", "doomscroll",
        "smoke", "drink", "sober", "quit", "addiction", "relapse", "habit",
    ]
    /// The shame register — the same list the slip and settings tables face. A milestone
    /// must never imply that not reaching it sooner was a failure.
    private static let shameSubstrings: [String] = [
        "failed", "failure", "failing", "blew it", "gave in",
        "ruined", "wasted", "thrown away", "you lost", "lost your streak",
        "back to day", "back to zero", "start over", "from scratch",
        "shame", "guilt", "weak", "willpower", "disappoint",
        "relapse", "temptation", "purity", "recover", "treatment",
    ]
    /// Apple's `.trait` audit fails a Button whose label restates its own trait — S50 hit
    /// this for real on a settings row. Both actions here are Buttons.
    private static let traitNouns = ["button", "image", "icon", "switch", "toggle", "graphic"]

    private static func folded(_ string: String) -> String {
        string.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            .split(whereSeparator: { $0.isWhitespace || $0.isNewline })
            .joined(separator: " ")
    }

    @Test func test_shippingCopy_isLeakAndShameFree_withNonVacuityFloor() {
        var collected: [String] = []
        for child in Mirror(reflecting: MilestoneUnlockCopy.shipping).children {
            guard let value = child.value as? String else { continue }
            collected.append(value)
            let haystack = Self.folded(value)
            for banned in Self.leakSubstrings {
                #expect(!haystack.contains(banned), "'\(banned)' leaked into: \(value)")
            }
            for banned in Self.shameSubstrings {
                #expect(!haystack.contains(banned), "shame register '\(banned)' in: \(value)")
            }
        }
        // 4 stored strings: eyebrow, doneLabel, seeAllLabel, discreetBody.
        #expect(
            collected.count >= 4,
            "the Mirror walk collapsed (<4) — a computed-property style would scan nothing"
        )
    }

    /// Both card actions render as Buttons, so neither label may restate a control trait.
    @Test func test_actionLabels_doNotRestateAControlTrait() {
        for label in [MilestoneUnlockCopy.shipping.doneLabel, MilestoneUnlockCopy.shipping.seeAllLabel] {
            let haystack = Self.folded(label)
            for noun in Self.traitNouns {
                #expect(
                    !haystack.contains(noun),
                    """
                    "\(label)" contains the control-type noun '\(noun)'. Apple's .trait audit \
                    fails a Button whose label restates its trait ("Label duplicates traits", \
                    run 30220337353). Re-word it; never paper over it with \
                    .accessibilityLabel, which breaks WCAG 2.5.3.
                    """
                )
            }
        }
    }

    /// The dismissal byte is deliberately SHARED with the app's other quiet dismissals —
    /// one word for one gesture, across every surface.
    @Test func test_dismissalByte_matchesTheAppsOtherQuietDismissals() {
        #expect(MilestoneUnlockCopy.shipping.doneLabel == DiscreetSettingsCopy.shipping.eraseCompletionDismissLabel)
        #expect(MilestoneUnlockCopy.shipping.doneLabel == "Done")
    }

    /// The discreet substitute is the copy-doc §9 byte verbatim, and it must name nothing.
    @Test func test_discreetBody_isTheSignedByte() {
        #expect(
            MilestoneUnlockCopy.shipping.discreetBody
                == "A marker worth noting. Your numbers tell the story."
        )
    }
}
