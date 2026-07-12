# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v3.4 |
| Last updated | 2026-07-12 (Session 21 close: E6.2 COMPLETE — the widget feed's app half + all five family templates; red evidence `29179114316` matched the manifest name-for-name → final green `29179855734` + TestFlight; **4 billed runs: 1 burned + red + green-with-one-stale-pin + final**) |
| Phase | Phase 2 — E2–E6.2 + E8 CLOSED; delivery 23/32 (72%) |
| Next session objective | **Session 22: E6.3 — discreet mode + alternate icons + app-switcher privacy overlay** |

> **What changed in Session 21:** a REAL streak widget now renders on the lock
> screen. `QuitRepository.rebuildSnapshots()` writes `widget-state.json` (the
> §10-gated, label-free `WidgetFeed` DTO) beside the panic pre-cache on every
> mutating write; `Quit` gained its ADR-11 FIXED zone
> (`startTimeZoneIdentifier`, stamped at creation + one-time launch backfill);
> the extension's `StreakWidget` (new kind, SkeletonWidget RETIRED —
> operator-vetoable) renders five families (rect/circular/inline/small/medium —
> StandBy DEFERRED to v1.1, mvp §3's cut, operator-vetoable) through the
> unit-tested Shared `StreakWidgetComposer`, with per-widget quit binding BY
> UUID over `PanicQuitQuery`. WidgetToolkit is 1.1.0 (milestone-crossing
> `milestones:` param + the decode-door timezone re-pin). 15 widget goldens
> recorded via the red run's own artifact. Full ledger: Session 21 in
> `docs/past-prompts.md` (the R1–R12 arbitration).

---

## Standing tooling rules (permanent, apply to every agent)

1. **CodeGraph**: query `codegraph_explore` (shell: `codegraph explore "..."`)
   BEFORE grep/find or manual reading; pass this instruction into every
   subagent/workflow prompt; check blast radius before editing public symbols.
   **Before the session-end commit: `codegraph sync` + confirm status clean.**
2. **Parse gate**: `swiftc -parse` every touched Swift file before every push.
   PLUS the import-AND-ANNOTATION coverage check on every NEW test file: copy
   the closest proven neighbor's import block AND its type-declaration
   attributes. **NEW (Session 21, the burned-run gate): any API form in a new
   test file that NO neighbor uses is a docs-check item, and the docs check
   must read the DEPRECATION metadata (`metadata.platforms`
   deprecated/deprecatedAt), not just existence — a deprecated API is a BUILD
   FAILURE under warnings-as-errors.** Cross-import overlays are FILE-granular
   (`Button(intent:)` needs SwiftUI AND AppIntents imported in THAT file;
   `swiftc -parse` is blind to it).
3. **Access-level gate + empirical harness:** scan for private types in
   non-private signatures, and RUN (never just typecheck) a Linux scratch
   harness over the exact shipping bytes of every pure-Foundation API —
   **probe the BOUNDARY, not the middle**, and probe under MULTIPLE HOST
   TIMEZONES (TZ=UTC vs a named zone — Session 21's decode-repin inversion was
   invisible on a Berlin-zone host and fatal on the UTC CI runner).
4. **Docs-check gate:** every Darwin-only / AppIntents / WidgetKit / SF-Symbol /
   third-party member spelling verified against official docs BEFORE code
   (`developer.apple.com/tutorials/data/documentation/<path>.json`). Recorded:
   `Text(timerInterval:)` AND `ProgressView(timerInterval:)` both default
   `countsDown` to TRUE — count-up passes `false`. The `widgetFamily`
   environment key is GET-ONLY (views take the family as an explicit param;
   that is why they live in Shared and are snapshot-testable).
5. Docs-only commits carry `[skip ci]`; never spawn agent workflows for
   docs-only changes. Critic/reader agents Write findings to scratchpad files
   and return a one-line pointer. **NEVER `git stash` mid-session.** Check the
   STAGED set before every commit (a stray staged deletion nearly burned a run
   in Session 21).
6. `git fetch` + `git log origin/main` before EVERY push — the operator commits
   mid-session.
7. **Privacy-surface gate:** anything touching stores/`AnalyticsEvent`/outbound
   gets Architect pre-approval BEFORE implementation; adding an enum case is
   Architect-gated AND needs the MVP §5 row first (mvp.md is OPERATOR-ONLY).
   **Safety-content** (slip copy, resources, alcohol notice, age gate, quiz,
   consent, companion, widget gallery strings) needs the PM+Brand+QA joint
   copy-table sign-off before code. `widget-state.json` IS a privacy surface —
   its field set is R1-ruled; ADDING a field (E6.3's discreet flag) needs
   Architect pre-approval. **Scanned string tables must be STRUCTS with STORED
   properties** — Mirror yields NOTHING over computed-property enums, so a
   PanicControlStyle-shaped table makes any reflection lexicon scan vacuously
   green (Session 21 reproduction; the G1 non-vacuity floor is the guard).
8. **BUDGET REALITY:** there is no zero-billed-run code session; free lanes
   exist, free runs do not. App-lane red evidence = the CI run on the red
   commit; package-lane red is the free local `swift test`. **A schema/shared-
   pass change must sweep the FUNCTION-level blast radius of every pin on it
   (return values, not just fields) — Session 21's 4th run was one stale
   `recomputeDerivedState() == false` fixture.**

## Where we are

- **The M1 user loop is real end to end, and a REAL widget now renders it:**
  age gate → quiz (incl. slot-3 consent) → personalized summary → dashboard
  placeholder → panic flow → slip → undo; the lock screen carries "Day N" +
  money + the panic button, self-ticking, timezone-fixed (ADR-11), erased to a
  calm "Ready when you are." by one-tap erase (3-site sweep, test-pinned).
- **E6.2 shipped label-FREE templates by construction** — no habit content
  renders on ANY family, which makes E6.3's discreet variants ADDITIVE (strip
  the wind glyph where needed, neutral gallery copy) rather than a rewrite.
- **StreakEngine 1.2.0 untouched. WidgetToolkit 1.1.0** (tag
  `widgettoolkit-v1.1.0` at the operator's convenience). TestFlight LIVE — the
  newest build is the FIRST whose widget gallery shows real strings.
- Copy status: gallery strings + milestones.json are NEW DRAFT shipping copy in
  the operator's §3 queue; Epic-5 goldens still wait on the founder pass; the
  15 widget goldens are RECORDED (a §3 copy rewrite re-records affected ones,
  batched).

## Next session objective (one session, definition of done below)

**Session 22 — E6.3: discreet mode + alternate icons + app-switcher privacy
overlay** (implementation-plan E6.3 row; deps E6.2 ✓).

0. **STEP-0 candidates (resolve BEFORE red):**
   (a) **The discreet flag joins `WidgetQuitState`** — an ADDITIVE field on a
   §10 surface: Architect pre-approval (the R1 precedent; same schemaVersion,
   additive decode).
   (b) **What discreet strips per family** — E6.2 is already label-free; the
   candidates are the wind glyph (category-adjacent per the PanicControlStyle
   precedent), money (is "$412 saved" an outing signal?), and the gallery
   strings' neutral variants. Brandkit §2.4: discreet variants carry zero brand
   color, zero habit glyphs. PM+Brand+QA copy sign-off for any new string.
   (c) **Alternate icons** — "Calendar-ish" + "Timer" (brandkit §4.3);
   project.yml/actool wiring for alternate icon sets; `discreetIconId` already
   exists on AppSettings.
   (d) **The app-switcher privacy overlay** (`test_appSwitcherOverlay_
   activeWhenDiscreet()`) — scene-phase-driven; interacts with the panic
   route's thin path (ADR-6: nothing heavy pre-frame).
   (e) **`discreet_mode_enabled` fires** (mvp §5 row exists — component
   widget/icon) — fire-point + the R8 widget_added breadcrumb decision ride
   together (both are extension-adjacent signals; widget_added needs its
   FOURTH erase site if built).
1. **Red first:** the plan-named tests (`test_snapshot_<family>_discreet()`
   matrix over the EXISTING five families,
   `test_discreetWidgets_accessibilityLabels_containNoHabitTerms()`,
   `test_altIcon_switch_appliesAndPersists()`,
   `test_appSwitcherOverlay_activeWhenDiscreet()`), + the feed pin for the new
   flag (presence when discreet, absence-set intact).
2. **Green:** the flag through writer→composer→views (render-time branches,
   never separate timelines — architecture §11), the icon switcher, the
   overlay. Goldens: the discreet matrix records via the red run's artifact
   (the R10 flow — it WORKS, keep the views FINAL at red).
3. Scope guards: E6.2's families are the substrate — no template rewrites; the
   Epic-6 DoD's full matrix (families × light/dark × normal/discreet) closes
   with this session MINUS StandBy (deferred, recorded); `widget_active` in
   the DoD is a confirmed typo for widget_added.
4. Budget: **2 billed runs + 1 contingency** (red evidence needs CI; goldens
   ride the red artifact). Check operator-expected §4.

## Operator-owned blockers (not agent work; carry until closed)

1. E0.3 device measurement (`docs/spike-panic-latency.md`) — still the only
   blocker on the permanent latency gate.
2. E3.3 device matrix (operator-expected §7) — **now also carries the E6.2
   rows: tinted-mode render check + widget device QA (day ring mid-fill,
   ticker, 60s freshness, selector binding).**
3. Content tone review (§3) — the founder pass now ALSO covers the widget
   gallery strings (StreakWidgetStyle) + milestones.json (newly shipping).
4. GitHub Actions billing headroom (§4 — Session 21 used 4 runs; see the
   honest accounting there).
5. TestFlight testers (§5) — placed Skeleton widgets vanished with the
   retirement; testers re-add "Streak" once.
6. TelemetryDeck app ID (§8 — THE LAST GATE on real funnel data); Slack
   webhook rotation (§6, optional).

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name
> **Ballast**, org `com.beyondkaira`). E6.2 is CLOSED (final green
> `29179855734`; 4 billed runs — a real five-family streak widget ships;
> WidgetToolkit 1.1.0). **Session 22 = E6.3: discreet mode + alternate icons +
> app-switcher privacy overlay.** Local Swift toolchain:
> `. ~/.local/share/swiftly/env.sh`.
> **Standing gates:** CodeGraph query-first + sync at close; `swiftc -parse`
> every touched file + import/annotation coverage on every new test file +
> **the NEW deprecation gate: any API form no neighbor uses gets its docs
> DEPRECATION metadata checked (deprecated APIs are build failures under
> warnings-as-errors; cross-import overlays are FILE-granular)**; access-level
> scan + Linux harness RUN empirically, probing boundaries **under multiple
> host timezones (TZ=UTC minimum)**; docs-check every WidgetKit/SDK spelling
> (both `timerInterval:` initializers default `countsDown` TRUE; `widgetFamily`
> env is get-only); docs-only commits `[skip ci]`; check the STAGED set before
> every commit; critics REPRODUCE risky constructs under
> `-strict-concurrency=complete -warnings-as-errors`; NEVER `git stash`;
> scanned string tables = STRUCTS with STORED properties (the Mirror-vacuity
> trap); a schema/shared-pass change sweeps FUNCTION-level pin blast radius;
> `widget-state.json` is a §10 surface — the E6.3 discreet flag is an
> Architect-gated ADDITIVE field; `git fetch` + `git log origin/main` before
> every push; push red then green (app-lane red evidence = the CI run on the
> red commit; goldens ride the red run's artifact — keep views FINAL at red).
> READ FIRST: `docs/implementation-plan.md` E6.3 row, the Session 21 ledger in
> `docs/past-prompts.md` (the R1–R12 arbitration — R6 family content, R8
> widget_added mechanism, R9 string-table rules), `docs/architecture.md` ADR-11
> + §10 + §11 + ADR-6, `docs/mvp.md` §2 features 9/6 + §5
> (`discreet_mode_enabled`), `docs/frontend-brandkit.md` §2.4 + §4.3 + item 14,
> `Shared/Sources/StreakWidgetViews.swift` + `WidgetFeed.swift` +
> `StreakWidgetStyle.swift` (the substrate you are branching),
> `Widgets/Sources/StreakWidget.swift`, `docs/session-rules.md`.
> **This session:** STEP-0 rulings (a)–(e) (the discreet feed flag is
> ARCHITECT-GATED) → red (discreet matrix + a11y leak scan + icon persistence +
> overlay + the feed-flag pin) → green (flag through writer→composer→views,
> icons, overlay) → verify → flag operator items. Budget: 2 billed runs + 1
> contingency.
> **At session end:** append the Session 22 ledger, overwrite this resume
> prompt (next per `roadmap.md` — likely E7.1 PaywallKit), update
> `docs/operator-expected.md`, `codegraph sync`, commit `[skip ci]`, push,
> `gh run watch` green.

## Standing rules reminders (do not relearn these)

- **ADR-11 binding:** displayed "Day N" = 1-based CALENDAR day at local
  midnight in the quit's FIXED start timezone (`Quit.startTimeZoneIdentifier`,
  stamped at creation, backfilled once at launch) — never `TimeZone.current`,
  never `StreakValue.days` (elapsed/86_400, zero display consumers). Count by
  NOON anchoring. The widget feed's zone travels as a STRING identifier;
  decode resolves the identifier explicitly (decoding `TimeZone.self` from
  autoupdating bytes binds to the READING host — the Session 21 inversion).
- Analytics ONLY via the closed enum; zero events before opt-in; the widget
  extension can NEVER fire analytics (no TelemetryDeck dep; consent behind
  ADR-6) — the R8 breadcrumb mechanism is the sanctioned path when built.
- The consent choice is a DEVICE SETTING; erase resets it OFF.
- No shame copy (the lexicon only GROWS; gallery/table scans need STORED
  properties + a non-vacuity floor); no medical claims; no red anywhere;
  motivations VERBATIM in user order. **Widgets: animation is BANNED** — the
  only motion is system-driven timerInterval ticking (both initializers:
  `countsDown: false`).
- Monotonic fields never decrease; streaks freeze, never inflate (ADR-7); the
  widget floors at Day 1 and runs NO clock guard (ADR-6).
- WITNESS discipline: three advance paths only; widgets never advance it.
- Erase discipline: local-first; owned file-set =
  {panic-snapshot.json, panic outcome buffer, widget-state.json} in THREE
  enumeration sites; zero active quits ⇒ widget-state is REMOVED (never
  present-empty — WidgetKit keeps last pixels on an empty timeline; the
  planner's nil-read ⇒ ONE .unavailable entry); post-erase relaunch = fresh
  install.
- Panic path stays thin: panic surfaces NEVER open the store; the two App
  Group files have separate readers (ADR-6); the widget feed is label-free BY
  FIELD SET (R1) — the selector's labels come from the panic pre-cache.
- Never weaken a QA assertion (fixture repairs that preserve a pin's meaning
  under a schema change are the sanctioned form — Session 21's 4th run);
  TDD red first; `cloudKitDatabase` stays `.none` until the §4.3 flip.
- Snapshot goldens: light/dark ×5 families + AX5 home-only (accessory Dynamic
  Type is CLAMPED); fixtures dated 2025 so timer windows are fully elapsed;
  `pauseDate` freezes Text tickers; ProgressView(timerInterval:) has NO
  pauseTime. SnapshotTesting 1.19.3 + TelemetryDeck 2.14.1 pinned.
