import AppIntents
import SwiftUI
import WidgetKit
import WidgetToolkit

/// E6.2 — the real streak widget (kind `StreakWidget`; retires E0.2's SkeletonWidget,
/// step-0 R12, operator-vetoable: testers re-add once). The provider is a thin shim by
/// design: every decision lives in the unit-tested `StreakWidgetComposer` (Shared) —
/// the extension target links into no test bundle, so anything only IT compiles is
/// untestable (test-suite §2's "TimelineProviders tested" is met at the composer).
///
/// ADR-6 discipline: the provider reads ONLY `widget-state.json` (never the store),
/// fires no analytics (the extension structurally cannot — no TelemetryDeck dep), and
/// runs no clock guard (the app corrected `streakStart` at write time).

/// The per-widget quit selector (mvp feature 5): binds by quit UUID via the SAME
/// entity/query the panic intent resolves (R5 — the brand-safe label lives in the
/// panic pre-cache; the widget feed stays label-free). Strings are the shipped
/// intent-vocabulary precedent ("Streak"/"Quit") — no new copy.
struct SelectStreakQuitIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Streak"

    @Parameter(title: "Quit")
    var quit: PanicQuitEntity?

    init() {}
}

/// One rendered timeline instant: the planner's entry (timing) + the selected quit's
/// rich DTO (money/momentum/milestones) the templates read at render time (R1).
struct StreakTimelineBox: TimelineEntry {
    let date: Date
    let widgetEntry: StreakWidgetEntry
    let quit: WidgetQuitState?
}

struct StreakWidgetProvider: AppIntentTimelineProvider {
    /// Gallery/redaction sample: a neutral static "Day 7" (the signed
    /// `placeholderDayText`), NEVER a live read — the gallery preview must not touch
    /// the feed (step-0 P5).
    func placeholder(in context: Context) -> StreakTimelineBox {
        StreakTimelineBox(
            date: .now,
            widgetEntry: StreakWidgetEntry(
                date: .now,
                kind: .streak,
                dayNumber: 7,
                tickWindow: nil,
                freshness: .fresh
            ),
            quit: nil
        )
    }

    func snapshot(for configuration: SelectStreakQuitIntent, in context: Context) async -> StreakTimelineBox {
        box(for: configuration, at: .now).first ?? placeholder(in: context)
    }

    func timeline(for configuration: SelectStreakQuitIntent, in context: Context) async -> Timeline<StreakTimelineBox> {
        let now = Date.now // the E0.2 provider precedent — the extension has no clock seam
        let composition = StreakWidgetComposer.compose(
            feed: WidgetStateStore.appGroup()?.read(),
            configuredQuitID: configuration.quit?.id,
            now: now,
            horizonDays: 2
        )
        let boxes = composition.plan.entries.map {
            StreakTimelineBox(date: $0.date, widgetEntry: $0, quit: composition.quit)
        }
        // The ROLLOVER path (§11): refill at the plan's own renewal point. An
        // unavailable plan has none — the push-based FRESHNESS path reloads it the
        // moment a write produces a feed again.
        let policy: TimelineReloadPolicy = composition.plan.refreshAfter.map { .after($0) } ?? .never
        return Timeline(entries: boxes, policy: policy)
    }

    private func box(for configuration: SelectStreakQuitIntent, at now: Date) -> [StreakTimelineBox] {
        let composition = StreakWidgetComposer.compose(
            feed: WidgetStateStore.appGroup()?.read(),
            configuredQuitID: configuration.quit?.id,
            now: now,
            horizonDays: 0
        )
        return composition.plan.entries.map {
            StreakTimelineBox(date: $0.date, widgetEntry: $0, quit: composition.quit)
        }
    }
}

/// Maps the system family onto the explicit-parameter views (the `widgetFamily`
/// environment key is get-only — readable here, never injectable in tests, which is
/// exactly why the views take the family as a parameter).
struct StreakWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family

    let box: StreakTimelineBox

    var body: some View {
        StreakWidgetView(family: mapped, entry: box.widgetEntry, quit: box.quit)
    }

    private var mapped: StreakWidgetFamily {
        switch family {
        case .accessoryCircular: .circular
        case .accessoryInline: .inline
        case .systemSmall: .small
        case .systemMedium: .medium
        // .accessoryRectangular, plus any future family the system offers before we
        // declare support: the flagship layout is the safe render.
        default: .rectangular
        }
    }
}

struct StreakWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: StreakWidgetStyle.shipping.widgetKind,
            intent: SelectStreakQuitIntent.self,
            provider: StreakWidgetProvider()
        ) { box in
            StreakWidgetEntryView(box: box)
        }
        .configurationDisplayName(StreakWidgetStyle.shipping.displayName)
        .description(StreakWidgetStyle.shipping.galleryDescription)
        .supportedFamilies([
            .accessoryRectangular, .accessoryCircular, .accessoryInline,
            .systemSmall, .systemMedium,
        ])
    }
}
