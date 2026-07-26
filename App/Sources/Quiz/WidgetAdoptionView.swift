import SwiftUI
import WidgetToolkit

/// ME-1 (redesign §6.15) — the widget-adoption moment: "the highest-leverage
/// screen in this document". Mounts once per funnel completion, immediately
/// post-entitlement-resolution (post-paywall on live-key builds, post-summary
/// on dormant ones — payment friction never blocks it), and serves the north
/// star: panic widget added by D1 ≥ 40%.
///
/// Honesty contract: the preview is the REAL rectangular widget over the REAL
/// App Group feed (`WidgetPreviewFrame`) — a discreet quit previews discreet,
/// an empty feed previews the calm unavailable state, and no fabricated state
/// ever renders. The guided add is honest about iOS's manual flow (Ballast
/// cannot programmatically install accessory widgets). Every string rides the
/// audited `WidgetMomentCopy` table (DRAFT, founder pass pending).
///
/// `widget_added` detection: the screen sweeps the app-group handshake on
/// appear and on every foreground return, so the moment the widget's first
/// timeline render lands the guide's steps check themselves off and the
/// consent-gated fire happens right here (the dashboard sweep covers adds that
/// happen after this screen is gone).
struct WidgetAdoptionView: View {
    let copy: WidgetMomentCopy
    /// The true feed (nil = fresh install with no feed — the preview renders
    /// the widget's own unavailable state, never a fabricated day).
    let feed: WidgetFeed?
    /// The preview's single frozen instant (injected for deterministic goldens).
    let now: Date
    /// The ONE consent-gated service (repository-vended; `.disabled` on debug
    /// mounts).
    let analytics: AnalyticsService
    /// The handshake suite — nil (debug/snapshot mounts) detects nothing.
    var handshakeDefaults: UserDefaults? = WidgetAdoptionHandshake.groupDefaults
    /// The forward seam — both "Maybe later" and the post-add continue.
    let onContinue: () -> Void

    @State private var showsGuide = false
    @State private var widgetDetected = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        OnboardingScaffold {
            VStack(spacing: Theme.space.s6) {
                VStack(spacing: Theme.space.s2) {
                    Text(copy.eyebrow)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Theme.color.contentSecondary.color)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(copy.title)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Theme.color.contentPrimary.color)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("widgetAdoption.title")
                }

                Text(copy.body)
                    .font(.body)
                    .foregroundStyle(Theme.color.contentPrimary.color)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: Theme.space.s3) {
                    WidgetPreviewFrame(entry: previewEntry, quit: previewQuit)
                    Text(copy.visualCaption)
                        .font(.footnote)
                        .foregroundStyle(Theme.color.contentSecondary.color)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                // One described element (redesign §8): the frame itself is
                // a11y-hidden; the label frames it and appends the live data.
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(previewAccessibilityLabel)
                .accessibilityIdentifier("widgetAdoption.preview")

                Text(copy.discreetFootnote)
                    .font(.footnote)
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } actions: {
            VStack(spacing: Theme.space.s2) {
                Button {
                    showsGuide = true
                } label: {
                    Text(copy.primaryCTA)
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.space.s4)
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier("widgetAdoption.cta")

                Button(copy.secondaryCTA, action: onContinue)
                    .buttonStyle(QuietButtonStyle())
                    .accessibilityIdentifier("widgetAdoption.later")
            }
        }
        .themedScreenSurface()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("widgetAdoption.screen")
        .sheet(isPresented: $showsGuide) {
            guideOverlay
        }
        .onAppear { sweepHandshake() }
        .onChange(of: scenePhase) { _, phase in
            // The add happens OUTSIDE the app (lock screen, Customize) — the
            // foreground return is exactly when the first render can be seen.
            if phase == .active { sweepHandshake() }
        }
    }

    /// The 3-step guided overlay (copy doc §4): each step one line, no body
    /// text; steps check themselves off once the widget's first timeline
    /// render lands (§6.15 micro-interaction). A sheet per the modal strategy
    /// (§4) — standard spring, swipe-dismissible, quiet Done.
    private var guideOverlay: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.space.s5) {
                    ForEach(Array(copy.guideSteps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .firstTextBaseline, spacing: Theme.space.s3) {
                            if widgetDetected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Theme.color.positive.color)
                                    .accessibilityHidden(true)
                            } else {
                                // Ordinal as DATA (monospaced digits), not copy.
                                Text("\(index + 1)")
                                    .font(.body.weight(.semibold))
                                    .monospacedDigit()
                                    .foregroundStyle(Theme.color.brandPrimary.color)
                            }
                            Text(step)
                                .font(.body)
                                .foregroundStyle(Theme.color.contentPrimary.color)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Theme.space.s4)
                        .themedCard()
                    }
                }
                .frame(maxWidth: Theme.layout.contentMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Theme.space.s5)
                .padding(.top, Theme.space.s8)
            }
            .scrollBounceBehavior(.basedOnSize)

            Button(copy.guideDismiss) { showsGuide = false }
                .buttonStyle(QuietButtonStyle())
                .padding(.horizontal, Theme.space.s5)
                .padding(.bottom, Theme.space.s5)
                .accessibilityIdentifier("widgetAdoption.guide.dismiss")
        }
        .presentationDetents([.medium])
        .themedScreenSurface()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("widgetAdoption.guide")
        .onAppear { sweepHandshake() }
    }

    // MARK: - Live preview composition (the true feed, one frozen instant)

    private var composition: StreakWidgetComposer.Composition {
        StreakWidgetComposer.compose(
            feed: feed, configuredQuitID: nil, now: now, horizonDays: 0
        )
    }

    /// The planner always emits at least one entry (its `.unavailable` arm), so
    /// the fallback is structurally unreachable — kept total anyway: a preview
    /// must never crash the funnel.
    private var previewEntry: StreakWidgetEntry {
        composition.plan.entries.first ?? StreakWidgetEntry(
            date: now, kind: .unavailable, dayNumber: nil, tickWindow: nil, freshness: .fresh
        )
    }

    private var previewQuit: WidgetQuitState? { composition.quit }

    /// "Preview of your lock screen widget" + the live rendered facts (pure
    /// data: the day line, and the money line when the widget shows one).
    private var previewAccessibilityLabel: String {
        var parts = [copy.previewAccessibilityLabel]
        let entry = previewEntry
        parts.append(
            StreakWidgetDisplay.dayText(entry) ?? StreakWidgetStyle.shipping.unavailableText
        )
        if StreakWidgetDisplay.showsMoney(for: previewQuit), let quit = previewQuit,
           let money = StreakWidgetDisplay.moneyText(for: quit, at: entry.date) {
            parts.append("\(money) \(StreakWidgetStyle.shipping.savedLabel)")
        }
        parts.append(copy.visualCaption)
        return parts.joined(separator: ". ")
    }

    // MARK: - widget_added (the dormant fire point, finally wired)

    private func sweepHandshake() {
        guard let defaults = handshakeDefaults else { return }
        WidgetAdoptionWiring.firePendingAdoptions(analytics: analytics, defaults: defaults)
        widgetDetected = WidgetAdoptionHandshake.hasAnyRender(in: defaults)
    }
}
