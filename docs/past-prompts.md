# Past Prompts: Unhooked — Session Log

Append-only ledger of build/design sessions. Newest entries at the bottom. Never edit a past entry after the fact — append corrections as new lines.

---

## 2026-07-07 · Session 01 · Portfolio-architect mission — design package authored & QA-reconciled

**Prompted.** Produce (and then release-QA) the full analysis/design documentation package for `unhooked-quit-widget`: a native iOS "quit-anything" app whose wedge is an **interactive lock-screen panic button** (AppIntents) landing the user in a <2s full-screen urge intervention, with forgiveness mechanics, multi-vice tracking, and privacy-absolutist (no-account, local-first) architecture. Analysis/design phase only — Markdown docs, no production code.

**Produced.** The 11-document package: `prd.md`, `feasibility-report.md`, `mvp.md`, `architecture.md`, `roadmap.md`, `implementation-plan.md`, `test-suite.md`, `frontend-brandkit.md`, `agent-workflows.md`, plus this log and `resume-prompt.md`. `feasibility-report.md`, `mvp.md`, and `architecture.md` were regenerated later than the planning docs; a QA pass reconciled the planning docs to the current architecture (see "Reconciliation" below).

### Key decisions

- **Feasibility verdict: GO WITH CAUTION.** Demand, willingness-to-pay (comparables charge $45–$100/yr vs the PRD's $29.99), technical foundation (iOS 26 interactive AppIntents), and portfolio fit all clear. Caution drivers: (1) the name "Unhooked" is burned by 5+ live in-category products (incl. a nicotine panic-button app) → **rename is a hard pre-build gate**; (2) the concept wedge is partly shipped (Quit All has ~70% of it at zero traction) → the winner is decided by funnel/brand/content, not features; (3) growth is founder-content-driven and the PRD commits to no content plan.
- **Stack.** Swift 6 + SwiftUI; WidgetKit + AppIntents + ActivityKit (P1); **single SwiftData store** in an App Group, CloudKit-mirrored (fully local when iCloud off); StoreKit 2 via **RevenueCat** + **Superwall** (paywall A/B is the business); **TelemetryDeck** opt-in via an app-local `AnalyticsService`; MetricKit crashes. P1 AI urge-companion = **one Cloudflare Worker** → **Claude Haiku-class**, authenticated by **App Attest** with **KV** per-device rate caps; transcripts on-device only. No first-party backend at v1 (portfolio cluster A2).
- **MVP scope.** Included: 12–14-step quiz funnel → hard-ish paywall; streak engine with slip-forgiveness + Momentum score + 10-min undo; Quit **and Reduce** goal modes (Reduce promoted to headline per research); up to 3 concurrent quits; full widget suite (lock-screen interactive rectangular + circular + inline, home small/medium) + discreet mode + alternate icons; interactive panic launch (<2s cold); ~90s panic flow; money-saved counter; safety layer (helplines, alcohol withdrawal notice); no-account privacy + one-tap erase; streak time integrity; opt-in category-only analytics. Excluded: community/social, content blocker, medical claims, Android, gambling module, shame mechanics, AI companion (P1), Live Activity (P1), share cards/insights/Health (P1), Screen Time API, lifetime SKU, non-EN localization, StandBy (v1.1).
- **Monetization.** $6.99/mo; annual **A/B $29.99 vs $39.99** (per feasibility, the PRD under-prices the category); **3-day** free trial on annual; **50%-off** win-back 7 days post-lapse; no lifetime SKU.
- **Success metrics.** Quiz completion ≥70%; completers→trial/paid ≥8%; trial→paid ≥35%; panic widget added by D1 ≥40%; panic uses/WAU ≥1.0; post-slip D7 retention ≥50%; D30 sub retention ≥65% (honest bar; PRD's 75% is the stretch); rating ≥4.7.

### Architectural choices (ADRs, current numbering)

ADR-1 native Swift 6/SwiftUI · ADR-2 no backend / no accounts · ADR-3 SwiftData + CloudKit mirroring · ADR-4 RevenueCat + Superwall · ADR-5 Claude Haiku behind one Cloudflare Worker (App Attest + KV) · ADR-6 snapshot-driven thin panic launch (<2s) · ADR-7 monotonic-anchor streak integrity · ADR-8 TelemetryDeck opt-in + MetricKit only · ADR-9 static content in-bundle (no CDN) · ADR-10 Reduce mode as a first-class engine mode.

Data models: `Quit`, `Slip`, `UrgeEvent`, `QuizProfile`, `AppSettings` (+ `PanicSnapshot` JSON for the thin panic/widget read path; static `MilestoneTable`/`HelplineDirectory`). Reduce mode uses `Quit.weeklyAllowance` + `Slip.countsAgainstAllowance` — no separate allowance entity.

### Reconciliation (QA pass — planning docs aligned to the regenerated architecture/MVP)

Edited `roadmap.md`, `implementation-plan.md`, `test-suite.md`, `agent-workflows.md`, `frontend-brandkit.md` to remove drift from the older planning docs:
- **AI backend:** Supabase Edge Function / Sonnet / Postgres+pg_cron → **Cloudflare Worker / Claude Haiku-class / KV counters** (ADR-5).
- **Shared-package name:** dropped the non-existent **`TelemetryKit`** package; analytics is the app-local `AnalyticsService` wrapping TelemetryDeck (architecture §14 lists no analytics package). Added SupaKit (pattern only) where the Worker template was mis-attributed.
- **Persistence:** **split `Synced.store`/`LocalOnly.store`** → **single CloudKit-mirrored store** (architecture §4); v1.2 companion transcripts held in a separate non-mirrored store.
- **Data-model names:** `QuizResponse` → `QuizProfile`; removed `AllowanceDay`.
- **Pricing/trial:** fixed `$39.99` / `7-day` / `$24.99` → **A/B $29.99 vs $39.99 / 3-day / 50%-off** (MVP §6).
- **ADR renumbering:** planning-doc citations corrected to current numbers (panic thin-launch → ADR-6; Superwall removability → ADR-4; Worker/prompt-eval/App Attest → ADR-5; static-content-in-bundle → ADR-9).

### Pending items (carried into the build phase)

- **Gate G0 — rename** (BLOCKING for App Store Connect / ASO / marketing; not for code). Clear against App Store search + USPTO + domains.
- **Content plan** (feasibility condition #2): cadence + 10 lock-screen-demo formats + 2-week pre-launch bank.
- **Panic-latency spike** on a physical iPhone 15-class device (Epic 0 / ADR-6) → sets the "<2s" vs "fast" copy decision.
- Create bundle ID / App Group ID / CloudKit container ID **after** the rename.

### Gate status

Design docs: complete and consistent. Feasibility: GO WITH CAUTION. No code, no CI, no TestFlight build yet. MVP §7 release criteria: 0 checked (pre-build).

### Next session

Enter build at **Epic 0 (walking skeleton + spike)** per `implementation-plan.md`, TDD-first — see `resume-prompt.md` for the exact resume prompt.
