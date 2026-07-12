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
        .onChange(of: model.phase) { _, phase in
            if phase == .unlocked { onUnlocked() }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
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
