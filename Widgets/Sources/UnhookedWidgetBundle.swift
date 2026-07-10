import SwiftUI
import WidgetKit

@main
struct UnhookedWidgetBundle: WidgetBundle {
    var body: some Widget {
        SkeletonWidget()
        PanicControlWidget()
        PanicResetControlWidget()
    }
}
