# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v3.6 |
| Last updated | 2026-07-12 (Session 23 close: E7.1 PACKAGE HALF COMPLETE — the entitlement state machine, PaywallKit 1.0.0; red evidence = the FREE local package lane (11 designed-failing / 17 issues, manifest-matched issue-for-issue, the 9th consecutive harness-predicted red) → red `14b1593` + green `098d087` pushed TOGETHER → CI `29192612869` at HEAD; **exactly the 1 planned billed run, zero burned, contingency unused — the zero-burn streak continues**) |
| Phase | Phase 2 — E2–E6 (minus operator device QA) + E7.1 (package half) + E8 CLOSED; delivery 25/32 (78%) |
| Next session objective | **Session 24: E7.1 APP HALF — RevenueCat wiring (DORMANT) + the bundled default paywall at the summary CTA seam** |

> **What changed in Session 23:** PaywallKit stopped being a stub (1.0.0): a pure
> four-state entitlement machine (`never|trial|active|lapsed`) with ZERO imports
> and ZERO persisted bytes — the mapper trusts RevenueCat's `isActive` and
> carries NO clock (R23.2: the anti-Quittr grace canon beat local expiry math;
> a lapse only ever arrives as the source's next snapshot; `willRenew` is
> pin-ignored so a cancelled trial never lapses mid-trial). The "cached
> entitlement store" is the provider actor's in-memory `lastKnown` ONLY.
> `EntitlementEvent.trialStarted(product:)` is an edge-triggered DOMAIN event
> on the package's own sink seam — tier payload only, no Dates; the app maps it
> to the closed `AnalyticsEventKind.trialStarted` behind consent at wiring and
> owns cross-launch dedup. RevenueCat stays OUT of project.yml (Darwin-only,
> docs-grounded); exact pin RECORDED for the wiring session: purchases-ios
> 5.80.3. The 90% coverage floor is CI-live (98.21% actual). Erase's future
> hook exists by name: `EntitlementProviding.reset()` (local-first order).
> Full ledger: Session 23 in `docs/past-prompts.md` (rulings R23.1–R23.9).

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
   neighbor uses gets its docs DEPRECATION metadata checked — and (S22) an
   operator/initializer the docs JSON does NOT CONFIRM is treated as
   nonexistent even if tutorials use it. (S23 extension: third-party SDK
   members too — the docs-verifier panel role killed `allExpirationDates`
   folklore pre-code; keep that role for every SDK-facing session.)**
   Cross-import overlays are FILE-granular; **UIApplication and every UIKit
   app-only API live in App/Sources ONLY — Shared/Sources compiles into the
   widget extension where `UIApplication.shared` is a HARD compile error.**
3. **Access-level gate + empirical harness:** scan for private types in
   non-private signatures, and RUN (never just typecheck) a Linux scratch
   harness over the exact shipping bytes of every pure-Foundation API —
   probe the BOUNDARY, under MULTIPLE HOST TIMEZONES (TZ=UTC minimum).
   JSON pins use JSONSerialization key-SET semantics, never byte/string
   equality (JSONEncoder key order is hash-randomized per run). **NEW (S23):
   the free package lane runs `swift test` WITHOUT warnings-as-errors — close
   the gap pre-push with `swift build --build-tests -Xswiftc
   -strict-concurrency=complete -Xswiftc -warnings-as-errors --package-path
   Packages/<pkg>` (a warning that is clean on the free lane is a BUILD
   FAILURE on the 10x macOS lane).**
4. **Docs-check gate:** every Darwin-only / AppIntents / WidgetKit / SF-Symbol /
   third-party member spelling verified against official docs BEFORE code
   (`developer.apple.com/tutorials/data/documentation/<path>.json`; SDK repos'
   actual source for third-party). Recorded: both `timerInterval:` initializers
   default `countsDown` TRUE; the `widgetFamily` env key is GET-ONLY; RC
   `PeriodType` = normal|intro|trial|prepaid and `.trial` is the ONLY trial
   gate; `CustomerInfo.allExpirationDates` DOES NOT EXIST in v5.
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
   code. `widget-state.json` remains a §10 surface. Scanned string tables must
   be STRUCTS with STORED properties. A new-file overlay/cover claim must name
   the PRESENTATION LAYER it covers. **NEW (S23): a future entitlement boolean
   in PanicSnapshot/widget-state.json is a §10 additive field-set change —
   presence-only Bool at most, NEVER product/expiry/price (guard recorded so
   E7.x/E9 cannot slide it in silently).**
8. **BUDGET REALITY:** there is no zero-billed-run code session; free lanes
   exist, free runs do not. App-lane red evidence = the CI run on the red
   commit; package-lane red is the free local `swift test` (push red+green
   together — cancel-in-progress is FALSE on main, so two pushes = two full
   billed runs). A schema/shared-pass change sweeps the FUNCTION-level blast
   radius of every pin on it.

## Where we are

- **The M1 loop + the discreet-capable widget suite + the entitlement BRAIN:**
  age gate → quiz (slot-3 consent) → summary → dashboard placeholder → panic →
  slip → undo; five widget families (normal + discreet), per-widget quit
  binding, one-tap erase incl. OS icon state, the app-switcher shield.
  PaywallKit 1.0.0 owns `never|trial|active|lapsed` — but NOTHING consumes it
  yet: no RevenueCat in the app, no paywall screen, the summary CTA still
  routes straight to the dashboard (its closure is the NAMED seam).
- **StreakEngine 1.2.0 / WidgetToolkit 1.1.0 untouched. PaywallKit 1.0.0 NEW**
  (tag `paywallkit-v1.0.0` at the operator's convenience). TestFlight LIVE.
- Copy status: the §3 founder queue unchanged by S23 (no new strings — the
  package has no user-facing surface); the paywall screen's copy + the
  guideline-3.1.1 strings arrive with Session 24's safety-gated sign-off.

## Next session objective (one session, definition of done below)

**Session 24 — E7.1 APP HALF: RevenueCat wiring (DORMANT) + the bundled
default paywall at the summary CTA seam.** (The E6.1→E6.2 [PKG:] precedent:
the package half closed the plan row's machine; this session makes the app
consume it. E7.2 Superwall stays OUT — the bundled fallback paywall is the
ADR-4 default that must exist with or without Superwall.)

0. **STEP-0 candidates (resolve BEFORE red):**
   (a) **Scope ruling** — the panel rules the exact vertical: adapter + catalog
   + `.storekit` + EntitlementModel + erase wiring + trial_started wire are
   IN; is the paywall SCREEN itself in this session or its own (the copy
   sign-off + 3.1.1 strings + scenario-29 smoke ride whichever session
   renders it — the S18 valve owes that smoke to E7)?
   (b) **The DORMANT pattern** — RevenueCat configures ONLY behind the
   operator's RC key (the TelemetryDeck §8 precedent: key absent ⇒ the
   adapter is never constructed, `EntitlementSource` falls back to a
   never-source; zero network, zero SDK init on any build until the operator
   acts). Panic-path purity: the adapter/model init LAZILY post-frame on the
   NORMAL route only (recorded S23 privacy guard).
   (c) **project.yml** gains purchases-ios **5.80.3 EXACT** (re-confirm
   latest at session open; SnapshotTesting/TelemetryDeck precedent) — a new
   SPM dep on the macOS lane is a build-failure class: budget the risk.
   (d) **ProductCatalog + `App/Resources/Ballast.storekit`** (R23.6 homes):
   $6.99/mo + annual A/B $29.99/$39.99, 3-day trial on annual only; the
   bundled fallback paywall shows the CONTROL arm ($29.99, architecture §8).
   StoreKitTest display-price pins per test-suite §4.3.
   (e) **trial_started wire** — the app's `EntitlementEventSink` conformer
   maps to `AnalyticsEventKind.trialStarted` behind the ONE consent gate +
   owns cross-launch at-most-once (seed the diff from RC's cached state);
   `paywall_viewed(variant:price_test:source:)` fire-point rules ride the
   session that renders the screen.
   (f) **Erase wiring** — `EntitlementProviding.reset()` joins
   `eraseEverything()` (the E2.4 recorded seam; local-first order already
   package-pinned).
1. **Red first (app-lane, billed):** per the panel's manifest — at minimum
   the adapter mapping pins (RC CustomerInfo → EntitlementSnapshot, incl.
   present-but-inactive ⇒ isActive:false NEVER nil — the S23 doc-bound seam
   nuance becomes type-exercised here), the DORMANT gate (no key ⇒ zero SDK
   references), EntitlementModel state flow, erase-reset, and the consent-
   gated trial_started wire with cross-launch dedup.
2. **Green:** the wiring; paywall screen per ruling (a).
3. Scope guards: no Superwall (E7.2), no win-back (E7.3), no §10 field-set
   change (no entitlement bit in any pre-unlock file), panic route never
   queries entitlements.
4. Budget: **2 billed runs + 1 contingency** (app-lane session; the new SPM
   dep makes the FIRST macOS build the risk point — the panel's burn critic
   must enumerate the dep-resolution failure classes pre-push).

## Operator-owned blockers (not agent work; carry until closed)

1. E0.3 device measurement (`docs/spike-panic-latency.md`) — still the only
   blocker on the permanent latency gate.
2. E3.3 + E6.2 + E6.3 device matrix rows (operator-expected §7).
3. Content tone review (§3) — carried (settings strings, icons veto, R22.10
   store-marketing decision; nothing new from S23).
4. GitHub Actions billing headroom (§4 — Session 23 used exactly 1).
5. TestFlight testers (§5) — carried.
6. TelemetryDeck app ID (§8 — the last gate on real funnel data).
7. **HEADS-UP (not yet blocking): Session 24 builds the RevenueCat wiring
   DORMANT behind your RC public SDK key (a new §-item will land at its
   close). Your RevenueCat account + App Store Connect products/offerings
   become BLOCKING only at sandbox-verification time (the MVP §7 purchase
   matrix); the build half needs neither.**

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name
> **Ballast**, org `com.beyondkaira`). E7.1's PACKAGE half is CLOSED
> (CI `29192612869`; 1 billed run, zero burned — PaywallKit 1.0.0: the
> no-clock four-state machine, in-memory-only cache, edge-triggered
> trialStarted domain event, 90% floor CI-live). **Session 24 = E7.1 APP
> HALF: RevenueCat wiring (DORMANT, purchases-ios 5.80.3 exact) + the
> bundled default paywall at the summary CTA seam.** Local Swift toolchain:
> `. ~/.local/share/swiftly/env.sh`.
> **Standing gates:** CodeGraph query-first + sync at close; `swiftc -parse`
> every touched file + import/annotation coverage on every new test file +
> the deprecation gate (docs metadata; docs-UNCONFIRMED spellings are
> nonexistent — now including third-party SDK members: keep the S23
> docs-verifier panel role); UIApplication/UIKit app-only APIs never enter
> Shared/Sources; access-level scan + Linux harness RUN empirically under
> multiple host timezones (TZ=UTC minimum); the free package lane runs NO
> warnings-as-errors — close the gap pre-push with the strict `swift build
> --build-tests` gate; JSON pins use key-SET semantics; docs-only commits
> `[skip ci]`; check the STAGED set before every commit; critics REPRODUCE
> risky constructs under `-strict-concurrency=complete -warnings-as-errors`;
> NEVER `git stash`; scanned string tables = STRUCTS with STORED properties;
> a schema/shared-pass change sweeps FUNCTION-level pin blast radius;
> `git fetch` + `git log origin/main` before every push; app-lane red
> evidence = the CI run on the red commit (2 billed runs + 1 contingency);
> the panic route NEVER queries entitlements (pre-cache boolean only, a §10
> gate); no entitlement bit enters any pre-unlock file without Architect
> §10 pre-approval (presence-only Bool ceiling, recorded S23).
> READ FIRST: `docs/implementation-plan.md` E7.1 row + Epic 7 DoD, the
> Session 23 ledger in `docs/past-prompts.md` (R23.1–R23.9 — the no-clock
> grace arbitration, the in-memory-only cache ruling, the DTO seam nuance:
> present-but-inactive ⇒ isActive:false NEVER nil), `docs/architecture.md`
> §3 (entitlement is not a data model) + §5.2 + §8 (offline grace) + ADR-4,
> `docs/mvp.md` §2 feature 2 + §5 (trial_started/purchase/paywall_viewed) +
> §6 pricing + §7 monetization gates, `docs/test-suite.md` §4.3 (StoreKitTest
> tier — the `.storekit` display-price pins) + §3.1 (FakeEntitlementProvider),
> `Packages/PaywallKit/` (1.0.0 — the seams to fill), `docs/session-rules.md`,
> operator-expected §8 (the TelemetryDeck DORMANT precedent to mirror).
> **This session:** STEP-0 rulings (a)–(f) (scope: is the paywall SCREEN in?)
> → red (app-lane manifest per panel) → green → verify → flag operator items
> (the RC-key §-item lands at close). Budget: 2 billed runs + 1 contingency.
> **At session end:** append the Session 24 ledger, overwrite this resume
> prompt (next per `roadmap.md` — E7.2 Superwall variants, or the paywall
> screen session if ruling (a) split it), update `docs/operator-expected.md`,
> `codegraph sync`, commit `[skip ci]`, push, `gh run watch` green.

## Standing rules reminders (do not relearn these)

- **ADR-11 binding:** displayed "Day N" = 1-based CALENDAR day at local
  midnight in the quit's FIXED start timezone — never `TimeZone.current`,
  never `StreakValue.days`. Count by NOON anchoring. The feed zone travels as
  a STRING identifier.
- Analytics ONLY via the closed enum; zero events before opt-in; the widget
  extension can NEVER fire analytics — the R8 breadcrumb (E8) is the
  sanctioned path when built. **PaywallKit emits DOMAIN events on its own
  sink seam; only the app-side conformer may touch AnalyticsService (behind
  the ONE consent gate), and it owns cross-launch dedup (R23.4).**
- **Entitlement canon (S23):** the mapper has NO clock — offline NEVER flips
  a cached entitled state (architecture §8 anti-Quittr grace); `willRenew`
  is pin-ignored (never a mid-trial lapse); the package persists ZERO bytes
  (no Codable — structural); trial carries no expiry; `Product` is the
  {monthly, annual} TIER (both annual A/B arms = `.annual`; price rides
  `paywall_viewed.price_test` app-side only).
- The consent choice is a DEVICE SETTING; erase resets it OFF. Erase also
  best-effort-resets the OS alternate icon AFTER the data erase (reconciliation
  RESET-ONLY) — **and E7's erase wiring calls `EntitlementProviding.reset()`
  local-clear-FIRST, source step last, failure surfaces for retry.**
- No shame copy (lexicons only GROW); no medical claims; no red anywhere;
  motivations VERBATIM. Widgets: animation BANNED — only system timerInterval
  ticking (`countsDown: false` on BOTH initializers).
- Monotonic fields never decrease; streaks freeze, never inflate (ADR-7); the
  widget floors at Day 1 and runs NO clock guard (ADR-6).
- WITNESS discipline: three advance paths only; widgets never advance it.
- Erase discipline: local-first; owned file-set = {panic-snapshot.json, panic
  outcome buffer, widget-state.json} in THREE enumeration sites; zero active
  quits ⇒ widget-state REMOVED (never present-empty); post-erase relaunch =
  fresh install (including the app icon).
- Panic path stays thin: panic surfaces NEVER open the store OR query
  entitlements; the widget feed is label-free BY FIELD SET (R1) +
  presence-only discreet (R22.1); the shield policy is tri-state FAIL-CLOSED.
- Never weaken a QA assertion; TDD red first; `cloudKitDatabase` stays `.none`
  until the §4.3 flip.
- Snapshot goldens: light/dark ×5 families ×normal/discreet + AX5 home-only;
  fixtures dated 2025; `pauseDate` freezes Text tickers;
  ProgressView(timerInterval:) has NO pauseTime. SnapshotTesting 1.19.3 +
  TelemetryDeck 2.14.1 pinned (+ purchases-ios 5.80.3 EXACT when Session 24
  lands it).
