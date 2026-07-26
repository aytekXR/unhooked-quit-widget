import Foundation

/// ME-1 — the app-side half of the widget-adoption handshake: turns each
/// un-acknowledged first-render stamp into at most ONE `widget_added` fire
/// through the ONE consent-gated service, then acknowledges it.
///
/// Acknowledge-regardless-of-consent is deliberate (ADR-8): consent-off means
/// the event never existed — parking it for a later opt-in would transmit a
/// pre-consent fact. An unknown wire name (a future family this build does not
/// know) leaves its stamp standing for a build that does.
@MainActor
enum WidgetAdoptionWiring {
    /// Returns how many stamps were consumed (fired-or-swallowed + acknowledged).
    @discardableResult
    static func firePendingAdoptions(
        analytics: AnalyticsService,
        defaults: UserDefaults? = WidgetAdoptionHandshake.groupDefaults
    ) -> Int {
        var consumed = 0
        for pending in WidgetAdoptionHandshake.pending(in: defaults) {
            guard let kind = WidgetKind(rawValue: pending.kindWireName) else { continue }
            analytics.fire(.widgetAdded(kind: kind, discreet: pending.discreet))
            WidgetAdoptionHandshake.acknowledge(pending.kindWireName, in: defaults)
            consumed += 1
        }
        return consumed
    }
}
