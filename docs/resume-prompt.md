# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v8.0 |
| Last updated | 2026-07-26 (**Session 50 — ME-7: the Settings rebuild, and the accessibility item that had been parked for TEN sessions is CLOSED. 4 billed runs, ALL GREEN at close (`30221833229`, 10/10 jobs incl. the TestFlight upload); each run bought distinct evidence rather than a retry.** The project is no longer operator-blocked: §0 was answered **(B)** — the redesign runs before launch — and waves 1–2 landed in a parallel session, so the agent workstream is now `redesign/design-roadmap.md` itself. S50 is wave 3. **The session's real finding is that the S40 diagnosis was right about the symptoms and WRONG about the cure, and that error cost seven billed runs.** QW-9 had been attacked three times (S38 `3053b06`/`513edcb`, S39 `0a4bcda`/`56eb13d`, S40 `7d861d5`/`52eafa6`), each time hunting a row SHAPE that would satisfy Apple's audit — `Label` truncated, `HStack{Image;Text}` read "partially unsupported", the hidden-icon variant failed too — and it was finally parked as *Mac-gated, needs the Accessibility Inspector*. The shape was never the variable: **every failure happened inside a `List` row or a `Section(footer:)` slot, whose height iOS caps.** The tell had been in the ledger all along — the SHORT icon-picker labels PASSED on the same screen where the longer "Support & resources" label failed, and `.fixedSize` on the haptic caption changed nothing because the constraint was never the text's. **ME-7's §6.11 rebuild removes the `List`, so the class is retired by construction**, and the AX5 golden is the proof seven runs never got: "Add the lock-screen button" now wraps to FOUR full lines with its glyph co-scaled, where it used to truncate. **10 surfaces now carry the full 7-type audit** — settings is back after three reverts, and **erase confirm is new**, which was the S49 audit's own prescription (it found a HIGH assistive-activation defect and named the reason it shipped: erase was not an audited surface, so no lane could catch it). That defect is fixed STRUCTURALLY: `HoldToConfirmButton` chose its safe branch by reading two `@Environment` flags, an enumeration that can never be completed because **Voice Control and Full Keyboard Access are not reportable by ANY Apple API** (`accessibilityFullKeyboardAccessEnabled` → HTTP 404, confirming S49 §6's correlated-hallucination finding first-hand); `.accessibilityRepresentation` (docs JSON 200, iOS 15.0+, label `representation:` — the audit's own `content:` is a 404) replaces detection so every AT, including the unreportable ones, sees one standard Button. **THREE new born-green lints, each PROVEN by an executed Linux harness, and two of them caught real defects before they cost anything:** `SettingsSourceLintTests` (bans the height-capped containers; its harness caught a false positive — a plain-substring `Section(` matched the new file's own `discreetModeSection(`/`breathingSection(`/`yourPlanSection(` method names, which would have reddened the unit lane on a billed run); the `DiscreetSettingsCopy` lexicon harness (the plan's free check was IMPOSSIBLE — it prescribed `Packages/AppTests`, which does not exist, and a `--filter` on a test whose own header says it cannot run locally); and `UITestMountCoherenceTests`, written because **run 1's two new legs both failed at their GATE, not their audit** — `AgeGateContainerView.uiTestOnboardingMount` is a hand-maintained allow-list that is the SECOND HALF of every direct mount, and a missing entry reports a 15s timeout that blames the view. `UITEST_WIDGET_MOMENT` had been missing since wave 2 for the same reason. **Four of the plan's own load-bearing claims were overruled** — see the ledger; the most consequential was a proposed style rewrite of S46-FINAL founder-owned copy, including "Breathe with taps", which `operator-expected.md` §7 tells the operator to toggle BY NAME. Copy delta: 5 DRAFT strings, not 11. **THE AUDIT LEG EARNED ITS KEEP IMMEDIATELY: it caught a violation that would otherwise have SHIPPED.** Copy doc §11 drafts the panic-access row as "Add the lock-screen **button**" — and every settings row is a `Button`, so Apple's `.trait` audit fails it with *"Label duplicates traits"*. The word plainly meant the WIDGET's panic button, a different object, and it reads perfectly sensibly in the copy doc; it is invisible to a golden, to every free lint, and to a human review. Fixed with one word (`button` → `widget`, the truer noun anyway) and flagged to the operator as an audit-forced deviation. **The shortcut was refused:** keeping the bytes and overriding `.accessibilityLabel` would buy the green check by breaking WCAG 2.5.3 (Label in Name), so a Voice Control user saying "tap Add the lock-screen button" would stop matching the control — a11y only strengthens. A new `test_settingsRowLabels_doNotRestateAControlTrait` now states this on the unit lane in one line, because the founder pass may well try to restore the doc's wording. **RUN LEDGER: run 1** goldens recorded + the discovery that both new legs never reached their mounts (the age-gate allow-list); **run 2** mount fixed → erase leg PASSED CLEAN on its first audit, settings leg surfaced the trait violation; **run 3** violation fixed, goldens re-recorded, **all 10 legs green**; **run 4** goldens adopted, everything green. **NO operator action is required to continue; the next wave is ME-3.** Superseded S48 header below.) |
| _superseded_ | 2026-07-26 (**Session 48 — the golden batch was SCOPED END-TO-END and then deliberately NOT minted. ZERO billed runs, docs-only. THE PROJECT IS BLOCKED ON ONE OPERATOR DECISION: `operator-expected.md` §0.**) The §3 copy pass closing in 46B was exactly the trigger `golden-batch.md` had waited for since S40, so S48 opened to mint it — the last agent task on the launch path. It stopped for **two independent reasons, either sufficient.** **(1)** The operator's own `redesign/design-roadmap.md`, committed in the SAME 46B session that unblocked the batch, schedules changes to **all four** surfaces the batch covers: QW-6 crest on the age gate (Phase 2), ME-8's waterline field behind the quiz + "warmer keyboard steps (spend/custom-name)" (Phase 3), **ME-4 "Summary payoff redesign"** and **ME-9 "Paywall goldens + reachable polish"** (Phase 4) — and Phase 4's own text says goldens "re-record once … screenshots can shoot against final UI", with Phases 1–4 framed as "to launch-ready … ~7 weeks". Meanwhile `critical-path-post-uir.md`, ALSO operator-updated in 46B, says the batch is mintable now. **Two operator-authored documents disagree and only the operator can say which governs.** **(2)** The batch requires PRODUCTION seams on exactly the views the redesign rewrites — including `QuizSummaryView`, which IS ME-4. **The scoping (`wf_37cf6604-562`, 6 agents) paid for itself regardless:** it proved a CERTAIN silent failure — `QuizSummaryView` renders `.opacity(revealed ? 1 : 0)` and sets `revealed` inside `.onAppear { withAnimation { … } }`, so **every summary golden would have been a BLANK PNG**; the critic additionally caught a FATAL seam-label mismatch between two agents' proposals (would not compile, would record nothing), a fixture approach that would have left goldens GREEN when copy changed, and a scope blowup of 51 proposed goldens against a 12–20 budget (cut to **22** with per-golden rationale). **The whole mint plan is BANKED** — seams, 22-golden matrix, a two-run split isolating the one risky seam, verified-by-quote initializers, and two open risks (the age-gate UIPickerView's 122 rows may not populate synchronously; CI pins no locale/timezone) — in the S48 ledger entry and in `golden-batch.md`. **Answering §0 (A) or (C) starts the mint immediately with zero re-scoping.** Superseded S47 header below.) |
| _superseded_ | 2026-07-26 (**Session 47 — the LOCALE axis: 46A found ONE device-settings defect; S47 swept the CLASS and found two more, both in the money path. 1 billed run.** **Session-open (three commands, not an eighth plan-audit):** `git fetch` → `41cc162`, clean; CI `30173055411` SUCCESS per-job (10/10); free lanes first-hand **121 pass**; `roadmap.md` re-checked independently — **zero unchecked boxes**, Phase 4/5 post-launch-gated. **The axis:** R46.1 was treated by 46A as one bug; it is a CLASS — a device *Settings* value silently changing behaviour, invisible to a suite and 107 goldens that are always `en_US`. A hand probe confirmed the axis before any agent spend: all three money formatters leave `formatter.locale` at the device default, and the app declares **no localizations at all**. `wf_716e9226-b8c` ran **13 adversarial agents** (6 dimension finders, each required to EXECUTE a Swift probe over the exact shipping bytes rather than reason → an independent refuter per finding, default-REFUTED → a completeness critic). **6 findings → 2 actioned, 2 refuted, 2 downgraded; TWO dimensions CLEAN.** **R47.1 (FIXED):** `spend` and `allowance` are both `decimalInput`, rendering a `.decimalPad` whose separator iOS draws from the user's Region — so a comma-decimal user (most of Europe, Turkey, Brazil, Indonesia) typing **"12,50" had it stored as 12**; **"0,50" became 0**, which hides the money feature app-wide via the `spend > 0` guards on summary, dashboard AND widget; an Arabic-Indic entry became 0 outright. `weeklySpend` is written at `createQuit` and has **NO edit path**, so the wrong value is permanent. **Passing `Locale.current` is NOT the fix** — measured, `en_DE` reports `,` (the REGION drives it) but then `Decimal(string:"6.50", locale:)` is **6**, merely inverting the truncation; Apple's forums report keyboard language and region routinely disagree. NEW `DecimalInputParser` is separator-AGNOSTIC (folds non-Latin digits, drops grouping spaces, reads the final separator's role from grouping SHAPE: `1.250` ⇒ 1250 on de_DE, 1.25 on en_US). **The harness caught THREE bugs in the parser itself** before it was wired in — the session's methodological point. **R47.1b:** the audit agent called `allowance` a "stepper"; it is not, and bare `Int()` returned nil for ANY separator, so a reduce goal silently lost its limit. **R47.2 (FIXED):** `savingsDisplay` guarded `savings > 0` BEFORE the floor-to-ten, so any projection under ten units floored ONTO zero and rendered the fabricated "~$0/year" AC4 forbids. **R47.3 (FIXED):** 46A's own `CalendarSourceLintTests` claimed "ALL shipping code" and named the timeline planner as what it protects, but `scopedRoots` omitted `Packages/` — the two files that actually do the calendar math were never opened by the walk (now 143 files). **CLEAN:** crash safety (every trapping construct proven unreachable) and helpline region resolution (4 probes — now evidence for the paste-to-Apple "region-aware" claim). **Batched R46.6.** **REBASED mid-flight onto the operator's 46B copy-pass commits** — zero file overlap; their in-flight CI run was allowed to finish first so this run isolates these changes. **NO operator action for the code**; two items added to `operator-expected.md` (a free ITMS-9105 inbox check §8; the beta-tester geography decision §5). **46B closing §3 means the FINAL GOLDEN BATCH is UNBLOCKED — that is the next session.** Superseded 46B header below.) |
| _superseded_ | 2026-07-26 (**Session 46B — THE OPERATOR SHOWED UP AND THE §3 COPY PASS IS CLOSED.** The five-session terminal-state loop (S41–S45) ended: the operator opened with "operator expected dosyasında benim üzerime düşen işleri yapmaya geldim" and worked the critical path's **step 1**, its longest-lead item, end-to-end in one sitting. A 14-agent workflow (`wf_e323a333-604`, ~928k subagent tokens, 0 errors) read every shipping copy table in parallel — one agent per file, plus external helpline verification and a cross-file consistency critic — and the operator then made **~20 decisions** across four rounds. **18 string edits + 5 code changes landed, all verified green locally before commit:** 121 free-lane package tests, 404 unit in 64 suites, 35 snapshot in 8 suites, and the UI-smoke/a11y-audit lane, run with the CI invocations byte-for-byte on an iPhone 17 Pro simulator (Xcode 26.6); 12 goldens re-recorded (107 total, unchanged). **THE SESSION'S MOST IMPORTANT FINDING: `operator-expected.md` §3 had been instructing, since S27, to verify ALO 182 and flip `verified: true` — following that instruction would have shipped a life-safety defect.** ALO 182 is Turkey's **hospital appointment booking line** (MHRS); the Ministry of Health's own page is titled "Alo 182 - Merkezi Hastane Randevu Sistemi". The `helplines.json` row claimed the name "Yaşam Hattı" and described psychologist support for suicidal ideation — both fabricated — and its own source URL pointed at findahelpline.com, not any official page. A Turkish user in crisis dialling 182 would have reached an appointment IVR; `verified: false` was the only thing protecting them. The row is corrected in place, stays `verified: false` **permanently**, and carries an explicit "ASLA verified: true YAPMAYIN" note with the evidence so no future session repeats it. **SECOND: a real safety gap was fixed, not accepted** — the alcohol withdrawal notice mounted ONLY on the dashboard, so an alcohol user who hit the HARD paywall and did not convert never reached it and never saw the notice; it now also mounts on the SUMMARY (pre-paywall), sharing one extracted `AlcoholNoticeCard`, with the dashboard mount kept as the fallback (the durable `recordAlcoholNoticeShown()` stamp makes double-presentation impossible). **THIRD: OQ-1 resolved toward brandkit §1.2** ("Adult content"/"Cannabis") — and the documented scope was wrong: the words rendered on **5** surfaces, not 2, because two views called `rawValue.capitalized` and never touched `displayLabel`, also shipping "Vape"/"Doomscroll"/"Custom"; all five now read `HabitCategory.displayNoun`. **FOURTH: the Schedule 2 legal rider is CLOSED in code** — Terms/Privacy were inert `Text` labels and are now real `Link`s to `beyondkaira.com/terms` + `/privacy` (constants in `AppIdentifiers.swift`); making them interactive immediately failed the a11y audit with `Hit area is too small` ×2, fixed with 44pt targets. Also: the paywall promised a **journal** that `mvp.md:68` puts out of MVP scope (now "notes and reflections"); `review-notes.md` cited a notification test **that does not exist** (now code-absence verification); three milestone bodies softened off medical adjacency; the panic entry title shortened — and the AX5 goldens proved the docs' "it truncates" claim wrong while revealing something worse they had never recorded: the long title pushed the **breath bloom entirely off-screen** at max Dynamic Type. **NEXT SESSION: the operator selected FOUR tracks and only §3 was worked — device sitting #1, the §8 keys, and §5/§6 TestFlight+Slack housekeeping are still open and were left with parallel-homework instructions.** The final golden batch is now UNBLOCKED. **READ FIRST: `docs/critical-path-post-uir.md`, then `docs/operator-expected.md` §3 for the external gates.** RAN CONCURRENTLY WITH SESSION 46A (the autonomous pre-launch defect hunt — the 17+ age-gate calendar fix + the redesign blueprint); the two were merged after the fact and did not collide, the only code overlap being the same stale "15 goldens" comment both fixed identically. 46A's header is immediately below. Superseded S45 header beneath that.) |
| _superseded_ | 2026-07-25 (**Session 46 — the PRE-LAUNCH DEFECT HUNT: a REAL 17+ age-gate compliance defect found and FIXED. 1 billed run, CI green.** This is the first session since S40 to change shipping code, and the first EVER to audit the CODE rather than the plan. **Session-open (three commands, not a sixth audit):** `git fetch` → local == `origin/main` at `77b7c44`, clean; the only two commits after the S45 ledger are AGENT docs-declutter commits (operator asked for open-items-only in `operator-expected.md`; now recorded in the ledger — they had been missed); last code CI run `29679913441` SUCCESS per-job (10/10); free lanes re-run first-hand = **121 pass**; **no unblock trigger fired**; `roadmap.md:252-256` confirms Phase 4/5 are post-launch-gated, so no roadmap item exists for an agent to start. **The new axis:** S41–S45 all asked *"is any PLANNED work left?"*; none asked *"is the SHIPPED CODE correct?"* — 121 tests + 107 goldens passing is not the same claim as correct, and external beta + App Review are next. So `wf_e3149939-8ad` ran **12 adversarial agents** (6 read-only dimension finders → an independent refuter per dimension told to REFUTE and default-to-refuted → a completeness critic) over the 119 shipping files. **Result: 5 findings, 5 CONFIRMED, 0 refuted; privacy/consent and app-flows/concurrency came back CLEAN** (meaningful negative results — the ADR-8 double gate and the §10 absence set survived an adversarial read). **R46.1 (HIGH, FIXED, `0cec0bf`):** `AgeGateContainerView:136` derived `currentYear` via **`Calendar.current`** — the device's Language & Region calendar. MEASURED with an executed Linux probe, not reasoned: on an Islamic-calendar device the 17+ boundary's youngest passer is **16.60 solar years** (vs 17.57 Gregorian) — an ~11.7-month hole in a legally load-bearing gate; and under the **Japanese** calendar `component(.year:)` returns the ERA year (8), collapsing the birth-year wheel to **`-112...8`**. Nothing caught it because `Calendar.current` IS Gregorian on every simulator — the suite and every golden are structurally blind to the class. Decisive: `StreakCardModel:54`, `AdherenceCalculator:27`, `StreakTimelinePlanner:114` ALL already pin `.gregorian` — **the gate was the single dissenting site.** Fixed via `AgeGate.calendar`/`currentYear(at:)` + NEW `CalendarSourceLintTests` (born-green PROVEN by an executed Linux harness: 119 files, 0 violations, fire-on-mutation on both idioms) + a semantic pin in `AgeGateTests` written RELATIONALLY so an ICU revision can't redden it + the `review-notes.md:69` paste-to-Apple rider. Byte-identical on CI/Gregorian devices ⇒ zero golden churn. **R46.2 (MEDIUM, DOCUMENTED not fixed):** `EntitlementModel`'s own contract promises refresh on construction/purchase/foreground; **only construction exists** — `makeOnPurchaseCompleted` receives the fresh state and discards it. Live-path only (dormant builds unaffected), so it is a **named rider on the operator's §8 key step**, deliberately not blind-fixed (Architect-gated + unverifiable without the RC key — the R41.1 lesson). **R46.3 (LOW):** launch-time `refreshPanicSnapshot()` skips `scheduleWidgetReload()` — owner tradeoff (reload budget), recorded. **R29.4 independently rediscovered** — already known/deferred, no action. Batched the banked `StreakWidgetStyle` 15→29 comment. **NO NEW operator action required.** READ FIRST next session: `docs/critical-path-post-uir.md`. Superseded S45 header below.) |
| _superseded_ | 2026-07-24 (**Session 45 — terminal-state re-confirmation with a FIRST-HAND free-lane run; ZERO billed runs, ZERO code touched, NO agent build work.** The project has been operator-gated and independently verified FOUR times (S41 5-agent audit; S42 6-agent adversarial refute-audit; S43 green re-verify + 16-agent runbook-fidelity sweep; S44 cheap green/commit check). The standing objective is unchanged: the cheap direct check for whether the operator unblocked anything, act only on a genuine trigger, else report blocked and stop — **do NOT run yet another "is it blocked" audit (five-times-answered), do NOT mine doc nits (S43 swept the runbook clean, S44 re-confirmed), do NOT burn a CI run, do NOT re-attempt the Mac-gated settings audit on CI.** **Session-open (the only signal that carries new information):** `git fetch` → local == `origin/main` at `504fb40` (**no operator commits since S44**), tree clean; `gh run view 29679913441 --json` → the last **code** run is SUCCESS verified **per-job** (all 10 jobs green, incl. the two submission lints + the TestFlight upload), every commit since is a `[skip ci]` docs commit (no run, correctly), the `failure` rows are the already-reverted S40 settings attempts. **Unblock triggers — NONE fired:** §3 copy pass (would be operator copy-table commits → none); §8 key (agent acts only on a specific ask → no operator message beyond the standing loop instruction); OQ-1/OQ-2 (arrive as an operator decision message → none); the two S42 ready-to-ride items stay billed + non-launch. **The one net-new thing this session did (that S44 skipped as "byte-identical make-work"):** since the free package lanes cost ZERO CI billing, this fresh session RAN them itself rather than trusting the ledger — `swift test` on HEAD → **StreakEngine 84 / WidgetToolkit 21 / PaywallKit 16 = 121 pass**. So the terminal green is now first-hand across all three axes (git identity, CI per-job, a locally-executed free-lane run), not ledger-trust. **Deliberate restraint:** did NOT spin a workflow; did NOT touch source (both ready-to-ride edits need a billed run, non-launch — the handoff forbids a standalone run); did NOT re-nitpick the runbook. **Conclusion: NO operator action since S44, no genuinely-unblocked trigger → the project remains fully blocked on the operator critical path — the genuine human-dependency stopping condition.** Docs-only bookkeeping: the Session 45 ledger in `docs/past-prompts.md`, the S45 operator-checklist header, a `critical-path-post-uir.md` sync note, and this regeneration — all `[skip ci]`. **NO operator action required beyond the existing critical path. READ FIRST next session: `docs/critical-path-post-uir.md`.** Superseded S44 header below.) |
| _superseded_ | 2026-07-22 (**Session 44 — terminal-state CONFIRMATION; ZERO billed runs, ZERO code touched, NO agent build work.** The project has been operator-gated and independently verified THREE times (S41/S42/S43). The autonomous-loop mandate is continue-until-blocked-by-a-human-dependency; the S43→S44 handoff objective was explicit: do the cheap direct check for whether the operator has unblocked anything, act only on a genuine trigger, else report blocked and stop — **do NOT run a 4th "is it blocked" audit (thrice-answered), do NOT mine doc nits (S43 swept the runbook clean), do NOT burn a CI run, do NOT re-attempt the Mac-gated settings audit on CI.** This session honored that verbatim. **Session-open (the only signal that matters):** `git fetch` → local == `origin/main` at `b5bb5a0` (**no operator commits since S43**), tree clean; `gh run list` → last **code** run `29679913441` SUCCESS (10/10 jobs), every commit since is a `[skip ci]` docs commit (no run, correctly), the `failure` rows are the already-reverted S40 settings attempts. **Unblock triggers — NONE fired:** §3 copy pass (would be operator copy-table commits → none); §8 key (operator's wake-up, agent acts only on a specific ask → no operator message this session beyond the standing loop instruction); OQ-1/OQ-2 (arrive as an operator decision message → none); the two S42 ready-to-ride items stay billed + non-launch (not spent standalone). **Deliberate restraint:** did NOT re-run the free lanes — code is byte-identical to S43's 121-pass verification (zero code commits since), so re-running for an identical result is make-work, not verification; did NOT spin a workflow; did NOT touch source; did NOT re-edit the runbook for fidelity. **Conclusion: NO operator action since S43, no genuinely-unblocked trigger → the project remains fully blocked on the operator critical path — the genuine human-dependency stopping condition.** Docs-only bookkeeping this session: the Session 44 ledger in `docs/past-prompts.md`, the S44 operator-checklist header, a light sync note on `critical-path-post-uir.md`, and this regeneration — all `[skip ci]`. **NO operator action required beyond the existing critical path. READ FIRST next session: `docs/critical-path-post-uir.md`.** Superseded S43 header below.) |
| _superseded_ | 2026-07-21 (**Session 43 — a THIRD independent green re-verify + an operator-RUNBOOK FIDELITY sweep; ZERO billed runs.** This session did NOT run a third "is it blocked" audit (S41+S42 answered that twice — that would be make-work). It re-confirmed the terminal state cheaply and directly (`git fetch`: local==origin at `5ba36c3`, **no operator commits since S42**; `gh run list`: last code run `29679913441` SUCCESS 10/10 jobs; free lanes RE-RAN: StreakEngine 84 / WidgetToolkit 21 / PaywallKit 16 = **121 pass**; 107 goldens on disk), then did the one net-new high-value agent-doable thing: a **16-agent runbook-fidelity sweep (`wf_3555cfd8-7cd`)** — 6 finders (one per operator-facing doc cluster) + 1 adversarial verifier per finding — checking that every concrete instruction the operator is about to follow matches current source. **Result: 10 CONFIRMED operator-harmful defects, 0 refuted; all re-verified against source by hand before fixing.** The launch-relevant ones: **(1)** `review-notes.md:22/69` — the **PASTE-TO-APPLE** notes said "11-step quiz" but a "cut down" reviewer sees 12 and a custom habit a 13th → **11–13** (a reviewer-falsifiable count); **(2)** `payload-audit.md:97` — the MITM runbook's `cold_start_ms` buckets `<1s`/`1–2s`/`>2s` are NOT the wire values (`ColdStartBucket` raw = `under_1s`/`1s_to_2s`/`over_2s`, `AnalyticsService.swift:38-42`) → the operator would false-FAIL a valid payload; **(3)** `critical-path-post-uir.md:30` step 7 — implied the domain + bundle identity are still to-do, but both were done 2026-07-08 (`AppIdentifiers.swift:6`); only trademark/name clearance is open (+ its `roadmap.md §Naming` anchor was broken); **(4)** `operator-expected.md` §7 lacked the **streak-ring device-glance** checkbox the preamble promised (`StreakRing.swift` mandates a motion eyeball a golden can't verify). Plus stale counts (settings 8→12 copy strings; the widget copy list missing its 9th string "Reset" + a misfiled decision-fork moved to the correct file; quiz 10–12→11–13). **12 doc locations fixed, all docs-only, `[skip ci]`, ZERO billed runs. NO operator action required.** The operator critical-path boundary is UNCHANGED — this pass made the runbook more accurate, it did not unblock anything. **READ FIRST next session: `docs/critical-path-post-uir.md`.** Superseded S42 header below.) |
| _superseded_ | 2026-07-19 (**Session 42 — a SECOND independent verification of the terminal state + operator-handoff hardening; ZERO billed runs.** This session did NOT parrot S41: it re-ran the free lanes (StreakEngine 84 / WidgetToolkit 21 / PaywallKit 16 = **121 pass**), re-checked CI (last code run 29679913441 SUCCESS, all 10 jobs), and ran a **6-agent adversarial audit (wf_b6642546-5ff)** — 5 probes + a critic *tasked to REFUTE* "blocked on operator." **Result: the "no agent BUILD/FEATURE work remains" claim HOLDS** (deferred-items + settings probes both confirm every code item is operator/device/mac/architect-gated), but the critic *refuted* the broader "nothing agent-doable" claim on **doc-integrity + CI-hygiene** grounds — which S42 then fixed (all verified against source first): (1) **`spike-panic-latency.md:19` — MAJOR:** the E0.3 device runbook pointed Instruments at signpost subsystem `dev.placeholder.quitwidget` (never-registered, pre-Gate-G0) — the real signpost fires under `com.beyondkaira.ballast` (`UnhookedApp.swift:158`); an operator would have measured nothing. Fixed (+ the stale step-2 "placeholder IDs never registered" text). (2) **R41.1 CORRECTED** in `critical-path-post-uir.md` + `roadmap.md`: S41's "None of the 5 S40 runs hid the resources-row icon" is **factually wrong** — runs 3 (`fc2b68a`) + 4 (`bfe36ee`) both hid it; run 4 IS the R41.1 shape and FAILED. Hiding the icon is a **known-failed** shape; the one structurally-untried variant (exact `iconRow` ordering — Text leading, NO `.fixedSize`, `Spacer()`, trailing hidden icon) + two Inspector fallbacks are now documented. **Verdict re-affirmed: PARK_MAC.** (3) stale counts fixed: `submission-checklist.md` quiz "12–14"→"11–13"; `operator-expected.md` widget goldens "15"→"29", milestones "~40"→"43". (4) **CI hygiene (`ci.yml`, locally validated, `[skip ci]`):** `slack-notify` now `needs:` the 3 lint jobs (a dormant-TestFlight state could otherwise send a false-green while an account/monetization-import violation shipped); `account-absence-lint` gained a corpus-non-vacuity floor (≥100 swift files, currently 119). A real bug (a dropped `runs-on`) was caught in diff review — the YAML validator now checks `runs-on`/`steps` per job. **NO operator action required.** Two ready-to-ride items are banked (below). **READ FIRST next session: `docs/critical-path-post-uir.md`.** Superseded S41 header below.) |
| _superseded_ | 2026-07-19 (**Session 41 — the autonomous build loop reached its TERMINAL STATE.** The build is INDEPENDENTLY VERIFIED green (a 5-agent audit RAN the free lanes: 121 tests pass — StreakEngine 84/WidgetToolkit 21/PaywallKit 16; all four grep lint gates clean; strict-concurrency clean; the last code CI run 29661516821 SUCCESS on all 9 jobs) and there is **NO remaining agent BUILD/FEATURE work** — every open item is operator/device/mac/future-gated (an adversarial fact-check confirmed the handoff is not premature). This was a **DOCS-ONLY, ZERO-billed-run operator-handoff-hardening pass**: NEW `docs/critical-path-post-uir.md` (the operator's single-page 11-step launch playbook + the consolidated Open-decisions table + the settings Mac-gate handoff) and `docs/copy-pass-checklist.md` (the §3 copy pass, file-by-file); FIXED `docs/review-notes.md` (removed a stale R30.6 "submission blocker" — CLOSED S31 — and two false "the user's own iCloud" sync claims that violated the doc's own register ban and would have pasted to Apple), the operator-expected "Runway to launch" paragraph (was still "step 1 = the UI Reactor, ~6 sessions"), and a 25-session-stale `8a0c469` tester-guide build ref. **R41.1:** the settings resources-row has an UNTRIED `.accessibilityHidden(true)` candidate modeled on the SAME screen's PASSING `iconRow` (`DiscreetSettingsView.swift:203`) — RECORDED for the Mac session, NOT authored (unverifiable without a Mac/billed run; touching an audited surface unverified is banned). **NO operator action was required for the audit pass.** **Follow-up (operator said "go ahead"):** landed the `account-absence-lint` (+ wired both submission lints into the TestFlight `needs:` gate) and confirmed `ITSAppUsesNonExemptEncryption` was ALREADY set in project.yml — 1 billed run, CI 29679913441 all-green (10/10 jobs, incl. the TestFlight upload). **The project is again fully BLOCKED on the operator critical path.** READ FIRST next session: `docs/critical-path-post-uir.md`. Superseded S40-addendum header below.) |
| _superseded_ | 2026-07-18 (Session 40 addendum — **the SETTINGS-CONTENT audit was attempted on CI (operator-requested) and is now DEFINITIVELY DEFERRED as MAC-GATED, with a complete diagnosis.** 5 CI runs (enumerate-all-from-one-run) fixed 2 of 3 defects — title (free-standing `.largeTitle` above the List, R39.2) and the long footer (moved out of the height-capped `footer:` slot into a self-sizing `captionRow`) — but the resources row ("Support & resources") is an unsolved **Button + wrapping-title Dynamic-Type conflict**: a native `Label` truncates (`.textClipped`); an `HStack{Image;Text}` clears the clip but breaks the native icon+title co-scaling (`.dynamicType` "partially unsupported"); a plain-`Text` row passes both but isn't a Button. Pinning it needs Xcode's Accessibility Inspector, not CI. Reverted to green (settings unchanged; 8 audited surfaces; 107 goldens stable). **This is the operator-dependency boundary: no further CI-doable UIR work remains.** Superseded S40-UIR-5c-complete header below.) |
| _superseded_ | (Session 40 — **UIR-5c substantively COMPLETE; the agent-doable UIR work (Epic 2.5) is DONE. The project is now fully operator-gated.** Four UIR-5c items landed this session, each verify-then-execute (a workflow sized to its risk): (1) **widget typography R34.7** (§3 numeral/label, 2 runs); (2) **reasons-frame AX5 R35.6** — at accessibility sizes the panic reasons step scrolls so the title stops truncating; pure layout + a double no-op for the rule-11 audit; 4 goldens re-recorded + visually verified (2 runs); (3) **`StreakRing` motion** — the `motion/calm` appear animation, opt-in + golden-safe (byte-identical settled draw; only the live dashboard animates), 1 run ZERO golden churn, animation flagged for a device eyeball; (4) **golden-batch prep** (`docs/golden-batch.md` — the ONE final re-record for the §3 sitting). DEFERRED: the settings-content audit (S39 iceberg — characterized; needs enumerate-all-findings-from-one-run / a local macOS run). **All lanes green; 107 goldens stable. The next steps are OPERATOR-owned** (see the operator critical path). Superseded S40-item-1 header below.) |
| _superseded_ | (Session 40 — **UIR-5c item 1: widget typography R34.7 DONE in exactly 2 billed runs, ZERO theory-failures.** brandkit §3 `type/widgetNumeral` (rectangular numeral 17→20pt Semibold monospaced) + `type/widgetLabel` (rectangular "saved" SPLIT out of the money line; medium savedLabel/milestoneLabel → 12pt Medium tracking +0.3), in `Shared/Sources/StreakWidgetViews.swift` (luminance-only, no Theme). An **8-agent verify+critique workflow (wf_df8c942c-94b) made run 1 correct on the first try** — it caught a BLOCKER 4/5 critics flagged that the first plan missed (line 168's rectangular "saved" bundled in a `.caption2` money string) and produced a surgical 9-golden delete-list. 9 goldens re-recorded + all VISUALLY VERIFIED (no clip; unavailable text 2-line wrap validates `.semibold`); 20 unchanged untouched (total 29). Flagged to operator: numeral `.semibold` vs `.bold`; medium labels fixed-12pt (no AX5 scaling). **Remaining UIR-5c (all INDEPENDENT): `StreakRing` motion, reasons-frame AX5 (R35.6), settings-content audit (S39 iceberg, deferrable), golden-batch prep.** Superseded S39 header below.) |
| _superseded_ | (Session 39 close: **UIR-5b attempt 1 — the SETTINGS audit leg is DEFERRED to its true depth; reverted to the UIR-5a green state (byte-identical, all 107 goldens restored, 8 audited surfaces intact).** Two billed runs bought the DIAGNOSIS, no net feature. **R39.1:** a title in a LIST ROW clips exactly like the nav bar (a row is height-constrained) — `.dynamicType`/`.textClipped` fire on it. **R39.2:** a FREE-STANDING `.largeTitle` `Text` ABOVE the List FIXES the title (proven), but the audit then flags the settings LIST CONTENT — the long haptic-pacer SECTION FOOTER clips at AX5, and it uses NO explicit font (List's default scalable footnote): **List SECTION FOOTERS clip at accessibility sizes, a STRUCTURAL issue, not a font fix.** Deferred because completing it (move every long footer out of the `footer:` slot + re-record goldens) is unknown-depth whack-a-mole at 1 billed run/iteration on a polish surface — a future pass must enumerate ALL findings from ONE run (or a local macOS run) and fix wholesale. **The fix is now KNOWN on both axes** (title: free-standing text above the List; content: footers out of List slots). Also logged: `[skip ci]` in a commit BODY (not just the subject) skips the run — never write the literal token unless you mean it. Superseded S38 header below.) |
| _superseded_ | (Session 38 close: **UIR-5a DONE in exactly 2 billed runs — the deferred audit legs + the Monetization lint scope.** The **PAYWALL** joins the audited surfaces — `test_a11yAudit_paywall` (UITEST_PAYWALL_DIRECT → the hard-variant fixture) passed the FULL 7-type set CLEAN on its first run; the a11y audit now covers **8 surfaces** (age gate, quiz, summary, dashboard, panic, slip, resources, paywall). `App/Sources/Monetization` joined the layout-lint scope (48 files, floor 12 → 35, born-green; the inline retry `.plain` → the pass-through `PlanCardButtonStyle`). No goldens (audits mint none; the lint growth is born-green) — all 107 goldens byte-stable. **R38.2 = the SETTINGS audit leg is DEFERRED:** its run-1 `.dynamicType`+`.textClipped` fired on the navigation-bar LARGE TITLE ("Discreet Mode", NavigationBar/LargeTitle — a SYSTEM behavior, not the themed content), so the fix is a custom/`.inline` title (which re-records the settings golden), owned by UIR-5b. Run 1 also carried an UNRELATED erase-debounce unit FLAKE (passed in S37; resolved on run 2). **UIR-5b (motion/polish + the settings large-title fix + widget typography + reasons AX5 + golden-batch prep) is the LAST agent-doable UIR work.** Superseded S37 header below.) |
| _superseded_ | (Session 37 close: **UIR-4b DONE in exactly 2 billed runs — UIR-4 FULLY COMPLETE.** `DiscreetSettingsView` moved onto the Theme layer via in-place List theming (`.scrollContentBackground(.hidden)` + surface/base backdrop + `.listRowBackground(surface/raised)` per Section + `.tint(brand/primary)` + Theme text tokens), keeping List's native cell accessibility; 2 goldens minted (105 → 107), golden visually verified. Deferred to UIR-5: the settings/paywall audit legs + the Monetization lint scope + full settings golden coverage. **Every screen in the build is now regenerated onto the design system.** Superseded S36 header below.) |
| _superseded_ | (Session 36 close: **UIR-4a DONE in exactly 2 billed runs** — the two DEFECT surfaces regenerated: **RESOURCES** (safety) — `.background(.quaternary)` → `themedCard`, the R33.10 DIAL link (44pt floor + "Call <name>" label), 2 goldens + a new audit leg that passed the full 7-type set CLEAN on run 1 (the THIRD consecutive clean first-audit); **PAYWALL** — 3 R32.9 disabled-`.plain` fixes (`PrimaryButtonStyle`/`QuietButtonStyle` + the new pass-through `PlanCardButtonStyle`) + a pre-existing caution-on-caution contrast bug, no goldens (draft copy, verified by the QuizFunnelUITests smoke). **SETTINGS DEFERRED to UIR-4b** (the List→ScrollView restyle — the biggest structural risk, cleanly separable; full spec preserved in `scratchpad/uir4-step0.md` + workflow journal wf_b91f1762-aff). New contrast pair (34 total, Linux-verified). **R36.4 = the mount-gate lesson: a full-screen `.accessibilityElement(children: .contain)` container id does NOT surface as a queryable element (unlike a bounded card) — gate an audit leg on a real CHILD element.** Superseded S35 header below.) |
| _superseded_ | (Session 35 close: **UIR-3 DONE in exactly 2 billed runs** — the panic + slip flows (rule-11 SAFETY surfaces) are regenerated on the Theme layer with a PM+Brand+QA pre-code sign-off, copy byte-identical. **The `.dynamicType`/`.textClipped` exclusion list is CLOSED to ZERO** — all 8 `minHeight: 56` floors became growing PADDING (the exact S28 mechanism), `StepScaffold`/`confirmStage` scroll with pinned actions (R33.5), the reasons text moved off a `@ScaledMetric` point size onto `.largeTitle` (R33.12), both audit legs joined the full 7-type set and `safetyAuditTypes` is deleted. **The rule-11 panic/slip legs passed CLEAN on run 1** (the SECOND consecutive clean first-audit — the ledger a prior run wrote is the current run's free coverage). 64 class-A goldens re-recorded + visually verified; total unchanged at 103. STEP-0: did NOT grow the lint scope to panic/slip (would force a shape-changing `.buttonStyle(.plain)` refactor on safety surfaces — the full-set audit legs are the gate instead; deferred to UIR-5). Carried: the reasons-frame AX5 title truncation (R35.6, a UIR-5 AX-axis item) and the `.plain`→ButtonStyle refactor. Superseded S34 header below.) |
| _superseded_ | (Session 34 close: **UIR-2 DONE in exactly 2 billed runs** — the 2 planned, contingency UNUSED, ZERO burned. The **real `StreakDashboardCard` + `StreakRing`** are built on the Theme layer — the `RootPlaceholderView` "walking skeleton" that had stood in for the dashboard since Session 18 is RETIRED, replaced by one card per active quit (streak-day hero, flame + momentum figure, the momentum ring, money saved, next-milestone bar). **Copy is byte-identical** (R34.2, copyBlockerFound=FALSE): every string is audited (`"saved"`/`"next milestone"`, pinned byte-identical to `StreakWidgetStyle`) or pure ADR-11 data; the §3-blocked polish strings ship empty-guarded. **The dashboard is AUDITED FOR THE FIRST TIME and its first audit passed CLEAN** (R34.3) — the first UIR surface to fire nothing, because R33.12 was already known and the card was built to it from the first byte (the free layout lint pre-empted every `.dynamicType` idiom; `children:.contain` + 4.5-clean tokens pre-empted the rest). **Widgets were DEFERRED at STEP-0** (R34.7): the 5 families are on-spec bar two minor brandkit-§3 typography defects; `StreakWidgetViews.swift` was UNTOUCHED so the 29 widget goldens stay byte-stable and no golden churn entered the budget. 8 dashboard goldens minted (95 → 103); the a11y exclusion list did not shrink this session (panic + slip remain, UIR-3's job).) |
| Phase | **The redesign program IS the agent workstream now** (operator §0 = (B), pre-launch). Waves 1–2 landed in a parallel session; **wave 3 = S50 (ME-7 Settings + the a11y closures)**. UIR-0…5c DONE. **10 surfaces** carry the full 7-type audit (settings + erase confirm added S50) and the `.dynamicType`/`.textClipped` exclusion list is ZERO. **The last Mac-gated item is CLOSED** — no Accessibility Inspector session is needed. Sessions 41–45 verified the old terminal state five times; 46/47 audited the shipped CODE and fixed three defects no test could see (the 17+ age gate on the device calendar; comma-decimal money truncation; a fabricated "~$0/year"); 46B was the operator closing the §3 copy pass; 48B took RevenueCat LIVE and bound the paywall to Apple's real per-territory price; 49 audited 48B's wave. **Remaining redesign items: ME-3, ME-8, ME-4, ME-9, then the final golden batch + LB-5.** Remaining OPERATOR work: clinician + counsel sign-off, the two legal pages published, G0 trademark clearance, device sitting #1, the sandbox purchase matrix, Superwall + TelemetryDeck keys, external beta, submission. |
| Next session objective | **ME-3 — milestone unlock moments** (`redesign/design-roadmap.md` Phase 3; UX blueprint §6.20 + §6.17). NOT blocked, no operator input needed: the 43 milestone bodies already ship in `App/Resources/Content/milestones.json`, are lexicon-gated, and `StreakDetailView` (wave 2) already renders the catalog — so ME-3 is the *unlock moment* (a quiet Ember-lit card on Home + the waterline-rise motion, 600ms, one soft haptic, never confetti) plus the discreet variant (time-only title, no Ember). **Read `docs/past-prompts.md` Session 50 FIRST** — four of its rulings generalize: (1) a plan's "free" verification step is a claim to CHECK, not trust (`Packages/AppTests` does not exist, and `Tests/Unit` cannot run on Linux at all — write an executed harness over bytes PARSED FROM SOURCE); (2) any new `uiTest…Mount` needs its env var in `AgeGateContainerView`'s allow-list or its leg times out blaming the view — `UITestMountCoherenceTests` now catches that for free; (3) S46-final copy is founder-owned and `operator-expected.md` §7 quotes some of it BY NAME, so never restyle it; (4) verify every proposed Apple API against the docs JSON yourself — S49's finder AND its refuter invented the same property, and S49's own recommended fix had the wrong argument label. Milestone copy is DRAFT/founder-owned → append to §0's pass. **Other live triggers, independent of ME-3:** the **Superwall key** → variant mapping + dashboard placements; the **TelemetryDeck app ID** → wake the transport (+ the banked QW-1-class win-back repository-tier tests, which must never be spent standalone); an **ITMS-9105 reply** → the manifest edit or delete the checkbox. |

> **What changed in Session 46 — the first session to audit the CODE instead of the plan, and it found a real
> defect.** Five sessions had verified "no PLANNED work is left." None had ever verified "the shipped code is
> CORRECT" — and 121 unit tests + 107 goldens + 4 lint gates passing is a different, weaker claim, especially
> with external beta and App Review next. So S46 spent its effort there: `wf_e3149939-8ad`, 12 read-only
> adversarial agents over the 119 shipping source files (6 dimension finders → an independent refuter per
> dimension, told to REFUTE and to default to REFUTED under uncertainty → a completeness critic). **5 findings,
> 5 CONFIRMED, 0 refuted.** Privacy/consent and app-flows/concurrency came back **clean** — negative results
> worth having: the ADR-8 double gate and the §10 `widget-state.json` absence set survived an adversarial read.
> **The headline (R46.1, FIXED in `0cec0bf`):** the 17+ age gate derived its year through `Calendar.current` —
> the device's Language & Region calendar setting. This session did not argue about the consequence, it
> **measured** it with an executed Swift probe on the free Linux box: the youngest user the gate ADMITS is
> 17.57 solar years under Gregorian but **16.60 solar years under the Islamic calendar** — an ~11.7-month hole
> in a legally load-bearing gate, opened by a one-tap Settings choice. The probe surfaced a second consequence
> no agent had named: under the **Japanese** calendar `component(.year:)` returns the ERA year (8), so the
> birth-year wheel collapses to **`-112...8`** and onboarding is uncompletable in that locale. Nothing caught
> it because `Calendar.current` IS Gregorian on every simulator and dev machine — the whole suite and every
> golden are structurally blind to the class; it exists only on a user's device. And it was unambiguous rather
> than a judgment call, because the project's own convention was already unanimous: `StreakCardModel:54`,
> `AdherenceCalculator:27` and `StreakTimelinePlanner:114` each pin `Calendar(identifier: .gregorian)` — **the
> age gate was the single dissenting site in the codebase.** Fixed with `AgeGate.calendar` /
> `currentYear(at:)`, guarded permanently by a NEW `CalendarSourceLintTests` (the `ThemeSourceLintTests` shape
> applied to date math; born-green PROVEN by an executed Linux harness over the real bytes — 119 files, 0
> violations, fire-on-mutation on both banned idioms, comments and the sanctioned form exempt), pinned
> semantically in `AgeGateTests` with RELATIONAL cross-calendar assertions so an ICU revision can never redden
> the suite for a non-defect reason, and ridered into the paste-to-Apple claim at `review-notes.md:69`. The fix
> is byte-identical on CI and on every Gregorian device, so **zero goldens moved.** **R46.2 (MEDIUM) was found
> and deliberately NOT fixed:** `EntitlementModel` refreshes only at construction though its own contract
> promises purchase/restore/foreground too (`makeOnPurchaseCompleted` literally receives the fresh state and
> discards it) — live-path only, Architect-gated, and unverifiable without the operator's RC key, so it is a
> named rider on the §8 key step where the sandbox matrix will prove it. **1 billed run, CI green on all 10 jobs — and the run log was read back to PROVE the new tests executed rather than compiling out** (the `S46 · calendar single-source lint` suite started and passed on a real 119-file walk; unit lane 407 tests / 65 suites; 107 goldens unmoved); the banked
> `StreakWidgetStyle` 15→29 comment rode along per the batching rule. **NO NEW operator action.**
> [Prior S45 — terminal-state re-confirmed a fifth time, cheaply, with one net-new
> free piece of first-hand evidence: nothing about the build or the operator boundary changed, and that was the
> finding. The project has been operator-gated since S41 and verified FOUR times (S41 5-agent audit; S42 6-agent
> adversarial refute-audit; S43 16-agent runbook-fidelity sweep; S44 cheap green/commit check). Another audit
> workflow would be exactly the make-work the handoff warns against, so this session did the cheap direct check —
> **no operator commits since S44** (`git fetch`: local == `origin/main` at `504fb40`), **CI still green** (last
> code run `29679913441` SUCCESS, verified **per-job**: all 10 jobs green; every commit since is `[skip ci]`
> docs), and **no unblock trigger fired** (no §3 copy-table commits, no operator message asking for a §8-key
> follow-up or an OQ-1/OQ-2 re-pin) — PLUS the one thing S44 skipped as "byte-identical make-work": because the
> free package lanes cost ZERO CI billing, this fresh session RAN them itself rather than trusting the ledger —
> `swift test` on HEAD → **StreakEngine 84 / WidgetToolkit 21 / PaywallKit 16 = 121 pass.** The terminal green is
> now first-hand across all three axes (git identity, CI per-job, a locally-executed free-lane run). It did NOT
> spin a workflow, did NOT touch source (both S42 ready-to-ride edits need a billed run + are non-launch — the
> handoff forbids a standalone run), did NOT re-nitpick the runbook (S43 left it source-accurate; S44
> re-confirmed). **Conclusion: the project remains fully blocked on the operator critical path — the genuine
> human-dependency stopping condition; the autonomous loop correctly stops here rather than spinning empty
> sessions.** Docs-only bookkeeping: the Session 45 ledger (`docs/past-prompts.md`), the S45 operator-checklist
> header, a `critical-path-post-uir.md` sync note, this regeneration — all `[skip ci]`, ZERO billed runs. **NO
> operator action required beyond the existing critical path.**]
> [Prior S44: the cheap green/commit check (no operator commits since S43, CI green, no unblock trigger),
> deliberately no fourth audit. Prior S43: a 16-agent runbook-fidelity sweep fixed 10 operator-harmful doc defects — a paste-to-Apple quiz
> count in `review-notes.md` (→**11–13**), a MITM-audit false-FAIL in `payload-audit.md` (`cold_start_ms` → the
> real wire values `under_1s`/`1s_to_2s`/`over_2s`), a G0 step-7 overstatement in `critical-path-post-uir.md`
> (domain + bundle identity already registered 2026-07-08; only trademark/name clearance open) + a broken
> `roadmap.md §Naming` anchor, a missing streak-ring device-glance in `operator-expected.md` §7, plus stale
> copy-string counts. Prior S42: fixed the `spike-panic-latency.md` signpost subsystem
> (`dev.placeholder.quitwidget` → `com.beyondkaira.ballast`) + CI-hygiene.] The settings-content audit is
> MAC-GATED (S40, 5 CI runs): title = free-standing `.largeTitle` above the List (R39.2) + the long haptic
> footer out of the List `footer:` slot (S39) are PROVEN; the "Support & resources" row is an unsolved Button +
> wrapping-title Dynamic-Type conflict needing Xcode's Accessibility Inspector — the R41.1 hidden-icon candidate
> is a KNOWN-FAILED shape. The mount-gate lesson (R36.4): **gate an audit leg on a real CHILD element, not a
> full-screen `.contain` container id.**

---

## Standing tooling rules (permanent, apply to every agent)

1. **CodeGraph**: query `codegraph_explore` (shell: `codegraph explore "..."`)
   BEFORE grep/find or manual reading; pass this instruction into every
   subagent/workflow prompt; check blast radius before editing public symbols.
   **Before the session-end commit: `codegraph sync` + confirm status clean.**
2. **Parse gate**: `swiftc -parse` every touched Swift file before every push.
   PLUS the import-AND-ANNOTATION coverage check on every NEW test file: copy
   the closest proven neighbor's import block AND its type-declaration
   attributes. The deprecation gate (S21): any API form in a new file that NO
   neighbor uses gets its docs DEPRECATION metadata checked — and (S22) an
   operator/initializer the docs JSON does NOT CONFIRM is treated as
   nonexistent even if tutorials use it; (S23) third-party SDK members too —
   verify against the SDK's ACTUAL tagged source (a local SwiftPM bare-repo
   cache serves offline: `git -C ~/.cache/org.swift.swiftpm/repositories/<repo>
   show <tag>:<path>`); (S28, #5b) docs-confirmed EXISTENCE is not platform
   AVAILABILITY: every member of a multi-platform type/option-set gets its OWN
   docs-JSON `platforms` array check before code. Cross-import overlays are
   FILE-granular; UIApplication and every UIKit app-only API live in
   App/Sources ONLY. **S34: foundational Shape APIs (`StrokeStyle`, `.trim`,
   `.rotationEffect`) are not the deprecation gate's class — they're iOS-13-era
   stable; the gate targets deprecated/platform-specific forms.**
3. **The burn gates (S24/S25 — all Linux-reproducible, all permanent):**
   (a) **spurious-await** — every `await` in a NEW file must mark a genuinely
   async/cross-actor operation; mockup-typecheck new closure-into-seam shapes
   under `-strict-concurrency=complete -warnings-as-errors` (the ShapeChecks
   pattern). (b) **qualified-name** — a Darwin-only file's NON-SDK qualified type
   references get Linux-PROBED before push; both-SDK files use the
   bare-name-exact typealias, NEVER the module-qualified form. (c)
   **non-Sendable SDK results** cannot return into a @MainActor conformance under
   strict flags (`@preconcurrency import`, sole-importer file). (d) **lint anchors
   admit attributes WITH parenthesized arguments.** **(e) S34: a `try?` around an
   optional-chain that throws FLATTENS to `T?` in Swift 5+ — type-checked free on
   Linux before push (`(try? provider?.repository?.streakValue(...)) ?? fallback`).**
4. **Access-level gate + empirical harness:** scan for private types in
   non-private signatures, and RUN (never just typecheck) a Linux scratch
   harness over the exact shipping bytes of every pure-Foundation/PaywallKit/
   DesignSystem-data API — probe the BOUNDARY, under MULTIPLE HOST TIMEZONES
   (the standing set: UTC/Berlin/Kiritimati). **A source LINT is such an API,
   and so is a pure display-derivation** (S34 RAN `DashboardCardComposer`'s
   noon-anchor day + milestone math ×3 TZ + fire-on-mutation, and ran the layout
   lint's exact logic over the new Dashboard corpus — both born-green honestly on
   the free box). JSON pins use JSONSerialization key-SET semantics — plist pins
   use PropertyListSerialization key-SET — never byte/string equality. Free
   package lane runs `swift test` WITHOUT warnings-as-errors — close the gap
   pre-push with `swift build --build-tests -Xswiftc -strict-concurrency=complete
   -Xswiftc -warnings-as-errors --package-path Packages/<pkg>`.
5. **Docs-check gate:** every Darwin-only / AppIntents / WidgetKit / SwiftUI /
   SF-Symbol / third-party member spelling verified against official docs
   BEFORE code — AND per-member platform availability (#5b). **Proven THREE times
   now: docs CONFIRM existence + availability; they do NOT describe rendered
   behavior.** `.buttonStyle(.plain)`'s disabled dimming (R32.9) and the audit's
   rejection of `@ScaledMetric` point sizes + `ViewThatFits` (R33.12) are BOTH
   undocumented. **S34 rider: a KNOWN audit contract is free coverage — the
   dashboard's clean first audit was reachable ONLY because R33.12 (a prior run's
   ledger) was enforced by the free lint before the push. When a claim is about
   PIXELS or what an AUDIT will say, measure it — but once measured, it protects
   every later surface for free.**
6. Docs-only commits carry `[skip ci]`; never spawn agent workflows for
   docs-only changes. Critic/reader agents Write findings to scratchpad files
   and return a one-line pointer (permanent — paid for itself FIVE times; S34's
   10-agent understand+design workflow scoped the whole session before a byte was
   written, and caught that the "dashboard" was a placeholder). Fan-outs are
   available. **A reviewer's confident prediction about a runtime audit is a
   HYPOTHESIS, not a finding (S33: two reviewers refuted by the run). Never
   pre-suppress a rule-11 leg on a guess; a first audit's JOB is to produce the
   ledger — and S34 showed a first audit CAN pass clean when the contract is
   already known.** **NEVER `git stash` mid-session.** Check the STAGED set before
   every commit (the machine-local `.claude/settings.json` subagent-model pin
   NEVER rides a feature commit).
7. `git fetch` + `git log origin/main` before EVERY push — the operator
   commits mid-session.
8. **Privacy-surface gate:** anything touching stores/`AnalyticsEvent`/outbound
   gets Architect pre-approval BEFORE implementation; adding an enum case is
   Architect-gated AND needs the MVP §5 row first (pending ratifications:
   S25's teaser_expiry source + {teaser,hard} labels; S26's mvp §6 in-app-only
   win-back). Safety-content needs the PM+Brand+QA joint copy-table sign-off
   BEFORE code. `widget-state.json` remains a §10 surface; no entitlement /
   teaser / winback bit enters any pre-unlock file (presence-only Bool
   ceiling; a render-necessary content-free a11y Bool is admissible, R28.2).
   Scanned string tables must be STRUCTS with STORED NON-OPTIONAL properties
   (`DashboardCopy` is an enum of static lets — admissible ONLY because its two
   live strings are pinned byte-identical to the scanned `StreakWidgetStyle`
   struct, and the rest are empty; R34.2). The App Privacy label AND the app
   manifest's collected-data half re-derive together on ANY enum/property change.
9. **BUDGET REALITY:** there is no zero-billed-run code session; free lanes
   exist, free runs do not. App-lane red evidence = the CI run on the red
   commit; package-lane red is the free local `swift test` (push red+green
   together — cancel-in-progress is FALSE on main, so two pushes = two full
   billed runs). **The born-green ruling (R31.4) extends beyond the audit class
   when — and only when — the designed red's ENTIRE evidence value is reproduced
   free (executed harness: pass-on-real-bytes + fire-on-mutation/absence) AND the
   green run's own results prove the new tests executed. NEW snapshot goldens are
   NOT born-green (R32.4 record-missing WRITES-then-FAILS on macOS): plan
   red→adopt-from-artifact→green (S34 did it in the 2 planned runs, 8 goldens).**
   NEW SPM deps land in the GREEN commit, never red. **xcresult + the test-outputs
   artifact are FULLY readable on the Linux box — artifact-first diagnosis before
   ANY billed hypothesis run, and the recorded PNGs are downloaded, VISUALLY
   VERIFIED, and committed (S34: `gh run download <id> -n test-outputs`; all 8
   dashboard goldens eyeballed before adoption).** Every multi-step UI drive
   verifies each tap TOOK (R29.10).

### S32–S34 additions (permanent, UIR-era)

- **The Theme layer is load-bearing:** every color in App/Sources rides `Theme`
  (`ThemeSourceLintTests` bans the retired idioms — comment-stripped, grow-only);
  every NEW fg/bg pair a view introduces gets a `Theme.contrastPairs` entry in the
  SAME diff (S34 added `secondary text on raised`, 5.48/6.64 — now 33 pairs). The
  GHOST disabled treatment is the standing disabled form. Raw `.white`/`Color.white`
  on fills is BANNED.
- **Disabled controls are audited (R32.9):** a disabled CTA rides a custom
  ButtonStyle, never `.plain`.
- **The Dynamic-Type contract (R33.12 — MEASURED; obey verbatim):** 1. Text is
  sized by a TEXT STYLE, never a point value (`@ScaledMetric` does NOT rescue it).
  2. `ViewThatFits` is BANNED on any audited surface — read
  `@Environment(\.dynamicTypeSize).isAccessibilitySize` for the stacked-at-AX layout
  (S34: the dashboard card OMITS its ring + goes full-width at AX sizes this way,
  proven in the light/dark-ax5 goldens). 3. A point size on a decorative `Image`
  (SF Symbol) is FINE (the dashboard flame is `.font(.system(size: 20))` and passed).
  4. Content SCROLLS; actions PIN (S34: the dashboard content scrolls, the panic
  entry is pinned in the lower reach); a height floor on anything containing text
  stays BELOW that text's accessibility-size height; `.fixedSize(horizontal: false,
  vertical: true)` on every wrapping `Text`. `OnboardingLayoutLintTests` enforces
  1–3 for free on every lane; **its scope GREW to `App/Sources/Dashboard` in S34
  and never shrinks — UIR-3 adds `App/Sources` panic/slip files** (it does NOT yet
  cover `RootPlaceholderView`, which keeps its pre-UIR `.buttonStyle(.plain)`/56pt
  idioms out of scope until its epic).
- **`.dynamicType`/`.textClipped`** remain excluded on the PANIC and SLIP legs
  only, owned BY NAME by UIR-3 — the exact 5 firing elements (4 panic redirect rows
  + the slip forgiveness body) are already known from the S28 artifact. The
  exclusion list may only SHRINK; **UIR-3 is the session that shrinks it to zero.**
- **In-app motion is UIR-5's scope (R34.4):** the `StreakRing`'s motion/calm appear
  animation is deferred there (rendering settled is golden-safe — the settled frame
  is identical animated-or-not — and keeps snapshots deterministic). Any UIR-3
  panic/slip motion polish similarly rides UIR-5 unless it's structural.
- **Never assume the element TYPE an identifier lands on (R33.13):** an id on a
  `.contain`/`.ignore`-collapsed block surfaces to XCUITest as `.other`. Query
  `descendants(matching: .any)`.
- **Widgets stay luminance-only and NEVER import Theme.** Two minor brandkit-§3
  typography defects (rectangular numeral, micro-labels) are DEFERRED to UIR-5's
  golden batch (R34.7) — `StreakWidgetViews.swift` untouched keeps the 29 goldens
  byte-stable.
- **uipro:** present as an npm CLI (`which uipro`; nvm node v20.20.2). Domain
  searches as generator input; the brandkit + tokens-v2 canon OVERRIDE it.

### S50 additions (permanent)

- **A plan's "free verification" step is a CLAIM, not a fact — check it before you rely on it.**
  S50's plan prescribed `swift test --package-path Packages/AppTests` (no such package) and a `--filter` on
  a test whose own header says *"This lane CANNOT run locally (@testable app import)"*. Only three SwiftPM
  packages exist (StreakEngine / WidgetToolkit / PaywallKit); **everything under `Tests/` is an Xcode target
  and cannot run on the Linux box at all.** The substitute is the standing rule-4 technique: an executed
  harness that replicates the test's matcher over bytes **PARSED FROM SOURCE**, never a hand transcription,
  proving pass-on-real-bytes AND fire-on-mutation.
- **Every `uiTest…Mount` is TWO edits in TWO files.** `PostGateRootView` declares the branch;
  `AgeGateContainerView.uiTestOnboardingMount` is the allow-list that lets the launch reach it on a FRESH
  install. Miss the second and the leg times out after 15s with a message that blames the VIEW.
  `UITestMountCoherenceTests` now catches it for free — but know the coupling.
- **Apply the docs-JSON oracle to AGENT-PROPOSED fixes, not just to hand-written code.** S49's finder and
  its adversarial refuter independently invented `accessibilityFullKeyboardAccessEnabled` (404), and S49's
  own recommended fix named `accessibilityRepresentation(content:)` — also a 404; the real label is
  `representation:`. Two agents from the same distribution confirm each other's plausible fiction. Check it
  from the orchestrator, first-hand.
- **When a defect has resisted several runs, suspect the CONTAINER, not the element.** QW-9 burned seven
  billed runs on row shapes because everyone read the audit's complaint as being about the row. The evidence
  that it was the `List` was already in the ledger: short labels passed where long ones failed, on the same
  screen, in the same shape.
- **A source LINT can be a stronger guarantee than an audit leg, and it is free.** An audit checks one
  render of one mount; the `UITEST_SETTINGS` mount injects no repository, so it cannot render four of the
  six settings sections. A lint reads every line of every shipping file, including the ones no lane mounts.

## Where we are

- **The pre-UIR build side is 100% DONE.** **Phase 2.5 — Epic UIR: COMPLETE** (UIR-0 S32 … UIR-5c S40).
- **The agent workstream is now the REDESIGN program** (`redesign/design-roadmap.md`), because the operator
  answered `operator-expected.md` §0 with **(B) — it runs before launch** — as a standing instruction
  ("take all the designs live, don't wait for my approval"). Three waves have landed; that file's new
  **Execution status** table is the authoritative per-item state. **Next: ME-3.**
- **10 surfaces carry Apple's full 7-type accessibility audit** (age gate, quiz, summary, dashboard, panic,
  slip, resources, paywall, **settings**, **erase confirm**) and the `.dynamicType`/`.textClipped` exclusion
  list is CLOSED to ZERO. **NOTHING is Mac-gated any more** — the settings-content audit that stood parked
  from S40 to S50 is closed, and the reason it stayed open for ten sessions is worth carrying: the fix was
  never a row shape, it was removing the height-capped container. Three source lints now hold the invariants
  a runtime audit cannot see: `SettingsSourceLintTests` (no `List`/`Section` in shipping source),
  `UITestMountCoherenceTests` (every `uiTest…Mount` is hooked through the age gate),
  `CalendarSourceLintTests` (no ambient calendar), plus `ThemeSourceLintTests` and
  `OnboardingLayoutLintTests`.
- **The §3 copy pass is CLOSED (46B) and its bytes are FINAL and founder-owned.** Never restyle them —
  `operator-expected.md` §7 quotes some of them BY NAME in a checklist a human executes. New surfaces ship
  DRAFT strings appended to §0's founder pass; safety-adjacent strings additionally need the clinician +
  counsel loop and an agent may never author them. Other binding constraints unchanged: no red anywhere,
  a11y only strengthens, privacy surfaces untouched, ADR-6 panic latency, goldens adopted from run artifacts
  with **every new PNG visually verified** before adoption.
- **Monetization is LIVE** (48B): RevenueCat key in, all three products READY_TO_SUBMIT across 175
  territories, the paywall bound to Apple's real `localizedPriceString` per storefront (it had shown one
  hardcoded price to 174 of 175), purchase failures logged to `os_log` category `Purchase`. Superwall +
  TelemetryDeck stay dormant behind their keys.
- **StreakEngine 1.2.0 / WidgetToolkit 1.1.0 / PaywallKit 1.0.0 untouched.**
  purchases-ios 5.80.3 + SuperwallKit 4.16.1 + SnapshotTesting 1.19.3 +
  TelemetryDeck 2.14.1 exact-pinned. TestFlight LIVE.
- **Carried debts (all named):** OQ-1 (displayLabel) + OQ-2 (label taxonomy, R31.5
  manifest-lockstep) awaiting the operator; R29.4 (startIfNeeded no-retry); brandkit
  §2 prose still carries pre-correction hexes (tokens-v2 is the record); **R46.2 + R46.3
  (S46 defect hunt — detailed below)**; tight watch
  pairs tertiary-on-sunken 3.11 L / primary-text-on-tint 4.72 L (registry-pinned);
  scenario-30 purchase-leg E2E (sandbox tier); MVP §7 a11y box honestly UNCHECKED;
  the label is code-derived/wire-verify-pending (§8 app ID); the settings-content
  audit is MAC-GATED (R41.1 hidden-icon candidate is a KNOWN-FAILED shape per S42 — see
  `critical-path-post-uir.md` for the one untried variant + the Inspector fallbacks); the
  dashboard frozen-tooltip / reduce-framing / composed-a11y polish (all §3-blocked) —
  named, ride the founder pass / a Mac session. **CLEARED this session (were stale):
  `SafetyResourcesView`'s `.quaternary` fill + phone-number-only `Link` (fixed S36 —
  now `.themedCard()` + "Call <name>"); the widget typography defects R34.7 (done S40).**
- **S46 defect-hunt debts (source-proven, adversarially confirmed — see the S46 ledger):**
  **R46.2 (MEDIUM, the one real agent item left)** — `EntitlementModel` is refreshed ONLY at
  construction (`RepositoryProvider.swift:130` is the sole `refresh()` call site), though its
  own doc contract at `EntitlementModel.swift:8-10` promises construction + purchase/restore +
  foreground; `PaywallPresenter.makeOnPurchaseCompleted` receives the fresh `EntitlementState`,
  fires analytics with it, and DISCARDS it (`state` is `private(set)`). Consequences, live-path
  ONLY (dormant builds have no model ⇒ nothing is wrong today): (a) the win-back settings row
  (`DiscreetSettingsView.swift:73-75`) stays visible to someone who JUST purchased, re-offering
  the half-price deal; (b) `checkPaywallReentry()` re-runs on every foreground
  (`PostGateRootView.swift:264-267`) against a launch-time snapshot, so a trial expiring
  mid-process keeps access. **NOT fixed by design:** Architect-gated monetization surface,
  unverifiable without the operator's RC key (the R41.1 "never touch a gated surface unverified"
  lesson). It is a named rider on `operator-expected.md` §8 — land it in ONE run WITH the key,
  before the sandbox matrix, which is the test that proves it.
  **R46.4 (NOTE, not a defect)** — the `UITEST_RESET` hook (`UnhookedApp.swift:62-74`) clears
  `QuizProgressStore.key` but not `TrialAnalyticsDedupeStore.key`. TEST SCAFFOLDING only — the production
  `eraseEverything()` clears it (`QuitRepository.swift:681`), and the key is unwritable today (downstream of a
  consent gate AND dormant RevenueCat). Not worth a billed run; tidy it in passing if a session touches the hook.
  **R46.5 (FORWARD-LOOKING, for the G0/CloudKit step)** — the duplicate-fold path
  (`recomputeDerivedState`/`adoptChildren`) exists FOR CloudKit and is the least production-exercised code in
  the data layer; two S46 refutations leaned partly on CloudKit being dormant (`cloudKitDatabase: .none` until
  G0 registers a container). **When the operator turns the container on, that fold deserves its own focused
  session** — it is the one place a sync-ordering surprise could merge two real quits and their children.
  **R46.3 (LOW)** — `QuitRepository.swift:1380` `refreshPanicSnapshot()` (launch-time) rewrites
  the widget feed without `scheduleWidgetReload()`, so a launch-time heal is invisible to the
  widget until the planner's next natural `refreshAfter`. Deliberately NOT fixed: a reload on
  every cold start spends WidgetKit's rate-limited budget — an owner tradeoff, not a bug.
- **R46.6 (ready-to-ride, source-comment fidelity — MILDLY DANGEROUS if left):**
  `App/Sources/Persistence/PersistentStore.swift:6-10` still reads "CloudKit mirroring is configured EXPLICITLY
  off **until Gate G0 clears**… when the rename lands, **this is the one line that flips** to
  `.private("iCloud.<newname>")`." G0's technical half LANDED 2026-07-08 and the line deliberately did NOT flip,
  because **v1 is local-only by design** — entitlements declare App Groups ONLY (no iCloud), the sync seam is
  `LocalOnlyCloudSync`, and the positioning copy promises "No server. Nothing to leak." / "never leave your
  device." As written the comment reads as a PENDING TO-DO, so a future agent could "finish" it and silently
  break the privacy promise AND the App Privacy label. Reword to "v1 ships local-only BY DESIGN; enabling
  CloudKit is a post-v1 decision that re-derives the privacy label + manifest." Comment-only ⇒ needs a billed
  run ⇒ **batch it, never standalone.**
- **Ready-to-ride agent items:** (a) the `StreakWidgetStyle` "15" → "29" comment — ✅ **DONE S46**
  (batched into the R46.1 run, exactly as the rule prescribes). (b) two repository-tier
  integration tests for `winbackEligible`/`paywallReentry` — STILL BANKED; the pure
  `WinbackPolicy` is thoroughly pinned, only the `FetchDescriptor<AppSettings>` store-read shim
  is uncovered (seed stamp@epoch +7d ⇒ eligible, +6d ⇒ not, via the existing Harness). S46
  deliberately did NOT batch it: a new app-lane test file cannot be typechecked on the Linux box,
  so it carries red-run risk, and it is non-launch. **Its natural home is now the R46.2 fix
  session** — that session will be exercising exactly this path with a live key.

## Next session objective — ME-3, milestone unlock moments (NOT blocked)

**§0 is answered.** The operator chose **(B) — the redesign runs before launch** — and said so as a
standing instruction: *"take all the designs live, don't wait for my approval."* Waves 1–2 landed in a
parallel session, wave 3 is S50. **There is no operator gate on continuing.** The authoritative per-item
state is the **Execution status** table at the top of `redesign/design-roadmap.md`.

### What ME-3 is, and why it is cheap

Almost all of it already exists. **43 milestone bodies ship** in
`App/Resources/Content/milestones.json`, lexicon-gated and pinned by `MilestoneCopyTests`; wave 2's
`StreakDetailView` already renders the catalog as a timeline. What is missing is the *moment*:

- a quiet **unlock card** on Home (UX §6.20): raised card → the milestone glyph in **Ember**
  (`#E8833A` light / `#F29D5C` dark — the sanctioned SECOND spend of Ember, which is what warms a palette
  the brief calls "cooler than intended") → title → the "commonly reported" body → a quiet "See all" into
  Streak Detail's timeline;
- the **waterline rise** motion: the crest lifting over the horizon line in ONE 600ms breath
  (`Theme.motion.calm`) + one soft haptic. **Never confetti, never sound, never a modal.** Reduce Motion →
  it simply appears already-risen;
- the **discreet variant**: time-only catalog title + "A marker worth noting. Your numbers tell the story."
  (copy doc §9), and **no Ember** — a discreet surface names nothing and celebrates nothing loudly;
- appears once per unlock, dismisses on tap or next visit.

**Milestone text must never reach the widget feed** — `Shared/Sources/WidgetFeed.swift` is a §10
pre-unlock-readable surface.

### Read these first, in this order

1. **`docs/past-prompts.md` Session 50** — four of its rulings generalize, and three of them are about
   not trusting a plan (see the S50 additions under the standing rules above).
2. `redesign/ui-ux-redesign.md` §6.20 (the unlock card) and §6.17 (Streak Detail, already built).
3. `redesign/design-roadmap.md` — the Execution status table, then ME-3's row.
4. `docs/operator-expected.md` §0 — append every DRAFT string you ship to the founder pass list. Do not
   author safety-adjacent copy.

### Budget shape that has worked twice now

Two billed runs, planned as: **run 1** lands the code plus any new goldens (record-missing writes-then-fails
— NEW goldens are never born-green, R32.4) and, in the SAME run, any new audit leg, because the snapshot and
UI-smoke lanes are independent steps in one job and one run therefore buys both the recorded PNGs and the
full audit ledger (the S40 enumerate-all-from-one-run rule). **run 2** adopts the goldens after visually
verifying every PNG, plus whatever run 1's ledger named. Everything provable on Linux — parse gate, executed
harnesses over real bytes, lint-idiom greps, the three free package lanes — is done BEFORE run 1.

### Triggers that are live and independent of ME-3

- **The Superwall key** → create the app, then two placements (`quiz_completed`, `winback`), the
  teaser-vs-hard and the $29.99-vs-$39.99 experiments, then hand an agent the variant ids for
  `SuperwallPlacement.variantMapping`. Also assign the review build to the TEASER arm — that is the
  dashboard setting that makes the S46-ratified 3.1.2 posture true.
- **The TelemetryDeck app ID** → wakes the transport (today it is a Noop sink; zero bytes leave any build).
  Batch the banked win-back repository-tier integration tests into that run — they must never be spent
  standalone.
- **An ITMS-9105 reply** → land the named category + reason code (a two-line XML edit plus its
  `PrivacyManifestTests` pin), or delete the §8 checkbox if the operator confirms no email ever arrived.
- **QW-3** (the remaining dormant analytics fire-points) and **QW-8** (the consent revisit toggle, whose
  home — *Privacy & Data* — ME-7 just built) are both small and unblocked if a session wants a smaller unit
  of work than ME-3.

### [ARCHIVE] Session 40 — UIR-5c: the remaining UIR polish (all DONE)

UIR-0…4 + UIR-5a are DONE; UIR-5b (S39) deferred the settings audit leg. The items below were INDEPENDENT;
each was its own red→adopt→green golden batch.

1. **Session-open checks:** the standing three-way operator check + `which uipro`.

2. **Widget typography (R34.7): ✅ DONE (Session 40, 2 billed runs, zero theory-failures).** Rectangular
   numeral → `.system(size: 20, weight: .semibold).monospacedDigit()`; rectangular money+"saved" SPLIT
   (money mono, "saved" 12pt Medium tracking); medium savedLabel/milestoneLabel → 12pt Medium tracking
   +0.3. 9 goldens re-recorded + visually verified. An 8-agent verify+critique workflow caught the
   line-168 blocker up front. Flagged to operator: numeral `.semibold` vs `.bold`; medium labels
   fixed-12pt. Original plan (banked for reference): the EXACT spec + call-site map was
   (`docs/frontend-brandkit.md` §3 lines 124–125: `type/widgetNumeral` rectangular ~20pt /
   circular ring-center ~17pt / **Semibold–Bold** / monospaced digits — SF Compact, NOT rounded (§3
   line 110: rounded is dashboard-numeral-only); `type/widgetLabel` ~12pt / **Medium** / **tracking
   +0.3**). File `Shared/Sources/StreakWidgetViews.swift` (luminance-only, NEVER Theme; point sizes are
   the INTENDED widget form — Shared/Sources is outside the lint scope + widgets aren't audited). The
   THREE call sites (small/medium numerals already exceed 20pt via `.title2.bold` — do NOT touch them):
     - **line 165** `rectangular`: `primaryDayLine(font: .headline)` → `.system(size: 20, weight:
       .semibold).monospacedDigit()`. Affects `rectangularFamily{,_discreet}.{light,dark}` = **4
       goldens** (rectangular has NO ax5).
     - **line 238** medium `savedLabel`: `.caption2` → `.system(size: 12, weight: .medium).tracking(0.3)`.
     - **line 244** medium `milestoneLabel`: same as line 238.
       Medium labels affect `mediumFamily{,_discreet}.{light,dark,light-ax5,dark-ax5}` = up to **8
       goldens** (discreet-medium hides money→savedLabel; confirm from `StreakWidgetSnapshotTests`
       whether discreet renders `milestoneLabel` before deleting its goldens — delete ONLY the ones
       that actually change, ~8–12 total). Do NOT change label TEXT/case (copy, operator-owned).
       Weight `.semibold` vs `.bold` on the lock-screen numeral is a §3-range judgment (both comply;
       §3 says "heaviest that fits") — FLAG the choice to the operator. Maneuver: edit → `git rm` the
       changed goldens → run 1 record→red → `gh run download <id> -n test-outputs` → VISUALLY VERIFY
       each (bigger rectangular numeral; tracked medium labels; nothing else moved) → adopt → run 2 green.

3. **`StreakRing` motion (`Dashboard/StreakRing.swift`)** — golden-safe ONLY if the snapshot captures
   the SETTLED frame. RISK: an `.onAppear`-triggered animation renders the FIRST frame unsettled →
   breaks dashboard goldens. Structure it so the DEFAULT render is settled (e.g., gate the animation
   off under snapshot/reduce-motion, or animate a property identical at rest). Verify the 8 dashboard
   goldens do NOT move (they must stay byte-stable). Defer if it can't be made deterministic.

4. **Reasons-frame AX5 title (R35.6)** — the panic reasons title truncates at AX5 (a paging→scroll
   treatment). NOTE: panic is a rule-11 AUDITED leg (passed clean S35), so this is the NON-audited
   title truncation; fixing it likely re-records the panic `*ax5*` goldens — budget + visually verify.

5. **The SETTINGS-CONTENT audit [OPTIONAL/deferrable — the S39 iceberg].** If attempted: title =
   free-standing `.largeTitle` `Text` ABOVE the List (R39.2, PROVEN — never a List row); content = move
   the long List SECTION FOOTERS (e.g. the haptic-pacer footer) OUT of the `footer:` slot into scalable
   in-content rows. **ENUMERATE ALL findings from ONE audit run (or a local macOS run) BEFORE fixing** —
   do NOT whack-a-mole (S39 spent 3 runs discovering the depth). Re-adds the audit leg + re-records the
   2 settings goldens. A breadcrumb with this exact plan sits at the site in `DiscreetSettingsView`.

6. **Golden-batch PREP** for the operator §3 sitting (the final onboarding+paywall re-record waits on
   the founder copy pass — do NOT mint them; prepare the list). Zero-run documentation.

7. **Constraints:** copy BYTE-IDENTICAL; DORMANT monetization canon; widgets luminance-only (never
   Theme); no privacy surface. NEW STANDING NOTE (S39): never write `[skip ci]`/`[ci skip]` ANYWHERE in
   a commit message (body included) unless you intend the skip — GitHub honors it anywhere; docs/**` +
   `**.md` are already `paths-ignore`d so docs commits never run CI regardless.

**After UIR-5c the agent-doable UIR work is COMPLETE and the project is BLOCKED on the operator
critical path** (G0 rename, §3 copy pass, §8 keys + sandbox matrix, device rows + E0.3 latency,
external beta, submission) — see the operator-owned blockers below.

## Operator-owned blockers (not agent work; carry until closed)

1. E0.3 device measurement (`docs/spike-panic-latency.md`) — the one consolidated
   physical sitting (§7) clears it.
2. E3.3 + E6.2 + E6.3 device matrix rows + the lock-screen day-counter row + the S27
   safety-layer eyeball + the S28 eyes-free/VoiceOver eyeball.
3. Content tone review (§3) — the S30 review-notes DRAFT + OQ-1 + the S28 a11y block +
   S27 safety items + carried winback/teaser/paywallCopy/settings items + MVP §5/§6
   ratifications + the 3.1.1 riders. The §3 pass gates the FINAL golden batch
   (post-UIR: final copy + final palette, ONE re-record). **The dashboard's own copy
   is audited/data, so its 8 goldens are NOT in that batch — they are stable now.**
4. GitHub Actions billing headroom (§4 — Session 37 used exactly 2). Spend limit
   LIFTED; fan-outs available.
5. TestFlight testers (§5) — carried; the funnel E2E is machine-proven.
6. TelemetryDeck app ID (§8) — carried; gates the label/manifest wire-verify.
7. **§8 keys + config:** RevenueCat → Superwall → ASC promotional offer + IAP Key →
   the App Privacy label ENTRY (OQ-2 first) + the privacy-policy text. Sequenced at
   sandbox-matrix time.

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app **Ballast**, org `com.beyondkaira`).
> **You are NOT blocked. Your objective is ME-3 (milestone unlock moments).**
>
> **Where the project is.** Sessions 0–31 built the functional app; 32–40 (the UI Reactor) regenerated every
> screen onto the design system; 41–45 verified that terminal state five times; **46/47 were the first
> sessions to audit the shipped CODE rather than the plan** and found three defects no test could see — the
> 17+ age gate derived its year from the DEVICE's calendar (admitting 16.60-year-olds on an Islamic-calendar
> device), the quiz's money fields dropped everything after a comma so a European user's "12,50" was stored
> as 12 (and "0,50" as 0, which hides the money feature app-wide, permanently — spend has no edit path), and
> a projection under ten units floored onto the fabricated "~$0/year" the app's own rules forbid. **46B was
> the OPERATOR closing the §3 copy pass** (~20 decisions; ALO 182 corrected from a fabricated "crisis line"
> to the hospital-appointment line it actually is — the standing instruction to mark it verified would have
> shipped a life-safety defect; the alcohol notice made reachable pre-paywall; Terms/Privacy made real
> links). **48/48B/49/50 are the redesign program**, which the operator put ahead of launch in
> `operator-expected.md` §0 with a standing "take all the designs live, don't wait for my approval": waves
> 1–2 shipped the icon set, the erase UI, panic in-flow support, the widget-adoption moment with
> `widget_added` finally wired, Streak Detail, the panic wave timer and the Home shell — and took RevenueCat
> LIVE end-to-end. **Wave 3 (S50) rebuilt Settings (ME-7) and closed the last Mac-gated accessibility item.**
>
> **Your objective: ME-3.** `redesign/design-roadmap.md` (start at its **Execution status** table) + UX
> blueprint **§6.20** (the unlock card) and **§6.17** (Streak Detail — already built in wave 2). Most of ME-3
> exists: 43 milestone bodies already ship in `milestones.json`, lexicon-gated, and the catalog already
> renders. What is missing is the moment — a quiet Ember-lit unlock card on Home with the **waterline rise**
> (one 600ms `Theme.motion.calm` breath + one soft haptic; **never confetti, never sound, never a modal**;
> Reduce Motion → already-risen), plus the discreet variant (time-only title, no Ember). Milestone text must
> **never** reach `Shared/Sources/WidgetFeed.swift` (a §10 pre-unlock-readable surface).
>
> **READ FIRST: `docs/past-prompts.md` Session 50.** Four of its rulings will save you a billed run:
> **(1)** a plan's "free verification" step is a claim to CHECK — there is no `Packages/AppTests`, and
> *nothing* under `Tests/` runs on the Linux box (Xcode targets); write an executed harness over bytes
> **parsed from source**, proving pass-on-real-bytes AND fire-on-mutation. **(2)** every new
> `uiTest…Mount` in `PostGateRootView` needs its env var in `AgeGateContainerView.uiTestOnboardingMount`'s
> allow-list, or the leg times out after 15s with a message that blames the view;
> `UITestMountCoherenceTests` now catches that for free. **(3)** the §3 copy is FINAL and founder-owned, and
> `operator-expected.md` §7 quotes some strings BY NAME in a checklist a human executes — never restyle
> them; new strings ship DRAFT and get appended to §0's founder pass, and safety-adjacent strings are never
> agent-authored. **(4)** verify every proposed Apple API against the docs JSON **yourself** — S49's finder
> and its adversarial refuter invented the same nonexistent property, and S49's own recommended fix carried
> the wrong argument label.
>
> **Budget shape that has now worked twice.** Two billed runs: run 1 lands the code + records new goldens
> (record-missing writes-then-FAILS; new goldens are never born-green, R32.4) **and** ships any new audit leg
> in the SAME run — the snapshot and UI-smoke lanes are independent steps of one job, so one run buys both
> the PNGs and the full audit ledger. Run 2 adopts the goldens after **visually verifying every PNG** plus
> whatever the ledger named. Do every free check first: `swiftc -parse` on each touched file, executed
> harnesses, lint-idiom greps, and the three free package lanes (`swift test --package-path Packages/*` →
> 121 pass).
>
> **10 surfaces carry Apple's full 7-type accessibility audit** and five source lints gate every merge
> (Theme, layout, calendar, height-capped containers, mount coherence). Nothing is Mac-gated. **No operator
> action is required for you to proceed** — the remaining human work (clinician + counsel sign-off, the two
> published legal pages, G0 trademark clearance, device sitting #1, the sandbox purchase matrix, the
> Superwall + TelemetryDeck keys, external beta, submission) is sequenced in
> `docs/critical-path-post-uir.md` and runs on its own clock.

## Standing rules reminders (do not relearn these)

- **Theme canon (S32, amended S33/S34/S35):** `docs/design/tokens-v2.md` IS the palette
  record; `Theme.contrastPairs` is the WCAG gate (unit-lane, key-set pinned, grow-only —
  33 pairs as of S34); **the a11y audit set is now ONE FULL SET for EVERY leg (UIR-3
  closed the exclusion to zero; `safetyAuditTypes` is deleted)** — age gate/quiz/summary/
  dashboard/panic/slip all run the full seven; widgets stay luminance-only and NEVER
  import Theme; `AppSwitcherPrivacyOverlay` keeps its hardcoded surface hexes until its
  goldens are deliberately re-recorded; **`DiscreetSettingsView` keeps its system
  container background until UIR-4 — that is Session 36.** `Theme.type` holds ONLY glyph
  point sizes — no hero/text point size (R33.12).
  The `StreakRing` is a Shape (`Circle().trim().stroke(StrokeStyle(lineWidth:6))`), not a
  point-size glyph.
- **ADR-11 binding:** displayed "Day N" = 1-based CALENDAR day at local midnight in the
  quit's FIXED start timezone — never `TimeZone.current`, never `StreakValue.days`. Count
  by NOON anchoring. The feed zone travels as a STRING identifier. **The dashboard's
  `DashboardCardComposer.calendarDayNumber` inlines the exact `StreakTimelinePlanner`
  algorithm and is drift-guarded against the widget planner in the unit lane (R34.5) — the
  in-app "Day N" and the widget "Day N" can never disagree.** Durations are the
  exception-by-domain: teaser 24h wall-clock; win-back window 7×86_400s inclusive.
- Analytics ONLY via the closed enum; zero events before opt-in; the widget extension can
  NEVER fire analytics. Wire values: `ballast.monthly`/`ballast.annual`; `variant` ∈
  {"teaser","hard"}; `source` gains "teaser_expiry" (ratification pending); `offer` =
  {"winback_annual"}; `resources_viewed.source` ∈ {"settings","slip_flow"} CLOSED. purchase
  fires ONLY on user-initiated PAID completions; winback_converted co-fires BEFORE purchase.
  **The dashboard fires NOTHING — it is a display surface (R34.8).**
- **Privacy-manifest canon (S31):** TWO manifests, per-executable truth — app = UserDefaults
  [CA92.1, 1C8F.1] + the 3 label-lockstep rows; widget .appex = [1C8F.1] ONLY, collected
  EMPTY; NSPrivacyTracking=false always; reason codes ONLY from the fetched docs enumerations.
- **Entitlement canon (S23+S24):** the mapper has NO clock; the package persists ZERO bytes;
  present-but-inactive ⇒ `isActive:false` NEVER nil; unknown SKU honors an active entitlement.
- **DORMANT canon (S24–S26):** key absent ⇒ the SDK symbol is never referenced at runtime.
  NEVER call `Purchases.configure`/`Superwall.configure` without the operator key. The paywall
  is reachable ONLY via the live gate or DEBUG `UITEST_PAYWALL=1|teaser`.
- **Teaser canon (S25) / Win-back canon (S26):** single-use escape; entitled ALWAYS wins;
  eligibility = ANY `.lapsed` + stamp ≥ 7d; dismissible OFFER once per process.
- **Safety canon (S27):** the resources screen is STORE-FREE; only `verified: true` rows render;
  the GLOBAL region stays NUMBER-FREE; the E5.1 age-gate keeps its own funcs, byte-frozen; the
  alcohol notice is once-EVER app-wide, inline amber card, "Got it" ≥ prominence; helpline rows
  are NEVER lexicon-scanned; a helpline DIAL link is a 44pt-floor target (R33.10). **The alcohol
  notice + the pending-undo banner render inside the S34 dashboard (RootPlaceholderView) — UIR-3
  touches the panic/slip FLOWS, not these dashboard-mounted cards (UIR-4's surfaces, or they
  ride their own epics).**
- **A11y canon (S28, amended S32/S33/S34):** the eyes-free pacer preference is a §10-admissible
  pre-unlock bit; the panic route opens NO store. The audit family: panic/slip/**ageGate** legs
  are rule-11 (NEVER quarantined/valved/suppressed); quiz + summary + **dashboard** legs carry
  the R28.6 valve. **NO issue handler anywhere.** `UITEST_QUIZ`/`UITEST_SUMMARY`/**`UITEST_DASHBOARD`**
  mount their screens through BOTH levels with zero store dependency — `#if DEBUG`-walled,
  `.disabled`/no analytics. A template sentence with an unfilled token drops WHOLE.
  **`children:.contain` (not `.ignore`) lets each `Text` carry its own description when a composed
  a11y sentence is §3-blocked (R34.3) — the dashboard's clean first audit used this.**
- **Funnel-smoke canon (S29):** scenario-29 anchors on SURFACING elements only (nested `.contain`
  container ids never surface — R33.13); UITEST_EVENT_SPY arms the spy + bridge (DEBUG-inert
  otherwise).
- **Metadata-lint canon (S30):** the explicit-terms register is GRAPHIC-only; the metadata-medical
  register excludes detox/heal/toxin; helplines.json is never read; intent titles pin via
  `LocalizedStringResource.key`. Lexicons only GROW.
- The consent choice is a DEVICE SETTING; erase resets it OFF. Erase order: rows → infallible local
  clears → owned files → widget reload → `resetEntitlement()` → CloudKit purge LAST.
- No shame copy (lexicons only GROW); no medical claims (the milestone gate is PHRASE-ANCHORED); no
  red anywhere; motivations VERBATIM; the paywall bans countdowns/fake discounts/"one-time offer";
  prices are NEVER copy-table literals; the hard variant has NO close.
- Monotonic fields never decrease; streaks freeze, never inflate (ADR-7); the widget floors at
  Day 1 and runs NO clock guard (ADR-6). **The dashboard renders a frozen streak
  (`clockSanity == .clockRolledBack`) with its correct numbers + a neutral ring, no red, no alarm
  (R34.4) — the tooltip is §3-blocked.**
- WITNESS discipline: three advance paths only; widgets never advance it.
- Erase discipline: local-first; owned file-set = {panic-snapshot.json, panic outcome buffer,
  widget-state.json} in THREE enumeration sites; zero active quits ⇒ widget-state REMOVED;
  post-erase relaunch = fresh install (entitlements survive BY DESIGN).
- Panic path stays thin: panic surfaces NEVER open the store, query entitlements, teaser, OR
  winback state; the widget feed is label-free BY FIELD SET + presence-only discreet; the shield
  policy is tri-state FAIL-CLOSED.
- Never weaken a QA assertion; TDD red first (the R31.4 born-green valve is the ONLY sanctioned
  exception shape; NEW snapshot goldens are NOT born-green — R32.4); `cloudKitDatabase` stays
  `.none` until the §4.3 flip.
- Snapshot goldens: light/dark ×5 widget families ×normal/discreet + AX5 home-only; the DASHBOARD
  card ×{active(4 axes),discreet(2),frozen,reduce} = 8 (S34, on the tokens-v2 palette, copy
  audited — NOT in the founder batch); fixtures dated 2025 epoch; `pauseDate`/frozen clocks freeze
  tickers; the ONBOARDING + PAYWALL golden batch waits for the founder copy pass (post-UIR, ONE
  re-record); the panic/slip goldens are on the tokens-v2 palette (S32) and UIR-3 re-records them
  on the restyle. SnapshotTesting 1.19.3 + TelemetryDeck 2.14.1 + purchases-ios 5.80.3 +
  SuperwallKit 4.16.1 pinned EXACT.
