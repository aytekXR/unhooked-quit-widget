# Critical Path — Post-UIR: the operator's launch playbook

| Field | Value |
|---|---|
| Document | Post-UIR critical path (created Session 41, 2026-07-19; synced Session 42; **synced Session 43** — a 16-agent runbook-fidelity sweep corrected step 7's G0 overstatement (the domain + bundle identity are already registered; only trademark/name clearance is open) and its broken `roadmap.md §Naming` anchor; the 11-step path + open-decisions table below are otherwise unchanged) |
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
| 7 | **G0 rename clearance** — App Store name search + USPTO trademark knockout. NOTE: G0's technical half is already DONE (`AppIdentifiers.swift:6` — CLEARED 2026-07-08): the domain `beyondkaira.com` is owned and the bundle identity `com.beyondkaira.ballast` (+ widget App ID, App Group, iCloud container) is registered in the Apple Developer portal (Team `UH7MXG7Z94`). Only the **trademark / App-Store-name legal clearance** is open; after it clears, finalize the ASO/marketing identity (store name/subtitle/keywords) | [F] | screenshots, ASO, marketing copy, submission | `submission-checklist.md` (App Review readiness), `roadmap.md` (the "Naming note (hard gate)" blockquote near the top) |
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
3. **The "Support & resources" row** — a Button whose icon+title must co-scale at accessibility sizes. Across the 5 S40 runs the failure ping-ponged: `Label(...)` **truncates** (`.textClipped`, even with `.lineLimit(nil)` + `.fixedSize` — runs 1, 5); an `HStack{Image;Text}` clears the clip but reads **"Dynamic Type partially unsupported"** (runs 3, 4); a plain `Text` passes both but isn't a Button. This is a genuine Button + wrapping-title Dynamic-Type conflict that CI can only report pass/fail on — it needs Xcode's Accessibility Inspector to pin the exact failing content-size interactively.
   - **CORRECTION (Session 42 audit — supersedes the S41 "R41.1" note):** the S41 claim that a hidden-icon candidate was *untried* is **factually wrong.** S40 **run 3 (`fc2b68a`) and run 4 (`bfe36ee`) both hid the resources-row icon** with `.accessibilityHidden(true)`, and run 4 was essentially the exact R41.1 shape (hidden icon + full-width `.fixedSize` scalable `Text`) — it **failed** with "Dynamic Type partially unsupported." So "hide the icon like `iconRow`" is a **known-failed** shape, not the fix. Do NOT burn a CI run re-trying it.
   - **The ONE structurally-untried variant (try in the Inspector, not on CI):** the *exact* `iconRow` ordering — `Button { … } label: { HStack { Text(copy.resourcesRowLabel); Spacer(); Image(systemName: "lifepreserver").accessibilityHidden(true) }.contentShape(Rectangle()) }` — i.e. **Text leading with NO `.fixedSize`**, `Spacer()`, icon **trailing** and hidden. The difference from run 4 is icon-position + dropping `.fixedSize`. It may still reintroduce `.textClipped` (the resources label is longer than the short "Default/Calendar/Timer" iconRow labels), which is exactly why it needs the Inspector, not a blind CI run. Two further Inspector candidates if it fails: (a) `Button` wrapping a **plain `Text`** with an explicit `.accessibilityLabel(copy.resourcesRowLabel)`; (b) `.accessibilityElement(children: .ignore).accessibilityLabel(...)` on the whole Button.
   - **Land the whole bundle together:** the two proven fixes (title, footer) + whichever resources-row shape the Inspector confirms + re-add the `UITEST_SETTINGS` mount (follow the `UITEST_RESOURCES`/`UITEST_DASHBOARD` precedent in `PostGateRootView`) + re-add the settings audit leg in `A11yAuditUITests.swift` (gate on `settings.resources.row`, R36.4) + record/adopt the 2 settings goldens. Budget: ~2 CI runs (after the Inspector settles the shape). **Note the visual delta needs your eyeball:** the title moves from a nav-bar large title to a free-standing one and the haptic-pacer caption moves out of its footer slot — the screen looks slightly different, so glance at it before adopting the 2 new goldens.
   - **Do not** re-attempt this on CI blindly — the S40 tail (and the Session 42 confirmation) proved CI guessing unproductive; a Mac with the Accessibility Inspector answers it in minutes.

---

## Two agent-executable items — ✅ BOTH DONE (Session 41, operator-authorized)

1. **"No account-creation path" grep lint** — ✅ LANDED. A free-Linux CI job
   (`account-absence-lint` in `.github/workflows/ci.yml`) fails the build if any shipping source
   (`App/Sources` + `Shared/Sources` + `Widgets/Sources`) imports `AuthenticationServices` or
   references `ASAuthorizationController`/`ASAuthorizationAppleIDProvider`/`SignInWithAppleButton`/
   `ASWebAuthenticationSession`. Born-green (proven pass-on-real-bytes + fire-on-mutation locally).
   Closes the explicitly-flagged `submission-checklist.md` gap. Bundled with it: the pre-existing
   `monetization-importer-lint` was NOT in the TestFlight gate's `needs:` (so it wasn't blocking the
   upload) — both lints are now in `needs:`.
2. **`ITSAppUsesNonExemptEncryption = false`** — ✅ ALREADY PRESENT (not newly added). Verified in the
   app target's Info.plist (`project.yml` → `Unhooked` → `info.properties`); the export-compliance
   question is already suppressed. The `testflight-tester-guide.md` §3 "a future session can add it"
   note was stale and is corrected.

**Session 42 follow-on (docs + CI hygiene, zero billed runs):** a 6-agent re-audit confirmed no build work
remains and fixed the agent-doable gaps it found — the stale signpost subsystem in `spike-panic-latency.md`
(your E0.3 device runbook now names the real `com.beyondkaira.ballast`), stale counts on the submission
checklist + operator-expected, the R41.1 settings note (corrected above — the "untried" candidate was
already tried and failed at S40), and two CI-plumbing hardenings (`slack-notify` now depends on the three
lint jobs so a dormant-TestFlight state can't send a false-green; `account-absence-lint` gained a
corpus-non-vacuity floor). None of this changes the sequenced path or the open decisions below.

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
