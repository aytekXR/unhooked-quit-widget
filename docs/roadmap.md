# Roadmap: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Roadmap v1.1 (v1.0 2026-07-07; v1.1 2026-07-14 adds Phase 2.5 — Epic UIR "UI Reactor", operator-mandated) |
| Date | 2026-07-07 |
| Inputs | PRD v1.0, Feasibility Report v1.0 (**GO WITH CAUTION**), MVP Definition v1.0, Architecture v1.0 |
| Owner | Solo founder + AI agents |
| Companion doc | `implementation-plan.md` (TDD work breakdown) |

> **Naming note (hard gate):** "Unhooked" is a working title. Per feasibility §6/§7, the rename + trademark/App Store/domain clearance is **Gate G0** and blocks App Store Connect setup, ASO assets, and all marketing copy. It does NOT block code (architecture is name-independent), so it runs in parallel with Phase 0–1 but must close before Phase 3.

---

## 1. Timeline at a Glance (solo-dev + AI-agent weeks)

The PRD's own build target is **4 weeks code-complete for v1.0**; the feasibility report corrects this to **5–6 weeks to store-approved**. This roadmap adopts the feasibility number and challenges the PRD's 4-week figure for one stated reason: it budgets zero time for App Review iterations in a 17+ addiction-category app with a quiz-gated paywall — historically a 1–2-round review category. Everything else in the PRD's phasing survives contact.

```
Week:      0    1    2    3    4    5    6    7    8    9   10   11   12   13
           |----|----|----|----|----|----|----|----|----|----|----|----|----|
Phase 0    ██                                              Spike + skeleton + rename clearance
Phase 1         █████████                                  Core build (engine, quiz, panic, widgets)
Phase 2                   █████████                        Monetization, safety, polish → code-complete
Phase 3                          ████████                  TestFlight beta + App Review (overlaps ph.2 tail)
LAUNCH                                  ▲ v1.0 (end wk 6, target: App Store approval ≤ mid-Dec 2026)
Phase 4                                   ████████         Fast-follow v1.1 (Live Activity, share cards)
Phase 5                                           ██████████ v1.2 (AI companion, insights) — gated
Checkpoint                                                          ▲ Month-3 kill/pivot review
```

| Milestone | End of week | Contents | Confidence |
|---|---|---|---|
| **M0 — Spike verdict + walking skeleton** | 0 (2–3 days spike + 2 days skeleton) | Panic AppIntent measured on device; CI green on empty app; rename shortlist filed | High |
| **M1 — Core loop works on a phone** | 2 | Streak engine (TDD, edge-suite green), quiz→summary, panic flow, slip/undo, 3 quits | High |
| **M2 — Full surface area** | 4 | All widget families + discreet mode, paywall + trial + A/B wiring, analytics, safety screens, iCloud/erase — **code-complete v1.0** | Medium-High |
| **M3 — TestFlight beta live** | 4.5 | ≥15 external testers across 3 personas; dashboards live | High |
| **M4 — v1.0 App Store approved** | **5–6** | Release-criteria checklist (MVP §7) fully green; 1–2 review rounds absorbed | Medium (review variance) |
| **M5 — v1.1 fast-follow** | 8 | Live Activity urge timer, share cards, win-back tuning, review-response cadence | High |
| **M6 — v1.2 shipped (conditional)** | 10–11 | AI urge companion (guardrailed) + pattern insights + Health minutes | Medium (gated, see §4) |
| **M7 — Kill/pivot checkpoint** | launch + 12 | ≥1,000 quiz-completing installs/mo and ≥8% conversion, else stop feature work and re-decide | — |

**Total estimate: 5–6 weeks to approved v1.0; ~10–11 cumulative weeks through v1.2** (matching feasibility §4: 5–6 + 2 + 2–3).

---

## 2. Development Phases

### Phase 0 — Spike + Walking Skeleton (Week 0; ~4–5 working days)
The feasibility report's condition #2, plus the shipping harness so every later week ends in a installable build.

- **De-risk spike (days 1–3):** interactive lock-screen AppIntent → dedicated panic launch path on a physical iPhone 15-class device; measure lock-to-intervention cold. **Decision recorded:** if <2s → "<2s" is marketing copy; if not → copy degrades to "fast," architecture unchanged (ADR-6). Also verify iOS 26 lock-screen widget slots and Control Center/Action-button registration.
- **Walking skeleton (days 3–5):** repo, Swift 6 app target + widget extension + App Group, shared-package dependency wiring (StreakEngine, WidgetToolkit, PaywallKit stubs; the app-local `AnalyticsService` wrapping the TelemetryDeck SDK), GitHub Actions + fastlane from `ci-templates` running unit tests + a snapshot test + TestFlight upload of an empty booting app. CI is a Phase-0 deliverable, not a later chore.
- **In parallel (non-engineering):** rename shortlist → App Store / USPTO knockout / domain checks (Gate G0). Start founder TikTok content backlog (the Action-button demo can be filmed off the spike build).

**Exit criteria:** spike verdict documented; `main` produces a signed TestFlight build automatically; G0 candidate name selected.

### Phase 1 — Core Product Loop (Weeks 1–2)
Everything a user touches at the moment of urge, built inside-out from the pure logic.

- **StreakEngine v1** (portfolio package, TDD-first — the densest test surface in the app): streak math, monotonic-clock guard, timezone safety, slip archiving + momentum, 10-minute undo, Reduce-mode adherence.
- Persistence layer: single SwiftData store in the App Group (CloudKit-mirrored; runs fully local when iCloud is off, per architecture §4/§8), repository protocol, launch-time dedupe merge.
- **Panic flow** end-to-end from the real intent path (breath pacer + haptics, urge timer message, verbatim reasons from pre-cached snapshot, redirect menu, both exit states).
- **Slip flow** with forgiveness mechanics and zero-shame copy checklist.
- **Onboarding quiz** (12–14 screens + age gate) → personalized summary. Copy is the hard part; agents scaffold screens, founder owns tone.
- Up to 3 concurrent quits; Quit vs Reduce goal modes.

**Exit criteria (M1):** on a physical device: complete quiz → create quit → see streak → trigger panic from lock screen → log slip → undo. StreakEngine edge-case suite green in CI.

### Phase 2 — Surfaces, Money, Safety (Weeks 3–4)
- **Widget suite:** accessoryRectangular/Circular/Inline, systemSmall/Medium, StandBy state; per-widget quit selector; discreet-mode variant for every family; alternate app icons; write→debounced timeline reload; snapshot tests per family × mode.
- **Monetization:** PaywallKit + RevenueCat products ($6.99/mo, **annual A/B $29.99 vs $39.99, 3-day trial, 50%-off win-back** — per MVP §6), Superwall teaser-vs-hard variant wiring, restore, entitlement-survives-reinstall.
- **Analytics:** typed `AnalyticsEvent` enum (privacy by unrepresentability), all §5 MVP events, opt-in consent screen.
- **Safety & compliance:** resources/helplines screen, alcohol withdrawal notice, content-table audit, copy audit.
- **iCloud sync + one-tap erase** (incl. CloudKit zone purge); fully-local mode verified.
- Accessibility pass (VoiceOver, Dynamic Type, haptics-only pacer).

**Exit criteria (M2):** MVP §7 "Core product" + "Monetization" checklists green in sandbox; code-complete.

### Phase 2.5 — Epic UIR "UI Reactor": full UI/UX regeneration (ADDED 2026-07-14, operator-mandated)

> **Operator directive (2026-07-14, verbatim intent):** the current UI is "not good
> enough" — regenerate the app's UI/UX. This phase inserts AFTER the last
> pre-submission functional build task (R30.6, Session 31) and BEFORE submission
> assets: G0 screenshots/preview must be captured on the post-UIR surface. It does
> NOT block the operator's parallel tracks (§3 copy pass, §8 keys/sandbox, device
> rows, external beta on the current build).

**Scope — what changes:** the visual layer only. Layout, hierarchy, spacing, color
tokens, component styling, motion, across the full screen set: age gate, quiz,
consent step, summary, dashboard, panic flow, slip flow, settings sheet, resources,
paywall (hard/teaser/winback), and all widget families × normal/discreet.

**Binding constraints — what does NOT change (the canons hold):**
- Copy: every user-facing string stays byte-identical to its audited table — copy is
  operator-expected §3 founder-owned; UIR moves pixels, never words.
- Register: no red anywhere (the alcohol notice card stays AMBER); calm, quiet
  celebration (brandkit §1/§7); no countdown/urgency mechanics enter any paywall.
- Accessibility only strengthens: the audit family stays green and unquarantined;
  Dynamic-Type no-truncation and VoiceOver labels are floors (brandkit §8). UIR-0's
  token work CLOSES the deferred R28.13 WCAG contrast/textClipped findings by
  construction — the new palette must pass the audit's contrast checks, shrinking
  the R28.13 exclusion list toward zero.
- Privacy surfaces untouched: the widget feed field set, discreet mode's no-leak
  rule, and panic-path thinness (panic surfaces still never open the store or query
  entitlements) are structural, not visual.
- ADR-6: no new blocking work enters the panic launch path (latency budget).
- Safety-content surfaces (panic/slip/resources/notice) keep the stricter loop:
  PM+Brand+QA sign the redesign spec BEFORE code (agent-workflows §2.2).

**Goldens discipline:** each UIR session re-records only its own surfaces' goldens
from its run artifacts (the established free maneuver); the operator's §3-gated
batch remains ONE final re-record (final copy + final palette together — the
Session 28 promise stands, UIR widens its scope, not its count).

**Tooling note (honesty record):** the operator's directive referenced a "uipro"
tool, and mid-Session-31 the operator reported it INSTALLED. Verified twice on the
build box (2026-07-14, session open + after the report): no skill/plugin/MCP tool
by that name is visible in this environment (skills registry, both plugin
surfaces, MCP/deferred tool list — the only marketplace is claude-plugins-official,
uipro-free). The install either landed on another machine (the Mac?) or did not
take — a discrepancy only the operator can resolve (operator-expected §9).
**Standing instruction:** the moment a tool named "uipro" IS available in a
session's environment, UIR sessions load it and use it as the PRIMARY UI
regeneration tool — the multi-agent design workflows (independent redesign
proposals per surface → judge panel → synthesis, per `agent-workflows.md`) plus
the snapshot lane are the execution vehicle either way, with uipro slotting in as
the generator when present. UIR does not block on it.

**Session plan (each one-objective, standard loop, budget ruled per-session at its
own STEP-0):**
- **UIR-0 — Design system:** regenerated tokens (color/type/spacing/motion) + the
  component kit + the WCAG-clean palette closing R28.13; deliverable = a
  brandkit-tokens addendum + a Theme layer in code + re-recorded goldens.
- **UIR-1 — Onboarding:** age gate + quiz + consent + summary.
- **UIR-2 — Dashboard + widget families** (× discreet).
- **UIR-3 — Panic + slip flows** (safety pre-sign-off; copy untouched).
- **UIR-4 — Paywall (hard/teaser/winback) + settings + resources.**
- **UIR-5 — Motion/polish + AX5 axes** + consolidated golden-batch prep for the
  operator's §3 sitting.

**Exit criteria:** all snapshot goldens re-recorded on the new system; the a11y
audit green with the R28.13 exclusion list shrunk to zero or a documented
remainder; zero copy bytes changed (the lexicon/copy gates prove it); G0
screenshots captured post-UIR.

### Phase 3 — Beta → Review → Launch (Weeks 4–6, overlapping Phase 2 tail)
See §3 Release Phases.

### Phase 4 — Fast-Follow v1.1 (Weeks 6–8 post-launch start)
Live Activity/Dynamic Island urge timer (ActivityKit), milestone share cards (rendered images, no server), win-back offer tuning with real lapse cohorts, iOS 27 widget-size prep, ASO keyword iteration #1, review-response routine. **Rule: no v1.1 feature work before launch dashboards confirm the funnel instrumentation is trustworthy.**

### Phase 5 — v1.2 AI Companion + Insights (Weeks 8–11, conditionally)
The only owned infrastructure: one rate-limited Cloudflare Worker (Claude Haiku-class proxy, App Attest device attestation, KV per-device rate counters, crisis-template guardrail — per ADR-5), EvalHarness golden sets as CI gates, on-device risk-window pattern insights, Apple Health mindful minutes. **Gate:** ships only after v1.0 is stable (crash-free ≥99.5%) and the funnel shows signs of life — per feasibility, never ship safety-critical AI under launch pressure. If M7 metrics are trending toward kill, Phase 5 is cancelled and the weeks go to distribution work instead.

---

## 3. Release Phases

| Stage | When | Gate to advance |
|---|---|---|
| **Internal TestFlight** | Continuous from Week 0 (CI uploads every merge) | CI green |
| **External TestFlight beta** | Week 4–4.5 | M2; ≥15 external testers recruited across the three personas (vape/porn/alcohol) via Reddit/Discord — authentic, non-astroturf outreach doubling as distribution groundwork |
| **Beta hardening** | Weeks 4.5–5 | Crash-free ≥99.5%; quiz median ≤120s across 5 test users; analytics payload MITM audit clean; panic-latency signpost within budget |
| **App Store submission** | Week 5 | Full MVP §7 release-criteria checklist, incl. review notes (quiz-gated onboarding, PanicIntent, 17+ context, no demo account needed), App Privacy label, ASO assets under the **cleared new name** |
| **v1.0 launch** | Week 5–6 | Approval (1–2 review rounds budgeted). **Calendar target: approved by mid-December 2026** to catch the New Year quitting spike (feasibility condition #4). Slack exists: a Week-0 start in early July leaves ~4 months of buffer — use it for distribution content, not scope creep |
| **Fast-follow v1.1** | Launch + ~2 weeks | Funnel dashboards trustworthy; no P0 field bugs |
| **v1.2** | Launch + ~5 weeks | Phase-5 gate above |
| **Kill/pivot checkpoint** | Launch + 3 months | <1,000 quiz-completing installs/mo OR conversion <4% across both paywall variants → halt feature work, pivot positioning (single-vice lead) or shelve |

> **UIR gate on submission (added 2026-07-14):** the App Store submission row above
> additionally waits on **Phase 2.5 (UI Reactor)** — the operator ruled the current
> UI below the submission bar, and G0 screenshots/preview must show the post-UIR
> surface. The operator may waive this gate (it is a quality bar, not a compliance
> one); everything else in the table proceeds in parallel on the operator's clock.

**Launch-week funnel discipline:** the teaser-vs-hard paywall A/B (the MVP-thesis test) starts day 1 via Superwall remote variants — no app release needed to iterate. Week-1 and week-2 checkpoints read `paywall_viewed → trial_started` by variant; the losing variant is retired by week 4 and the winner eventually frozen into PaywallKit (planned Superwall de-integration, ADR-4).

---

## 4. Workstream Dependencies

```
G0 Rename clearance ────────────────────────────┐ (blocks store setup, ASO, marketing copy — NOT code)
                                                ▼
W0 Spike ──► Panic launch path ──► Panic flow ──► App Review notes
W0 Skeleton/CI ──► everything (all merges ride CI from day 1)
StreakEngine (pkg) ──► Repository/stores ──► Slip flow, Widgets, Dashboard
Quiz ──► Summary ──► Paywall (paywall content = quiz output; sequential)
Quiz answers ──► Panic "your reasons" (pre-cache written at quiz completion)
Widgets ──► Discreet mode variants (same templates, second pass)
PaywallKit/RevenueCat config ──► Trial ──► Win-back (config-only, ships in v1.0 per MVP)
Analytics enum ──► every feature's instrumentation (enum lands in Phase 1, week 1)
Beta testers recruited (week 3, parallel) ──► External beta (week 4)
v1.0 stability + funnel signal ──► Phase 5 (AI companion)
EvalHarness golden sets ──► any companion prompt/model change (CI gate)
```

```
R30.6 manifest (S31) ──► UIR-0 tokens ──► UIR-1…5 surfaces ──► §3-gated golden batch ──► G0 screenshots ──► submission
```

Critical path: **Spike → StreakEngine → panic/slip flows → widget suite → paywall → UI Reactor → beta → review.** The quiz and safety screens are off-critical-path and parallelizable to agents; copy review is the founder bottleneck and should be batched twice weekly.

---

## 5. Risk Mitigation Plan (tied 1:1 to feasibility risks)

| Feasibility risk | Roadmap response |
|---|---|
| **Name collision (High/High)** | G0 hard gate, week 0, parallel to spike; no ASO asset, store listing, or marketing copy produced under the working title. |
| **Distribution failure (High/High) — the load-bearing risk** | Launch timed to New Year window with ~4 months of calendar slack; founder content production starts Week 0 (spike build = first Action-button demo video); creator rev-share outreach during beta; authentic Reddit presence begins with beta recruiting; teaser-vs-hard A/B live from day 1; **M7 kill/pivot checkpoint calendared at launch, not discovered later**; Phase-5 engineering weeks are explicitly convertible to distribution weeks. |
| **<2s panic latency unproven (Low-Med/High)** | Week-0 device spike *before* any copy commits; ADR-6 architecture makes the claim engineered; CI carries a signposted on-device latency test forever; copy fallback pre-agreed ("fast"). |
| **App Review rejection (Med/High)** | 1–2 review rounds budgeted inside the 5–6-week number; pre-review checklist + review notes drafted in Phase 2, not at submission; clinical metadata; age gate implemented (feasibility condition #6); no hot-updatable content (ADR-9) keeps reviewer trust. |
| **Panic button commoditized (High/Low-Med)** | All positioning copy written against *lock-screen-native / two-second* panic, never "panic button"; measured latency becomes the marketing number. |
| **Underpricing caps LTV (Med/Med)** | Roadmap adopts the MVP §6 annual A/B ($29.99 vs $39.99) + 3-day trial + 50%-off win-back from day 1 (config, not code); no weekly SKU ever; transparent-pricing stance in onboarding + ASO copy. |
| **Widget staleness / streak-integrity bugs (Med/Med)** | StreakEngine is TDD-first with the edge-case suite as a permanent CI release gate; WidgetToolkit stale-grace + rollover entries; write-triggered debounced reloads; timezone/clock QA on the beta checklist. |
| **AI companion safety failure (Low/High)** | Entire feature deferred to Phase 5 behind a stability gate; fixed crisis template served from the function (never generated); EvalHarness crisis-recall golden set gates every prompt/model change in CI; rate limits are launch config. |
| **Minors in category (Med/High)** | Age gate is a Phase 1 quiz task (first screen), 17+ rating, no under-17-skewing content formats in the founder content plan. |
| **Vulnerable-user duty of care** | Safety/resources screens and copy audits are M2/M4 **release gates**, not backlog items; slip flow ships with the zero-shame checklist enforced. |
| **iOS API churn (High/Low)** | v1.1 line item reserved for iOS 27 widget sizes; surface area deliberately small. |
| **Thin technical moat (High/Med)** | The roadmap's answer is cadence: v1.1 two weeks after launch, funnel iteration without releases (Superwall), codebase small enough that a competitor's copy is answered within a release cycle. |

---

## 6. What This Roadmap Deliberately Does NOT Contain

Community/social, content blocker, Android, gambling module, lifetime SKU, localization beyond EN (TR fast-follow only after tone is proven), Screen Time API — all per PRD non-goals and MVP exclusions. Any addition that requires a second server-side surface re-justifies against ADR-2 first.
