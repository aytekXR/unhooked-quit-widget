import WidgetKit

/// Production `WidgetRefreshing` conformance (resume-prompt v2.0 item 1): the seam's
/// single-call passthrough to WidgetCenter. Coverage-exempt by test-suite §2 (a unit
/// test here would test the mock); the behavior it triggers is pinned by the
/// device-tier widget-staleness check (test 38) once widgets render real data (E6).
@MainActor
struct LiveWidgetRefresher: WidgetRefreshing {
    func reloadAllTimelines() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
