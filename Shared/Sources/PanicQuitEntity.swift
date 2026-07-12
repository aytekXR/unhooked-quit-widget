import AppIntents
import Foundation

/// The AppEntity a per-control panic intent's `@Parameter(title: "Quit")` resolves to.
/// Lives in Shared/Sources so the app and the widget extension build the intent from ONE
/// type (the pre-iOS-17 shared-source pattern — no AppIntentsPackage, no double
/// registration). Its query reads ONLY the panic pre-cache (ADR-6), never SwiftData.
struct PanicQuitEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Quit"
    static let defaultQuery = PanicQuitQuery()

    let id: UUID
    let title: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }

    /// A discreet quit arrives with its label already stripped (§10) — it surfaces as the
    /// neutral "Your goal" (the existing discreet precedent, PanicPlaceholderView).
    init(card: QuitSnapshot) {
        id = card.id
        title = card.label ?? "Your goal"
    }

    /// E6.2: the streak widget's panic button builds its intent from the label-FREE
    /// widget feed (§10 keeps labels out of widget-state.json), so the entity carries
    /// the configured quit's id with the neutral title. `perform()` reads only the id.
    init(id: UUID, title: String) {
        self.id = id
        self.title = title
    }
}

/// Resolves panic quits for the intent parameter over the pre-cache. Injected-location
/// per the PanicSnapshotStore precedent: production reads the App Group cache, tests point
/// `store` at a throwaway temp directory. The memberwise init's default satisfies
/// EntityQuery's required `init()` (no custom init declared).
struct PanicQuitQuery: EntityQuery {
    var store: PanicSnapshotStore? = PanicSnapshotStore.appGroup()

    func entities(for identifiers: [UUID]) async throws -> [PanicQuitEntity] {
        let wanted = Set(identifiers)
        return cards().filter { wanted.contains($0.id) }.map(PanicQuitEntity.init(card:))
    }

    func suggestedEntities() async throws -> [PanicQuitEntity] {
        cards().map(PanicQuitEntity.init(card:))
    }

    /// The pre-cache cards this query resolves over (nil-safe; empty when no cache).
    private func cards() -> [QuitSnapshot] {
        store?.read()?.quits ?? []
    }
}
