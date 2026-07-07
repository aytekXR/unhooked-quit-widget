import SwiftUI

/// Bare full-screen view the panic route lands on (E0.3 spike harness).
/// This is throwaway UI: the real breath pacer/flow is Epic 3. What matters now is
/// that this frame appears with zero store queries, zero network, zero decorative
/// animation (brandkit §7: the <2s budget spends nothing on transitions).
struct PanicPlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wind")
                .font(.system(size: 56))
                .foregroundStyle(.teal)
                .accessibilityHidden(true)
            Text("You're here. Breathe.")
                .font(.title.weight(.semibold))
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            PanicLaunchTrace.endIfActive()
            PanicLaunchFlag.clear()
        }
    }
}

#Preview {
    PanicPlaceholderView()
}
