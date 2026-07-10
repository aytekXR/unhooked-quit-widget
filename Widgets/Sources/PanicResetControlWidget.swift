import AppIntents
import SwiftUI
import WidgetKit

/// The DISCREET control variant (E3.3): "Reset" + a neutral glyph, its own registered
/// kind so the user can place it INSTEAD of the flagship control anywhere controls go
/// (Control Center, lock screen, Action button). Every gallery-visible string stays
/// habit-neutral — the Settings controls gallery is readable by anyone holding the
/// phone (§10). Brandkit §2.4: controls carry zero brand color (the system tints);
/// meaning lives in glyph + text. Strings come from `PanicControlStyle.discreet`, the
/// Shared single source of truth pinned by the E3.3 unit lane's discreet test.
struct PanicResetControlWidget: ControlWidget {
    private static let style = PanicControlStyle.discreet

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
