# Operator Expected — the live "what only aytek can do" checklist

| Field | Value |
|---|---|
| Status | LIVE — updated at every session close (operator request, Session 10) |
| Last updated | 2026-07-10 (Session 11 close: E4.1 design ratified + red WIP committed; Session 12 completes E4.1) |
| Rule for agents | Update this file at session end alongside `resume-prompt.md`. It is TRACKED (in `docs/`) so the operator can read it anywhere on the go. The untracked root `OPERATOR-TODO.md` is now just a pointer here. |

Nothing below blocks the next session (E4.1). Items are ordered by how much they
age; check a box by replacing `[ ]` with `[x]` and the next session's agent will
prune completed items.

> **Session 11 outcome (2026-07-10):** E4.1 is HALF-DONE — design ratified, 33
> designed-red tests + API stubs on `main` (af00116, `[skip ci]`), **0 billed runs
> used**. The Claude subagent session limit cut the red phase short (resets 12:50am
> Berlin); Session 12 completes E4.1 with the full run budget intact. **Two things
> to know: (1)** until Session 12's red run, any code push to `main` will show ~30
> DESIGNED test failures — expected red, not a regression; docs pushes with
> `[skip ci]` are unaffected. **(2)** §3 billing headroom matters before Session 12
> (3–4 billed macOS runs: red evidence → green → snapshot refs).

## 1. E0.3 panic-latency device measurement — carried since Session 02, load-bearing

- [ ] Run the harness in `docs/spike-panic-latency.md` on an **iPhone 15-class
      physical device** with full Xcode; record the numbers in that doc (~30 min).
      It is the ONLY remaining blocker on wiring E3's permanent latency CI gate —
      and since Session 10 it measures the REAL panic flow's first frame.
- [ ] With the numbers, settle the wording drift: MVP §7 "<2 s, 10/10" vs
      test-suite §1.5 "p90 < 2.0 s" (one-line edit to the losing doc).
- [ ] While on the device (optional, ~5 min): feel-pass the 4-7-8 haptic rhythm in
      the real panic flow — input for E5's haptics-only settings work.

## 2. Content tone review — priority bumped in Session 10

- [ ] `panicScript.json` now SHIPS in TestFlight builds (bundled in Session 10 —
      every string in the panic flow renders from it). Review that ONE file's tone
      against the brand kit voice; it gates TestFlight-visible copy now, not just
      ship.
- [ ] **Queued for Session 12:** `slipCopy.json` gets bundled when E4.1 goes green
      (the slip flow renders from it) — its tone review then joins the
      TestFlight-visible gate too. It also gains ONE new agent-drafted line,
      `confirm.retryNote` (shown only when the durable write fails; must stay calm
      and zero-shame) — review that line with the file.
- [ ] Pre-ship (unchanged): clinician/legal pass on `safetyCopy.json`; verify the
      flagged helplines; TR L10n review (`App/Resources/Content/REVIEW.md`).

## 3. GitHub Actions billing headroom — ~2 min per session

- [ ] Session 11 used **0** billed runs (the WIP commit deliberately carries
      `[skip ci]` — an incomplete red suite would have wasted the run). Session 12
      needs 3–4 (red evidence → green → snapshot refs). Check
      Settings → Billing → spending limit before the session.
- [ ] Optional, would eliminate the wasted-run class entirely: a cheap self-hosted
      macOS runner or a pre-push `xcodebuild -quiet build` step.

## 4. TestFlight housekeeping — carried from Sessions 07–09

- [ ] Add internal testers (nobody receives builds until a tester group exists —
      the panic flow is now genuinely worth testing).
- [ ] Expire the stray bundle-version-"1" build; answer export compliance only if
      App Store Connect prompts.

## 5. Slack webhook rotation — optional hygiene, ~5 min

- [ ] CI reads `secrets.SLACK_WEBHOOK_URL`; the old URL briefly sat in local git
      history. Rotate when convenient.

---

## Decisions on record you can veto (FYI, no action needed)

- **Discreet quits keep VERBATIM motivations in the pre-cache** (labels stay
  stripped) — Session 10 ruling on the Session 09 privacy question. The new
  write buffer uses the stricter `.completeUntilFirstUserAuthentication` file
  protection; the same class is recommended for `panic-snapshot.json` once E6
  decides whether widgets read it. Veto before E5.2 if you want discreet
  motivations minimized instead.
- **The slipped panic exit parks on a labeled placeholder** until E4.1 (next
  session) replaces it with the real slip flow.
- **Redirect menu ships the JSON's 4 options** (no "journal one line" row — that
  affordance belongs to the slip/journal epics; ratified override, not drift).
- Cold panic launches are attributed `.lockscreenWidget` until E3.3 lands true
  per-source attribution.
