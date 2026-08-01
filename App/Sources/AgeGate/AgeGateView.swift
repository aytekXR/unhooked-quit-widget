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

                // R60.2 — the footer MOVED HERE from the pinned action zone, and the
                // move is half the fix. It is informational ("No account, no sign-up.
                // This stays on your device."), not an action, so the scaffold's own
                // contract puts it in the scrolling half: `actions:` exists for
                // "a control the user needs [that] is never below the fold".
                // At AX5 it wraps to four lines — roughly 240pt of PINNED height
                // spent on a sentence nobody has to reach — which is most of what
                // squeezed the wheel out of existence.
                Text(copy.footer)
                    .font(.footnote)
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
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ageGate.entry")
    }

    /// The floor that makes the wheel incompressible. **Not scaled**, deliberately:
    /// the rows inside a wheel already scale with Dynamic Type, so a floor that grew
    /// with the text size would demand MORE room exactly when there is less, which is
    /// the direction that caused R60.2. A fixed floor keeps roughly three rows
    /// visible at every size — enough to see that it is a wheel and to spin it —
    /// against ~199pt measured for the default-size wheel in the adopted golden.
    private static let pickerMinHeight: CGFloat = 132

    /// The wheel: a sunken well the year sits in (`surface/sunken` — the same
    /// recessed-input language the quiz's fields and chips speak).
    ///
    /// **R60.2 — this used to say "No fixed height", and that was the defect.**
    /// The first AX5 goldens (S60) showed the wheel COLLAPSED TO ZERO: "Year of
    /// birth" rendered and the next thing was a disabled "Continue", so no year could
    /// be chosen and the CTA could never enable. A legally-required 17+ gate was
    /// impassable at the largest accessibility size, and it had been since the screen
    /// was built.
    ///
    /// **The mechanism, and why the floor is the right lever.** The scaffold lays out
    /// `VStack { header; ScrollView { content }; actions }`. Two children there are
    /// flexible — the ScrollView and, because `UIPickerView` reports a flexible
    /// height, this wheel. At AX5 the action zone's fixed children (the CTA, and
    /// formerly the four-line footer) over-subscribe the space, and SwiftUI takes it
    /// out of the flexible ones. The wheel lost, silently and completely.
    /// A `minHeight` makes the wheel incompressible below a usable size, so the
    /// squeeze lands on the ScrollView instead — which is exactly what the scaffold
    /// was built for ("Content SCROLLS … the text can always grow"). The fix uses the
    /// shell as designed rather than fighting it.
    ///
    /// **Two alternatives were rejected before this one.** Moving the picker INTO the
    /// scrolling content would put a wheel's own scroll gesture inside an ancestor
    /// ScrollView — the scaffold's doc comment names that fight explicitly as the
    /// reason the picker lives in `actions:`. And swapping to `.menu`/`.navigationLink`
    /// at accessibility sizes would present 121 years as a list, which is a bigger
    /// behavioural change than the defect warrants and needs a navigation ancestor
    /// this screen does not have.
    ///
    /// ⚠️ **This is a layout hypothesis until a golden says otherwise** — the S53/S54/S58
    /// rule, and S58 proved it by measuring the "obvious" fix for R58.1 as wrong. Expect
    /// the two `entry.*-ax5` goldens to move; treat movement in the default-size pair as
    /// a signal the floor reached further than intended.
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
            // R60.2: the floor that stops this being the child SwiftUI compresses
            // away when the pinned zone is over-subscribed. See `pickerMinHeight`.
            .frame(minHeight: Self.pickerMinHeight)
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
