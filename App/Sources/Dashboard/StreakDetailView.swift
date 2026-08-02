import SwiftUI

/// P2 (redesign §6.17) — Streak Detail, Level 2 of the IA: the destination the
/// dashboard card has always implied. Day N hero over a thin waterline rule →
/// momentum block (with the plain-language explainer the app never offered) →
/// money block → the milestone timeline (the 43 dormant catalog bodies'
/// FIRST renderer — Ember's sanctioned second spend on the unlocked glyphs) →
/// averted-urge stat line → private notes list → the per-quit slip action.
///
/// Discreet variant (§6.17 / §9.5): "Tracked goal", numbers-only — no
/// milestone titles or bodies (time-only rows), no Ember (zero brand-accent is
/// the disguise's posture), no money, no notes. Frozen: neutral ring, calm
/// numbers (never a problem state). No missed states exist anywhere.
///
/// A THIN renderer over `StreakDetailModel` (fixture-able; the snapshot lane
/// renders it without a store). R33.12 honored: text styles only; point sizes
/// on decorative SF-Symbol images; the ring and its 72pt frame are omitted at
/// AX sizes (the card precedent — numbers carry the meaning).
struct StreakDetailView: View {
    let model: StreakDetailModel
    /// The per-quit slip action (§6.17 actions row). Nil hides the button
    /// (snapshot/audit mounts); the dashboard host wires the real slip flow.
    var onLogSlip: (() -> Void)? = nil
    /// The quiet settle (§11), OPT-IN like `StreakRing.animateOnAppear`: only
    /// the live push passes `true`. Off (the default) draws the header settled
    /// — snapshots capture the final frame, never frame zero of a fade.
    var animateHeader: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var settled = false

    private var isAX: Bool { typeSize.isAccessibilitySize }
    private var momentumPercent: Int { Int((model.momentumFraction * 100).rounded()) }
    /// The SIGNED milestone footer (clinician-gated `safetyCopy.json` fragment
    /// — never redrafted here; absent table ⇒ the footer simply does not render).
    private let milestoneFooter = SafetyCopy.loadShipping()?.notMedicalCareDisclaimer

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: Theme.space.s6) {
                header
                momentumBlock
                moneyBlock
                milestoneTimeline
                notesList
                if let onLogSlip {
                    Button(
                        model.isDiscreet
                            ? StreakDetailCopy.logSlipLabelDiscreet
                            : StreakDetailCopy.logSlipLabel,
                        action: onLogSlip
                    )
                    .buttonStyle(QuietButtonStyle())
                    .accessibilityIdentifier("streakDetail.logSlip")
                }
            }
            .frame(maxWidth: Theme.layout.contentMaxWidth, alignment: .leading)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Theme.space.s5)
            .padding(.vertical, Theme.space.s4)
        }
        .scrollBounceBehavior(.basedOnSize)
        .themedScreenSurface()
        // The header's eyebrow carries the quit label — the CONTENT owns the
        // identity (shoulder-honest: "Tracked goal" when discreet), and the
        // nav bar stays title-free (no large-title AX5 defect inheritance, no
        // second rendering of the same word). The push's back affordance is
        // the system's.
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("streakDetail.screen")
        .onAppear {
            // The quiet settle (§11), live pushes only: the header fades up
            // ONCE at motion/calm; Reduce Motion → the quick crossfade.
            guard animateHeader else { return }
            withAnimation(Theme.motion.entrance(reduceMotion: reduceMotion)) {
                settled = true
            }
        }
    }

    // MARK: - Header (label eyebrow + Day N over the waterline rule)

    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.space.s3) {
            Text(model.title) // the quit's label ("Tracked goal" when discreet)
                .font(.footnote.weight(.medium))
                .foregroundStyle(Theme.color.contentSecondary.color)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("streakDetail.title")
            Text("Day \(model.dayNumber)") // ADR-11 data — the card's exact pattern
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(Theme.color.contentPrimary.color)
                .fixedSize(horizontal: false, vertical: true)
            // WaterlineRule (§9.4): the thin horizon under the hero numeral —
            // creative §2's SECOND sanctioned spend of the luminous waterline
            // ("under the dashboard's Day N hero"; the summary hero spends the
            // first). The primitive owns height + a11y-hidden.
            WaterlineRule()
        }
        .padding(.top, Theme.space.s4)
        .opacity(animateHeader && !settled ? 0 : 1)
    }

    // MARK: - Momentum

    private var momentumBlock: some View {
        VStack(alignment: .leading, spacing: Theme.space.s3) {
            HStack(alignment: .center, spacing: Theme.space.s4) {
                VStack(alignment: .leading, spacing: Theme.space.s1) {
                    HStack(spacing: Theme.space.s2) {
                        Text("\(momentumPercent)%")
                            .font(.system(.title2, design: .rounded, weight: .semibold))
                            .monospacedDigit()
                            .foregroundStyle(
                                model.isDiscreet || model.isFrozen
                                    ? Theme.color.contentSecondary.color
                                    : Theme.color.brandSecondary.color
                            )
                            .fixedSize(horizontal: false, vertical: true)
                        Text(StreakDetailCopy.momentumLabel)
                            .font(.subheadline)
                            .foregroundStyle(Theme.color.contentSecondary.color)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Text(StreakDetailCopy.momentumExplainer)
                        .font(.footnote)
                        .foregroundStyle(Theme.color.contentSecondary.color)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if !isAX {
                    Spacer(minLength: Theme.space.s4)
                    StreakRing(
                        fraction: model.momentumFraction,
                        isDiscreet: model.isDiscreet,
                        isFrozen: model.isFrozen
                    )
                    .frame(width: 72, height: 72) // decorative Shape frame — R33.12 safe
                }
            }
        }
        .padding(Theme.space.s4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .themedCard()
    }

    // MARK: - Money (Moss, floored — hidden when discreet or nothing saved)

    @ViewBuilder private var moneyBlock: some View {
        if !model.isDiscreet, let money = formattedMoney() {
            VStack(alignment: .leading, spacing: Theme.space.s1) {
                Text(money) // ADR-11 data
                    .font(.system(.title2, design: .rounded, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(Theme.color.positive.color)
                    .fixedSize(horizontal: false, vertical: true)
                Text(DashboardCopy.savedLabel) // AUDITED (Session-21)
                    .font(.subheadline)
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(Theme.space.s4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .themedCard()
        }
    }

    // MARK: - Milestone timeline (the 43 dormant bodies' first renderer)

    @ViewBuilder private var milestoneTimeline: some View {
        if !model.milestones.isEmpty {
            VStack(alignment: .leading, spacing: Theme.space.s4) {
                Text(StreakDetailCopy.milestonesTitle)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Theme.color.contentPrimary.color)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("streakDetail.milestones.title")

                VStack(alignment: .leading, spacing: Theme.space.s4) {
                    ForEach(model.milestones) { row in
                        milestoneRow(row)
                    }
                }

                if let footer = milestoneFooter, !footer.isEmpty {
                    // The SIGNED not-medical-care fragment, verbatim — the one
                    // sanctioned hedge framing for this catalog (§12 policy).
                    Text(footer)
                        .font(.footnote)
                        .foregroundStyle(Theme.color.contentSecondary.color)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(Theme.space.s4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .themedCard()
            .accessibilityIdentifier("streakDetail.milestones")

            if model.avertedUrgeCount >= 1 {
                Text(StreakDetailCopy.avertedLine(count: model.avertedUrgeCount))
                    .font(.footnote)
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("streakDetail.avertedLine")
            }
        }
    }

    @ViewBuilder private func milestoneRow(_ row: MilestoneRowModel) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.space.s3) {
            rowGlyph(row.state)
            VStack(alignment: .leading, spacing: Theme.space.s1) {
                // Discreet: time-only rows — the §6.20 discreet posture (zero
                // habit vocabulary, no bodies) applied to the whole ladder.
                Text(
                    model.isDiscreet
                        ? StreakDetailComposer.durationText(afterHours: row.afterHours)
                        : row.title
                )
                .font(.body.weight(.medium))
                .foregroundStyle(
                    row.state == .locked
                        ? Theme.color.contentSecondary.color
                        : Theme.color.contentPrimary.color
                )
                .fixedSize(horizontal: false, vertical: true)

                switch row.state {
                case .unlocked:
                    if !model.isDiscreet {
                        Text(row.body) // catalog bytes, verbatim ("commonly reported")
                            .font(.subheadline)
                            .foregroundStyle(Theme.color.contentSecondary.color)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                case .next(let progress):
                    ThemedProgressBar(fraction: progress)
                        .accessibilityHidden(true)
                    lockedTimeLine(row)
                case .locked:
                    lockedTimeLine(row)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// "Unlocks at" + a formatted duration — time only, no body preview
    /// (anticipation without promise; copy doc §9). Discreet rows already ARE
    /// the time, so the line would be a duplicate and is dropped there.
    @ViewBuilder private func lockedTimeLine(_ row: MilestoneRowModel) -> some View {
        if !model.isDiscreet {
            Text("\(StreakDetailCopy.milestoneLockedPrefix) \(StreakDetailComposer.durationText(afterHours: row.afterHours))")
                .font(.footnote)
                .foregroundStyle(Theme.color.contentSecondary.color)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// Unlocked = the Ember flame (the palette's sanctioned second spend —
    /// glyph scale only, never on discreet surfaces, where neutral gray keeps
    /// the disguise); next/locked = quiet circles, never a "missed" mark.
    private func rowGlyph(_ state: MilestoneRowModel.State) -> some View {
        Group {
            switch state {
            case .unlocked:
                Image(systemName: model.isDiscreet ? "checkmark.circle" : "flame.fill")
                    .foregroundStyle(
                        model.isDiscreet
                            ? Theme.color.paused.color
                            : Theme.color.accentFlame.color
                    )
            case .next:
                Image(systemName: "circle.dashed")
                    .foregroundStyle(Theme.color.brandSecondary.color)
            case .locked:
                Image(systemName: "circle")
                    .foregroundStyle(Theme.color.paused.color)
            }
        }
        .font(.body) // matches adjacent text weight (§9.5) — scales with type
        .accessibilityHidden(true)
    }

    // MARK: - Private notes (slip reflections — on-device, §10)

    @ViewBuilder private var notesList: some View {
        if !model.isDiscreet, !model.notes.isEmpty {
            VStack(alignment: .leading, spacing: Theme.space.s3) {
                Text(StreakDetailCopy.notesHeader)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .fixedSize(horizontal: false, vertical: true)
                ForEach(model.notes) { note in
                    VStack(alignment: .leading, spacing: Theme.space.s1) {
                        Text(note.at, format: .dateTime.day().month().year()) // data
                            .font(.footnote)
                            .foregroundStyle(Theme.color.contentSecondary.color)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(note.text) // the user's words, verbatim
                            .font(.body)
                            .foregroundStyle(Theme.color.contentPrimary.color)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(Theme.space.s4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .themedCard()
            .accessibilityIdentifier("streakDetail.notes")
        }
    }

    /// Realized savings, stored currency, zero fraction digits — mirrors the
    /// card. `nil` hides the block (never "$0").
    private func formattedMoney() -> String? {
        guard model.moneySaved > 0 else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = model.currencyCode
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        guard let text = formatter.string(from: model.moneySaved as NSDecimalNumber),
              text != formatter.string(from: 0)
        else { return nil }
        return text
    }
}
