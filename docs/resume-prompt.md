# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v1.2 |
| Last updated | 2026-07-08 (end of Session 03) |
| Phase | Phase 1 core build — Epic 1 in progress (E1.1 + E1.2 DONE) |
| Next session objective | **E1.3 slip archiving + undo (+E1.4 Reduce adherence if E1.3 is fully green)** |

---

## Where we are

**E1.1 and E1.2 are code-complete and green** (see `past-prompts.md` Session 03):
`Packages/StreakEngine` now holds the pure computation core — `StreakCalculator`
(streak days/hours, Decimal money-saved, momentum fraction + percent view, milestone
selection) and the ADR-7 clock-integrity guard (`sanityCheck`/`conservativeElapsedSeconds`
over one `evaluate()`: monotonic-as-truth within a boot, freeze-not-inflate in both
directions, quarter-hour ≤14h jumps classify `.timezoneShift`, reboot falls back to
floored wall clock). Time seam: `MonotonicAnchor` (persisted) + `MonotonicNow`
(read-time) + injected `now: Date` — the docs' informal "TimeAnchor/ClockProvider"
names map to these; `ClockProvider` is app/test-side by design, not a package type.
29/29 tests green locally; llvm-cov 100% regions/functions/lines on the whole package.
Red→green discipline held throughout (commits A–G, red runs pasted in the Session 03
log). An ultracode adversarial review (28 verifiers) confirmed-and-fixed one major
latent bug (momentum denominator was unguarded under rollback) plus hardening.

## Carried technical item (address in Epic 2, do not lose)

**Reboot high-side sanity cap (ADR-7 gap, deliberate deferral):** across a reboot the
wall delta is trusted uncapped upward — reboot + forward-set clock can inflate. The
principled cap needs a persisted last-known-good wall reading; wire it when the Epic 2
repository lands (red test first: reboot + huge forward jump must NOT read `.normal`).
Marked in code at `StreakCalculator.evaluate()`'s reboot branch.

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

**E1.3 — Slip archiving, momentum preservation, 10-minute undo**
(`implementation-plan.md` E1.3), inside `Packages/StreakEngine`, strictly test-first.
If — and only if — E1.3 is fully green with its coverage bar met, continue into
**E1.4 — Reduce-mode adherence**.

Definition of done (E1.3): the six named failing tests written and committed red first
(`test_slip_archivesToBest_whenCurrentExceedsBest`, `test_slip_preservesTotalCleanSeconds`,
`test_momentum_survivesSlip_partialCredit`, `test_undo_within10Minutes_restoresExactPriorState`,
`test_undo_at10MinutesPlus1Second_returnsNil`, `test_bestStreak_neverDecreases_afterAnySlipSequence`);
`applySlip` archives current→best, restarts the counter, preserves cumulative totals
(feeds `priorCleanSeconds`/`trackedSince` — note the guarded-denominator invariant from
Session 03's momentum fix must survive); `undoSlip` restores the EXACT prior state within
the window, nil after; append-only invariants asserted (best/totalClean monotonic
non-decreasing incl. a debug-assertion path test per implementation-plan acceptance);
pure `Sendable`, no `Date()` (the undo window measures injected time only); 100% branch
coverage on new computation code; `swift test` green locally AND in the Linux package
lane; no Unhooked-specific types in the public surface. Design note: slip state likely
extends `QuitSnapshot` with trailing-defaulted fields (`bestStreakSeconds`, undo bookkeeping)
— every addition MUST keep the hand-written init's existing parameter order with defaults
(portfolio non-breaking evolution rule, Session 03 key decision).

E1.4 stretch (same rules): `adherence(for:in:)` counting allowance-adherent days, the
four named tests from implementation-plan E1.4 + the DST-transition test
(`test_reduceMode_dstTransitionDay_countsOnce()`); day boundaries in the quit's timezone
(this introduces the package's first timezone-aware math — keep it out of
StreakCalculator.swift's absolute-time core; a separate computation file with its own
100% bar).

Scope guards: no SwiftData, no UI, no app-target changes. Epic-1 close-out items
(package v1.0.0 tag, edge-case suite as named CI release gate, Vigil/Vakit API review)
land in the session that finishes E1.4 — not before.

---

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (working title "Unhooked",
> Gate-G0 rename pending — placeholder IDs stay). E1.1+E1.2 are done, green, and
> adversarially reviewed; local Swift toolchain lives at `~/.local/share/swiftly`
> (`. ~/.local/share/swiftly/env.sh`). Read `docs/session-rules.md`,
> `docs/implementation-plan.md` (E1.3/E1.4), `docs/architecture.md` §5.1/§9/ADR-7,
> `docs/test-suite.md` §1.1/§3.1/§7, and the Session 03 entry in `docs/past-prompts.md`
> (key decisions + carried items) before writing code.
>
> **This session: implement E1.3 in `Packages/StreakEngine`, strictly TDD-first**
> (six named red tests committed and run before any implementation; paste the red
> `swift test` output under a `## Red` heading in `past-prompts.md`). All slip/undo
> state is value-in/value-out — the package stays pure, `Sendable`, Foundation-only,
> zero `Date()`. Monotonic fields (`bestStreakSeconds`, `totalCleanSeconds`) never
> decrease — assert it in debug and property-test it. Extend `QuitSnapshot` only with
> trailing-defaulted init parameters. If E1.3 is fully green with 100% branch coverage
> on its computation code, proceed to E1.4 (Reduce adherence, quit-timezone day
> boundaries, DST test); otherwise stop and document.
>
> **At session end:** append the Session 04 entry to `docs/past-prompts.md`, overwrite
> `docs/resume-prompt.md` with the next objective (E1.4 completion / Epic-1 close +
> Epic 2 entry per `roadmap.md`), commit, push, and verify GitHub Actions is green
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
- StreakEngine semantics ratified in Session 03: zero-tracked momentum = 1.0;
  boundary-inclusive milestones; cumulative clean numerators; momentum's denominator
  rides the guarded timeline; uptime readings must be sleep-inclusive monotonic.
