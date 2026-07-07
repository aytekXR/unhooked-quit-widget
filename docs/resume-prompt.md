# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v1.0 |
| Last updated | 2026-07-07 |
| Phase | Analysis & design COMPLETE → ready to enter build (Phase 0 walking skeleton) |
| Feasibility verdict | **GO WITH CAUTION** (see `feasibility-report.md` §7) |

---

## Where we are

The full documentation package for `unhooked-quit-widget` is **complete and internally consistent**. All 11 required documents exist:

`prd.md` · `feasibility-report.md` · `mvp.md` · `architecture.md` · `roadmap.md` · `implementation-plan.md` · `test-suite.md` · `frontend-brandkit.md` · `agent-workflows.md` · `resume-prompt.md` · `past-prompts.md`

No production code, no package manifests, no Xcode project yet — this is deliberate. The project sits at the boundary between the design phase and the first build session.

**Canonical facts locked by the docs (do not re-litigate without an ADR):**
- **Verdict:** GO WITH CAUTION — conditions in `feasibility-report.md` §7 (rename before build; committed content plan; Reduce mode promoted to headline; price A/B from day one; <2s + safety release gates).
- **Stack:** Swift 6 + SwiftUI; WidgetKit + AppIntents (interactive panic) + ActivityKit (P1); **single SwiftData store** in an App Group, CloudKit-mirrored (fully local when iCloud off); StoreKit 2 via **RevenueCat** + **Superwall**; **TelemetryDeck** (opt-in, via the app-local `AnalyticsService` wrapper — not a shared package); MetricKit for crashes. P1 AI companion = **one Cloudflare Worker** proxying **Claude Haiku-class**, App Attest + KV rate counters (ADR-5).
- **Data models:** `Quit`, `Slip`, `UrgeEvent`, `QuizProfile`, `AppSettings` (+ `PanicSnapshot` JSON, static `MilestoneTable`/`HelplineDirectory`). No `QuizResponse`/`AllowanceDay` entities (Reduce mode rides `Quit.weeklyAllowance` + `Slip.countsAgainstAllowance`).
- **Monetization:** $6.99/mo; annual **A/B $29.99 vs $39.99**; **3-day** free trial on annual; **50%-off** win-back 7 days post-lapse; no lifetime SKU.
- **Shared packages consumed:** StreakEngine, WidgetToolkit, PaywallKit, EvalHarness, L10nPipeline (deferred), SupaKit (pattern only), ci-templates. StreakEngine is the anchor consumer.
- **Portfolio cluster:** A2 — native Swift, local-first, no backend at v1.

## Unfinished tasks (outside the docs)

These are pre-build gates and operator-owned items, not documentation gaps:

1. **Rename (Gate G0, BLOCKING):** "Unhooked" is burned (5+ live in-category products, incl. a nicotine panic-button app). Clear a new name against App Store search / USPTO / domains before any App Store Connect setup, ASO, or marketing copy. Does **not** block code.
2. **Content plan (feasibility condition #2):** a written cadence + 10 pre-scripted lock-screen-demo formats + a 2-week pre-launch content bank. Treated as P0, equal to the quiz.
3. **Panic-latency spike (Epic 0 / ADR-6):** measure lock-to-intervention cold on a physical iPhone 15-class device; the result decides whether "<2s" is marketing copy or degrades to "fast."
4. **Bundle ID / App Group ID / CloudKit container ID:** create only **after** the rename (architecture naming note) to avoid burning identifiers.

## Next priorities (in order)

1. **Epic 0 — Walking Skeleton & de-risk spike** (`implementation-plan.md` E0.1–E0.3): repo + CI (build → test → TestFlight) green on an empty app; app + widget-extension targets + App Group + shared-package wiring; the on-device panic-latency spike.
2. **Epic 1 — StreakEngine** (pure logic, TDD-first, the densest test surface): streak/clock-integrity/slip-undo/Reduce-adherence math as an I/O-free package.
3. **Epic 2 — Persistence, repository & erase**, then **Epic 3 — Panic path** (the product's soul).

Follow `roadmap.md` phasing and `agent-workflows.md` for the agent loop, checkpoints, and escalation rules.

---

## Resume prompt

> You are the lead build agent for **unhooked-quit-widget** (working title "Unhooked", pending rename). The design phase is complete; all docs in `/home/aytek/repo/prds/unhooked-quit-widget/` are current and mutually consistent, and the feasibility verdict is **GO WITH CAUTION**.
>
> **Adopt `implementation-plan.md` as your work breakdown.** Begin with the **walking-skeleton epic (Epic 0: E0.1 → E0.2 → E0.3)** and do not start any product feature until E0.1–E0.3 are green (empty app shipping to TestFlight via CI, targets + App Group + shared-package wiring compiling under Swift 6 strict concurrency, and the on-device panic-latency spike measured with its go/degrade verdict recorded).
>
> **TDD is non-negotiable** (see `test-suite.md` §7 working agreement): for every task, write the named failing test(s) first, paste the red run under a `## Red` heading, implement the minimum to pass, then refactor on green. StreakEngine is strictly test-first. Never weaken a QA assertion; safety-critical paths (crisis template, age gate, alcohol notice, zero-shame copy, resources reachability) are acceptance-test-first with zero disabled tests.
>
> **Honor the locked canonical facts** (do not re-decide without an ADR addendum): single CloudKit-mirrored SwiftData store; data models `Quit`/`Slip`/`UrgeEvent`/`QuizProfile`/`AppSettings`; RevenueCat + Superwall; TelemetryDeck opt-in via the app-local `AnalyticsService`; P1 AI = one Cloudflare Worker → Claude Haiku-class (App Attest + KV caps); pricing = $6.99/mo, annual A/B $29.99 vs $39.99, 3-day trial, 50%-off win-back. Keep the panic launch path thin (snapshot-driven, ADR-6) and streaks monotonic-anchored (ADR-7). Analytics via the `AnalyticsEvent` enum only; `logSlip` stays synchronous-local; monotonic fields never decrease; discreet variants mandatory. This remains an analysis/build repo — write real Swift/tests when you start Epic 0, but keep the rename (Gate G0) as a standing blocker on App Store Connect / ASO / marketing work only.
>
> **At session end**, update `past-prompts.md` (append a new dated session entry) and overwrite `resume-prompt.md` (current status, unfinished tasks, next priorities, and a refreshed copy-pasteable resume prompt) so a fresh session can continue from documents alone.
