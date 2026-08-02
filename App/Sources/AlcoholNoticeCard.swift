import SwiftUI

/// E9.1 / S46 — everything a screen needs to present the alcohol withdrawal
/// notice, so the two mount points cannot drift apart.
///
/// WHY TWO MOUNTS (S46, operator §3). The notice originally lived only on the
/// dashboard (`RootPlaceholderView`), inside the store-gated subtree. That left a
/// real safety hole: a user who selects an alcohol goal, finishes the quiz, and
/// meets the HARD paywall variant never dismisses it, never reaches the
/// dashboard, and therefore never meets the notice — and "did not convert" is
/// exactly uncorrelated with "does not need to know about withdrawal risk". The
/// notice now also mounts on the SUMMARY, which every completer sees BEFORE the
/// paywall. The dashboard mount stays as the fallback for anyone whose summary
/// is already behind them (existing installs, TestFlight testers).
///
/// Showing it twice is impossible by construction: `recordAlcoholNoticeShown()`
/// stamps durably through the ONE writer at display, and `shouldShowAlcoholNotice()`
/// reads that stamp — whichever mount fires first closes the other.
struct AlcoholNoticeSlot {
    let copy: SafetyCopy.AlcoholNotice
    let onDismiss: () -> Void
    let onSeeResources: () -> Void
}

/// E9.1 (R27.6, Brand-signed shape) — the ONE calm caution: an inline amber
/// `semantic/caution` card (never a blocking modal, never a sheet — zero
/// contention with the panic mounts), zero red, no alarm glyph
/// (`lifepreserver` — the brand-blessed help glyph; no new symbol, R27.9).
/// "Got it" carries EQUAL-OR-GREATER prominence than "See resources" — the
/// user leaves freely; the hand-off opens the resources screen with a nil
/// source (out-of-domain, fires nothing — R27.4).
///
/// Extracted from `RootPlaceholderView` in S46 so the summary mount renders the
/// byte-identical card. The a11y identifiers are unchanged, so every landed
/// assertion keeps pointing at the same elements.
struct AlcoholNoticeCard: View {
    let slot: AlcoholNoticeSlot

    var body: some View {
        VStack(spacing: Theme.space.s3) {
            HStack(spacing: Theme.space.s2) {
                Image(systemName: "lifepreserver")
                    .foregroundStyle(Theme.color.caution.color)
                    .accessibilityHidden(true)
                Text(slot.copy.title)
                    .font(.body.weight(.semibold))
            }
            Text(slot.copy.body)
                .font(.footnote)
                .foregroundStyle(Theme.color.contentSecondary.color)
                .multilineTextAlignment(.center)
            Button(action: slot.onDismiss) {
                Text(slot.copy.dismissLabel)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Theme.color.brandPrimary.color)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("alcoholNotice.dismiss")
            Button(action: slot.onSeeResources) {
                Text(slot.copy.primaryActionLabel)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Theme.color.brandPrimary.color)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("alcoholNotice.seeResources")
        }
        .padding(Theme.space.s4)
        .frame(maxWidth: .infinity)
        // Amber semantic/caution ONLY — never red (§2 hard rule), calm typography.
        .background(Theme.color.caution.color.opacity(Theme.alpha.cautionTint), in: RoundedRectangle(cornerRadius: Theme.radius.m))
        // ME-4 (S54) — the OPAQUE floor under that 10% tint, and it is load-bearing
        // rather than cosmetic.
        //
        // The three pairs this card renders are registered as "caution@10% over
        // surface/BASE". That was true while every mount sat on a flat base. ME-4
        // puts a full-bleed `WaterlineField` behind the summary, where S46 also
        // mounts this notice (so a hard-wall non-converter still meets it) — and a
        // translucent fill over a TINTED base composites to something else. Measured
        // on the shipping tokens: light `brand/primary` on this tint drops 4.900 →
        // 4.554 against its 4.5 floor at the field's standard 0.06, and to 4.442 —
        // a real WCAG failure — at the field's own 0.08 ceiling.
        //
        // Nothing in CI could catch that: no golden renders this card, and
        // `PostGateRootView.debugSummaryMount` passes no notice, so the runtime
        // .contrast audit never sees it either. So the fix is structural rather
        // than a note asking future callers to be careful — pinning an opaque
        // surface/base directly beneath the tint makes the REGISTERED composite the
        // one that actually renders, whatever is behind the card.
        //
        // Byte-identical everywhere the field is absent: the dashboard already
        // mounts this on `.themedScreenSurface()`, i.e. surface/base over
        // surface/base. Zero goldens move.
        .background(Theme.color.surfaceBase.color, in: RoundedRectangle(cornerRadius: Theme.radius.m))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("alcoholNotice.card")
    }
}
