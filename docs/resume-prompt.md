# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v3.7 |
| Last updated | 2026-07-12 (Session 24 close: E7.1 APP HALF COMPLETE — RevenueCat wiring DORMANT behind the operator key + the bundled default paywall at the summary CTA seam; red evidence = CI run `29197338715` (28 designed-failing / 47 issues, manifest-matched NAME-FOR-NAME, the 10th consecutive harness-predicted red) → green `88b32a6`+`966f067`, CI `29198309877`; **4 billed runs: the planned 2 + the contingency + ONE over — TWO burned** (`29196899754`: a spurious `await` in a NEW test file; `29197958414`: the PaywallKit module-vs-type shadowing in the Darwin-only adapter — BOTH classes Linux-reproduced post-hoc and now permanently gated, standing rule #3 below) |
| Phase | Phase 2 — E2–E6 (minus operator device QA) + E7.1 COMPLETE (both halves; sandbox matrix = operator tier) + E8 CLOSED; delivery 26/32 (81%) |
| Next session objective | **Session 25: E7.2 — Superwall variant adapter (teaser-vs-hard A/B), carrying S24's named deferrals** |

> **What changed in Session 24:** the app now has a complete, DORMANT
> monetization vertical. purchases-ios **5.80.3 exact** is linked (app target
> + UnhookedTests ONLY — never the widget extension; the new free-lane
> `monetization-importer-lint` pins the SINGLE RC-importing file). With the
> operator key EMPTY (shipping state), `Purchases.configure` is never called
> — zero SDK init, zero network, no `EntitlementModel` exists, and the
> summary CTA falls through to the dashboard exactly as before: **the M1
> loop is byte-identical on TestFlight until the operator acts.** When the
> key lands: configure-once (post-frame, normal route only, device-ID
> collection OFF) → `RevenueCatEntitlementSource` → PaywallKit's caching
> provider → the summary CTA mounts the bundled default paywall for
> non-entitled users (never/lapsed; entitled users pass straight through).
> The screen renders the CONTROL arm ($29.99 + $6.99/mo, 3-day annual trial)
> from `ProductCatalog` constants through `paywallCopy.json`'s `%@` templates
> — every guideline-3.1.1/3.1.2(c) disclosure string-presence-pinned AND
> rendered; hard-ish wall (NO close — the sanctioned escape is E7.2's
> teaser); never-trap failure surface (retry + restore always reachable).
> trial_started fires through the ONE consent gate with cross-launch dedup
> (marker set only on a consented send; erase sweeps it). Erase gained step 5:
> `resetEntitlement` before the CloudKit purge (honest form:
> `invalidateCustomerInfoCache()` — v5 has NO anonymous-ID reset, docs-verified;
> entitlements are Apple-account-level and survive erase BY DESIGN).
> Full ledger: Session 24 in `docs/past-prompts.md` (rulings R24.1–R24.12).

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
3. **NEW (S24) — the TWO burned-run gates (both Linux-reproducible; both now
   permanent):** (a) **the spurious-await gate** — every `await` in a NEW
   file must mark a genuinely async/cross-actor operation; a non-Sendable
   closure literal INHERITS its enclosing actor isolation, so a same-actor
   call inside it is SYNCHRONOUS and its `await` is a warning ⇒ an app-lane
   build error (`swiftc -parse` is syntax-only and CANNOT catch it). For
   files the Linux harness cannot compile (SwiftData/SwiftUI/@testable),
   MOCKUP-TYPECHECK every new closure-into-seam shape under
   `-strict-concurrency=complete -warnings-as-errors` (the ShapeChecks
   pattern). (b) **the qualified-name gate** — a Darwin-only file's NON-SDK
   qualified type references get Linux-PROBED before push: the PaywallKit
   module exports an enum ALSO named `PaywallKit` (the version marker), so
   `PaywallKit.<Type>` resolves to the ENUM and fails; both-SDK files use
   the `EntitlementPeriodType`-style alias declared where the bare name is
   exact, NEVER the module-qualified form.
4. **Access-level gate + empirical harness:** scan for private types in
   non-private signatures, and RUN (never just typecheck) a Linux scratch
   harness over the exact shipping bytes of every pure-Foundation/PaywallKit
   API — probe the BOUNDARY, under MULTIPLE HOST TIMEZONES (TZ=UTC minimum).
   JSON pins use JSONSerialization key-SET semantics, never byte/string
   equality. The free package lane runs `swift test` WITHOUT
   warnings-as-errors — close the gap pre-push with `swift build
   --build-tests -Xswiftc -strict-concurrency=complete -Xswiftc
   -warnings-as-errors --package-path Packages/<pkg>` (or the scratch
   harness for app-side pure subsets).
5. **Docs-check gate:** every Darwin-only / AppIntents / WidgetKit / SF-Symbol /
   third-party member spelling verified against official docs BEFORE code
   (`developer.apple.com/tutorials/data/documentation/<path>.json`; SDK repos'
   tagged raw source for third-party). Recorded: RC `PeriodType` =
   normal|intro|trial|prepaid, `.trial` is the ONLY trial gate;
   `CustomerInfo`/`EntitlementInfo`/`EntitlementInfos` HAVE public
   "unit testing" inits (5.80.3); `logOut()` THROWS for anonymous users —
   there is NO anonymous-ID reset in v5; `cachedCustomerInfo` is the nil-safe
   cache peek (`customerInfo(fetchPolicy: .fromCacheOnly)` THROWS on empty);
   `configure` alone fires network + persists `$RCAnonymousID`.
6. Docs-only commits carry `[skip ci]`; never spawn agent workflows for
   docs-only changes. Critic/reader agents Write findings to scratchpad files
   and return a one-line pointer. **NEVER `git stash` mid-session.** Check the
   STAGED set before every commit (mid-session pathspec commits keep the
   dirty-tree rule in view).
7. `git fetch` + `git log origin/main` before EVERY push — the operator
   commits mid-session.
8. **Privacy-surface gate:** anything touching stores/`AnalyticsEvent`/outbound
   gets Architect pre-approval BEFORE implementation; adding an enum case is
   Architect-gated AND needs the MVP §5 row first (mvp.md is OPERATOR-ONLY).
   **Safety-content** needs the PM+Brand+QA joint copy-table sign-off before
   code. `widget-state.json` remains a §10 surface; no entitlement bit enters
   any pre-unlock file (presence-only Bool ceiling, S23; the S24 sweep held
   it). Scanned string tables must be STRUCTS with STORED properties. Grep
   LINT REGEXES MUST ANCHOR `^import` (S24: an unanchored import-grep matched
   a comment).
9. **BUDGET REALITY:** there is no zero-billed-run code session; free lanes
   exist, free runs do not. App-lane red evidence = the CI run on the red
   commit; package-lane red is the free local `swift test` (push red+green
   together — cancel-in-progress is FALSE on main, so two pushes = two full
   billed runs). A schema/shared-pass change sweeps the FUNCTION-level blast
   radius of every pin on it. NEW SPM deps land in the GREEN commit, never
   red (R24.8 — red evidence must be un-burnable by dep resolution; reproduce
   the FULL pin-graph `swift package resolve` locally first).

## Where we are

- **The M1 loop + the discreet-capable widget suite + a COMPLETE DORMANT
  monetization vertical:** age gate → quiz (slot-3 consent) → summary →
  dashboard placeholder → panic → slip → undo; five widget families
  (normal + discreet), per-widget quit binding, one-tap erase incl. OS icon
  state + the entitlement reset step, the app-switcher shield. PaywallKit
  1.0.0 (untouched this session) is now CONSUMED: adapter, EntitlementModel,
  PaywallRouting, the bundled PaywallView at the CTA seam, the trial_started
  wire — all live code, all dormant until the operator's RC key.
- **StreakEngine 1.2.0 / WidgetToolkit 1.1.0 / PaywallKit 1.0.0 untouched.**
  purchases-ios 5.80.3 exact-pinned. TestFlight LIVE (the newest build
  behaves identically to S23's — dormancy verified by construction + pins).
- Copy status: the §3 founder queue GAINS paywallCopy.json (20 DRAFT strings
  + the POSITIONING register decision + operator/legal riders: Terms/Privacy
  URLs, auto-renew boilerplate wording). Goldens still deferred to the
  post-founder-copy batch (S17 R5, extended to the paywall by R24.1).

## Next session objective (one session, definition of done below)

**Session 25 — E7.2: Superwall variant adapter (teaser-vs-hard A/B).** Per
plan: Superwall behind PaywallKit's interface (removable per ADR-4); variant
assignment logged; teaser mode = 1-day local timer then re-present. The four
plan-named tests verbatim (`test_paywallViewed_carriesVariantAndSource`,
`test_teaserMode_expiresAfter1Day_representsPaywall`,
`test_teaserExpiry_paywallSource_isTeaserExpiry`,
`test_superwallRemoved_paywallKitFallbackRendersHardVariant` — the
de-integration insurance test runs against S24's bundled paywall as its
substrate).

0. STEP-0 candidates: (a) the Superwall SDK pin (docs-verify the latest
   release at session open; Darwin-only? then the S23/S24 lane split applies)
   + the DORMANT posture (Superwall key is operator-owned — mirror the RC
   pattern); (b) `AppSettings.paywallVariantAssigned` (test-suite §4.4's
   local echo — a NEW AppSettings field: Architect §7 pre-approval + schema
   look needed); (c) the **paywall_viewed fire-point** (deferred here by
   R24.4: variant = the Superwall id per MVP §5; the bundled fallback's
   variant value needs a panel ruling that fits the row's vocabulary);
   (d) the **purchase analytics fire-point** (deferred by R24.4 — needs its
   own ruling: user-initiated purchase completion only; renewals are not
   honestly distinguishable client-side); (e) **scenario-29** (deferred here
   by R24.1: re-land WITH the S18-owed drive diagnostics + the pre-worded
   re-flake valve; its `…→ paywall_viewed` analytics tail lands with (c));
   (f) teaser expiry state: `AppSettings.teaserExpiresAt` EXISTS (unused
   forward field) — the teaser timer rules ride the panel.
1. Red first (app-lane, billed): per the panel's manifest.
2. Green: the adapter + variant wiring; 3.1.1 copy review on BOTH variants
   (Epic 7 DoD) — the S24 paywall copy table is the base.
3. Scope guards: no win-back (E7.3); PaywallKit sources untouched (the
   Superwall adapter is app-side per ADR-4 — confirm with the panel; if the
   panel rules it PaywallKit-side as the plan's §14 note suggests, that is a
   package-version session with the pin-sweep blast radius); the panic route
   never queries entitlements; no §10 field-set change beyond (b)'s ruling.
4. Budget: **2 billed runs + 1 contingency** (the Superwall SPM dep lands
   GREEN per standing rule #9).

## Operator-owned blockers (not agent work; carry until closed)

1. E0.3 device measurement (`docs/spike-panic-latency.md`) — still the only
   blocker on the permanent latency gate.
2. E3.3 + E6.2 + E6.3 device matrix rows (operator-expected §7).
3. Content tone review (§3) — GROWS: paywallCopy.json (20 DRAFT strings), the
   paywall POSITIONING register decision (audit-safe vs MVP §6 canon), the
   Terms/Privacy URLs + auto-renew boilerplate (operator/legal), and the
   carried settings strings/icons/R22.10 items.
4. GitHub Actions billing headroom (§4 — Session 24 used 4: the planned 2 +
   the contingency + one over; two burned runs, both classes now gated).
5. TestFlight testers (§5) — carried.
6. TelemetryDeck app ID (§8) — carried; the last gate on real funnel data.
7. **NEW (§8): the RevenueCat key + dashboard** — paste the PUBLIC SDK key
   into `RevenueCatConfiguration.revenueCatAPIKey` to wake the vertical;
   the RC dashboard (entitlement "premium", products matching ProductCatalog's
   three SKUs, an offering with monthly + control annual) + App Store Connect
   products become BLOCKING only at sandbox-verification time (MVP §7 matrix).
   Also: re-validate the hand-authored `Ballast.storekit` by opening it in
   Xcode 26 once (recorded rider), and eyeball the paywall via the DEBUG
   `UITEST_PAYWALL=1` launch env from Xcode when convenient.

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name
> **Ballast**, org `com.beyondkaira`). E7.1 is COMPLETE both halves (red
> evidence `29197338715` manifest-matched 28/47 name-for-name — the 10th
> consecutive predicted red; green `966f067`; 4 billed runs: 2 planned + the
> contingency + one over — TWO burned, both classes now standing rule #3).
> **Session 25 = E7.2: Superwall variant adapter (teaser-vs-hard A/B),
> carrying the S24 deferrals BY NAME: paywall_viewed fire-point + variant
> assignment + AppSettings.paywallVariantAssigned echo (§7-gated new field),
> purchase fire-point ruling, scenario-29 re-land with the S18-owed drive
> diagnostics, 3.1.1 both-variant copy review.** Local Swift toolchain:
> `. ~/.local/share/swiftly/env.sh`.
> **Standing gates:** CodeGraph query-first + sync at close; `swiftc -parse`
> every touched file + neighbor import/annotation coverage + the deprecation
> gate (docs-UNCONFIRMED spellings are nonexistent — SDK members verify
> against TAGGED RAW SOURCE; keep the docs-verifier panel seat); the
> spurious-await gate (standing rule #3 — mockup-typecheck new closure
> shapes under strict flags; the harness ShapeChecks pattern);
> UIApplication/UIKit app-only APIs never enter Shared/Sources; access-level
> scan + Linux harness RUN empirically under multiple host timezones (TZ=UTC
> minimum); JSON pins use key-SET semantics; grep lints anchor `^import`;
> docs-only commits `[skip ci]`; check the STAGED set before every commit;
> critics REPRODUCE risky constructs under
> `-strict-concurrency=complete -warnings-as-errors`; NEVER `git stash`;
> scanned string tables = STRUCTS with STORED properties; a schema/shared-pass
> change sweeps FUNCTION-level pin blast radius; `git fetch` + `git log
> origin/main` before every push; app-lane red evidence = the CI run on the
> red commit (2 billed runs + 1 contingency; NEW SPM deps land GREEN, resolve
> the full pin graph locally first); the panic route NEVER queries
> entitlements; no entitlement bit enters any pre-unlock file without
> Architect §10 pre-approval (presence-only Bool ceiling).
> READ FIRST: `docs/implementation-plan.md` E7.2 row + Epic 7 DoD, the
> Session 24 ledger in `docs/past-prompts.md` (R24.1–R24.12 — the DORMANT
> gate shape, the paywall_viewed/purchase deferrals, the scenario-29 grounds,
> the hard-wall no-close ruling, the erase-reset honesty note),
> `docs/architecture.md` §5.2 + §8 + ADR-4, `docs/mvp.md` §5 (paywall_viewed
> + purchase + teaser_entered rows) + §6, `docs/test-suite.md` §4.4
> (Superwall contract) + §1.4 (scenario 29), `App/Sources/Monetization/`
> (the S24 vertical — the seams E7.2 fills), `docs/session-rules.md`,
> operator-expected §8 (the RC-key item + the TelemetryDeck precedent).
> **This session:** STEP-0 rulings (a)–(f) → red (app-lane manifest per
> panel) → green → verify → flag operator items. Budget: 2 billed runs + 1
> contingency.
> **At session end:** append the Session 25 ledger, overwrite this resume
> prompt (next per `roadmap.md` — E7.3 win-back), update
> `docs/operator-expected.md`, `codegraph sync`, commit `[skip ci]`, push,
> `gh run watch` green.

## Standing rules reminders (do not relearn these)

- **ADR-11 binding:** displayed "Day N" = 1-based CALENDAR day at local
  midnight in the quit's FIXED start timezone — never `TimeZone.current`,
  never `StreakValue.days`. Count by NOON anchoring. The feed zone travels as
  a STRING identifier.
- Analytics ONLY via the closed enum; zero events before opt-in; the widget
  extension can NEVER fire analytics. PaywallKit emits DOMAIN events on its
  own sink seam; only the app-side conformer touches AnalyticsService (behind
  the ONE consent gate) and owns cross-launch dedup — **the S24 rule: the
  dedupe marker is set ONLY on a consented actual send (app-STANDARD
  defaults, bare Bool, erase-swept in step 2 — the App Group sweep can NEVER
  reach it).** Wire values: `ballast.monthly`/`ballast.annual` (the committed
  fixture vocabulary; value-domain-pinned).
- **Entitlement canon (S23+S24):** the mapper has NO clock; `willRenew`
  pin-ignored; the package persists ZERO bytes; `Product` = {monthly, annual}
  TIER (both A/B arms `.annual`; price rides `paywall_viewed.price_test`).
  **App-side (S24):** present-but-inactive ⇒ `isActive:false` NEVER nil
  (contract-pinned on REAL SDK types); an unknown SKU still honors an active
  entitlement (defaults `.annual` — the §8 grace direction);
  `entitlements.all`, never `.active`, is the extraction read.
- **DORMANT canon (S24):** key absent ⇒ the SDK symbol is never referenced at
  runtime, `entitlementModel` stays nil, the CTA falls through. NEVER call
  `Purchases.configure` without the operator key (it fires network + persists
  an anonymous ID). Device-ID collection stays OFF. The paywall screen is
  reachable ONLY via the live gate or DEBUG `UITEST_PAYWALL=1`.
- The consent choice is a DEVICE SETTING; erase resets it OFF. Erase order:
  rows → infallible local clears (incl. the trial dedupe marker) → owned
  files → widget reload → `resetEntitlement()` (throws surface for retry) →
  CloudKit purge LAST.
- No shame copy (lexicons only GROW); no medical claims; no red anywhere;
  motivations VERBATIM; the paywall bans countdowns/fake discounts/"one-time
  offer" (brandkit §6.8) and its prices are NEVER copy-table literals (`%@`
  templates + ProductCatalog constants only).
- Monotonic fields never decrease; streaks freeze, never inflate (ADR-7); the
  widget floors at Day 1 and runs NO clock guard (ADR-6).
- WITNESS discipline: three advance paths only; widgets never advance it.
- Erase discipline: local-first; owned file-set = {panic-snapshot.json, panic
  outcome buffer, widget-state.json} in THREE enumeration sites; zero active
  quits ⇒ widget-state REMOVED (never present-empty); post-erase relaunch =
  fresh install (including the app icon; entitlements survive BY DESIGN —
  Apple-account-level, a wipe is not a cancellation).
- Panic path stays thin: panic surfaces NEVER open the store OR query
  entitlements (explicitly pinned since S24); the widget feed is label-free
  BY FIELD SET (R1) + presence-only discreet (R22.1); the shield policy is
  tri-state FAIL-CLOSED.
- Never weaken a QA assertion; TDD red first; `cloudKitDatabase` stays `.none`
  until the §4.3 flip.
- Snapshot goldens: light/dark ×5 families ×normal/discreet + AX5 home-only;
  fixtures dated 2025; `pauseDate` freezes Text tickers; the ONBOARDING +
  PAYWALL golden batch waits for the founder copy pass (S17 R5 + R24.1).
  SnapshotTesting 1.19.3 + TelemetryDeck 2.14.1 + purchases-ios 5.80.3
  pinned EXACT.
