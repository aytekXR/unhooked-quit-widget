# Critical Path — Post-UIR: the operator's launch playbook

| Field | Value |
|---|---|
| Document | Post-UIR critical path (created Session 41, 2026-07-19) |
| Status | LIVE — the single-page "what do I do next, in what order" for the operator. Everything here is human/operator/device/legal work; there is no remaining agent build work (see the bottom section). |
| Companion docs | `operator-expected.md` (the detailed live checklist — this doc sequences it), `copy-pass-checklist.md` (the file-by-file §3 copy pass), `golden-batch.md` (the final screenshot re-record), `submission-checklist.md` (MVP §7 wired to evidence), `review-notes.md` (paste-ready App Review notes) |
| Rule for agents | This doc is a synthesis of existing docs — keep it in sync when the underlying items change; never let a step here contradict `operator-expected.md`. |

---

## Where we are (one paragraph)

The whole **build side is agent-complete** — the pre-UIR functional app (Sessions 0–31) and the UI Reactor visual regeneration (Sessions 32–40) are both done. Every screen is on the design system, 8 screens carry Apple's on-every-merge accessibility audit, both executables ship their required-reason privacy manifests, all CI lanes are green, 107 snapshot goldens are stable, and internal TestFlight is live. **Session 41 was a docs/handoff-hardening pass** (this doc, `copy-pass-checklist.md`, and correctness fixes to `review-notes.md`), not a feature session. **There are no more agent build sessions to run.** Everything below requires you (or counsel / a physical device / an App Store Connect account). One UIR polish item is parked as **Mac-gated** (the settings-screen accessibility audit — see its section below); it is optional and does not block submission.

---

## The sequenced path (today → submission)

Steps are ordered by dependency. Owner tags: **[F]** founder · **[C]** counsel/legal · **[D]** physical device · **[K]** SaaS keys/console · **[A]** agent (only after you unblock it). Time estimates are rough.

| # | Step | Owner | ~Time | Unblocks | Reference |
|---|---|---|---|---|---|
| 1 | **§3 copy pass** — read and finalize every DRAFT string, file by file; make the open copy decisions | [F] | 3–4 h | the final golden batch; clinician/counsel gates | `copy-pass-checklist.md`, `operator-expected.md` §3 |
| 2 | **Open decisions** — settle the pre-launch calls (OQ-1, OQ-2, review-build posture, ratifications, ALO-182) | [F]/[C] | with step 1 | ASC entry; a few re-pin runs | "Open decisions" table below |
| 3 | **Device sitting #1** (~1 h, one build) — the carried §7 device rows + **E0.3 panic-latency measurement** + the new **streak-ring animation glance** + eyes-free/VoiceOver + safety-layer eyeball + re-add the "Streak" widget | [D] | the release-criteria device boxes; the marketing-copy latency verdict | `operator-expected.md` §7, `spike-panic-latency.md` |
| 4 | **§8 keys** — paste in order: **RevenueCat** (wakes monetization) → **Superwall** (A/B) → create **ASC products + the win-back promotional offer + upload the In-App Purchase Key** → **TelemetryDeck app ID** (+ salt decision) | [K] | the sandbox matrix; the payload audit; live funnel data | `operator-expected.md` §8 |
| 5 | **Device sitting #2** — the **sandbox purchase matrix** (trial start, trial→paid, monthly, restore, cancellation, on-update regression) — needs the RC key live | [D] | Epic 7 DoD | `operator-expected.md` §8, `submission-checklist.md` (Monetization) |
| 6 | **§8 payload/MITM audit** — proxy-inspect the wire: zero events before opt-in, only §5 properties — needs the TelemetryDeck app ID in a build | [D] | Epic 8 DoD half | `payload-audit.md` |
| 7 | **G0 rename clearance** — App Store name search + USPTO knockout + domain; then the bundle/ASO identity | [F] | screenshots, ASO, marketing copy, submission | `roadmap.md` §Naming, `submission-checklist.md` (App Review readiness) |
| 8 | **Screenshots + preview video** — shot #1 = lock-screen panic; preview = lock→intervention; needs the cleared name in-frame + the final golden batch minted (post copy pass) | [F]/[D] | the ASC store listing | `golden-batch.md`, brandkit §9.2 |
| 9 | **Legal riders** — make the paywall Terms/Privacy links **functional URLs**; publish the privacy-policy text; **clinician + counsel sign-off** on `safetyCopy.json`; ratify the **OQ-2 habit-category taxonomy** | [C]/[F] | the ASC label entry; the safety-copy ship gate | `review-notes.md` §3, `app-privacy-label.md` |
| 10 | **External beta** — recruit ≥15 testers across the 3 personas (vape/porn/alcohol); crash-free ≥99.5% over ≥1 week; unblocked from the build side NOW | [F] | the beta-hardening gate | `testflight-tester-guide.md`, `roadmap.md` §3 |
| 11 | **ASC final entry + submit** — App Privacy label rows, metadata (name/subtitle/keywords/description), 17+ rating, paste the review notes, submit; budget 1–2 review rounds | [F] | LAUNCH | `submission-checklist.md`, `app-privacy-label.md`, `review-notes.md` |

**Parallelism:** steps 1–2 (copy + decisions) and 7 (G0) can run at the same time and are the two longest-lead items — start both first. Step 10 (beta) can start from any clean build in parallel with everything. Steps 3→5→6 are a device/keys chain. The golden batch (part of step 8) waits only on step 1.

**Do this week:** the **§3 copy pass** — it is the longest-lead item and gates the golden batch, which gates screenshots, which gate submission.

---

## Open decisions you must make (settle during step 1–2)

Each is a judgment call an agent deliberately did not make for you. "Consequence if you do nothing" tells you what ships by default.

| Decision | The call | If you do nothing (default) | Owner | Ref |
|---|---|---|---|---|
| **OQ-1 — displayLabel** | Keep the in-app words "Porn"/"Weed", or switch to the clinical "Adult content"/"Cannabis" (Brand wants clinical; a brand-signed test currently pins the words) | Current words stand; changing them is one agent re-pin run | [F] | operator-expected §3 veto list |
| **OQ-2 — habit-category taxonomy** | The App Privacy label's health-category classification (counsel call); flows lockstep to the manifest + label doc | Blocks the ASC label entry until decided | [C] | `app-privacy-label.md`, review-notes §3 |
| **R24.9 — 3.1.2 review-build posture** | Point the review build at the **teaser** variant (has the "look around for a day" escape) or defend the **hard wall** (no close) in the review notes | Must be decided before submission | [F] | review-notes §3 item 1 |
| **Keys at submission** | Submit with RC/Superwall keys **live** (reviewer sees the paywall) or explain the dormant-gating in the notes | A no-keys build never shows a purchase screen | [F] | review-notes §3 item 2, submission-checklist blockers |
| **Win-back in-app-only** | Ratify that v1.0 ships the win-back offer in-app only (no notification) | Ships in-app-only (R26.5) | [F] | mvp §6, operator-expected §3 |
| **Teaser vocabulary** | Ratify the two MVP §5 vocabulary deviations the teaser introduced | Current strings stand | [F] | operator-expected §3 |
| **Alcohol-notice dashboard-mount gap** | Accept that a hard-walled non-converter never reaches the dashboard, so never meets the alcohol notice (or change the mount) | Accepted as-is | [F] | operator-expected §3 veto |
| **ALO-182 Turkish helpline** | Verify the Turkish crisis line against an official source (Sağlık Bakanlığı) and flip `verified: true` in `helplines.json` | The row never renders (unverified rows are suppressed) | [F] | operator-expected §3, `helplines.json` `_meta` |
| **E0.3 latency verdict** | After device sitting #1: if 10/10 cold taps < 2000 ms, "<2s" becomes marketing copy; else copy degrades to "fast" | Blocks marketing copy only, not the build | [D]/[F] | `spike-panic-latency.md` |
| **Terms/Privacy links** | Supply the real Terms and Privacy URLs (paywall renders them as labels today) | Apple Schedule 2 requires functional links before submission | [C]/[F] | review-notes §3, `paywallCopy.json` |

---

## The settings-content accessibility audit (parked — Mac-gated, OPTIONAL)

The one UIR polish item that could not be finished on CI. **It does not block submission** (the settings screen ships exactly as you last saw it; the other 8 screens' audits are on and passing). Do it in a **Mac session** if/when convenient.

**State (from the S40 5-run CI enumeration):** two of three defects are fixed and known-good; the third needs Xcode's Accessibility Inspector.

1. **Title** — fixed: a free-standing `.largeTitle` `Text` ABOVE the List (never a nav-bar title or List row, both of which clip at the largest text sizes). *Proven.*
2. **Long section footer** (haptic-pacer caption) — fixed: moved OUT of the List `footer:` slot (whose height iOS caps) into a self-sizing content row. *Proven.*
3. **The "Support & resources" row** — a Button whose icon+title must co-scale at accessibility sizes. `Label(...)` truncates; an `HStack` with a *visible* icon reads "Dynamic Type partially unsupported"; a plain `Text` passes but isn't a Button.
   - **Untried candidate to try FIRST (Session 41 audit finding):** apply the icon-picker's *passing* pattern — `Button { … } label: { HStack { Image(systemName: "lifepreserver").accessibilityHidden(true); Text(copy.resourcesRowLabel).lineLimit(nil); Spacer() }.contentShape(Rectangle()) }`. The `iconRow` in this same screen (`DiscreetSettingsView.swift:188`, the `.accessibilityHidden(true)` at :203) passes the full audit precisely because its decorative image is hidden from the accessibility tree, leaving the Button's label pure scalable text. **None of the 5 S40 runs hid the resources-row icon.** Verify with the Accessibility Inspector (or one confirm CI run) before landing.
   - **Land the whole bundle together:** the two proven fixes + the resources-row fix + re-add the `UITEST_SETTINGS` mount (follow the `UITEST_RESOURCES`/`UITEST_DASHBOARD` precedent in `PostGateRootView`) + re-add the settings audit leg in `A11yAuditUITests.swift` (gate on `settings.resources.row`, R36.4) + record/adopt the 2 settings goldens. Budget: ~2 CI runs.
   - **Do not** re-attempt this on CI blindly — the S40 tail proved CI guessing unproductive; a Mac with the Accessibility Inspector answers it in minutes.

---

## Two agent-executable items awaiting your "say the word"

Both are safe and low-risk, but each costs ~1 billed macOS CI run to land+verify (any code/config change triggers the full workflow), so they are held for your go-ahead rather than spent unilaterally. Neither blocks submission.

1. **"No account-creation path" grep lint** — a free-Linux CI job that scans `App/Sources` + `Shared/Sources` for `AuthenticationServices`/`ASAuthorizationController`/`SignInWithAppleButton`/`ASWebAuthenticationSession` and fails if any appear. Born-green (no such imports exist). Closes the explicitly-flagged gap in `submission-checklist.md` ("no standing grep gate keeps 'no account creation path' true forever"). Also worth bundling: add the monetization-importer lint to the TestFlight job's `needs:` list so that existing gate is actually blocking.
2. **`ITSAppUsesNonExemptEncryption = false`** in the generated Info.plist (via `project.yml`) — removes the export-compliance question at every TestFlight upload. Noted as agent-doable in `testflight-tester-guide.md` §3.

Say the word on either and an agent lands it in one run.

---

## What is genuinely DONE (the floor you're standing on)

So you know what you do *not* have to worry about:

- **Every screen** regenerated onto the design system; **8 screens** under Apple's accessibility audit (age gate, quiz, summary, dashboard, panic, slip, resources, paywall), all passing.
- **StreakEngine / WidgetToolkit / PaywallKit** built and unit-covered; **121 free-lane tests** green; all lint gates clean.
- **Monetization** (RevenueCat + Superwall + win-back) built and **dormant behind your keys** — pasting a key is the only step, zero further code.
- **Analytics** (typed event enum, opt-in consent, zero-before-consent) built; **privacy manifests** shipped for both executables; the **App Privacy label** and **review notes** drafted.
- **Safety layer** (resources/helplines, alcohol notice, age gate) live; the metadata/lexicon lints gate every merge.
- **107 snapshot goldens** stable; the final onboarding+paywall batch is the ONLY re-record left, and it waits on your copy pass (`golden-batch.md`).
- **Internal TestFlight** live; CI auto-uploads every green `main`.
