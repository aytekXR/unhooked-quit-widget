import SwiftUI
import Testing
@testable import Unhooked

// E6.3 unit lane — the app-switcher shield's PURE activation policy (PrivacyOverlayPolicy).
// I/O-free, so it pins here without the simulator; ScenePhase is a SwiftUI value type
// (docs-confirmed in E3.1's warm-launch lane — nothing new to docs-check). The policy is
// deliberately INERT at red (returns false always):
//   O1  — DESIGNED-RED: it must COVER for the snapshot phases + fail-toward-privacy on nil.
//   twins — born-green against the inert policy AND meaningful at green (the safe rows are
//           false in both worlds).
//
// This lane CANNOT run locally (@testable app import); its evidence is the parse-gate +
// the predicted manifest.

@Suite("E6.3 · privacy overlay policy")
struct PrivacyOverlayPolicyTests {

    // MARK: - O1 · the shield covers the snapshot surface when discreet (plan-named)

    @Test func test_appSwitcherOverlay_activeWhenDiscreet() {
        #expect(
            PrivacyOverlayPolicy.isActive(phase: .inactive, anyActiveQuitDiscreet: true),
            "inactive (the app-switcher snapshot phase) with a discreet quit ⇒ the shield covers — inert false at red"
        )
        #expect(
            PrivacyOverlayPolicy.isActive(phase: .background, anyActiveQuitDiscreet: true),
            "backgrounded with a discreet quit ⇒ the shield covers — inert false at red"
        )
        #expect(
            PrivacyOverlayPolicy.isActive(phase: .inactive, anyActiveQuitDiscreet: nil),
            "fail-toward-privacy: an INDETERMINATE discreet signal (store not yet open / pre-cache unreadable) still covers — inert false at red"
        )
    }

    // MARK: - twins · the shield stays down when the surface is safe (born-green)

    @Test func test_appSwitcherOverlay_inactiveWhenSafe() {
        #expect(
            !PrivacyOverlayPolicy.isActive(phase: .active, anyActiveQuitDiscreet: true),
            "active phase ⇒ never shielded (nothing is being snapshotted; the cold-launch first frame stays shield-free — ADR-6's budget untouched)"
        )
        #expect(
            !PrivacyOverlayPolicy.isActive(phase: .inactive, anyActiveQuitDiscreet: false),
            "affirmatively NON-discreet ⇒ no shield even in the snapshot phase (no motivations to hide)"
        )
        #expect(
            !PrivacyOverlayPolicy.isActive(phase: .active, anyActiveQuitDiscreet: nil),
            "active always wins over an indeterminate signal — the first frame is never gated"
        )
    }
}
