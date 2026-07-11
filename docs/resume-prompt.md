# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v3.1 |
| Last updated | 2026-07-11 (Session 19 close: E8.2 COMPLETE — red evidence `29164705316` (225 tests, EXACTLY the 39 designed issues / 14 designed failing tests, two-lane-predicted issue-for-issue: 34 Linux-harness-EMPIRICAL + 5 hand-enumerated) → green `29165381934` all-green + TestFlight; **2 billed runs, zero burned — the streak restarts**) |
| Phase | Phase 1 done in build terms; Phase 2 opens — E2–E5 + E8 CLOSED (E8.2's audit EXECUTION is the operator half); delivery 21/32 (66%) |
| Next session objective | **Session 20: E6.1 — WidgetToolkit timeline provider (midnight/DST rollover, stale-grace, ticking counters)** |

> **What changed in Session 19:** E8.2 shipped WHOLE — the consent step RENDERS
> at the reserved fixed slot 3 (new `StepKind.consent`; the engine's visibility
> predicate byte-untouched; the choice is type-level unable to become a
> QuizAnswer/checkpoint byte — the render path calls the new
> `QuizFlowModel.recordConsent` only), persists to the EXISTING
> `AppSettings.analyticsOptIn` AT THE TAP (`setAnalyticsOptIn` over the shared
> singleton helper; fail-closed `try?` injected callback), and **BOTH
> hardwired-off sites are retired into ONE live service**: the composition root
> builds it (late-bound `ConsentReader` breaks the self-reference), the
> repository VENDS it, `PostGateRootView` consumes it — so an opt-in made at
> slot 3 governs the SAME RUN's later fires (the summary's `quiz_completed`,
> pinned). Slot 3 EMITS `quiz_step_completed(3)` post-choice through the generic
> gate (step-0 a; decliners are gate-dropped — zero special-casing). Copy lives
> IN quizConfig slot 3, PM+Brand+QA-signed (Brand STRUCK "anonymous" as an
> unverifiable overclaim; "never tied to you" rides the helper instead), DRAFT/
> founder-owned. `docs/payload-audit.md` = the standing operator MITM release
> gate (its property half waits on the §8 app ID — record, not blocker). The six
> E5.2-era R4 seam pins were REVERSED in the red commit by design. `quit_created`
> deferred AGAIN to its own wiring session (guard-4 stays protective). Ten
> vetoable rulings in operator-expected. Full ledger: Session 19 in
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
   attributes (`@MainActor` on every UITest class — XCUIApplication is
   MainActor-isolated under Swift 6). The parse gate is import-blind
   (Session 15) AND isolation-blind (Session 18). Compile critics must trace
   class-level attributes AND REPRODUCE risky concurrency constructs under
   `-strict-concurrency=complete -warnings-as-errors` (the Session 19 practice:
   repro, don't reason).
3. **Access-level gate + empirical harness:** scan for private types in
   non-private signatures, and RUN (never just typecheck) a Linux scratch
   harness over the exact shipping bytes of every pure-Foundation API — both
   red and green profiles when a designed red exists (Sessions 15–19: the
   harness predicted the billed red runs issue-for-issue, six times running;
   the @Observable model + AnalyticsService + engine + checkpoint lane is all
   harnessable, and the lexicon matcher mirrors into the harness for new
   audited strings).
4. **Docs-check gate:** every Darwin-only / AppIntents / WidgetKit / SF-Symbol /
   third-party member spelling verified against official docs BEFORE code;
   SwiftUI under warnings-as-errors: house `.background(_:in:)` form only.
   E6 is WidgetKit-heavy — `Text(timerInterval:)`, `TimelineProvider`
   signatures, StandBy/accessory families all get the docs pass.
5. Docs-only commits carry `[skip ci]`; never spawn agent workflows for
   docs-only changes. Critic/reader agents Write findings to scratchpad files
   and return a one-line pointer. **NEVER `git stash` mid-session.**
6. `git fetch` + `git log origin/main` before EVERY push — the operator commits
   mid-session.
7. **Privacy-surface gate:** anything touching stores/`AnalyticsEvent`/outbound
   gets Architect pre-approval BEFORE implementation; adding an enum case is
   Architect-gated AND needs the MVP §5 row first (mvp.md is OPERATOR-ONLY).
   **Safety-content** (slip copy, resources, alcohol notice, age gate, quiz,
   consent, companion) needs the PM+Brand+QA joint copy-table sign-off before
   code. Widget-facing strings in discreet mode are habit-context-free BY RULE
   (E6.3's gate, but E6.1 entry content must not paint it into a corner).

## Where we are

- **The M1 user loop is real end to end AND the privacy loop is code-complete:**
  age gate → quiz (11–13 visible screens incl. the slot-3 consent step) →
  personalized summary → placeholder dashboard → panic flow with the user's own
  words → slip → undo. Consent default-off gates every fire LIVE; the transport
  stays DORMANT until the operator's TelemetryDeck app ID (§8) — now the LAST
  gate on real funnel data. The newest TestFlight build walks all of it.
- **Live fire-points:** `onboarding_started` + `quiz_step_completed(1–2)` fire
  pre-consent and are gate-dropped for everyone (recorded limitation: the
  measurable funnel begins at slot 3); `quiz_step_completed(3–13)` +
  `quiz_completed` transmit for opted-in users the moment §8 lands;
  `urge_averted` + `slip_undone` likewise. Deferred fire-points: `slip_logged`,
  `panic_opened` (E0.3), `panic_step_reached`, `erase_all_completed`,
  `quit_created` (its own wiring session WITH the QuizCompletionTests guard-4
  widening — Session 18 ruling 7 / Session 19 ruling 8).
- **E6's seams are waiting:** `rebuildSnapshots()` names `widget-state.json` as
  the second App Group snapshot (writer = E6-era; only `panic-snapshot.json`
  exists today); the `Widgets/` extension target exists with the two panic
  controls + the lock-screen panic widget; `Packages/WidgetToolkit` is scaffolded
  (CI package lane green) and E6.1's rollover/stale/ticking logic belongs THERE
  (portfolio-shared), only templates in the app (plan acceptance).
- The summary CTA (`onContinue` in `PostGateRootView`) is E7's named paywall
  seam. Consent-step a11y ids (`quiz.step.consent`, `quiz.choice.optIn/decline`)
  are in place for E7's smoke. UITEST_RESET stays inert, no consumer.
- **StreakEngine 1.2.0 untouched. TestFlight LIVE** through green `29165381934`.
  CI signing read-only; never re-enable MATCH_BOOTSTRAP; macOS minutes bill 10x.
- Brand kit load-bearing: no red anywhere; slip + age-gate + quiz (incl.
  consent) + summary strings all CI-lexicon-gated; quiz/consent/summary copy is
  DRAFT pending the founder pass (operator-expected §3); Epic-5 goldens (now
  incl. the consent step) deliberately zero until after it.

## Next session objective (one session, definition of done below)

**Session 20 — E6.1 WidgetToolkit timeline provider** (implementation-plan row,
verbatim goal): stateless provider reading shared store → StreakEngine →
entries; midnight/DST rollover; stale-grace; `Text(timerInterval:)` ticking
counters. Plan-named tests: `test_timeline_entriesCrossMidnight_incrementDay()`,
`test_timeline_dstSpringForward_dayBoundaryCorrect()`,
`test_staleGraceEntry_showsLastKnownStreak_ticking()`,
`test_provider_readsStoreReadOnly()`. Acceptance: rollover/stale logic lives in
WidgetToolkit (portfolio-shared, Linux-testable `swift test` lane — CHEAP red
evidence), only templates live in the app. Deps: E1.1, E2.1 (both done).

0. **STEP-0 candidates (resolve BEFORE red):** (a) what exactly feeds the
   provider — the E6 `widget-state.json` snapshot (architecture §7: "widgets are
   pure functions of widget-state.json") vs a direct store read; the plan says
   "reading shared store" but architecture §8/ADR-6 says widgets read ONLY
   snapshots — reconcile (likely: the provider consumes a snapshot DTO, and the
   `rebuildSnapshots()` writer half either lands here or in E6.2; Architect
   rules the split). (b) The `widget-state.json` content-minimization table
   (§10: App Group files are pre-unlock-readable — decide the field set with the
   discreet rule in view; privacy-surface gate applies). (c) Whether the package
   half is a PURE red (swift test on Linux, billed-run-free) with the app-side
   integration riding E6.2 — if so this session may need ZERO or ONE billed
   macOS run (the cheapest session yet; QA rules the honest tier split).
   (d) Timezone/DST fixture discipline: StreakEngine's ManualClock precedents +
   test-suite §3.2 fixtures; name the DST instants (spring-forward) explicitly.
1. **Red first:** the four plan-named tests in the WidgetToolkit package lane
   (Linux `swift test` — local red evidence is FREE; paste the run under `## Red`
   per test-suite §7 rule 1's package-lane provision) + any CI-tier pins the
   step-0 split assigns.
2. **Green:** the provider + rollover/stale/ticking logic in WidgetToolkit;
   app-side templates ONLY if the step-0 split pulls them in.
3. Scope guards: (a) NO widget FAMILY rendering/snapshot matrix (E6.2's); (b) NO
   discreet variants (E6.3's) but no habit strings in any E6.1 entry content;
   (c) NO `widget_added` event wiring without its own step-0 (the enum case
   exists; the fire-point needs a ruling); (d) goldens still deferred; (e) the
   panic pre-cache (`panic-snapshot.json`) is UNTOUCHED — widget-state is a
   SEPARATE file (ADR-6: the panic path never grows a reader/writer here).
4. Budget: potentially ZERO billed macOS runs if the package-lane split holds
   (Linux red+green are free); plan 1 billed run as the ceiling for any app-side
   integration + TestFlight refresh; +1 contingency (check operator-expected §4).

## Operator-owned blockers (not agent work; carry until closed)

1. E0.3 device measurement (`docs/spike-panic-latency.md`) — still the only
   blocker on the permanent latency gate (and `panic_opened`'s `cold_start_ms`).
2. E3.3 device matrix (operator-expected §7).
3. Content tone review (§3) — the FOUNDER COPY PASS now covers quizConfig.json
   (incl. the 4 NEW consent strings + Brand's conditional-vs-imperative helper
   style fork) AND summaryCopy.json + safetyCopy/helplines/ageGateCopy + ALO 182
   + the E4.2 signature. The pass unblocks the Epic-5 goldens batch (now incl.
   the consent step screen).
4. GitHub Actions billing headroom (§4 — Session 19 used exactly its 2 planned).
5. TestFlight testers (§5 — the newest build adds the consent step to the M1
   walk: gate → quiz incl. "Share app usage data?" → summary → dashboard).
6. **TelemetryDeck app ID (§8 — NOW THE LAST GATE on real funnel data**; once it
   lands, run + archive `docs/payload-audit.md` — the audit's §1 explains the
   sequencing); Slack webhook rotation (§6, optional).

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name
> **Ballast**, org `com.beyondkaira`). E8.2 is CLOSED (green `29165381934`; 2
> runs zero burned; the payload audit's EXECUTION rides operator-expected §8);
> Session 20 = E6.1 WidgetToolkit timeline provider. Local Swift toolchain:
> `. ~/.local/share/swiftly/env.sh`.
> **Standing gates:** CodeGraph query-first + sync at close; `swiftc -parse`
> every touched file + import/annotation coverage on every new test file;
> access-level scan + Linux harness RUN empirically (red AND green profiles);
> docs-check every WidgetKit/SDK spelling (house `.background(_:in:)` form
> only); docs-only commits `[skip ci]`, no workflows for docs-only work;
> critics Write findings to files and REPRODUCE risky concurrency constructs;
> NEVER `git stash`; privacy-surface changes (widget-state.json IS one — §10
> pre-unlock-readable) need Architect pre-approval BEFORE code; `git fetch` +
> `git log origin/main` before every push.
> READ FIRST: `docs/implementation-plan.md` E6.1 row + Epic 6 DoD,
> `docs/architecture.md` §7 (widget state) + §8 + §11 (widget refresh) + ADR-6,
> `docs/mvp.md` §2 (widget features) + §5 (`widget_added` — NOT this session
> without a step-0), `docs/operator-expected.md` §3 (founder pass landed? →
> goldens) + §4 + §8, the Session 19 ledger (the E6 seam notes),
> `docs/session-rules.md`, `Packages/WidgetToolkit/` (the scaffold),
> `Widgets/Sources/` (the extension target + panic controls),
> `QuitRepository.rebuildSnapshots()` (the widget-state.json writer seam),
> `docs/frontend-brandkit.md` (widget sections).
> **This session:** STEP-0 rulings (a)–(d) (Architect+PM+QA; the
> snapshot-vs-store feed question is ARCHITECTURE-LOAD-BEARING) → Architect
> pre-approval on the widget-state.json field set (privacy surface, §10) → red
> (the four plan-named tests, package lane = FREE Linux evidence) → green
> (WidgetToolkit logic; templates only if ruled in) → verify → flag operator
> items. Budget: 0–1 billed runs + 1 contingency.
> **At session end:** append the Session 20 ledger, overwrite this resume
> prompt (next per `roadmap.md` — likely E6.2 widget families), update
> `docs/operator-expected.md`, `codegraph sync`, commit `[skip ci]`, push,
> `gh run watch` green.

## Standing rules reminders (do not relearn these)

- Analytics ONLY via the closed enum; zero events before opt-in (the consent
  step at slot 3 IS the choice; the gate reads `AppSettings.analyticsOptIn`
  live); never a generic track; adding a case = MVP §5 row (OPERATOR) +
  Architect + fixture + whitelist. Fires post-save, BESIDE writes, never
  inside; never pre-frame on the panic path (ADR-6). The age-gate surface fires
  NOTHING; pre-consent quiz events (onboarding_started, slots 1–2) are
  gate-dropped for everyone BY DESIGN — the measurable funnel begins at slot 3.
  The transport stays DORMANT until the operator app ID (§8) — now the LAST
  gate; consent alone sends nothing.
- The consent choice is a DEVICE SETTING: `recordConsent` → `persistConsent` →
  `setAnalyticsOptIn` only — never a QuizAnswer, never a checkpoint byte, never
  read back into the transient `consentChoice` (stored false is ambiguous).
  Erase resets it OFF via the AppSettings row deletion (test-pinned).
- No shame copy (slip AND age-gate AND quiz/consent AND summary strings
  CI-gated; lexicon only GROWS); no medical claims; no fabricated statistics or
  testimonials; no red anywhere; discreet variants mandatory where habit context
  exists (E6.3 makes this widget-load-bearing); motivations VERBATIM in user
  order.
- Monotonic fields never decrease — undo is the ONE exemption (§9r3); streaks
  freeze, never inflate (ADR-7); `totalCleanSeconds` is BANKED-only.
  QuizProfile's summary fields are quiz-time projections — never wired into
  recomputeDerivedState (Session 18 MF2).
- WITNESS discipline: three advance paths only; erase clears it; flush/undo
  never advance; deferred slips apply with the SLIP-TIME witness.
- Erase discipline: local-first; key sweep (quiz checkpoint, app-standard
  defaults; consent→OFF rides the row deletion); owned file-set (`widget-state.json`
  JOINS the owned set with its writer — remember the E3.1 standing rule: new
  App Group artifacts join erase in their landing session); cloud purge last;
  post-erase relaunch = fresh install ⇒ the AGE GATE and the QUIZ return.
- Panic path stays thin: panic surfaces NEVER open the store; the panic route
  never consults the gate or the quiz; single store; no accounts;
  `panic-snapshot.json` and `widget-state.json` are SEPARATE files with separate
  readers.
- Control-family attribution ceiling stands (`.controlCenter`); never fabricate
  `.actionButton`.
- Never weaken a QA assertion; TDD red first (red evidence = the CI run on the
  red commit for app lanes, the local `swift test` output for package lanes;
  build failures are NOT evidence); `cloudKitDatabase` stays `.none` until the
  §4.3 flip.
- Snapshot goldens: pinned geometry (.iPhone13) + AX5; re-record deliberately
  via the CI artifact; Epic-5 goldens (incl. summary + consent) wait on the
  founder copy pass; SnapshotTesting 1.19.3 + TelemetryDeck 2.14.1 pinned.
- Carried product notes: store-route SlipFraming passes momentum/motivation nil
  (dashboard epic feeds real values); dashboard-half slip XCUITest waits for the
  fixture-seeding session; the quiz checkpoint is the ONE sanctioned in-progress
  free-text store; `quit_created` fire-point = repository create path (assigned;
  its own wiring session WITH the guard-4 widening); UITest self-isolation = the
  `UITEST_RESET` hook — new state-mutating UITests must use it; it currently has
  NO consumer (E7 re-lands scenario-29 WITH drive diagnostics and now also
  drives the consent step via `quiz.choice.optIn`).
