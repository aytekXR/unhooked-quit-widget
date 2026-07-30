# Critical Path — Post-UIR: the operator's launch playbook

| Field | Value |
|---|---|
| Document | Post-UIR critical path (created S41; synced S42/S43/S44/S45; **substantially re-trued Session 50** — the §0 blocker resolved to (B), the parked Mac-gated accessibility item CLOSED, four already-settled rows removed from the open-decisions table (OQ-1, OQ-2, ALO-182, Terms/Privacy), and the step-3/step-4 rows updated for what S48/S48B actually measured and landed) |
| Status | LIVE — the single-page "what do I do next, in what order" for the operator. Everything here is human/operator/device/legal work. The agent workstream runs in parallel and is now the **redesign program** (`redesign/design-roadmap.md`), which you put ahead of launch in §0; it does not need you between waves, only the founder copy pass and a device glance at the end. |
| ✅ §0 ANSWERED — the redesign runs PRE-LAUNCH, and it is now the agent workstream | The S48 blocker is closed. You answered **(B)** as a direct instruction ("take all the designs live, don't wait for my approval") and waves 1–3 have landed on `main`: **wave 1** the Surfaced Breath icon set, the erase UI (QW-2), panic in-flow support (QW-10), dashboard panic priority (QW-4), the summary CTA + footer signature, brandkit tokens (QW-1); **wave 2** the widget-adoption moment with `widget_added` finally wired (ME-1 — the north-star metric has a surface), Streak Detail rendering the 43-body milestone catalog, the panic wave timer (ME-5), the Home "Today" shell; **wave 3** the Settings rebuild (ME-7) — see the settings-audit section below, which this page previously carried as *parked and Mac-gated*. **The final golden batch is DEFERRED by the redesign's own sequencing, not blocked:** re-scope it after ME-4/ME-8/ME-9 land, exactly as the roadmap's Phase 4 says ("goldens re-record once … screenshots can shoot against final UI"). The S48 banked scoping still applies minus the surfaces the waves already covered. **What the program still owes (re-trued S58):** **ME-9 LANDED in S58**, so Phase 4's build items are DONE. What is left is **QW-6** (the crest mark's first in-app appearance — a small DesignSystem primitive, not an asset task: there is no crest file, but `BRAND-GUIDELINES.md` §5 and `creative-assets.md` specify it as geometry) and **then the final batch + LB-5 screenshots**, in that order, because the batch's remaining 12 goldens are the age gate and the quiz and QW-6 rewrites the age gate. (**ME-8 landed in S53** — the `WaterlineField` primitive and the continuous quiz field; **ME-4 landed in S54** — the summary payoff, the primitive's second consumer. Two follow-ups were carved out and NAMED rather than dropped: **ME-8b** the quiz interstitials, and **ME-4b** the 24-hour risk-window band, which is OPERATOR-gated because it needs axis copy plus a decision about the four trigger tokens that carry no clock meaning.) **The ME-9 warning this row used to carry was half right and S58 corrected it by measurement:** a FULL-BLEED field on the paywall is unsafe at standard opacity because the paywall renders two translucent fills — but the fix that shipped is structural rather than geometric, because the plan cards live in a `ScrollView` and a crop measured against the screen cannot bound what scrolls under it. Opaque `surface/base` floors now sit beneath every translucent fill in the app, after which any scroll position is safe to 0.1640, 2.7× the shipped weight. (**ME-3 milestone unlock moments landed in S51** — `30beabe`, with an 11th accessibility audit leg clean on its first run.) |
| Session 58 update | **Nothing on this page changed owner, and one line on it is now more accurate.** S58 landed the internal Xcode rename (`Unhooked` → `Ballast` across the project, five targets, the scheme and the module — **bundle identifiers deliberately untouched**, so the live TestFlight app record and the RevenueCat products across 175 territories are unaffected) and **ME-9**, the paywall's Waterline band and its first six goldens. **One item on YOUR list got more urgent rather than less:** S57 established that an external TestFlight ring needs a privacy-policy URL in its Test Information, so the `ballast.beyondkaira.com` deploy now blocks the **beta** as well as submission — it is the single highest-leverage thing on this page. **A defect on this page's sibling was also fixed:** `review-notes.md`, the notes PASTED TO APPLE, cited `Widgets/Sources/UnhookedWidgetBundle.swift` as its evidence anchor for panic-control registration — a file that has not existed since S56. |
| Session 52 update | **Step 10 is now fully prepped — the beta pack is written and one real finding came out of writing it.** `docs/testflight-beta-kit.md` is new: pre-flight, paste-ready ASC fields ("What to Test", beta app description, Beta App Review notes), the tester invite, a 20-minute test script with per-persona passes, and the known-issues list. **The finding (§0.1):** RevenueCat going live in 48B changed what a *tester* meets, not just what a buyer meets — the summary CTA now routes every non-entitled user into the paywall, and with Superwall still dormant the arm is always **hard**, i.e. no close button. Nobody is permanently stuck (relaunch lands on the dashboard) and in TestFlight the purchase is free, so the intended path works — but an unbriefed tester refuses the purchase sheet and reports the app as broken, and a non-purchaser silently skips the ME-1 widget-adoption moment. Briefing costs nothing and is the recommendation; pasting the Superwall key and assigning the teaser arm is the stronger fix and is already the decided posture for the review build. Also verified against Apple: TestFlight renews **every** subscription duration once per 24 h, 6 times, then disables auto-renew — that lapse is the only free way to prove the R46.2 foreground-refresh fix. Sequencing changed: **the internal beta moved up to third in "Do next"**, because testers run on their own clock and the gate wants ≥1 week. |
| Session 50 update | **ME-7 landed, and with it the one open accessibility item on this page.** The "settings-content audit" section below had been parked since S40 as *Mac-gated — needs Xcode's Accessibility Inspector*, after seven billed runs and three reverted audit legs. The diagnosis in it was right about the symptoms and wrong about the cure: every failure happened inside a `List` row or a `Section(footer:)` slot, whose height iOS caps, so no row shape could ever have settled it — which is also why the SHORT icon-picker labels passed on the same screen while the longer "Support & resources" label did not. The redesign's own §6.11 rebuild removes the `List`, so the class is retired by construction, the audit leg is back, and a new source lint makes the regression unwritable. **The erase confirm also joined the audited surfaces** — the S49 audit had found a HIGH-severity defect there and named the reason it shipped: erase was not one of the 8 audited surfaces, so no lane could catch it. Now 10 surfaces carry the audit. **Nothing on this page needs you for that item any more; delete the Inspector session from your plans.** |
| Session 47 update | 46A found ONE device-settings defect (`Calendar.current`); **S47 treated it as a CLASS and swept the rest** — 13 adversarial agents over locale/region resolution plus crash safety. **Two more real money-path defects found and FIXED, both invisible to CI because every simulator is `en_US`:** (1) the quiz spend/limit fields render a `.decimalPad`, whose separator iOS draws from the user's Region — so a comma-decimal user typing **"12,50" had it stored as 12**, and **"0,50" as 0**, which hides the money feature app-wide, permanently (spend has no edit path); (2) a projection under ten units floored onto zero and rendered the fabricated "~$0/year" the app's own rules forbid. Also fixed: 46A's calendar lint was not actually scanning the two package files it was written to protect. **Two dimensions came back CLEAN** — crash safety, and helpline region resolution (now probe-backed evidence for the "region-aware" claim in the App Review notes). **Nothing in the sequence below changes.** Two items want the operator's eye, both in `operator-expected.md`: a free 2-minute ITMS-9105 email check (§8, first box) and the beta-tester **geography** question (§5, first box — verified helplines are US + TR only). **Step 1 being DONE is what unblocks the golden batch below; an agent can mint it on request (2 billed runs).** |
| Session 46 update | A **pre-launch defect hunt** (12 adversarial agents over the 119 shipping source files — the first session to audit the CODE rather than the plan) found and **fixed a real 17+ compliance defect**: the age gate derived its year from the DEVICE's calendar setting, so on an Islamic-calendar device the 17+ boundary admitted **16.60-year-olds**, and on a Japanese-calendar device the birth-year wheel collapsed to `-112...8`. Fixed + a permanent lint; CI green. Two dimensions (privacy/consent, app flows/concurrency) came back **clean**. One live-path monetization defect (**R46.2**) is documented and rides step 4. Nothing you must do differently — the sequence below is unchanged. |
| Companion docs | `operator-expected.md` (the detailed live checklist — this doc sequences it), **`testflight-beta-kit.md` (the initial beta sitting: pre-flight, paste-ready ASC + invite text, test script, known issues)**, `testflight-tester-guide.md` (ASC group mechanics), `copy-pass-checklist.md` (the file-by-file §3 copy pass), `golden-batch.md` (the final screenshot re-record), `submission-checklist.md` (MVP §7 wired to evidence), `review-notes.md` (paste-ready App Review notes) |
| Rule for agents | This doc is a synthesis of existing docs — keep it in sync when the underlying items change; never let a step here contradict `operator-expected.md`. |

---

## Where we are (one paragraph)

The **pre-launch functional app is agent-complete** (Sessions 0–31) and so is the UI Reactor visual regeneration (32–40). Sessions 41–45 verified that terminal state five times; 46–47 then audited the shipped CODE rather than the plan and found three real defects nobody's tests could see — a 17+ age gate riding the device's calendar (it admitted 16.6-year-olds on an Islamic-calendar device), and two money-path defects on comma-decimal locales. **Since Session 48 the agent workstream is the redesign program itself, because you answered §0 with (B).** Waves 1–3 have landed (see the header). Every screen is on the design system, **11 surfaces** carry Apple's on-every-merge accessibility audit, both executables ship their required-reason privacy manifests, all CI lanes are green, and internal TestFlight is live. **What still needs YOU is unchanged and is the whole list below** — counsel, a physical device, two published legal pages, trademark clearance, two SaaS keys, and an App Store Connect sitting. The Mac-gated accessibility item that used to sit here is **closed** (S50) — no Inspector session needed.

---

## The sequenced path (today → submission)

Steps are ordered by dependency. Owner tags: **[F]** founder · **[C]** counsel/legal · **[D]** physical device · **[K]** SaaS keys/console · **[A]** agent (only after you unblock it). Time estimates are rough.

| # | Step | Owner | ~Time | Unblocks | Reference |
|---|---|---|---|---|---|
| 1 | ~~**§3 copy pass**~~ — ✅ **DONE, Session 46.** Every copy table read and finalized; 18 string edits + 4 code fixes landed; 12 goldens re-recorded; 404 unit / 35 snapshot / 121 free-lane green | [F] | — | **the final golden batch is now unblocked** | `copy-pass-checklist.md` (closed-state record) |
| 2 | ~~**Open decisions**~~ — ✅ **DONE, Session 46.** OQ-1, OQ-2, review-build posture, keys-at-submission, 17+, both MVP ratifications, R22.10, ALO-182 and the paywall register all settled | [F]/[C] | — | ASC entry | table below (all rows now carry their decision) |
| 3 | **Device sitting #1** (~1 h, one build) — the carried §7 device rows + eyes-free/VoiceOver + safety-layer eyeball + the streak-ring animation glance + the icon eyeball + the new **Settings glance** (wave 3) + re-add the "Streak" widget. **E0.3 is now PARTLY measured (S48): the app-owned panic cost is ~104 ms** (2483 ms arm vs 2379 ms control — the raw number is XCTest's own attach handshake, not the product). What only you can measure is total lock-to-intervention, which also contains the OS's intent→spawn phase; tooling and procedure are ready in `operator-expected.md` §1. **Note the harness could never have run before S48** — the UI test target carried no bundle id, so a device run failed the build before any test executed | [D] | the release-criteria device boxes; the marketing-copy latency verdict | `operator-expected.md` §1/§7, `spike-panic-latency.md` |
| 4 | **§8 keys** — ✅ **RevenueCat is DONE (S48B): the key is in, the RC project carries the app / entitlement / all three products / an offering / the In-App Purchase Key, and all three ASC products report READY_TO_SUBMIT across 175 territories.** The R46.2 entitlement-refresh rider landed in the same run. **Still open: Superwall** (A/B; without it every build shows the bundled hard wall) and the **TelemetryDeck app ID** (+ the salt decision; until then the analytics transport is a Noop sink and zero bytes leave any build) | [K] + [A] | the sandbox matrix; the payload audit; live funnel data | `operator-expected.md` §8 |
| 5 | **Device sitting #2** — the **sandbox purchase matrix** (trial start, trial→paid, monthly, restore, cancellation, on-update regression) — needs the RC key live | [D] | Epic 7 DoD | `operator-expected.md` §8, `submission-checklist.md` (Monetization) |
| 6 | **§8 payload/MITM audit** — proxy-inspect the wire: zero events before opt-in, only §5 properties — needs the TelemetryDeck app ID in a build | [D] | Epic 8 DoD half | `payload-audit.md` |
| 7 | **G0 rename clearance** — App Store name search + USPTO trademark knockout. NOTE: G0's technical half is already DONE (`AppIdentifiers.swift:6` — CLEARED 2026-07-08): the domain `beyondkaira.com` is owned and the bundle identity `com.beyondkaira.ballast` (+ widget App ID, App Group, iCloud container) is registered in the Apple Developer portal (Team `UH7MXG7Z94`). Only the **trademark / App-Store-name legal clearance** is open; after it clears, finalize the ASO/marketing identity (store name/subtitle/keywords) | [F] | screenshots, ASO, marketing copy, submission | `submission-checklist.md` (App Review readiness), `roadmap.md` (the "Naming note (hard gate)" blockquote near the top) |
| 8 | **Screenshots + preview video** — shot #1 = lock-screen panic; preview = lock→intervention; needs the cleared name in-frame + the final golden batch minted (post copy pass) | [F]/[D] | the ASC store listing | `golden-batch.md`, brandkit §9.2 |
| 9 | **Legal riders** — make the paywall Terms/Privacy links **functional URLs**; publish the privacy-policy text; **clinician + counsel sign-off** on `safetyCopy.json`; ratify the **OQ-2 habit-category taxonomy** | [C]/[F] | the ASC label entry; the safety-copy ship gate | `review-notes.md` §3, `app-privacy-label.md` |
| 10 | **Beta testing** — internal first (~10 min to set up, no Apple review), then external: recruit ≥15 testers across the 3 personas (vape/adult content/alcohol); crash-free ≥99.5% over ≥1 week. **Unblocked from the build side NOW, and the whole pack is written**: `testflight-beta-kit.md` carries the pre-flight (§0), the paste-ready ASC + invite text (§1–§2), the 20-minute test script (§3), and the known-issues list (§4). **Read §0.1 first** — the close-free paywall is the one thing that can stall an unbriefed sitting | [F] | the beta-hardening gate | **`testflight-beta-kit.md`**, `testflight-tester-guide.md`, `roadmap.md` §3 |
| 11 | **ASC final entry + submit** — App Privacy label rows, metadata (name/subtitle/keywords/description), 17+ rating, paste the review notes, submit; budget 1–2 review rounds | [F] | LAUNCH | `submission-checklist.md`, `app-privacy-label.md`, `review-notes.md` |

**Parallelism:** step 7 (G0 trademark clearance) is now the longest-lead item and has no dependencies — start it today. Step 10 (beta) can start from any clean build in parallel with everything. Steps 3→4→5→6 are a device/keys chain. The golden batch (part of step 8) was gated on step 1 and is now **unblocked** — an agent can mint it whenever you want it.

**Do next, in this order:**
1. **Send the clinician + counsel package** (operator-expected §3) — it is now the only external gate whose clock you do not control, and the copy inside it is final.
2. **Start G0 trademark clearance** (step 7) — same reason: someone else's clock.
3. **Open the internal beta** (step 10, ~10 min + invites) — third on this list for the same reason as 1 and 2: **testers run on their own clock**, the gate wants ≥1 week of data, and every day it is not started is a day added to launch. **S56 removed the setup step entirely:** CI created the internal group `Friends` (id `60ebfad4-30e8-489c-864d-bbb0378b9194`) with `hasAccessToAllBuilds`, so every build — including the latest — is already available to it and every future build will be, structurally. It now needs nothing from you but **adding the testers** (internal groups take Users on your ASC account). The invite text, the test script and the known-issues list are already written (`testflight-beta-kit.md`). Read its §0.1 first.
4. **Device sitting #1** (step 3) — one hour clears E0.3 latency, the E3.3 matrix, and the icon eyeball.
5. **§8 keys** (step 4) — Superwall + TelemetryDeck; unlocks the A/B posture and the payload audit.
Items 1–3 are things you hand to other people, so start them today; 4–5 are an afternoon of your own. None of them block each other.

---

## Open decisions you must make (settle during step 1–2)

Each is a judgment call an agent deliberately did not make for you. "Consequence if you do nothing" tells you what ships by default.

| Decision | The call | If you do nothing (default) | Owner | Ref |
|---|---|---|---|---|
| **OQ-1 — displayLabel** | ✅ **RESOLVED S46** toward brandkit §1.2 — the clinical "Adult content"/"Cannabis". The documented scope was wrong: the words rendered on **5** surfaces, not 2, because two views called `rawValue.capitalized` and never consulted `displayLabel`, also shipping "Vape"/"Doomscroll"/"Custom". All five now read `HabitCategory.displayNoun` | Ships as resolved | — | past-prompts S46 |
| **OQ-2 — habit-category taxonomy** | ✅ **RATIFIED S46** as **Health & Fitness › Health**. Counsel may still veto; if they do, the manifest + its key-set pin move in the SAME session (lockstep) | Ships as ratified | [C] | `app-privacy-label.md` (rationale + the two rejected alternatives) |
| **R24.9 — 3.1.2 review-build posture** | Point the review build at the **teaser** variant (has the "look around for a day" escape) or defend the **hard wall** (no close) in the review notes | Must be decided before submission | [F] | review-notes §3 item 1 |
| **Keys at submission** | Submit with RC/Superwall keys **live** (reviewer sees the paywall) or explain the dormant-gating in the notes | A no-keys build never shows a purchase screen | [F] | review-notes §3 item 2, submission-checklist blockers |
| **Win-back in-app-only** | Ratify that v1.0 ships the win-back offer in-app only (no notification) | Ships in-app-only (R26.5) | [F] | mvp §6, operator-expected §3 |
| **Teaser vocabulary** | Ratify the two MVP §5 vocabulary deviations the teaser introduced | Current strings stand | [F] | operator-expected §3 |
| **Alcohol-notice dashboard-mount gap** | Accept that a hard-walled non-converter never reaches the dashboard, so never meets the alcohol notice (or change the mount) | Accepted as-is | [F] | operator-expected §3 veto |
| **ALO-182 Turkish helpline** | ⛔ **CLOSED PERMANENTLY, S46 — and this row used to say the opposite.** ALO 182 is Turkey's **hospital appointment booking line** (MHRS), per the Ministry of Health's own page; the JSON row's "Yaşam Hattı" name and its crisis-support description were both fabricated. Following the old instruction would have shipped a life-safety defect — a Turkish user in crisis reaching an appointment IVR. The row stays `verified: false` forever and carries an "ASLA verified: true YAPMAYIN" note with the evidence | The row never renders. **Correct.** | — | `helplines.json` `_meta`, past-prompts S46 |
| **E0.3 latency verdict** | After device sitting #1: if 10/10 cold taps < 2000 ms, "<2s" becomes marketing copy; else copy degrades to "fast" | Blocks marketing copy only, not the build | [D]/[F] | `spike-panic-latency.md` |
| **Terms/Privacy links** | ✅ **WIRED S46** — the paywall's dead labels are real `Link`s to `ballast.beyondkaira.com/terms` + `/privacy` (constants in `AppIdentifiers.swift`). **The remaining half is yours and is a HARD dependency: the two pages must be LIVE before submission** — a reviewer tapping through to a 404 is a rejection | Links exist but 404 until you publish | [C]/[F] | operator-expected §3, `app-privacy-label.md` |

---

## The settings-content accessibility audit — ✅ CLOSED, Session 50 (no Mac session needed)

This section stood for ten sessions as *parked — Mac-gated, OPTIONAL*, the app's one open
accessibility item. **It is done, and it did not need the Accessibility Inspector.**

**What was actually wrong.** The S40 diagnosis was right about the symptoms and wrong about the
cure. It treated the "Support & resources" row as a *Button + wrapping-title Dynamic-Type
conflict* to be solved by finding the right row shape, and five runs of candidate shapes
ping-ponged between `.textClipped` (`Label`) and "Dynamic Type partially unsupported"
(`HStack{Image;Text}`, including the hidden-icon variant at run 4, `bfe36ee`) without
converging. The shape was never the variable. **Every failure happened inside a `List` row or a
`Section(footer:)` slot, whose height iOS controls** — which is exactly why the SHORT icon-picker
labels ("Default", "Calendar style") passed on the very same screen while the longer resources
label did not, and why adding `.fixedSize` to the haptic-pacer caption did nothing (the
constraint was never the text's). No row shape can win against a capped container.

**How it closed.** The redesign's own **§6.11 Settings rebuild (ME-7)** removes the `List`
entirely — a ScrollView of themed cards, the title as a free-standing scalable `Text` carrying
`.isHeader`, every caption an ordinary in-content `Text`, every touch target built from padding
rather than a height floor. The defect class is retired by construction rather than worked
around, so:

- the `UITEST_SETTINGS` mount and the settings audit leg are back (after three reverts:
  `3053b06`/`513edcb`, `0a4bcda`/`56eb13d`, `7d861d5`/`52eafa6`);
- the **erase confirm** joined the audited surfaces too — the S49 audit had found a HIGH-severity
  assistive-activation defect there and named the reason it shipped: erase was not one of the 8
  audited surfaces, so no lane could ever have caught it. **That took the audit to 10 surfaces; S51's ME-3 leg made it 11;**
- a new **`SettingsSourceLintTests`** bans the height-capped containers (`List`, `Section`, and
  the List-only modifiers) across all shipping sources, born-green and proven by an executed
  harness. This matters because the `UITEST_SETTINGS` mount injects no repository, so it cannot
  render the Breathing caption that clipped in S39 — a lint reads every line of every file,
  including the ones no lane mounts. The ban is amendable, but only with an audit leg that
  renders the surface's longest string at AX5 first, which is the evidence nobody had in S38–S40.

**What is left for you: one 2-minute glance, and it is optional.** The screen looks different on
purpose (see `operator-expected.md` §0). Four goldens were recorded and eyeballed, two of them at
the largest accessibility size — an axis the old settings golden never had, which is why no
golden could previously have shown either the defect or its fix. Goldens still cannot tell you
whether it *feels* like a settings screen.

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
   app target's Info.plist (`project.yml` → `Ballast` → `info.properties`); the export-compliance
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

- **Every screen** regenerated onto the design system; **11 surfaces** under Apple's full 7-type accessibility audit on every merge (age gate, quiz, summary, dashboard, panic, slip, resources, paywall, **settings**, **erase confirm** — added S50 — and **milestone unlock** — added S51), all passing. The `.dynamicType`/`.textClipped` exclusion list is closed to ZERO, and the one parked accessibility item is closed too (see above).
- **StreakEngine / WidgetToolkit / PaywallKit** built and unit-covered; **121 free-lane tests** green; all lint gates clean.
- **Monetization** — RevenueCat is **LIVE** (S48B), the paywall now binds Apple's real storefront price per territory (it used to show a hardcoded $6.99/$29.99 to all 175), and purchase failures log a diagnosable reason to `os_log`. Superwall + TelemetryDeck remain dormant behind their keys — pasting a key is the only step, zero further code.
- **Analytics** (typed event enum, opt-in consent, zero-before-consent) built; **privacy manifests** shipped for both executables; the **App Privacy label** and **review notes** drafted.
- **Safety layer** (resources/helplines, alcohol notice, age gate) live; the metadata/lexicon lints gate every merge.
- **Snapshot goldens** stable and growing with the redesign (**141 on disk across 12 suites** as of S52 — counted, not quoted: `find Tests/Snapshot/__Snapshots__ -name '*.png' | wc -l`). The final onboarding+paywall batch is deferred by the redesign's own Phase-4 sequencing, not blocked — re-scope it once ME-4/ME-8/ME-9 land (`golden-batch.md` holds the banked S48 scoping).
- **Internal TestFlight** live; CI auto-uploads every green `main`.
