import SwiftUI
import WidgetKit

/// E0.2 static placeholder widget. Real families/templates arrive in Epic 6 via
/// WidgetToolkit; the accessoryRectangular here also carries the E0.3 spike's
/// interactive panic button (lock-screen AppIntent → thin launch path).
///
/// Placeholder constraints honored: no animation of any kind (brandkit §7 — widgets:
/// animation is banned), no habit-identifying words or glyphs, no red, no custom
/// corner masks (system container shapes only), meaning in glyph + text not hue.
struct SkeletonEntry: TimelineEntry {
    let date: Date
}

struct SkeletonProvider: TimelineProvider {
    func placeholder(in context: Context) -> SkeletonEntry {
        SkeletonEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (SkeletonEntry) -> Void) {
        completion(SkeletonEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SkeletonEntry>) -> Void) {
        // Static skeleton: one entry, never refreshed. Real timelines (midnight
        // rollover, stale-grace) are WidgetToolkit work in E6.1.
        completion(Timeline(entries: [SkeletonEntry(date: .now)], policy: .never))
    }
}

struct SkeletonWidgetView: View {
    var entry: SkeletonEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Day 0")
                    .font(.headline)
                Text("Streak")
                    .font(.caption2)
            }
            Spacer()
            Button(intent: OpenPanicIntent()) {
                Image(systemName: "wind")
            }
            .accessibilityLabel("Panic — opens a full-screen reset")
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

struct SkeletonWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "SkeletonWidget", provider: SkeletonProvider()) { entry in
            SkeletonWidgetView(entry: entry)
        }
        .configurationDisplayName("Streak")
        .description("Walking-skeleton placeholder widget.")
        // accessoryRectangular only: it satisfies both E0.2 (placeholder renders) and
        // E0.3 (lock-screen panic button). Other families are Epic 6 work.
        .supportedFamilies([.accessoryRectangular])
    }
}
