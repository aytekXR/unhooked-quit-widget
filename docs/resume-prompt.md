# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v2.5 |
| Last updated | 2026-07-10 (Session 13 close: E3.3 COMPLETE — red `29117701445` → green `29118390046`, 2 billed runs, zero burned) |
| Phase | Phase 1 core build — Epics 0–1 CLOSED; E2.1–E2.4 + E3.1–E3.3 + E4.1 DONE; delivery 15/32 (~47%) |
| Next session objective | **Session 14: E4.2 — zero-shame copy enforcement (banned-lexicon CI gate over the centralized strings)** |

> **What changed in Session 13:** E3.3 shipped WHOLE in 2 runs — per-quit intent
> `@Parameter` (PanicQuitEntity/Query over the pre-cache, ADR-6 readers-only), TRUE
> per-source attribution (`panic.launch.source` channel, pre-frame capture, the
> `.lockscreenWidget` hardcode is DEAD), the discreet **"Reset"** control
> (`PanicControlDiscreet`, `arrow.counterclockwise`, strings unit-pinned via Shared
> `PanicControlStyle`), and the in-app entry (fourth source, placeholder-grade root
> button → `InAppPanicEntry`). ONE recorded adjustment (platform ceiling,
> docs-checked): control-family launches attribute `.controlCenter`; `.actionButton`
> stays reserved — iOS has no launch-surface API. Device matrix → operator
> (`docs/operator-expected.md` §7). Full ledger: Session 13 in `docs/past-prompts.md`.

---

## Standing tooling rules (permanent, apply to every agent)

1. **CodeGraph**: the repo is indexed (`.codegraph/`, machine-local). Query
   `codegraph_explore` (shell: `codegraph explore "<symbols or question>"`) BEFORE
   grep/find or manual reading; pass this instruction into every subagent/workflow
   prompt; check blast radius before editing public symbols. **Before the
   session-end commit: `codegraph sync` + confirm `codegraph status` clean.**
2. **Parse gate**: `swiftc -parse` every touched Swift file before every push.
3. **Access-level gate (Session 12):** scan for private types named in non-private
   signatures (`@Test` methods are internal), and `swiftc -typecheck` a scratch
   harness on the Linux toolchain for every NEW pure-Foundation API shape —
   include a USAGE-exercise file calling the new API the way the tests will
   (the Session-13 refinement that caught signature drift for free).
4. **Docs-check gate (Session 13 refinement):** every Darwin-only / AppIntents /
   SF-Symbol member spelling gets verified against Apple docs (the
   `developer.apple.com/tutorials/data/...json` endpoints work headlessly) BEFORE
   the code is written — this is what made Session 13 zero-burn. Never answer SDK
   questions from memory.
5. Docs-only commits carry `[skip ci]`; never spawn agent workflows for docs-only
   changes (operator rule). Subagent structured outputs need hard size caps or
   Write-to-file returns (three Session-13 readers died on the retry cap).

## Where we are

- **StreakEngine 1.2.0** — untouched since Session 07; E4.2 needs ZERO engine work.
- **E3.3 is DONE and green** (`29118390046`): both intents carry the quit
  `@Parameter`; `PanicLaunchFlag` has the 3-key launch instruction
  (requested/quitID/source; `clear()` sweeps all three); source threads
  UnhookedApp → PanicPlaceholderView → PanicFlowView → model → UrgeEvent;
  `PanicControlStyle` (Shared) is the single source of truth for both control
  kinds' strings; `InAppPanicEntry` is the in-app seam; the walking-skeleton root
  now has "Panic" + slip-entry surfaces. Widgets bundle registers SkeletonWidget +
  PanicControlWidget + PanicResetControlWidget.
- **Copy inventory for E4.2**: bundled content lives in
  `App/Resources/Content/` — `panicScript.json`, `slipCopy.json`, `safetyCopy.json`
  (+ `REVIEW.md` tracking operator tone review). UI strings also live inline in
  views (slip banner "Slip logged. Undo?", forgiveness copy is slipCopy-driven,
  root placeholder rows). E4.2 centralizes the SLIP/RELAPSE strings into one
  audited table and gates them.
- **TestFlight: LIVE**, carrying panic → slip → undo + the new entry-point matrix.
  CI signing read-only; never re-enable MATCH_BOOTSTRAP. macOS CI minutes bill 10x.
- Brand kit stays load-bearing: no red anywhere; no shame lexicon; discreet
  variants neutral; motivations VERBATIM in user order.

## Next session objective (one session, definition of done below)

**Session 14 — E4.2 zero-shame copy enforcement** (implementation-plan row,
verbatim goal): every slip/relapse string passes the no-shame checklist; copy
centralized in one audited strings table.

1. **Red first** (billed run 1): the named test
   `test_slipStrings_containNoForbiddenLexicon()` — a unit test scanning the
   centralized strings table against a banned-word/phrase list ("failed",
   "ruined", "back to day 1", etc. — derive the list from the brandkit no-shame
   checklist + MVP §7, and pin the LIST ITSELF so it can only grow). Add pins
   that the table is COMPLETE (every slip-flow-rendered string comes from it —
   e.g. a reflection/altitude pin over SlipCopy + the inline slip strings the
   audit finds).
2. **Green** (billed run 2): centralize whatever inline slip/relapse strings the
   audit finds into the audited table (`slipCopy.json` is the natural home; keep
   decode-tolerance discipline), make the lexicon gate pass, wire it as a
   PERMANENT unit-lane gate (it already is one by living in Tests/Unit — no
   ci.yml change needed).
3. **Acceptance**: copy-audit checklist (MVP §7) SIGNED — the human half is
   operator work: flag it in `docs/operator-expected.md`; forbidden-lexicon test
   permanent.
4. Scope guards: no analytics (E8); no engine changes; SwiftData stays inside
   `App/Sources/Persistence/**`; never weaken a QA assertion; NO new goldens
   expected (copy centralization must not change rendered output — if a string
   changes, snapshot refs would need a third run: avoid).
5. Budget: 2 billed runs. E4.2 is small — do NOT pad it with E5.1: E5.1's third
   named test needs E8.1's `AnalyticsEvent` enum. If E4.2 lands early, the right
   pairing decision (E8.1 next to unblock E5.1, per the dependency chain) belongs
   to the SESSION-END resume prompt, not mid-session scope creep.

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name **Ballast**,
> org `com.beyondkaira`). E3.3 is DONE (green `29118390046`); Session 14 = E4.2
> zero-shame copy enforcement (see the objective above). Local Swift toolchain:
> `. ~/.local/share/swiftly/env.sh`. **Standing gates:** CodeGraph query-first +
> sync at close; `swiftc -parse` every touched file; the access-level scan +
> Linux typecheck harness WITH usage-exercise file; docs-check every SDK spelling
> against Apple docs before writing code; docs-only commits `[skip ci]`, no
> workflows for docs-only work; cap subagent structured outputs.
> READ FIRST: `docs/implementation-plan.md` E4.2 row + Epic 4 DoD, the brandkit
> no-shame checklist (`docs/frontend-brandkit.md`), `App/Resources/Content/*`
> (slipCopy.json + REVIEW.md), `App/Sources/SlipFlowModel.swift` +
> `SlipFlowView.swift` + `RootPlaceholderView.swift` (where slip strings render),
> the Session 13 ledger (gates), `docs/session-rules.md`.
> **This session:** red (the named lexicon test + table-completeness pins) → THE
> red-evidence run → green (centralize strings, gate passes) → verify all-green →
> flag the human checklist sign-off for the operator. Budget 2 billed macOS runs.
> **At session end:** append the Session 14 ledger, overwrite this resume prompt
> (next objective per `roadmap.md` — likely E8.1 event enum to unblock E5.1, or
> E5.2 quiz if the operator prefers user-visible progress), update
> `docs/operator-expected.md`, `codegraph sync`, commit `[skip ci]`, push,
> `gh run watch` green.

## Operator-owned blockers (not agent work; carry until closed)

1. **E0.3 device measurement** (`docs/spike-panic-latency.md`) — STILL the only
   blocker on the permanent latency gate.
2. **E3.3 device matrix** (`docs/operator-expected.md` §7, NEW) — the operator
   half of E3.3's acceptance: lock screen / CC / Action button / in-app × Focus
   on/off, one airplane-mode pass; includes the "Reset" control gallery check.
3. **Content tone review:** `panicScript.json` + `slipCopy.json` (incl. the
   agent-drafted `confirm.retryNote`, REVIEW.md item 3) — E4.2 will ADD the
   signed copy-audit checklist to this pile.
4. TestFlight housekeeping: internal-tester group; expire the stray
   bundle-version-"1" build.
5. GitHub Actions billing headroom: Session 13 used 2 runs; Session 14 needs 2.
6. Slack webhook rotation (optional hygiene) — unchanged.

## Standing rules reminders (do not relearn these)

- No shame copy; no medical claims; no red anywhere in UI; discreet variants
  mandatory; motivations render VERBATIM in user order.
- Analytics via the closed `AnalyticsEvent` enum only (E8); zero events before
  opt-in; `logSlip` stays synchronous-local on the store-backed path.
- Monotonic fields never decrease — undo is the ONE sanctioned exemption (§9r3);
  streaks freeze, never inflate (ADR-7). `Quit.totalCleanSeconds` is BANKED-only.
- WITNESS discipline: three advance paths only; erase clears it; flush/undo never
  advance it; deferred slips apply with the SLIP-TIME witness, windows with nil.
- Erase discipline: local-first; key sweep (now 3 flag keys — the full
  `dictionaryRepresentation` sweep covers them); owned file-set sweep; cloud
  purge last.
- Panic path stays thin (ADR-6): panic surfaces NEVER open the store (the in-app
  entry reads the pre-cache even with the store warm); single-writer pre-cache
  pin; single store; no accounts (ADR-2).
- E3.3 attribution ceiling is a RECORDED ADJUSTMENT: control family →
  `.controlCenter`; `.actionButton` reserved; do not "fix" it without a platform
  API.
- Never weaken a QA assertion; TDD red first (red evidence = the CI run on the
  red commit; build failures are NOT evidence); `cloudKitDatabase` stays `.none`
  until the §4.3 flip (which must also design undone-slip tombstoning).
- Snapshot goldens: pinned in-test geometry (.iPhone13) + AX5 axis; re-record
  deliberately via the CI artifact; SnapshotTesting exact-pinned at 1.19.3.
- Carried product notes: store-route SlipFraming passes momentum/motivation nil
  (feed real values in the dashboard epic); dashboard-half slip XCUITest waits
  for the fixture-seeding session.
