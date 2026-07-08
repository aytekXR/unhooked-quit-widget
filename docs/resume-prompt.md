# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v1.3 |
| Last updated | 2026-07-08 (end of Session 04) |
| Phase | Phase 1 core build — Epic 1 code-complete (E1.1–E1.4 DONE) |
| Next session objective | **Epic 1 close-out (v1.0.0 tag + CI release gate + portfolio API review), then E2.1 SwiftData store if fully done** |

---

## Where we are

**All of Epic 1 is code-complete, green, and adversarially reviewed** (see `past-prompts.md`
Sessions 03–04). `Packages/StreakEngine` holds: `StreakCalculator` (streak/money/momentum/
milestones), the ADR-7 clock guard (`sanityCheck`/`conservativeElapsedSeconds`),
E1.3 slip transitions (`applySlip`/`undoSlip`, `PendingSlipUndo`, boundary-inclusive 600s
guarded undo window, append-only debug assertion with pure `appendOnlyViolations` detector),
and E1.4 Reduce adherence (`adherence(for:in:allowancePerDay:timezone:)`, whole-day
evaluation, half-open day membership, `startOfDay`-re-anchored boundaries surviving
midnight DST transitions). 63/63 tests green locally; llvm-cov 100% regions/functions/lines
package-wide. Two review-confirmed MAJOR bugs were fixed red-first in Session 04: the slip
instant now rides the guarded timeline (momentum can't inflate via rollback slips), and
adherence day boundaries re-anchor each step (America/Santiago-class midnight transitions).
Ratified semantics live in the Session 03 + 04 "Key decisions" — read both before touching
the engine.

## Carried technical items (do not lose)

1. **Reboot high-side sanity cap (ADR-7 gap, deliberate deferral since Session 03):**
   across a reboot the wall delta is trusted uncapped upward. The principled cap needs a
   persisted last-known-good wall reading — wire it when the Epic 2 repository lands (red
   test first: reboot + huge forward jump must NOT read `.normal`). `undoSlip` knowingly
   inherits the same fallback across reboots (pinned by test).
2. `StreakCalculating` does not expose sanityCheck / applySlip / undoSlip / adherence —
   deferred to first consumer need; ship with protocol-extension defaults (non-breaking).
3. `QuitSnapshot` synthesized Codable requires the `bestStreakSeconds` key — decide the
   payload-compatibility story when Epic 2 persistence makes it real.

## Operator-owned blockers (not agent work; carry until closed)

1. **Gate G0 rename** — blocks TestFlight/ASC/ASO/marketing only.
2. **E0.3 device measurement** — `docs/spike-panic-latency.md` on an iPhone 15-class device.
3. **Content plan** (feasibility condition #2).
4. **Drift decision:** MVP §7 "<2s 10/10" vs test-suite §1.5 "p90 < 2s".

## Next session objective (one session, definition of done below)

**Epic 1 close-out** (the items the E1 Definition of Done names, deferred by scope guard
from Session 04):

1. **Edge-case suite as a named CI release gate:** the StreakEngine package lane
   (`swift test`, Linux) becomes an explicitly named, merge-blocking release-gate job in
   `ci.yml` (test-suite §5.1; keep macOS lanes lean — repo is private, 10x minutes).
   Enforce the coverage floor mechanically in that job (llvm-cov ≥98% per test-suite §2;
   the package currently reads 100%).
2. **Portfolio API review (architecture §14):** review the whole public surface against
   Vigil/Vakit/Keeper consumption — no Unhooked-specific types, naming coherent, doc
   comments accurate. Run it as an adversarial workflow; fix only what findings survive
   verification (red test first for any behavior change).
3. **Tag `Packages/StreakEngine` v1.0.0** (annotated tag `streakengine-v1.0.0`) — only
   after 1–2 are green and pushed.

**If — and only if —** all three land green with CI verified, enter **E2.1** (single
CloudKit-mirrored SwiftData store in the App Group, `implementation-plan.md` E2.1,
strictly test-first; simulator-dependent tests run in the macOS CI lane per the
session-rules environment note). E2.1 red tests are named in the implementation plan;
remember the carried reboot-cap red test belongs to the repository work (E2.2-ish) —
do not start it without its failing test.

Scope guards: no UI, no paywall, no widget work; StreakEngine behavior changes only via
red→green with the coverage bar held; never weaken a QA assertion.

---

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (working title "Unhooked",
> Gate-G0 rename pending — placeholder IDs stay). Epic 1 (E1.1–E1.4) is done, green,
> 100%-covered, and adversarially reviewed; local Swift toolchain lives at
> `~/.local/share/swiftly` (`. ~/.local/share/swiftly/env.sh`). Read
> `docs/session-rules.md`, `docs/implementation-plan.md` (Epic 1 DoD + E2.1),
> `docs/architecture.md` §4/§14/ADR-3/ADR-7, `docs/test-suite.md` §2/§5.1/§7, and the
> Session 03 + 04 entries in `docs/past-prompts.md` (ratified semantics + carried items)
> before writing anything.
>
> **This session: close out Epic 1** — (1) make the StreakEngine package lane a named,
> merge-blocking CI release gate with a mechanical ≥98% coverage floor; (2) run an
> adversarial portfolio API review of the package surface (Vigil/Vakit/Keeper per
> architecture §14) and land only verified findings, red-first for behavior; (3) tag
> `streakengine-v1.0.0`. Only if all three are green and CI-verified, continue into
> **E2.1** (SwiftData store, test-first, macOS CI lane).
>
> **At session end:** append the Session 05 entry to `docs/past-prompts.md`, overwrite
> `docs/resume-prompt.md` with the next objective (Epic 2 continuation per `roadmap.md`),
> commit, push, and verify GitHub Actions is green (`gh run watch`). Fix small CI issues
> immediately; document large ones and put them at the top of the next resume prompt.

## Standing rules reminders (do not relearn these)

- No shame copy; no medical claims; no red anywhere in UI; discreet variants mandatory.
- Analytics via the closed `AnalyticsEvent` enum only; zero events before opt-in;
  `logSlip` stays synchronous-local.
- Monotonic fields (`bestStreakSeconds`, `totalCleanSeconds`) never decrease — undo is
  the ONE sanctioned exemption (§9 rule 3); streaks freeze, never inflate (ADR-7).
- Panic path stays thin (ADR-6). Single CloudKit-mirrored SwiftData store; no accounts,
  no backend (ADR-2). Never register placeholder IDs with Apple; never weaken a QA
  assertion; TDD red first, always (test-suite §7).
- StreakEngine ratified semantics (Sessions 03–04): zero-tracked momentum = 1.0;
  boundary-inclusive milestones; cumulative clean numerators; momentum's denominator —
  and the slip instant — ride the guarded timeline; momentum unchanged in the same tick
  across a slip; one reversible slip at a time; whole-day adherence evaluation with
  half-open membership and re-anchored day boundaries; uptime readings must be
  sleep-inclusive monotonic.
