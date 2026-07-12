// AppIntents is LOAD-BEARING even though no AppIntents type is named directly:
// `Button(intent:)` lives in the SwiftUI↔AppIntents cross-import overlay, which is
// FILE-granular — without both imports in THIS file the initializer does not resolve
// and every target that compiles Shared fails to build (compile-critic reproduction,
// Session 21).
import AppIntents
import Foundation
import StreakEngine
import SwiftUI
import WidgetToolkit

/// The widget family being rendered, as an EXPLICIT parameter. Deliberately our own
/// enum, not `WidgetKit.WidgetFamily`: the `widgetFamily` environment key is get-only
/// (panel-reproduced — injecting it does not compile), so snapshot tests select the
/// family through this parameter and the extension's provider maps the system value.
/// Keeping WidgetKit out of Shared also keeps these views renderable in the app-side
/// snapshot lane.
enum StreakWidgetFamily: CaseIterable, Sendable {
    case rectangular, circular, inline, small, medium
}

/// Pure display math for the family templates, separated from view bodies so the unit
/// lane can pin it (view bodies are coverage-exempt; these functions are not).
/// Everything takes the entry's own date — never a clock read (test-suite §3.1).
enum StreakWidgetDisplay {
    /// "Day N" — ADR-11's calendar-day number, straight off the entry. Data, not copy.
    static func dayText(_ entry: StreakWidgetEntry) -> String? {
        entry.dayNumber.map { "Day \($0)" }
    }

    /// Money saved at `date`: banked + current-streak elapsed through the ONE engine
    /// formula every app surface uses (realized value — never floored-to-ten; that
    /// rule is for the summary's PROJECTION). Formatted with the STORED currency code,
    /// zero fraction digits. `nil` when spend is absent/zero (free habits render no
    /// money line, never "$0").
    static func moneyText(for quit: WidgetQuitState, at date: Date) -> String? {
        guard let spend = Decimal(string: quit.weeklySpend), spend > 0 else { return nil }
        let clean = quit.bankedCleanSeconds + max(0, Int(date.timeIntervalSince(quit.streakStart)))
        let saved = StreakCalculator.moneySaved(weeklySpend: spend, cleanSeconds: clean)
        guard saved > 0 else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = quit.currencyCode
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter.string(from: saved as NSDecimalNumber)
    }

    /// Progress toward the next milestone rung at `date`, 0...1 — through the engine's
    /// own boundary semantics (a rung you are exactly AT is earned). `nil` with no
    /// ladder; a fully-climbed ladder shows a full bar (earned, not fabricated).
    static func milestoneProgress(for quit: WidgetQuitState, at date: Date) -> Double? {
        guard !quit.milestoneHours.isEmpty else { return nil }
        let elapsed = max(0, Int(date.timeIntervalSince(quit.streakStart)))
        let table = MilestoneTable(
            milestones: quit.milestoneHours.map { Milestone(afterHours: $0, title: "", body: "") }
        )
        guard let next = StreakCalculator.nextMilestone(elapsedSeconds: elapsed, in: table),
              next.afterHours > 0
        else { return 1.0 }
        return min(1.0, max(0.0, Double(elapsed) / Double(next.afterHours * 3_600)))
    }

    /// The interval a ticking template hands to `Text(timerInterval:)`: streak start
    /// through the entry's day end (the entry is replaced at the next boundary).
    /// `nil` when the range would invert — a rolled-back device clock can put the
    /// guard-corrected start past the entry's window (ADR-6: the widget runs no clock
    /// guard of its own), and a crashing `ClosedRange` is not an option on a widget.
    static func tickerInterval(for quit: WidgetQuitState, entry: StreakWidgetEntry) -> ClosedRange<Date>? {
        guard let window = entry.tickWindow, quit.streakStart <= window.upperBound else { return nil }
        return quit.streakStart...window.upperBound
    }

    /// The rectangular family's panic intent, carrying the CONFIGURED quit's id (mvp
    /// feature 5: per-widget binding by UUID — the app-side resolver honors it; a nil
    /// quit falls back to the intent's own picker path).
    static func panicIntent(for quit: WidgetQuitState?) -> OpenPanicIntent {
        guard let quit else { return OpenPanicIntent() }
        return OpenPanicIntent(quit: PanicQuitEntity(id: quit.id, title: "Your goal"))
    }

    // MARK: Discreet render-time selection (E6.3, R22.2)
    //
    // Pure data selection the family bodies call — architecture §11's "render-time
    // branches, not separate timelines" with the branch itself unit-pinnable (W1),
    // not only golden-provable. A nil quit (the `.unavailable` state) has no discreet
    // flag and selects the normal strings by construction.

    /// True iff the bound quit rides the feed's discreet flag (absent key ⇒ normal —
    /// the presence-only writer contract, R22.1).
    static func isDiscreet(_ quit: WidgetQuitState?) -> Bool {
        quit?.discreet == true
    }

    /// The panic button's SF Symbol name for this quit's mode.
    static func panicGlyph(for quit: WidgetQuitState?, style: StreakWidgetStyle) -> String {
        isDiscreet(quit) ? style.panicGlyphDiscreet : style.panicGlyph
    }

    /// The panic button's accessibility label for this quit's mode ("Reset" when
    /// discreet — brandkit literal; the full descriptive label otherwise).
    static func panicAccessibilityLabel(for quit: WidgetQuitState?, style: StreakWidgetStyle) -> String {
        isDiscreet(quit) ? style.panicAccessibilityLabelDiscreet : style.panicAccessibilityLabel
    }

    /// Whether the money line renders. Discreet drops it entirely (figure AND the
    /// "saved" micro-label): a currency figure beside a day count reads as an
    /// abstinence-savings tracker — the outing signal discreet mode exists to
    /// suppress (R22.2; the money DATA stays in the feed — this is a shoulder-surfer
    /// defense, and the file's field set is separately §10-ruled).
    static func showsMoney(for quit: WidgetQuitState?) -> Bool {
        !isDiscreet(quit)
    }

    /// Whether the systemMedium milestone bar carries its "next milestone"
    /// micro-label. Discreet keeps the BARE bar (a generic progress bar is neutral)
    /// but drops the word — "milestone" is recovery-culture vocabulary that
    /// strengthens the tracker gestalt (R22.2, privacy-panel amendment).
    static func showsMilestoneLabel(for quit: WidgetQuitState?) -> Bool {
        !isDiscreet(quit)
    }
}

/// One view, five families (brandkit item 14, minus the mvp §3-cut StandBy pair —
/// step-0 ruling R7). E6.2 renders NO habit content in any family, so E6.3's discreet
/// variants are render-time branches over the SAME entries (architecture §11): swap
/// the panic glyph/label to the neutral pair, drop money, bare the milestone bar —
/// selection through the pure `StreakWidgetDisplay` helpers above. Accessory families are
/// luminance-only (brandkit §2.4: the system tints; meaning lives in glyph + text,
/// never hue). Animation is banned — the only motion is system-driven
/// `Text(timerInterval:)` / `ProgressView(timerInterval:)` ticking, both explicitly
/// `countsDown: false` (both default to TRUE — docs-checked).
struct StreakWidgetView: View {
    let family: StreakWidgetFamily
    let entry: StreakWidgetEntry
    /// The selected quit's rich state (money/momentum/milestones render from here;
    /// the entry carries timing only). `nil` iff the entry is `.unavailable`.
    let quit: WidgetQuitState?
    /// Freezes ticking text for deterministic snapshot goldens; production passes nil.
    var pauseDate: Date?
    var style: StreakWidgetStyle = .shipping

    var body: some View {
        Group {
            switch family {
            case .rectangular: rectangular
            case .circular: circular
            case .inline: inline
            case .small: small
            case .medium: medium
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }

    // MARK: Families

    /// Lock screen flagship: Day N + money + the interactive panic button (E0.3's
    /// button, carried forward — the full-region affordance stays).
    private var rectangular: some View {
        HStack {
            VStack(alignment: .leading) {
                primaryDayLine(font: .headline)
                if StreakWidgetDisplay.showsMoney(for: quit), let quit,
                   let money = StreakWidgetDisplay.moneyText(for: quit, at: entry.date) {
                    Text("\(money) \(style.savedLabel)")
                        .font(.caption2)
                }
            }
            Spacer()
            Button(intent: StreakWidgetDisplay.panicIntent(for: quit)) {
                Image(systemName: StreakWidgetDisplay.panicGlyph(for: quit, style: style))
            }
            .accessibilityLabel(StreakWidgetDisplay.panicAccessibilityLabel(for: quit, style: style))
        }
    }

    /// The day ring: center = Day N, ring = system-driven progress through the local
    /// day (`tickWindow` IS the real local day, 23/25h on DST days). Zero extra data
    /// fields, no milestone consumer on the lock screen (step-0 R6).
    private var circular: some View {
        Group {
            if let window = entry.tickWindow, let day = entry.dayNumber {
                ProgressView(timerInterval: window, countsDown: false) {
                    EmptyView()
                } currentValueLabel: {
                    Text(verbatim: "\(day)")
                        .font(.headline.monospacedDigit())
                }
            } else {
                Image(systemName: "wind")
            }
        }
    }

    /// One line of text — the system renders inline as text only.
    private var inline: some View {
        Text(StreakWidgetDisplay.dayText(entry) ?? style.unavailableText)
    }

    /// Home small: Day N + ticking streak duration + the momentum ring (step-0 P2.b
    /// ruled momentum over the milestone bar here — closes brandkit §11 Q3).
    private var small: some View {
        VStack(alignment: .leading, spacing: 4) {
            primaryDayLine(font: .title2.weight(.bold))
            tickerLine
            Spacer(minLength: 0)
            if let quit {
                Gauge(value: Double(min(100, max(0, quit.momentumPercent))) / 100) {
                    EmptyView()
                } currentValueLabel: {
                    Text(verbatim: "\(quit.momentumPercent)%")
                        .font(.caption2.monospacedDigit())
                }
                .gaugeStyle(.accessoryCircularCapacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    /// Home medium: the small content plus money and the milestone progress bar
    /// (bar data = elapsed ÷ next rung; milestone TITLES never reach the widget).
    private var medium: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                primaryDayLine(font: .title2.weight(.bold))
                tickerLine
            }
            Spacer()
            VStack(alignment: .leading, spacing: 4) {
                if let quit {
                    if StreakWidgetDisplay.showsMoney(for: quit),
                       let money = StreakWidgetDisplay.moneyText(for: quit, at: entry.date) {
                        Text(money)
                            .font(.title3.weight(.semibold).monospacedDigit())
                        Text(style.savedLabel)
                            .font(.caption2)
                    }
                    if let progress = StreakWidgetDisplay.milestoneProgress(for: quit, at: entry.date) {
                        ProgressView(value: progress)
                        if StreakWidgetDisplay.showsMilestoneLabel(for: quit) {
                            Text(style.milestoneLabel)
                                .font(.caption2)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: Shared pieces

    /// "Day N" when the entry has one; the calm unavailable line otherwise (never a
    /// fabricated "Day 0", never an error face — planner contract).
    private func primaryDayLine(font: Font) -> some View {
        Text(StreakWidgetDisplay.dayText(entry) ?? style.unavailableText)
            .font(font)
    }

    /// The ticking streak duration (count-up: `countsDown: false` is load-bearing).
    /// Hidden when the interval would invert under a rolled-back clock.
    @ViewBuilder private var tickerLine: some View {
        if let quit, let interval = StreakWidgetDisplay.tickerInterval(for: quit, entry: entry) {
            Text(timerInterval: interval, pauseTime: pauseDate, countsDown: false, showsHours: true)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}
