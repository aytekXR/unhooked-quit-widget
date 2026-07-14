import SwiftUI
import UIKit

/// The SwiftUI half of the token layer (ruling R32.1): `Color` is DERIVED from the
/// token's data via a dynamic provider, so light/dark adapt exactly like the system
/// palette colors the views used before the UIR-0 swap (snapshot tests drive the
/// appearance the same way either form). UIKit is admissible here — this file is
/// App-target-only (UIKit app-only APIs never enter Shared/Sources).
extension ColorToken {
    /// The adaptive SwiftUI color for this token.
    var color: Color {
        Color(UIColor { traits in
            let value = traits.userInterfaceStyle == .dark ? darkRGB : lightRGB
            return UIColor(
                red: CGFloat((value >> 16) & 0xFF) / 255.0,
                green: CGFloat((value >> 8) & 0xFF) / 255.0,
                blue: CGFloat(value & 0xFF) / 255.0,
                alpha: 1
            )
        })
    }
}

extension Theme {
    /// The swapped screens' shared backdrop (brandkit §2.3: warm off-white avoids
    /// clinical white; dark near-black keeps OLED smear off the pacer). One
    /// modifier so every screen states the surface the contrast registry assumes.
    struct ScreenSurface: ViewModifier {
        func body(content: Content) -> some View {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.color.surfaceBase.color.ignoresSafeArea())
        }
    }
}

extension View {
    /// Applies `surface/base` behind the whole screen (tokens-v2 §surfaces).
    func themedScreenSurface() -> some View {
        modifier(Theme.ScreenSurface())
    }
}
