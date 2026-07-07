# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v1.1 |
| Last updated | 2026-07-08 (end of Session 02) |
| Phase | Phase 0 walking skeleton DONE (agent share) → Phase 1 core build begins |
| Next session objective | **Epic 1: StreakEngine E1.1 (+E1.2 if E1.1 is fully green)** |

---

## Where we are

**Epic 0 is code-complete and CI is green on `main`** (see `past-prompts.md` Session 02):
XcodeGen project, app + widget-extension targets (iOS 26, Swift 6 strict concurrency,
warnings-as-errors), App Group wiring with placeholder IDs (Gate-G0 sweep list in
`project.yml`), local stub packages `Packages/{StreakEngine,WidgetToolkit,PaywallKit}`,
inert `AnalyticsService` (uninhabited `AnalyticsEvent`), panic-launch skeleton
(`OpenPanicIntent` → App Group flag → thin `LaunchRouter` → `PanicPlaceholderView`,
signposted), E0 test bundle red→green through CI, and the spike harness + runbook in
`docs/spike-panic-latency.md`.

CI (`.github/workflows/ci.yml`): package `swift test` on Linux, app unit/snapshot/
UI-smoke lanes on `macos-26`, dormant secrets-gated TestFlight lane. The dev machine
is Linux — package work iterates locally (`swift test`), app-target work verifies
through CI (see `docs/session-rules.md`, Environment note).

## Operator-owned blockers (not agent work; carry until closed)

1. **Gate G0 rename** — blocks TestFlight/ASC/ASO/marketing only. After clearing:
   create IDs under the new name, sweep per `project.yml` list, provision the five
   TestFlight secrets named in `fastlane/Fastfile`.
2. **E0.3 device measurement** — run `docs/spike-panic-latency.md` on an iPhone
   15-class device; record verdict (blocks marketing copy, not code).
3. **Content plan** (feasibility condition #2).
4. **Drift decision:** MVP §7 "<2s 10/10" vs test-suite §1.5 "p90 < 2s" (both
   recorded in the spike doc).

## Next session objective (one session, definition of done below)

**E1.1 — Streak computation from anchors** (`implementation-plan.md` E1.1), inside
`Packages/StreakEngine`, strictly test-first. If — and only if — E1.1 is fully green
with its coverage bar met, continue into **E1.2 — clock-integrity guard**.

Definition of done (E1.1): the five named failing tests written and committed red
first (`test_streak_daysAndHours_fromStartAnchor`, `test_moneySaved_weeklySpendProRata`,
`test_momentum_cleanOverTotal_asPercent`, `test_nextMilestone_selectsFirstUnreached`,
`test_streak_zeroSecondsAfterFreshStart`); `currentStreak(for:now:)` returning
days/hours, money saved, momentum %, next milestone — all derived, never stored;
pure `Sendable` functions; **no `Date()` inside the package** (time injected via a
`TimeAnchor`/`ClockProvider` seam per test-suite §3.1 — this seam is E1's most
important design act); 100% branch coverage on the computation file; `swift test`
green locally AND in the Linux package lane; API keeps Unhooked-specific types out
of the public surface (architecture §14: Vigil/Vakit must be able to consume it).

E1.2 stretch (same rules): `sanityCheck(anchor:now:)` → freeze-not-inflate semantics,
the five named tests from implementation-plan E1.2 + the property test
`test_property_streakMonotonicUnderClockNoise()` with a seeded generator.

Scope guards: no SwiftData, no UI, no app-target changes beyond (if needed) linking
new package API behind the existing stub entry point; `Quit`/`Slip` SwiftData models
are Epic 2 — StreakEngine defines its own I/O-free value types (e.g. `QuitSnapshot`).

---

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (working title "Unhooked",
> Gate-G0 rename pending — placeholder IDs stay). Epic 0 is done and CI is green on
> `main`. Read `docs/session-rules.md`, `docs/implementation-plan.md` (Epic 1),
> `docs/architecture.md` §5.1/§9/ADR-7, and `docs/test-suite.md` §1.1/§3.1/§7 before
> writing code.
>
> **This session: implement E1.1 in `Packages/StreakEngine`, strictly TDD-first**
> (red tests committed and run before any implementation — the dev box has a local
> Swift toolchain; paste the red `swift test` output under a `## Red` heading in
> `past-prompts.md`). Design the injected-clock seam (`TimeAnchor`, no `Date()` in
> package code) as the first act; all math is pure, `Sendable`, Foundation-only.
> Money-saved uses `Decimal`, never `Double`. Derived values are computed, never
> stored; monotonic fields never decrease. If E1.1 is fully green with 100% branch
> coverage on the computation file, proceed to E1.2 (clock-integrity guard,
> freeze-not-inflate, property test with seeded generator); otherwise stop and
> document. Keep the package API free of Unhooked-only types (portfolio anchor).
>
> **At session end:** append the Session 03 entry to `docs/past-prompts.md`, overwrite
> `docs/resume-prompt.md` with the next objective (E1.2/E1.3 continuation or Epic 2
> entry per `roadmap.md`), commit, push, and verify GitHub Actions is green
> (`gh run watch`). Fix small CI issues immediately; document large ones and put
> them at the top of the next resume prompt.

## Standing rules reminders (do not relearn these)

- No shame copy; no medical claims; no red anywhere in UI; discreet variants mandatory.
- Analytics via the closed `AnalyticsEvent` enum only (cases land in E8.1 from MVP §5
  verbatim); zero events before opt-in; `logSlip` stays synchronous-local.
- Monotonic fields (`bestStreakSeconds`, `totalCleanSeconds`) never decrease; streaks
  freeze, never inflate, under clock rollback (ADR-7).
- Panic path stays thin: snapshot-driven, no SDK/store work before first frame (ADR-6).
- Single CloudKit-mirrored SwiftData store (Epic 2); no accounts, no backend (ADR-2).
- Never register placeholder IDs with Apple; never weaken a QA assertion; TDD red
  first, always (test-suite §7).
