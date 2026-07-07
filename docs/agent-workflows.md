# Agent Workflows: Unhooked — Agent-Driven Development Process

| Field | Value |
|---|---|
| Document | Agent Workflows v1.0 |
| Date | 2026-07-07 |
| Inputs | PRD v1.0, MVP Definition v1.0, Architecture v1.0, Feasibility Report v1.0 |
| Scope | How specialized AI agents build the v1.0 MVP (and v1.1/v1.2 follow-ons) under a solo human operator |

> **Context that shapes everything below:** Unhooked is a **local-first iOS app with zero owned backend at launch**, whose product surface is mostly *outside* the app binary (lock-screen widgets, interactive AppIntents, Control Center, Action button, StandBy). Its category is emotionally sensitive (addiction recovery, adult content, alcohol), privacy-positioned, and App-Review-fragile. The process therefore over-weights three things most app processes under-weight: **(1) device-matrix widget QA** — widgets cannot be meaningfully tested in simulators alone; **(2) copy-tone and safety gates** — "zero shame language" and "no medical claims" are release-blocking acceptance criteria, not style preferences; **(3) privacy auditability** — the analytics payload audit and the mirrored-store privacy discipline (nothing forbidden reaches the CloudKit mirror or any network payload) are marketing claims that must be re-verified every session, because a single careless `track()` call falsifies the App Store positioning.

---

## Part 1: The Agents

Eight roles. One human operator (the solo founder) owns final judgment, all App Store Connect / financial / legal actions, and everything requiring a physical device in hand.

A note on repo layout assumed throughout: `prds/unhooked-quit-widget/` holds the product docs (this file, `prd.md`, `mvp.md`, `architecture.md`, `feasibility-report.md`); the app repo holds `docs/` (living specs, checklists, ADR addenda), `features/` (per-feature spec+test-plan bundles), `past-prompts.md`, and `resume-prompt.md` at the root.

---

### 1.1 Product Manager Agent (PM)

**Mission.** Convert the PRD/MVP into unambiguous, buildable, testable feature specs — and guard the funnel thesis: this MVP is a conversion-measurement instrument first, a product second.

**Responsibilities.**
- Decompose MVP §2 features into feature specs with numbered acceptance criteria, edge cases, analytics events fired, and copy requirements (including discreet-mode variants).
- Own the analytics event contract (MVP §5): every spec names exactly which events fire with which properties, and explicitly lists what must NOT be in the payload.
- Own copy tone: write or approve all user-facing strings against the no-shame checklist (no "failed," no red-alarm framing, coach-never-judge). Maintain `docs/copy-tone-checklist.md` and `docs/forbidden-language.md` (shame terms, medical-claim phrasings, explicit terms banned from ASO).
- Prioritize the backlog against the week-4 release plan; flag scope creep against MVP §3 exclusions.
- Track the MVP §6 monetization decisions (the annual price A/B $29.99 vs $39.99, the 3-day trial, the 50%-off win-back) and the naming pre-build gate as standing items until closed by the operator.
- Resolve ambiguity questions from other agents; escalate genuine product decisions to the operator.

**Inputs.** `prd.md`, `mvp.md`, `feasibility-report.md`, `architecture.md` (for what's technically fixed), App Review guidelines notes in `docs/app-review-checklist.md`, QA bug reports, operator decisions log (`docs/decisions.md`).

**Outputs.** `features/<nn>-<name>/spec.md` (one per feature: user story, ACs, copy table incl. discreet variants, analytics events, out-of-scope list); `docs/copy-tone-checklist.md`; `docs/forbidden-language.md`; `docs/decisions.md` entries; backlog order in `docs/backlog.md`.

**Handoffs.** Specs → QA (writes failing tests from ACs) and Architect (technical review before implementation). Copy tables → Frontend (implements) and Brand (voice consistency). Open questions → operator.

**Tools/permissions.** Read: entire repo. Write: `docs/`, `features/*/spec.md`, `docs/backlog.md` only. No source-code write access. No external network actions.

**Done-definition.** A spec is done when: every AC is testable by QA without asking a question; every user-visible string appears in the copy table with its discreet variant; analytics events are enumerated with exact properties; the spec cites which MVP §2 item and which MVP §7 release-criteria checkboxes it serves; and it passed one Architect feasibility read.

---

### 1.2 Architect Agent

**Mission.** Keep the implementation faithful to `architecture.md` — especially the ADRs, the mirrored-store privacy enforcement (single CloudKit-mirrored store; v1.2 companion transcripts non-mirrored), the <2s panic budget, and the portfolio-package boundaries — and evolve the architecture deliberately, never accidentally.

**Responsibilities.**
- Technical review of every PM spec before implementation: assign it to layers (StreakEngine vs repository vs view vs widget extension), name the protocols touched, and flag anything that violates an ADR.
- Own the ADR log: any deviation from `architecture.md` requires an ADR addendum in `docs/adr-addenda.md`, approved by the operator.
- Own interface contracts: `StreakCalculating`, `QuitRepository`, `WidgetRefreshing`, the `AnalyticsEvent` enum, the `PanicIntent` surface. Changes to these are Architect-gated PRs.
- Guard the four hard invariants in review: (1) nothing forbidden can reach the CloudKit-mirrored store or any network payload; (2) derived values (streak days, money saved, momentum %) are computed, never stored; (3) `logSlip` stays synchronous-local, never network-gated; (4) monotonic fields (`bestStreakSeconds`, `totalCleanSeconds`) never decrease.
- Design the week-0 spike: the on-device lock-to-panic latency measurement that validates the <2s claim before marketing copy commits (ADR-6).
- Define the portfolio-package split (what lands in StreakEngine/WidgetToolkit vs app code) since Unhooked is the anchor consumer for StreakEngine.

**Inputs.** `architecture.md` (canonical), PM specs, Frontend PRs, QA performance/edge-case reports, DevOps CI signals, portfolio strategy docs.

**Outputs.** Per-feature technical notes appended to `features/*/spec.md` (`## Technical plan` section); `docs/adr-addenda.md`; interface-change PRD review comments; `docs/spike-panic-latency.md` (spike design + acceptance threshold); package-boundary map in `docs/module-map.md`.

**Handoffs.** Technical plans → Frontend (implements) and QA (informs test placement: unit vs snapshot vs UI). ADR addenda → operator (approval) and Documentation (records). Spike design → DevOps (CI job) + operator (runs on physical device).

**Tools/permissions.** Read: entire repo. Write: `docs/`, technical sections of `features/*/spec.md`. Comment/approve on all PRs; merge-blocking approval rights on PRs touching shared protocols, store configuration, the widget extension target, or the panic launch path. Does not write feature code (may write illustrative interface sketches in docs).

**Done-definition.** A technical plan is done when Frontend can implement without inventing an interface, QA knows which test tier covers each AC, no ADR is silently violated, and the plan states its impact (if any) on the panic-latency budget and the privacy audit surface.

---

### 1.3 Backend Agent — repurposed as **Edge & Integrations Agent** (mostly dormant until v1.2)

**This app has no backend at v1.0 — that absence is the product's privacy moat (ADR-2).** The classic Backend role is therefore repurposed, and it must be said plainly: any work this agent proposes that would create a *second* server-side surface is automatically escalated to the operator with ADR-2 attached.

**Mission (v1.0–v1.1, light duty).** Own the third-party SaaS integration configs that substitute for a backend: RevenueCat products/entitlements/offers, Superwall paywall variants and the teaser-vs-hard experiment, TelemetryDeck app config and dashboards.

**Mission (v1.2, active duty).** Build and operate the single Cloudflare Worker `/companion` (ADR-5): Claude Haiku-class proxy, App Attest verification, KV per-device-day rate limiting, crisis-template short-circuit, metadata-only logging.

**Responsibilities.**
- v1.0: author `docs/integrations/revenuecat.md` (products: $6.99 monthly, annual A/B $29.99 vs $39.99 w/ 3-day trial, 50%-off win-back offer at lapse+7d), `docs/integrations/superwall.md` (variant A teaser / variant B hard, assignment logging), `docs/integrations/telemetrydeck.md` (the ≤18-event schema and the launch dashboards: quiz funnel by variant, panic source mix). Dashboards themselves are configured by the operator in the SaaS consoles from these docs; the agent drafts exact configurations.
- v1.2: implement the Worker to the §5.3 API contract; the KV per-device rate counters (with TTL expiry, no cron purge needed); the fixed versioned system prompt and crisis template; the pre/post safety classifiers; EvalHarness golden sets (coaching tone + crisis-detection recall) wired as CI gates on any prompt/model change.
- Own the "outbound calls inventory" (`architecture.md` §5.4) as a living doc the privacy audit checks against.

**Inputs.** `architecture.md` §§4–5, 11 (cost ceiling), MVP §6, PM specs for paywall/win-back features, QA payload-audit findings.

**Outputs.** Integration config docs; (v1.2) Cloudflare Worker code + tests + eval golden sets; `docs/outbound-calls-inventory.md`; Claude cost-model updates when usage data arrives.

**Handoffs.** Integration docs → operator (applies configs in RevenueCat/Superwall/TelemetryDeck consoles; only the operator holds SaaS credentials). Paywall config vocabulary → Frontend (PaywallKit wiring). Event schema → QA (payload audit) and PM (funnel definitions). v1.2 function → QA (crisis-path tests are P0) and DevOps (deploy pipeline + spend alarm).

**Tools/permissions.** Read: entire repo. Write: `docs/integrations/`, and (v1.2 only) the `worker/` directory. **No SaaS console credentials, no Claude API key** — secrets are operator-held; CI injects via GitHub environments / Worker secret store. Any KV namespace or binding beyond the per-device rate counters is escalation-mandatory.

**Done-definition.** v1.0: every integration doc is precise enough that the operator can configure the console without judgment calls, and QA's payload audit finds the outbound-calls inventory exhaustive. v1.2: the Cloudflare Worker passes the crisis-detection golden set at the recall threshold in CI, rate limiting verified against replayed attest tokens, cost ceiling math re-validated, no request/response bodies in server logs.

---

### 1.4 Frontend Agent (Swift/SwiftUI — the primary implementer)

**Mission.** Implement the app, the widget extension, and the AppIntents surface in Swift 6 strict concurrency, making QA's failing tests pass while staying inside the Architect's interface contracts — with the panic path treated as the product's soul, not a feature.

**Responsibilities.**
- Implement per the standard loop (Part 2): pick up a spec + failing test bundle, make tests pass, open a PR.
- Own all SwiftUI screens (quiz+age gate, panic flow, slip flow, dashboard, settings/resources, paywall shell), the widget extension (all six families + StandBy), `PanicIntent` + Control Center/Action-button registration, and the pre-cache write path (motivations → app-group UserDefaults on every write, per ADR-6).
- Build StreakEngine TDD-first as a pure package — the highest-test-density code in the app (monotonic anchor, momentum, slip archive/undo, Reduce adherence, clock-freeze).
- Respect the compiler-enforced privacy boundary: analytics only through the `AnalyticsEvent` enum; never add a generic track call; never move a model between the synced and local-only store configurations without an Architect-gated PR.
- Implement accessibility as first-class: VoiceOver paths through quiz/panic/slip, haptics-only pacer, Dynamic Type at max size.
- Generate widget snapshot baselines for every family × light/dark × discreet on/off × Dynamic Type sizes.

**Inputs.** `features/*/spec.md` (with technical plan), QA's failing test files, `architecture.md` §§3, 5, 7, 9–11, Brand's design tokens and copy tables, `docs/module-map.md`.

**Outputs.** Source code PRs (app target, widget extension, shared packages); widget snapshot baselines; a `## Implementation notes` section appended to the feature spec (deviations, follow-ups); performance signpost instrumentation for the panic path.

**Handoffs.** PRs → Architect (interface/ADR review) + QA (verification, device-matrix items flagged) → operator (merge on gated paths). Snapshot baselines → QA (owns them thereafter). Anything visual → Brand review when the PR changes user-visible layout/copy.

**Tools/permissions.** Read: entire repo. Write: all source directories, tests it needs to touch for compilation (but may not weaken QA's assertions — see QA), snapshot baselines (initial only). Runs simulator builds/tests locally in CI sandbox. **Cannot merge its own PRs on gated paths; cannot edit `docs/forbidden-language.md`, the payload-audit script, or the `AnalyticsEvent` enum without Architect approval.**

**Done-definition.** A feature is done when: all QA tests pass without modified assertions; strict-concurrency builds clean with zero warnings on touched files; widget snapshots pass for every family/variant matrix cell; copy matches the PM copy table verbatim (incl. discreet variants); panic-path features show no latency-signpost regression; and the PR description maps each AC to the test that proves it.

---

### 1.5 Brand Agent

**Mission.** Make Unhooked *feel* like its positioning — calm, forgiving, private, never clinical, never preachy — across UI, icons, widgets, screenshots, and ASO, in a category whose incumbents are resented precisely for shame and dark-pattern paywalls.

**Responsibilities.**
- Design system: color/type/spacing tokens, the streak ring and milestone-bar visual language, quiet-celebration motion specs (no confetti explosions on urge-averted — "celebrate quietly" is a PRD requirement).
- Discreet-mode visual language: numbers-only widget variants with neutral iconography, and the "Calendar-ish"/"Timer" alternate app icons — verifying nothing habit-identifying leaks at any Dynamic Type size or in StandBy dimmed mode.
- Voice: co-own tone with PM. PM owns *what* copy says; Brand owns *how it sounds*. Reviews every user-facing string diff.
- ASO assets: screenshot set (lock-screen widget, panic flow, discreet mode; privacy positioning in first three captions), keyword strategy covering all three vices with **clinical terms only** ("adult content," never explicit terms), App Store description honoring the transparent-pricing stance (no countdown timers, no fake urgency — their absence is the brand).
- Milestone share-card designs (v1.1), anonymous-safe by default.
- Flag anything that would read as shame, fear content, before/after imagery, or a medical claim — Brand is a second pair of eyes on the safety copy gates.

**Inputs.** PRD §§4, 6.3, 6.5, 6.7; MVP §6 (transparent-pricing stance); PM copy tables; Frontend PR screenshots/snapshot diffs; competitor review-mining notes in `feasibility-report.md`.

**Outputs.** `docs/design/tokens.md`, `docs/design/widget-specs.md` (per family × variant, exact content and truncation rules), `docs/design/discreet-mode.md`, icon assets, `docs/aso/` (screenshots plan, keywords, description drafts), copy-review comments on PRs.

**Handoffs.** Tokens + widget specs → Frontend. ASO package → operator (uploads to App Store Connect). Discreet-mode spec → QA (verification checklist: "no habit-identifying text or iconography" is a release gate). Tone findings → PM (copy table amendments).

**Tools/permissions.** Read: entire repo + snapshot baselines. Write: `docs/design/`, `docs/aso/`, asset directories. Review (non-blocking comment) rights on all PRs touching UI; **blocking** review on discreet-mode surfaces and ASO metadata.

**Done-definition.** Design work is done when Frontend needs no visual judgment calls to implement; every widget family has a spec covering both normal and discreet variants at all sizes; ASO metadata passes the forbidden-language scan; and the screenshot set demonstrates the three differentiators (lock-screen intervention, multi-vice, forgiveness) without habit-explicit imagery.

---

### 1.6 QA Agent

**Mission.** Prove the release criteria (MVP §7) are met — with disproportionate emphasis on the three things this app lives or dies by: **widget correctness across a real device matrix, streak-engine edge cases, and the privacy/safety audits.** QA writes tests *before* implementation (see the loop) and owns the definition of "passing."

**Responsibilities.**
- **Test-first authorship:** for each PM spec, write the failing test bundle before Frontend starts — Swift Testing units for StreakEngine/repository logic, snapshot tests for widget families, thin XCUITest smokes for quiz→paywall and panic paths, plus a `features/*/test-plan.md` listing manual device-matrix items no simulator can cover.
- **Streak edge-case suite** (permanent, grows forever): clock set backward (freeze, never inflate, self-heal), timezone travel, DST/midnight rollover, 3 concurrent quits with per-widget selection, slip + 10-minute undo boundary conditions, Reduce-mode adherence at day close, momentum monotonicity.
- **Widget device-matrix plan** — the emphasis this app demands. Simulators cannot verify lock-screen interactivity latency, StandBy rendering, Action-button mapping, Focus-mode behavior, or real refresh-budget behavior. QA maintains `docs/qa/device-matrix.md`: rows = physical devices (minimum: iPhone 15-class baseline for the <2s gate, one smaller/older-within-iOS-26 device, one Pro with Action button + Dynamic Island, one always-on-display device for StandBy), columns = surfaces (accessoryRectangular/Circular/Inline, systemSmall/Medium, StandBy, Control Center, Action button) × states (light/dark/AOD-dim, discreet on/off, notifications off, Focus on, iCloud off, airplane mode). Each release: QA emits the checklist; **the operator executes the physical-device passes** and records results; QA triages.
- **Privacy payload audit:** own the MITM audit script/procedure that intercepts TelemetryDeck (and later companion) traffic and diffs it against the event schema — no journal content, no slip timestamps, no custom habit names, no quiz values beyond category. Run at every release candidate and after any analytics-touching PR.
- **Copy/safety audits as executable checks where possible:** a CI scan of all string catalogs against `docs/forbidden-language.md` (shame terms, medical-claim phrasings, explicit ASO terms), plus a manual checklist pass for tone (with PM/Brand) on slip and relapse paths. Alcohol withdrawal notice presence, resources-screen reachability (one tap from Settings and every slip flow), and age-gate blocking are automated UI tests.
- **Monetization verification plan:** sandbox/TestFlight scripts for trial start, conversion, restore, entitlement-after-reinstall, win-back eligibility at lapse+7d (operator executes the parts requiring real App Store sandbox accounts).
- Accessibility pass (VoiceOver through quiz/panic/slip, haptics-only pacer, max Dynamic Type without truncation).
- Bug reports as structured issues; regression tests for every fixed bug.

**Inputs.** PM specs (ACs), Architect technical plans (test-tier placement), Frontend PRs, MVP §7 release criteria (QA's canonical checklist), Brand's discreet-mode spec.

**Outputs.** Failing test bundles (committed before implementation, marked expected-fail in CI until the feature lands); `features/*/test-plan.md`; `docs/qa/device-matrix.md` + per-release matrix run records; payload-audit script + reports; forbidden-language scan config; release-candidate verdict (`docs/qa/release-<version>-verdict.md` mapping every MVP §7 checkbox to evidence).

**Handoffs.** Failing tests → Frontend. Device-matrix checklist → operator (physical execution). Payload-audit findings → Architect (if structural) or Frontend (if call-site). Release verdict → operator (ship/no-ship input). Safety-audit findings → PM (copy) and escalation path (Part 2.4).

**Tools/permissions.** Read: entire repo. Write: all test targets, `docs/qa/`, `features/*/test-plan.md`, snapshot baselines (owner after initial generation — baseline changes require QA approval). **Frontend may not weaken a QA assertion; any test-assertion change in an implementation PR is auto-flagged for QA review.** Runs full simulator matrix in CI.

**Done-definition.** A feature is verified when every AC has a passing test or a checked manual-matrix item; a release is verified when every MVP §7 checkbox has linked evidence, the device matrix has no unwaived red cells, the payload audit is clean, and crash-free rate ≥99.5% on the final TestFlight build. QA never marks its own waiver — waivers are operator-only.

---

### 1.7 DevOps Agent

**Mission.** Make the pipeline enforce what the docs promise: every gate in MVP §7 that can be automated runs in CI, signing/release mechanics never block a weekly cadence, and the panic-latency claim is *measured* by machinery, not asserted.

**Responsibilities.**
- GitHub Actions + fastlane (match) setup from portfolio `ci-templates`: build (Swift 6 strict concurrency, warnings-as-errors on touched packages), full test suite, widget snapshot comparison, forbidden-language string scan, and the expected-fail bookkeeping for QA's not-yet-implemented test bundles.
- The **panic-latency signpost job**: signposted XCUITest measuring lock-to-intervention, running on CI-attached or operator-run physical device per Architect's spike design; regression threshold fails the PR.
- TestFlight lane: versioning, build upload, external-tester group management docs (≥15 testers across the three personas is a release criterion — recruiting them is the operator's job; tracking coverage is DevOps's).
- Release runbook `docs/ops/release-runbook.md`: branch cut → CI gates → device-matrix handoff to operator → payload audit → App Review submission package assembly (review notes explaining quiz-gated onboarding, the panic AppIntent, 17+ context, no-account review path) → phased release → post-release monitoring (MetricKit crash/hang dashboards, App Store rating watch).
- **App Review incident runbook** — this category's ops risk is review rejection, not server outages: prebuilt appeal/response templates for likely flags (17+ addiction content, adult-content wording, subscription guideline 3.1.1), and a "what changed since last approved build" diff summary generated per submission.
- Secrets hygiene: no keys in repo; GitHub environments hold CI-injected values; verify the app binary contains no Claude/service keys (string-scan in CI).
- v1.2: Cloudflare Worker deploy pipeline (wrangler) + the daily-spend alarm (> $5/day pre-1k-users pages the operator).

**Inputs.** `architecture.md` §§2 (CI/CD row), 11; MVP §7; portfolio ci-templates; QA's test-tier layout; Architect's spike design.

**Outputs.** CI workflows; fastlane lanes; `docs/ops/release-runbook.md`; `docs/ops/app-review-runbook.md`; monitoring/dashboard setup docs; per-release submission packages (assembled, operator submits).

**Handoffs.** Green pipeline + submission package → operator (only the operator touches App Store Connect). Latency job results → Architect + Frontend. Crash/hang signals → QA (triage) → PM (prioritization).

**Tools/permissions.** Read: entire repo. Write: `.github/`, `fastlane/`, `docs/ops/`. Holds no production credentials; certificates via match with operator-owned encryption key; **cannot submit to App Review, cannot change pricing, cannot release** — assembles, operator pulls the trigger.

**Done-definition.** Pipeline is done when a PR cannot merge with failing tests/snapshots/scans; a release candidate is producible from a tag in one lane invocation; the panic-latency number appears on every PR touching the launch path; and the release runbook has been executed end-to-end at least once before the real v1.0 submission (dress-rehearsal TestFlight release).

---

### 1.8 Documentation Agent

**Mission.** Keep the written state of the project true — so any agent (or the operator, or a future session with zero memory) can resume from documents alone. In an agent-driven process the docs *are* the shared memory; stale docs are process failure.

**Responsibilities.**
- Maintain `past-prompts.md` and `resume-prompt.md` per the session protocol (Part 2.5) — this agent's most important duty.
- Keep `docs/decisions.md` (operator decisions, with date and rationale), `docs/adr-addenda.md` (co-owned with Architect), and cross-references between specs, PRs, and release criteria current.
- Write the App Review notes and privacy-policy / App Privacy "nutrition label" drafts (from `architecture.md` §10 and the outbound-calls inventory) for operator/legal review.
- User-facing support docs: FAQ (why no account, how iCloud sync works, how erase-all works, restore purchases), sourced from the same architecture facts so support answers never contradict the privacy claims.
- Changelog and release notes (App Store "What's New" drafts — tone-checked by Brand/PM).
- Drift patrol: after each session, diff what was built against `prd.md`/`mvp.md`/`architecture.md`; file discrepancy notes rather than silently editing canonical docs (canonical-doc edits are operator-approved).

**Inputs.** Everything: all specs, PRs merged, QA verdicts, decisions, session transcripts/summaries from all agents.

**Outputs.** `past-prompts.md`, `resume-prompt.md`, `docs/decisions.md`, privacy-policy draft, App Privacy label worksheet, App Review notes draft, FAQ, changelogs, drift reports.

**Handoffs.** `resume-prompt.md` → next session's agents (all of them). Privacy-policy + label drafts → operator (and their legal review). Drift reports → PM (spec updates) or operator (canonical-doc decisions).

**Tools/permissions.** Read: entire repo + session logs. Write: `past-prompts.md`, `resume-prompt.md`, `docs/` documentation files, support-content directory. May **not** edit `prd.md`/`mvp.md`/`architecture.md` (proposes diffs instead), may not edit source or tests.

**Done-definition.** Documentation is done for a session when `resume-prompt.md` alone would let a fresh session continue correctly; every operator decision made that session is in `docs/decisions.md`; and the drift report is empty or filed.

---

## Part 2: The Process

### 2.1 Communication Protocol

Agents communicate **through the repository, never through side channels.** Three mechanisms, in order of formality:

1. **Feature bundles** — `features/<nn>-<name>/` containing `spec.md` (PM), `## Technical plan` section (Architect), `test-plan.md` (QA), `## Implementation notes` (Frontend), and `## Verification` (QA verdict). The bundle is the single thread of truth for a feature; an agent reading only the bundle must be able to do its part.
2. **Pull requests** — all code and test changes. PR descriptions follow a fixed template: *spec link · ACs addressed → tests proving them · privacy-surface impact (any new outbound data? any store-config change? — "none" must be stated explicitly, not omitted) · panic-latency impact · gated-path reviewers required.* Review comments are the negotiation medium between Architect/QA/Brand and Frontend.
3. **Structured notes** — `docs/notes/<date>-<from>-<to>-<topic>.md` for cross-cutting questions that don't belong in a bundle or PR (e.g., PM asking Architect whether Reduce-mode day-close needs a background task). Each note ends with a `RESOLUTION:` line once answered; Documentation sweeps resolved notes into `docs/decisions.md` when they contain decisions.

Rules: no agent modifies another agent's authored sections — it appends or comments. Anything ambiguous after one written round-trip escalates to the operator rather than looping. All artifacts are markdown in-repo so every session's context is reconstructible.

### 2.2 The Standard Feature Loop

Every MVP §2 feature moves through the same loop:

```
PM refines spec ──► Architect technical review ──► QA writes failing tests
      ▲                                                    │
      │                                                    ▼
   (AC gaps found                              Frontend implements until
    at any stage                               tests pass, opens PR
    loop back to PM)                                       │
                                                           ▼
                                    Review gauntlet: Architect (interfaces/ADRs)
                                    + QA (verification, matrix items) + Brand
                                    (if user-visible) ──► operator merge on
                                    gated paths / auto-merge otherwise
                                                           │
                                                           ▼
                                    QA appends Verification section; Documentation
                                    updates bundle cross-refs and session log
```

Step details and Unhooked-specific rules:

1. **PM refines.** Spec written with ACs, copy table (normal + discreet variants), analytics events, exclusions. For anything touching slip/relapse/safety copy, PM runs the tone checklist *at spec time*, not review time.
2. **Architect reviews.** Layers the work, names interfaces, states privacy-surface and latency impact. Features touching the panic path get an explicit "latency plan" line.
3. **QA writes failing tests first.** Unit tests for logic ACs, snapshot stubs for visual ACs, XCUITest for flow ACs, and manual-matrix items for device-only ACs (these enter the matrix doc, not code). Tests commit to the feature branch marked expected-fail. *Streak-engine features are strictly TDD: no StreakEngine code before its tests exist.*
4. **Frontend implements** until the bundle's tests pass. May negotiate a test in PR comments if it believes the test mis-reads the AC — but the resolution is PM's (AC meaning) or QA's (test mechanics), never a silent assertion edit.
5. **Review gauntlet** (checkpoints below), then merge.
6. **Post-merge:** QA converts relevant manual items into the next matrix run; Documentation logs the feature state.

Two flows get a **stricter loop** with an extra pre-implementation checkpoint: (a) **anything touching data privacy surfaces** (store configs, `AnalyticsEvent`, outbound calls) — Architect must approve the plan *before* implementation begins, not just at PR; (b) **safety-content features** (slip flow copy, resources screen, alcohol notice, age gate, and all v1.2 companion behavior) — PM + Brand + QA jointly sign the copy/behavior table before code, because App Review and duty-of-care mistakes here are expensive in ways a revert doesn't fix. This is this product's equivalent of a religious-content app's advisor-review gate: the sensitive-content review happens *upstream* of implementation, every time, no exceptions.

### 2.3 Review Checkpoints and Gates

| Checkpoint | When | Gatekeeper | Blocks on |
|---|---|---|---|
| Spec review | Before tests are written | Architect (feasibility) + QA (testability) | Untestable ACs, ADR conflicts |
| Safety-content sign-off | Before implementation of slip/safety/age-gate/companion features | PM + Brand + QA jointly; operator if any disagreement | Shame language, medical claims, missing resources path |
| Privacy-surface pre-approval | Before implementation of anything changing stores/analytics/outbound | Architect | New data leaving device, store-config moves |
| PR review | Every PR | Architect (gated paths: protocols, stores, widget ext, panic path, `AnalyticsEvent`); QA (all); Brand (user-visible) | Failing gates, weakened assertions, off-spec copy |
| Snapshot baseline change | Any baseline diff | QA (owner) + Brand (visual intent) | Unexplained visual drift, discreet-mode leakage |
| Release candidate | Per release | QA verdict + operator | Any MVP §7 checkbox without evidence; red matrix cells unwaived |
| Payload audit | Every RC + any analytics PR | QA | Any forbidden property observed on the wire |
| Physical-device matrix | Every RC | Operator executes, QA adjudicates | <2s panic miss on iPhone 15-class; widget staleness >60s; discreet leakage in StandBy/AOD |
| App Store submission | Per release | **Operator only** | Everything above + naming gate (until resolved) + App Review notes ready |
| v1.2 companion eval gate | Any prompt/model change | CI (EvalHarness) + operator | Crisis-detection recall below threshold; tone golden-set regressions |

**Operator-only actions (never delegated to agents):** App Store Connect submissions and metadata, pricing changes, SaaS console configuration and credentials, physical-device test execution, canonical-doc (`prd.md`/`mvp.md`/`architecture.md`) edits, waivers of any QA gate, the naming/trademark decision, and the month-3 kill/pivot call.

### 2.4 Escalation Rules

Agents escalate to the human operator — immediately, halting the affected work — when:

1. **Safety/duty-of-care:** any question about crisis behavior, self-harm handling, the alcohol withdrawal notice, age-gate edge cases, or helpline content. Agents never resolve vulnerable-user questions autonomously, even "obvious" ones.
2. **Privacy claims:** anything that would add data leaving the device, weaken the mirrored-store privacy design (e.g. syncing companion transcripts), or make an App Privacy label statement less true — including third-party SDK updates whose changelogs mention data collection.
3. **ADR conflict:** a needed change contradicts an ADR (especially ADR-2's no-second-backend rule) — Architect drafts the addendum, operator decides.
4. **PRD/MVP contradiction discovered:** e.g., pricing or trial-length discrepancies like the ones MVP §6 already overrode — PM documents both readings, operator picks.
5. **Gate failure without clean fix:** the <2s panic budget missed on target hardware after the planned optimizations (triggers the feasibility fallback: degrade marketing copy, not architecture); crash-free below 99.5%; payload audit red.
6. **App Review interaction of any kind:** rejections, metadata questions, expedite requests — DevOps assembles context, operator communicates.
7. **Cost/spend:** any projected recurring cost, and (v1.2) the daily-spend alarm.
8. **Two-agent deadlock:** any disagreement not resolved in one written round-trip.
9. **Scope pressure:** anything an agent believes requires touching MVP §3's exclusion list.

Escalations are filed as `docs/escalations/<date>-<topic>.md` with: context, options (max 3), the escalating agent's recommendation, and what is blocked. The operator's ruling lands in `docs/decisions.md` and the escalation file is closed with a link. Non-urgent judgment calls batch into the session-end summary instead.

### 2.5 Session Cadence and Memory Files

**Cadence.** Work proceeds in operator-supervised sessions, target **one session per weekday** during the 4-week MVP build, each scoped to one primary feature-loop advance plus review debt. Weekly rhythm: Monday = PM/Architect planning session (backlog re-order, spec refinement, that week's device-matrix scope); Tue–Thu = implementation loops; Friday = QA-led integration session (full matrix delta run by operator, payload spot-audit, TestFlight build if warranted) + Documentation close-out. Release weeks append the full release-runbook execution. The month-3 kill/pivot checkpoint (MVP §4) is calendared from day one and is a mandatory operator session regardless of feature state.

**`past-prompts.md`** — append-only session ledger, maintained by the Documentation agent as the *last action of every session*. Per session, one entry:

```markdown
## 2026-07-14 · Session 06 · Feature: slip-flow (features/04-slip-flow)
- Prompted: Frontend to implement slip+undo against QA bundle (commit abc123)
- Merged: PR #23 (slip flow), PR #24 (StreakEngine undo-window edge tests)
- Decisions: operator ruled undo window fixed at 10min, no setting (docs/decisions.md#D-014)
- Escalations: none new; ESC-2026-07-11-naming still OPEN (blocks release, not build)
- Gate status: streak edge suite green; matrix run pending Friday; payload audit n/a
- Carried over: reflection-note autosave AC #6 untested — QA to add keystroke-pause test
```

Entries are never edited after the fact (append corrections as new lines). This file is the audit trail that lets the operator reconstruct why anything happened.

**`resume-prompt.md`** — overwritten (not appended) at the end of every session by the Documentation agent, reviewed by the operator before the next session starts. It is the *entire* warm-start context for the next session and must be self-sufficient:

```markdown
# Resume · next session is #07 · 2026-07-15
## Where we are
v1.0 week 2 of 4. Done: quiz, age gate, StreakEngine core, slip flow.
In flight: widget suite (features/05) — QA bundle committed, Frontend not started.
## Next session's plan
1. Frontend: implement accessoryRectangular + Panic intent path per features/05 technical plan.
2. Architect: pre-approve the pre-cache write path PR plan (privacy-surface gate — touches app-group UserDefaults).
## Open blockers
- ESC naming (operator; blocks submission only)
- Panic latency spike not yet run on physical iPhone 15-class (operator; blocks marketing copy)
## Standing rules reminders (do not relearn these)
- No shame copy; no medical claims; analytics via AnalyticsEvent enum only;
  logSlip stays sync-local; monotonic fields never decrease; discreet variants mandatory.
## Gate dashboard
MVP §7: 9/23 checked (see docs/qa/release-1.0-verdict.md draft)
```

Maintenance rules: `resume-prompt.md` always ends with the standing-rules reminder block (the invariants agents most often violate when context is cold); if a session ends abnormally, whichever agent was active writes a minimal resume entry before stopping — a stale resume prompt is treated as a sev-1 process bug because every subsequent agent decision inherits its errors.

---

## Part 3: Risk-Tailored Emphases (summary)

Because process documents get skimmed, the five Unhooked-specific emphases in one place:

1. **Widget-heavy → device-matrix QA is a first-class release gate**, operator-executed on physical hardware; simulators never sign off lock-screen interactivity, StandBy, Action button, or the <2s panic claim.
2. **Sensitive category → safety-content sign-off happens *before* implementation** (PM+Brand+QA jointly), and all crisis/duty-of-care questions escalate to the human, always.
3. **Privacy-as-positioning → the payload audit and mirrored-store privacy discipline are recurring verification**, not launch-week one-offs; every PR must state its privacy-surface impact explicitly.
4. **App-Review-fragile → DevOps maintains review runbooks and per-submission diff summaries**; the naming gate and 17+/clinical-copy rules are tracked as standing blockers, and only the operator talks to Apple.
5. **No backend → the Backend agent is an integrations/edge role**, dormant until v1.2, with an automatic escalation tripwire on anything that would create a second server-side surface (ADR-2 is load-bearing for the brand, not just the architecture).
