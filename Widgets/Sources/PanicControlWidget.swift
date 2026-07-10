import AppIntents
import SwiftUI
import WidgetKit

/// Control Center / lock-screen / Action-button control for the panic intent.
/// E0.3 acceptance: registration is verified manually on a physical device
/// (docs/spike-panic-latency.md). Strings come from `PanicControlStyle.standard` —
/// the Shared single source of truth the E3.3 unit lane pins; the discreet "Reset"
/// variant is `PanicResetControlWidget`.
struct PanicControlWidget: ControlWidget {
    private static let style = PanicControlStyle.standard

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.style.controlKind) {
            ControlWidgetButton(action: OpenPanicControlIntent()) {
                Label(Self.style.title, systemImage: Self.style.symbolName)
            }
        }
        .displayName("\(Self.style.displayName)")
        .description("\(Self.style.description)")
    }
}
