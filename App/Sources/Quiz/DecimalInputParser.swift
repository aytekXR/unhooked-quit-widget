import Foundation

/// S47 — the locale-tolerant parse for every `decimalInput` quiz step's raw
/// `freeText` (today: `spend` slot 5 and `allowance` slot 12).
///
/// **The defect this exists to close (R47.1, measured).** Both sites previously
/// called `Decimal(string:)` / `Int(_:)` with no locale, which accept ONLY a
/// period decimal separator. But the field they read is a `.decimalPad`
/// `TextField`, and iOS renders that keypad's separator from the user's
/// Language & Region settings — a German, French, Turkish, Brazilian, Spanish,
/// Italian, Dutch, Polish, Indonesian or Russian device offers a COMMA key.
/// So the app asked for a number in the user's notation and then parsed it in
/// one notation only:
///
/// - `Decimal(string: "12,50")` → **12** (the cents are silently dropped)
/// - `Decimal(string: "0,50")`  → **0**  (the money feature silently disappears —
///   every display site guards on `spend > 0`)
/// - `Int("10,5")` / `Int("10.5")` → **nil** (a reduce goal silently loses its
///   weekly limit)
///
/// This is the R46.1 class exactly: a device Settings value changes behavior, and
/// it is structurally invisible to the whole suite and every golden because CI
/// and every simulator are `en_US`. It is worse than R46.1 in one respect — the
/// parsed value is persisted into `Quit.weeklySpend` at `createQuit` and there is
/// NO edit path anywhere in the app, so a truncated spend is permanent for the
/// life of that quit and corrupts money on the summary, the dashboard AND the
/// widget.
///
/// **Why this reads the ambient locale when R46.1 says not to.** R46.1's rule is
/// that a *derivation of a fixed quantity* (what year is it) must never depend on
/// device settings. This is the opposite case: the input IS in the user's
/// notation, so the locale is genuine semantic information, not ambient noise.
/// `locale` is injected with a `.current` default — the `SummaryFormatter`
/// precedent — so every test pins it explicitly and nothing here is
/// device-dependent under test.
///
/// **Why it is not simply `Decimal(string:locale:)`.** Measured: passing the
/// locale alone just moves the failure. On `de_DE`/`en_DE` (the region drives the
/// separator, so an English-only app on a German device still reports `,`),
/// `Decimal(string: "6.50", locale:)` returns **6** — so a user whose keyboard
/// language and region disagree, which Apple's own forums report as common, would
/// be truncated in the other direction. The rule below is separator-AGNOSTIC and
/// correct in all four quadrants.
///
/// Foundation-only and pure, so the Linux harness runs these exact bytes across
/// the full locale × input matrix before any billed macOS run.
enum DecimalInputParser {
    /// Space characters used as GROUPING separators in `fr`/`ru`-style locales
    /// (plain, no-break, narrow no-break, thin, figure). Always noise in a number.
    private static let groupingSpaces: Set<Character> = [
        "\u{0020}", "\u{00A0}", "\u{202F}", "\u{2009}", "\u{2007}",
    ]

    /// Every character that can act as a decimal OR grouping separator across the
    /// locales Apple ships a `.decimalPad` for: ASCII period/comma plus the Arabic
    /// decimal separator (U+066B) and Arabic thousands separator (U+066C).
    private static let separators: Set<Character> = [".", ",", "\u{066B}", "\u{066C}"]

    /// The user's typed amount as an exact `Decimal`, or `nil` when the field holds
    /// nothing parseable (the callers keep their existing safe fallback).
    ///
    /// Negative results are rejected: a weekly spend or limit is never negative,
    /// and a stray "-" is far likelier to be a typo than an intent.
    static func decimal(from raw: String, locale: Locale = .current) -> Decimal? {
        let folded = foldToASCIIDigits(raw)
        guard !folded.isEmpty else { return nil }

        let separatorIndices = folded.indices.filter { separators.contains(folded[$0]) }
        guard !separatorIndices.isEmpty else { return canonicalParse(folded) }

        // Split into the digit runs BETWEEN separators. Validating the shape of
        // those runs is what keeps a malformed string ("1.2.3.4") from being
        // silently reinterpreted as a plausible number instead of rejected.
        var segments: [Substring] = []
        var separatorCharacters: [Character] = []
        var segmentStart = folded.startIndex
        for index in separatorIndices {
            segments.append(folded[segmentStart..<index])
            separatorCharacters.append(folded[index])
            segmentStart = folded.index(after: index)
        }
        segments.append(folded[segmentStart...])

        guard segments.allSatisfy({ $0.allSatisfy(\.isNumber) }),
              folded.contains(where: \.isNumber)
        else { return nil }

        // Decide what the FINAL separator means. A `.decimalPad` can only ever
        // produce ONE separator and it is by construction the decimal one, so the
        // grouping reading is deliberately narrow — it applies only to text that is
        // unambiguous: the character IS this locale's grouping separator, is NOT
        // also its decimal separator, and is followed by exactly three digits
        // ("1.250" on de_DE ⇒ 1250, while the same bytes on en_US ⇒ 1.25, which is
        // what each user meant).
        let decimalSeparator = locale.decimalSeparator?.first
        let groupingSeparator = locale.groupingSeparator?.first
        let finalIsGrouping =
            separatorCharacters[separatorCharacters.count - 1] == groupingSeparator
            && separatorCharacters[separatorCharacters.count - 1] != decimalSeparator
            && segments[segments.count - 1].count == 3

        // Every separator that is NOT the decimal one must be grouping-shaped:
        // exactly three digits after it, and one to three digits before the first.
        let groupingCount = finalIsGrouping ? separatorCharacters.count : separatorCharacters.count - 1
        if groupingCount > 0 {
            guard (1...3).contains(segments[0].count) else { return nil }
            for position in 1...groupingCount where segments[position].count != 3 { return nil }
        }

        let integerDigits = segments[0...groupingCount].joined()
        let fractionDigits = finalIsGrouping ? "" : String(segments[segments.count - 1])
        return canonicalParse(
            fractionDigits.isEmpty ? integerDigits : "\(integerDigits).\(fractionDigits)"
        )
    }

    /// The whole-number reading of the same field — the `allowance` step's shape.
    /// Truncates toward zero so "10,5" yields 10 rather than the `nil` the bare
    /// `Int(_:)` returned for ANY separator, period or comma.
    static func int(from raw: String, locale: Locale = .current) -> Int? {
        guard let value = decimal(from: raw, locale: locale) else { return nil }
        var truncated = Decimal()
        var source = value
        NSDecimalRound(&truncated, &source, 0, .down)
        return NSDecimalNumber(decimal: truncated).intValue
    }

    /// Trims, drops grouping spaces, and folds any decimal-digit script (Arabic-
    /// Indic, Extended Arabic-Indic, Devanagari, …) to ASCII so a user typing on a
    /// non-Latin numeric keypad is not silently read as zero.
    private static func foldToASCIIDigits(_ raw: String) -> String {
        var folded = ""
        for character in raw.trimmingCharacters(in: .whitespacesAndNewlines) {
            if groupingSpaces.contains(character) { continue }
            if character.isASCII, character.isNumber {
                folded.append(character)
            } else if character.isNumber, let digit = character.wholeNumberValue,
                      (0...9).contains(digit) {
                folded.append(Character(String(digit)))
            } else {
                folded.append(character)
            }
        }
        return folded
    }

    /// The final POSIX read. Rejects anything that is not digits plus at most one
    /// canonical period, and rejects negatives — a partially-understood amount is
    /// worse than an honest `nil` the caller can floor to zero.
    private static func canonicalParse(_ canonical: String) -> Decimal? {
        guard !canonical.isEmpty,
              canonical.allSatisfy({ $0.isASCII && ($0.isNumber || $0 == ".") }),
              canonical.filter({ $0 == "." }).count <= 1,
              let value = Decimal(string: canonical),
              value >= 0
        else { return nil }
        return value
    }
}
