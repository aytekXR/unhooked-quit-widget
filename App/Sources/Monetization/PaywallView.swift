import PaywallKit
import SwiftUI

/// E7.1 — the bundled default paywall (ADR-4: the fallback that must exist
/// with or without Superwall; architecture §8: control arm, offline-safe).
/// A thin renderer over `PaywallViewData` (the QuizSummaryView discipline) +
/// the `PaywallModel` phases. Brandkit §6.8 contract: teal CTA (accentFlame
/// BANNED on buttons), amber failure surface with a symbol (never color
/// alone, no red anywhere), quiet text buttons for restore/legal, plan cards
/// at radius 24, no countdowns, no fake discounts, `paywall.*` a11y ids.
///
/// Reachability (R24.2): mounted ONLY by the summary CTA remap when a LIVE
/// entitlement model says not-entitled — dormant TestFlight builds never
/// route here (the M1 loop is untouched until the operator's key lands).
struct PaywallView: View {
    let data: PaywallViewData
    let model: PaywallModel
    /// The forward seam: called on `.unlocked` (purchase or restore) — the
    /// host dismisses to the dashboard.
    let onUnlocked: () -> Void
    /// E7.2 (R25.7) — the teaser-escape seam: called AFTER `takeTeaser()`
    /// fired + stamped the grant; the host dismisses to the dashboard.
    /// Defaulted so every E7.1 call site stays byte-compatible.
    var onTeaserDismiss: () -> Void = {}
    /// E7.3 (R26.6) — the win-back dismiss seam: the offer is DISMISSIBLE
    /// (an offer never traps; the hard wall and teaser re-present stay
    /// close-free). No event fires on dismiss — the closed enum has no
    /// dismissal vocabulary, deliberately. Defaulted for byte-compat.
    var onWinbackDismiss: () -> Void = {}

    var body: some View {
        VStack(spacing: 20) {
            ScrollView {
                VStack(spacing: 24) {
                    header
                    planCards
                    if model.selectedPlan == .annual {
                        Text(data.trialMechanicsLine)
                            .font(.footnote)
                            .foregroundStyle(Theme.color.contentSecondary.color)
                            .multilineTextAlignment(.center)
                            .accessibilityIdentifier("paywall.trialMechanics")
                    }
                    positioningBlock
                    // The 3.1.2(c)/Schedule-2 auto-renewal statement renders
                    // ON the screen, before any purchase (the green critics'
                    // catch: composing it is not disclosing it). Caption is
                    // the brandkit floor — small, but never truncated.
                    Text(data.autoRenewDisclosure)
                        .font(.caption)
                        .foregroundStyle(Theme.color.contentSecondary.color)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("paywall.renewalTerms")
                    statusSurface
                }
                .padding(.top, 24)
                .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)

            Spacer(minLength: 0)

            footerActions
        }
        .padding(20)
        .themedScreenSurface() // UIR-0: surface/base behind the paywall
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("paywall.card")
        // The ONE presentation fire (R25.5): onAppear delegates to the
        // model's didFire guard, so SwiftUI re-renders/re-appears stay a
        // single paywall_viewed per presentation. Both mount paths (live
        // gate + the DEBUG UITEST_PAYWALL render) arrive here — the smoke's
        // event tail is true for release builds by construction.
        .onAppear { model.paywallPresented() }
        .onChange(of: model.phase) { _, phase in
            if phase == .unlocked { onUnlocked() }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            // E7.2 (R25.8): the zero-shame acknowledgment on the
            // teaser-expiry re-present ONLY — a fact plus reassurance,
            // never a countdown, never loss framing (brandkit §6.8).
            if let eyebrow = data.expiryEyebrow {
                Text(eyebrow)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier("paywall.expiryEyebrow")
            }
            // E7.3 (R26.9): the win-back offer block — a real discount
            // stated as fact (no countdown, no urgency, §6.8): the offer
            // line, the two-price mechanics disclosure, the zero-shame
            // reassurance. Composed ONLY on source == .winback.
            if let offer = data.winbackOffer {
                VStack(spacing: 4) {
                    Text(offer.offerLine)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Theme.color.contentSecondary.color)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("paywall.winback.offer")
                    Text(offer.mechanicsLine)
                        .font(.caption)
                        .foregroundStyle(Theme.color.contentSecondary.color)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("paywall.winback.mechanics")
                    Text(offer.reassurance)
                        .font(.caption)
                        .foregroundStyle(Theme.color.contentSecondary.color)
                        .multilineTextAlignment(.center)
                }
            }
            Text(data.headline)
                .font(.title.weight(.bold))
                .multilineTextAlignment(.center)
            Text(data.subhead)
                .font(.body)
                .foregroundStyle(Theme.color.contentSecondary.color)
                .multilineTextAlignment(.center)
        }
    }

    private var planCards: some View {
        VStack(spacing: 12) {
            planCard(
                plan: .annual,
                title: data.planAnnualTitle,
                priceLine: data.priceAnnualLine,
                badge: data.trialBadge,
                a11y: "paywall.plan.annual"
            )
            planCard(
                plan: .monthly,
                title: data.planMonthlyTitle,
                priceLine: data.priceMonthlyLine,
                badge: nil,
                a11y: "paywall.plan.monthly"
            )
        }
    }

    private func planCard(
        plan: PaywallModel.Plan, title: String, priceLine: String,
        badge: String?, a11y: String
    ) -> some View {
        let selected = model.selectedPlan == plan
        return Button {
            model.selectedPlan = plan
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: Theme.space.s1) {
                    Text(title)
                        .font(.title3.weight(.semibold))
                    Text(priceLine)
                        .font(.subheadline)
                        // content/secondary on the SELECTED tint (5.20 L / 6.77 D — the
                        // UIR-4 contrast pair) and on the unselected sunken (5.64 L) — pinned.
                        .foregroundStyle(Theme.color.contentSecondary.color)
                }
                Spacer()
                if let badge {
                    Text(badge)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.color.positive.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        // NEUTRAL sunken capsule (R32.3): positive text on a positive
                        // tint computes 4.29:1, sub-WCAG — the badge fill stays neutral.
                        .background(Theme.color.surfaceSunken.color, in: Capsule())
                }
                // Selection carries a checkmark, never color alone (the
                // Session 16 micro-rule / quiz chip precedent).
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle((selected ? Theme.color.brandPrimary : Theme.color.contentSecondary).color)
            }
            .padding(Theme.space.s4)
            .background(
                selected ? Theme.color.brandPrimary.color.opacity(Theme.alpha.selectionTint) : Theme.color.surfaceSunken.color,
                in: RoundedRectangle(cornerRadius: Theme.radius.l)
            )
        }
        // R32.9 structural: PlanCardButtonStyle suppresses .plain's ghost-disabled dimming
        // (plan cards are always enabled today; closes the future-disable risk window).
        .buttonStyle(PlanCardButtonStyle())
        .accessibilityIdentifier(a11y)
    }

    private var positioningBlock: some View {
        VStack(spacing: 6) {
            Text(data.positioning)
                .font(.footnote.weight(.medium))
            Text(data.positioningNotes)
                .font(.footnote)
                .foregroundStyle(Theme.color.contentSecondary.color)
        }
        .multilineTextAlignment(.center)
    }

    /// The never-trap surfaces: amber + symbol failure banner with retry
    /// reachable (restore is ALWAYS on screen below); the calm restore-empty
    /// line — a fact, not an error.
    @ViewBuilder private var statusSurface: some View {
        switch model.phase {
        case .failed:
            VStack(spacing: Theme.space.s2) {
                // Fixes a pre-existing contrast bug: the banner text was caution-on-caution-tint
                // (~1:1). Caution now rides the DECORATIVE glyph only; the text is content/primary
                // on the caution tint (13.7:1, registry-pinned) via themedCautionCard.
                HStack(alignment: .top, spacing: Theme.space.s2) {
                    Image(systemName: "arrow.clockwise.circle")
                        .foregroundStyle(Theme.color.caution.color)
                        .accessibilityHidden(true)
                    Text(data.failureBanner)
                        .font(.footnote)
                        .foregroundStyle(Theme.color.contentPrimary.color)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Button {
                    Task { await model.purchaseSelectedPlan() }
                } label: {
                    Text(data.retryCta)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Theme.color.brandPrimary.color)
                        // R33.5: retry is a 44pt target via a frame floor (never-trap).
                        .frame(minHeight: Theme.touch.minTarget)
                        .contentShape(Rectangle())
                }
                // Pass-through style (not `.plain`) so App/Sources/Monetization is lint-clean
                // — an inline text link, never disabled; PlanCardButtonStyle only suppresses
                // the default highlight (no shape/ghost change).
                .buttonStyle(PlanCardButtonStyle())
                .accessibilityIdentifier("paywall.retry")
            }
            .padding(Theme.space.s3)
            .themedCautionCard()
        case .restoredEmpty:
            Text(data.restoreEmpty)
                .font(.footnote)
                .foregroundStyle(Theme.color.contentSecondary.color)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("paywall.restoreEmpty")
        case .idle, .working, .unlocked:
            EmptyView()
        }
    }

    private var footerActions: some View {
        VStack(spacing: Theme.space.s3) {
            // R32.9: the CTA adopts PrimaryButtonStyle (the STYLE, not the wrapper — R33.8
            // keeps `paywall.cta` on this exact Button). The style's ghost-disabled form
            // (surfaceSunken + contentSecondary, registry-pinned) replaces the hand-rolled
            // brandPrimary fill that Apple's .contrast audit measured on the DISABLED
            // (.working) control. The spinner tints content/secondary — visible on the
            // ghost surface during .working (the button is disabled then).
            Button {
                Task { await model.purchaseSelectedPlan() }
            } label: {
                Group {
                    if model.phase == .working {
                        ProgressView().tint(Theme.color.contentSecondary.color)
                    } else {
                        Text(model.selectedPlan == .annual ? data.ctaTrial : data.ctaMonthly)
                    }
                }
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: Theme.touch.minTarget)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(model.phase == .working)
            .accessibilityIdentifier("paywall.cta")

            // E7.2 (R25.8): the teaser variant's escape — a §6.2 QuietButton
            // directly below the CTA (never hidden, never shrunk below
            // type/body), with its honest "what this does" note read BEFORE
            // tapping (§1.1 no-dark-patterns). Composed ONLY on the teaser
            // arm's first impression (data.teaserEscape nil = the close-free
            // hard variant / the single-use re-present, R24.9/R25.7).
            if let escape = data.teaserEscape {
                VStack(spacing: Theme.space.s1) {
                    // R32.9: QuietButtonStyle carries the content/secondary label + 44pt
                    // target + the correct disabled treatment (no .plain dimming).
                    Button {
                        model.takeTeaser()
                        onTeaserDismiss()
                    } label: {
                        Text(escape.label)
                    }
                    .buttonStyle(QuietButtonStyle())
                    .disabled(model.phase == .working)
                    .accessibilityIdentifier("paywall.teaser.escape")

                    Text(escape.note)
                        .font(.caption)
                        .foregroundStyle(Theme.color.contentSecondary.color)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("paywall.teaser.note")
                }
            }

            // E7.3 (R26.6): the win-back dismiss — a QuietButton in the
            // escape's slot (the two never co-compose, R26.9 fork
            // isolation). The OFFER never traps: "Not now" returns to the
            // dashboard, wordlessly (no event — a dismissal is not funnel
            // vocabulary).
            if let offer = data.winbackOffer {
                // R32.9: same QuietButtonStyle adoption as the teaser escape.
                Button {
                    onWinbackDismiss()
                } label: {
                    Text(offer.dismissLabel)
                }
                .buttonStyle(QuietButtonStyle())
                .disabled(model.phase == .working)
                .accessibilityIdentifier("paywall.winback.dismiss")
            }

            // R33.5: restore is a full-width QuietButton (44pt target). Terms/privacy
            // render as plain labels (not yet functional links — the pre-submission
            // rider on the operator's queue).
            Button {
                Task { await model.restorePurchases() }
            } label: {
                Text(data.restoreLabel)
            }
            .buttonStyle(QuietButtonStyle())
            .accessibilityIdentifier("paywall.restore")

            HStack(spacing: Theme.space.s5) {
                Text(data.termsLabel)
                Text(data.privacyLabel)
            }
            .font(.footnote)
            .foregroundStyle(Theme.color.contentSecondary.color)
        }
    }
}
