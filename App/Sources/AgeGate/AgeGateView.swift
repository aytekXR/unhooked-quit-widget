import SwiftUI

/// E5.1 — the birth-year entry screen (the app's first screen). Every string comes
/// from the audited `ageGateCopy.json` table (lexicon-scanned in CI); the picker is
/// a wheel (no keyboard, no invalid input, discreet) with NO pre-selected passing
/// year — the CTA stays disabled until an explicit choice (the gate never nudges).
/// House style: teal accents, SF Symbols only, no red anywhere (brandkit §2.1).
struct AgeGateView: View {
    @Bindable var model: AgeGateModel

    private let copy = (AgeGateCopy.loadShipping() ?? .degraded).gate

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 12)

            Image(systemName: "calendar")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Theme.color.brandPrimary.color)
                .accessibilityHidden(true)

            Text(copy.title)
                .font(.title.weight(.semibold))
                .multilineTextAlignment(.center)

            Text(copy.body)
                .font(.body)
                .foregroundStyle(Theme.color.contentSecondary.color)
                .multilineTextAlignment(.center)

            VStack(spacing: 4) {
                Text(copy.yearLabel)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Theme.color.contentSecondary.color)
                Picker(copy.yearLabel, selection: $model.selectedBirthYear) {
                    // The unpicked placeholder row — "no passing year pre-selected"
                    // (PM §4): the wheel rests here until the user chooses.
                    Text(verbatim: "—").tag(Int?.none)
                    ForEach(model.selectableYears.reversed(), id: \.self) { year in
                        Text(verbatim: String(year)).tag(Int?.some(year))
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxHeight: 180)
                .accessibilityIdentifier("ageGate.yearPicker")
            }

            Button {
                guard let year = model.selectedBirthYear else { return }
                model.submit(birthYear: year)
            } label: {
                Text(copy.continueLabel)
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            // The GHOST disabled treatment DELIVERED THROUGH the primitive
            // (R32.9): `.buttonStyle(.plain)` auto-dims a disabled label to
            // ~50% opacity over any explicit foregroundStyle (rendered 2.14:1
            // on the quiz's identical CTA — run 29295414489, artifact-measured).
            // PrimaryButtonStyle renders the ghost tokens as authored
            // (content2-on-sunken 5.6:1 L / 8.8:1 D, registry-pinned).
            .buttonStyle(PrimaryButtonStyle())
            .disabled(model.selectedBirthYear == nil)
            .accessibilityIdentifier("ageGate.continue")

            Text(copy.footer)
                .font(.footnote)
                .foregroundStyle(Theme.color.contentSecondary.color)
                .multilineTextAlignment(.center)

            Spacer(minLength: 12)
        }
        .padding(20)
        .themedScreenSurface() // UIR-0: surface/base behind the age-gate entry
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ageGate.entry")
    }
}
