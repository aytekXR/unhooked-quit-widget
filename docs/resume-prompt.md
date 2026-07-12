# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v3.8 |
| Last updated | 2026-07-12 (Session 25 close: E7.2 COMPLETE — Superwall variant adapter DORMANT behind its own operator key + teaser-vs-hard wiring + the paywall_viewed/purchase/teaser_entered fire-points + scenario-29 re-landed; red evidence = CI run `29204803764` (16 designed-failing / 22 issues, manifest-matched NAME-FOR-NAME, the 11th consecutive harness-predicted red) → green `acd2783` (16/16 flips verified in CI `29205964725`) + the valve commit `e281621` (run `29206650207` ALL-9-JOBS green + TestFlight); **3 billed runs = the 2 planned + the contingency spent on scenario-29's pre-worded valve — ZERO burned.** The smoke's diagnostics RETIRED the S18 wheel hypothesis (wheel verified + continue tapped, still no gate→quiz hand-off; the seeded leg stalled too — deterministic-on-CI, 0-for-2 across sessions; deferred with the run's artifact evidence). Probe-3b caught a would-be burn pre-push (non-Sendable `[Assignment]` under strict concurrency — the S24 run-3 class, killed on the free box) and its fix exposed a NEW standing lint shape: import-anchored greps must admit attribute prefixes (`@preconcurrency import` had made the sole-importer gate silently vacuous). |
| Phase | Phase 2 — E2–E6 (minus operator device QA) + E7.1 + E7.2 COMPLETE + E8 CLOSED; delivery 27/32 (84%) |
| Next session objective | **Session 26: E7.3 — win-back offer (config), closing Epic 7's build half** |

> **What changed in Session 25:** the paywall now has a VARIANT BRAIN, fully
> dormant. `SuperwallKit 4.16.1 exact` is linked (app target ONLY — never the
> widget extension, not UnhookedTests; `monetization-importer-lint` pins the
> single SuperwallKit-importing file and bans RC/SW dual-import forever).
> With the Superwall key EMPTY (shipping state) the composition vends the
> bundled HARD-arm assigner and `Superwall.configure` is never called
> (configure alone fetches remote config, mints an anonymous identity, and
> can post install attribution — docs-verified against 4.16.1 source);
> keyless builds behave byte-identically. The assignment seam
> (`VariantAssigning`, `{teaser, hard}`), the pure `TeaserPolicy` (24h
> wall-clock duration), the re-entry rule (entitled-wins → unexpired grant →
> expired re-presents with `source=teaser_expiry`), the three fire-points
> (paywall_viewed at the presentation seam with the live-only
> `paywallVariantAssigned` echo; purchase = user-initiated PAID completions
> only, mutually exclusive with trial_started; teaser_entered on the
> single-use escape), the teaser copy (3 new DRAFT strings), are ALL live;
> scenario-29 re-landed, fired its pre-worded valve on its single run
> (deferred WITH evidence — the wheel hypothesis is retired; the hooks
> stay landed), and every DoD obligation stays unit-pinned. Full ledger: Session 25 in
> `docs/past-prompts.md` (rulings R25.1–R25.14).

---

## Standing tooling rules (permanent, apply to every agent)

1. **CodeGraph**: query `codegraph_explore` (shell: `codegraph explore "..."`)
   BEFORE grep/find or manual reading; pass this instruction into every
   subagent/workflow prompt; check blast radius before editing public symbols.
   **Before the session-end commit: `codegraph sync` + confirm status clean.**
2. **Parse gate**: `swiftc -parse` every touched Swift file before every push.
   PLUS the import-AND-ANNOTATION coverage check on every NEW test file: copy
   the closest proven neighbor's import block AND its type-declaration
   attributes. The deprecation gate (S21): any API form in a new file that NO
   neighbor uses gets its docs DEPRECATION metadata checked — and (S22) an
   operator/initializer the docs JSON does NOT CONFIRM is treated as
   nonexistent even if tutorials use it; (S23) third-party SDK members too —
   verify against the SDK's ACTUAL tagged source. Cross-import overlays are
   FILE-granular; UIApplication and every UIKit app-only API live in
   App/Sources ONLY.
3. **The burn gates (S24, extended S25 — all Linux-reproducible, all
   permanent):** (a) **spurious-await** — every `await` in a NEW file must
   mark a genuinely async/cross-actor operation; mockup-typecheck new
   closure-into-seam shapes under `-strict-concurrency=complete
   -warnings-as-errors` (the ShapeChecks pattern). (b) **qualified-name** —
   a Darwin-only file's NON-SDK qualified type references get Linux-PROBED
   before push; the PaywallKit module exports an enum ALSO named `PaywallKit`
   so `PaywallKit.<Type>` resolves to the ENUM; both-SDK files use the
   bare-name-exact typealias, NEVER the module-qualified form. (c) **NEW
   (S25) — non-Sendable SDK results:** a nonisolated async SDK call whose
   result type is not Sendable CANNOT return into a @MainActor conformance
   under strict flags — probe every new SDK-facing conformance with a
   stub-module mockup (probe-3b caught `[Assignment]` pre-push; sanctioned
   fix: `@preconcurrency import`, scoped to the sole-importer file).
   (d) **NEW (S25) — lint anchors admit attributes:** import-anchored grep
   lints use `^(@[A-Za-z_]+ )*import …` — a bare `^import` anchor goes
   VACUOUS on `@preconcurrency import` and silently stops gating.
4. **Access-level gate + empirical harness:** scan for private types in
   non-private signatures, and RUN (never just typecheck) a Linux scratch
   harness over the exact shipping bytes of every pure-Foundation/PaywallKit
   API — probe the BOUNDARY, under MULTIPLE HOST TIMEZONES (TZ=UTC minimum;
   the S24/S25 set: UTC/Berlin/Kiritimati). JSON pins use JSONSerialization
   key-SET semantics, never byte/string equality. The free package lane runs
   `swift test` WITHOUT warnings-as-errors — close the gap pre-push with
   `swift build --build-tests -Xswiftc -strict-concurrency=complete -Xswiftc
   -warnings-as-errors --package-path Packages/<pkg>` (or the scratch harness
   for app-side pure subsets).
5. **Docs-check gate:** every Darwin-only / AppIntents / WidgetKit / SF-Symbol /
   third-party member spelling verified against official docs BEFORE code
   (`developer.apple.com/tutorials/data/documentation/<path>.json`; SDK repos'
   tagged raw source for third-party). Recorded: RC `PeriodType` =
   normal|intro|trial|prepaid, `.trial` is the ONLY trial gate; `logOut()`
   THROWS for anonymous users (no v5 anonymous-ID reset); `cachedCustomerInfo`
   is the nil-safe peek; RC `configure` alone fires network + persists
   `$RCAnonymousID`. Superwall (4.16.1): `configure` fetches config + mints
   identity + can post attribution — NEVER keyless; `reset()` asserts
   unconfigured AND tracks a network event — NOT wired into erase (R25.2);
   the variant id = `PaywallInfo.experiment?.variant.id` ONLY;
   `eventTrackingBehavior` is the privacy knob
   (`automaticDeviceIdentifierCollection` DOES NOT EXIST); `register` uses
   `placement:`, the delegate hook is `handleSuperwallEvent` (the Placement
   spelling is deprecated; Graveyard `@objc` overloads are the trap);
   `Assignment` is non-Sendable (rule #3c).
6. Docs-only commits carry `[skip ci]`; never spawn agent workflows for
   docs-only changes. Critic/reader agents Write findings to scratchpad files
   and return a one-line pointer. **NEVER `git stash` mid-session.** Check the
   STAGED set before every commit (mid-session pathspec commits keep the
   dirty-tree rule in view).
7. `git fetch` + `git log origin/main` before EVERY push — the operator
   commits mid-session.
8. **Privacy-surface gate:** anything touching stores/`AnalyticsEvent`/outbound
   gets Architect pre-approval BEFORE implementation; adding an enum case is
   Architect-gated AND needs the MVP §5 row first (mvp.md is OPERATOR-ONLY;
   the S25 `teaser_expiry` add rode the R24.9 flagged-deviation shape —
   operator ratification pending). **Safety-content** needs the PM+Brand+QA
   joint copy-table sign-off before code. `widget-state.json` remains a §10
   surface; no entitlement OR TEASER bit enters any pre-unlock file
   (presence-only Bool ceiling, S23; teaser state lives ONLY in AppSettings,
   R25.7). Scanned string tables must be STRUCTS with STORED properties
   (non-optional — a nil String? child dodges the Mirror lexicon walk, S25).
9. **BUDGET REALITY:** there is no zero-billed-run code session; free lanes
   exist, free runs do not. App-lane red evidence = the CI run on the red
   commit; package-lane red is the free local `swift test` (push red+green
   together — cancel-in-progress is FALSE on main, so two pushes = two full
   billed runs). A schema/shared-pass change sweeps the FUNCTION-level blast
   radius of every pin on it. NEW SPM deps land in the GREEN commit, never
   red (R24.8; reproduce the FULL pin-graph `swift package resolve` locally
   first — the graph now carries superscript-ios-next's ~95MB binary
   `libcel.xcframework`, so a cold SPM cache makes the first post-dep run
   slower).

## Where we are

- **The M1 loop + the discreet-capable widget suite + a COMPLETE DORMANT
  monetization vertical WITH ITS VARIANT BRAIN:** age gate → quiz (slot-3
  consent) → summary → dashboard placeholder → panic → slip → undo; five
  widget families (normal + discreet), per-widget quit binding, one-tap
  erase incl. OS icon state + the entitlement reset step, the app-switcher
  shield. E7.1's bundled paywall + E7.2's assignment seam/teaser/fires are
  all live code, all dormant until the operator's TWO keys (RC first, then
  Superwall — the vertical wakes as a unit, R25.2).
- **StreakEngine 1.2.0 / WidgetToolkit 1.1.0 / PaywallKit 1.0.0 untouched.**
  purchases-ios 5.80.3 + SuperwallKit 4.16.1 + SnapshotTesting 1.19.3 +
  TelemetryDeck 2.14.1 all exact-pinned. TestFlight LIVE (dormancy verified
  by construction + pins; keyless behavior byte-identical).
- Copy status: the §3 founder queue GAINS the 3 teaser DRAFT strings (+ the
  remote-B-arm 3.1.1 checklist rider). Goldens still deferred to the
  post-founder-copy batch (S17 R5 → R24.1 → S25 unchanged;
  `UITEST_PAYWALL=1|teaser` is the operator's eyeball path).

## Next session objective (one session, definition of done below)

**Session 26 — E7.3: win-back offer (config).** Per plan: 50%-off annual
win-back offered 7 days post trial-lapse via RevenueCat offer, no push
dependency. The three plan-named tests verbatim
(`test_winback_eligibility_trialLapsedPlus7Days`,
`test_winback_notShownToActiveOrNeverTrialed`,
`test_winbackPurchase_firesPurchaseWinbackAnnual`).

0. STEP-0 candidates: (a) **the lapse-clock problem** — `EntitlementState.
   lapsed` carries NO date BY RULING (S23: the machine has no clock, no Date
   payloads) and eligibility needs "lapse + 7 days"; the panel must rule
   where lapse age comes from (RC's server-side offer targeting? an app-side
   observed-lapse stamp — a NEW AppSettings/§7 field? docs-verify RC
   offers/win-back mechanics against 5.80.3 + the dashboard docs FIRST);
   (b) **the delivery-surface conflict** — mvp §6 says "delivered via
   Superwall placement + local notification"; the plan's acceptance says
   "surfaced in-app (settings/paywall source), never via notification" —
   two canonical docs disagree (the C1 arbitration shape; mvp.md is
   operator-only); (c) `SuperwallPlacement` gains `winback` (arch §5.2's
   second placement) + `PaywallSource.winback` is already in the enum;
   (d) `winback_shown`/`winback_converted` fire-points (cases + wire names
   exist since E8.1; `offer` value-domain pin needed — the S15 rule);
   (e) the `purchase` fire on a win-back conversion — the plan test name
   says `firesPurchaseWinbackAnnual`: reconcile with R25.6's
   product-value-domain {ballast.monthly, ballast.annual} (does the offer
   ride the same SKU? almost certainly yes — a discounted price on
   ballast.annual — but the panel confirms against RC offer mechanics);
   (f) win-back is DORMANT-compatible by construction (no keys ⇒ no lapse
   ever observed) — pin it.
1. Red first (app-lane, billed): per the panel's manifest; Superwall/RC
   symbols stay OUT of red (standing rule #9 — no new dep this time, so the
   red is pure-seam only).
2. Green: eligibility + surfacing + fires; scope guards: the panic route
   never queries entitlements; no §10 change; PaywallKit untouched unless
   the panel rules a package-version session (unlikely — the S25 precedent
   keeps app-side).
3. Budget: **2 billed runs + 1 contingency.**
4. Epic 7 DoD check at close: what remains operator-tier (sandbox matrix,
   3.1.1 sign-off) vs build-tier — record honestly.

## Operator-owned blockers (not agent work; carry until closed)

1. E0.3 device measurement (`docs/spike-panic-latency.md`) — still the only
   blocker on the permanent latency gate.
2. E3.3 + E6.2 + E6.3 device matrix rows (operator-expected §7).
3. Content tone review (§3) — GROWS: the 3 teaser DRAFT strings + the
   remote-B-arm 3.1.1 checklist rider + the MVP §5 vocabulary ratifications
   (teaser_expiry source; {teaser,hard} variant labels), plus the carried
   paywallCopy items (20 strings, REGISTER decision, legal riders) and
   settings strings/icons/R22.10.
4. GitHub Actions billing headroom (§4 — Session 25 used 3: the 2 planned
   + the contingency on scenario-29's sanctioned valve; zero burned).
5. TestFlight testers (§5) — carried.
6. TelemetryDeck app ID (§8) — carried; the last gate on real funnel data.
7. **§8 keys:** the RevenueCat key (S24, the vertical's wake switch) and
   **NEW: the Superwall key** (`SuperwallConfiguration.superwallAPIKey`) +
   the Superwall dashboard config (the "quiz_completed" placement, the two
   variant paywalls, the $29.99-vs-$39.99 experiment on
   ballast.annual/.hi, and the variant-id → {teaser,hard} mapping table in
   `SuperwallPlacement.variantMapping`). Order matters: the Superwall key
   does nothing until the RC key lands (the vertical wakes as a unit).

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name
> **Ballast**, org `com.beyondkaira`). E7.2 is COMPLETE (red evidence
> `29204803764` — 16/22 manifest-matched name-for-name, the 11th consecutive
> predicted red; green `acd2783` CI `29205964725`; exactly 2 billed runs,
> zero burned). **Session 26 = E7.3: win-back offer (config) — the three
> plan-named tests verbatim, closing Epic 7's build half.** Local Swift
> toolchain: `. ~/.local/share/swiftly/env.sh`.
> **Standing gates:** CodeGraph query-first + sync at close; `swiftc -parse`
> every touched file + neighbor import/annotation coverage + the deprecation
> gate (docs-UNCONFIRMED spellings are nonexistent — SDK members verify
> against TAGGED RAW SOURCE; keep the docs-verifier panel seat); the FOUR
> burn gates (standing rule #3: spurious-await shape-pins; Darwin-only
> qualified-name Linux probes; non-Sendable SDK results into @MainActor
> conformances — stub-module probe, `@preconcurrency import` is the
> sanctioned fix; import-lint anchors admit attribute prefixes);
> UIApplication/UIKit app-only APIs never enter Shared/Sources; access-level
> scan + Linux harness RUN empirically under multiple host timezones (TZ=UTC
> minimum); JSON pins use key-SET semantics; docs-only commits `[skip ci]`;
> check the STAGED set before every commit; critics REPRODUCE risky
> constructs under `-strict-concurrency=complete -warnings-as-errors`; NEVER
> `git stash`; scanned string tables = STRUCTS with STORED NON-OPTIONAL
> properties; a schema/shared-pass change sweeps FUNCTION-level pin blast
> radius; `git fetch` + `git log origin/main` before every push; app-lane
> red evidence = the CI run on the red commit (2 billed runs + 1
> contingency; NEW SPM deps land GREEN — none expected this session); the
> panic route NEVER queries entitlements OR teaser state; no entitlement/
> teaser bit enters any pre-unlock file (presence-only Bool ceiling).
> READ FIRST: `docs/implementation-plan.md` E7.3 row + Epic 7 DoD, the
> Session 25 ledger in `docs/past-prompts.md` (R25.1–R25.14 — the dormant
> Superwall gate, the teaser semantics, the purchase mutual-exclusion, the
> scenario-29 valve + the DEFERRED event-spy design, the erase/reset
> deferral), `docs/architecture.md` §5.2 + §8 + ADR-4, `docs/mvp.md` §5
> (winback rows) + §6 (win-back para — NOTE the delivery-surface conflict
> with the plan's acceptance, step-0 item (b)), `docs/test-suite.md` §4.2
> (win-back sandbox contract), `App/Sources/Monetization/` (the S24+S25
> vertical), `docs/session-rules.md`, operator-expected §8.
> **This session:** STEP-0 rulings (a)–(f) → red (app-lane manifest per
> panel) → green → verify → flag operator items. Budget: 2 billed runs + 1
> contingency.
> **At session end:** append the Session 26 ledger, overwrite this resume
> prompt (next per `roadmap.md`), update `docs/operator-expected.md`,
> `codegraph sync`, commit `[skip ci]`, push, `gh run watch` green.

## Standing rules reminders (do not relearn these)

- **ADR-11 binding:** displayed "Day N" = 1-based CALENDAR day at local
  midnight in the quit's FIXED start timezone — never `TimeZone.current`,
  never `StreakValue.days`. Count by NOON anchoring. The feed zone travels as
  a STRING identifier. **The TEASER is the deliberate exception-by-domain:**
  a 24h wall-clock DURATION (now+86_400s), never calendar-anchored (R25.7).
- Analytics ONLY via the closed enum; zero events before opt-in; the widget
  extension can NEVER fire analytics. PaywallKit emits DOMAIN events on its
  own sink seam; only the app-side conformer touches AnalyticsService (behind
  the ONE consent gate). Wire values: `ballast.monthly`/`ballast.annual`;
  `variant` ∈ {"teaser","hard"}; `source` gains "teaser_expiry" (S25,
  operator ratification pending). trial_started dedupe marker: app-STANDARD
  defaults, consented-send-only, erase-swept. **purchase fires ONLY on
  user-initiated PAID (.active) completions from the purchase path — never
  on trial starts (mutual exclusion), never on restore, NO dedupe marker
  (R25.6).** paywall_viewed fires once per presentation at the presentation
  seam (both live + DEBUG mounts); the `paywallVariantAssigned` echo is
  written ONLY by a live Superwall assignment.
- **Entitlement canon (S23+S24):** the mapper has NO clock; `willRenew`
  pin-ignored; the package persists ZERO bytes; `Product` = {monthly, annual}
  TIER. App-side: present-but-inactive ⇒ `isActive:false` NEVER nil; unknown
  SKU honors an active entitlement; `entitlements.all` is the extraction read.
- **DORMANT canon (S24+S25):** key absent ⇒ the SDK symbol is never
  referenced at runtime. NEVER call `Purchases.configure` OR
  `Superwall.configure` without the operator key (both phone home + mint
  identity — docs-verified). The Superwall assigner is constructed only
  inside the RC-key branch (the vertical wakes as a unit). The paywall
  screen is reachable ONLY via the live gate or DEBUG
  `UITEST_PAYWALL=1|teaser`. `Superwall.reset()` is NOT in the erase order
  (asserts unconfigured + phones home — R25.2 named deferral).
- **Teaser canon (S25):** single-use escape (the re-present is close-free +
  eyebrow); entitled ALWAYS wins over teaser state; the grant stamp is
  consent-independent; teaser state lives ONLY in AppSettings (never
  pre-unlock); re-entry = the post-gate root's dashboard branch, live-model
  builds only — E9's dashboard INHERITS `reentryDestination`
  (binding-on-future-surfaces).
- The consent choice is a DEVICE SETTING; erase resets it OFF. Erase order:
  rows (sweeps teaserExpiresAt + paywallVariantAssigned) → infallible local
  clears (incl. the trial dedupe marker) → owned files → widget reload →
  `resetEntitlement()` → CloudKit purge LAST.
- No shame copy (lexicons only GROW); no medical claims; no red anywhere;
  motivations VERBATIM; the paywall bans countdowns/fake discounts/"one-time
  offer" (brandkit §6.8) — teaser expiry is SILENT, never a ticking surface;
  prices are NEVER copy-table literals (`%@` templates + ProductCatalog
  constants only); the hard variant has NO close (R24.9; the escape is the
  teaser arm's alone).
- Monotonic fields never decrease; streaks freeze, never inflate (ADR-7); the
  widget floors at Day 1 and runs NO clock guard (ADR-6).
- WITNESS discipline: three advance paths only; widgets never advance it.
- Erase discipline: local-first; owned file-set = {panic-snapshot.json, panic
  outcome buffer, widget-state.json} in THREE enumeration sites; zero active
  quits ⇒ widget-state REMOVED (never present-empty); post-erase relaunch =
  fresh install (entitlements survive BY DESIGN; a fresh teaser day is
  grantable post-erase — accepted fresh-install semantics).
- Panic path stays thin: panic surfaces NEVER open the store, query
  entitlements, OR read teaser state (the init-order spy pins
  entitlementModel == nil AND paywallAssigner == nil on the panic route);
  the widget feed is label-free BY FIELD SET (R1) + presence-only discreet
  (R22.1); the shield policy is tri-state FAIL-CLOSED.
- Never weaken a QA assertion; TDD red first; `cloudKitDatabase` stays `.none`
  until the §4.3 flip.
- Snapshot goldens: light/dark ×5 families ×normal/discreet + AX5 home-only;
  fixtures dated 2025; `pauseDate` freezes Text tickers; the ONBOARDING +
  PAYWALL golden batch (now incl. the teaser variant) waits for the founder
  copy pass (S17 R5 + R24.1). SnapshotTesting 1.19.3 + TelemetryDeck 2.14.1 +
  purchases-ios 5.80.3 + SuperwallKit 4.16.1 pinned EXACT.
