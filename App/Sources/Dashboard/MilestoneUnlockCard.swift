import SwiftUI

/// ME-3 (S51, redesign §6.20) — the milestone unlock moment: the retention loop the app
/// has been carrying 43 pieces of content for without ever surfacing them.
///
/// **Structural kindness governs the whole surface.** It is a CARD, never a modal — a
/// milestone must not interrupt anything. It uses the *waterline rise* (the crest lifting
/// over its horizon line in one `Theme.motion.calm` breath) and one soft haptic: **never
/// confetti, never sound**. Nothing counts down, nothing is "achieved", nothing is lost by
/// dismissing it.
///
/// **Golden-safety follows `StreakRing` exactly** (R34.4): the rise is opt-in via
/// `animateOnAppear`, and when it is off the draw reads the settled values directly, so the
/// settled frame is byte-identical animated or not. Snapshot fixtures and any audit mount
/// therefore capture a settled card, this surface's goldens never move on a motion change,
/// and no mid-animation frame can be captured. The motion itself renders only at runtime,
/// so it carries an operator DEVICE-EYEBALL flag — a golden cannot verify motion.
///
/// **The discreet variant is a different card, not a dimmed one.** No crest, no eyebrow, no
/// Ember: a neutral `checkmark.circle` in `paused`, the time-only catalog title
/// ("12 hours"), and the copy-doc §9 line instead of the experiential body. That is the
/// shoulder test — a card visible to someone next to the user names nothing.
///
/// **The not-medical-care disclaimer rides the non-discreet card**, verbatim from
/// `safetyCopy.json`, exactly as `StreakDetailView` renders it. The catalog bodies are
/// hedged "commonly reported" experiential claims and that fragment is, in the words of
/// `StreakDetailView`'s own comment, "the one sanctioned hedge framing for this catalog"
/// — it is attached to the CATALOG, not to a screen. For a user who crosses a rung before
/// ever opening Streak Detail, this card is the first place those bytes are read, which is
/// precisely where the hedge matters. It is fail-safe: an absent or degraded table renders
/// nothing. The discreet card omits it because it renders no body to hedge.
struct MilestoneUnlockCard: View {
    /// The crossed rung, straight from `StreakDetailComposer` — catalog title and body
    /// verbatim. The hedge marker's case and position vary across the catalog
    /// ("Commonly reported around now:" vs "This is commonly reported as…"), so the body
    /// is rendered whole and never re-prefixed or trimmed.
    let row: MilestoneRowModel
    /// Discreet quits get the numbers-only variant (the `StreakDetailView` signed swap).
    let isDiscreet: Bool
    /// Opt-in waterline rise (live Home only). Off ⇒ settled draw, for goldens and audits.
    var animateOnAppear: Bool = false
    /// Retires this rung's moment. The host writes the durable stamp.
    let onDone: () -> Void
    /// Pass-through into the full timeline. nil hides the affordance — a host with no
    /// Streak Detail route must not offer a door to nowhere.
    var onSeeAll: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// Drives the rise; UNUSED when `animateOnAppear` is false (the draw reads the
    /// settled values then), so it can never leave the settled card stale.
    @State private var risen = false

    private let copy = MilestoneUnlockCopy.shipping
    /// The SIGNED not-medical-care fragment (§12 policy) — the same read
    /// `StreakDetailView:37` already ships. Absent table ⇒ the footer simply does not render.
    private let disclaimer = SafetyCopy.loadShipping()?.notMedicalCareDisclaimer

    /// Settled draw shows the risen state; animated draw reads the `@State`.
    private var isRisen: Bool { animateOnAppear ? risen : true }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space.s3) {
            if !isDiscreet {
                MilestoneCrestMark(risen: isRisen)
                Text(copy.eyebrow)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .fixedSize(horizontal: false, vertical: true)
            }
            titleRow
            Text(bodyText)
                .font(.subheadline)
                .foregroundStyle(Theme.color.contentSecondary.color)
                .fixedSize(horizontal: false, vertical: true)
            if !isDiscreet, let disclaimer, !disclaimer.isEmpty {
                // Verbatim, never redrafted here (§12) — the catalog's one sanctioned hedge.
                Text(disclaimer)
                    .font(.footnote)
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .fixedSize(horizontal: false, vertical: true)
            }
            actions
        }
        .padding(Theme.space.s4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .themedCard()
        .opacity(isRisen ? 1 : 0)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("milestoneUnlock.card")
        .onAppear {
            guard animateOnAppear else { return }
            // The waterline rise: ONE calm breath, or the quick crossfade under Reduce
            // Motion (the StreakDetailView / StreakRing idiom). No spring, no bounce.
            withAnimation(.easeOut(
                duration: reduceMotion ? Theme.motion.quick : Theme.motion.calm
            )) {
                risen = true
            }
        }
    }

    /// Title + its glyph. Ember (`accentFlame`) is GLYPH-ONLY and a11y-hidden — the
    /// sanctioned second spend of that colour, per `StreakDetailView:267`'s docstring —
    /// so no `Theme.contrastPairs` entry is owed. Discreet swaps to a neutral checkmark
    /// in `paused`, the same signed swap the timeline uses.
    private var titleRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.space.s3) {
            Image(systemName: isDiscreet ? "checkmark.circle" : "flame.fill")
                .font(.title3)
                .foregroundStyle(
                    isDiscreet
                        ? Theme.color.paused.color
                        : Theme.color.accentFlame.color
                )
                .accessibilityHidden(true)
            Text(titleText)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Theme.color.contentPrimary.color)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var actions: some View {
        HStack(spacing: Theme.space.s4) {
            Button(copy.doneLabel, action: onDone)
                .buttonStyle(QuietButtonStyle())
                .accessibilityIdentifier("milestoneUnlock.done")
            if let onSeeAll {
                Button(copy.seeAllLabel, action: onSeeAll)
                    .buttonStyle(QuietButtonStyle())
                    .accessibilityIdentifier("milestoneUnlock.seeAll")
            }
        }
    }

    /// Discreet renders the rung's DURATION (data), never the catalog's worded title.
    private var titleText: String {
        isDiscreet ? StreakDetailComposer.durationText(afterHours: row.afterHours) : row.title
    }

    /// Discreet renders the copy-doc §9 line, never the experiential catalog body.
    private var bodyText: String {
        isDiscreet ? copy.discreetBody : row.body
    }
}

/// ME-3 — the crest mark with its rise. The `CrestMark` geometry from the erase completion
/// frame (brand glyph budget #1, "surfaced breath": a soft circle cresting a thin
/// waterline), with two deliberate differences:
///
///  * the submerging mask is `surfaceRaised`, not `surfaceBase` — this crest sits on a
///    `themedCard`, and `surfaceBase` would draw a visible seam in dark mode;
///  * it RISES. `risen == false` holds the circle below its waterline; the animation the
///    parent drives lifts it over. At `risen == true` the draw is byte-identical to the
///    static original, which is what keeps the goldens stable.
///
/// Decorative throughout — hidden from the a11y tree; the title and body carry the meaning.
private struct MilestoneCrestMark: View {
    let risen: Bool

    var body: some View {
        ZStack(alignment: .top) {
            Circle()
                .fill(Theme.color.brandPrimary.color)
                .frame(width: 44, height: 44)
                // Below the line, then over it — the whole motion, in one offset.
                .offset(y: risen ? 0 : 18)
            VStack(spacing: 0) {
                Color.clear.frame(height: 36)
                Rectangle()
                    .fill(Theme.color.borderStrong.color)
                    .frame(height: 1)
                // Submerges the circle's lower arc below the waterline.
                Theme.color.surfaceRaised.color
            }
        }
        .frame(width: 96, height: 64)
        .clipped()
        .accessibilityHidden(true)
    }
}
