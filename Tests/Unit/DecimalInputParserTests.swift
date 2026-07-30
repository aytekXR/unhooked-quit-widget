import Foundation
import Testing
@testable import Ballast

// S47 unit lane — the locale-tolerant `decimalInput` parse (R47.1/R47.1b).
//
// Why this suite exists: the quiz's spend and allowance steps render a
// `.decimalPad`, and iOS draws that keypad's separator from the device's Language
// & Region setting — so the raw `freeText` legitimately reads "12,50" on a German,
// French, Turkish, Brazilian, Spanish, Italian, Dutch, Polish, Indonesian or
// Russian device. The shipped parse was `Decimal(string:)` / `Int(_:)` with no
// locale, which accept a PERIOD only; "12,50" silently became 12 and "0,50" became
// 0, and the value is written into `Quit.weeklySpend` at `createQuit` with no edit
// path anywhere in the app. It is the R46.1 class — a device Settings value moving
// behaviour, structurally invisible to a suite and goldens that are always en_US.
//
// RED evidence for this file was reproduced FREE on the Linux box before the push
// (R31.4): the exact shipping bytes of `DecimalInputParser` were executed across
// the full locale × input matrix below, and every comma-notation case here was
// confirmed to FAIL against the previous `Decimal(string:)` form. Three real bugs
// in the parser were caught by that harness and fixed before it was wired in.
//
// Locales are pinned EXPLICITLY on every assertion — the production default is
// `.current`, but a test that read the host's locale would be exactly the
// device-dependence this parser exists to remove.
private let unitedStates = Locale(identifier: "en_US")
private let germany = Locale(identifier: "de_DE")
/// The unlocalized-app case: English language, German region. Measured — the
/// REGION drives the separator, so this still reports "," and is the realistic
/// shape for this app (it ships no .lproj at all).
private let englishInGermany = Locale(identifier: "en_DE")
private let france = Locale(identifier: "fr_FR")
private let turkey = Locale(identifier: "tr_TR")
private let egypt = Locale(identifier: "ar_EG")

@Suite("S47 · locale-tolerant decimalInput parsing")
struct DecimalInputParserTests {

    // MARK: - The defect (R47.1): comma-notation input

    /// The headline case: a comma-decimal device's own notation must survive.
    @Test func test_decimal_commaNotation_keepsTheFractionalPart() {
        #expect(DecimalInputParser.decimal(from: "12,50", locale: germany) == Decimal(string: "12.50"))
        #expect(DecimalInputParser.decimal(from: "12,50", locale: englishInGermany) == Decimal(string: "12.50"))
        #expect(DecimalInputParser.decimal(from: "6,50", locale: france) == Decimal(string: "6.50"))
        #expect(DecimalInputParser.decimal(from: "12,99", locale: turkey) == Decimal(string: "12.99"))
    }

    /// The worst sub-case: sub-unit spend used to collapse to 0, which every money
    /// display site then hides entirely (`spend > 0` guards on summary, dashboard
    /// AND widget) — the feature silently disappeared for the life of the quit.
    @Test func test_decimal_subUnitCommaSpend_isNotFlattenedToZero() {
        #expect(DecimalInputParser.decimal(from: "0,50", locale: germany) == Decimal(string: "0.5"))
        #expect(DecimalInputParser.decimal(from: "0,50", locale: germany) != 0)
    }

    /// The inverse must hold too: Apple's own forums report the keyboard language
    /// and the region can disagree, so a PERIOD typed on a comma-region device has
    /// to keep working. A naive "just pass Locale.current" fix breaks exactly this.
    @Test func test_decimal_periodNotation_survivesOnACommaRegionDevice() {
        #expect(DecimalInputParser.decimal(from: "6.50", locale: germany) == Decimal(string: "6.50"))
        #expect(DecimalInputParser.decimal(from: "6.50", locale: englishInGermany) == Decimal(string: "6.50"))
    }

    // MARK: - Regression floor: the previously-shipped behaviour is unchanged

    /// Every input the existing quiz/summary suites feed must parse byte-identically
    /// to the old `Decimal(string:)` — this fix may only ADD understood notations.
    @Test func test_decimal_plainAsciiInput_matchesThePreviousBehaviour() {
        for locale in [unitedStates, germany, englishInGermany, france, turkey, egypt] {
            #expect(DecimalInputParser.decimal(from: "26", locale: locale) == 26)
            #expect(DecimalInputParser.decimal(from: "0", locale: locale) == 0)
        }
        #expect(DecimalInputParser.decimal(from: "26.5", locale: unitedStates) == Decimal(string: "26.5"))
        #expect(DecimalInputParser.decimal(from: "9.99", locale: unitedStates) == Decimal(string: "9.99"))
    }

    // MARK: - Grouping separators (pasted text)

    /// A `.decimalPad` has no grouping key, so grouped text can only arrive by
    /// paste — and the SAME bytes mean different numbers per locale. Both readings
    /// must be the one the user meant.
    @Test func test_decimal_groupedPaste_readsPerLocale() {
        #expect(DecimalInputParser.decimal(from: "1.250", locale: germany) == 1250)
        #expect(DecimalInputParser.decimal(from: "1.250", locale: unitedStates) == Decimal(string: "1.25"))
        #expect(DecimalInputParser.decimal(from: "1,250", locale: unitedStates) == 1250)
        #expect(DecimalInputParser.decimal(from: "1,250", locale: germany) == Decimal(string: "1.25"))
        #expect(DecimalInputParser.decimal(from: "1,350.50", locale: unitedStates) == Decimal(string: "1350.50"))
        #expect(DecimalInputParser.decimal(from: "1.350,50", locale: germany) == Decimal(string: "1350.50"))
    }

    /// `fr`/`ru` group with space characters, including no-break forms.
    @Test func test_decimal_spaceGroupedInput_dropsTheSpaces() {
        #expect(DecimalInputParser.decimal(from: "1 350,50", locale: france) == Decimal(string: "1350.50"))
        #expect(DecimalInputParser.decimal(from: "1\u{00A0}350,50", locale: france) == Decimal(string: "1350.50"))
        #expect(DecimalInputParser.decimal(from: "1\u{202F}350,50", locale: france) == Decimal(string: "1350.50"))
    }

    // MARK: - Non-Latin numerals

    /// An Arabic-Indic keypad used to read as `nil` ⇒ a silent zero spend.
    @Test func test_decimal_nonLatinDigits_foldToASCII() {
        #expect(DecimalInputParser.decimal(from: "١٢", locale: egypt) == 12)
        #expect(DecimalInputParser.decimal(from: "١٢٫٥", locale: egypt) == Decimal(string: "12.5"))
    }

    // MARK: - Hostile / malformed input rejects rather than guessing

    /// A partially-understood amount is worse than `nil`: the call sites floor `nil`
    /// to a safe 0/absent, but a WRONG number is persisted and shown as fact.
    @Test func test_decimal_malformedInput_returnsNilNeverAGuess() {
        for bad in ["", " ", "abc", "12abc", "-3", "--", ".", ",", "1.2.3.4", "1,35.50", "1234,567.50"] {
            #expect(
                DecimalInputParser.decimal(from: bad, locale: unitedStates) == nil,
                "\(bad.debugDescription) must reject, never resolve to a plausible-looking number"
            )
        }
    }

    /// Tolerated shapes a real keypad can produce.
    @Test func test_decimal_toleratedShapes() {
        #expect(DecimalInputParser.decimal(from: "  6.50  ", locale: unitedStates) == Decimal(string: "6.50"))
        #expect(DecimalInputParser.decimal(from: "6,", locale: unitedStates) == 6)
        #expect(DecimalInputParser.decimal(from: ".5", locale: unitedStates) == Decimal(string: "0.5"))
    }

    // MARK: - The allowance step (R47.1b)

    /// `allowance` is ALSO a `decimalInput` step (slot 12), and the bare `Int(_:)`
    /// returned nil for ANY separator — period or comma — so a reduce-goal quit
    /// silently lost its weekly limit.
    @Test func test_int_allowanceInput_survivesEitherSeparator() {
        #expect(DecimalInputParser.int(from: "10", locale: unitedStates) == 10)
        #expect(DecimalInputParser.int(from: "10,5", locale: germany) == 10)
        #expect(DecimalInputParser.int(from: "10.5", locale: unitedStates) == 10)
        #expect(DecimalInputParser.int(from: "abc", locale: unitedStates) == nil)
    }

    // MARK: - No ambient dependence on the digits-only path

    /// The overwhelmingly common input (plain digits) must be locale-INVARIANT, so
    /// the injected locale can never surprise a user who typed no separator at all.
    @Test func test_decimal_digitsOnly_isLocaleInvariant() {
        let locales = [unitedStates, germany, englishInGermany, france, turkey, egypt]
        let parsed = locales.map { DecimalInputParser.decimal(from: "26", locale: $0) }
        #expect(Set(parsed.map { $0 ?? -1 }).count == 1, "digits-only input must not vary by locale")
    }
}
