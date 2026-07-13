import Foundation
import Testing
@testable import Unhooked

// E3.3 unit lane — the panic ENTRY-POINT matrix. The two plan-named tests are verbatim
// (implementation-plan.md E3.3); the attribution pins prove every entry point lands its
// TRUE PanicSource end to end, killing the `.lockscreenWidget` hardcode at
// PanicFlowView.swift:36. All new logic under assertion lives in Shared pure types
// (PanicControlStyle, PanicLaunchFlag, PanicQuitEntity/PanicQuitQuery) so the unit lane
// can reach it — UnhookedTests links target Unhooked only, so the Widgets/Sources
// control wrappers stay thin and invisible here (the constraint that forces the styling
// data into Shared).
//
// Red evidence for this file = the CI run on the red commit. Against the red stubs:
//   - PanicControlStyle returns the STANDARD values for BOTH variants (so the discreet
//     pin fails; the standard pin is green-at-red, guarding the unchanged control);
//   - PanicLaunchFlag.set(source:quitID:) writes the requested + source + quitID keys
//     but launchSource() is the unimplemented reader half (returns nil) and clear()
//     does not yet sweep the source key (so the round-trip and clear-sweep pins fail
//     honestly, not vacuously);
//   - PanicQuitQuery returns [] (so the entity-resolution pin fails);
//   - PanicFlowView's new init(quit:script:source:) accepts but IGNORES `source`
//     (so the view-threading pin fails for every source except the hardcoded default).
//
// UserDefaults hygiene: PanicLaunchFlag reads/writes the process-global App Group suite
// (AppIdentifiers.appGroupID), so the flag pins clear the flag at entry AND in `defer`,
// exactly like PanicPathTests.test_panicIntent_quitIDChannel_roundTripsThroughAppGroup.
// The suite is @MainActor and each flag pin's body is fully synchronous (no `await`
// between set and read), so the main actor runs each to completion without interleaving
// — the parameterized source cases cannot race one another on the shared suite.

// Fixture clock epoch (test-suite §3.2): 2026-07-07T12:00:00Z. Carried per convention
// (each panic unit file owns its file-private fixtures — no cross-file coupling).
private let epoch = Date(timeIntervalSince1970: 1_783_425_600)

/// The pre-cache card fixture, copied verbatim from PanicPathTests/PanicFlowTests so
/// the entity-resolution pin reads exactly the shape the repository writes.
private func card(
    _ label: String?,
    id: UUID = UUID(),
    discreet: Bool = false,
    motivations: [String] = []
) -> QuitSnapshot {
    QuitSnapshot(id: id, label: label, discreet: discreet, motivations: motivations)
}

/// A throwaway pre-cache store rooted at a per-test temp directory standing in for the
/// App Group root (the injected-location pattern the PanicSnapshotStore precedent set;
/// mirrors the Harness in PanicPathTests).
private func makeTempStore() throws -> PanicSnapshotStore {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("e33-snap-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return PanicSnapshotStore(directoryURL: directory)
}

@MainActor
@Suite("E3.3 · Panic entry-point matrix")
struct PanicEntryPointTests {

    // MARK: - Per-quit intent parameter (plan-named)

    /// The `@Parameter` quit that the per-control panic intent carries is resolved by an
    /// AppEntity query over the panic PRE-CACHE (ADR-6: the widget/intent surface is a
    /// pre-cache READER — never SwiftData). `suggestedEntities()` offers every active
    /// quit (the pre-cache is built from `activeQuits()`, so archived quits never
    /// surface — the "resolvesActiveQuits" name is honest), in cache/user order; a
    /// discreet quit surfaces with its label already stripped (§10) so the entity shows
    /// the neutral "Your goal" title, never a habit word. `entities(for:)` resolves a
    /// stored selection back to exactly its card for the round-trip through perform().
    @Test func test_panicIntent_parameter_quitEntity_resolvesActiveQuits() async throws {
        let store = try makeTempStore()
        let open = card("Vaping", motivations: ["For my kids"])
        let hidden = card(nil, discreet: true, motivations: ["sleep"])
        try store.write(PanicSnapshot(quits: [open, hidden]))

        let query = PanicQuitQuery(store: store)

        let suggested = try await query.suggestedEntities()
        #expect(
            suggested.map(\.id) == [open.id, hidden.id],
            "the query offers every active quit as a selectable entity, in cache (user) order"
        )
        #expect(
            suggested.map(\.title) == ["Vaping", "Your goal"],
            "a discreet quit's label is already stripped (§10) — its entity shows the neutral 'Your goal', never a habit word; an open quit shows its label verbatim"
        )

        let byID = try await query.entities(for: [hidden.id])
        #expect(
            byID.map(\.id) == [hidden.id],
            "a stored selection resolves back to exactly its card — the round-trip that carries the chosen quit through perform()"
        )
        #expect(
            byID.first?.title == "Your goal",
            "resolving a discreet quit by id still yields the stripped, neutral title (§10 holds on the resolve path too)"
        )
    }

    // MARK: - Discreet control gallery strings (plan-named)

    /// The discreet control is a SEPARATELY registered control kind, so its gallery
    /// strings (title, symbol, displayName, description) must ALL be neutral — a control
    /// the user can hide in plain sight (§10). "Reset" is locked by the plan; the symbol
    /// is the neutral `arrow.counterclockwise` (the brand breath glyph `wind` is NOT
    /// neutral, `eye.slash` outs the user). The description must leak none of the habit
    /// lexicon, and the kind must differ from the standard control's or the two would
    /// collide into one registration.
    @Test func test_controlWidget_discreetMode_usesNeutralTitleAndSymbol() {
        let discreet = PanicControlStyle.discreet

        #expect(discreet.title == "Reset", "the discreet control's title is the plan-locked neutral 'Reset'")
        #expect(
            discreet.symbolName == "arrow.counterclockwise",
            "the discreet glyph is neutral — never the brand breath glyph `wind`, never an outing glyph like `eye.slash`"
        )
        #expect(discreet.displayName == "Reset", "the Settings-gallery display name matches the neutral title")

        let leakLexicon = ["panic", "urge", "quit", "habit", "vape", "smoke", "drink"]
        let description = discreet.description.lowercased()
        for term in leakLexicon {
            #expect(
                !description.contains(term),
                "the discreet control's gallery description must not leak '\(term)' — the Settings widget gallery is readable by anyone holding the phone (§10)"
            )
        }

        #expect(
            discreet.controlKind != PanicControlStyle.standard.controlKind,
            "the discreet control is its OWN registered kind — sharing the standard kind would collapse the two into one control the user cannot place discreetly"
        )
    }

    /// The standard panic control is UNCHANGED by E3.3: still "Panic" + the brand breath
    /// glyph `wind`. Green-at-red by construction (it pins current behavior); its value
    /// is guarding the flagship control against an accidental restyle when the discreet
    /// variant's real values land in the green commit.
    @Test func test_panicControl_standardMode_keepsPanicTitleAndBreathGlyph() {
        let standard = PanicControlStyle.standard

        #expect(standard.title == "Panic", "the flagship control keeps its headline verb")
        #expect(standard.symbolName == "wind", "the flagship control keeps the brand breath glyph")
        #expect(standard.displayName == "Panic", "the flagship gallery name is unchanged")
    }

    // MARK: - Source attribution channel (the .lockscreenWidget hardcode dies)

    /// Every entry point writes its TRUE origin on the same App Group hop that carries
    /// the quit selection, and the app reads it back verbatim: this is the channel that
    /// lets a persisted `UrgeEvent.source` tell a lock-screen widget launch apart from a
    /// Control Center launch (the E3.3 acceptance criterion). Parameterized over all five
    /// sources so no arm silently maps onto another.
    @Test(arguments: PanicSource.allCases)
    func test_launchFlag_source_roundTrips_perSource(_ source: PanicSource) {
        PanicLaunchFlag.clear()
        defer { PanicLaunchFlag.clear() }

        let quitID = UUID()
        PanicLaunchFlag.set(source: source, quitID: quitID)

        #expect(
            PanicLaunchFlag.launchSource() == source,
            "the entry point's TRUE source must survive the intent → app process hop for \(source) — this is what the .lockscreenWidget hardcode replaced with a fiction"
        )
        #expect(
            PanicLaunchFlag.selectedQuitID() == quitID,
            "writing a source carries the chosen quit on the SAME hop — one atomic launch instruction, never two half-written launches"
        )
        #expect(
            PanicLaunchFlag.isSet(),
            "arming a source arms the panic launch — the app's thin route reads isSet() before it builds the panic scene"
        )
    }

    /// A source that survives `clear()` would mis-attribute the NEXT panic launch onto a
    /// stale origin, so clear() must PHYSICALLY sweep the source key alongside the flag
    /// and the selection. Asserted on the raw App Group key (not just launchSource(),
    /// whose own read could mask a lingering key) — the same raw-bytes discipline the
    /// §10 leak pins use.
    @Test func test_launchFlag_clear_removesSourceKey() throws {
        PanicLaunchFlag.clear()
        defer { PanicLaunchFlag.clear() }

        PanicLaunchFlag.set(source: .controlCenter, quitID: UUID())
        PanicLaunchFlag.clear()

        #expect(PanicLaunchFlag.launchSource() == nil, "clear() drops the source together with the flag")
        #expect(!PanicLaunchFlag.isSet(), "clear() drops the requested flag (existing behavior, unweakened)")
        #expect(PanicLaunchFlag.selectedQuitID() == nil, "clear() drops the quit selection (existing behavior, unweakened)")

        let groupDefaults = try #require(UserDefaults(suiteName: AppIdentifiers.appGroupID))
        #expect(
            groupDefaults.string(forKey: PanicLaunchFlag.sourceKey) == nil,
            "clear() must PHYSICALLY remove the source key from the App Group suite — a stale source key would hijack the next launch's attribution even after the flag is gone"
        )
    }

    // MARK: - View threading (the hardcode's last mile)

    /// The source captured pre-frame must thread all the way into the flow model, which
    /// stamps it onto the buffered `PanicOutcomeDraft` → `UrgeEvent.source`. Pinned at
    /// the view→model seam (view-tree introspection is out of scope): constructing the
    /// production `PanicFlowView(quit:script:source:)` must land the injected source on
    /// its model. Parameterized so the surviving `.lockscreenWidget` hardcode fails for
    /// every other source.
    @Test(arguments: PanicSource.allCases)
    func test_panicFlowView_threadsInjectedSourceIntoModel(_ source: PanicSource) throws {
        let script = try #require(
            PanicScript.loadShipping(),
            "the shipping panicScript.json must bundle for the production flow init"
        )

        let view = PanicFlowView(quit: card("Vaping"), script: script, source: source)

        #expect(
            view.model.source == source,
            "the launch-captured source must reach PanicFlowModel.source for \(source) — the flow stamps it onto the outcome draft, so the .lockscreenWidget hardcode at PanicFlowView.swift:36 must be dead"
        )
    }

    /// DESIGNED RED (Session 28 manifest R2): the production init's last mile — the
    /// envelope preference handed to `PanicFlowView(quit:script:source:hapticsOnlyPacer:)`
    /// must land on the model (the `threadsInjectedSource` pin's shape). RED because
    /// the red commit's init accepts the parameter but does not thread it (the model
    /// still constructs with its false default); GREEN passes it through.
    @Test func test_panicFlowView_threadsHapticsOnlyPacerIntoModel() throws {
        let script = try #require(
            PanicScript.loadShipping(),
            "the shipping panicScript.json must bundle for the production flow init"
        )

        let view = PanicFlowView(
            quit: card("Vaping"), script: script, source: .lockscreenWidget, hapticsOnlyPacer: true
        )

        #expect(
            view.model.hapticsOnlyPacer == true,
            "the persisted eyes-free preference must reach PanicFlowModel.hapticsOnlyPacer — an accepted-but-unthreaded parameter leaves every cold launch on the visual pacer"
        )
    }

    // MARK: - In-app entry (the fourth source)

    /// The in-app entry point (E3.3's fourth source — the only one that is NOT a cold
    /// launch) composes from the PRE-CACHE like every other panic mount (one composition
    /// path, ADR-6: the panic surface never opens the store even when the store is warm)
    /// and attributes `.inApp`. The presentation half rides the proven resolver matrix,
    /// so a fresh install (no cache) degrades to the bare breathe frame, never a dead end.
    @Test func test_inAppEntry_attributesInApp_andResolvesFromPreCache() {
        #expect(
            InAppPanicEntry.source == .inApp,
            "an in-app launch must record .inApp — the last surviving `.lockscreenWidget` fiction dies with the E3.3 matrix"
        )

        let open = card("Vaping")
        let hidden = card(nil, discreet: true)
        #expect(
            InAppPanicEntry.presentation(snapshot: PanicSnapshot(quits: [open, hidden])) == .picker([open, hidden]),
            "with several quits and no selection the in-app mount shows the picker — the same resolver matrix as the cold route"
        )
        #expect(
            InAppPanicEntry.presentation(snapshot: PanicSnapshot(quits: [open])) == .breathe(open),
            "a single quit goes straight to its intervention frame"
        )
        #expect(
            InAppPanicEntry.presentation(snapshot: nil) == .empty,
            "no pre-cache (fresh or erased install) degrades to the bare breathe frame — the in-app button never dead-ends (§9)"
        )
    }
}
