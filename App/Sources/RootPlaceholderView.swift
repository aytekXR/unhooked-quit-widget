import SwiftUI

/// Normal-launch root for the walking skeleton. Real tabs (dashboard/settings) arrive
/// with their epics; this view exists so E0.1's UI smoke has a stable anchor.
///
/// Copy/style constraints honored even in placeholders: no red anywhere
/// (brandkit §2 hard rule), no habit-naming or shame lexicon, SF Symbols only.
struct RootPlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "circle.dashed")
                .font(.largeTitle)
                .foregroundStyle(.teal)
                .accessibilityHidden(true)
            Text("Walking skeleton")
                .font(.title2.weight(.semibold))
            Text("Nothing here yet — features arrive epic by epic.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("root.placeholder")
    }
}

#Preview {
    RootPlaceholderView()
}
