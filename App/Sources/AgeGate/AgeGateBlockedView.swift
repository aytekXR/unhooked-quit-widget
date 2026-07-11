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
struct AgeGateBlockedView: View {
    let model: AgeGateModel

    private let copy = (AgeGateCopy.loadShipping() ?? .degraded).blocked
    private let footerDisclaimer = SafetyCopy.loadShipping()?.resourcesScreen.footerDisclaimer
    private let blocked: AgeGateBlocked

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
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "lifepreserver")
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(.teal)
                    .accessibilityHidden(true)

                Text(copy.title)
                    .font(.title.weight(.semibold))
                    .multilineTextAlignment(.center)

                Text(copy.body)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                if !blocked.emergencyNote.isEmpty {
                    // Calm text by binding brand rule — never red, never a button.
                    Text(blocked.emergencyNote)
                        .font(.subheadline.weight(.medium))
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 12) {
                    ForEach(blocked.rows, id: \.dialString) { row in
                        helplineRow(row)
                    }
                }

                if let footerDisclaimer {
                    Text(footerDisclaimer)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Button {
                    model.goBackToEntry()
                } label: {
                    Text(copy.goBackLabel)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.teal)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("ageGate.blocked.goBack")
            }
            .padding(20)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ageGate.blocked")
    }

    /// One verbatim helpline row: name + description + a tappable tel: link.
    private func helplineRow(_ row: HelplineRow) -> some View {
        VStack(spacing: 4) {
            Text(row.name)
                .font(.body.weight(.semibold))
                .multilineTextAlignment(.center)
            Text(row.descr)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if let url = URL(string: "tel:\(row.dialString)") {
                Link(destination: url) {
                    HStack(spacing: 6) {
                        Image(systemName: "phone.fill")
                            .accessibilityHidden(true)
                        Text(verbatim: row.phoneDisplay)
                            .font(.body.weight(.semibold))
                    }
                    .foregroundStyle(.teal)
                }
            } else {
                Text(verbatim: row.phoneDisplay)
                    .font(.body.weight(.semibold))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 16))
    }
}
