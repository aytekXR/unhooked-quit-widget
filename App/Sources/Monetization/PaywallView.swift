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
                            .foregroundStyle(.secondary)
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
                        .foregroundStyle(.secondary)
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
                    .foregroundStyle(.secondary)
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
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("paywall.winback.offer")
                    Text(offer.mechanicsLine)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("paywall.winback.mechanics")
                    Text(offer.reassurance)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            Text(data.headline)
                .font(.title.weight(.bold))
                .multilineTextAlignment(.center)
            Text(data.subhead)
                .font(.body)
                .foregroundStyle(.secondary)
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
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3.weight(.semibold))
                    Text(priceLine)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if let badge {
                    Text(badge)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.green.opacity(0.12), in: Capsule())
                }
                // Selection carries a checkmark, never color alone (the
                // Session 16 micro-rule / quiz chip precedent).
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selected ? Color.teal : Color.secondary)
            }
            .padding(16)
            .background(
                selected ? Color.teal.opacity(0.10) : Color.secondary.opacity(0.06),
                in: RoundedRectangle(cornerRadius: 24)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(a11y)
    }

    private var positioningBlock: some View {
        VStack(spacing: 6) {
            Text(data.positioning)
                .font(.footnote.weight(.medium))
            Text(data.positioningNotes)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
    }

    /// The never-trap surfaces: amber + symbol failure banner with retry
    /// reachable (restore is ALWAYS on screen below); the calm restore-empty
    /// line — a fact, not an error.
    @ViewBuilder private var statusSurface: some View {
        switch model.phase {
        case .failed:
            VStack(spacing: 10) {
                Label(data.failureBanner, systemImage: "arrow.clockwise.circle")
                    .font(.footnote)
                    .foregroundStyle(.orange)
                    .multilineTextAlignment(.leading)
                Button {
                    Task { await model.purchaseSelectedPlan() }
                } label: {
                    Text(data.retryCta)
                        .font(.footnote.weight(.semibold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.teal)
                .accessibilityIdentifier("paywall.retry")
            }
            .padding(12)
            .background(.orange.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
        case .restoredEmpty:
            Text(data.restoreEmpty)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("paywall.restoreEmpty")
        case .idle, .working, .unlocked:
            EmptyView()
        }
    }

    private var footerActions: some View {
        VStack(spacing: 12) {
            Button {
                Task { await model.purchaseSelectedPlan() }
            } label: {
                Group {
                    if model.phase == .working {
                        ProgressView().tint(.white)
                    } else {
                        Text(model.selectedPlan == .annual ? data.ctaTrial : data.ctaMonthly)
                    }
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.teal, in: Capsule())
            }
            .buttonStyle(.plain)
            .disabled(model.phase == .working)
            .accessibilityIdentifier("paywall.cta")

            // E7.2 (R25.8): the teaser variant's escape — a §6.2 QuietButton
            // directly below the CTA (never hidden, never shrunk below
            // type/body), with its honest "what this does" note read BEFORE
            // tapping (§1.1 no-dark-patterns). Composed ONLY on the teaser
            // arm's first impression (data.teaserEscape nil = the close-free
            // hard variant / the single-use re-present, R24.9/R25.7).
            if let escape = data.teaserEscape {
                VStack(spacing: 4) {
                    Button {
                        model.takeTeaser()
                        onTeaserDismiss()
                    } label: {
                        Text(escape.label)
                            .font(.body)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .disabled(model.phase == .working)
                    .accessibilityIdentifier("paywall.teaser.escape")

                    Text(escape.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
                Button {
                    onWinbackDismiss()
                } label: {
                    Text(offer.dismissLabel)
                        .font(.body)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .disabled(model.phase == .working)
                .accessibilityIdentifier("paywall.winback.dismiss")
            }

            HStack(spacing: 20) {
                Button {
                    Task { await model.restorePurchases() }
                } label: {
                    Text(data.restoreLabel)
                }
                .accessibilityIdentifier("paywall.restore")
                // Legal labels render pre-link (the destinations are
                // operator/legal-owned — paywallCopy.json _meta.legalNote);
                // they MUST become functional links before submission
                // (Schedule 2), a recorded rider on the operator's queue.
                Text(data.termsLabel)
                Text(data.privacyLabel)
            }
            .buttonStyle(.plain)
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }
}
