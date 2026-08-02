import Foundation
// `MonotonicNow` (used by the file-local ManualClock below) is declared in the
// StreakEngine PACKAGE, not in Ballast — `QuizCompletionTests`, whose clock shape
// this copies, imports it for exactly that reason. Omitting it is the one thing
// `swiftc -parse` cannot catch: the syntax is fine, the name just is not in scope.
import StreakEngine
import SwiftData
import Testing
@testable import Ballast

// QW-3 (Session 61) — the first two of the five dormant fire-points, wired.
//
// WHY THIS SUITE EXISTS. `AnalyticsEvent` has declared `quit_created` and
// `erase_all_completed` since E8.1 and NEITHER HAD A SINGLE CALL SITE — counted
// from source at the start of S61: five of the nineteen audited events were
// declared, parameter-typed, unit-pinned by `AnalyticsEventTests`, and never
// fired by anything. `redesign/design-roadmap.md` rates QW-3 **High** for the
// reason that matters: three of the five MVP success metrics are unmeasurable
// without them, so the month-3 kill/pivot checkpoint has nothing behind it.
//
// THE FIRE-POINTS WERE NOT INVENTED HERE. Both were assigned by the Architect and
// left as named seams in `QuitRepository`, and both are implemented to their own
// stated spec rather than to a fresh opinion:
//
//   quit_created  "fires HERE post-save … (quitIndex = quit.sortIndex + 1). The
//                 repository create path is the fire-point so both onboarding AND
//                 the future E6.2 dashboard add emit it exactly once."
//   erase_all     "the final `erase_all_completed` fires here IF opted in … zero
//                 events before consent, and none after erase in the same process
//                 lifetime."
//
// The one judgment S61 added is that `quit_created` belongs on BOTH `createQuit`
// overloads. The seam says "both onboarding AND the future dashboard add", and the
// plain `createQuit(habitCategory:…)` overload is the one a dashboard add calls —
// wiring only the quiz path would have undercounted every non-onboarding quit and
// looked correct in every test that only walks the funnel.
//
// CONSENT IS THE POINT, NOT A DETAIL. Every assertion below is duplicated across
// opted-in and opted-out, because `zero events before opt-in` is an App Privacy
// label claim and a §10 promise, not a preference.

// ── File-local fixtures, per the house no-shared-fixtures convention. Every one
// of these is `private` in each suite that needs it (verified: `SpyWidgetRefresher`
// alone is declared privately in at least three test files), so they are declared
// here rather than imported — copying the shapes verbatim from `QuizCompletionTests`,
// which drives the same repository.

private let epoch = Date(timeIntervalSince1970: 1_783_425_600)
private let bootA = UUID(uuidString: "0B00071D-A000-4000-8000-000000000001")!

@MainActor
private final class ManualClock: ClockProviding {
    var now: Date
    var monotonicNow: MonotonicNow
    init(now: Date = epoch, bootID: UUID = bootA, uptime: TimeInterval = 50_000) {
        self.now = now
        self.monotonicNow = MonotonicNow(bootID: bootID, uptime: uptime)
    }
}

@MainActor
private final class SpyWidgetRefresher: WidgetRefreshing {
    private(set) var reloadCount = 0
    func reloadAllTimelines() { reloadCount += 1 }
}

@MainActor
private final class StubCloudSync: CloudSyncControlling {
    func accountStatus() async -> CloudAccountStatus { .available }
    func deleteAllPrivateZones() async throws {}
}

/// The typed-event spy (test-suite §3.1) — file-local copy, same convention.
@MainActor
private final class SpyAnalyticsSink: AnalyticsSink {
    private(set) var received: [AnalyticsEvent] = []
    func receive(_ event: AnalyticsEvent) { received.append(event) }
}

/// A QuizProfile carrying the given answers — built in test code, exactly as
/// `QuizCompletionTests.fixtureProfile` does (Tests/ may touch SwiftData types;
/// production assembly stays in the repository).
@MainActor
private func fixtureProfile(_ answers: [QuizAnswer]) -> QuizProfile {
    let profile = QuizProfile()
    profile.answers = answers
    return profile
}

/// The minimal answer set the quiz create path needs, copied from
/// `QuizCompletionTests`' canned minimal path.
@MainActor
private func minimalAnswers() -> [QuizAnswer] {
    [
        QuizAnswer(stepID: "habit", choiceIDs: ["vape"]),
        QuizAnswer(stepID: "frequency", choiceIDs: ["daily"]),
        QuizAnswer(stepID: "spend", choiceIDs: [], freeText: "26"),
        QuizAnswer(stepID: "duration", choiceIDs: ["y1to3"]),
        QuizAnswer(stepID: "triggers", choiceIDs: ["stress", "evenings"]),
        QuizAnswer(stepID: "priorAttempts", choiceIDs: ["few"]),
        QuizAnswer(stepID: "motivations", choiceIDs: ["Energy", "Money"]),
        QuizAnswer(stepID: "effects", choiceIDs: ["tired"]),
        QuizAnswer(stepID: "goal", choiceIDs: ["quit"]),
    ]
}

@MainActor
private struct Harness {
    let repository: QuitRepository
    let spy: SpyAnalyticsSink

    init(optedIn: Bool) throws {
        let container = try ModelContainer(
            for: PersistentStore.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        let spy = SpyAnalyticsSink()
        self.spy = spy
        repository = QuitRepository(
            container: container,
            clock: ManualClock(),
            widgetRefresher: SpyWidgetRefresher(),
            lastKnownGoodStore: LastKnownGoodStore(
                defaults: UserDefaults(suiteName: "qw3-lkg-\(UUID().uuidString)")!
            ),
            cloud: StubCloudSync(),
            appGroupDefaults: UserDefaults(suiteName: "qw3-group-\(UUID().uuidString)")!,
            panicSnapshotStore: PanicSnapshotStore(
                directoryURL: FileManager.default.temporaryDirectory
                    .appendingPathComponent("qw3-snap-\(UUID().uuidString)", isDirectory: true)
            ),
            // Declaration order matters: `analytics` is the LAST parameter, after
            // `debounceSleep` (checked against the init rather than assumed — the
            // reverse order compiles nowhere and would have cost a run).
            debounceSleep: { _ in },
            analytics: AnalyticsService(sink: spy, isOptedIn: { optedIn })
        )
    }
}

private extension Array where Element == AnalyticsEvent {
    var quitCreatedEvents: [AnalyticsEvent] {
        filter { if case .quitCreated = $0 { return true } else { return false } }
    }
    var eraseEvents: [AnalyticsEvent] {
        filter { if case .eraseAllCompleted = $0 { return true } else { return false } }
    }
}

@MainActor
@Suite("QW-3 · quit_created + erase_all_completed wires")
struct QuitCreatedWireTests {

    // MARK: - quit_created

    /// The ordinal is 1-BASED and is an ordinal, never an identifier — the enum's own
    /// doc comment says so in as many words ("`quitIndex` is the 1-based ordinal
    /// (1–3), NEVER an identifier — a UUID here would be a §10 violation"), and
    /// `mvp.md` §5 pins the range. A 0-based index would silently mis-bucket every
    /// cohort in the activation funnel while every test that ignored the value passed.
    @Test func test_createQuit_optedIn_firesQuitCreatedWithOneBasedOrdinal() throws {
        let h = try Harness(optedIn: true)

        _ = try h.repository.createQuit(habitCategory: .vape, goalMode: .quit)
        let events = h.spy.received.quitCreatedEvents
        #expect(events.count == 1, "one create, one event — fired beside the durable write")

        guard case let .quitCreated(habitCategory, goalMode, quitIndex) = events[0] else {
            Issue.record("expected quitCreated, got \(events[0])")
            return
        }
        #expect(habitCategory == .vape)
        #expect(goalMode == .quit)
        #expect(quitIndex == 1, "the FIRST quit is index 1, not 0 (mvp §5: the range is 1–3)")
    }

    /// The ordinal has to MOVE, or it is a constant wearing a metric's name. This is
    /// the assertion that would have caught a hardcoded 1.
    @Test func test_createQuit_secondAndThird_incrementTheOrdinal() throws {
        let h = try Harness(optedIn: true)

        _ = try h.repository.createQuit(habitCategory: .vape, goalMode: .quit)
        _ = try h.repository.createQuit(habitCategory: .alcohol, goalMode: .reduce)
        _ = try h.repository.createQuit(habitCategory: .weed, goalMode: .quit)

        let ordinals = h.spy.received.quitCreatedEvents.compactMap { event -> Int? in
            guard case let .quitCreated(_, _, index) = event else { return nil }
            return index
        }
        #expect(ordinals == [1, 2, 3], "three quits ⇒ ordinals 1, 2, 3 — got \(ordinals)")
    }

    /// The quiz path is the one onboarding actually walks, and it is a DIFFERENT
    /// overload from the one above. Both are wired; this pins the one a user meets.
    @Test func test_createQuitFromProfile_optedIn_firesQuitCreated() throws {
        let h = try Harness(optedIn: true)
        let profile = fixtureProfile(minimalAnswers())

        _ = try h.repository.createQuit(from: profile)

        // NOTE the string form: `#expect`'s comment parameter is `Comment?`, which is
        // ExpressibleByStringLiteral — a LITERAL converts, a concatenated `"a" + "b"`
        // is a String expression and does not. Multi-line literals are the house form
        // (`OnboardingLayoutLintTests` uses them) and they are still literals.
        #expect(
            h.spy.received.quitCreatedEvents.count == 1,
            """
            the quiz create path fires exactly once — it is the same seam, and the \
            seam's own wording is that BOTH create paths emit
            """
        )
    }

    /// §10 / App Privacy: zero events before opt-in. Not a preference — a published
    /// claim, and the label is derived from this enum.
    @Test func test_createQuit_optedOut_firesNothingAtAll() throws {
        let h = try Harness(optedIn: false)

        _ = try h.repository.createQuit(habitCategory: .vape, goalMode: .quit)

        #expect(
            h.spy.received.isEmpty,
            "an opted-out install must emit NOTHING — got \(h.spy.received)"
        )
    }

    // MARK: - erase_all_completed

    /// The erase event's claim is "this device's data is gone", so it must fire on a
    /// completed erase and carry no parameters (the enum gives it `[:]` — an erase
    /// event with a habit category attached would be its own privacy joke).
    @Test func test_eraseEverything_optedIn_firesEraseAllCompletedWithNoParameters() async throws {
        let h = try Harness(optedIn: true)
        _ = try h.repository.createQuit(habitCategory: .vape, goalMode: .quit)

        try await h.repository.eraseEverything()

        let events = h.spy.received.eraseEvents
        #expect(events.count == 1, "one completed erase, one event")
        #expect(
            events.first?.parameters.isEmpty == true,
            "erase_all_completed carries no properties by design"
        )
    }

    /// The same consent floor, on the surface where breaking it would be worst.
    @Test func test_eraseEverything_optedOut_firesNothing() async throws {
        let h = try Harness(optedIn: false)
        _ = try h.repository.createQuit(habitCategory: .vape, goalMode: .quit)

        try await h.repository.eraseEverything()

        #expect(h.spy.received.isEmpty, "opted out ⇒ silence, including on erase")
    }
}
