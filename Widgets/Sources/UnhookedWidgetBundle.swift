import SwiftUI
import WidgetKit

@main
struct UnhookedWidgetBundle: WidgetBundle {
    var body: some Widget {
        // E6.2: StreakWidget (kind "StreakWidget") replaces E0.2's SkeletonWidget —
        // the placeholder is RETIRED (step-0 R12, operator-vetoable: testers re-add
        // the widget once; its panic button carried into the rectangular family).
        StreakWidget()
        PanicControlWidget()
        PanicResetControlWidget()
    }
}
