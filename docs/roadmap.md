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

**Tooling note (honesty record — RESOLVED in Session 32):** the operator's directive
referenced a "uipro" tool, and mid-Session-31 the operator reported it INSTALLED;
S31 could not find it and recorded the discrepancy. **Session 32 found it: `uipro`
v2.11.0 is an npm CLI on this box's PATH** (`~/.nvm/versions/node/v20.20.2/bin/uipro`)
— the S31 probes searched the skill/plugin/MCP surfaces, not PATH binaries, so the
tool was present all along. `uipro init -a claude` installs its "UI/UX Pro Max"
skill under `.claude/skills/` (gitignored — machine-local tooling, the `.codegraph`
precedent). **Standing instruction (unchanged in force, now executable):** UIR
sessions probe `which uipro` at open and drive it as the PRIMARY generator — with
the brandkit + `docs/design/tokens-v2.md` canon OVERRIDING it wherever they conflict
(every stock uipro palette ships a red destructive token, banned in this product;
its font suggestions assume Google Fonts, not our SF-only rule). The adopt/override
record for UIR-0 is tokens-v2 §8. The multi-agent design workflows (independent
redesign proposals per surface → judge panel → synthesis, per `agent-workflows.md`)
plus the snapshot lane remain the execution vehicle; uipro is the generator inside
it, never the authority.

**Session plan (each one-objective, standard loop, budget ruled per-session at its
own STEP-0):**
- **UIR-0 — Design system: ✅ DONE (Session 32, 2 billed runs).** Delivered
  `docs/design/tokens-v2.md` (the brandkit addendum of record — 5 LIGHT hexes
  drift-corrected, R32.7), the `App/Sources/DesignSystem` Theme layer (data-first
  `ColorToken` registry + `ContrastMath` + `ThemeMetrics` + 5 primitives), the
  colors-only swap of all 12 view files, 64 re-recorded panic/slip goldens, and two
  permanent unit gates (`ThemeContrastTests` 30 pairs ×2 modes, `ThemeSourceLintTests`).
  **`.contrast` is RESTORED to the a11y audit on all three legs — the R28.13
  exclusion list shrank for the first time**; `.dynamicType`/`.textClipped` remain
  excluded and are now owned BY NAME (quiz→UIR-1, panic + slip→UIR-3).
- **UIR-1 — Onboarding: ✅ DONE (Session 33, 2 billed runs).** Age gate + quiz +
  consent + summary regenerated on the Theme layer, copy bytes byte-identical.
  Delivered the `OnboardingScaffold` primitive (content scrolls / actions pinned —
  the Dynamic-Type fix as STRUCTURE), the style adoptions (R33.8), a 44pt floor on
  the blocked screen's helpline dial link (R33.10), and `OnboardingLayoutLintTests`.
  **`.dynamicType` + `.textClipped` are RESTORED on all three onboarding legs — the
  exclusion list shrinks a second time — and the age gate and summary are AUDITED FOR
  THE FIRST TIME** (5 legs, 6 frames). The audit's own finding ledger produced
  **R33.12**, the session's discovery: a point size on TEXT is un-scalable to Apple's
  audit no matter what drives it (a `@ScaledMetric` does not rescue it), and
  `ViewThatFits` makes every `Text` inside it un-scalable too. Only panic and slip
  remain excluded, owned by UIR-3.
- **UIR-2 — Dashboard + widget families: ✅ DONE (Session 34, 2 billed runs).** The real
  `StreakDashboardCard` + `StreakRing` are built on the Theme layer — the `RootPlaceholderView`
  "walking skeleton" that had stood in for the dashboard since Session 18 is RETIRED, replaced by
  one card per active quit (streak-day hero, flame + momentum figure, the momentum ring, money
  saved, next-milestone bar). Copy is byte-identical (audited labels + ADR-11 data; the §3-blocked
  polish strings ship empty-guarded). **The dashboard is audited for the first time and its first
  a11y audit passed CLEAN** — the first UIR surface to fire nothing, because R33.12 was already
  known and the free layout lint enforced it before the push. **Widgets were DEFERRED at STEP-0**:
  the 5 families are on-spec bar two minor brandkit-§3 typography defects, so `StreakWidgetViews.swift`
  stayed untouched and the 29 widget goldens byte-stable — the typography fix rides UIR-5. 8 dashboard
  goldens minted (95 → 103); the `.dynamicType`/`.textClipped` exclusion list still holds panic + slip
  (UIR-3's job).
- **UIR-3 — Panic + slip flows: ✅ DONE (Session 35, 2 billed runs).** The panic and slip
  flows (rule-11 SAFETY surfaces) are regenerated on the Theme layer with a PM+Brand+QA
  pre-code sign-off; copy byte-identical. **The `.dynamicType`/`.textClipped` exclusion list
  is CLOSED to ZERO** — all 8 `minHeight: 56` floors became growing PADDING (the exact S28
  mechanism), `StepScaffold`/`confirmStage` now scroll with pinned actions (R33.5), the reasons
  text moved off a `@ScaledMetric` point size onto the `.largeTitle` text style (R33.12), and
  both audit legs joined the full 7-type set (`safetyAuditTypes` deleted). **The rule-11 legs
  passed CLEAN on run 1** (the second consecutive clean first-audit; contingency unused). 64
  class-A goldens re-recorded, each visually verified. Carried: the reasons-frame AX5 title
  truncation and the `.buttonStyle(.plain)` → ButtonStyle refactor ride UIR-5.
- **UIR-4 — Paywall + settings + resources: ✅ DONE (Session 36 / UIR-4a, 2 billed runs).**
  The two DEFECT surfaces are DONE: **RESOURCES** (safety) — `.background(.quaternary)` → `themedCard`,
  and the R33.10 fix (the helpline DIAL link at a 44pt floor + a "Call <name>" VoiceOver label);
  minted 2 goldens + a new audit leg that passed the full 7-type set CLEAN on its first run (the third
  consecutive clean first-audit). **PAYWALL** — 3 R32.9 disabled-`.plain` violations fixed
  (`PrimaryButtonStyle`/`QuietButtonStyle` + a new pass-through `PlanCardButtonStyle`), plus a
  pre-existing caution-on-caution contrast bug in the failure banner; no goldens (draft copy).
  **SETTINGS (`DiscreetSettingsView`) — the List→ScrollView restyle is DEFERRED to UIR-4b** (a
  canon-only change, the biggest structural risk, cleanly separable; its full spec is preserved). New
  contrast pair (34 total). R36.4 = the mount-gate lesson: a full-screen `.contain` container id does
  NOT surface — gate an audit leg on a real child element.
- **UIR-4b — Settings restyle: ✅ DONE (Session 37, 2 billed runs).** `DiscreetSettingsView` moved onto
  the Theme layer via in-place List theming (`.scrollContentBackground(.hidden)` + surface/base backdrop +
  `.listRowBackground(surface/raised)` per Section + `.tint(brand/primary)` + Theme text tokens), keeping
  List's native cell accessibility. 2 goldens minted. **UIR-4 is now fully complete.** Deferred to UIR-5:
  the settings/paywall audit legs + the Monetization lint scope + full settings golden coverage.
- **UIR-5a — The deferred audit legs + Monetization lint scope: ✅ DONE (Session 38, 2 billed runs).**
  The **paywall** joins the audited surfaces — `test_a11yAudit_paywall` (UITEST_PAYWALL_DIRECT → the
  hard-variant fixture) passed the FULL 7-type set CLEAN on its first run; the a11y audit now covers **8
  surfaces** (age gate, quiz, summary, dashboard, panic, slip, resources, paywall). `App/Sources/Monetization`
  joined the layout-lint scope (48 files, floor 12 → 35, born-green; the inline retry `.plain` → the
  pass-through `PlanCardButtonStyle`). No goldens. **R38.2:** the **settings** audit leg is DEFERRED — its
  `.dynamicType`+`.textClipped` fired on the navigation-bar LARGE TITLE ("Discreet Mode",
  NavigationBar/LargeTitle — a SYSTEM behavior, not the themed content), so the fix (a custom/`.inline`
  title, which re-records the settings golden) rides UIR-5b.
- **UIR-5b attempt 1 — The settings audit leg: ⏸️ DEFERRED to its true depth (Session 39, 2 billed
  runs, reverted to green).** The runs bought the DIAGNOSIS, no net feature. **R39.1:** a `.largeTitle`
  title in a List ROW clips at AX5 exactly like the nav bar (a row is height-constrained). **R39.2:** a
  FREE-STANDING title above the List FIXES the title (proven), but the audit then flags the settings
  **List CONTENT** — the long haptic-pacer SECTION FOOTER clips at AX5 with NO font to fix (List section
  footers clip at accessibility sizes — STRUCTURAL). Deferred: completing it (move every long footer out
  of the `footer:` slot + re-record goldens) is unknown-depth whack-a-mole per billed run. Reverted
  byte-identical to the UIR-5a green state; the 8 audited surfaces + 107 goldens stay green. Fix now
  KNOWN on both axes (title = free-standing text above the List; content = footers out of List slots).
- **UIR-5c — The remaining UIR polish** (INDEPENDENT items; sequence lowest-risk first):
  - **Widget typography (R34.7): ✅ DONE (Session 40, 2 billed runs, zero theory-failures).** brandkit
    §3 `type/widgetNumeral` (rectangular numeral 17→20pt Semibold monospaced) + `type/widgetLabel`
    (rectangular "saved" split out + medium savedLabel/milestoneLabel → 12pt Medium tracking +0.3). An
    8-agent verify+critique workflow made run 1 correct on the first try (caught the line-168 blocker
    the first plan missed). 9 goldens re-recorded + visually verified; 20 unchanged untouched (total 29).
    Flagged to operator: numeral `.semibold` vs `.bold`; medium labels fixed-12pt (no AX5 scaling).
  - **Reasons-frame AX5 (R35.6): ✅ DONE (Session 40, 2 billed runs).** At accessibility sizes the panic
    "your reasons" step scrolls (title grows) instead of paging (title truncated). Pure layout; a
    double no-op for the rule-11 audit. 4 reasons-AX goldens re-recorded + visually verified.
  - **`StreakRing` motion: ✅ DONE (Session 40, 1 billed run, zero golden churn).** The momentum ring's
    `motion/calm` (0.6s) appear animation — opt-in + golden-safe (default settled draw is byte-identical;
    only the live dashboard animates). The animation is flagged for the operator's device eyeball.
  - **Golden-batch prep: ✅ DONE (Session 40).** `docs/golden-batch.md` — the plan for the ONE final
    re-record at the operator's §3 sitting (the onboarding + paywall goldens get MINTED then; everything
    else is stable).
  - **DEFERRED (MAC-GATED): the settings-content audit.** Attempted on CI in S40 (5 runs,
    enumerate-all-from-one-run): title (free-standing `.largeTitle`) + long footer (self-sizing
    `captionRow`) FIXED and known-good, but the resources row is an unsolved Button+wrapping-title
    Dynamic-Type conflict (`Label` truncates; `HStack` clears the clip but "partially unsupported"
    persists) that needs Xcode's Accessibility Inspector. Reverted to green. **After UIR-5c the
    CI-doable UIR work is COMPLETE — only the Mac-gated settings-content audit + the operator critical
    path remain.**

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
