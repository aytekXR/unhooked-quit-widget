# Operator Expected — the live "what only aytek can do" checklist

| Field | Value |
|---|---|
| Status | LIVE — updated at every session close (operator request, Session 10) |
| Last updated | 2026-07-18 (**Session 40: the UI regeneration is DONE as far as a build agent can take it — the whole app is on your design system, and the ball is now entirely in your court.** This session finished the last polish: (1) the **lock-screen & home-screen widgets** got their two tiny typography touch-ups (the streak number is now the specified size/weight; the small "saved"/"next milestone" labels are the specified size + spacing) — your other 20 widget screenshots are untouched; (2) the **panic "your reasons" screen** now scrolls (instead of paging) at the very largest text sizes, so the screen title no longer gets cut off — verified in the screenshots; (3) the dashboard **streak ring** now gently animates in when the screen appears (a calm 0.6s fill) — this is the one thing a screenshot can't check, so **please glance at it on a real device** during your dashboard check; (4) a written plan (`docs/golden-batch.md`) for the ONE final round of screenshots you'll shoot once your copy is locked (the onboarding + paywall screens are the only ones still on draft copy). **One item is deliberately parked:** switching Apple's audit on for the SETTINGS screen turned out to need a Mac to see the full list of what to fix (the settings list's longer captions also get cut at the biggest text sizes) — it's a tidy, well-understood fix documented in the code, best done on a Mac rather than guessing over CI. **Nothing was required from you this session.** **From here it's all you:** the name/G0, your copy pass + the final screenshots, your keys + the sandbox purchase test, the device checks (incl. the new streak-ring glance), external beta, and submission. A couple of small brand calls are flagged for you (the widget number weight; whether the widget labels should grow at giant text sizes). |
| Superseded header (S39) | 2026-07-18 (**Session 39: we tried to switch Apple's accessibility audit on for the SETTINGS screen and found the problem runs deeper than expected — so we deferred it, cleanly, with nothing changed.** Here's the honest story: last session we saw that the big iOS title at the top of the settings screen ("Discreet Mode") doesn't shrink well at the largest text sizes. This session we fixed THAT (the title now scales properly) — but Apple's audit then flagged the settings LIST itself: the longer explanatory captions under some switches also get cut off at the very largest text sizes. That's a structural quirk of iOS grouped lists (the captions live in a slot that doesn't grow), and there's no quick one-line fix — fixing it properly means rebuilding those captions as normal rows and re-shooting the settings screenshots, and we couldn't see the full list of what needs fixing without spending a paid CI run for each guess. Rather than burn runs guessing, we **reverted the whole attempt** (the app is byte-for-byte back to where it was — your 107 screenshots and all 8 already-audited screens are untouched and green) and wrote down EXACTLY what the fix is, so a future dedicated pass can do it in one shot. **Net: nothing user-facing changed, the other 8 screens' audits are all still on and passing, and nothing is required from you.** Next: Session 40 = the remaining polish (this settings-list audit is now optional/deferrable; plus the streak-ring animation, the small widget-typography touch-ups, and the largest-text edge case on the panic "reasons" screen). |
| Superseded header (S38) | 2026-07-18 (**Session 38 CLOSED: UIR-5a DONE in exactly 2 billed runs (the 2 planned; ZERO burned).** What that means concretely: **Apple's accessibility audit now covers your PAYWALL too** — the screen a non-subscriber hits — and it passed the full audit CLEAN on the very first try (the S36 paywall fixes hold up). That brings the number of screens under Apple's on-every-merge accessibility audit to **eight**: age gate, quiz, summary, dashboard, panic, slip, resources, and now paywall. We also switched on an automatic check that keeps the paywall's code free of the text-scaling mistakes we've been hunting all epic. **Not one word of copy moved; no goldens changed.** **One honest deferral:** we tried to switch the audit on for the **settings screen** too, and it flagged a real issue — but the issue is in the big iOS **navigation-bar title** at the top of the screen ("Discreet Mode"), which is a built-in iOS behavior that doesn't shrink cleanly at the very largest text sizes, NOT anything in the themed content below it (the settings rows themselves are clean). The fix is to switch that title to the compact style, which re-shoots the 2 settings screenshots — a tidy, low-risk change we split into the final polish session to keep this one clean. **Session-open check: NOTHING was required from you, open to close.** Next: Session 39 = UIR-5b, the FINAL polish pass (the settings title fix + motion niceties + the widget-typography touch-ups + the largest-text-size edge case).) |
| Superseded header (S37) | 2026-07-18 (**Session 37 CLOSED: UIR-4b DONE in exactly 2 billed runs — and with it, UIR-4 is fully complete.** What that means concretely: the **settings screen** is now on your design system too. It had been the last screen still wearing the plain iOS system look; it now uses your surfaces and your teal, while keeping the native iOS list behavior (which is the most accessible option). **Not one word of copy moved**, no behavior changed. That means **every screen in the app has now been regenerated onto the design system** — onboarding, dashboard, panic, slip, resources, paywall, and settings. What's left of the UI work is one final polish pass (motion/animation niceties, a couple of tiny widget-typography touch-ups, and the largest-text-size edge cases) — after that, the whole UI regeneration is DONE and the ball is entirely in your court (the operator checklist below: the name/G0, your copy pass, your keys + the sandbox purchase test, the physical-device checks + the panic-speed measurement, external beta, and submission). **Session-open check: NOTHING was required from you, open to close.** Next: Session 38 = the final polish pass (UIR-5).) |
| Superseded header (S36) | 2026-07-18 (**Session 36 CLOSED: UIR-4a DONE in exactly 2 billed runs (the 2 planned; contingency UNUSED, ZERO burned).** What that means concretely: the **resources/help-lines screen** and the **paywall** are now on the design system, and **not one word of your copy moved**. On the SAFETY screen (the help-lines a user reaches from settings or a slip), we closed two real defects: the help-line card was drawn with a raw system material that our contrast checker can't verify (now a proper themed card), and — the important one — **the button that DIALS a help line was less than half the minimum tappable size, and a screen-reader announced only the bare phone number**. It is now full-size and announces "Call [name]". Apple's accessibility audit now covers this screen too, and it passed clean on the first try. On the **paywall**: three buttons dimmed their text below the readable contrast floor while a purchase was in flight (Apple's audit flags this), and the error banner's text was nearly invisible on its own background — all fixed; the pricing, the no-countdown/no-tricks rules, and the "you can always restore/retry" guarantee are unchanged. **One thing we deliberately deferred:** the **settings screen** still uses the plain iOS system look; regenerating it onto your design system is the biggest and least-urgent piece, so we split it out to the next session to keep this one clean and low-risk — it changes no behavior and no copy. That leaves just settings + the final motion/polish pass before the whole UI regeneration is done. **Session-open check: NOTHING was required from you, open to close.** Next: Session 37 = the settings screen + the final polish pass.) |
| Superseded header (S35) | 2026-07-17 (**Session 35 CLOSED: UIR-3 DONE in exactly 2 billed runs (the 2 planned; contingency UNUSED, ZERO burned).** What that means concretely: the two screens a user meets in a hard moment — the **panic flow** (the 90-second reset) and the **slip flow** (the calm "you slipped, here's your best, undo if you want") — are now rebuilt on the design system, and **not one word of your copy moved**. What a user with poor eyesight would notice, and it is the whole point of this session: every button and prompt on these screens now **grows with their text size and reflows cleanly** — the tappable targets get taller to fit bigger text instead of clipping it, and the screens scroll so a big-text title or a long prompt is never cut off. **Apple's text-scaling accessibility audit is now switched ON for these two screens too — and they passed CLEAN on the very first try** (the second screen in a row to do that). That closes a milestone: **Apple's full accessibility audit is now ON for EVERY screen we've built** — age gate, quiz, summary, dashboard, panic, and slip. The "switched-off list" that Session 28 had to create is now EMPTY. Because these are SAFETY screens, an internal design panel (PM + Brand + QA) signed off on the redesign before a line of code was written, and the calm, no-red register is unchanged. One small thing we deliberately did NOT change: on the panic "your reasons" screen (the one that shows your own words very large), at the single most extreme text-size setting the screen TITLE gets shortened with a "…" so your words still get the whole screen — a cosmetic edge case on a screen Apple's audit doesn't police, logged for the final polish pass. **Session-open check: NOTHING was required from you, open to close.** Next: Session 36 = UIR-4, the paywall + settings + resources screens.) |
| Superseded header (S34) | 2026-07-17 (**Session 34 CLOSED: UIR-2 DONE in exactly 2 billed runs (the 2 planned; contingency UNUSED, ZERO burned).** What that means concretely: your app finally has the REAL dashboard your brand kit always specified. Since the earliest builds, the screen a user lands on after onboarding has been a literal placeholder — a "walking skeleton" card that said "Nothing here yet." It is now a proper streak card, one per quit: the big **Day N** counter, the money saved, a momentum ring, and a next-milestone progress bar — the most-looked-at screen in the app, built for the first time. **Not one word of your copy moved** (machine-checked: no copy table touched, and every label on the card is either already-approved wording or a pure number). What a user would notice: the app now looks finished the moment they finish the quiz. What a user with poor eyesight would notice: the whole card grows with their text-size setting and reflows cleanly (the ring steps aside), and **Apple's accessibility audit now checks this screen on every merge — and it PASSED CLEAN on the very first try.** That is a first for this project: every screen we've audited before turned up at least one real defect on its first audit. This one didn't, for a good reason — last session cost us a run to learn Apple's exact text-scaling rule, and this session we built to that rule from the first line, with an automatic check that catches any slip before it ever reaches Apple's audit. **On the widgets:** we reviewed all five lock-screen families against your type spec and found them essentially on-spec — two tiny typography nits (a number one size too small, some labels a hair light) that we deliberately DID NOT touch, because fixing them would re-shoot ~13 of your widget screenshots for a change nobody would notice; they're logged for the final polish session, and your 29 widget screenshots stayed byte-for-byte identical. **Session-open check: NOTHING was required from you, open to close.** Next: Session 35 = UIR-3, the panic + slip screens.) |
| Superseded header (S33) | 2026-07-14 (**Session 33 CLOSED: UIR-1 DONE in exactly 2 billed runs (the 2 planned; contingency UNUSED, ZERO burned).** What that means concretely: the four screens a new user actually meets first — the age gate, the quiz, the consent step and the savings summary — are now REBUILT on the design system from Session 32, and **not one word of your copy moved** (machine-checked: no copy table touched, not one new user-facing string in any of them). What a user would notice: the summary is finally the CARD your brandkit always specified, the quiz's answer chips are true pills instead of the almost-pills they had drifted into, and every button on the way in speaks the same visual language. What a user with poor eyesight would notice is bigger: **the text on these screens now actually grows when they turn up their phone's text size** — and Apple's own accessibility audit now CHECKS that on every merge, for the age gate and the summary for the very first time (two screens that had never been audited at all; the age gate is now a safety-grade check that can never be switched off). The text-scaling audit that Session 28 had to switch off is now back on for ALL of onboarding — the switched-off list has shrunk for the second session running, and only the panic and slip screens are left on it (Session 35's job; we already know the exact 5 elements at fault). **We also fixed a real safety defect nobody had noticed:** on the screen an under-17 visitor is sent to, the button that DIALS the helpline — the one thing that screen exists to get tapped — was barely half the minimum tappable size. It is now full-width at the floor. **The session's discovery, and it cost the run it was worth:** Apple's audit rejects any text sized by a fixed number — even when that number is wired to grow with the user's setting, which is what every guide (and every one of our own design agents) will tell you to do. It also rejects SwiftUI's `ViewThatFits`, the standard tool for "use a stacked layout when the text gets big" — the very thing your brandkit asks for. We only learned this by reading the audit's own screenshots out of the failed run (it named `~$1,350` and `/year`). Both facts are now enforced automatically so no future screen can repeat them. One process note worth your eye: two independent reviewers insisted we pre-emptively switch off part of the age-gate check (they predicted the year-wheel and the helpline link would fail it). We refused and let the run decide — **both predictions were wrong; the age gate passed clean.** Had we listened, a safety-grade check would have been permanently half-blind, on a guess. **Session-open check: NOTHING was required from you, open to close.** Next: Session 34 = UIR-2, the dashboard + the lock-screen widget families.) |
| Superseded header (S32) | 2026-07-14 (**Session 32 CLOSED: UIR-0, the UI Reactor's design-system session — DONE in exactly 2 billed runs (the 2 planned; contingency UNUSED, ZERO burned).** What that means concretely: your app now has a REAL design system in code — one Theme layer every screen reads its colors from, machine-verified against WCAG before anything renders it — and **the accessibility CONTRAST audit that Session 28 had to switch off is back ON, permanently, on all three audited flows** (panic, slip, quiz). The S28 findings you deferred (teal buttons and gray text your users couldn't read — 18 failing element pairs, the worst at 1.38:1 where 4.5:1 is the floor) are CLOSED by construction: the new palette is your brandkit's, but machine-checked — and the check found your brandkit's own §2 prose carried four contrast claims that don't hold on real surfaces (its caution amber, positive green, indigo and gray-caption values all computed BELOW their stated ratios; five light-mode hexes were nudged darker by a few percent to fix it — imperceptible hue-wise, documented side-by-side in the new `docs/design/tokens-v2.md` §7 — dark mode needed zero changes). Every panic/slip screenshot golden re-recorded on the new palette (64 files, including the 2 stale ones carried since S28 — that debt closes); the 31 widget/overlay goldens provably did not move. A permanent unit gate now FAILS the build if any future color edit dips below WCAG — the audit can never silently rot again. **The session's real discovery:** Apple's contrast audit DOES inspect DISABLED buttons, and SwiftUI's plain button style silently re-dims a disabled label to ~50% opacity on top of whatever color you set — so a button that computes 5.9:1 on paper renders at 2.1:1 on screen (we measured the actual pixels in the run's own artifact). The disabled CTAs now ride our own button primitive, which renders exactly what the tokens say. **ALSO: the §9 uipro mystery is SOLVED, nothing needed from you** — uipro WAS installed on this box all along, as an npm command-line tool (the previous session's probes looked at AI-assistant plugin surfaces, not the shell PATH). It generated design input this session; where its stock suggestions contradicted your brand rules (every palette it offers ships a RED destructive color — banned in this product) your brandkit won, with the adopt/override record in tokens-v2 §8. **Session-open check: NOTHING was required from you, open to close.** One process note in the interest of honesty: you killed the session after the final green run but before its documentation commit; the close was reconstructed from the run artifacts and the session's own on-disk drafts — no code was re-run and no CI runs were re-spent. Next: Session 33 = UIR-1, the onboarding redesign (age gate + quiz + consent + summary) on the new system.) |
| Superseded header (S31) | 2026-07-14 (**Session 31 CLOSED: R30.6 DONE in exactly 1 billed run — born-green ruled, contingency UNUSED, ZERO burned; the LAST Apple submission blocker in the build is closed.** What that means concretely: your app now ships the `PrivacyInfo.xcprivacy` "required-reason API" manifests Apple has rejected apps without since May 2024 — and the docs-check gate earned its keep TWICE: (1) the reason code carried since S30 (CA92.1) turned out to be the app-only code; the App-Group suite your panic pre-cache rides needs a DIFFERENT documented code (**1C8F.1**) — the app manifest declares both, each tied to verified call sites; (2) a finding nobody had: **the widget extension needs its OWN manifest** — the panic intents run inside the widget process and write the App-Group launch flag, so Apple's per-executable rule mandates a second manifest in the .appex ([1C8F.1] only, honestly empty collected-data). The app manifest's collected-data half now mirrors your App Privacy label doc row-for-row — **label and manifest move TOGETHER from now on** (if counsel repicks the OQ-2 taxonomy, one session updates label doc + manifest + pin as one edit). Permanent key-set pins gate all of it in CI; LiveClock's boot-time-ish reads were classified OFF Apple's list (no false declaration). **Session-open check: NOTHING was required from you, open to close.** TWO more things from this session: (a) **your UI Reactor mandate is in the roadmap** — v1.1 adds Phase 2.5 (Epic UIR: full UI/UX regeneration in 6 sessions, copy bytes untouched, closes the S28 WCAG contrast debt by construction, gates submission screenshots — waivable by you); **Session 32 = UIR-0, the design-token session**; (b) **the "uipro" tool you reported installed is NOT visible on the build box** — checked twice (skills, plugin marketplaces, MCP tools); see the NEW §9: tell us where it lives or how to install it and UIR will drive it; meanwhile UIR proceeds on the documented workflows. Budget FYI: your **Claude monthly spend limit is NO LONGER hit** — verified empirically this session (a canary + a 6-agent sweep/verify/judge workflow ran clean); the §4 S30 item is closed.) |
| Superseded header (S30) | 2026-07-13 (**Session 30 CLOSED: E10.2 submission-package prep, the BUILD-side half — DONE in exactly 1 billed run, contingency UNUSED, ZERO burned.** What that means concretely: the submission package now exists as far as a build agent can take it — (1) **`docs/review-notes.md`**, a paste-ready App Review notes DRAFT (the age-gate/quiz path, why there is no demo account, exactly how a reviewer exercises the lock-screen Panic control, the 17+ clinical posture, the privacy story) with every claim anchored to a shipped test so you can defend it — your clinician+counsel pass is its ship gate, and the three decisions it deliberately does NOT make for you (teaser-vs-hard review build, keys-at-submission, the 17+ rating) are surfaced in its §3; (2) **`docs/app-privacy-label.md`**, the App Privacy label derived row-by-row from the code (three collected rows, all "not linked / not tracking": product interaction + the habit CATEGORY + purchase history once your RC key lands; NO identifiers row; code-derived until your §8 app ID lets the MITM audit verify it on the wire) ready for you to enter in App Store Connect — one taxonomy judgment call is yours/counsel's (OQ-2, veto list); (3) a **permanent explicit-terms/no-medical metadata lint** now gates every merge (born-green — your shipping surfaces were already clean: 357 copy strings + the bundle names + the widget/control strings, zero violations); (4) **`docs/submission-checklist.md`** wires every MVP §7 release box to its exact CI evidence or its operator owner — NO box was auto-ticked, and the honest gaps are named in it. **TWO real finds worth your eye:** (a) **the app ships no PrivacyInfo.xcprivacy "required-reason API" manifest — Apple rejects apps without one (since 2024); a REAL submission blocker, and Session 31 (the last build session) closes it — no action needed from you**; (b) two in-app spots render the words "Porn"/"Weed" (the panic multi-quit picker + the widget setup screen) — the Brand seat wants "Adult content"/"Cannabis", but an existing brand-signed test deliberately PINS the current words, so it is YOUR call (OQ-1, veto list; not an App-Review blocker either way). **Session-open check: NOTHING was required from you, open to close.** One budget FYI (§4): your **Claude monthly spend limit was hit mid-session** — the agent panel's last worker died on it (zero loss; findings were already on disk by standing rule) and the session finished inline; until you raise it or the month rolls, sessions run without agent fan-outs (slower, not blocked). Session 31 = the PrivacyInfo.xcprivacy manifest, the last build session.) |
| Superseded header (S29) | 2026-07-13 (**Session 29 CLOSED: the StoreKit-config/contract session — the funnel is now MACHINE-PROVEN end to end, and the win-back's 50%-off purchase is one key-upload from live.** What that means concretely: the two-year-flaky "gate→quiz hang" was DISSOLVED with evidence — we parsed the failed run's raw test archive on the Linux box (screenshots + accessibility trees, no Xcode needed) and found the quiz had been mounting FINE all along; the old test was waiting on an identifier that never appears in the accessibility tree, while the seeded fallback's stall is a real named app defect (a store-open failure is silently swallowed with no retry — documented in code, deferred by name for the recovery-flow epic). The funnel smoke re-landed on correct anchors and PASSED ITS FIRST RUN: real age gate → the 11-step quiz → summary → paywall mount, with every analytics event's order asserted end-to-end through a new consent-honest debug event spy (it can only ever see what the consent gate lets through — structurally). The win-back seam: RevenueCat signs promotional offers SERVER-side with your In-App Purchase Key — we proved no keyless path exists — so the complete signed-purchase code is BUILT and dormant, the local StoreKit test config declares the same winback_annual offer (CI-pinned against drift), and **your IAP-key upload is now the ONLY thing between the app and the live discount — zero further code.** **Billed runs: exactly 3 = the 2 planned + the contingency, ZERO burned** (§4: the red run matched all 5 predicted failures name-for-name — the 15th consecutive; the contingency went to a PRE-EXISTING panic-smoke flake our diff didn't cause: a tap swallowed mid-animation, artifact-proven, the drive now verifies every tap took). **Session-open check: NOTHING was required from you, open to close, and there are ZERO new asks** — §8's winback block just gained an update note (the signed path is built; your Xcode-26 open-and-save rider now also covers the new offer entry) and one vetoable ruling (on offer-config drift the purchase fails honestly rather than charging full price after "half price" copy). Session 30 = E10.2 submission-package prep, the LAST build session.) |
| Superseded header (S28) | 2026-07-13 (**Session 28 CLOSED: E9.3 DONE — the ACCESSIBILITY PASS; Epic 9's build half is COMPLETE.** What that means concretely: a visually-impaired user can now run the entire panic loop EYES-FREE — a new "Breathe with taps" switch in the settings sheet makes the breath pacer haptics-only, and the preference reaches even the cold lock-screen panic launch (the store never opens on that path — the bit rides the same pre-cached file the panic screen already reads); VoiceOver now reads honest labels through quiz, panic, and slip (the commitment slider speaks its WORDS — "Ready to start today" — never "50 percent"; every field/stepper/icon-picker state is named); the breath step gained a taps-anchored instruction because "Follow the circle" was literally false in haptics-only mode; and a PERMANENT runtime accessibility audit now gates every merge (Apple's own audit engine, driven through quiz/panic/slip on CI). The audit's very first run EARNED ITS KEEP: it caught a real broken VoiceOver sentence on the forgiveness screen ("Your momentum is still ." — an empty number slot; fixed, with a new never-dangle composition rule) and an untappable 4pt progress element (fixed). It ALSO enumerated real CONTRAST + TEXT-SCALING violations (your teal buttons and secondary text sit under WCAG on several frames) — those fixes are brand-palette decisions whose golden re-records cascade, so they are deferred BY NAME with the full finding ledger to the a11y-visual/golden-batch session (which already waits on your §3 copy pass — colors+copy+goldens land in ONE re-record). **Billed runs: 5 = the 2 planned + the contingency + 2 over, 1 BURNED** (§4 has the honest accounting: two docs-listed audit options exist only on macOS — the per-platform availability check is now a standing gate; every other run produced designed evidence, incl. two free golden re-records from CI's own artifacts). **Session-open check: NOTHING was required from you, open to close.** Your NEW asks: §3 gains the 4 a11y DRAFT strings (each with alternatives) + two copy niceties the audit surfaced; §7 gains a 2-minute eyes-free/VoiceOver eyeball. Vetoable rulings at the bottom — the DEFERRED CONTRAST findings are the one worth your eye. Session 29 = the StoreKit-config/contract session.) |
| Superseded header (S27) | 2026-07-13 (**Session 27 CLOSED: E9.1 + E9.2 DONE — the SAFETY LAYER is live in every build.** What that means concretely: a "Support & resources" row now sits at the bottom of Settings, the slip flow's forgiveness screen carries the same one-tap link (both routes — even a panic-descended slip), and both open a calm resources screen showing ONLY operator-verified helplines for the user's region; a user outside your US/TR maps meets an honest GLOBAL fallback — "call your local emergency number" + a pointer to findahelpline.com (a vetted 175+-country directory we live-checked) — never US numbers dressed as local, and NEVER an invented phone number (no legitimate worldwide crisis number exists, so the GLOBAL bucket is deliberately number-free); and the FIRST alcohol quit or reduce goal meets your safetyCopy.json withdrawal caution ONCE ever — a calm amber card on the dashboard, "Got it" always first-class, "See resources" one tap from the danger it names. E9.2's milestones audit is now a PERMANENT CI gate (phrase-anchored medical-claim lexicon + the "commonly reported" framing pinned on all 43 bodies) — the mechanical half of your §7 copy-audit signature is done by machines forever. **Billed runs: exactly the 2 planned, ZERO burned, contingency UNUSED** (the red run matched the panel's prediction name-for-name — the 13th consecutive — including the 6 slip-flow snapshot diffs the new link caused BY DESIGN; those goldens were re-recorded for FREE from the red run's own artifact instead of spending a third run). **Session-open check: NOTHING was required from you, open to close.** Your NEW asks: §3 gains the safety-copy block (the 4 alcohol-notice strings — your clinician+counsel pass is the SHIP gate, one disclaimer REWORD to eyeball, the new "Support & resources" label, and the GLOBAL fallback note incl. the findahelpline.com pointer to verify-or-veto) + the E9.2 audit signature; §7 gains a 2-minute safety-layer eyeball for the consolidated sitting. Vetoable rulings at the bottom — the notice's dashboard-mount gap (a hard-walled non-converter in the LIVE-keys era never reaches the dashboard, so never meets the notice) is the one worth your eye. Session 28 = E9.3 accessibility pass.) |
| Superseded header (S26) | 2026-07-12 (**Session 26 CLOSED: E7.3 DONE — Epic 7's BUILD half is now COMPLETE, and the whole monetization vertical stays fully DORMANT until you act.** The win-back: once your keys are live, a user whose trial (or paid plan) lapsed at least 7 days ago meets a calm 50%-off annual OFFER — "Your annual plan, now at half price. / $14.99 for your first year, then $29.99 per year. Cancel anytime." — at most once per app launch on re-entry, always DISMISSIBLE ("Not now" → dashboard; an offer never traps — your hard onboarding wall stays close-free), plus a persistent "See your plan options" row in Settings that only renders while eligible. The 7-day clock is an app-side observed-lapse stamp because we PROVED the alternative doesn't exist: Apple's win-back offers can't go below 1 MONTH and require prior PAID history (your 7-day trial-lapse cohort fails both), and RevenueCat's targeting has no lapse condition — so the discount mechanically rides an **App Store Connect promotional offer** you'll create at sandbox time (§8, NEW block incl. the In-App Purchase Key upload). **Billed runs: exactly the 2 planned, ZERO burned, contingency UNUSED** (the red run matched the panel's 11-test prediction name-for-name — the 12th consecutive). **Your session-open bug report (lock-screen day counter) was TRIAGED, no code change needed: the binary from 2 days ago predates the real widget — see the NEW §7 row (update + re-add the "Streak" widget once, ~2 min).** Your NEW asks: §3 gains 5 winback DRAFT strings + one mvp §6 ratification; §7 gains the day-counter row; §8 gains the promotional-offer block. Six-ish vetoable rulings at the bottom — the any-lapse eligibility and the once-per-launch offer cadence are the two worth your eye. Session 27 = E9.1 safety layer.) |
| Superseded header (S25) | 2026-07-12 (**Session 25 CLOSED: E7.2 DONE — the paywall now has its A/B variant brain, fully DORMANT until you act.** SuperwallKit 4.16.1 is linked (app target only), but with your Superwall key EMPTY (the shipping state) the SDK is literally never initialized — zero network, no identity minted — and every build renders the same hard-wall control paywall as last session; **TestFlight behaves byte-identically.** When you paste BOTH keys (RevenueCat first — the vertical wakes as a unit — then Superwall, the NEW §8 block), Superwall's dashboard decides teaser-vs-hard per install: the teaser arm adds a quiet "look around for a day" escape under the subscribe button (one day of full access, then the wall returns with a calm "your free day wrapped up" line — never a countdown), and the funnel events you'll read A/B results from (`paywall_viewed` with variant + source, `teaser_entered`, `purchase`) all fire only after consent. **Billed runs: 3 — the 2 planned + the contingency, ZERO burned** (the red run matched the panel's 16-test prediction name-for-name, the 11th consecutive; a would-be burn — a Swift concurrency trap in the one Superwall-importing file — was caught by the new standing probe on the free Linux box BEFORE the push; the contingency went to the quiz-funnel smoke's own pre-worded escape valve — it failed its single allowed run, but its new diagnostics finally DISPROVED the old wheel theory: the wheel was set correctly and the tap landed, and the gate→quiz hand-off still hung — a real finding the next diagnosis session starts from, with screenshots preserved in the failed run's artifact). **Your NEW asks: §3 gains 3 DRAFT teaser strings + two MVP §5 vocabulary ratifications, and §8 gains the Superwall key + dashboard block.** Seven-ish vetoable rulings at the bottom — the single-use teaser escape and the teaser-as-24h-duration are the two worth your eye. Session 26 = E7.3 win-back, closing Epic 7's build half.) |
| Superseded header (S24) | 2026-07-12 (**Session 24 CLOSED: E7.1 APP HALF DONE — the whole monetization vertical now exists in the app, fully DORMANT until you act.** purchases-ios 5.80.3 is linked, but with your RevenueCat key EMPTY (the shipping state) the SDK is literally never initialized — zero network, no anonymous ID minted, and the quiz-summary Continue button still goes straight to the dashboard: **TestFlight behaves byte-identically to last session's build.** When you paste your RC public key (the NEW §8 item), the summary routes non-subscribers to a real paywall screen — $6.99/mo + $29.99/yr with the 3-day trial (the $39.99 test arm waits for Superwall next session), restore + retry always reachable, the Apple-required renewal disclosures rendered on-screen. The trial-start analytics event fires once per install era, only after consent, and one-tap erase now also clears the entitlement caches (honest note: a data wipe can NEVER revoke a subscription — entitlements live on the Apple account, and that is correct behavior, not a gap). **Billed runs: 4 — the planned 2 + the contingency + ONE over, with TWO burned** (§4 has the honest accounting: a one-word Swift concurrency mistake in a NEW test file, then a module-naming collision in the one file that can only compile on Apple hardware — BOTH turned out to be reproducible on the free Linux box after the fact, and both classes are now permanently gated so neither can recur). **Your NEW asks: §3 gains the 20 DRAFT paywall strings + one REAL register decision (your mvp.md's "No server. Nothing to leak." canon was deliberately NOT placed on the RevenueCat-brokered purchase screen — read §3), and §8 gains the RC-key item.** Seven vetoable rulings at the bottom — the hard-wall-no-close and the erase-cannot-revoke rulings are the two worth your eye. Session 25 = E7.2 Superwall variants.) |
| Superseded header (S23) | 2026-07-12 (**Session 23 CLOSED: E7.1 PACKAGE HALF DONE — the app now has an entitlement BRAIN (PaywallKit 1.0.0), and nothing was needed from you, open to close.** The four-state machine (`never|trial|active|lapsed`) ships pure: no clock (offline can NEVER flip a paying user to locked-out — your architecture's anti-Quittr grace rule, enforced by construction), no persisted bytes (the "cache" is in-memory; RevenueCat's SDK owns durable caching app-side, later), no prices or SKUs (the state machine knows monthly-vs-annual and nothing else). Nothing renders it yet — no paywall screen exists; that is Session 24's job, and it is deliberate (the same package-half-first split your E6.1→E6.2 widget sessions used). **Billed runs: exactly the 1 planned, zero burned, contingency unused** (red evidence was FREE — the local Linux package lane predicted all 11 failing tests / 17 issues issue-for-issue, the 9th consecutive; red+green rode ONE push, CI `29192612869`). **Nothing new is expected from you** — §3 gains no strings (the package has no user-facing surface). One forward heads-up in §8: Session 24 wires RevenueCat DORMANT behind your RC key, exactly like the TelemetryDeck pattern you already know — your RC account + App Store Connect products become blocking only at sandbox-verification time, not for the build. Five vetoable rulings at the bottom; the one worth your eye is the OFFLINE GRACE call: a lapsed-while-offline trial keeps premium until the device next reaches RevenueCat — the direction your docs mandate, but it is a real product call now enforced by tests.) |
| Superseded header (S22) | 2026-07-12 (**Session 22 CLOSED: E6.3 discreet mode + alternate icons + the app-switcher shield DONE — every widget family now hides its habit on demand.** Toggle a quit discreet and its lock-screen widget shows "Day N" + a neutral "Reset" arrow — no money, no wind glyph; the app-switcher card goes blank; two new innocuous app icons ("Calendar style" / "Timer style") switch from the new one-screen settings sheet; one-tap erase now also puts the ORIGINAL icon back (OS icon state survives a data wipe — we reset it, plus a launch self-heal). **Billed runs: exactly the 2 planned, zero burned, contingency unused — the zero-burn streak restarts** (red evidence `29183485997` matched the prediction name-for-name, the 8th consecutive; green `29184196211` all-green + TestFlight). **Three things worth your eye:** (1) §3 gains the 8 DRAFT settings strings AND the two DRAFT GENERATED app icons — agents drew them to your brandkit's spec (pure-geometry tiles; regenerate anytime with `brandkit/branding-assets/generate-alt-icons.py`); veto or replace at will; (2) §3 also carries a REAL decision: your brandkit contradicts itself on whether the discreet icons may appear in App Store screenshots (§9.1 says never, §9.2's frame 3 shows one) — the panel says NEVER (one public exposure makes the "innocuous" icon reverse-image-linkable to Ballast forever); you own ASO, so you decide; (3) the veto list gains the Session 22 rulings — the most product-visible: the app-switcher cover only protects DISCREET users (the plan's spec); making it universal is a one-line change if you want banking-app-style protection for everyone. Session 23 = E7.1 PaywallKit.) |
| Superseded header (S21) | 2026-07-12 (**Session 21 CLOSED: E6.2 widget families + the widget feed DONE — a REAL five-family streak widget now ships on TestFlight.** The lock screen shows "Day N" + money saved + the panic button, self-ticking, timezone-fixed, erased clean by one-tap erase. **Billed runs: 4 — the planned 2 + the contingency + ONE over** (§4 has the honest accounting: one burned on a deprecated-API build failure the neighbor-copy rule should have caught — its closing gate is now standing; one spent on a single stale test fixture the new timezone field legitimately flipped, 243/244 green). **Two things worth your eye:** (1) the widget gallery now shows REAL strings ("Streak" / "Your streak, on your lock screen…") — they are DRAFT and join your §3 pass, alongside milestones.json which now ships in-bundle; (2) the veto list below gains six Session 21 rulings — the StandBy deferral and the SkeletonWidget retirement are the two most user-visible: **your testers' placed widgets vanished with the retirement; they re-add "Streak" once.** Session 22 = E6.3 discreet mode.) |
| Superseded header (S20) | 2026-07-12 (**Session 20 CLOSED: E6.1 widget timeline provider DONE — 1 billed run, zero burned.** WidgetToolkit stopped being a stub: it now owns the streak timeline planner (day rollover at local midnight, stale-grace, ticking counters). **Nothing was needed from you, open to close — and nothing new blocks Session 21.** Two things worth your eye, both below: (1) §4 — the "possibly ZERO billed runs" hope from the last close was WRONG and is struck; there is no such thing as a free code session. (2) The **NEW ADR-11 day rule** in the veto list: your widget will say "Day 2" the morning after someone quits on Tuesday night — not 24 hours later. That is a product decision and it is now binding on the dashboard too. Session 21 = E6.2, which finally makes a real widget render on the lock screen.) |
| Rule for agents | Update this file at session end alongside `resume-prompt.md`. It is TRACKED (in `docs/`) so the operator can read it anywhere on the go. The untracked root `OPERATOR-TODO.md` is now just a pointer here. |

The agent-doable UI regeneration is now COMPLETE (Epic 2.5 closed except the Mac-gated settings-list
audit, parked with a documented fix). Copy bytes never moved; no new SDK, no new key. **The whole
project now waits entirely on YOU** — the operator critical path below (the
G0 rename, your §3 copy pass, your §8 keys + the sandbox purchase matrix, the physical
device rows + the panic-latency measurement, external beta, and submission). ASO
assets/screenshots stay YOURS behind Gate G0 and wait on UIR (waivable); the FINAL
goldens batch still waits on your §3 copy pass and lands post-UIR as ONE re-record.
The dashboard's 8 + the 64 panic/slip + the 2 resources screenshots ARE stable now
(their copy is audited/data), so they are NOT in that final batch — only onboarding +
paywall still wait on your copy pass.)

> **Runway to launch (updated Session 31: R30.6 CLOSED — the pre-UIR build
> side is 100% DONE; your UI Reactor mandate re-shapes the remaining build
> runway).** A compliance-submittable build EXISTS as of today: both
> executables ship their required-reason privacy manifests, the review-notes
> draft, the label derivation, the metadata lint, and the §7 checklist are
> all in place. What stands between today and SUBMISSION is now: **(1) the
> UI Reactor (Phase 2.5, ~6 agent sessions, YOUR mandate — the current UI is
> below your bar; waivable if you change your mind: say the word and
> submission prep resumes on the current UI), then (2) the operator critical
> path unchanged.** The FINAL goldens batch waits on your §3 copy pass and
> lands post-UIR as ONE re-record (final copy + final palette together —
> the S28 promise, scope widened, count unchanged). E10.1
> (external beta, ≥15 testers) runs on YOUR clock in parallel — **internal
> TestFlight is already live** (today's Session 27 build is installable),
> and **the safety layer that was the recommended bar for distributing an
> addiction-category beta LANDED today** — external beta is unblocked from
> the build side. **Going LIVE is gated on the operator critical
> path, not on agent sessions:** the §3 copy pass (gates the golden batch),
> the two §8 keys + RC/Superwall dashboards + the ASC products + the NEW
> promotional offer/IAP-key items + the sandbox purchase matrix (gates
> Epic 7's DoD — now the FULL remaining Epic 7 scope), the TelemetryDeck
> app ID + §8 payload audit (gates Epic 8's DoD half), the §2/§7 device
> rows + E0.3 latency measurement (gates the release criteria), then E10.1
> beta and submission. None of it is urgent today; all of it is sequenced.
> **The ONE thing worth doing THIS WEEK: the consolidated physical sitting
> (~1 hour, §7)** — today's build + re-add the widget (your day-counter
> report) + the carried device rows + E0.3. One sitting clears four carried
> items AND verifies your bug report; the second physical sitting (sandbox
> matrix + payload audit) comes only after your keys/console work.
**§0 is CLOSED** (only its optional gstack FYI remains). Items below §0 are
ordered by how much they age; check a box by replacing `[ ]` with `[x]` and the
next session's agent will prune completed items.

> **Session 26 outcome (2026-07-12):** E7.3 is DONE — the win-back offer,
> closing Epic 7's build half. What that means concretely: the eligibility
> brain (an observed-lapse stamp + a pure 7-day-duration policy), both
> in-app surfaces (the dismissible re-entry offer + the eligible-only
> Settings row), and all four funnel fires now exist — and every bit of it
> is dormant behind your keys (no key ⇒ the app can never even OBSERVE a
> lapse, so the offer is structurally unreachable). The panel's
> docs-verifier killed the "let Apple/RevenueCat compute the 7 days"
> folklore with primary sources — App Store Connect win-back offers are
> months-only and demand paid history; RC targeting has no lapse cohort —
> so the mechanism is an ASC PROMOTIONAL OFFER (50% off year one on the
> same annual product), which is exactly the "config, not code" shape the
> plan wanted. The red run matched the 11-test prediction name-for-name
> (12th consecutive); exactly the 2 planned billed runs, zero burned,
> contingency unused. **Your session-open day-counter report: triaged, not
> a bug in current code — the 2-days-ago binary only ever had the
> placeholder widget (a hardcoded "Day 0"), and the real widget that
> replaced it uses a new widget identity, so the OLD placed widget died
> with it (documented Session 21). Fix is the NEW §7 row: update, re-add
> "Streak", open the app once. If it STILL fails after that, the §7 row
> tells you exactly what to record so the next session can hunt it with
> evidence.** Your NEW asks: §3 (5 winback DRAFT strings + the mvp §6
> in-app-only ratification + the 3.1.1 winback disclosure rider) and §8
> (the promotional offer + the In-App Purchase Key, sequenced at sandbox
> time). To SEE the winback screen from Xcode: it needs a live lapsed
> state, so it rides the sandbox pass — the composed copy is
> string-pinned meanwhile.

> **Session 25 outcome (2026-07-12):** E7.2 is DONE — the Superwall variant
> adapter. What that means concretely: teaser-vs-hard A/B machinery now
> exists end-to-end (the assignment seam, the 1-day teaser grant + its
> re-present rule, the three funnel fire-points, the variant echo field) and
> ALL of it is dormant behind your two keys — the panel's standing rule held
> again: the SDK is never initialized until you paste the key, because
> Superwall's own `configure` phones home and mints an anonymous identity
> the moment it runs (verified against the 4.16.1 source, not marketing —
> same as the RevenueCat finding last session). The red run matched the
> 16-test prediction name-for-name (11th consecutive); exactly the 2 planned
> billed runs, zero burned. Scenario-29 (the full quiz-funnel smoke) was re-landed,
> failed its ONE allowed run, and its pre-worded valve fired: it is
> deferred again — but this time WITH evidence (the wheel theory is dead;
> the gate→quiz hand-off itself hangs on CI, reproducibly), and the debug
> hooks it needs next time are landed and inert. **Your NEW asks: §3
> (3 teaser strings + two MVP §5 vocabulary ratifications) and §8 (the
> Superwall key + dashboard config, sequenced AFTER the RC key).** To SEE
> both paywall variants from Xcode: launch env `UITEST_PAYWALL=1` (hard) or
> `UITEST_PAYWALL=teaser` (teaser with the escape).

> **Session 24 outcome (2026-07-12):** E7.1 is DONE — both halves. What that
> means concretely: the app now contains the complete purchase machinery
> (the RevenueCat adapter, the product catalog, the entitlement model, the
> paywall screen at the quiz-summary seam, the consent-gated trial analytics,
> the erase hook) and ALL of it is dormant — the panel's standing rule is
> that the SDK is never even initialized until you paste your key, because
> the SDK's own `configure` call phones home and mints an anonymous ID the
> moment it runs (verified against the SDK's source, not its marketing).
> The red evidence run matched the panel's 28-test prediction name-for-name
> and issue-for-issue (the 10th consecutive predicted red). TWO runs WERE
> burned (a spurious `await` in a new test file, then a module-name
> collision in the one Darwin-only file — both warning/build classes are now
> permanently gated, and both turned out to be locally reproducible, which
> is exactly why the gates will hold). **Your NEW asks: §3 (the paywall copy
> pass + the positioning register decision + two legal riders) and §8 (the
> RC key + dashboard, when you're ready to test purchases).** The paywall is
> invisible to testers until then — no golden screenshots exist yet BY
> RULING (they'd bake your unreviewed DRAFT copy; they ride your §3 pass),
> so if you want to SEE the screen: run from Xcode with launch env
> `UITEST_PAYWALL=1`, or wait for E7.2's smoke.

> **Session 23 outcome (2026-07-12):** E7.1's PACKAGE half is DONE — PaywallKit
> 1.0.0 owns the entitlement state machine. What that means concretely: the
> logic that will decide "show the paywall or the dashboard" now exists, is
> 98.21%-covered behind a new CI-enforced 90% floor on the FREE Linux lane,
> and was adversarially reviewed (a reentrancy probe ran 1,600 concurrent
> refreshes against a slow event sink — the trial-start event fired exactly
> once, every time; three deliberate mutants were planted and every one was
> killed by the shipped tests). A new panel role born from Session 22's
> UIWindow lesson — the docs-verifier — checked every RevenueCat claim
> against the SDK's actual source and killed two pieces of folklore before
> any code used them. **Nothing from you was needed, and nothing new is
> asked** — no strings, no device rows, no decisions. The five Session 23
> rulings are in the veto list; the offline-grace one is the real product
> call.

> **Session 22 outcome (2026-07-12):** E6.3 is DONE — discreet mode is REAL on
> every family. The discreet flag rides the widget feed additively (Architect-
> approved field set; a non-discreet user's file is unchanged byte-shape);
> discreet rectangular/medium drop the money line entirely ("$412 saved" is an
> outing signal — the mockup's own transform); the medium milestone bar keeps
> its bar but drops the WORD "milestone" (recovery vocabulary; privacy-panel
> amendment); the panic button swaps to the same neutral counterclockwise
> arrow + "Reset" your Control-Center control already uses. The app-switcher
> shield is a real WINDOW above every sheet — the panel caught that a naive
> overlay would have left your warm-panic sheet (your verbatim motivations!)
> visible in the switcher — and it FAILS CLOSED: if the app cannot yet tell
> whether any quit is discreet, it covers. 16 new snapshot goldens recorded
> via the red run's own artifact (second session in a row the trick worked).
> **Your NEW asks: §3 (strings + icons + the screenshot decision) and §7 (four
> device rows).** Six vetoable rulings at the bottom — the widget_added
> deferral was UNANIMOUS (6/6 panel).

> **Session 21 outcome (2026-07-12):** E6.2 is DONE — the widget is REAL. Every
> mutating write now also rewrites `widget-state.json` (a deliberately minimal,
> label-free file: your habit category, motivations, and notes are NEVER in it —
> it is readable before first unlock, so its field set was privacy-ruled before
> code). Each quit remembers the timezone it was created in, so "Day N" rolls at
> YOUR midnight and a flight can never mint a free day. The widget gallery
> offers "Streak" in five sizes (lock-screen rectangular with the panic button,
> the day ring, the one-liner, and the two home sizes with money + momentum +
> the milestone bar); a per-widget selector binds each widget to ONE quit by id,
> so an erased or archived quit shows a calm "Ready when you are." instead of
> silently switching to another habit. One-tap erase removes the widget file in
> the same sweep (test-pinned in three places).
>
> **What earned its keep:** the adversarial critics caught TWO would-be burned
> runs before they happened (a missing cross-import that would have failed every
> target, and a timezone-decode inversion that passed on a Berlin-zone machine
> and failed on CI's UTC runner — reproduced, fixed, verified under three host
> zones). One run WAS burned anyway (a deprecated API in a new test file — the
> gate that closes that class is now permanent), and one more went to a single
> stale fixture (243/244 green). Honest total: 4.
>
> **Your NEW asks: §3 gains the widget gallery strings + milestones.json (both
> DRAFT, both now shipping); §7 gains the tinted-mode + widget device rows.**
> Six vetoable rulings at the bottom — StandBy deferral and SkeletonWidget
> retirement are the product-visible two.

> **Session 20 outcome (2026-07-12):** E6.1 is DONE — the **widget's brain**
> shipped. `WidgetToolkit` (the portfolio package that was a stub since Session 01)
> now owns the timeline planner: it decides when a widget re-renders (at the
> user's local midnight, so the day number turns over when *their* day does),
> keeps the last-known streak **ticking** when something has gone stale, and
> refuses to invent a number when there is no data (no "Day 0" on a fresh or
> erased device). **Nothing renders it yet** — the app half of the feed is
> Session 21's job, and that is deliberate: the plan tags this row
> "[PKG:WidgetToolkit]" and the app-side work would have cost two more billed runs.
> **Billed runs: exactly the 1 planned, zero burned.**
>
> **What earned its keep this session:** the review agents REPRODUCED five real
> bugs rather than reasoning about them, and one was serious — in Chile and Cuba,
> where the clocks spring forward *at* midnight, a user who quit on that day would
> have had their streak read **one day low forever**. It was invisible to every
> test that existed and is now pinned by one that fails on the old code. Also
> caught: "Day 0"/"Day -399" if someone sets their device clock back; the
> stale-widget flag being silently dead; and a timezone bug that would have
> detonated *next* session, inside the writer, far from its cause.
>
> **Your NEW asks: none.** Two FYIs: §4's budget correction, and the **ADR-11 day
> rule** in the veto list at the bottom (a genuine product call — please read that
> one).

> **Session 19 outcome (2026-07-11):** E8.2 is DONE — the consent step renders at
> the quiz's fixed slot 3 ("Share app usage data?" — plain-language helper, the
> two choices visually EQUAL, default off, nothing pre-selected, nothing sent
> before the choice), your pick persists to `AppSettings.analyticsOptIn` at the
> tap, and the hardwired consent-off closures are RETIRED: the one production
> analytics gate now reads your stored choice live on every fire, so an opt-in
> made mid-quiz governs that same run's later events (the summary's
> quiz_completed included) while a decline transmits nothing, ever. Post-erase =
> consent OFF again, re-asked (test-pinned). **`docs/payload-audit.md` is NEW —
> your operator-run MITM release gate** (mitmproxy procedure, the code-derived
> allow-list, a worked FAIL example, the archive checklist that feeds the App
> Privacy label); its §1 explains the sequencing: the property half can only run
> AFTER your §8 app ID ships in a build (the zero-before-consent half is
> verifiable even now). **Billed runs: exactly the 2 planned, zero burned**
> (red evidence `29164705316` matched the two-lane prediction issue-for-issue —
> the sixth consecutive harness-predicted red → green `29165381934` +
> TestFlight). Your NEW asks: §3 gains the 4 consent DRAFT strings (one style
> fork flagged); §8 gains the run-the-audit follow-up and is now the LAST gate
> on real funnel data. Ten vetoable rulings at the bottom.

> **Session 18 outcome (2026-07-11):** E5.3 is DONE and **Epic 5 is closed** — the
> personalized summary renders at quiz completion (projected annual savings =
> weekly spend × 52, displayed floored-to-ten so it never overstates; a hedged
> "first hard window" line derived ONLY from your frequency/trigger answers —
> no answers, no line, never a guess; your motivation words echoed verbatim),
> then hands off to the dashboard through the NAMED seam E7 will remap to the
> paywall. `quiz_completed` now fires on summary render (in-process only —
> nothing leaves any build until E8.2 consent + your §8 app ID). **The step-0
> social-proof ruling (vetoable, #1 below): the PRD's "real review quotes"
> screen is DEFERRED until real reviews exist** — a fully-drafted, Brand-verified
> trust-frame alternative sits in the Session 18 ledger if you'd rather ship
> that. **Billed runs: 4** (red evidence `29156626484` matched the two-lane
> harness prediction label-for-label → `29157369825` BURNED: the new XCUITest
> file was missing the one-line `@MainActor` class annotation every neighbor
> carries, a build failure with no evidence → fix → `29157616479` proved the
> whole E5.3 implementation green (unit 210/210, snapshot clean) while the NEW
> gate→quiz→summary smoke itself flaked its first-ever CI drive (the
> birth-year wheel interaction) → QA's pre-recorded deferral valve fired: the
> smoke rides E7 with proper drive diagnostics; unit-tier routing pins hold
> the un-bypassability meanwhile → final green `29158183470` + TestFlight).
> The zero-burn streak ended at two sessions; BOTH closing gates are recorded
> (standing rule #2: neighbor-copying covers class annotations, not just
> imports; state-mutating UITests need the new UITEST_RESET hook AND land
> with drive diagnostics). Your NEW asks: §3 gains the 11 summaryCopy.json
> DRAFT strings (one flagged copy nit) — everything else is carried, nothing
> new blocks.

> **Session 16 outcome (2026-07-11):** E5.1 is DONE — the age gate is the app's
> FIRST screen (birth-year wheel; conservative boundary `≥ 18` year-difference,
> vetoable below), under-17 lands on a calm VERIFIED-helplines resources screen
> (US 988; TR 112 until your §3 ALO-182 check), and exactly ONE boolean persists
> (`ageGatePassed` — the birth year never lands anywhere, test-pinned). The
> whole surface fires ZERO analytics — the plan's `age_gate_blocked` event was
> deliberately NOT created (step-0 ruling, vetoable below; your mvp.md was not
> touched). **Billed runs: 2, zero burned** (red evidence `29135328846` matched
> the local harness prediction issue-for-issue → green `29136061287` +
> TestFlight). Your only NEW asks live in §3; the TestFlight-testers item (§5)
> is now extra-timely since the newest build is the first with real onboarding.

> **Session 15 outcome (2026-07-11):** E8.1 is DONE — the closed `AnalyticsEvent`
> enum (19 MVP §5 events, forbidden properties unrepresentable BY TYPE) +
> `AnalyticsService` with the consent gate (default OFF) + TelemetryDeck 2.14.1
> exact-pinned behind a DORMANT transport; `urge_averted`/`slip_undone` fire live
> (in-process only — nothing can leave any build until BOTH the E8.2 consent step
> ships AND you provide the app ID in §8). **Billed runs used: 3** (one burned on
> a missing test-file import — red `29130610823` burned → red evidence
> `29130875659` → green `29131380401` + TestFlight). The zero-burn streak ended
> at three sessions; the gate that closes this failure class is recorded in the
> resume prompt.

> **Session 14 outcome (2026-07-10):** E4.2 is DONE — every slip/relapse string now
> comes from the ONE audited table (`slipCopy.json`, new `dashboard` section is a
> byte-move of already-shipped literals), and
> `SlipLexiconTests.test_slipStrings_containNoForbiddenLexicon()` is a PERMANENT
> unit-lane gate (37 banned tokens, list can only grow, reflection-driven corpus).
> **Billed runs used: 2** (red evidence `29122473990` → green `29123195424`, zero
> burned — third zero-burn session in a row). Nothing rendered changed: no golden
> was touched. Your half of the E4.2 acceptance is the §3 checklist signature below.

## 0. ✅ CLOSED (same day) — Control Center panic fix: pushed, rebased, device-verified

Resolution (2026-07-11): you pushed the fix as **`8a0c469`** (rebased cleanly onto
the E8.1 session commits — the file sets were kept disjoint on purpose), CI run
**`29132554144`** went all-green (162/162 unit incl. the 5 new
`PanicWarmLaunchTests`, 17/17 snapshot, TestFlight uploaded), and you confirmed
both device paths work (cold CC tap → panic flow; warm CC tap → sheet). The
sheet-vs-cover ruling stands unvetoed. **CI-history note:** the two ✗ runs from
the same evening are `29130610823` (burned build, documented in the Session 15
ledger) and `29130875659` (the E8.1 red-evidence run — red BY DESIGN); neither is
a live failure. Original context, for the record:

- [x] **Commit & push the fix from the Mac** (2 moved, 3 edited, 2 new files).
      Until then the verified fix is one careless `git checkout` from being lost,
      and the build installed on your iPhone corresponds to no commit. If
      Session 15 has already pushed E8.1 commits by the time you do this, pull
      and rebase first — the touched file sets were kept disjoint on purpose
      (see the deferral note below). Push protection tripping ⇒ secret-ify,
      never unblock-URL.
- [x] **Device-verify both paths** (the debug session's ask): COLD — app not
      running, tap Control Center "Panic" → app launches straight into the
      panic flow. WARM — app open on the dashboard, pull down Control Center,
      tap Panic → panic flow appears as a sheet over the dashboard. Doing §1's
      latency capture in the same sitting kills two birds.
- [x] **Decide the warm-mount presentation:** it ships as a swipe-dismissible
      SHEET, not a full-screen cover, because the celebration screen has no
      dismiss button and a cover would trap you there. Veto (= you want a hard
      cover + a designed dismiss affordance) or accept; if accepted, silence —
      the record stands.
- [ ] FYI from that Mac session: `gstack` 1.39 → 1.60 is available —
      `/gstack-upgrade` on the Mac when convenient.

> **Now-obsolete Session 15 consequence (kept for the record):** E8.1 deferred
> the `panic_opened` wiring because its call sites were hot in the then-uncommitted
> Mac tree. With `8a0c469` landed, that guard is RETIRED — `panic_opened` wiring
> is unblocked for a future wiring session (its `cold_start_ms` VALUE still waits
> on the §1 latency numbers; the case ships unfired until then).

## 1. E0.3 panic-latency device measurement — carried since Session 02, load-bearing

- [ ] Run the harness in `docs/spike-panic-latency.md` on an **iPhone 15-class
      physical device** with full Xcode; record the numbers in that doc (~30 min).
      It is the ONLY remaining blocker on wiring E3's permanent latency CI gate —
      and since Session 10 it measures the REAL panic flow's first frame.
- [ ] With the numbers, settle the wording drift: MVP §7 "<2 s, 10/10" vs
      test-suite §1.5 "p90 < 2.0 s" (one-line edit to the losing doc).
- [ ] While on the device (optional, ~5 min): feel-pass the 4-7-8 haptic rhythm in
      the real panic flow — input for E5's haptics-only settings work.

## 2. Try E4.1 on your device (your ask, Session 12) — ~10 min

- [ ] **From Xcode (Mac26 + iOS26 device):** open the project, edit the Unhooked
      scheme's Run environment variables, add `FORCE_PANIC_ROUTE=1` and
      `UITEST_SEED_PANIC_SNAPSHOT=1`, run on the device. You should see: the
      seeded two-quit picker → the real ~90s panic flow (4-7-8 breath bloom with
      haptics, urge timer, your seeded motivations verbatim, redirect menu) →
      exits → **"I slipped" → the NEW two-tap slip flow**: "Log a slip?" →
      "Log it" → the forgiveness screen ("Logged." + best/momentum framing, the
      calm NEUTRAL undo banner) → tap Undo within 10 minutes → "Undone. Your
      streak is right where it was."
- [ ] A plain TestFlight launch now shows the **AGE GATE first**, and (NEW,
      Session 17) a passing year lands on **THE QUIZ** — answer the 10–12
      screens (habit → … → readiness) and a real quit is created with your
      motivations verbatim; the panic flow then renders YOUR words. Enter e.g.
      2012 instead to see the blocked resources surface (988 on a US-region
      device; "Go back" recovers). **NEW (Session 18): after the quiz you now
      land on the PERSONALIZED SUMMARY** — your projected yearly savings (enter
      a weekly spend to see the hero figure; leave it blank to see the calm
      non-monetary reframe), your likely hard window (pick triggers to see it;
      pick none and no line renders — by design), and your motivation words —
      then Continue drops you on the placeholder dashboard. All quiz AND
      summary copy is DRAFT pending your §3 pass.

## 3. Content tone review — now fully TestFlight-visible — **+ NEW: E4.2 checklist signature (~15 min)**

- [ ] **NEW (Session 30 — THE REVIEW-NOTES DRAFT, ~15 min read; your
      clinician+counsel pass is its SHIP gate):** `docs/review-notes.md` is the
      paste-ready App Review notes draft — every factual claim is anchored to a
      shipped test so you can defend it under review. Read it top to bottom
      with the same eye as the copy tables (its §4 lists the register bans it
      holds itself to — no latency number, no "anonymous", no medical
      vocabulary). Its §3 surfaces the THREE submission decisions that are
      yours alone: (a) the 3.1.2 review-build posture (point the review build
      at the teaser arm vs defend the close-less hard wall — the R24.9 rider);
      (b) keys-at-submission (a keyless review build never shows a purchase
      screen — submit keyed or explain the gating); (c) the 17+ rating in ASC.
- [ ] **NEW (Session 30 — OQ-1, THE displayLabel DECISION, ~2 min,
      VETO-CLASS):** the panic multi-quit picker and the widget setup screen
      render the category words **"Porn"** and **"Weed"** (from
      `QuitRepository.displayLabel`). The Brand seat flags this against your
      brandkit §1.2 clinical-noun rule (the quiz chips already say "Adult
      content"/"Cannabis") — but `PanicPathTests` deliberately PINS the
      current words as "brand-reviewed, clinical", so this is a genuine
      documented deadlock, not a drive-by fix. YOUR call: keep the short
      nouns (silence = they stand) or say the word and a session repins both
      strings + the sanctioning test to "Adult content"/"Cannabis" (one
      billed run; not an App-Review blocker either way — the graphic-terms
      lint is a separate register and is green).
      ~10 min):** (a) the settings toggle label **"Breathe with taps"**
      (alternatives on record: "Eyes-free breathing" / "Haptic breath
      guide") + its footer **"The breathing exercise guides you with gentle
      taps, so you can follow it with the screen off or your eyes
      closed."** (2 alts recorded) — the panel's one binding condition:
      never frame the mode as an accessibility accommodation (it is
      first-class, eyes-free-for-anyone; brandkit §8); (b) the taps-anchored
      breath instruction **"Breathe with the taps. In for 4, hold for 7,
      out for 8. Three rounds."** (2 alts recorded) — it renders INSTEAD of
      "Follow the circle…" in haptics-only mode (where no circle is drawn)
      and is what VoiceOver speaks over the visual pacer; PANIC-PATH copy,
      so your clinician+counsel pass is its ship gate too; the shipping
      "Feel the taps — in, hold, out." stands verbatim; (c) TWO copy
      niceties the audit/goldens surfaced, yours to keep-or-fix with the
      copy pass: the panic entry title "Let's take this one wave at a
      time." TRUNCATES at max Dynamic Type ("Let's take t…" — pinned by the
      existing goldens; a shorter title fixes it), and the degraded slip
      path shows "Logged." twice (title + body echo).

- [ ] **NEW (Session 27 — THE SAFETY-COPY BLOCK; your clinician + counsel pass
      is the SHIP gate, not a build gate):** E9.1 made `safetyCopy.json` FULLY
      consumed — every string in it now renders in TestFlight builds:
      (a) the **alcohol withdrawal notice** (title "One thing worth knowing" +
      body + "See resources" + "Got it") shows once on the first alcohol
      quit/reduce goal — the panel signed the wording AS-IS (calm, hedged,
      points to a professional, never says HOW to withdraw), but the file's
      own `_meta` still says **"DRAFT — needs clinician + counsel sign-off"**
      and that stays YOURS before public release; (b) the **resourcesScreen**
      strings (title/intro/footer) now render post-gate too — re-read them in
      the new context; (c) ONE REWORD to eyeball: `notMedicalCareDisclaimer`
      lost the word "treatment" → "…not medical or mental-health **care**"
      (the CI lexicon can't tell an honest negation from a claim; meaning
      preserved — veto with different wording if counsel prefers);
      (d) the NEW **"Support & resources"** label (Settings row + slip-flow
      link, byte-identical) — DRAFT/founder-owned; (e) the NEW **GLOBAL
      fallback note**: an unmapped-region user reads *"If you're in immediate
      danger, call your local emergency number. To find a helpline in your
      country, visit findahelpline.com."* — findahelpline.com is ThroughLine's
      vetted global directory (we live-verified it); **verify-or-veto the
      pointer** (removing the sentence is a one-line edit; the GLOBAL bucket
      itself stays number-free BY RULING — never add a phone row there
      without an official source, the file's `_meta` says so too).
- [ ] **NEW (Session 27 — the E9.2 audit signature, ~10 min):** the mvp §7 row
      "milestones say 'commonly reported'" + the medical-claim scan are now
      PERMANENT CI (phrase-anchored lexicon; all 43 bodies framing-pinned).
      Your half is the judgment call a wordlist can't make: read
      `milestones.json` top to bottom for nuance (the E4.2-signature shape)
      and record the sign-off by checking this box.
- [ ] **NEW (Session 26 — E7.3 win-back, 5 DRAFT strings):**
      `paywallCopy.json` gains `winbackOfferLine` ("Your annual plan, now at
      half price."), `winbackMechanicsLineFmt` ("%@ for your first year,
      then %@ per year. Cancel anytime." — the two slots bind $14.99 then
      $29.99 from the catalog; NEVER put a price literal in the copy),
      `winbackReassurance` ("Everything you set up is still here."), and
      `winbackDismissLabel` ("Not now"); the settings table gains
      `winbackRowLabel` ("See your plan options"). All DRAFT/founder-owned,
      CI-scanned. Register rules the panel bound: the 50%-off is a REAL
      discount so "half price" is honest — but NO countdown, NO "one-time",
      NO we-miss-you framing, and NEVER "Reactivate"/"Come back" (a
      trial-lapse user may never have paid — those words mis-state fact).
- [ ] **NEW (Session 26 — ONE mvp.md §6 ratification, the R24.9 shape —
      your file was not touched):** mvp §6 says the win-back is "delivered
      via Superwall placement + **local notification**." v1 ships IN-APP
      ONLY — an eligible lapsed user meets the offer when they next open
      the app (the re-entry offer + the Settings row). Why: a local
      notification would add a notification-permission prompt this
      privacy-first app has never asked for AND break a landed test that
      asserts the v1.0 target requests no notification authorization
      (test-suite §7; the plan + test-suite already read §6 as "no push
      permission" in three places). **Ratify in-app-only for v1, or veto**
      to schedule the notification as its own permission-surface session.
      Honest cost, stated plainly: without a notification, a lapsed user
      who never re-opens the app never sees the offer — we can measure
      shown→converted but NOT eligible→shown. That measurement gap is the
      strongest data argument for adding the notification later; it is
      yours to weigh.
- [ ] **NEW (Session 26 — the 3.1.1 checklist gains a winback row):** the
      rendered winback paywall must show the discounted price AND the
      standard renewal price in one line (it does — the mechanics line),
      plus the standing auto-renew/restore/Terms/Privacy set. Add the row
      to your guideline-3.1.1 sign-off alongside the S25 remote-B-arm
      rider.
- [ ] **NEW (Session 25 — E7.2 teaser variant, 3 DRAFT strings + 2 §5
      ratifications):** `paywallCopy.json` gains `teaserEscapeLabel` ("Look
      around for a day first"), `teaserEscapeNote` ("Full access for one
      day. Then this screen returns."), and `teaserExpiryEyebrow` ("Your
      free day wrapped up. Everything you set up is still here.") — the
      A/B'd 1-day teaser's escape button, its honest what-this-does note,
      and the zero-shame line when the wall returns. DRAFT/founder-owned,
      CI-scanned against the dual lexicon on every run; alternatives in the
      S25 ledger. Register rules: factual duration (never a countdown), no
      urgency, no loss framing, name-free. **Ratify (or veto) two mvp.md §5
      vocabulary deviations shipped flagged (the R24.9 shape — your file
      was not touched):** `paywall_viewed.source` gains `teaser_expiry`
      (the second-impression funnel split the A/B needs), and `variant`
      transmits the semantic labels `teaser`/`hard` (the raw Superwall
      variant id stays dashboard-side via the mapping table in §8).
      **+ rider:** the remote Superwall paywalls you'll build (§8) must
      carry the full 3.1.1/3.1.2(c) set in the same register: price, trial
      length + follow-on price, auto-renew statement, Terms/Privacy links,
      Restore — and the $39.99 B-arm renders ONLY there (no display
      constant exists in app code by ruling). **+ carried App-Review rider
      (R24.9):** the HARD variant has no close; point the review build at a
      teaser variant or accept the 3.1.2 posture.

- [ ] **NEW (E4.2 acceptance, your half): sign the MVP §7 copy-audit checklist**
      — "Copy audit: no medical claims, no fear content, no fabricated statistics;
      milestones say 'commonly reported'" — for the SLIP surface. The mechanical
      half is now CI-enforced (`Tests/Unit/SlipLexiconTests.swift` scans every
      slip string against 37 banned tokens on every run, and the list can only
      grow); your half is the judgment call a wordlist can't make: read
      `slipCopy.json` top to bottom (including the new `dashboard` section — its
      3 strings are byte-moves of copy you've already seen on device) against the
      brandkit voice (Steady / Forgiving / Honest), and record the sign-off by
      checking this box. If any string fails your read, note the replacement —
      the next session re-records the affected goldens deliberately (a string
      change is a third billed run; batch it with other copy edits if possible).
- [ ] `panicScript.json` ships since Session 10; **`slipCopy.json` ships since
      Session 12** — every string in the slip flow renders from it. Review both
      files' tone against the brand kit voice.
- [ ] **The ONE new agent-drafted line (Session 12):** `slipCopy.json`
      `confirm.retryNote` — *"That didn't save just yet — nothing's lost. Tap Log
      it to try again whenever you're ready."* Shown only when the durable write
      fails; must stay calm, zero-shame, retryable (`REVIEW.md` item 3).
- [ ] Pre-ship (unchanged): clinician/legal pass on `safetyCopy.json`; verify the
      flagged helplines; TR L10n review (`App/Resources/Content/REVIEW.md`).
- [ ] **NEW (Session 16 — E5.1 makes two more content files TestFlight-visible):**
      the age gate's blocked screen renders `safetyCopy.json`'s resourcesScreen
      framing and `helplines.json` rows, so BOTH files now ship in every build
      (previously unbundled drafts). Their clinician/legal + verification passes
      above move up your queue accordingly — same posture as when panicScript/
      slipCopy started shipping. Also review the NEW `ageGateCopy.json` (8 strings,
      both gate screens; panel-signed, CI-scanned against the shame lexicon).
- [ ] **NEW (Session 16 — ALO 182, ~5 min):** the blocked-minors surface shows only
      `appliesTo:"all"` rows with `verified: true`, so TR currently shows ONLY 112 —
      `tr_crisis` (ALO 182) is `verified: false` pending your official-source check
      (Sağlık Bakanlığı page; the file's own `_meta` MUST_VERIFY item). Verify it,
      flip its `verified` flag to `true`, and 182 joins the surface automatically
      (a unit test pins that unverified rows can never render there).
- [ ] **NEW (Session 17 — THE FOUNDER QUIZ COPY PASS, ~20 min, yours by design):**
      `App/Resources/Content/quizConfig.json` is the quiz's ONE audited copy table
      and every string in it is **DRAFT — agents scaffolded, you own the words**
      (roadmap: "agents scaffold screens, copy owned by founder"). It is
      CI-lexicon-scanned (so any shame/medical token is a build failure), and the
      Brand agent signed it with two replacements already applied (effects title;
      the lowest commitment-slider echo — "One day at a time" was rejected as
      AA-coded). Read it top to bottom against the brandkit voice and rewrite
      freely; a copy edit is cheap NOW (no snapshot goldens exist yet — see the
      rulings below). Two sub-decisions ride along:
      (a) the **effects step (slot 10)** needs your medical-claims read — chips are
      non-diagnostic self-report nouns ("Restless sleep", never "insomnia") and the
      title deliberately makes no causal claim; keep it that way;
      (b) whether the motivations step should gain an optional free-text
      "why does {motivation} matter to you?" elaboration (enriches the panic
      reasons screen; local-only like all answers) — a copy/UX call, not built yet.
- [ ] **NEW (Session 19 — THE CONSENT STRINGS, ~5 min, rides the same pass):**
      quizConfig.json's slot-3 step now carries the 4 consent strings — title
      "Share app usage data?", the helper ("You'd share which steps you reach and
      your habit type — never your answers, notes, or the times you log, and
      never tied to you. It's off until you choose, and nothing's been sent
      yet."), and the two choice labels "Share usage data" / "No thanks". All
      DRAFT/founder-owned like their siblings; PM+Brand+QA joint-signed
      (safety-content gate) with ONE Brand strike already applied: "anonymous"
      was removed everywhere as an unverifiable overclaim — the payload audit
      can prove what leaves the device, not that it is "anonymous"; the
      audit-backed "never tied to you" carries the reassurance instead. Two
      founder calls ride along: (a) the helper's opener is the conditional
      "You'd share…" (Brand's marginally-less-nudging pick) vs the imperative
      "Turn this on to share…" — both register-clean, your call; (b) do NOT let
      any "change this anytime in Settings" promise creep in — no settings
      analytics surface exists yet (a recorded roadmap candidate), and the copy
      must promise nothing unbuilt.
- [ ] **NEW (Session 21 — THE WIDGET GALLERY STRINGS, ~5 min, rides the same pass):**
      `Shared/Sources/StreakWidgetStyle.swift` is the streak widget's ONE audited
      string table (9 strings: gallery name "Streak" + description, the
      "today"/"saved"/"next milestone" micro-labels, the empty-state line
      "Ready when you are.", the "Day 7" gallery sample, the panic button's
      accessibility label). All DRAFT/founder-owned; PM+Brand+QA joint-signed;
      CI-scanned against BOTH the shame lexicon AND a habit-leak lexicon on
      every run. NOTE: the in-widget micro-copy is baked into the 15 recorded
      snapshot goldens — a rewrite re-records those goldens (cheap, batch it
      with the rest of this pass).
- [ ] **NEW (Session 21 — MILESTONES.JSON NOW SHIPS, ~10 min, rides the same pass):**
      `App/Resources/Content/milestones.json` is now bundled (the widget feed
      maps each quit's milestone ladder from it — hours only; its titles/bodies
      never reach the widget). Its ~40 milestone strings ("commonly reported"
      framing, per its own _meta audit note) are DRAFT and will first RENDER on
      the E9 dashboard — review them with the same medical-claims eye as the
      effects step: experiential, never clinical promises.
- [ ] **NEW (Session 18 — THE SUMMARY COPY ROWS, ~10 min, rides the same pass):**
      `App/Resources/Content/summaryCopy.json` — 11 DRAFT strings for the
      summary screen (eyebrow, savings caption + no-spend reframe, the six
      "first hard window" phrases, motivation intro, CTA). Brand signed with
      ZERO required replacements (a first), but two founder calls ride along:
      (a) the **flagged copy nit** — the hero renders "~$1,350<small>/year</small>"
      and the caption says "saved in a year, if you stay on track." (a
      double-"year" read; Brand's optional alternative: "saved in a year at
      this rate."); (b) the risk-window phrases are REFLECTION hedges ("Your
      first hard window is likely evenings.") — keep the "likely" and never let
      "predict"-family words in (the clinical line the register gate holds).
      A copy edit is still cheap (goldens remain unrecorded until this pass).

- [ ] **NEW (Session 22 — THE SETTINGS STRINGS, ~3 min, rides the same pass):**
      `App/Sources/DiscreetSettingsCopy.swift` — 8 strings: "Discreet Mode"
      (screen title), "Widgets" / "Widgets for this streak show numbers only."
      (section header/footer — the footer deliberately promises only what the
      toggle observably does, the S19 rule), "App Icon", "Default",
      "Calendar style", "Timer style" (the two picker names are brandkit §4.3
      LITERALS — confirm rather than rewrite), "Settings" (the entry's
      VoiceOver label). All DRAFT/founder-owned except the two literals;
      CI-scanned (shame + habit-leak, non-vacuity floor). One flagged fork:
      the discreet widget button's VoiceOver label is bare "Reset" (your
      brandkit's literal); a descriptive "Reset — opens a quick reset" would
      give VoiceOver users action-hint parity and still leak nothing — panel
      shipped the literal, your call.
- [ ] **NEW (Session 22 — THE TWO GENERATED APP ICONS, ~5 min, VETO-CLASS):**
      agents generated `AppIconCalendar` + `AppIconTimer` (1024², opaque) to
      your brandkit §4.3 spec + the mockup's exact geometry/hex — warm
      gray-white tile with a 4×4 dot grid + one muted-blue today-dot (ruled
      #3D6C9E over "system blue": a static PNG can't bake a dynamic color);
      dark slate tile with a thin dial + single index mark. Look at them on a
      device home screen (§7 row). Veto/replace freely — the committed
      generator (`brandkit/branding-assets/generate-alt-icons.py`) is
      deterministic, so a tweak is a parameter edit + re-run, and NO snapshot
      golden pins icon pixels (behavior is pinned, art is yours).
- [ ] **NEW (Session 24 — THE PAYWALL COPY PASS, ~15 min, rides the same pass):**
      `App/Resources/Content/paywallCopy.json` is the bundled paywall's ONE
      audited copy table — 20 strings, ALL DRAFT/founder-owned (headline
      "Keep your momentum.", plan titles, the trial-mechanics line, CTAs,
      the never-trap failure strings). CI-scanned against BOTH lexicons on
      every run, PM+Brand+QA joint-signed. Prices are NEVER in this file
      (the `%@` slots bind `ProductCatalog`'s constants), so rewrite freely —
      a copy edit cannot drift the pricing, and no goldens exist yet so
      edits are still cheap. Three decisions ride along:
      (a) **THE REGISTER DECISION (the real one):** your mvp.md §6 fixes the
      paywall positioning canon VERBATIM as "No account. No server. Nothing
      to leak. Apple handles billing — cancel or refund in one tap." The
      panel shipped the audit-safe variant instead: **"No account. No
      sign-up. Apple handles billing — cancel in one tap."** + "Your notes
      and journal never leave your device." Grounds (the Session-19
      "anonymous" precedent): the paywall is the ONE screen literally
      brokered by RevenueCat's servers, so "No server" one tap before an
      RC-mediated purchase is the most self-contradictory possible placement
      (your own brandkit §7 already softened it to "No cloud we control");
      "Nothing to leak" is unprovable in the absolute; Apple refunds are
      REQUESTED at reportaproblem.apple.com, never a one-tap in-app action
      (your brandkit's own screenshot caption dropped "refund"). Restore the
      canon verbatim by saying so — mvp.md was not touched; this is your
      call alone.
      (b) **Legal riders (operator/legal-owned):** the Terms of Use (EULA) +
      Privacy Policy links render as LABELS today — they MUST become
      functional links before App Store submission (Apple Schedule 2), and
      the auto-renewal boilerplate should be re-checked against Apple's
      current required wording ("Apple Account" terminology) in App Store
      Connect when you set up the products.
      (c) The screen has **NO "Not now" close** (vetoable ruling below —
      your mvp.md's hard-ish wall; the sanctioned escape is E7.2's teaser).
- [ ] **NEW (Session 22 — THE STORE-SCREENSHOT DECISION, R22.10, ~2 min):**
      brandkit §9.1 says "NEVER use the discreet alternates in store
      marketing"; §9.2's screenshot plan frame 3 shows the Calendar icon on a
      home screen. These are mutually exclusive: one public store exposure
      makes the alternate icon reverse-image-linkable to Ballast FOREVER —
      anyone spotting "Calendar style" on a partner's phone could match it to
      your listing. The panel resolved toward §9.1 (never market them; frame 3
      should show the discreet WIDGET only, primary icon). You own ASO —
      confirm or veto before any screenshot work; note it in the brandkit when
      you decide.

## 4. GitHub Actions billing headroom — ~2 min per session

- [ ] Session 32 (UIR-0, the design system) used **exactly 2 billed runs — the
      2 planned, contingency UNUSED, ZERO burned.** Run 1 (`29295414489`,
      commit `d1c529a`) = the designed red: exactly the 64 predicted
      "no reference on disk" golden failures (the palette moved, so every
      panic/slip screenshot must be re-recorded — there is no free way to get
      an adoptable PNG without a run), with the unit + accessibility lanes
      GREEN on it, which is what actually PROVED the WCAG closure. It also
      surfaced the R32.9 disabled-button discovery for free. Run 2
      (`29296599848`, commit `0a3402f`) = the 64 re-recorded goldens adopted
      straight out of run 1's own artifact + the R32.9 fix → all nine jobs
      green, TestFlight uploaded.
- [ ] Session 31 (R30.6 privacy manifests) used **exactly 1 billed run,
      contingency UNUSED, ZERO burned** — run 1 (`29290910960`, commit
      `c9d8478`) = the born-green single push (both manifests + project.yml
      wiring + the 3 key-set pins), all-green + TestFlight. Born-green was
      ruled over a RECORDED two-judge split (the S31 ledger has the grounds)
      and proven empirically pre-push: the exact pin logic RUN over the exact
      shipping manifest bytes under the strict-flags harness ×3 timezones —
      pass on the real bytes, fire on every mutation and on absence.
- [x] **CLOSED (Session 31) — the S30 monthly-spend-limit item below:** your
      Claude limit is no longer hit — verified empirically (a canary agent +
      a 6-agent workflow ran clean this session). Fan-outs are available
      again; the write-findings-to-files discipline stays permanent anyway.
- [ ] Session 30 (E10.2 submission package, build half) used **exactly 1 billed
      run, contingency UNUSED, ZERO burned** — the cheapest code session on
      record: run 1 (`29287258848`) = the born-green metadata lint's first and
      only run, all-green + TestFlight. The three docs deliverables rode the
      free docs path. Born-green was proven EMPIRICALLY before the push on the
      free Linux box (the exact matcher over the exact shipping bytes + the
      strict-flags Swift harness ×3 timezones), which is why no red run and no
      contingency were needed.
- [x] *(CLOSED S31 — see above)* **(Session 30) — YOUR CLAUDE MONTHLY SPEND LIMIT IS HIT:** the
      STEP-0 panel's synthesis agent died mid-session on "You've hit your
      monthly spend limit" (claude.ai/settings/usage). Nothing was lost — the
      standing write-findings-to-files rule salvaged everything at zero cost —
      but until you raise the limit or the month rolls, agent sessions run
      INLINE (no multi-agent fan-outs: slower on big analysis sessions, not
      blocked). Raise it or leave it; the next session works either way.

- [ ] Session 29 (StoreKit-config/contract) used **exactly 3 = its 2 planned +
      the contingency, ZERO burned — every run produced designed evidence:**
      run 1 (`29272338401`) = the red manifest, EXACTLY the 5 designed unit
      failures name-for-name (the 15th consecutive harness-predicted red);
      run 2 (`29273795616`) = all 5 reds flipped + the re-landed scenario-29
      funnel smoke GREEN on its first-ever allowed run (incl. the event-spy
      bridge reads) — its only red was a PRE-EXISTING panic-smoke flake
      (a synthesized tap swallowed mid step-transition; artifact-diagnosed
      on the Linux box, our diff exonerated); run 3 (`29275973732`) = the drive
      hardening + all-green + TestFlight. NEW STANDING PRACTICE born this session:
      xcresult artifacts are fully readable on the free Linux box (the
      fileBacked2 parser) — artifact-first diagnosis now precedes ANY billed
      hypothesis run, and every multi-step UI drive verifies each tap took
      (one bounded guarded re-tap, evidence attached).

- [ ] Session 28 (E9.3 a11y) used **5** billed runs = the 2 planned + the
      contingency + 2 over, **1 BURNED**: run 3 hit a TEST-BUILD failure
      because two docs-listed audit-scope options (`.action`,
      `.parentChild`) exist ONLY on macOS — docs-confirmed existence is not
      platform availability, and the per-member `platforms` check is now a
      standing gate (#5b). Every other run produced designed evidence: run
      1 = the red manifest name-for-name (verbatim failure strings, the
      14th consecutive); run 2 = all flips + the audit family's first
      execution (its complete finding ledger — two real defects fixed, the
      contrast/text-scaling debt enumerated); run 4 = the repaired audits
      green (panic+quiz) + the 4 degraded-slip goldens re-recorded by CI
      itself; run 5 = all-green + TestFlight. Two golden re-record batches
      this session cost ZERO extra runs (extracted from CI's own artifacts).

- [ ] Session 15 used **3** billed macOS runs (**1 burned**: a new test file was
      missing an import — TEST BUILD FAILED with no red evidence; the gate that
      closes this class is now standing rule #2 in the resume prompt). Session 16
      (E5.1 age gate) used **exactly its 2 planned runs, zero burned** (the
      Linux harness predicted the red run issue-for-issue, and a pre-push
      critic caught a would-be build-breaker in the green views). Session 17
      (E5.2 quiz — the largest surface yet) **used exactly its 2 planned runs,
      zero burned** (red evidence `29151832001` matched the harness prediction
      issue-for-issue → green `29152486541`; the fourth zero-burn TDD session).
      Session 18 (E5.3 summary) used **4** billed runs (planned 2 + 1
      contingency, ran one over): red evidence `29156626484` (exactly the 31
      designed issues, two-lane-harness-predicted) → `29157369825` **burned**
      (missing `@MainActor` on the new XCUITest class — build failure, no
      evidence) → `29157616479` (implementation verified whole; the new smoke
      itself flaked → its pre-recorded deferral valve fired) → final green
      `29158183470`. BOTH closing gates recorded in the resume prompt
      (class-annotation coverage; smokes with unproven drive interactions
      defer until they can land with diagnostics). Session 19 (E8.2 consent)
      used **exactly its 2 planned runs, zero burned** — the zero-burn streak
      restarts (red evidence `29164705316` = exactly the 39 predicted issues,
      the sixth consecutive harness-predicted red; the green critics now
      REPRODUCE risky Swift-6 constructs under warnings-as-errors instead of
      reasoning about them — that practice caught nothing this time because
      there was nothing to catch, which is the point). Session 20 (E6.1 widget
      timeline provider) used **exactly its 1 planned run, zero burned** (green
      `29174800786`). **This CORRECTS the Session-19 close's "possibly zero billed
      runs" hope, which was simply wrong — and the correction is PERMANENT, so no
      future session re-learns it:** the WidgetToolkit package lane does run on
      free Linux CI, but `.github/workflows/ci.yml` applies NO path filter to the
      macOS `app` job — its only exclusion is `paths-ignore: docs/**, **.md`. So
      *any* push touching `Packages/**` spins the 10x macOS lane too, whether or
      not a single app file changed (and a green push to main also spins the macOS
      TestFlight lane). **Free lanes exist; free runs do not.** Only DOCS-only
      pushes are truly free. The honest lever, which Session 20 used: produce the
      package lane's red evidence LOCALLY and free (`swift test` on Linux — the
      sanctioned package-tier form per session-rules.md), then push the red and
      green commits TOGETHER so CI fires ONCE at HEAD instead of twice. Session 21
      (E6.2 — widget families + the app-side feed) planned **2 billed runs + 1
      contingency** and used **4 (1 burned)**: `29178893738` BURNED — a
      deprecated API (`UITraitCollection(traitsFrom:)`) in the NEW snapshot test
      file turned warnings-as-errors into a build failure with zero evidence
      (the closing gate is now standing rule #2 in the resume prompt: new API
      forms no neighbor uses get their docs DEPRECATION metadata checked);
      `29179114316` = the red evidence, manifest-matched name-for-name (the
      seventh consecutive harness-predicted red) AND the run whose artifact
      recorded the 15 widget goldens; `29179524777` = green 243/244 (ONE
      pre-existing fixture legitimately flipped by the new timezone backfill);
      `29179855734` = final all-green + TestFlight. The two would-be burns the
      critics caught BEFORE pushing (the cross-import overlay, the
      timezone-decode inversion) would have made it 6. Session 22 (E6.3 —
      discreet + icons + shield) planned **2 billed runs + 1 contingency** and
      used **exactly 2, zero burned, contingency unused — the zero-burn streak
      restarts**: `29183485997` = the red evidence (manifest-matched
      name-for-name, the 8th consecutive: 6 designed unit reds + 6 recording
      snapshot fns whose artifact carried the 16 new goldens; every old golden
      compared clean) → `29184196211` = green all-8-jobs + TestFlight. The
      adversarial critics caught, pre-push: a sheet-coverage hole that would
      have leaked motivations into the app switcher, a fail-open window in the
      shield policy, a UIApplication-in-Shared placement that is a hard
      extension compile error, JSONEncoder key-order randomization that would
      have made byte-equality pins flake, and a docs-unconfirmed
      UIWindow.Level operator spelling — any of the last three was a burned
      run. Session 23 (E7.1 PaywallKit, package lane) planned **1 billed run +
      1 contingency** and used **exactly 1, zero burned, contingency unused —
      the zero-burn streak continues**: red evidence was FREE (the local Linux
      package lane, 11 designed-failing / 17 issues predicted issue-for-issue,
      the 9th consecutive harness-predicted red) → red `14b1593` + green
      `098d087` pushed together → ONE CI run `29192612869` at HEAD (the new
      PaywallKit coverage gate went green in 41s on the free lane). The
      pre-push critics reproduced every lane locally before the push — and the
      free-lane/macOS-lane WARNINGS gap they closed (the free package lane
      runs no warnings-as-errors) is now a standing resume-prompt gate.
      Session 24 (E7.1 app half — RevenueCat wiring + paywall) planned
      **2 billed runs + 1 contingency** and used **3 (1 burned)**:
      `29196899754` BURNED — ONE spurious `await` on a same-actor synchronous
      call in the NEW erase-wiring test file (a non-Sendable closure literal
      inherits its suite's @MainActor isolation, so the marked call was
      synchronous; the warning became a build failure under
      warnings-as-errors, with zero red evidence). Neither `swiftc -parse`
      (syntax-only) nor the Linux harness (SwiftData test files can't compile
      there) could catch it; the closing gate is now standing: the
      closure-isolation shape is permanently pinned in the local
      strict-concurrency gate, and every new closure-into-seam shape in a
      non-harnessable file gets mockup-typechecked before push.
      `29197338715` = the red evidence (28 designed failures / 47 issues,
      manifest-matched name-for-name — the 10th consecutive predicted red;
      the first burn's one silver lining: it proved the app target compiled
      clean a run early). `29197958414` BURNED — the session's designed risk
      point (the first macOS build with the new purchases-ios dependency)
      fired, but NOT on dependency resolution (that had been reproduced
      clean on Linux, full pin graph): it fired on OUR OWN module quirk —
      the PaywallKit package exports an enum named PaywallKit (its version
      marker), so the adapter's `PaywallKit.PeriodType` resolved to the enum
      instead of the module, and the one Darwin-only file met its first
      compiler on CI. Post-hoc: the identical error reproduces on the free
      Linux toolchain in a one-file probe — locally catchable, now a
      standing pre-push gate (Darwin-only files get their qualified
      non-SDK type names Linux-probed; a typealias replaces the qualified
      form). `29198309877` = green + TestFlight (the three-line alias fix,
      Linux-verified both ways first). RUN 4 IS ONE OVER the 2+1 envelope —
      the same honest overrun shape as Sessions 18 and 21. NEW STANDING
      RULES from the arbitration: SPM dependencies land in the GREEN commit,
      never red (red evidence must be un-burnable by dependency resolution);
      grep-lint regexes anchor `^import`. Session 25 (E7.2 Superwall) used
      **3 = the 2 planned + the contingency on scenario-29's sanctioned
      valve, ZERO burned**. **Session 26 (E7.3 win-back) used EXACTLY the 2
      planned runs — zero burned, contingency UNUSED** (red `29209285506` =
      the 11-test manifest name-for-name, the 12th consecutive predicted
      red; green `29209801255` all-green + TestFlight). **Session 27 (E9.1
      + E9.2 safety layer) used EXACTLY the 2 planned runs — zero burned,
      contingency UNUSED** (red `29245297054` = the 4-test manifest
      name-for-name + the 2 DESIGNED snapshot shifts, the 13th consecutive
      predicted red; green `29246823045` all-green + TestFlight; the 6
      shifted goldens were re-recorded for free from the red run's own
      artifact — a new standing technique, so a planned golden change no
      longer costs a third run). Session 28 (E9.3 accessibility) plans
      **2 billed runs + 1 contingency**; no new SPM dep.
      Check Settings → Billing → spending limit before the session.
- [ ] Optional, would eliminate the burned-run class entirely: a cheap self-hosted
      macOS runner or a pre-push `xcodebuild -quiet build` step.

## 5. TestFlight housekeeping — carried from Sessions 07–09; NOW TIMELY

> **NEW (Session 16, on your request): step-by-step walkthrough in
> `docs/testflight-tester-guide.md`** — internal group setup, external
> groups/public link, and both items below, with the Ballast-specific context
> (CI uploads internal-only; build worth distributing = the `8a0c469` one).

- [ ] Add internal testers (nobody receives builds until a tester group exists).
      **This item is now MAXIMALLY timely (Session 17, doubled by Session 18):**
      the newest build (from `b17ce0f`, run `29165381934`) completes the M1
      loop — a tester installs, passes the gate, answers the quiz (now incl.
      the calm "Share app usage data?" consent step at its third screen —
      declining changes nothing about their experience), sees THE SUMMARY
      PAYOFF (their savings figure, their hard window, their words), and gets a
      real quit whose panic flow speaks their own motivations. That is the
      product thesis in one hand-off. Follow Part 1 of the guide. (The earlier
      `8a0c469` note stands superseded.)
- [ ] Expire the stray bundle-version-"1" build; answer export compliance only if
      App Store Connect prompts (guide Part 3 has the exact answers).
- [ ] **NEW (Session 21): re-add the widget once.** SkeletonWidget was retired
      for the real "Streak" widget (new kind — a placed placeholder widget
      disappears from the lock screen). Long-press → add "Streak"; the
      rectangular size carries the panic button. Any tester who had the old
      placeholder placed must re-add too (one-time; veto ruling #6 below).

## 6. Slack webhook rotation — optional hygiene, ~5 min

- [ ] CI reads `secrets.SLACK_WEBHOOK_URL`; the old URL briefly sat in local git
      history. Rotate when convenient.

## 7. E3.3 manual device matrix — YOUR half of the E3.3 acceptance (~15 min)

> **Recommended: do everything in this section as ONE consolidated sitting
> (~1 hour) on TODAY's build** — the day-counter row below + the E3.3
> matrix + the S21/S22 widget/discreet rows + §2's E4.1 try + the E0.3
> latency measurement. One sitting clears four carried items and verifies
> your bug report. The SECOND physical sitting (sandbox purchase matrix +
> payload audit) waits for your §8 keys/console work — sequenced, not now.

- [ ] **NEW (Session 28 — the eyes-free/VoiceOver eyeball, ~2 min, same
      sitting):** on the newest build: (a) Settings (gear) → toggle
      **"Breathe with taps"** ON → lock the phone → hit the lock-screen
      panic button → the breath step shows the hand-tap glyph + "Breathe
      with the taps…" instead of the circle, and the 4-7-8 rhythm arrives
      as TAPS you can follow with your eyes shut (this is the part no
      simulator can verify — the haptic pattern's feel is yours to judge;
      its correctness is device-test 40, also carried here); (b) toggle it
      back OFF → the visual bloom returns; (c) with VoiceOver on, swipe
      through one quiz step, the panic steps, and a slip log — every
      control should announce a sensible name (the commitment slider says
      its WORDS, the icon picker says which icon is selected).
- [ ] **NEW (Session 27 — the safety-layer eyeball, ~2 min, same sitting):**
      on the newest build: (a) Settings (gear) → the "Support & resources"
      row at the bottom → the resources screen shows YOUR region's verified
      lines (US: 988 first, then SAMHSA/quitline/NAMI; TR: 112 + 171 + 115 —
      182 stays hidden until your ALO-182 check flips its flag); tap a number
      row and confirm the dial sheet opens with the number VERBATIM; (b) log
      a slip → the forgiveness screen carries the same link one tap deep;
      (c) if you have an alcohol quit (or create a reduce goal for one), the
      amber "One thing worth knowing" card appears ONCE on the dashboard —
      "Got it" dismisses forever, "See resources" opens the same screen.
- [ ] **NEW (Session 26 — YOUR day-counter report, ~2 min):** you reported
      "lock screen day counter not working as of 2 days ago's binary."
      Triage verdict: **not a code bug** — the binary from 2 days ago
      (2026-07-10) predates the real widget entirely; it contains only the
      walking-skeleton placeholder, which renders a HARDCODED "Day 0" and
      never counts (by design, E0.2). The real self-ticking counter shipped
      Session 21 under a NEW widget identity, so a widget placed from the
      old binary went permanently dead (documented S21: "testers re-add
      once"). Steps: (1) update to the NEWEST TestFlight build; (2) remove
      the dead lock-screen widget and re-add **"Streak"** from the widget
      gallery; (3) open the app once (the launch refresh writes the widget
      feed). **If the day counter STILL fails after that**, record: the
      build number, what the widget shows ("Day 0" / "Day 7" / "Ready when
      you are." / blank), whether the in-app dashboard shows the right Day
      N, and whether logging any event updates the widget within ~60s —
      that evidence makes it a real device bug and the next session hunts
      it from your notes.

The build half shipped Session 13; the acceptance's device matrix is operator-owned
device work. Any post-E3.3 build works; for seeded quits run from Xcode with scheme
env `UITEST_SEED_PANIC_SNAPSHOT=1` (two-quit pre-cache: "Vaping" + one discreet).

- [ ] **Place the surfaces** from the system galleries: the "Streak" lock-screen
      widget (its wind button); the **"Panic"** control in a lock-screen control
      slot AND in Control Center; Settings → Action Button → Controls → "Panic".
- [ ] **Discreet check:** in the controls gallery, confirm the **"Reset"** control
      shows the neutral counterclockwise-arrow glyph and its description ("Opens a
      quick reset.") carries zero habit words; place it once and fire it.
- [ ] **Run the matrix** — each row × Focus ON and OFF; at least one pass in
      airplane mode (Epic 3 DoD: zero network dependency):

      | # | Launch from | Expect | Recorded source |
      |---|---|---|---|
      | 1 | Lock-screen widget button | picker (2 quits) → flow | lockscreenWidget |
      | 2 | Lock-screen control slot | same | controlCenter (see note) |
      | 3 | Control Center "Panic" | same | controlCenter |
      | 4 | Action button | same | controlCenter (see note) |
      | 5 | "Reset" control (any surface) | same | controlCenter (see note) |
      | 6 | In-app "Panic" button on the root | picker sheet | inApp |

- [ ] The attribution VALUES are unit-pinned, so if row-by-row source inspection is
      friction, it is enough to confirm each surface OPENS the flow (Focus on/off,
      airplane ok) — that closes the matrix. To spot-check a recorded source, finish
      one flow arm ("The urge passed") and inspect the persisted UrgeEvent from an
      Xcode run.

> **Platform note (recorded adjustment, not a bug):** iOS provides NO API to tell
> Control Center vs lock-screen slot vs Action button apart — one control
> registration serves all three and YOU assign placement. Rows 2/4/5 recording
> `controlCenter` is correct behavior. `.actionButton` stays reserved in the schema.

- [ ] **NEW (Session 21 — the E6.2 widget rows, ~15 min, same sitting works):**
      (a) **Tinted mode** (mvp feature 6's third render mode): tinted home
      screens cannot be host-snapshotted, so this is device-only QA — set a
      tinted home screen, add systemSmall/Medium "Streak", confirm legibility
      (the templates are luminance-only by design). (b) **The day ring
      mid-fill**: the circular family's ring fills across YOUR local day
      (goldens could only pin the full-ring state — ProgressView's timer form
      has no freeze seam). (c) **Freshness**: log an urge/slip, confirm the
      widget updates within ~60s. (d) **Selector binding**: with 2+ quits,
      long-press → Edit Widget → pick a quit; archive/erase that quit and
      confirm the widget shows "Ready when you are." — never another habit's
      streak.

- [ ] **NEW (Session 22 — the E6.3 device rows, ~10 min, same sitting):**
      (a) **Discreet toggle**: Settings sheet (gear on the root) → toggle a
      quit discreet → the lock-screen rectangular widget shows "Day N" + the
      counterclockwise-arrow button ONLY (no money); VoiceOver on the button
      says "Reset". (b) **Alternate icons**: pick "Calendar style", confirm
      the home-screen icon swaps (iOS shows its own confirmation alert —
      platform behavior) and the app NAME still reads "Ballast" (an iOS limit
      we recorded: a discreet icon is not a discreet app); this row also
      verifies the actool wiring end-to-end — a misspelled build setting
      fails SILENTLY, so only a device proves it. (c) **The shield**: with a
      discreet quit, background the app → the switcher card is BLANK (also
      try it with the panic sheet open — that was the panel's big catch);
      with NO discreet quit, the card shows content (per-spec; see the veto
      list if you want universal). (d) **Erase**: with an alternate icon set,
      one-tap erase → the icon reverts to the primary "surfaced breath".

## 8. TelemetryDeck app ID — NOW THE LAST GATE on real funnel data (~10 min + a ~30 min audit when you're ready)

> **Heads-up added Session 23, LANDED Session 24:** the RevenueCat wiring now
> exists and is DORMANT exactly like this TelemetryDeck item — see the new
> RC block below.

- [ ] **NEW (Session 24 — THE REVENUECAT KEY, the vertical's wake switch,
      ~10 min when you're ready):** create the app in the **RevenueCat
      dashboard** (SaaS credentials are operator-held by design —
      agent-workflows §1.3) and paste the PUBLIC SDK key into
      `RevenueCatConfiguration.revenueCatAPIKey`
      (`App/Sources/Monetization/RevenueCatConfiguration.swift`). Until then
      the SDK is never initialized — zero network, no anonymous ID, and the
      summary CTA routes to the dashboard exactly as today. The moment a
      build carries the key: non-subscribers hit the paywall after the quiz
      summary, and RevenueCat starts caching entitlements (its own privacy
      manifest declares Purchase History only, not linked, not tracking —
      recorded for your App Privacy label; the wiring also switches the
      SDK's automatic device-identifier collection OFF).
- [ ] **Sequenced AFTER the key (sandbox-verification time, the MVP §7
      purchase matrix — THIS is where your accounts become blocking):** in
      the RC dashboard create the entitlement **"premium"** + the three
      products matching `ProductCatalog` EXACTLY —
      `com.beyondkaira.ballast.monthly` ($6.99), `com.beyondkaira.ballast.annual`
      ($29.99, 3-day trial — the control + bundled arm),
      `com.beyondkaira.ballast.annual.hi` ($39.99, 3-day trial — the
      Superwall B arm) — attach all three to "premium", build an offering
      with monthly + the control annual, and create the same products in
      App Store Connect. The sandbox matrix (trial start, trial→paid,
      monthly, restore, reinstall, cancellation) is your half of the Epic 7
      acceptance.
- [ ] **NEW (Session 24, ~5 min, rides any Mac sitting):** open
      `App/Resources/Ballast.storekit` in Xcode 26 once — it was
      hand-authored on the Linux box against Apple's documented structure
      (Apple publishes no formal schema), and a one-time open-and-save in
      the real editor validates/normalizes it. Also worth the same sitting:
      run the app with launch env `UITEST_PAYWALL=1` to eyeball the paywall
      screen (it is unreachable any other way until your key lands).

- [ ] **NEW (Session 26 — THE WIN-BACK OFFER CONFIG, sequenced WITH the
      sandbox-matrix block, ~15 min):** in **App Store Connect**, on
      `com.beyondkaira.ballast.annual`, create a **Promotional Offer**:
      type **Pay Up Front**, duration **1 year**, price **$14.99**, offer
      identifier **`winback_annual`** (this exact string — it is the pinned
      analytics `offer` value and the id the app will request; the panel
      REJECTED Apple's native "win-back offer" type on evidence: its
      eligibility floor is 1 month + prior paid history, which your
      7-days-post-trial-lapse cohort fails). Then in **App Store Connect →
      Users and Access → Integrations → In-App Purchase**, generate (or
      reuse) the **In-App Purchase Key** and upload it to the **RevenueCat
      dashboard** (Project settings → Apple → In-App Purchase Key) — RC
      signs promotional offers with it; without the key the discounted
      purchase cannot be authorized. **UPDATE (Session 29): the app-side
      signed-purchase path is now BUILT** — the winback screen's CTA calls
      `promotionalOffer(forProductDiscount:product:)` →
      `purchase(package:promotionalOffer:)` on `ballast.annual` with offer
      `winback_annual`, and the local `Ballast.storekit` test config now
      declares the same offer (pay-up-front / $14.99 / 1 year — parse-pinned
      in CI so the two config homes can never drift). We PROVED the live
      signed call is unexercisable without this key (RC signs SERVER-side —
      its SDK has no offline path — and Apple's local StoreKit test
      environment has no signature bypass), so the ONLY thing between the
      app and the live 50%-off discount is this upload — zero further
      app-side code. Your standing "open Ballast.storekit once in Xcode 26"
      rider now also normalizes the new adHocOffers entry. One vetoable
      ruling rides along (R29.9): if ASC/dashboard drift ever leaves the
      offer OFF the fetched product, the purchase FAILS honestly (retry +
      restore reachable) rather than silently charging full price after
      "half price" copy — veto = you prefer a full-price fallback. Nothing
      here blocks builds.
- [ ] **NEW (Session 25 — THE SUPERWALL KEY, the A/B's wake switch,
      sequenced AFTER the RC key — it does nothing until RevenueCat is
      live, the vertical wakes as a unit):** create the app in the
      **Superwall dashboard** and paste the public API key into
      `SuperwallConfiguration.superwallAPIKey`
      (`App/Sources/Monetization/SuperwallConfiguration.swift`). Until then
      the SDK is never initialized — zero network, no identity — and every
      build shows the bundled hard-wall control paywall. The wiring
      restricts event fan-out (`eventTrackingBehavior = .superwallOnly`).
- [ ] **Sequenced WITH the Superwall key (dashboard config):** TWO
      triggers/placements — **`quiz_completed`** and (NEW, Session 26)
      **`winback`** (the win-back presentation registers its own placement,
      architecture §5.2); the teaser-vs-hard experiment
      with its two paywalls (teaser = escape allowed; hard = no close); the
      $29.99-vs-$39.99 price experiment binding
      `com.beyondkaira.ballast.annual` (control) vs `….annual.hi` (B arm);
      then fill the **variant-id mapping** in
      `SuperwallPlacement.variantMapping` (your dashboard's opaque variant
      ids → `teaser`/`hard` — a one-line agent edit per id; unmapped ids
      safely render the hard control arm). For your App Privacy label:
      SuperwallKit's own manifest declares Purchase History (not linked,
      not tracking) + a FileTimestamp API reason, and the dependency pulls
      a checksummed Rust binary (`libcel.xcframework`) — recorded here so
      App Store review surprises no one.
- [ ] Create the app in the **TelemetryDeck console** (SaaS credentials are
      operator-held by design — agent-workflows §1.3) and paste the app ID into
      `AnalyticsConfiguration.telemetryDeckAppID`
      (`App/Sources/TelemetryDeckSink.swift`). Until then the transport is a Noop
      sink and the SDK is never even initialized — zero bytes leave any build.
      **Status change (Session 19): E8.2's consent step SHIPPED, so this is now
      the ONLY remaining gate** — the moment a build carries your app ID, opted-in
      users' funnel events (quiz steps 3–13, quiz_completed, urge_averted,
      slip_undone) start flowing; decliners still transmit nothing, ever. Still
      no urgency — but it is now a one-item decision, not half a double gate.
- [ ] While creating the app, decide the **salt** (optional `Config(appID:salt:)`
      hardening — 64 random chars; TelemetryDeck says set it once and never change
      it, or distinct-user continuity breaks). Record the decision; wiring it is a
      one-line agent edit.
- [ ] **NEW (Session 19, sequenced AFTER the app ID ships in a TestFlight
      build): run `docs/payload-audit.md`** — your operator-only MITM release
      gate (~30 min with the doc open; mitmproxy + the step-by-step §4
      procedure). Archive the result per its §6 checklist
      (`docs/audits/payload-audit-<build>.md`) — that archive IS the Epic 8
      DoD's operator half and the evidence base for the App Privacy label. The
      zero-before-consent half is verifiable on today's dormant build too, if
      you want a dry run of the tooling.
- [ ] **NEW (Session 30 — THE APP PRIVACY LABEL ENTRY, ~15 min at submission
      time):** `docs/app-privacy-label.md` is the ready-to-enter row set,
      derived from the closed analytics enum with code evidence per row: THREE
      collected rows (Usage Data › Product Interaction; the habit CATEGORY —
      see OQ-2 below; Purchases › Purchase History once your RC key is live),
      all Not-linked / Not-tracking, NO Identifiers row, everything else
      explicitly Not Collected. Its §1 recommends declaring the LIVE-state
      rows rather than "Data Not Collected" (the false-label window opens the
      instant a key lands, and your review build runs keyed for the paywall
      anyway). **OQ-2 (counsel, VETO-CLASS): the habit-category taxonomy
      call** — the recommendation is **Health & Fitness › Health** (the
      reviewer-safe mapping for a 17+ addiction app); the alternatives are
      Sensitive Info, or folding it into Product Interaction with the
      sensitive-class disclosure carried only in the privacy policy. Declare
      exactly ONE — ratify before ASC entry. The label re-derives on any
      analytics-enum change (the doc carries that trigger verbatim), and it
      stays "code-derived, wire-verify pending" until your app ID lets the
      MITM audit confirm it on the wire.

---

## 9. ✅ RESOLVED (Session 32) — the "uipro" discrepancy: it was on the box all along

**Nothing is needed from you. Closed.**

Resolution (2026-07-14): `which uipro` →
`~/.nvm/versions/node/v20.20.2/bin/uipro` (v2.11.0) — **an npm command-line
tool**, which is exactly why Session 31's probes missed it: they searched the
AI-assistant surfaces (skills registry, plugin marketplaces, MCP tools) and
never looked at the shell PATH. You had installed it correctly; we looked in the
wrong places. `uipro init -a claude` installs its "UI/UX Pro Max" skill into
`.claude/skills/` (gitignored — machine-local tooling, the same treatment
`.codegraph` gets).

UIR sessions now drive it as the generator per your standing instruction, with
one rule: **where its stock output contradicts your brand canon, your canon
wins** — every palette it ships carries a RED destructive token (banned in this
product), its wellness style pick self-reports low contrast, and its type advice
assumes Google Fonts against our SF-only rule. What we ADOPTED from it (its UX
acceptance criteria — WCAG floors, token-driven single-source theming, dark+light
co-design, disabled-state emphasis, visible focus, tabular numerals, scrim
ranges) and what we OVERRODE is recorded in `docs/design/tokens-v2.md` §8.

ONE FYI, no action needed: it rides nvm's node v20.20.2 — if you change the
default node version on this box, uipro may drop off PATH. Sessions probe
`which uipro` at open either way.

- [x] Locate/confirm uipro — **found: PATH binary, this box, v2.11.0**

---

## Decisions on record you can veto (FYI, no action needed)

- **Session 32 (UIR-0, the design system) — the rulings, each vetoable
  (R32.1–R32.9; full grounds in the S32 ledger):** the four worth your eye:
  1. **Five LIGHT palette hexes were CORRECTED away from your brandkit §2
     prose** (primary `#0E7A6F`→`#0C6F65`, caution `#9A6B00`→`#8C6100`,
     positive `#2E7D4F`→`#2C774B`, secondary `#5B6ABF`→`#5262BC`, tertiary
     `#8A9097`→`#80868E`). Grounds: your brandkit's own claimed contrast
     ratios were never machine-verified, and four of them FAIL their stated
     thresholds on real surfaces (caution 4.34, positive-on-sunken 4.27,
     secondary-on-sunken 4.18, tertiary 2.73–2.98 against a 4.5 floor). The
     corrections are hue-preserving lightness walks — a few percent darker,
     side-by-side in `docs/design/tokens-v2.md` §7. **Dark mode needed zero
     changes.** Veto = say the word and a session reverts any of them, at the
     cost of re-opening the matching WCAG failures (and re-disabling the
     contrast audit on the affected frames).
  2. **Disabled buttons now render as "ghost"** (gray text on a sunken gray
     capsule) instead of brandkit §6.1's 40%-opacity teal. Grounds: the
     40%-opacity form computes 1.4–3.1:1 at EVERY alpha value, the very first
     quiz screen shows a disabled Continue, and Apple's audit inspects
     disabled controls (R32.9). Veto = restore the 40% form and accept a
     permanently-failing contrast audit on the quiz + age-gate frames.
  3. **The paywall's free-trial badge sits on a NEUTRAL capsule now** —
     green-on-green-tint computes 4.29:1, under the 4.5 floor. Veto = keep the
     green tint and exclude that pair from the gate.
  4. **The contrast audit is RESTORED on the crisis paths** — from now on a
     contrast regression HALTS merges. That is the point of the session, but
     it is real new hardness and you should know it exists: any future color
     change that dips below WCAG fails CI until it is fixed or the pair is
     deliberately de-registered.

- **Session 31 (R30.6 privacy manifests + the UIR roadmap change) — the
  rulings, each vetoable (R31.1–R31.8; full grounds in the S31 ledger):**
  1. **The widget manifest declares 1C8F.1 ONLY** — the .appex executable
     reaches App-Group UserDefaults via the panic-intent launch flag; the
     app's CA92.1 deliberately does NOT appear there (no `.standard` compiles
     into the widget — copying the app's reason set would mis-state what that
     binary does). Veto = declare identical sets in both (legal but less
     honest; one-line edit + pin repin).
  2. **The manifest's collected-data half declares the 3 LIVE-state rows NOW**
     (Product Interaction / Health / Purchase History — mirroring the label
     doc, R30.4 grounds re-applied), even though today's keyless build
     collects nothing. Same posture as the label: the live path activates on
     a key upload, not a code change. Veto = strip to the required-reason
     half until key-land (opens the same false-window R30.4 closed).
  3. **The Health row bakes the OQ-2 RECOMMENDED taxonomy into the shipped
     binary ahead of counsel** — deliberately, because label + manifest are
     lockstep by design: when counsel ratifies (or repicks), ONE session
     updates label doc + manifest + pin together. Veto = hold the Health row
     out of the manifest until counsel rules (breaks lockstep meanwhile).
  4. **Born-green over red-first, 1 billed run** — ruled by the lead over a
     recorded two-judge split; the designed red's entire evidence value
     (fires-on-absence) was reproduced free on the Linux box ×3 timezones
     before the push. Veto = future manifest-class sessions run red+green at
     2 billed runs.
  5. **The UI Reactor gates submission assets** (roadmap v1.1) — G0
     screenshots must show the post-UIR surface. This is YOUR quality bar
     made binding; waive it any time and submission prep resumes on the
     current UI.

- **Session 30 (E10.2 build half) — the rulings, each vetoable (R30.1–R30.7 +
  OQ-1/OQ-2; full grounds in the S30 ledger):**
  1. **OQ-1 — displayLabel "Porn"/"Weed" (the one worth your eye):** carried as
     the §3 decision item above — a documented Brand-vs-QA deadlock over an
     existing sanctioning test; yours to settle, silence = the words stand.
  2. **OQ-2 — the habit-category label taxonomy (Health & Fitness › Health
     recommended):** carried as the §8 counsel item above; declare exactly one.
  3. **R30.4 — declare LIVE-state label rows, never "Data Not Collected":**
     veto = you prefer the keyless-minimal posture for a genuinely keyless
     review build, accepting the must-flip-on-key-land gate the doc records.
  4. **R30.2 — the explicit-terms lexicon is GRAPHIC-register only:** the
     category nouns porn/weed and the sanctioned ASO forms ("porn addiction",
     "dopamine detox", "nofap") are deliberately NOT banned — banning the noun
     would false-fire on sanctioned clinical/ASO copy. Veto = name the tokens
     you want added; lexicons only grow.
  5. **R30.5/R30.6 handling:** the missing PrivacyInfo.xcprivacy is scheduled
     as Session 31 (agent work, no ask); the review-notes draft claims only
     "no explicit/graphic terminology" (the safe true form) rather than
     "clinical noun on every surface" while OQ-1 is open.

- **Session 28 (E9.3) — the panel-signed rulings, each vetoable
  (R28.1–R28.13; full grounds in the S28 ledger):**
  1. **THE ONE WORTH YOUR EYE — the deferred contrast/text-scaling findings
     (R28.13):** Apple's audit measured sub-WCAG contrast on the panic
     skip + "I slipped" buttons, the slip confirm-cancel/undo, several
     secondary texts, and the disabled quiz Continue (white on faint teal
     ≈1.3:1), plus text that clips under large type on the redirect
     options/skip/confirm subtext. Every finding is preserved in run
     29262073722's CI artifact. The fixes are BRAND decisions (a darker
     teal / stronger secondary) whose golden re-records cascade, so they
     ride the a11y-visual/golden-batch session WITH your copy pass. The
     audit classes stay excluded IN-CODE (grow-only, documented) until
     then — the app ships today with those violations, dormant-monetization
     era, pre-external-beta. Veto = pull the visual pass forward as its own
     session.
  2. **The eyes-free preference rides the panic pre-cache file (R28.2):** a
     render-necessary, content-free accessibility Bool joins the same
     pre-unlock-readable file the panic screen already reads (the discreet
     flag's admissibility class; presence-only, stamped only when ON). The
     panic route still never opens the store. Veto = an app-group
     UserDefaults key instead (more moving parts, same exposure).
  3. **The toggle lives on the Discreet Mode screen (R28.3, the THIRD
     R22.7 amendment)** — one settings sheet, universally framed
     ("eyes-free for anyone", never an accommodation). Veto = its own
     settings surface.
  4. **The audit family is split per-leg under the plan's single name
     (R28.6):** panic/slip legs can never be quarantined (rule 11); the
     quiz leg carries a pre-worded valve; the quiz mount is a DEBUG-only
     direct mount that bypasses the age-gate SCREEN in the test lane only
     (the gate's un-bypassability stays unit-pinned).
  5. **"Logged." speaks as "Logged" to VoiceOver (R28.13):** the audit's
     classifier rejects terse word+period labels; the visible title is
     untouched (it is your copy). Veto = retitle in the copy pass.
  6. **Two stale-within-tolerance goldens (R28.4/R27.12):** the default-size
     haptics-only goldens still depict "Follow the circle…" within the 1%
     pixel tolerance; they re-record free with the next touch of that
     family.

- **Session 27 (E9.1/E9.2) — the panel-signed rulings, each vetoable
  (R27.1–R27.14; full grounds in the S27 ledger):**
  1. **The alcohol notice mounts on the DASHBOARD, once EVER app-wide, both
     goal modes** (R27.6). The recorded gap worth your eye: in the LIVE-keys
     era a hard-walled non-converter never reaches the dashboard, so never
     meets the notice (today, dormant, everyone does). Veto = move it to the
     quiz summary (its own session — paywall-seam sequencing work).
  2. **The notice's "See resources" tap fires NO analytics** (R27.4): the
     `resources_viewed` source domain stays closed {settings, slip_flow};
     an out-of-domain open is honest-by-omission (the S16 age-gate shape).
     Veto = an `alcohol_notice` source value, which needs your mvp §5 row
     first. Same posture: a panic-descended (cold-route) slip's resources
     open is intentionally unmeasured — the panic path constructs no
     analytics.
  3. **The GLOBAL fallback is NUMBER-FREE and applies ONLY to the new
     post-gate screen** (R27.7): no legitimate worldwide crisis number
     exists, so the bucket carries calm guidance + the findahelpline.com
     pointer; the age gate's blocked-minor surface keeps unmapped→US (a
     verified 988 floor beats an empty bucket for a blocked minor). Veto
     directions: unify both on GLOBAL (sweeps the S16 pins), or add
     verified per-country rows as you verify them (flag flips are free).
  4. **No region picker yet** (R27.7): device-region resolution + the GLOBAL
     fallback ship; the picker (its `regionPickerLabel` string already
     ships) waits for a session you request.
  5. **The resources screen shows ALL verified rows for the region,
     crisis-first, with NO active-quit filtering** (R27.8): hiding the
     alcohol line from a vape-quit user is a safety anti-pattern. Veto =
     category filtering or your-quits-first ordering.
  6. **Once-shown means once EVER** (R27.5/R27.6): a second alcohol quit
     never re-shows the notice (the resources screen stays one tap away);
     one-tap erase sweeps the stamp, so a post-erase fresh install meets it
     again. Veto = per-quit re-show.
  7. **The notice card's glyph is `lifepreserver`, amber-tinted** (R27.9):
     `info.circle` could not be doc-verified from the build box (the
     standing rule treats unconfirmed spellings as nonexistent). If you
     verify it in the SF Symbols app and prefer it, the swap is one word.
- **Session 26 (E7.3) — the panel-signed rulings, each vetoable
  (R26.1–R26.15; full grounds in the S26 ledger):**
  1. **ANY lapse qualifies, not just trial-lapse** (R26.4): the entitlement
     machine deliberately keeps no trial-vs-paid history, so "7 days post
     trial-lapse" ships as "7 days post ANY lapse" — a lapsed-monthly user
     meets the annual offer as an upsell. Veto = restrict to lapsed-annual,
     a one-line policy change.
  2. **The offer auto-presents at most ONCE PER APP LAUNCH** (R26.6) and is
     always dismissible ("Not now"); the Settings row is the persistent way
     back. Veto directions: every-foreground (pushier) or settings-only
     (quieter) — both one-line cadence changes.
  3. **The 7-day window is a wall-clock DURATION with an INCLUSIVE
     boundary** (R26.3) — the teaser precedent, never calendar-anchored.
  4. **The winback paywall is DISMISSIBLE** — an OFFER never traps (your
     hard onboarding wall and the teaser re-present stay close-free; this
     dismiss exists ONLY on the winback surface). Veto = close-free winback
     (the panel advises against: a lapsed user can reach the dashboard
     today, so an unclosable wall would trap them — Epic 7's own DoD).
  5. **The lapse stamp CloudKit-mirrors** with its AppSettings siblings
     (R26.1): a same-iCloud reinstall keeps the win-back clock honest
     across devices; the flip side is a monetization-adjacent timestamp in
     the mirror (it is an app-observation instant, never a purchase
     instant). Veto = device-local storage, a store-location change.
  6. **The win-back presentation registers its OWN Superwall placement
     (`winback`)** and fires BOTH winback_shown AND
     paywall_viewed(source=winback) — dual-funnel by design; read the
     paywall funnel source-segmented or the top line inflates (recorded).
  7. **No `winback_eligible` event exists** — eligible→shown is
     unmeasurable in-app-only BY DESIGN (it would need firing on users who
     never open the app). This is the honest cost of the no-notification
     ruling (§3's ratification item).

- **Session 25 (E7.2) — the panel-signed rulings, each vetoable
  (R25.1–R25.14; full grounds in the S25 ledger):**
  1. **The teaser is a 24-HOUR WALL-CLOCK duration** (take it at 23:00,
     it runs to 23:00 tomorrow) — deliberately NOT the calendar-day rule
     your widgets use; expiry is silent (no countdown anywhere). Veto =
     calendar-day anchoring, a two-literal change in TeaserPolicy.
  2. **The escape is SINGLE-USE:** when the wall returns after the free
     day it has NO escape (else "Then this screen returns." is a lie and
     the wall never walls). Veto = repeatable escape + a copy rewrite.
  3. **An entitled user always beats a stale teaser** (a purchase mid-teaser
     never re-meets the wall), and a decliner's teaser day still works
     (consent gates analytics, never product behavior).
  4. **The bundled/keyless paywall reports variant "hard"** — a first-class
     A/B value, never a third "bundled" bucket (keeps your denominators
     readable); `paywallVariantAssigned` is written ONLY by a live Superwall
     assignment, and it CloudKit-syncs (a same-iCloud reinstall may restore
     a pre-erase echo — accepted, attribution-only).
  5. **`purchase` fires only on user-initiated PAID completions** — never on
     trial starts (those are `trial_started`; no double-counting your ≥8%
     metric), never on restores, never on renewals (not client-honest).
  6. **`Superwall.reset()` is NOT in the one-tap erase** — it crashes on an
     unconfigured build and phones home on a live one; a data wipe already
     clears the teaser + echo rows. Revisit at the live-key session.
  7. **Scenario-29's valve fired and the smoke is deferred WITH evidence**
     (its one allowed run disproved the wheel theory — the gate→quiz
     hand-off itself hangs on CI, both driven and seeded; screenshots in
     the failed run's artifact); its event-assertion tail was already
     deferred by name — the funnel events are pinned at the unit tier.
     Veto = order an immediate re-land + diagnosis session and accept the
     billed-run cost.

- **Discreet quits keep VERBATIM motivations in the pre-cache** (labels stay
  stripped) — Session 10 ruling. Veto before E5.2 if you want discreet
  motivations minimized instead.
- **A completed store-route undo DELETES the Slip row** (Session 11, shipped
  Session 12) — an undone slip never counts against Reduce allowance or insights;
  its CloudKit tombstoning is a named §4.3-flip design item.
- **The cold slip flow writes ONLY the outcome buffer** (single-writer pre-cache
  pin, Session 11) — repeat-cold-slip display honesty comes from the in-memory
  draft fold, never a second writer to `panic-snapshot.json`.
- **Redirect menu ships the JSON's 4 options** (ratified override, not drift).
- **E3.3 attribution ceiling (Session 13, recorded adjustment):** control-family
  launches (Control Center / lock-screen slot / Action button) all record
  `.controlCenter` — iOS has no launch-surface API for controls (docs-checked,
  WWDC24 10157). `.actionButton` stays reserved in the schema. Veto path: a new
  dedicated `PanicSource` case for the "Reset" control would need a schema
  decision, not a platform fight.
- **Shortcuts exposure (Session 13):** the lock-screen widget intent ("Panic")
  remains Shortcuts-discoverable (pre-E3.3 behavior); a Shortcuts-run launch
  attributes `.lockscreenWidget` exactly as the old hardcode did. The control
  intent is NOT discoverable (the discreet "Reset" control rides it — a Shortcuts
  row titled "Panic" would leak what it hides).
- **Session 16 (E5.1 age gate) — the panel-signed rulings, each vetoable:**
  1. **Conservative age boundary:** birth-year-only entry (deliberate PII
     minimization) ⇒ PASS only when `currentYear − birthYear ≥ 18`; a difference
     of exactly 17 could still be a 16-year-old and BLOCKS. Costs a genuine
     17-year-old born late in the year a temporary block; duty-of-care-safe
     direction. Veto paths: literal `≥ 17`, or collect month+year.
  2. **The `age_gate_blocked` analytics event was NOT added** (the plan's third
     test was re-specced): consent lives POST-gate and is hardwired off until
     E8.2, so the event could never legally fire from a blocked user — and it
     would mark a device as a blocked minor, exactly the data this app refuses
     to hold. Instead a test pins the ENTIRE age-gate surface fires ZERO
     analytics. No mvp.md §5 edit happened (canonical, yours). Veto = tell the
     next session to propose the §5 row for you to add.
  3. **Verified-only helplines for blocked minors:** the blocked screen renders
     only `appliesTo:"all"` + `verified:true` rows (US → 988; TR → 112 until you
     verify 182, §3 above). An unverified number never faces a minor — the
     directory's own `_meta` posture, now test-pinned.
  4. **A blocked user is never locked out permanently:** nothing is persisted on
     block (the storage rule allows only the `ageGatePassed` boolean), so
     relaunch re-asks — the App-Review-standard self-attestation bar; a "Go back"
     on the blocked screen recovers a fat-fingered year in-session.
  5. **No discreet variant on the gate screens:** pre-gate no habit context
     exists to hide — "made for adults / 17+" is generic App Store language; a
     shoulder-surfer learns nothing.
- **Session 17 (E5.2 quiz) — the panel-signed rulings, each vetoable (all held
  through the green close; one look-ahead: Session 18 opens with a step-0 on
  SOCIAL-PROOF content — PRD wants "real review quotes", none exist pre-launch,
  and fabricated ones are banned by MVP §7, so the panel will pick
  defer-the-screen vs a non-testimonial trust frame; veto by telling Session 18
  your preference):**
  1. **`quiz_completed` is NOT fired by E5.2 — it moves to E5.3's summary render.**
     Your mvp.md §5 fixes its trigger as "Personalized summary shown", and the
     summary screen is E5.3's; firing it at quiz-questions-complete would inflate
     the ≥70% start→summary funnel metric and corrupt the ≥8% conversion
     denominator. E5.2 leaves a named handoff seam `(habitCategory, goalMode)`.
     mvp.md untouched (the Session-16 step-0 discipline). Veto = tell the next
     session to fire it at quit creation instead.
  2. **`quiz_step_completed` carries a FIXED canonical step number** (habit=1 …
     commitment=13; summary=14 is E5.3's): hidden conditional steps and the
     reserved consent slot simply emit no event — numbers never renumber per
     user, so funnel drop-off stays comparable. The on-screen progress bar shows
     the user's visible position ("Step 4 of 11") — two different numbers, both
     honest.
  3. **The consent step is a RESERVED, unrendered seam at slot 3** (E8.2 drops
     the real consent UI into it without renumbering). E5.2 renders nothing
     there, never touches `analyticsOptIn`.
  4. **The quiz resume checkpoint lives in app-STANDARD UserDefaults** (never the
     App Group suite — that's readable pre-unlock, and the checkpoint can hold
     the custom habit name), is cleared on completion, and one-tap erase sweeps
     it (test-pinned).
  5. **Snapshot goldens stay at zero for Epic 5 — the batch point MOVED to
     post-founder-copy.** Recording goldens against DRAFT copy guarantees a paid
     re-record when you rewrite the words; the one deliberate CI-artifact
     re-record now batches E5.1 + E5.2 + E5.3 screens AFTER your §3 copy pass.
     (Refines Session 16's "batch with E5.2" note.)
  6. **The scenario-29 quiz XCUITest defers to E5.3** — as specified it asserts
     the full funnel through summary + paywall, which don't exist yet; the
     Epic-5-DoD "age gate un-bypassable" obligation is met NOW at the unit tier
     (routing pins: gate → quiz → quit is the only path to content). Veto = a
     dedicated new E2E slot this session (the QA plan §5 documents the honest
     shape it would take).
  7. **Motivation chips store the display words themselves** (id == label:
     "Self-respect", "Faith", …) so the panic screen echoes the user's own words
     verbatim without the repository ever reading the copy table.
- **Session 18 (E5.3 summary) — the panel-signed rulings, each vetoable (all
  held through the green close):**
  1. **The social-proof screen is DEFERRED post-TestFlight-feedback** (step-0,
     PM+Architect+Brand unanimous): no real review quotes exist pre-launch;
     fabricated ones are banned (MVP §7 + Honest); no analytics event brackets
     the screen so deferral costs zero measurement; and the trust-frame
     alternative would fire the paywall's own privacy line one screen early,
     back-to-back. The summary CTA is the reserved NAMED seam E7 remaps. **Veto
     = tell Session 19 to build the trust frame — its full Brand-verified copy
     table is in the Session 18 ledger, no new panel round needed.**
  2. **Savings display FLOORS to the ten** ("~$1,350/year" from $26/wk — never
     overstate a motivational projection; the stored value stays the exact
     Decimal 1352). Veto = plain nearest-10 (one pure edit + two test literals).
  3. **Risk-window precedence** evenings > afterWork > social > alone >
     boredom > stress (clock windows beat mood states; multi-select collapses
     to the single "first" window); `frequency` reserved-but-unused v1; no
     triggers → NO line, never a guess.
  4. **`predictedRiskWindow` stores the trigger TOKEN, never the phrase** —
     your DRAFT copy stays out of the (future-mirrored) store; a copy rewrite
     never migrates rows.
  5. **Summary-once, in-memory:** relaunching during the summary's few seconds
     lands on the dashboard without re-showing it or re-firing quiz_completed —
     a conservative funnel undercount (the safe direction). No persisted flag,
     no new field. Veto = a persisted summary needs a schema decision first.
  6. **The gate→quiz→summary XCUITest was built, flaked its first CI drive,
     and its pre-recorded valve fired — scenario-29 DEFERS to E7** (where the
     full quiz→summary→paywall E2E lands with drive diagnostics). The
     `UITEST_RESET` fresh-install hook it introduced stays (test-only launch
     env; sweeps store + App Group + the quiz checkpoint; the prerequisite for
     any future state-mutating UITest). Unit routing pins hold the Epic-5
     DoD's un-bypassability meanwhile. Veto = tell Session 19 to re-land the
     smoke now and spend billed runs debugging the birth-year wheel drive.
  7. **`quit_created` wiring deferred AGAIN, with a plan:** firing it now would
     flip a green E5.2 assertion (its spy guard). It rides the E8 wiring batch
     where that guard is intentionally widened in the same commit.
  8. **The hero renders the tested display string split** (numeral hero +
     subordinate "/year" on the same baseline). The residual double-"year"
     read against the caption is YOUR §3 copy call (Brand's alternative
     recorded there); extreme-accessibility hero sizing (stack-vs-shrink)
     rides the post-copy-pass polish/golden batch.
- **Session 19 (E8.2 consent) — the panel-signed rulings, each vetoable (all
  held through the green close):**
  1. **The rendered consent step EMITS `quiz_step_completed(3)`** — post-choice,
     through the generic gate (decliners are gate-dropped by the gate itself;
     zero special-casing). It is the cleanest opt-in-numerator proxy and keeps
     the consenting funnel contiguous 3→14. Veto = suppress the slot-3 fire (a
     documented one-line test fork; tell Session 20).
  2. **Recorded LIMITATION, not a bug: the opt-in RATE has no event-based
     denominator.** `onboarding_started` and quiz slots 1–2 fire BEFORE the
     consent choice, so the gate drops them for everyone (your mvp.md §5's
     "fire nothing before the opt-in choice", enforced literally). The
     measurable funnel begins at slot 3; an opt-in rate needs an external
     denominator (App Store Connect units). The alternative — a consent event —
     is forbidden (no §5 row; adding one is yours alone).
  3. **Both hardwired consent-off sites retired into ONE vended live service**
     (composition root constructs; repository vends; the quiz model consumes) —
     an opt-in at slot 3 governs the same run's later fires. The age-gate
     surface keeps its dead service (zero-fire, belt-and-braces).
  4. **The consent choice is a device setting, by type:** slot 3 renders via a
     new `StepKind.consent` whose UI can only call `recordConsent` → your
     stored `AppSettings.analyticsOptIn` (written AT the tap) — never a
     QuizAnswer, never the resume checkpoint. Erase resets it OFF (the existing
     AppSettings row deletion; test-pinned).
  5. **Brand struck "anonymous" from the consent copy** (title + accept button)
     as an unverifiable overclaim and an asymmetric nudge; the audit-backed
     "never tied to you" rides the helper instead. Veto = restore it, but note
     the payload audit cannot prove the word.
  6. **The degraded emergency config carries NO consent step** — its users
     simply never opt in (fail-closed; an unmeasured emergency path defaulting
     to no-collection is the safe direction). Veto = a hardcoded degraded
     consent step (needs its own copy sign-off round).
  7. **`quit_created` deferred AGAIN, deliberately:** guard-4 (the opted-in spy
     that must see NOTHING at quit creation) was left un-widened precisely
     because it protected the completion seam while consent churned it. The
     wiring earns its own session (ordinal pins, multi-quit fixture, the
     guard-4 widening in the same commit).
  8. **No new UITest; the payload audit IS the end-to-end wire's gate** (a
     simulator UITest never touches real TLS or the real SDK's batching). The
     consent step shipped with stable a11y ids so E7's smoke can drive it.
  9. **No Settings opt-out surface yet** — the copy promises nothing unbuilt; a
     real Settings analytics toggle is a recorded roadmap candidate
     (GDPR/revocability fast-follow). Veto = pull it forward as its own session.
  10. **The selected consent chip uses the same hardcoded white as every
      shipping answer chip** (no brand/onPrimary token exists in-repo); the
      token refactor rides the post-founder-copy polish/golden batch with the
      Session-18 hero-sizing note.
- **Session 20 (E6.1 widget timeline provider) — the panel-signed rulings, each
  vetoable (all held through the green close):**
  1. **⚠️ THE ONE WORTH YOUR ATTENTION — "Day N" means a CALENDAR day, not a
     24-hour block (now ADR-11).** Someone who quits Tuesday at 11pm sees **"Day
     2" on Wednesday morning**, not at 11pm on Wednesday. The widget's day number
     turns over at *their* local midnight, in the timezone they quit in (so a
     flight can never hand them a free day). The alternative — counting whole
     24-hour blocks — is what the streak *engine* computes internally, and it
     would show "Day 1" all through Wednesday and "Day 0" on the quit day itself.
     Four of your own planning docs already assumed the calendar reading (the
     plan's own test is literally named "entries cross midnight, increment day"),
     so that is what shipped. **This is a real product call and it is now binding
     on the dashboard too** — whatever renders "Day N" there must use the same
     rule, or your widget and your app will disagree by a day for the same quit.
     Veto = tell Session 21 you want 24-hour blocks (a one-function change plus
     two test literals, cheap NOW, expensive once the dashboard ships).
     Side-effect worth knowing: milestones ("One full day", "72 hours") stay keyed
     to *elapsed hours*, so a milestone can unlock a day after the widget flips —
     they answer different questions on purpose.
  2. **E6.1 shipped the PACKAGE HALF ONLY** — the planner exists and is tested,
     but nothing feeds it and no widget renders it yet. The plan tags that row
     `[PKG:WidgetToolkit]` and its acceptance is "only templates live in the app";
     doing the app half too would have cost 2 more billed runs and dragged in a
     database schema change (storing each quit's start timezone) that deserves its
     own privacy review. Session 21 (E6.2) does the feed + the families together,
     which is when a real streak first appears on your lock screen. Veto = tell
     Session 21 to split it differently.
  3. **`WidgetToolkit` is Foundation-only BY RULE** — it may never import WidgetKit
     or SwiftUI. Not aesthetics: its CI lane runs on free Linux, and a WidgetKit
     import would force it onto the macOS runner that bills at 10x. WidgetKit code
     lives in the app's widget extension instead, which is exactly what the plan's
     acceptance criterion asks for.
  4. **`widget_added` is still not wired** (carried since the plan was written).
     The widget extension *structurally cannot* send analytics — it has no
     TelemetryDeck dependency, and your consent flag lives in the database, which
     ADR-6 forbids the extension from touching. Your own mvp.md already hedges the
     trigger as "via widget first-render signal", so the fix is a fire-point
     decision (the extension leaves a breadcrumb; the app sends it, behind consent),
     not a re-spec. Session 21 rules on it explicitly.
  5. **The widget gallery still shows developer jargon.** Anyone who long-presses
     to add your widget today reads **"Walking-skeleton placeholder widget."** —
     it has been shipping to TestFlight since Session 01. Real strings are
     safety-content-gated copy and join your §3 founder pass in Session 21.
- **Session 21 (E6.2 widget feed + families) — the panel-signed rulings, each
  vetoable (all held through the final green):**
  1. **StandBy is DEFERRED to v1.1** — your mvp.md §3 explicitly cuts it ("ship
     in v1.1 with Live Activity work") even though the implementation plan's
     E6.2 row and one test name assumed it; mvp.md is canonical, so the
     plan-named StandBy test was re-specced out (the Session-16 precedent) and
     the safety-gated "made it through the evening" copy defers with it. Veto =
     tell Session 22 to build the StandBy pair (it needs its own copy
     sign-off round).
  2. **The widget feed's field set (R1)** — per-quit: id, streak start, fixed
     timezone id, weekly spend + currency, banked clean seconds, momentum %,
     milestone hours. The ABSENCE list is the point (no habit category, no
     label, no motivations, no slip data). One accepted trade-off: only the
     vape ladder carries a 12h rung, so a sharp eye reading the raw file could
     infer "maybe vape" from the ladder — a single low-confidence bit, accepted
     to keep the milestone bar honest. Veto = flatten every ladder to a common
     rung set (loses per-category pacing).
  3. **"Day N" semantics on the ring/ticker (R6):** the circular family renders
     the DAY RING — the ring is progress through YOUR CURRENT DAY (it completes
     at your midnight, when the number flips), not progress toward a milestone;
     milestones live on the systemMedium bar. Veto = a milestone-progress ring
     on the lock screen (re-opens the ladder-leak and a stale-bar problem).
  4. **widget_added stays unwired; the mechanism is now RULED (R8):** the
     extension writes a tiny App-Group breadcrumb (widget kind + discreet flag
     + first-render time) and the APP transmits it later, behind your consent
     gate — the extension itself still can never send anything. Building it is
     E6.3's call (it needs one more privacy review + a fourth erase site).
     Veto = drop the breadcrumb idea entirely, or pull it forward.
  5. **WidgetToolkit bumped to 1.1.0** (the planner grew a milestone-crossings
     parameter + a decode-hardening fix; semver-minor; tag
     `widgettoolkit-v1.1.0` at your convenience).
  6. **SkeletonWidget RETIRED for the real "StreakWidget" kind** — the E0.2
     placeholder (hardcoded "Day 0", dev-jargon gallery text) is gone; placed
     placeholder widgets vanish and testers re-add "Streak" once (§5). The
     panic button carried into the rectangular family. Veto = resurrect the old
     kind as an alias (not recommended: two "Streak" cards in the gallery).
  7. **The extension links StreakEngine** (beyond the plan's WidgetToolkit-only
     note) so money-saved renders through the ONE engine formula everywhere —
     recorded deviation, Foundation-only, no privacy surface change.
- **Session 22 (E6.3 discreet + icons + shield) — the panel-signed rulings,
  each vetoable (all held through the green close):**
  1. **The discreet medium widget drops the WORD "next milestone"** (keeps the
     bare progress bar): "milestone" is recovery-culture vocabulary that
     strengthens the tracker gestalt beside a day count and a Reset button.
     Veto = keep the label (one-line render change + re-record 4 goldens).
  2. **The today-dot is #3D6C9E, not "system blue"** (§4.3 prose deviation,
     Brand-ruled): a static PNG cannot bake a dynamic color; #3D6C9E is your
     semantic/info token — non-brand, non-red, calmer. Veto = regenerate with
     #007AFF via the committed script.
  3. **The app-switcher shield covers WHEN-DISCREET (the plan's spec), and
     fails CLOSED on an indeterminate signal.** The privacy panel recommends
     UNIVERSAL (banking-app-style; non-discreet users' panic/slip sheets stay
     exposed in the switcher today, and a blank-for-everyone card is less of
     a tell than a blank-only-for-hiders card). Universal is a ONE-LINE
     policy change + zero new goldens. Veto direction of your choice.
  4. **widget_added stays unwired — DEFERRED to E8, UNANIMOUS 6/6** (the
     analytics sink is Noop until your §8 app ID, so the funnel loses ZERO
     data; building it now meant a new pre-unlock file + a fourth erase
     artifact + extension-side writes on a 2-run budget). The E8 builder
     inherits the pre-approved field set MINUS the discreet bit (privacy
     amendment: {kind, firstRenderAt} only). Veto = pull it into its own
     session.
  5. **The unavailable-state wind glyphs stay (rect button + circular
     fallback)** — a quit==nil state has no discreet flag to branch on, and
     changing the rect one re-records a committed golden. RECORDED as a
     future polish-batch candidate (neutralize both in one deliberate
     re-record). Veto = do it next session.
  6. **The two alternate icons are agent-generated DRAFT art** (see §3) —
     your veto is the intended review path; behavior tests pin
     switch/persist/reset/fire, never pixels.
- **Session 23 (E7.1 PaywallKit package half) — the panel-signed rulings,
  each vetoable (all held through the green close; the docs-verifier role —
  every RevenueCat claim checked against SDK source, no tutorials — is now a
  standing panel seat for SDK-facing sessions):**
  1. **⚠️ THE ONE WORTH YOUR ATTENTION — offline grace: the entitlement
     mapper has NO clock.** If a trial or subscription expires while the
     device is offline, the app keeps honoring the last state RevenueCat
     reported until it can reach RevenueCat again — it can never locally
     flip a paying user to locked-out (your architecture §8's own
     "never lock a paying user out because the network is down", the
     anti-Quittr rule; RevenueCat's SDK additionally enforces its own
     ~3-day grace ceiling app-side). The cost: a lapsed-while-offline trial
     keeps premium until next contact. The alternative (local expiry math)
     was proposed by QA and STRUCK by lead arbitration as contradicting
     your canon. Veto = tell Session 24 you want local expiry — it is a
     mapper change + new pins, cheap now, and it changes who gets locked
     out when.
  2. **The package persists ZERO bytes** — the "cached entitlement store"
     is in-memory only; durable caching is RevenueCat's SDK (your §3
     "entitlement state is never a data model of ours", now structural:
     nothing in the package is even Codable). A future entitlement bit in
     any pre-unlock file (widget feed / panic snapshot) is gated: Architect
     §10 pre-approval, presence-only Bool ceiling, never product/expiry.
  3. **`trial(product:)` carries NO expiry date** (privacy: no Date payload
     anywhere in the public API — nothing to tempt a future wire into
     transmitting a purchase instant). Trial-countdown UI, if ever wanted,
     is a named additive decision with its own privacy look.
  4. **PaywallKit bumped 0.0.1-skeleton → 1.0.0** (first real content, the
     WidgetToolkit precedent; tag `paywallkit-v1.0.0` at your convenience)
     and its 90% coverage floor is CI-live on the free lane (98.21% actual).
  5. **purchases-ios pinned by RECORD at 5.80.3** (exact-pin precedent) but
     NOT added to the project this session — the SDK is Darwin-only and a
     linked-but-unconfigured network SDK is a supply-chain surface with no
     consent wiring. It enters project.yml in Session 24, DORMANT behind
     your RC key (the TelemetryDeck §8 pattern).
- **Session 24 (E7.1 app half — RevenueCat DORMANT + the bundled paywall) —
  the panel-signed rulings, each vetoable (all held through the green close;
  the docs-verifier seat verified every SDK member against the 5.80.3 tagged
  source, twice — pre-red and pre-green):**
  1. **⚠️ WORTH YOUR EYE — the bundled paywall is a HARD wall: no "Not now",
     no close.** Your mvp.md §6 says "hard-ish … nothing past the summary
     without trial/purchase, except the A/B'd 1-day teaser" — and the teaser
     is Superwall's variant (next session), so the bundled default ships with
     no free pass to the dashboard. Brand's recorded caution: a zero-dismiss
     onboarding paywall carries App-Review scrutiny risk; a visible "Not now"
     is the safer posture and the copy for it ("Not now", quiet button)
     already exists unused in the table. Zero live impact today (the screen
     is dormant-unreachable) — decide before the key lands. Veto = one line
     + the closeLabel wiring.
  2. **⚠️ WORTH YOUR EYE — one-tap erase CANNOT revoke a subscription, by
     design and by platform.** The erase flow now clears the entitlement
     caches (new step 5, before the CloudKit purge), but entitlements live on
     the APPLE ACCOUNT: StoreKit restores them on the next receipt sync, and
     purchases-ios 5.80.3 has NO anonymous-identity reset at all (`logOut()`
     literally throws for anonymous users — verified in source; the original
     erase TODO's "anonymous-ID reset" promise was softened to match
     reality). "Fresh install" after erase means fresh DATA — a paying user
     who erases stays a paying user. This is correct (a wipe is not a
     cancellation) but it is now permanent, documented behavior.
  3. **The dormant gate constructs NOTHING without your key** — not even the
     never-source model (the CTA gate is `entitlementModel == nil`, the
     strongest possible fall-through). The composition fork is spy-pinned
     both ways; `Purchases.configure` is unreachable on the empty-key branch.
     Veto path: none needed (flipping the key IS the veto).
  4. **trial_started's dedupe marker is written ONLY on a consented send**
     (QA's rule, chosen over mark-on-observe): a decliner's device persists
     ZERO bytes about their trial, and a user who opts in mid-trial still
     counts exactly once (RevenueCat replays state each launch; the next
     consented replay fires). Consequences: a trial that starts AND ends
     entirely while consent is off is never counted (correct — zero before
     consent), and a reinstall during a trial may double-count (both caches
     wiped; no server-side dedup exists in this architecture). Veto = the
     mark-on-observe alternative (undercounts late opt-ins instead).
  5. **An UNRECOGNIZED product SKU still honors an active entitlement**
     (mapped to the annual tier for display/analytics granularity only) —
     your §8 "when in doubt, honor the entitlement" applied to catalog gaps:
     a future SKU added in the RC dashboard before an app update can never
     lock a paying user out. Veto = strict mapping (unknown ⇒ not entitled)
     — the direction that locks users out on config drift.
  6. **paywall_viewed and purchase analytics do NOT fire this session** —
     your mvp.md §5 defines `variant` as "(Superwall id)", so a
     bundled-fallback constant doesn't fit the row's vocabulary
     (fit-or-defer; mvp.md untouched). Both fire-points land with E7.2's
     variant assignment; the A/B denominators stay pristine by construction.
     Veto = tell Session 25 to backfill a "bundled_default" variant
     vocabulary (needs your §5 row edit first — yours alone).
  7. **scenario-29 (the quiz→summary→paywall E2E smoke) defers to E7.2 a
     second time, on NEW grounds:** its analytics tail (paywall_viewed) is
     E7.2's by ruling 6; its purchase leg cannot run on CI at all
     (xcodebuild never engages a scheme's StoreKit configuration — verified
     against RC's own docs, not assumed); and a historically-flaky UI drive
     on a one-contingency session is the largest avoidable burn. The S18
     drive-diagnostics debt carries with it BY NAME. Meanwhile the paywall
     mount is unit-pinned and the render is string-pinned (every
     guideline-3.1.1 disclosure). Veto = tell Session 25 to land the smoke
     first, before Superwall.
