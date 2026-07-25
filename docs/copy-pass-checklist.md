# Copy Pass Checklist — CLOSED (Session 46, 2026-07-25)

| Field | Value |
|---|---|
| Document | Copy-pass checklist (created Session 41; **worked and CLOSED Session 46**) |
| Status | **CLOSED.** The founder worked the §3 copy pass end-to-end in one sitting: every copy table read against the brandkit voice, every flagged decision made, 18 string edits + 4 code fixes landed, 12 goldens re-recorded, all lanes green (404 unit / 35 snapshot / 121 free-lane). |
| Where the record lives | `docs/past-prompts.md` (the append-only ledger) holds the full decision-by-decision record. `docs/operator-expected.md` §3 holds the only things still OPEN — all of them external (clinician + counsel sign-off, publishing the two legal pages, two helpline re-verifications, the app-icon eyeball). |
| Kept, not deleted | Other docs cross-reference this filename. It stays as the closed-state record of what was reviewed, so a future reader can see the pass was real and what it covered. |

---

## What was reviewed (all 13 tables + the rides-along items)

| # | Surface | Outcome |
|---|---|---|
| A1 | `quizConfig.json` — 13 slots, 71 strings | ✅ 2 edits. Slider echo "Ready when you are" → **"Almost there"** (the echo answers "How ready do you feel?" in the USER's voice; the old line was the app talking to the user). Weekly-limit helper "You can change this anytime." → **"Adjust until it feels right."** — source-verified that no post-quiz weekly-limit editor exists, so the old line promised an unbuilt feature. Consent helper KEPT (the conditional "You'd share…" describes the hypothetical without nudging toward opting in). Effects step passed the medical-claims read. Free-text motivation elaboration deferred to v1.1 — build the signal first. |
| A2 | `summaryCopy.json` — 11 strings | ✅ 2 edits. Caption → **"saved in a year at this rate."** (the hero renders "/year" directly above, so the old line read "year" twice). `savingsAbsent` "Every **clean** day…" → **"Every day you hold…"** — see the "clean" ruling below. |
| B | `paywallCopy.json` — 27 strings | ✅ 3 edits + the register decision + the legal rider. See "The four biggest calls" below. |
| C1 | `panicScript.json` | ✅ 1 edit — entry title → **"Just this one wave."** See "The truncation that wasn't" below. Breath instruction accepted as-is into the clinician gate (names no technique, makes no claim). |
| C2 | `slipCopy.json` | ✅ 2 edits. `bodyNoBest` lost its leading "Logged. " (the title already renders exactly that word directly above it, so the no-prior-best path showed it twice). `encouragement[1]` moved off "clean days". |
| D1 | `safetyCopy.json` | ✅ 1 edit — "the safest way to **cut down**" → **"the safest way forward"** (+ the same fix in the degraded fallback). The old phrasing was directional medical advice: it implied tapering is the safe route, which is not true for every heavy drinker. Clinician + counsel sign-off remains OPEN — that gate is external, not a copy defect. |
| D2 | `helplines.json` | ✅ **ALO 182 corrected — the session's most important finding.** See below. `findahelpline.com` verified live (ThroughLine, 130+ countries, IASP-cited) and KEPT. |
| D3 | `ageGateCopy.json` — 8 strings | ✅ Reviewed, no changes needed. |
| D4 | `milestones.json` — 43 bodies | ✅ 3 softened for medical-claim proximity: vape 1-month "easier **breathing**" (the only phrase in the file naming a body system) → "physical effort feels a bit easier"; weed 2-week "**memory** … sharper" (memory is the most clinically-loaded word in the cannabis conversation) → "thinking feels a little clearer"; porn 1-month "more **energy**" (NoFap-superpowers adjacency) → "the hours and attention you reclaim tend to go where you actually want them". The other 40 passed. |
| E1 | `StreakWidgetStyle.swift` | ✅ 2 edits — both VoiceOver labels. See below. |
| E2 | `DiscreetSettingsCopy.swift` | ✅ Reviewed. Settings gear label KEPT as "Settings". Haptic-pacer copy passed the binding constraint (never framed as an accessibility accommodation). |
| F1 | `docs/review-notes.md` | ✅ 3 inaccurate claims corrected + all three §3 submission decisions recorded as DECIDED. |
| F2 | OQ-1 (`displayLabel`) | ✅ **RESOLVED** — see below. |

## The four biggest calls

1. **OQ-1 — RESOLVED toward the brandkit.** In-app category nouns are now "Adult content" and "Cannabis". The investigation found the documented scope was wrong: the words rendered on **5** surfaces, not 2, because `RootPlaceholderView.swift:398` and `DiscreetSettingsView.swift:222` called `rawValue.capitalized` and never touched `displayLabel` at all — so they also shipped "Vape" (not Vaping), "Doomscroll" (not Doomscrolling) and "Custom" (not "Your goal"). Only "Alcohol" was consistent across all three code paths. All five now read from ONE table, `HabitCategory.displayNoun`. The `PanicPathTests` comment calling the old nouns "brand-reviewed, clinical" was factually wrong (brandkit §1.2 designates "Adult content" AS the clinical noun) and was corrected.
2. **The paywall register — audit-safe variant kept, tightened.** Positioning is now "No account. Apple handles billing — cancel in one tap." The mvp §6 canon was NOT restored: "No server" is self-contradictory on the one screen RevenueCat brokers, and Apple refunds are requested, not one-tap. "No sign-up" was dropped as redundant with "No account". Separately, `positioningNotes` promised a **journal** — a PRD P1 feature `mvp.md:68` explicitly puts out of MVP scope. Now "Your notes and reflections never leave your device.", which describes what actually ships.
3. **The legal rider — CLOSED in code.** Terms of Use / Privacy Policy were plain `Text` labels (an Apple Schedule 2 rejection waiting to happen). They are now real `Link`s to `beyondkaira.com/terms` and `/privacy`, with the URLs as constants in `AppIdentifiers.swift`. **The pages themselves must be published before submission** — that is the one half that left the repo.
4. **The alcohol-notice safety gap — FIXED, not accepted.** The notice mounted ONLY on the dashboard, inside the store-gated subtree. A user who picks an alcohol goal, finishes the quiz and meets the HARD paywall never dismisses it, never reaches the dashboard, and so never met the withdrawal notice — and "did not convert" is uncorrelated with "does not need to know". It now also mounts on the SUMMARY, which every completer sees before the paywall. The dashboard mount stays as the fallback for anyone whose summary is already behind them; showing it twice is impossible because `recordAlcoholNoticeShown()` stamps durably at display.

## ALO 182 — the finding that inverted its own task

This checklist and `operator-expected.md` both instructed: *verify ALO 182 against an official Sağlık Bakanlığı source and flip `verified: true`.* **That instruction was wrong and following it would have shipped a life-safety defect.**

ALO 182 is Turkey's **Merkezi Hastane Randevu Sistemi** — the MHRS hospital-appointment booking line. The Ministry of Health's own page is titled "Alo 182 - Merkezi Hastane Randevu Sistemi". The row in `helplines.json` claimed the name "Yaşam Hattı" and described it as psychologist support for "ruhsal kriz … intihar düşünceleri"; both were fabricated, and the row's own source URL pointed at findahelpline.com rather than any official source. A user in crisis dialling 182 reaches an appointment IVR.

The row's name, description and source URL are corrected, it stays `verified: false` **permanently**, and it now carries an explicit "ASLA `verified: true` YAPMAYIN" note plus the evidence — so no future session repeats the error. No official single-number Turkish mental-health crisis line was found on saglik.gov.tr or turkiye.gov.tr; Turkey's safety net is 112 + YEDAM 115 + ALO 171 + the global findahelpline.com pointer.

## The truncation that wasn't

The docs said the panic entry title "Let's take this one wave at a time." *truncates* to "Let's take t…" at max Dynamic Type. The AX5 goldens show it does not — it wraps. But they showed something worse that no doc had recorded: at AX5 the four-line title pushed the **breath bloom entirely off-screen**, so a user at the largest accessibility sizes saw only text and had no visual pacer to follow — on the one screen whose entire job is "follow this". The shorter title ("Just this one wave.", 19 chars) takes two lines and the bloom is back on screen. Verified against the newly recorded `snapshot_breathStep.light-ax5.png`.

## Two VoiceOver labels

- `panicAccessibilityLabel`: "Panic — opens a full-screen **reset**" → **"Panic — opens a 90-second urge exercise"** (the brandkit §8 canonical spec, which the shipped string had drifted from with no gate catching it). "Full-screen reset" describes screen geometry and can be heard as "resets my streak" — hesitation at exactly the wrong moment.
- `panicAccessibilityLabelDiscreet`: bare "Reset" → **"Reset — opens a quick exercise"**. The discreet rule bans habit WORDS, not information density; a user who cannot see the screen needs to know what the tap starts. Still leaks nothing.

## The "clean" ruling

CI bans "clean slate" but not bare "clean". Two shipped strings used "clean day(s)" — which in AA/NA orbit is an identity statement ("I've been clean for X years"), and the quiz offers "Faith" as a motivation chip, so that audience is real. Both moved to neutral phrasing ("Every day you hold…", "your steady days over total days"). Note the resources screen still shows the word "treatment" inside the SAMHSA helpline description — that is verbatim sourced material and is correctly exempted from the lexicon gate.
