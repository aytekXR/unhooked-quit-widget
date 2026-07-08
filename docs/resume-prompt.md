# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v1.4 |
| Last updated | 2026-07-08 (end of Session 05) |
| Phase | Phase 1 core build — Epic 1 CLOSED (tagged streakengine-v1.0.0); E2.1 green pushed, CI-blocked on billing |
| Next session objective | **FIRST verify commit H (E2.1 green) on CI once billing clears, then E2.2 QuitRepository (incl. the carried ADR-7 reboot-cap red test)** |

---

## ⚠️ Step 0 — blocked on operator, do this before ANY new work

**GitHub Actions is down for this repo: billing.** Run 28976762483 (commit H, ae4d34f —
E2.1 green) never started, both attempts: *"The job was not started because recent
account payments have failed or your spending limit needs to be increased."* The
operator must fix Billing & plans (payment method or Actions spending limit — note
macOS minutes bill at 10x on this private repo; this session ran three macOS lanes).

Once billing clears, the agent's first action is: `gh run rerun 28976762483` (or push
an empty commit) and verify the E2.1 green run — expected all-green; the red run
(28975932867) already empirically proved the risky parts (schema introspection API,
App Group resolution, on-disk container open at a custom URL). If the app lane is NOT
green, fixing it red-first IS the session until it is. Do not start E2.2 on top of an
unverified E2.1.

## Where we are

**Epic 1 is closed**: `Packages/StreakEngine` is tagged **streakengine-v1.0.0**
(annotated, on af5b969) with 63/63 tests green and llvm-cov 100% regions/functions/
lines; the E1 edge-case suite is a **named merge-blocking CI release gate**
(`Release gate · StreakEngine edge-case suite`, Linux, mechanical floors: lines ≥98%
package-wide, regions ≥95% on StreakCalculator.swift + SlipTransition.swift; TestFlight
lane `needs` it). The adversarial portfolio API review (architecture §14) landed six
verified findings — headline: the input type is now **`StreakSnapshot`** (renamed from
QuitSnapshot pre-tag; internal params `quit`→`snapshot`), `StreakEngine.version ==
"1.0.0"` (test-pinned both sides), platform floor iOS 18/macOS 15, and the public `///`
surface is consumer-self-contained. Ratified semantics live in Sessions 03–05 "Key
decisions" in `past-prompts.md` — read them before touching the engine.

**E2.1 (single SwiftData store in the App Group) is red→green complete in code**:
commit G (09b3a90) red CI-verified (run 28975932867, three canonical failures), commit
H (ae4d34f) green pushed but **CI-unverified (billing)**. The store: five §3 models
(CloudKit-checklist-clean, no `.unique`, everything defaulted/optional),
`PersistentStore` factory at `<App Group>/Library/Application Support/unhooked.store`,
**`cloudKitDatabase: .none` until Gate G0** (flip is red-test-first per test-suite §4.3;
never register placeholder IDs).

## Carried technical items (do not lose)

1. **Reboot high-side sanity cap (ADR-7 gap, since Session 03) — THIS session's E2.2 is
   where it lands:** the repository provides the persisted last-known-good wall reading
   the cap needs. Red test first: reboot + huge forward wall jump must NOT read
   `.normal`/inflate. `undoSlip` inherits the same fallback (pinned by test).
2. E2.1 acceptance items open by design: protection-class complete-until-first-unlock
   (device tier), §4.3 CloudKit-option instantiation (Gate G0), widget read-only open
   (device/E6). §4 indexes (`isArchived+sortIndex`, `at`, `isPendingUndo`) deferred to
   E2.2 — add them WITH the queries that justify them.
3. `StreakCalculating` doesn't expose sanityCheck/applySlip/undoSlip/adherence —
   deferred to first consumer need (protocol-extension defaults). E2.2's repository is
   likely that first consumer — if so, expose via defaults, red-first, non-breaking.
4. `StreakSnapshot` synthesized Codable requires the `bestStreakSeconds` key — decide
   the payload-compat story when persistence makes it real (repository/migration).

## Operator-owned blockers (not agent work; carry until closed)

1. **GitHub Actions billing** (NEW — blocks all CI; see Step 0).
2. **Gate G0 rename** — blocks TestFlight/ASC/ASO/marketing + the CloudKit container.
3. **E0.3 device measurement** — `docs/spike-panic-latency.md` on iPhone 15-class.
4. **Content plan** (feasibility condition #2).
5. **Drift decision:** MVP §7 "<2s 10/10" vs test-suite §1.5 "p90 < 2s".

## Next session objective (one session, definition of done below)

**Step 0 above, then E2.2 — QuitRepository** (`implementation-plan.md` E2.2, deps
E2.1 ✓ + E1.3 ✓), strictly test-first via the macOS CI lane (session-rules mechanics:
red evidence = the CI run on the red commit):

1. The implementation plan's named red tests: `test_logSlip_isSynchronous_noAwaitNoNetwork`
   (type-level + timing), `test_logSlip_persistsBeforeReturning`,
   `test_activeQuits_excludesArchived`, `test_createQuit_fourthActiveQuit_throwsLimitError`,
   `test_repositoryWrite_triggersDebouncedWidgetReload` (spy on a `WidgetRefreshing`
   protocol; single reload for a 3-write burst in 500ms).
2. **The carried ADR-7 reboot-cap red test** (item 1 above) — the repository persists
   the last-known-good wall reading and feeds the engine's guard; engine changes, if
   any, are red-first in the package with the coverage bar held (gate enforces it).
3. §4 indexes land here with their justifying queries; repository is the sole SwiftData
   importer outside trivial `@Query` lists (the E2.2 acceptance lint/grep CI check).

Scope guards: no UI, no paywall, no widget rendering; StreakEngine behavior changes
only red→green with 100% coverage held (the CI gate now enforces the floor
mechanically); never weaken a QA assertion; `logSlip` stays synchronous-local.

---

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (working title "Unhooked",
> Gate-G0 rename pending — placeholder IDs stay). Epic 1 is CLOSED and tagged
> (`streakengine-v1.0.0`); the StreakEngine CI release gate is live and merge-blocking.
> E2.1 is red→green complete; **commit H (ae4d34f) is CI-UNVERIFIED because GitHub
> Actions billing failed — Step 0 in `docs/resume-prompt.md` is mandatory before any
> new work.** Local Swift toolchain: `. ~/.local/share/swiftly/env.sh`. Read
> `docs/session-rules.md`, `docs/implementation-plan.md` (E2.2–E2.3),
> `docs/architecture.md` §3/§4/§5.1/ADR-3/ADR-7, `docs/test-suite.md` §2/§3.1/§7, and
> the Session 03–05 entries in `docs/past-prompts.md` before writing anything.
>
> **This session: verify E2.1 green on CI (Step 0), then E2.2 QuitRepository** —
> the implementation plan's five named red tests plus the carried ADR-7 reboot-cap
> red test (the repository's persisted last-known-good wall reading finally makes the
> cap implementable); §4 indexes land with their justifying queries; repository is the
> sole SwiftData importer. Test-first via the macOS CI lane; package changes red-first
> with the coverage gate held.
>
> **At session end:** append the Session 06 entry to `docs/past-prompts.md`, overwrite
> `docs/resume-prompt.md` with the next objective (E2.3 dedupe merge / E2.4 erase per
> `roadmap.md`), commit, push, and verify GitHub Actions is green (`gh run watch`).
> Fix small CI issues immediately; document large ones and put them at the top of the
> next resume prompt.

## Standing rules reminders (do not relearn these)

- No shame copy; no medical claims; no red anywhere in UI; discreet variants mandatory.
- Analytics via the closed `AnalyticsEvent` enum only; zero events before opt-in;
  `logSlip` stays synchronous-local.
- Monotonic fields (`bestStreakSeconds`, `totalCleanSeconds`) never decrease — undo is
  the ONE sanctioned exemption (§9 rule 3); streaks freeze, never inflate (ADR-7).
- Panic path stays thin (ADR-6). Single CloudKit-mirrored SwiftData store; no accounts,
  no backend (ADR-2). Never register placeholder IDs with Apple; never weaken a QA
  assertion; TDD red first, always (test-suite §7).
- StreakEngine ratified semantics (Sessions 03–05): zero-tracked momentum = 1.0;
  boundary-inclusive milestones; cumulative clean numerators; momentum's denominator —
  and the slip instant — ride the guarded timeline; momentum unchanged in the same tick
  across a slip; one reversible slip at a time; whole-day adherence evaluation with
  half-open membership and re-anchored day boundaries; uptime readings must be
  sleep-inclusive monotonic; the input type is `StreakSnapshot` (no consumer-domain
  nouns in the package surface); package doc comments stay consumer-self-contained.
- E2.1 store rules: no `@Attribute(.unique)` ever (CloudKit checklist, mechanically
  tested); `cloudKitDatabase` stays `.none` until Gate G0, and the flip is
  red-test-first (§4.3); `Date()`/`ProcessInfo` remain banned in production code.
