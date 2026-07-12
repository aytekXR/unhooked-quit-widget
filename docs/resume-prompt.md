# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v3.5 |
| Last updated | 2026-07-12 (Session 22 close: E6.3 COMPLETE — discreet mode + alternate icons + the app-switcher shield; red evidence `29183485997` manifest-matched NAME-FOR-NAME (the 8th consecutive) → green `29184196211` + TestFlight; **exactly the 2 planned billed runs, zero burned, contingency unused — the zero-burn streak restarts**) |
| Phase | Phase 2 — E2–E6 (minus operator device QA) + E8 CLOSED; delivery 24/32 (75%) |
| Next session objective | **Session 23: E7.1 — PaywallKit + the entitlement state machine [PKG:PaywallKit]** |

> **What changed in Session 22:** every widget family now has a REAL discreet
> variant (render-time branches over the same timelines — arch §11): a discreet
> quit's lock screen shows "Day N" + a neutral `arrow.counterclockwise` "Reset"
> button — no money, no wind glyph, no "milestone" vocabulary. Two DRAFT
> alternate icons ("Calendar style" / "Timer style", agent-generated per
> brandkit §4.3, operator-vetoable) switch from the new one-screen
> `DiscreetSettingsView` (per-quit toggles + icon picker, sheeted off the
> placeholder root); erase + a reset-only launch reconciliation heal the
> OS-level icon state the store wipe cannot touch. The app-switcher shield is a
> dedicated UIWindow above .alert (a WindowGroup overlay CANNOT cover sheets —
> the warm-panic sheet renders verbatim motivations; privacy-panel MUST-FIX)
> driven by a tri-state FAIL-CLOSED policy (indeterminate discreet-any ⇒
> covered). `discreet_mode_enabled` fires live (.widget/.icon, enable-only,
> consent-gated). The R8 `widget_added` breadcrumb was DEFERRED to E8 by a
> UNANIMOUS 6/6 panel (field set pre-approved; privacy amendments recorded).
> Full ledger: Session 22 in `docs/past-prompts.md` (rulings R22.1–R22.10).

---

## Standing tooling rules (permanent, apply to every agent)

1. **CodeGraph**: query `codegraph_explore` (shell: `codegraph explore "..."`)
   BEFORE grep/find or manual reading; pass this instruction into every
   subagent/workflow prompt; check blast radius before editing public symbols.
   **Before the session-end commit: `codegraph sync` + confirm status clean.**
2. **Parse gate**: `swiftc -parse` every touched Swift file before every push.
   PLUS the import-AND-ANNOTATION coverage check on every NEW test file: copy
   the closest proven neighbor's import block AND its type-declaration
   attributes. **The deprecation gate (S21): any API form in a new file that NO
   neighbor uses gets its docs DEPRECATION metadata checked — and (NEW, S22)
   an operator/initializer the docs JSON does NOT CONFIRM is treated as
   nonexistent even if tutorials use it: spell it the documented way
   (`UIWindow.Level(rawValue:)`, never the folklore `.alert + 1`).**
   Cross-import overlays are FILE-granular; **UIApplication and every UIKit
   app-only API live in App/Sources ONLY — Shared/Sources compiles into the
   widget extension where `UIApplication.shared` is a HARD compile error.**
3. **Access-level gate + empirical harness:** scan for private types in
   non-private signatures, and RUN (never just typecheck) a Linux scratch
   harness over the exact shipping bytes of every pure-Foundation API —
   probe the BOUNDARY, under MULTIPLE HOST TIMEZONES (TZ=UTC minimum).
   **NEW (S22): JSON pins use JSONSerialization key-SET semantics, never
   byte/string equality — JSONEncoder key order is hash-randomized per run
   (reproduced), so a byte-compare pin flakes even against itself.**
4. **Docs-check gate:** every Darwin-only / AppIntents / WidgetKit / SF-Symbol /
   third-party member spelling verified against official docs BEFORE code
   (`developer.apple.com/tutorials/data/documentation/<path>.json`). Recorded:
   both `timerInterval:` initializers default `countsDown` TRUE; the
   `widgetFamily` env key is GET-ONLY.
5. Docs-only commits carry `[skip ci]`; never spawn agent workflows for
   docs-only changes. Critic/reader agents Write findings to scratchpad files
   and return a one-line pointer. **NEVER `git stash` mid-session.** Check the
   STAGED set before every commit.
6. `git fetch` + `git log origin/main` before EVERY push — the operator commits
   mid-session.
7. **Privacy-surface gate:** anything touching stores/`AnalyticsEvent`/outbound
   gets Architect pre-approval BEFORE implementation; adding an enum case is
   Architect-gated AND needs the MVP §5 row first (mvp.md is OPERATOR-ONLY).
   **Safety-content** needs the PM+Brand+QA joint copy-table sign-off before
   code. `widget-state.json` remains a §10 surface (its field set now includes
   the R22.1 presence-only `discreet: Bool?` — additive fields are Optional,
   presence-only when the absent state is the common one, same schemaVersion).
   Scanned string tables must be STRUCTS with STORED properties (R9/G1/G2/S1
   scans + non-vacuity floors). **A new-file overlay/cover claim must name the
   PRESENTATION LAYER it covers — SwiftUI content overlays do NOT cover
   sheets; window-level covers do (the S22 shield lesson).**
8. **BUDGET REALITY:** there is no zero-billed-run code session; free lanes
   exist, free runs do not. App-lane red evidence = the CI run on the red
   commit; package-lane red is the free local `swift test`. A schema/shared-
   pass change sweeps the FUNCTION-level blast radius of every pin on it.

## Where we are

- **The M1 loop + a real, discreet-capable widget suite:** age gate → quiz
  (slot-3 consent) → summary → dashboard placeholder → panic flow → slip →
  undo; five widget families with normal AND discreet variants, per-widget
  quit binding, one-tap erase sweeping everything including the OS icon
  state; the app switcher shows a blank card for discreet users.
- **StreakEngine 1.2.0 / WidgetToolkit 1.1.0 untouched this session.**
  TestFlight LIVE. 260-golden-class snapshot suite (31 widget/overlay + flows).
- Copy status: the §3 founder queue now ALSO carries the 8 DRAFT
  discreet-settings strings, the two DRAFT generated alternate ICONS
  (regenerable via brandkit/branding-assets/generate-alt-icons.py), and the
  R22.10 store-marketing decision (never screenshot the alternates vs §9.2
  frame 3 — mutually exclusive, operator resolves).

## Next session objective (one session, definition of done below)

**Session 23 — E7.1: PaywallKit + RevenueCat products [PKG:PaywallKit]**
(implementation-plan E7.1 row; deps E0.2 ✓; app wiring needs E5.3 ✓).

0. **STEP-0 candidates (resolve BEFORE red):**
   (a) **The Linux-lane boundary** — PaywallKit runs on the FREE package lane,
   but the RevenueCat SDK is Darwin-only: the package must own a pure-
   Foundation entitlement state machine (`trial|active|lapsed|never`) over its
   OWN protocol surface (mocked CustomerInfo shapes), with the RevenueCat
   adapter living APP-side (the WidgetToolkit Foundation-only precedent, R20-3;
   ADR-4 removability). Rule the exact protocol seam.
   (b) **SDK pinning** — RevenueCat exact-version pin (the SnapshotTesting/
   TelemetryDeck precedent); Architect rules whether the dep enters
   project.yml this session at all or waits for the app-wiring session.
   (c) **`trial_started` fire-point** (mvp §5 row exists) + the E7 events'
   privacy review (entitlement state is not §10 pre-unlock data, but the
   paywall variant assignment rides AppSettings.onboardingVariant).
   (d) **Pricing is CONFIG, not code** (plan acceptance) — where the
   $6.99/mo + annual A/B $29.99-vs-$39.99 table lives so a price change never
   recompiles.
   (e) **Budget shape** — package-lane red is FREE (`swift test` locally);
   plan 1 billed run (the E6.1 precedent) unless app wiring lands too.
1. **Red first (plan-named):** `test_entitlementState_mapsRevenueCatCustomerInfo()`
   (all four states, mocked), `test_trialStart_firesTrialStartedEvent()`,
   `test_restore_recoversEntitlement_withoutAccount()`,
   `test_entitlementCheck_offline_usesCachedState()` — local `swift test` red.
2. **Green:** the state machine + cached-entitlement store + the protocol seam.
3. Scope guards: no Superwall (E7.2), no win-back (E7.3), no paywall UI unless
   the step-0 rules the session covers the app half too.
4. Budget: **1 billed run + 1 contingency** (package-lane session; the macOS
   lane fires anyway on any Packages/** push — push red+green together per the
   S20 lever if the red is package-only).

## Operator-owned blockers (not agent work; carry until closed)

1. E0.3 device measurement (`docs/spike-panic-latency.md`) — still the only
   blocker on the permanent latency gate.
2. E3.3 + E6.2 + **NEW E6.3 device matrix rows** (operator-expected §7):
   discreet-toggle lock-screen check, alternate-icon switch (actool wiring is
   only device-verifiable), app-switcher blank card (incl. with the warm-panic
   sheet open), erase-reverts-icon.
3. Content tone review (§3) — now also the settings strings + the ICON veto +
   the R22.10 store-marketing decision.
4. GitHub Actions billing headroom (§4 — Session 22 used exactly 2).
5. TestFlight testers (§5) — carried.
6. TelemetryDeck app ID (§8 — THE LAST GATE on real funnel data). **NEW
   heads-up: E7.x will eventually need the operator's RevenueCat account +
   App Store Connect products (SaaS credentials are operator-held); E7.1's
   package half needs NEITHER.**

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name
> **Ballast**, org `com.beyondkaira`). E6.3 is CLOSED (green `29184196211`;
> 2 billed runs, zero burned — discreet variants on all five families, DRAFT
> alternate icons, the app-switcher shield window, discreet_mode_enabled
> live). **Session 23 = E7.1: PaywallKit + the entitlement state machine
> [PKG:PaywallKit].** Local Swift toolchain: `. ~/.local/share/swiftly/env.sh`.
> **Standing gates:** CodeGraph query-first + sync at close; `swiftc -parse`
> every touched file + import/annotation coverage on every new test file + the
> deprecation gate (docs metadata, and treat docs-UNCONFIRMED operator
> spellings as nonexistent — the S22 UIWindow.Level lesson); UIApplication/
> UIKit app-only APIs never enter Shared/Sources (extension-fatal); access-
> level scan + Linux harness RUN empirically under multiple host timezones
> (TZ=UTC minimum); JSON pins use key-SET semantics never byte-equality;
> docs-check every SDK spelling; docs-only commits `[skip ci]`; check the
> STAGED set before every commit; critics REPRODUCE risky constructs under
> `-strict-concurrency=complete -warnings-as-errors`; NEVER `git stash`;
> scanned string tables = STRUCTS with STORED properties; a schema/shared-pass
> change sweeps FUNCTION-level pin blast radius; `git fetch` + `git log
> origin/main` before every push; package-lane red evidence = free local
> `swift test` (push red+green together when the red is package-only — the
> S20 lever); PaywallKit is Foundation-only on the free Linux lane, the
> RevenueCat adapter is APP-side (ADR-4 removability; the WidgetToolkit
> precedent).
> READ FIRST: `docs/implementation-plan.md` E7.1 row + Epic 7 DoD, the
> Session 22 ledger in `docs/past-prompts.md` (R22.1–R22.10 — the shield/
> sheet-coverage lesson, the presence-only Optional pattern, the unanimous
> widget_added deferral), `docs/architecture.md` ADR-4 + §5.1 (PaywallKit
> protocol) + §10, `docs/mvp.md` §2 feature 11 + §5 (trial_started,
> purchase rows) + §6 pricing, `docs/prd.md` §7 (pricing/paywall),
> `Packages/PaywallKit/` (the stub), `Packages/WidgetToolkit/` (the
> Foundation-only precedent), `docs/session-rules.md`.
> **This session:** STEP-0 rulings (a)–(e) (the Linux-lane protocol seam is
> the load-bearing one) → red (the four plan-named tests, local swift test)
> → green (state machine + cache) → verify → flag operator items. Budget:
> 1 billed run + 1 contingency.
> **At session end:** append the Session 23 ledger, overwrite this resume
> prompt (next per `roadmap.md` — likely E7.2 Superwall adapter or E9
> dashboard), update `docs/operator-expected.md`, `codegraph sync`, commit
> `[skip ci]`, push, `gh run watch` green.

## Standing rules reminders (do not relearn these)

- **ADR-11 binding:** displayed "Day N" = 1-based CALENDAR day at local
  midnight in the quit's FIXED start timezone — never `TimeZone.current`,
  never `StreakValue.days`. Count by NOON anchoring. The feed zone travels as
  a STRING identifier.
- Analytics ONLY via the closed enum; zero events before opt-in; the widget
  extension can NEVER fire analytics — the R8 breadcrumb (E8, unanimously
  deferred, field set pre-approved: {kind, firstRenderAt} — `discreet` was
  privacy-struck from the file) is the sanctioned path when built.
- The consent choice is a DEVICE SETTING; erase resets it OFF. **Erase also
  best-effort-resets the OS alternate icon AFTER the data erase, and the
  launch reconciliation heals a lost reset — RESET-ONLY, never re-apply.**
- No shame copy (the lexicons only GROW; the discreet-RENDER lexicon
  additionally bans panic/milestone/streak/urge/quit/habit + category
  synonyms, scoped to discreet-render strings — the gallery's "Streak" is
  legitimate); no medical claims; no red anywhere; motivations VERBATIM.
  **Widgets: animation BANNED** — only system timerInterval ticking
  (`countsDown: false` on BOTH initializers).
- Monotonic fields never decrease; streaks freeze, never inflate (ADR-7); the
  widget floors at Day 1 and runs NO clock guard (ADR-6).
- WITNESS discipline: three advance paths only; widgets never advance it.
- Erase discipline: local-first; owned file-set = {panic-snapshot.json, panic
  outcome buffer, widget-state.json} in THREE enumeration sites; zero active
  quits ⇒ widget-state REMOVED (never present-empty); post-erase relaunch =
  fresh install (including the app icon).
- Panic path stays thin: panic surfaces NEVER open the store; the widget feed
  is label-free BY FIELD SET (R1) + presence-only discreet (R22.1); the
  selector's labels come from the panic pre-cache. **The shield policy is
  tri-state FAIL-CLOSED (indeterminate ⇒ covered); the shield is a WINDOW
  above .alert because SwiftUI content overlays do not cover sheets.**
- Never weaken a QA assertion (born-green minimization guards like A1/A2 stay
  byte-untouched; new behavior gets NEW pins — the S22 A6 shape); TDD red
  first; `cloudKitDatabase` stays `.none` until the §4.3 flip.
- Snapshot goldens: light/dark ×5 families ×normal/discreet + AX5 home-only;
  fixtures dated 2025; `pauseDate` freezes Text tickers;
  ProgressView(timerInterval:) has NO pauseTime. SnapshotTesting 1.19.3 +
  TelemetryDeck 2.14.1 pinned (+ RevenueCat exact-pin when E7 lands it).
