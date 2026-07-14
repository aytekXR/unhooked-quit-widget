import SwiftUI

/// E5.1 — the birth-year entry screen (the app's first screen). Every string comes
/// from the audited `ageGateCopy.json` table (lexicon-scanned in CI); the picker is
/// a wheel (no keyboard, no invalid input, discreet) with NO pre-selected passing
/// year — the CTA stays disabled until an explicit choice (the gate never nudges).
///
/// UIR-1 (Session 33) — regenerated on the UIR-0 system, copy byte-identical:
/// - `OnboardingScaffold`: the text zone SCROLLS (the old plain `VStack` + `Spacer`
///   pair could not grow, so at accessibility sizes the title/body/footer had
///   nowhere to go — the S28 `.dynamicType` failure mode, structurally);
/// - the wheel stays a wheel (`.pickerStyle(.wheel)` — the funnel smoke drives it
///   via `pickerWheels.adjust(toPickerWheelValue:)`) and stays OUTSIDE the
///   ScrollView, so its own scroll gesture never competes with an ancestor's;
/// - its `.frame(maxHeight: 180)` is GONE: a fixed frame around text-rendering rows
///   is Apple's own documented Dynamic-Type clipping trigger. The wheel now takes
///   its intrinsic height;
/// - the glyph and every text role scale with Dynamic Type (`@ScaledMetric` —
///   `PanicFlowView`'s `reasonSize` is the shape precedent); nothing shrinks;
/// - the CTA rides `PrimaryButtonStyle`, whose disabled state is the GHOST form
///   (R32.9: `.buttonStyle(.plain)` auto-dims a disabled label ~50% ON TOP of any
///   foregroundStyle — an authored 5.9:1 rendered at 2.14:1 and fired the audit).
struct AgeGateView: View {
    @Bindable var model: AgeGateModel

    private let copy = (AgeGateCopy.loadShipping() ?? .degraded).gate

    /// Dynamic-Type-bound screen glyph (brandkit §8: everything scales). Capped so
    /// a decorative mark can never crowd out the content it decorates.
    @ScaledMetric(relativeTo: .largeTitle) private var glyphSize: CGFloat = Theme.type.screenGlyphBase

    var body: some View {
        OnboardingScaffold {
            VStack(spacing: Theme.space.s5) {
                Image(systemName: "calendar")
                    .font(.system(size: min(glyphSize, Theme.type.screenGlyphCap), weight: .light))
                    .foregroundStyle(Theme.color.brandPrimary.color)
                    .accessibilityHidden(true)

                Text(copy.title)
                    .font(.title.weight(.semibold))
                    .foregroundStyle(Theme.color.contentPrimary.color)
                    .multilineTextAlignment(.center)
                    // Take the natural height whatever the parent proposes — the
                    // anti-clipping guarantee, paired with the scaffold's ScrollView.
                    .fixedSize(horizontal: false, vertical: true)

                Text(copy.body)
                    .font(.body)
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } actions: {
            VStack(spacing: Theme.space.s5) {
                yearPicker

                Button {
                    guard let year = model.selectedBirthYear else { return }
                    model.submit(birthYear: year)
                } label: {
                    Text(copy.continueLabel)
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        // Padding, never a height floor: a floor that exceeds the
                        // label's natural accessibility-size height reads to Apple's
                        // audit as a cap on the text (the redirect-row finding class).
                        .padding(.vertical, Theme.space.s4)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(model.selectedBirthYear == nil)
                .accessibilityIdentifier("ageGate.continue")

                Text(copy.footer)
                    .font(.footnote)
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ageGate.entry")
    }

    /// The wheel: a sunken well the year sits in (`surface/sunken` — the same
    /// recessed-input language the quiz's fields and chips speak). No fixed height.
    private var yearPicker: some View {
        VStack(spacing: Theme.space.s1) {
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
            .accessibilityIdentifier("ageGate.yearPicker")
        }
        .padding(.vertical, Theme.space.s2)
        .frame(maxWidth: .infinity)
        .background(
            Theme.color.surfaceSunken.color,
            in: RoundedRectangle(cornerRadius: Theme.radius.m)
        )
    }
}
