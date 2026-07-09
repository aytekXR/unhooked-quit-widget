/// Seam for widget timeline reloads (test-suite §3.1 names `WidgetRefreshing` as a
/// first-class double). Production wraps `WidgetCenter.shared.reloadAllTimelines()`;
/// tests inject a spy. Main-actor bound like its only consumer (the repository).
@MainActor
protocol WidgetRefreshing {
    func reloadAllTimelines()
}
