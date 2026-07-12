# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v3.9 |
| Last updated | 2026-07-12 (Session 26 close: E7.3 COMPLETE — Epic 7's build half CLOSED. Win-back = an app-side observed-lapse stamp (`AppSettings.lapseObservedAt`, §7-approved) + the pure 7-day-duration `WinbackPolicy` + the dismissible OFFER at the reentry gate (entitled > winback > teaser-expiry) + the eligible-only settings row + the winback_shown/paywall_viewed(winback)/winback_converted/purchase fire-set — ALL dormant (no keys ⇒ no lapse ever observed). The offer MECHANISM is an ASC promotional offer (pay-up-front 1yr $14.99 on the SAME ballast.annual SKU, id `winback_annual`) — Apple win-back offers were REJECTED on primary-source evidence (months-granular + paid-history-gated; can't express "7 days post trial-lapse") and RC Targeting has no lapse cohort. Red evidence = CI run `29209285506` (11 designed-failing / 13 issues, manifest-matched NAME-FOR-NAME — the 12th consecutive harness-predicted red; the pure 10/11 subset verified TZ-invariant ×3 zones on the free box first) → green `2ba3a35` (all 11 flips, run `29209801255`, ALL-9-JOBS + TestFlight). **Exactly 2 billed runs, ZERO burned, contingency UNUSED.** The RC importer-lint anchor gained the attr-prefix form (the #3d latent gap, reproduced + planted-violation-tested). Session-open operator check: NOTHING was required; the operator's lock-screen day-counter report was TRIAGED as the pre-E6.2 skeleton's hardcoded "Day 0" + the S21 widget-kind retirement — operator re-adds the "Streak" widget on the newest build (§7 row; no code change, zero runs spent). |
| Phase | Phase 2 — E2–E6 (minus operator device QA) + E7.1/E7.2/E7.3 build-COMPLETE + E8 CLOSED; delivery 28/32 (87.5%) |
| Next session objective | **Session 27: E9.1 resources/helplines/alcohol-notice (+E9.2 content-table audit, batchable) — the safety layer** |

> **What changed in Session 26:** the monetization vertical's BUILD HALF IS
> DONE. A lapsed user (once the operator's keys are live) meets a 50%-off
> annual OFFER — at re-entry (once per process, dismissible via "Not now" —
> an offer never traps; the hard wall and teaser re-present stay close-free)
> and via an eligible-only settings row. Everything stays dormant-by-
> construction. Epic 7's remaining DoD is OPERATOR-TIER: the sandbox
> purchase matrix (now incl. the win-back time-travel row) + the 3.1.1
> checklist signature. Full ledger: Session 26 in `docs/past-prompts.md`
> (rulings R26.1–R26.15).

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
3. **The burn gates (S24/S25 — all Linux-reproducible, all permanent):**
   (a) **spurious-await** — every `await` in a NEW file must mark a genuinely
   async/cross-actor operation; mockup-typecheck new closure-into-seam shapes
   under `-strict-concurrency=complete -warnings-as-errors` (the ShapeChecks
   pattern). (b) **qualified-name** — a Darwin-only file's NON-SDK qualified
   type references get Linux-PROBED before push; the PaywallKit module
   exports an enum ALSO named `PaywallKit` so `PaywallKit.<Type>` resolves to
   the ENUM; both-SDK files use the bare-name-exact typealias, NEVER the
   module-qualified form. (c) **non-Sendable SDK results:** a nonisolated
   async SDK call whose result type is not Sendable CANNOT return into a
   @MainActor conformance under strict flags — probe every new SDK-facing
   conformance with a stub-module mockup (sanctioned fix: `@preconcurrency
   import`, scoped to the sole-importer file). Recorded S26:
   `WinBackOffer`/`PromotionalOffer`/`PurchaseParams` are Sendable at 5.80.3.
   (d) **lint anchors admit attributes:** import-anchored grep lints use
   `^(@[A-Za-z_]+ )*import …` — BOTH the RC and SW anchors now carry it (S26
   closed the RC gap).
4. **Access-level gate + empirical harness:** scan for private types in
   non-private signatures, and RUN (never just typecheck) a Linux scratch
   harness over the exact shipping bytes of every pure-Foundation/PaywallKit
   API — probe the BOUNDARY, under MULTIPLE HOST TIMEZONES (TZ=UTC minimum;
   the standing set: UTC/Berlin/Kiritimati). JSON pins use JSONSerialization
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
   THROWS for anonymous users; `cachedCustomerInfo` is the nil-safe peek; RC
   `configure` alone fires network + persists `$RCAnonymousID`. Superwall
   (4.16.1): `configure` fetches config + mints identity + can post
   attribution — NEVER keyless; `reset()` asserts unconfigured AND tracks a
   network event; variant id = `PaywallInfo.experiment?.variant.id` ONLY;
   `Assignment` is non-Sendable. NEW (S26): promotional offers =
   `promotionalOffer(forProductDiscount:product:)` (the `get…` spelling is
   DEPRECATED) + `purchase(package:promotionalOffer:)`, RC-signed via the
   uploaded In-App Purchase Key, iOS 13+; `eligibleWinBackOffers` is iOS 18+
   AND ASC-months-gated — REJECTED for the 7-day cohort (R26.2).
6. Docs-only commits carry `[skip ci]`; never spawn agent workflows for
   docs-only changes. Critic/reader agents Write findings to scratchpad files
   and return a one-line pointer. **NEVER `git stash` mid-session.** Check the
   STAGED set before every commit.
7. `git fetch` + `git log origin/main` before EVERY push — the operator
   commits mid-session.
8. **Privacy-surface gate:** anything touching stores/`AnalyticsEvent`/outbound
   gets Architect pre-approval BEFORE implementation; adding an enum case is
   Architect-gated AND needs the MVP §5 row first (mvp.md is OPERATOR-ONLY;
   deviations ride the R24.9 flagged shape — pending ratifications: S25's
   teaser_expiry source + {teaser,hard} labels; S26's mvp §6 in-app-only
   win-back). **Safety-content needs the PM+Brand+QA joint copy-table
   sign-off BEFORE code** (E9.1 IS safety content — this gate is Session 27's
   step-0 core). `widget-state.json` remains a §10 surface; no entitlement /
   teaser / winback bit enters any pre-unlock file (presence-only Bool
   ceiling). Scanned string tables must be STRUCTS with STORED NON-OPTIONAL
   properties (a nil String? child dodges the Mirror lexicon walk).
9. **BUDGET REALITY:** there is no zero-billed-run code session; free lanes
   exist, free runs do not. App-lane red evidence = the CI run on the red
   commit; package-lane red is the free local `swift test` (push red+green
   together — cancel-in-progress is FALSE on main, so two pushes = two full
   billed runs). A schema/shared-pass change sweeps the FUNCTION-level blast
   radius of every pin on it. NEW SPM deps land in the GREEN commit, never
   red (R24.8) — none expected for E9.1/E9.2.

## Where we are

- **The M1 loop + the discreet-capable widget suite + a build-COMPLETE
  DORMANT monetization vertical:** age gate → quiz (slot-3 consent) →
  summary → dashboard placeholder → panic → slip → undo; five widget
  families (normal + discreet), per-widget quit binding, one-tap erase incl.
  OS icon state + the entitlement reset step, the app-switcher shield.
  E7.1's bundled paywall + E7.2's variant brain + E7.3's win-back
  (eligibility + surfaces + fires) are all live code, all dormant until the
  operator's TWO keys (RC first, then Superwall; the win-back additionally
  needs the ASC promotional offer + the In-App Purchase Key upload — §8).
- **StreakEngine 1.2.0 / WidgetToolkit 1.1.0 / PaywallKit 1.0.0 untouched.**
  purchases-ios 5.80.3 + SuperwallKit 4.16.1 + SnapshotTesting 1.19.3 +
  TelemetryDeck 2.14.1 all exact-pinned. TestFlight LIVE.
- Copy status: the §3 founder queue GAINS the 5 winback DRAFT strings + the
  mvp §6 delivery-surface ratification + the 3.1.1 winback disclosure rider,
  atop the carried teaser/paywall/settings items. Goldens still deferred to
  the post-founder-copy batch.
- An under-17 VERIFIED-helplines resources screen ALREADY EXISTS (E5.1: US
  988; TR 112 until the operator's ALO-182 check) — E9.1 must rule
  reuse-vs-new at step-0.

## Next session objective (one session, definition of done below)

**Session 27 — E9.1: resources screen + helplines + alcohol notice
(+E9.2 content-table audit, batchable).** Per plan: region-aware
`helplines.json`, one tap from Settings and every slip flow; fixed alcohol
withdrawal-danger notice shown once, calmly. Plan-named tests VERBATIM:
`test_resources_reachableFromSettingsAndSlipFlow_oneTap`,
`test_helplines_regionFallbackToGlobal`,
`test_alcoholNotice_shownOnceOnAlcoholQuitCreation`,
`test_resourcesViewed_firesWithSource`, `test_helplinesJSON_matchesSchema`;
E9.2 adds `test_milestonesJSON_matchesSchema` +
`test_milestoneCopy_containsNoMedicalClaimLexicon` (milestones.json ships
since S21 — parts may be born-green; the batch decision is step-0's).

0. STEP-0 candidates: (a) **the safety-content gate** (standing rule #8:
   PM+Brand+QA joint copy-table sign-off BEFORE code — helplines + the
   alcohol notice ARE safety content; the E4.2 slipCopy precedent); (b)
   reuse-vs-new: the E5.1 under-17 resources screen already renders verified
   helplines — does E9.1 extend that surface or mount a sibling? (c)
   `resources_viewed(source)` value-domain {settings, slip_flow} (mvp §5) —
   reconcile with the S16 ruling that the AGE-GATE resources surface fires
   ZERO analytics; (d) the alcohol notice's once-semantics (where does
   "shown once" persist — a §7 field? the AppSettings exact-set pin sweeps
   same-commit); (e) the settings mount: DiscreetSettingsView is "discreet
   toggles + icon picker, NOTHING more" BY RULING (R22.7) — a resources row
   needs that ruling amended or a different settings surface; (f)
   helplines.json schema + region-fallback semantics (bundled, ADR-9 — no
   hot updates).
1. Red first (app-lane, billed): per the panel's manifest.
2. Green: the surface + data + fires; scope guards: the panic route's
   thinness is untouched (the slip-flow entry is one tap FROM the slip flow,
   never inside panic); no §10 change expected.
3. Budget: **2 billed runs + 1 contingency.**
4. At close: the runway drops to ~2–4 sessions to submission-ready.

## Operator-owned blockers (not agent work; carry until closed)

1. E0.3 device measurement (`docs/spike-panic-latency.md`) — still the only
   blocker on the permanent latency gate. **Best done in the ONE consolidated
   physical sitting on TODAY's build (see §7's new day-counter row).**
2. E3.3 + E6.2 + E6.3 device matrix rows (operator-expected §7) + the NEW
   lock-screen day-counter verification row (re-add the "Streak" widget).
3. Content tone review (§3) — GROWS: the 5 winback DRAFT strings + the mvp
   §6 delivery-surface ratification + the 3.1.1 winback disclosure rider,
   plus the carried teaser strings (3), the S25 MVP §5 ratifications, the
   paywallCopy items (20 strings, REGISTER decision, legal riders), and
   settings strings/icons/R22.10.
4. GitHub Actions billing headroom (§4 — Session 26 used exactly 2; zero
   burned; contingency unused).
5. TestFlight testers (§5) — carried; extra-timely once E9.1 lands.
6. TelemetryDeck app ID (§8) — carried; the last gate on real funnel data.
7. **§8 keys + config:** the RevenueCat key (the vertical's wake switch) →
   the Superwall key + dashboard (placement `quiz_completed` + the NEW
   `winback` placement, two variant paywalls, the price experiment, the
   variant-id mapping) → **NEW (S26): the ASC promotional offer
   (pay-up-front / 1 yr / $14.99 on `com.beyondkaira.ballast.annual`, offer
   id `winback_annual`) + the In-App Purchase Key upload to the RC
   dashboard** (promo signing). All sequenced at sandbox-matrix time;
   nothing blocks builds.

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name
> **Ballast**, org `com.beyondkaira`). E7.3 is COMPLETE (red evidence
> `29209285506` — 11/13 manifest-matched name-for-name, the 12th consecutive
> predicted red; green `2ba3a35` CI `29209801255`; exactly 2 billed runs,
> zero burned). **Session 27 = E9.1 resources/helplines/alcohol notice
> (+E9.2 content audit, batchable) — the safety layer.** Local Swift
> toolchain: `. ~/.local/share/swiftly/env.sh`.
> **Standing gates:** CodeGraph query-first + sync at close; `swiftc -parse`
> every touched file + neighbor import/annotation coverage + the deprecation
> gate (docs-UNCONFIRMED spellings are nonexistent — SDK members verify
> against TAGGED RAW SOURCE; keep the docs-verifier panel seat); the FOUR
> burn gates (standing rule #3); UIApplication/UIKit app-only APIs never
> enter Shared/Sources; access-level scan + Linux harness RUN empirically
> under multiple host timezones (TZ=UTC minimum); JSON pins use key-SET
> semantics; docs-only commits `[skip ci]`; check the STAGED set before
> every commit; critics REPRODUCE risky constructs under
> `-strict-concurrency=complete -warnings-as-errors`; NEVER `git stash`;
> scanned string tables = STRUCTS with STORED NON-OPTIONAL properties; a
> schema/shared-pass change sweeps FUNCTION-level pin blast radius;
> `git fetch` + `git log origin/main` before every push; app-lane red
> evidence = the CI run on the red commit (2 billed runs + 1 contingency);
> the panic route NEVER queries entitlements/teaser/winback state; no
> entitlement/teaser/winback bit enters any pre-unlock file; **SAFETY
> CONTENT (helplines, alcohol notice) needs the PM+Brand+QA joint copy-table
> sign-off BEFORE code (standing rule #8) — it is this session's step-0
> core.**
> READ FIRST: `docs/implementation-plan.md` E9.1+E9.2 rows + Epic 9 DoD, the
> Session 26 ledger in `docs/past-prompts.md` (R26.1–R26.15), the Session 16
> ledger (the E5.1 under-17 resources screen — the reuse-vs-new question),
> `docs/mvp.md` feature 11 + §7 Safety, `docs/architecture.md` §5.1
> (HelplineDirectory) if present, `docs/test-suite.md` §1/§3 resources
> scenarios, `App/Sources/` (AgeGate resources surface, DiscreetSettingsView
> — R22.7's "NOTHING more" ruling needs amending for a resources row),
> `docs/session-rules.md`, operator-expected §3/§7/§8.
> **This session:** STEP-0 rulings (a)–(f) → red (app-lane manifest per
> panel) → green → verify → flag operator items. Budget: 2 billed runs + 1
> contingency.
> **At session end:** append the Session 27 ledger, overwrite this resume
> prompt (next per `roadmap.md`), update `docs/operator-expected.md`,
> `codegraph sync`, commit `[skip ci]`, push, `gh run watch` green.

## Standing rules reminders (do not relearn these)

- **ADR-11 binding:** displayed "Day N" = 1-based CALENDAR day at local
  midnight in the quit's FIXED start timezone — never `TimeZone.current`,
  never `StreakValue.days`. Count by NOON anchoring. The feed zone travels as
  a STRING identifier. **Durations are the exception-by-domain:** the teaser
  = 24h wall-clock (R25.7); the win-back window = 7×86_400s wall-clock,
  INCLUSIVE boundary (R26.3) — never calendar-anchored.
- Analytics ONLY via the closed enum; zero events before opt-in; the widget
  extension can NEVER fire analytics. Wire values: `ballast.monthly`/
  `ballast.annual`; `variant` ∈ {"teaser","hard"}; `source` gains
  "teaser_expiry" (S25, ratification pending); `offer` = {"winback_annual"}
  (R26.8, single-member). **purchase fires ONLY on user-initiated PAID
  (.active) completions — never trials, never restore, NO dedupe (R25.6);
  a winback conversion co-fires winback_converted BEFORE purchase (R26.7,
  no mutual exclusion).** winback_shown co-fires with
  paywall_viewed(source:.winback) once per presentation — the paywall
  funnel MUST be source-segmented (recorded).
- **Entitlement canon (S23+S24):** the mapper has NO clock; `willRenew`
  pin-ignored; the package persists ZERO bytes; `Product` = {monthly, annual}
  TIER. App-side: present-but-inactive ⇒ `isActive:false` NEVER nil; unknown
  SKU honors an active entitlement; `entitlements.all` is the extraction read.
- **DORMANT canon (S24–S26):** key absent ⇒ the SDK symbol is never
  referenced at runtime. NEVER call `Purchases.configure` OR
  `Superwall.configure` without the operator key. The Superwall assigner and
  the lapse-observation edge are constructed only inside the RC-key branch
  (the vertical wakes as a unit). The paywall screen is reachable ONLY via
  the live gate or DEBUG `UITEST_PAYWALL=1|teaser`. `Superwall.reset()` is
  NOT in the erase order (R25.2).
- **Teaser canon (S25):** single-use escape; entitled ALWAYS wins; the grant
  stamp is consent-independent; teaser state lives ONLY in AppSettings;
  re-entry = the post-gate root's dashboard branch, live-model builds only —
  E9's dashboard INHERITS `paywallReentry` (binding-on-future-surfaces).
- **Win-back canon (S26):** eligibility = ANY `.lapsed` + observed-lapse
  stamp ≥ 7d (vetoable); the stamp writer is nil→set ONLY, from the injected
  clock, at the live refresh-adoption edge; the presentation is a
  DISMISSIBLE OFFER (the "Not now" QuietButton — no event on dismiss), once
  per process at the reentry gate + the eligible-only settings row; the hard
  wall and teaser re-present stay close-free (R24.9); prices via
  ProductCatalog constants (`annualWinbackDisplayPrice` "$14.99"), the
  mechanics line carries discounted AND renewal price (two %@ slots).
- The consent choice is a DEVICE SETTING; erase resets it OFF. Erase order:
  rows (sweeps teaserExpiresAt + paywallVariantAssigned + lapseObservedAt) →
  infallible local clears (incl. the trial dedupe marker) → owned files →
  widget reload → `resetEntitlement()` → CloudKit purge LAST.
- No shame copy (lexicons only GROW); no medical claims; no red anywhere;
  motivations VERBATIM; the paywall bans countdowns/fake discounts/"one-time
  offer" (brandkit §6.8) — the winback discount is REAL and stated as fact;
  prices are NEVER copy-table literals; the hard variant has NO close.
- Monotonic fields never decrease; streaks freeze, never inflate (ADR-7); the
  widget floors at Day 1 and runs NO clock guard (ADR-6).
- WITNESS discipline: three advance paths only; widgets never advance it.
- Erase discipline: local-first; owned file-set = {panic-snapshot.json, panic
  outcome buffer, widget-state.json} in THREE enumeration sites; zero active
  quits ⇒ widget-state REMOVED (never present-empty); post-erase relaunch =
  fresh install (entitlements survive BY DESIGN; a fresh teaser day and a
  fresh winback clock are grantable post-erase — accepted fresh-install
  semantics).
- Panic path stays thin: panic surfaces NEVER open the store, query
  entitlements, teaser, OR winback state (the init-order spy pins
  entitlementModel == nil AND paywallAssigner == nil on the panic route);
  the widget feed is label-free BY FIELD SET (R1) + presence-only discreet
  (R22.1); the shield policy is tri-state FAIL-CLOSED.
- Never weaken a QA assertion; TDD red first; `cloudKitDatabase` stays `.none`
  until the §4.3 flip.
- Snapshot goldens: light/dark ×5 families ×normal/discreet + AX5 home-only;
  fixtures dated 2025; `pauseDate` freezes Text tickers; the ONBOARDING +
  PAYWALL golden batch (incl. teaser + winback variants) waits for the
  founder copy pass (S17 R5 + R24.1). SnapshotTesting 1.19.3 + TelemetryDeck
  2.14.1 + purchases-ios 5.80.3 + SuperwallKit 4.16.1 pinned EXACT.
