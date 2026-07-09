import SwiftUI

/// The real ~90s panic flow UI (E3.2) — breath pacer → urge timer → reasons →
/// redirect → exits, every step skippable, rendered purely from the flow model
/// (store-free by contract, ADR-6). Mounts inside the panic root's content-stable
/// `root.panicPlaceholder` anchor so every route-level smoke keeps discriminating on
/// the ROUTE, not this epic's content.
struct PanicFlowView: View {
    @State var model: PanicFlowModel

    var body: some View {
        // red skeleton — the step views land with the green commit
        Text("panic flow (E3.2)")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
