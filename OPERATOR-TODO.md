# Operator TODO — as of Session 07 close (2026-07-09)

> **Operator-local file. Do NOT commit** — deliberately untracked so it can live
> across sessions without touching the repo history. (Future build agents: leave
> this file alone; it is the operator's personal checklist, not project docs.)
> Source of truth for the project itself stays `docs/` — this is just the
> "what only aytek can do" extract so you can work in parallel with Session 08.

Nothing below blocks Session 08 (E2.4 one-tap erase). Items are ordered by
usefulness-soon.

## 1. TestFlight housekeeping (App Store Connect) — ~10 min

- [ ] **Add internal testers** (App Store Connect → Ballast - Quit → TestFlight →
      Internal Testing): builds upload on every green merge now, but nobody
      receives them until a tester group exists. Add yourself at minimum.
- [ ] **Expire/ignore the stray build "1"**: the XcodeGen bundle-version bug
      (fixed in Session 07, commit 2a46abc) made the first-ever upload carry
      bundle version `1`. Real builds are **0.1.0 (23)** and **0.1.0 (24)**.
      Expiring build 1 keeps the list clean; harmless either way.
- [ ] **Export compliance**: only if ASC prompts — answer "no non-exempt
      encryption" (the app already declares `ITSAppUsesNonExemptEncryption:
      false`, so a prompt is unlikely).

## 2. GitHub Actions billing headroom — ~2 min

- [ ] Check Settings → Billing → spending limit. Session 07 ran **5 billed macOS
      runs** (private repo bills macOS at 10×); heavy TDD sessions run 4–6.
      Session 05 once died at the finish line on a spending-limit block — a
      quick headroom check before Session 08 avoids a repeat.

## 3. Slack webhook rotation (optional hygiene) — ~5 min

- [ ] The old incoming-webhook URL briefly sat in local git history (Session 06,
      before the push-protection rewrite). CI reads `secrets.SLACK_WEBHOOK_URL`
      now, so rotating is optional but cheap: create a new webhook in Slack,
      then `gh secret set SLACK_WEBHOOK_URL`, then delete the old webhook.

## 4. E0.3 panic-latency device measurement — needs hardware + Xcode

- [ ] Run the measurement harness in `docs/spike-panic-latency.md` on an
      **iPhone 15-class physical device** with full Xcode. This produces the
      lock-to-visible cold-launch number that sets the permanent CI latency-gate
      threshold when Epic 3 starts. Record device/OS + the measured numbers in
      that doc. (Carried since Session 02; becomes load-bearing at E3.1.)

## 5. Content sign-off (before ship, not before next session)

- [ ] Clinician/legal pass on `App/Resources/Content/safetyCopy.json`.
- [ ] Verify the 3 helpline entries flagged for verification.
- [ ] TR localization review.
      Checklist + notes: `App/Resources/Content/REVIEW.md`. The content stays
      deliberately unbundled (inert) until this signs off.

## 6. One-line spec decision (whenever convenient)

- [ ] Latency wording drift: MVP §7 says **"<2 s, 10/10 runs"**; test-suite §1.5
      says **"p90 < 2.0 s"**. Pick one; the losing doc gets a one-line edit.
      Matters when the E3 latency gate is wired (test 37), not before.

---

### FYI — state you don't need to act on

- TestFlight lane is fully live: match → manual signing → gym → pilot green on
  every merge to main, behind all test gates. CI signing is read-only
  (`MATCH_BOOTSTRAP` stays deleted — never re-enable without deciding to).
- Session 08 objective is **E2.4 one-tap erase**; the agent starts from
  `docs/resume-prompt.md` alone and needs nothing from this list.
- Engine tags to date: `streakengine-v1.0.0`, `v1.1.0`, `v1.2.0`.
