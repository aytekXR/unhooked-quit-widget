import SwiftUI

/// QW-2 (redesign §6.16 / §9.4) — the deliberate-confirm primitive: a destructive
/// action that requires a 600ms press-and-hold, visualized as a Low Sun ring that
/// FILLS while the user holds. Deliberateness without a countdown — the fill
/// measures the user's OWN press; nothing counts down against them (brand rule 4).
///
/// Structural kindness holds even on a destructive control: the chrome is amber
/// (`semantic/caution`), never red; the label rides a caution-on-sunken pair the
/// contrast registry already pins (4.65 L / 10.47 D — `caution text on sunken`),
/// so no new color pair enters the render path.
///
/// Assistive access is a FIRST-CLASS alternative, not a fallback: every assistive
/// technology gets a standard `Button` whose normal activation confirms (the redesign
/// §8 "standard double-activation alternative with an explicit hint") — a timed gesture
/// is never a gate for a non-visual user.
///
/// **S50 (S49 audit §1, HIGH) — that alternative is now STRUCTURAL rather than
/// DETECTED.** It used to be chosen by reading two `@Environment` flags:
/// `accessibilityVoiceOverEnabled` and `accessibilitySwitchControlEnabled`. The instinct
/// was right and the enumeration was incomplete — and it could never be completed:
///
///   * `accessibilityAssistiveAccessEnabled` exists (docs JSON 200, iOS 18+) and was
///     missing. Assistive Access is the mode built for users with cognitive
///     disabilities — precisely the population an accidental irreversible erase harms most.
///   * **Voice Control and Full Keyboard Access are not reportable by ANY Apple API.**
///     `accessibilityFullKeyboardAccessEnabled` returns HTTP 404 — it does not exist,
///     and neither `EnvironmentValues` nor `UIAccessibility` exposes an equivalent.
///
/// So the `else` branch was always reachable by *some* assistive user, and in it the
/// element advertised `.isButton` while offering no `.accessibilityAction` to receive
/// the activation — either erasing everything on a single activation (bypassing the
/// 600 ms deliberateness entirely) or dropping it, leaving the erase unreachable on a
/// control that calls itself a button.
///
/// `.accessibilityRepresentation` removes the enumeration problem instead of extending
/// it: touch keeps the hold, and the accessibility tree — for every technology, including
/// the ones iOS cannot report — sees exactly one standard `Button` whose
/// focus-then-activate IS the deliberate act. There is nothing left to leave off a list.
/// (`accessibilityRepresentation(representation:)`: docs JSON 200, iOS 15.0+, not
/// deprecated. Note the argument label is `representation:` — `content:` is a 404.)
struct HoldToConfirmButton: View {
    let label: String
    /// VoiceOver hint for the double-activation branch (DRAFT, founder-owned —
    /// routed through the caller's audited copy table, never authored here).
    let assistiveHint: String
    let accessibilityID: String
    /// M5 — ongoing-status indication while the confirmed action runs: the label
    /// swaps for an inline spinner, width locked (the PrimaryButton loading
    /// pattern). Defaulted so every existing call site stays byte-identical.
    var isLoading = false
    let action: () -> Void

    /// The hold duration — `Theme.motion.calm` (600ms) per the redesign motion
    /// table ("erase hold-fill" rides the calm token).
    private var holdDuration: TimeInterval { Theme.motion.calm }

    /// 0…1 fill of the Low Sun ring while the press is held.
    @State private var holdProgress: Double = 0

    var body: some View {
        chrome
            .onLongPressGesture(minimumDuration: holdDuration) {
                holdProgress = 0
                action()
            } onPressingChanged: { pressing in
                if pressing {
                    // The fill tracks the press linearly to the 600ms
                    // threshold — information (how far into the hold), not
                    // decoration, so it renders under Reduce Motion too.
                    withAnimation(.linear(duration: holdDuration)) {
                        holdProgress = 1
                    }
                } else {
                    // Released early: the ring quietly recedes. No failure
                    // state, no warning — the door simply stays open.
                    withAnimation(.easeOut(duration: Theme.motion.quick)) {
                        holdProgress = 0
                    }
                }
            }
            // S50 (S49 §1) — the one accessibility element every assistive technology
            // sees, detected or not: a standard Button. It REPLACES the drawn chrome in
            // the a11y tree (not in the raster), so `.isButton` is intrinsic and the
            // activation has a real receiver. The identifier and hint ride the
            // representation, keeping `erase.confirm.hold` queryable — note it now
            // surfaces as `.button`, so query it with `descendants(matching: .any)`.
            .accessibilityRepresentation {
                Button(action: action) { Text(label) }
                    .accessibilityHint(assistiveHint)
                    .accessibilityIdentifier(accessibilityID)
            }
    }

    /// Shared chrome: caution label on the sunken fill, Low Sun trim ring as the
    /// hold-progress indicator (zero-progress renders no ring — the goldens see a
    /// settled control).
    private var chrome: some View {
        ZStack {
            Text(label)
                .font(.body.weight(.semibold))
                .foregroundStyle(Theme.color.caution.color)
                .multilineTextAlignment(.center)
                // S50 (S49 §3.4 class) — the R33.12 item-4 invariant on every wrapping
                // `Text`. Inside the confirm stage's ScrollView the height is
                // unconstrained, so this grants the wrapped height without moving pixels
                // at the shipped sizes.
                .fixedSize(horizontal: false, vertical: true)
                // M5 width lock: the label keeps its layout, hidden, so the
                // control never resizes while the action runs (PrimaryButton:30).
                .opacity(isLoading ? 0 : 1)
            if isLoading {
                ProgressView()
                    .tint(Theme.color.contentSecondary.color)
            }
        }
        // 56pt-class target via PADDING, never a height floor (R33.5).
        .padding(.vertical, Theme.space.s5)
        .padding(.horizontal, Theme.space.s4)
        .frame(maxWidth: .infinity)
        .background(
            Theme.color.surfaceSunken.color,
            in: RoundedRectangle(cornerRadius: Theme.radius.m)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radius.m)
                .trim(from: 0, to: holdProgress)
                .stroke(
                    Theme.color.caution.color,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
        )
        .contentShape(Rectangle())
    }
}
// S50 — `HoldToConfirmChromeStyle` is deleted with the detection branch that was its
// only caller (no dead code, the S40 mount/env-var rule). The representation's Button
// is never rendered, so it needs no pressed style; the drawn chrome keeps its own
// hold-fill feedback.
