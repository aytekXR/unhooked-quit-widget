import SwiftUI

/// E5.1 — the under-17 blocked surface: a calm resource screen, never a wall.
/// Copy from the audited `ageGateCopy.json` table; framing/footer reused verbatim
/// from the shipping `safetyCopy.json`; helpline rows verbatim from `helplines.json`
/// via the verified appliesTo-all predicate (an unverified number never renders
/// here — test-pinned). Brand binding (Session 16 sign-off): ZERO red anywhere —
/// the emergency note renders as calm text, never an alarm; links are teal;
/// SF Symbols only (`lifepreserver` for resources, `phone.fill` on rows; no
/// warning triangles). The only exits are the tel: links and "Go back" to the
/// year entry — no path into app content (un-bypassability, AC5).
///
/// UIR-1 (Session 33) — regenerated on the UIR-0 system, copy byte-identical:
/// - helpline rows become real `themedCard()`s (`surface/raised` + hairline). They
///   were the app's LAST system-material fill (`.quaternary.opacity(0.5)`), which
///   is outside the Theme layer and therefore outside the contrast registry's
///   guarantees — on a SAFETY surface whose whole job is to be readable in a bad
///   moment. Every pair on the card is now registry-pinned (content/primary 16.9,
///   content/secondary 6.7, the teal dial link 6.0);
/// - "Go back" rides `QuietButtonStyle` (brandkit §6.2: the escape hatch is
///   content/secondary and never shrunk) so the TEAL emphasis on this screen
///   belongs to the phone numbers alone — the thing we want tapped;
/// - the glyph and all text scale with Dynamic Type; nothing is height-capped.
struct AgeGateBlockedView: View {
    let model: AgeGateModel

    private let copy = (AgeGateCopy.loadShipping() ?? .degraded).blocked
    private let footerDisclaimer = SafetyCopy.loadShipping()?.resourcesScreen.footerDisclaimer
    private let blocked: AgeGateBlocked

    @ScaledMetric(relativeTo: .largeTitle) private var glyphSize: CGFloat = Theme.type.screenGlyphBase

    init(model: AgeGateModel) {
        self.model = model
        if let directory = HelplineDirectory.loadShipping() {
            let region = AgeGateResources.region(for: Locale.current, in: directory)
            self.blocked = AgeGateResources.blocked(region: region, directory: directory)
        } else {
            // Missing/undecodable directory: the calm copy still renders — degraded,
            // never a crash, never an invented number (§9 posture).
            self.blocked = AgeGateBlocked(emergencyNote: "", rows: [])
        }
    }

    var body: some View {
        OnboardingScaffold {
            VStack(spacing: Theme.space.s5) {
                Image(systemName: "lifepreserver")
                    .font(.system(size: min(glyphSize, Theme.type.screenGlyphCap), weight: .light))
                    .foregroundStyle(Theme.color.brandPrimary.color)
                    .accessibilityHidden(true)

                Text(copy.title)
                    .font(.title.weight(.semibold))
                    .foregroundStyle(Theme.color.contentPrimary.color)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(copy.body)
                    .font(.body)
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                if !blocked.emergencyNote.isEmpty {
                    // Calm text by binding brand rule — never red, never a button.
                    Text(blocked.emergencyNote)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.color.contentPrimary.color)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: Theme.space.s3) {
                    ForEach(blocked.rows, id: \.dialString) { row in
                        helplineRow(row)
                    }
                }
                .padding(.top, Theme.space.s1)

                if let footerDisclaimer {
                    Text(footerDisclaimer)
                        .font(.footnote)
                        .foregroundStyle(Theme.color.contentSecondary.color)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        } actions: {
            Button {
                model.goBackToEntry()
            } label: {
                Text(copy.goBackLabel)
            }
            .buttonStyle(QuietButtonStyle())
            .accessibilityIdentifier("ageGate.blocked.goBack")
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ageGate.blocked")
    }

    /// One verbatim helpline row: name + description + a tappable tel: link, on a
    /// raised card so the number reads as the affordance it is.
    private func helplineRow(_ row: HelplineRow) -> some View {
        VStack(spacing: Theme.space.s1) {
            Text(row.name)
                .font(.body.weight(.semibold))
                .foregroundStyle(Theme.color.contentPrimary.color)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(row.descr)
                .font(.footnote)
                .foregroundStyle(Theme.color.contentSecondary.color)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if let url = URL(string: "tel:\(row.dialString)") {
                Link(destination: url) {
                    HStack(spacing: Theme.space.s2) {
                        Image(systemName: "phone.fill")
                            .accessibilityHidden(true)
                        Text(verbatim: row.phoneDisplay)
                            .font(.body.weight(.semibold))
                    }
                    .foregroundStyle(Theme.color.brandPrimary.color)
                    // The dial link is the one thing this screen exists to get
                    // tapped, and it shipped as a ~26pt-tall target — under the 44pt
                    // motor floor (brandkit §5), on the surface a distressed minor
                    // uses. It now fills the card's width at the full floor. (44 sits
                    // BELOW the label's accessibility-size height, so it is a floor
                    // the text grows past, never a cap it is trapped under.)
                    .frame(maxWidth: .infinity, minHeight: Theme.touch.minTarget)
                    .contentShape(Rectangle())
                    .padding(.top, Theme.space.s1)
                }
            } else {
                Text(verbatim: row.phoneDisplay)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Theme.color.contentPrimary.color)
                    .padding(.top, Theme.space.s1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.space.s4)
        .themedCard()
    }
}
