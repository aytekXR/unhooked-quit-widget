# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v3.2 |
| Last updated | 2026-07-12 (Session 20 close: E6.1 COMPLETE — red evidence = the LOCAL package lane (9 failing / 27 issues, zero crashes) → green 15/15, 98.68% lines vs the now-CI-enforced 90% floor; **1 billed run**, red+green pushed together) |
| Phase | Phase 2 — E2–E5 + E8 CLOSED, E6.1 (package half) CLOSED; delivery 22/32 (69%) |
| Next session objective | **Session 21: E6.2 — widget families + THE APP HALF of the widget feed** |

> **What changed in Session 20:** WidgetToolkit stopped being a stub. It now owns
> `StreakTimelinePlanner` — a stateless pure planner, fed by a read-only seam,
> emitting entries at LOCAL MIDNIGHT in the quit's FIXED start timezone, with
> per-entry stale-grace and `ClosedRange<Date>` ticking windows for
> `Text(timerInterval:)`. **The package is Foundation-only BY RULE** (no WidgetKit/
> SwiftUI/StreakEngine — that is what keeps its CI lane on the FREE Linux runner;
> WidgetKit is an adapter concern belonging in the extension). **ADR-11 is NEW and
> binding:** displayed "Day N" = a 1-based CALENDAR day at local midnight in the
> quit's fixed zone — deliberately NOT `StreakValue.days` (elapsed/86_400, a
> tz-invariant DURATION readout with zero display consumers). The green critics
> REPRODUCED five real defects (the day count STALLED forever in zones that spring
> forward AT midnight; "Day 0"/"Day -399" on a rolled-back clock; stale-grace was
> dead after the first entry; a `refreshAfter == now` hot loop; and
> `TimeZone.autoupdatingCurrent` surviving Codable to re-bind on the reading
> device). All five are fixed and test-pinned. Full ledger: Session 20 in
> `docs/past-prompts.md`.

---

## Standing tooling rules (permanent, apply to every agent)

1. **CodeGraph**: query `codegraph_explore` (shell: `codegraph explore "..."`)
   BEFORE grep/find or manual reading; pass this instruction into every
   subagent/workflow prompt; check blast radius before editing public symbols.
   **Before the session-end commit: `codegraph sync` + confirm status clean.**
2. **Parse gate**: `swiftc -parse` every touched Swift file before every push.
   PLUS the import-AND-ANNOTATION coverage check on every NEW test file: copy
   the closest proven neighbor's import block AND its CLASS DECLARATION LINE
   attributes (`@MainActor` on every UITest class). The parse gate is
   import-blind (Session 15) AND isolation-blind (Session 18). Compile critics
   must REPRODUCE risky concurrency constructs under
   `-strict-concurrency=complete -warnings-as-errors`, never reason about them.
3. **Access-level gate + empirical harness:** scan for private types in
   non-private signatures, and RUN (never just typecheck) a Linux scratch
   harness over the exact shipping bytes of every pure-Foundation API.
   **Session 20 sharpened this: probe the BOUNDARY, not the middle.** The lead's
   first day-count harness probed at noon and passed; the bug lived at exact
   midnight. A harness that samples where the code is comfortable proves nothing.
4. **Docs-check gate:** every Darwin-only / AppIntents / WidgetKit / SF-Symbol /
   third-party member spelling verified against official docs BEFORE code
   (Apple's docs JSON endpoint works:
   `developer.apple.com/tutorials/data/documentation/<path>.json`). SwiftUI under
   warnings-as-errors: house `.background(_:in:)` form only. **Recorded for E6.2:**
   `Text(timerInterval: ClosedRange<Date>, pauseTime: Date? = nil, countsDown:
   Bool = true, showsHours: Bool = true)` — iOS 16+, and `countsDown` defaults to
   **true**, so a count-UP streak MUST pass `countsDown: false`.
5. Docs-only commits carry `[skip ci]`; never spawn agent workflows for
   docs-only changes. Critic/reader agents Write findings to scratchpad files
   and return a one-line pointer. **NEVER `git stash` mid-session.**
6. `git fetch` + `git log origin/main` before EVERY push — the operator commits
   mid-session.
7. **Privacy-surface gate:** anything touching stores/`AnalyticsEvent`/outbound
   gets Architect pre-approval BEFORE implementation; adding an enum case is
   Architect-gated AND needs the MVP §5 row first (mvp.md is OPERATOR-ONLY).
   **Safety-content** (slip copy, resources, alcohol notice, age gate, quiz,
   consent, companion, **widget gallery strings**) needs the PM+Brand+QA joint
   copy-table sign-off before code. **`widget-state.json` IS a privacy surface**
   (§10: App Group files are pre-unlock-readable) — its field set needs Architect
   pre-approval BEFORE the writer lands.
8. **BUDGET REALITY (Session 20 correction — do not relearn this):** there is **no
   such thing as a zero-billed-run CODE session.** `ci.yml`'s only exclusion is
   `paths-ignore: docs/**, **.md`, and there is NO per-job path filter — so ANY
   push touching `Packages/**`, `App/**`, `Widgets/**`, `Tests/**` or `project.yml`
   runs the macos-26 `app` job (10x), and a green push to main additionally runs
   the macos-26 `testflight` job. Free *lanes* exist; free *runs* do not. **The
   honest lever: push red+green TOGETHER so GHA fires once at HEAD** (package-lane
   red evidence is the LOCAL `swift test` output — session-rules.md:84-85).

## Where we are

- **The M1 user loop is real end to end and the privacy loop is code-complete:**
  age gate → quiz (11–13 screens incl. the slot-3 consent step) → personalized
  summary → placeholder dashboard → panic flow with the user's own words → slip →
  undo. Consent default-off gates every fire LIVE; the transport stays DORMANT
  until the operator's TelemetryDeck app ID (§8).
- **E6.1 shipped the widget BRAIN, not yet the widget.** `StreakTimelinePlanner`
  is complete and tested, but nothing feeds it and nothing renders it: the
  `widget-state.json` writer does not exist, and the extension does not even link
  WidgetToolkit. **That is exactly E6.2's job** (see the objective below).
- **The widget extension today:** `Widgets/Sources` has the E0.2 `SkeletonWidget`
  (accessoryRectangular, hardcoded `Text("Day 0")`, the E0.3 panic button) + the
  two panic controls. `UnhookedWidgets` in `project.yml` has **NO package
  dependencies at all**.
- **StreakEngine 1.2.0 untouched. WidgetToolkit is now 1.0.0** (tag
  `widgettoolkit-v1.0.0` at the operator's convenience). TestFlight LIVE.
  CI signing read-only; never re-enable MATCH_BOOTSTRAP; macOS minutes bill 10x.
- Brand kit load-bearing: no red anywhere; slip + age-gate + quiz + consent +
  summary strings all CI-lexicon-gated; that copy is DRAFT pending the founder
  pass (operator-expected §3); Epic-5 goldens deliberately zero until after it.

## Next session objective (one session, definition of done below)

**Session 21 — E6.2: widget families + the APP HALF of the widget feed**
(implementation-plan E6.2 row, incl. its INHERITED list). The families cannot
render real data until the feed exists, so the feed comes first.

0. **STEP-0 candidates (resolve BEFORE red):**
   (a) **The `widget-state.json` FIELD SET — the privacy-gated one (§10,
   pre-unlock-readable).** Architect pre-approval BEFORE code. The ABSENCE set is
   the point: no habit category, no motivations, no slip notes, no label under
   discreet. But the families need money-saved, momentum and the next milestone —
   decide what each family in `mvp.md` §2 feature 6 / brandkit item 14 actually
   RENDERS, and let that (nothing else) earn a field. Note `StreakWidgetState` is
   deliberately domain-neutral (portfolio); the app's richer DTO maps ONTO it.
   (b) **Multi-quit binding.** `mvp.md` feature 5's AC is "a per-widget quit
   selector with no cross-contamination". Bind by **quit UUID, never array index**
   (the shipped `PanicQuitQuery` resolves by id; `QuitRepository.activeQuits()`'s
   "widget selectors bind by position" comment is STALE and should be fixed) — a
   `sortIndex` change from the dedupe merge would otherwise silently repoint a
   configured lock-screen widget at a different habit.
   (c) **Milestone-crossing entries** (owed by architecture §11): `afterHours`
   milestones almost never land on a local midnight, so the planner needs a
   `milestones:` parameter or the systemMedium bar renders ~24h stale.
   (d) **`widget_added`** (still unwired, scope-guarded since E6.1): the extension
   structurally CANNOT transmit (no TelemetryDeck dep; consent is SwiftData-backed
   behind ADR-6). `mvp.md`:85 already hedges the trigger as "via widget first-render
   signal". Rule the fire-point, or defer it again — but rule it explicitly.
   (e) **The gallery strings** (`SkeletonWidget` currently ships
   `.description("Walking-skeleton placeholder widget.")` to real testers): they
   are safety-content-gated copy and need a Shared home (the `PanicControlStyle`
   precedent) so the lexicon gate can see them.
1. **Red first:** the plan-named tests (`test_snapshot_<family>_<lightDarkStandBy>()`
   matrix, `test_rectangularWidget_panicButton_invokesPanicIntentWithQuitID()`,
   `test_widgetConfiguration_quitSelector_listsActiveQuitsOnly()`,
   `test_standby_eveningState_showsMadeItThroughCopy()`) + the feed's own pins
   (writer, field set, erase, post-erase `.unavailable`).
2. **Green:** the writer + the families. **`project.yml`: `UnhookedWidgets` MUST
   gain `- package: WidgetToolkit`** before the extension imports it, or the iOS
   build fails with "no such module" — a burned run.
3. **Erase is not optional (E3.1 standing rule):** `widget-state.json` joins the
   owned App Group set in **THREE** enumeration sites in the SAME commit —
   `QuitRepository.eraseEverything()` (`QuitRepository.swift:647`) and BOTH
   `eraseLocalArtifacts` hooks in `UnhookedApp.swift` (`UITEST_SEED_PANIC_THEN_ERASE`,
   `UITEST_RESET`) — plus a test pinning post-erase absence. The planner's half is
   already free: file absent ⇒ ONE `.unavailable` entry, no ticker, no fabricated
   "Day 0".
4. Scope guards: (a) NO discreet variants (E6.3's) — but no habit strings in any
   E6.1/E6.2 entry content, and remember discreet strips the label from the
   snapshot; (b) goldens: the Epic-5 batch still waits on the founder copy pass,
   but the WIDGET snapshot matrix is E6.2's OWN acceptance — record whether it can
   land against DRAFT gallery copy or must batch with §3; (c) ADR-11 binds any
   "Day N" rendered anywhere.
5. Budget: **2 billed runs + 1 contingency** (app-lane red evidence needs a CI run
   on the red commit — it cannot be produced on this Linux box; the package lane's
   red stays free and local). Check operator-expected §4.

## Operator-owned blockers (not agent work; carry until closed)

1. E0.3 device measurement (`docs/spike-panic-latency.md`) — still the only
   blocker on the permanent latency gate (and `panic_opened`'s `cold_start_ms`).
2. E3.3 device matrix (operator-expected §7).
3. Content tone review (§3) — the FOUNDER COPY PASS covers quizConfig.json (incl.
   the 4 consent strings) + summaryCopy.json + safetyCopy/helplines/ageGateCopy +
   ALO 182 + the E4.2 signature. It unblocks the Epic-5 goldens batch. **E6.2 adds
   the widget gallery strings to this queue.**
4. GitHub Actions billing headroom (§4 — Session 20 used exactly its 1 run).
5. TestFlight testers (§5).
6. **TelemetryDeck app ID (§8 — THE LAST GATE on real funnel data**; once it lands,
   run + archive `docs/payload-audit.md`); Slack webhook rotation (§6, optional).

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name **Ballast**,
> org `com.beyondkaira`). E6.1 is CLOSED (green `29174800786`; 1 billed run —
> WidgetToolkit 1.0.0 owns the timeline planner, but NOTHING feeds or renders it
> yet). **Session 21 = E6.2: widget families + THE APP HALF of the widget feed.**
> Local Swift toolchain: `. ~/.local/share/swiftly/env.sh`.
> **Standing gates:** CodeGraph query-first + sync at close; `swiftc -parse` every
> touched file + import/annotation coverage on every new test file; access-level
> scan + Linux harness RUN empirically — **probe the BOUNDARY, not the middle**;
> docs-check every WidgetKit/SDK spelling (`Text(timerInterval:)`'s `countsDown`
> defaults to TRUE — a count-up streak must pass `false`); docs-only commits
> `[skip ci]`; critics REPRODUCE risky constructs under
> `-strict-concurrency=complete -warnings-as-errors`; NEVER `git stash`;
> **`widget-state.json` IS a privacy surface** (§10 pre-unlock-readable) and needs
> Architect pre-approval on its field set BEFORE code; `git fetch` +
> `git log origin/main` before every push. **There is no zero-billed-run code
> session** — push red+green together so CI fires once.
> READ FIRST: `docs/implementation-plan.md` E6.2 row **+ its INHERITED list**,
> `docs/architecture.md` **ADR-11** (the day rule — binding) + §7 + §10 + §11 +
> ADR-6, `docs/mvp.md` §2 features 5/6 + §5 (`widget_added`), the Session 20
> ledger, `docs/session-rules.md`, `Packages/WidgetToolkit/Sources/` (the planner
> you are feeding), `Widgets/Sources/` (SkeletonWidget still hardcodes
> `Text("Day 0")`), `QuitRepository.rebuildSnapshots()` (the writer seam — it
> writes only panic-snapshot.json today), `project.yml` (**`UnhookedWidgets` has NO
> package dependencies — it must gain WidgetToolkit**), `docs/frontend-brandkit.md`
> (§2.4 + item 14 widget families).
> **This session:** STEP-0 rulings (a)–(e) (the field set is ARCHITECT-GATED and
> privacy-load-bearing) → red (feed pins + the family matrix) → green (writer +
> families + the project.yml dep) → erase membership in all THREE sites → verify →
> flag operator items. Budget: 2 billed runs + 1 contingency.
> **At session end:** append the Session 21 ledger, overwrite this resume prompt
> (next per `roadmap.md` — likely E6.3 discreet mode), update
> `docs/operator-expected.md`, `codegraph sync`, commit `[skip ci]`, push,
> `gh run watch` green.

## Standing rules reminders (do not relearn these)

- **ADR-11 (NEW, binding):** displayed "Day N" = 1-based CALENDAR day at local
  midnight in the quit's **fixed start timezone** — never `TimeZone.current` (a
  two-tap Settings change ADR-7's guard cannot see; a westward flight would mint a
  free day). It is NOT `StreakValue.days` (elapsed/86_400 — a tz-invariant DURATION
  readout that feeds milestone math and has zero display consumers). Rendering
  `StreakValue.days` as "Day N" is a BUG (it prints "Day 0" on the quit day). Any
  surface showing "Day N" — dashboard, StandBy, Live Activity — uses ADR-11's rule
  or two surfaces will disagree by a day for the same quit. **Count days by
  anchoring at local NOON**: `startOfDay` is wrong where midnight does not exist
  (Santiago/Havana spring forward AT midnight) and `ordinality(of:.day)` is off by
  one on exact-midnight instants under Linux Foundation.
- Analytics ONLY via the closed enum; zero events before opt-in; never a generic
  track; adding a case = MVP §5 row (OPERATOR) + Architect + fixture + whitelist.
  Fires post-save, BESIDE writes, never inside; never on the panic path (ADR-6).
  **The widget extension can NEVER fire analytics** — it has no TelemetryDeck dep
  and consent is SwiftData-backed behind ADR-6.
- The consent choice is a DEVICE SETTING (`recordConsent` → `setAnalyticsOptIn`);
  never a QuizAnswer, never a checkpoint byte. Erase resets it OFF.
- No shame copy (all shipping copy CI-lexicon-gated; the lexicon only GROWS); no
  medical claims; no fabricated statistics or testimonials; no red anywhere;
  discreet variants mandatory where habit context exists; motivations VERBATIM in
  user order. **Widgets: animation is BANNED** — the only motion is system-driven
  `Text(timerInterval:)` ticking.
- Monotonic fields never decrease — undo is the ONE exemption; streaks freeze,
  never inflate (ADR-7); `totalCleanSeconds` is BANKED-only.
- WITNESS discipline: three advance paths only; erase clears it; flush/undo never
  advance. **Widgets never advance the witness** (they run no guard at all).
- Erase discipline: local-first; key sweep; owned file-set (**`widget-state.json`
  JOINS it with its E6.2 writer, in THREE enumeration sites**); cloud purge last;
  post-erase relaunch = fresh install ⇒ the AGE GATE and the QUIZ return.
- Panic path stays thin: panic surfaces NEVER open the store; single store; no
  accounts; `panic-snapshot.json` and `widget-state.json` are SEPARATE files with
  separate readers (ADR-6).
- **WidgetKit contract:** an EMPTY timeline does not fall back to
  `placeholder(in:)` — WidgetKit keeps the last rendered pixels. A no-data state
  must emit exactly ONE `.unavailable` entry (no ticker), or an erased streak sits
  on the lock screen still ticking.
- Never weaken a QA assertion; TDD red first (red evidence = the CI run on the red
  commit for APP lanes, the local `swift test` output for PACKAGE lanes; build
  failures are NOT evidence); `cloudKitDatabase` stays `.none` until the §4.3 flip.
- Snapshot goldens: pinned geometry (.iPhone13) + AX5; Epic-5 goldens wait on the
  founder copy pass; SnapshotTesting 1.19.3 + TelemetryDeck 2.14.1 pinned.
