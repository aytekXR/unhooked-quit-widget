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
                .foregroundStyle(.teal)
                .accessibilityHidden(true)

            Text(copy.title)
                .font(.title.weight(.semibold))
                .multilineTextAlignment(.center)

            Text(copy.body)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 4) {
                Text(copy.yearLabel)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
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
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        model.selectedBirthYear == nil ? Color.teal.opacity(0.35) : Color.teal,
                        in: Capsule()
                    )
            }
            .buttonStyle(.plain)
            .disabled(model.selectedBirthYear == nil)
            .accessibilityIdentifier("ageGate.continue")

            Text(copy.footer)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer(minLength: 12)
        }
        .padding(20)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ageGate.entry")
    }
}
