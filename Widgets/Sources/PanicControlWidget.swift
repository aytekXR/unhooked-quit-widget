import AppIntents
import SwiftUI
import WidgetKit

/// Control Center / lock-screen / Action-button control for the panic intent.
/// E0.3 acceptance: registration is verified manually on a physical device
/// (docs/spike-panic-latency.md). The discreet "Reset" variant is E3.3 work.
struct PanicControlWidget: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "PanicControl") {
            ControlWidgetButton(action: OpenPanicIntent()) {
                Label("Panic", systemImage: "wind")
            }
        }
        .displayName("Panic")
        .description("Opens a full-screen reset, instantly.")
    }
}
