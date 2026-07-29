# TestFlight Beta Kit — everything the first tester sitting needs

| Field | Value |
|---|---|
| Document | Beta Kit v1.0 (Session 52) — the initial-testing pack |
| Status | LIVE. §0 is a **pre-flight you must read before you invite anyone**; §1–§2 are paste-ready; §3–§5 are the sitting itself |
| Audience | Operator. §1 pastes into App Store Connect; §2 pastes into the invite; §3 is what you hand a tester |
| Companion docs | `testflight-tester-guide.md` (**how** to add people in ASC — group mechanics), `critical-path-post-uir.md` step 10, `operator-expected.md` §5, `review-notes.md` (the App Review notes this borrows from) |
| Register | Tester-facing prose follows the same bans as `review-notes.md` §4 — clinical nouns for sensitive categories, no medical/efficacy vocabulary, no shame framing, no latency number, no unshipped state described as live. Docs bypass the CI lexicon gates, so this is hand-enforced |
| Rule for agents | Keep §0 true against the code. Every claim in §0 carries a file:line anchor; if the anchor moves, re-verify the claim before editing the prose |

---

## §0. Pre-flight — five things that are true today, and what each costs you

These are not risks. They are current, verified properties of the build that is
sitting in App Store Connect right now. Four of the five change what you tell
testers; one changes who you recruit.

### 0.1 ⚠️ The paywall is close-free, and it is the first thing a tester meets after the quiz

**This is the one that can waste the whole sitting.** Read it before you send a
single invite.

RevenueCat went live in Session 48B. That flipped a branch: the summary's
"Start your streak" CTA used to fall through to the dashboard on keyless builds,
and now it routes every non-entitled user into the paywall
(`App/Sources/Quiz/PostGateRootView.swift:412-413`). Superwall is still dormant,
and a keyless Superwall build takes the bundled assigner
(`App/Sources/Monetization/PaywallPresentationComposition.swift:21`), which
returns the **hard** arm unconditionally
(`App/Sources/Monetization/PaywallVariant.swift:47-50`). The hard arm composes no
escape affordance — `teaserEscape` is nil, by design, on every impression that is
not a teaser first-impression.

So: **quiz → summary → tap the CTA → a subscription screen with no close button.**

What that means in practice, stated precisely so you can brief testers rather
than guess:

- **The tester is not permanently stuck.** The wall has no dismiss, but it is not
  a re-entry gate. Force-quit and relaunch and they land on the dashboard —
  `PaywallRouting.reentryDestination` returns `.dashboard` whenever no teaser
  grant exists (`App/Sources/Monetization/PaywallRouting.swift:55`), and a
  tester who never took a teaser never has one. The wall is a **one-time gate on
  the onboarding path**, not a permanent lock on the app.
- **The intended way through is to buy it, and in TestFlight that is free.**
  TestFlight builds transact in Apple's sandbox environment, so the trial and
  the subscription cost the tester nothing. This is also the only way to
  exercise Epic 7 from a real device, so it is worth asking for rather than
  working around. Brief them with §4.1 or they will refuse the purchase sheet —
  and a tester who refuses it stops at the wall and reports "the app won't let
  me in."
- **A non-purchaser silently skips the widget-adoption moment.** ME-1's screen —
  the only surface the north-star metric has — mounts after the onboarding
  paywall *resolves* on a live-key build, not before it. Force-quitting past the
  wall goes straight to the dashboard and the moment never renders. The
  persistent way back is **Settings → Panic access → "Add the lock-screen
  widget"** (ME-7 built that row for exactly this), so put it in the script
  (§3.1 step 9) rather than losing the surface for the whole beta.

**Your three options, in the order I'd take them:**

1. **Brief around it** (zero cost, today). §2 and §4.1 already do this. The
   tester purchases in the sandbox, the funnel completes as designed, and you get
   the sandbox-matrix evidence you need for step 5 of the critical path as a free
   side effect. **This is the recommendation.**
2. **Paste the Superwall key and assign the teaser arm** (`operator-expected.md`
   §8). This is the posture you already decided on for the *review* build
   (`review-notes.md` §3 item 1) and it gives beta testers the "look around for a
   day" escape. It is a dashboard setting once the key is in, not a code change.
   Worth doing before the *external* beta; not worth blocking the internal one.
3. Change the wall in code. **Don't.** The close-free hard wall is a ratified
   product decision (R24.9), the teaser fork already exists for precisely this,
   and a monetization-surface change is Architect-gated.

### 0.2 The minimum is iOS 26.0 — recruit accordingly

`project.yml:18-19` sets `deploymentTarget.iOS: "26.0"`. Anyone on iOS 25 or
earlier cannot install the build at all — TestFlight will simply not offer it,
which reads to a tester as a broken invite. Confirm the OS version before you
spend an invite, especially for the ≥15 external testers the beta gate wants.

### 0.3 Off the public link — but an EXTERNAL group is what a friends ring needs

Gate G0's technical half is closed (the bundle identity and domain are
registered), but the **trademark / App-Store-name clearance is still open**
(`critical-path-post-uir.md` step 7). The build wears `CFBundleDisplayName:
Ballast` (`project.yml:190`). A TestFlight **public link** is a public,
indexable exposure of an uncleared name. Email-invited external testers are
fine; the public link can wait until G0 clears.

**S57 correction — "keep the first beta internal" is not available for friends.**
Measured against the live account: the only App Store Connect **User** is the
operator, and Apple restricts internal groups to team members holding an ASC role
(Account Holder, Admin, App Manager, Developer, Marketing), max 100. External
groups take "anyone with an email address", max 10,000, at the price of Beta App
Review. **An internal group also cannot be converted** — `isInternalGroup` is
absent from Apple's `BetaGroupUpdateRequest` schema.

So the shape of the first sitting is: **a new external group, invited by email, with
the public link still off.** `operator-expected.md` §5 carries the two commands;
`scripts/testflight_testers.py` does the work from a CSV of names and emails and
dry-runs by default. The Beta App Description and Beta App Review Information that
external distribution requires are **§1.2 and §1.3 below, paste-ready** — and
`betaAppLocalizations` came back empty, so they are genuinely unfilled today.

**Email-only.** There is no SMS or phone-number invite path in TestFlight, so a
phone number cannot be used to invite anyone.

### 0.4 This beta will produce zero analytics — the signal is manual

TelemetryDeck has no app ID yet, so the transport is a Noop sink and **no bytes
leave any build** (`operator-expected.md` §8). There is no funnel data, no
`widget_added` count, no drop-off chart. Everything you learn from the initial
sitting arrives as TestFlight feedback, screenshots, and what testers tell you.
Design the script accordingly — §5 says what to ask for.

That is a deliberate ordering, not an oversight: the payload/MITM audit
(critical path step 6) has to run before real events are collected, and it needs
the app ID in a build. Testing before the key lands means testing without
watching, which for an initial sitting is the right trade.

### 0.5 Crash-free ≥99.5% needs the tester to opt in

The beta-hardening gate is crash-free ≥99.5% over ≥1 week (`roadmap.md` §3).
Crashes reach you through **TestFlight → Crashes** only if the tester has
"Share With App Developers" enabled — it is a per-device iOS setting
(Settings → Privacy & Security → Analytics & Improvements), not something the
app can request. Ask for it in the invite; §2 does.

---

## §1. Paste-ready App Store Connect fields

CI uploads builds and stops there — `fastlane/Fastfile`'s `pilot` call runs with
`distribute_external: false` and `skip_waiting_for_build_processing: true`, so it
never sets build notes, never attaches a build to a group, and never notifies
anyone. Every field below is one you fill by hand in App Store Connect. That is
the correct division: nothing reaches a human without your action.

### 1.1 "What to Test" — TestFlight → the build → Test Details

> Ballast is a habit-tracking app: you pick something you want to cut down or
> stop, and it keeps a streak, saves your own reasons in your own words, and puts
> a panic button on your lock screen for the moment an urge hits.
>
> Please walk the whole first-run: the age check, the questions, the summary, and
> then add the "Streak" widget when it offers. After that, try the panic button
> from your lock screen at least once, and log a slip at least once.
>
> **The subscription screen after the summary has no close button, and that is
> expected.** In TestFlight the purchase is free and not a real charge — please
> go through it so the rest of the app opens up. If you would rather not, quit
> the app and reopen it and you will land on the main screen.
>
> Two known oddities, both Apple's and neither a bug: your test subscription will
> renew once a day for six days and then switch itself off, and the phone helpline
> list only has real numbers for the US and Turkey right now — everywhere else
> shows written guidance instead.
>
> Tell me anything that felt confusing, slow, or wrong — especially wording.
> Screenshots from inside TestFlight are the easiest way.

### 1.2 Beta App Description — external groups only

> Ballast helps you cut down or stop a habit — vaping, adult content, alcohol,
> cannabis, doomscrolling, or something you name yourself. It keeps your streak,
> holds on to the reasons you gave for starting, and puts a panic button one tap
> away on your lock screen for when an urge shows up.
>
> Everything stays on your device. There is no account to create and nothing to
> sign in to.

### 1.3 Beta App Review Information — external groups only

Beta App Review runs once per version, on the first build you distribute
externally. Later builds of the same version usually clear without a wait.

| Field | What to enter |
|---|---|
| Contact — first/last name, email, phone | Yours. Apple uses it only to reach you about the beta review |
| **Demo account required?** | **No.** The app is account-free by design: no sign-in exists anywhere, a fresh install reaches full functionality after onboarding, and all content ships in the bundle |
| **Review notes** | Paste the block below |
| Sign-in required? | No |

> Ballast is an on-device habit-tracking utility. It stores all data on-device,
> requires no account, and puts a lock-screen "panic" control one tap from a short
> breathing exercise.
>
> A fresh install opens on a birth-year age check (17+). An under-17 entry routes
> to a resources screen; no habit content is reachable before the gate. A passing
> entry leads to an onboarding quiz of 11–13 steps (two appear only for a custom
> habit or a "cut down" goal), then a personalized summary, then the subscription
> screen.
>
> To exercise the panic control: add the "Panic" control from the Control Center
> gallery (or a lock-screen control slot, or the Action button), or add the
> "Streak" lock-screen widget, which carries the same button. It launches the app
> directly into a full-screen urge intervention. It needs no account and no
> network, and works with notifications off and Focus on. A second, visually
> neutral "Reset" control opens the same flow for users who want it discreet.
>
> One trackable category is adult-content use. It is described in clinical terms
> ("Adult content") throughout, and no explicit terminology or imagery appears
> anywhere in the app. The app is a self-tracking utility and makes no medical or
> clinical claim.
>
> Analytics are opt-in and currently dormant in this build — no analytics data
> leaves the device. Billing is StoreKit via RevenueCat.

**Register check before you paste:** this text is bound by `review-notes.md` §4.
No latency number, no "anonymous", no medical vocabulary, no explicit terms, and
nothing dormant described as live.

### 1.4 What CI does *not* do, so you are not waiting on it

| Thing | Who does it | Why |
|---|---|---|
| Upload a build | **CI**, every green `main` | `fastlane beta`; build number = the GitHub run number, so newest run = highest build |
| Set "What to Test" | **You** | `pilot` runs with `skip_waiting_for_build_processing: true`, which is what keeps the macOS runner from idling through Apple's processing wait. Notes require a processed build |
| Attach a build to a group | **You**, or automatic distribution | `distribute_external: false` — CI never pushes to anyone |
| Notify testers | **You** / the group setting | — |

Leaving this manual is deliberate and worth keeping: turning the processing wait
on would add Apple-side idle minutes to **every** green merge on the priciest
runner in the matrix, to fill a field you visit anyway when you attach the build.

---

## §2. The tester brief — paste into the invite

> **S57: there is now a web page that says all of this**, at
> **`ballast.beyondkaira.com/beta`** (`site/beta.html`). It carries this brief plus the
> §3 test script and the §4 known issues, in tester-facing language. Once the site is
> deployed, the invite can be three lines and a link instead of a wall of text — and a
> link survives being read on a phone, which this block does not. The page contains **no
> invite and no build**, so forwarding it leaks nothing. Keep the text below for the
> invite email itself, or use it as the source if you prefer to paste.

> Thanks for testing Ballast.
>
> **What it is.** An app for cutting down or stopping a habit. You pick what you
> are working on, answer some questions, and it keeps your streak and holds on to
> the reasons you gave. There is a panic button for your lock screen for the
> moment an urge hits.
>
> **Before you start**
> - You need iOS 26 or newer. If TestFlight won't offer you the build, that is
>   why — tell me and I'll sort it out.
> - Please turn on Settings → Privacy & Security → Analytics & Improvements →
>   **Share With App Developers**. Without it I cannot see crashes, and that is
>   most of what I need from a beta.
> - Nothing you enter leaves your phone. There is no account and no sign-in. The
>   app does not ask for notifications, location, camera, or microphone — if
>   anything ever asks, that is a bug and I want to know immediately.
>
> **The one thing that will look broken and isn't.** After the summary screen you
> hit a subscription screen with no close button. **In TestFlight the purchase is
> free** — Apple runs it as a test transaction and you are not charged. Please go
> through it, because it is the only way to see the rest of the app and it is one
> of the things I most need tested. If you would rather not, quit the app
> completely and reopen it and you will land on the main screen.
>
> **What I need from you.** Roughly twenty minutes, following the steps I have
> sent separately. Then anything that felt confusing, slow, wrong, or badly
> worded. Wording matters as much as bugs here. Screenshot-and-send from inside
> TestFlight is the easiest route — shake the phone or take a screenshot and tap
> Share Beta Feedback.
>
> Please do not share the invite or screenshots — the name isn't final yet.

---

## §3. The test script — about 20 minutes

Hand testers §3.1 plus whichever persona in §3.2 matches them. §3.3 and §3.4 are
for whoever is willing to go around twice.

### 3.1 The spine — everyone does this

1. **Install and open.** Note anything slow or odd about the very first launch.
2. **Age check.** A birth-year wheel. Enter your real year. *(If you want to see
   the under-17 path, use a recent year — you get a calm resources screen and no
   habit content. Erase and start over afterwards, §3.4.)*
3. **The questions** — 11 to 13 of them depending on your answers. **Note the
   time when you start and when the summary appears** — roughly is fine, and it
   is a number I genuinely need. One asks
   whether to share usage data; **either answer is a valid test**, say what you
   would actually say. Two involve typing a number. *If you are outside the US or
   UK, watch the number keys closely — whether a comma or a period appears, and
   whether what you type is what you see.*
4. **The summary.** Does it feel like it was written about you? Are your own
   words in it, spelled the way you typed them? Is the money figure plausible?
5. **The subscription screen.** Read it before you tap. Price, trial length, what
   happens when the trial ends, Terms and Privacy links, Restore — is anything
   missing or confusing? Tap the Terms and Privacy links. **If you have already
   deployed the site (`docs/public-site-deploy.md`) these work and are worth
   checking; if not, they fail and that is known and on you** — say which, so a
   tester is not asked to report a failure you already know about.
   Then take the free trial.
6. **The widget moment** should appear. Follow it and add the **"Streak"** widget
   to your lock screen. Choose the wide rectangular one — it carries the panic
   button.
7. **Panic, from the lock screen.** Lock the phone. Tap the panic button on the
   widget. It should go straight into a full-screen breathing exercise showing
   *your* reasons. Do the whole thing. **How long from tap to something useful
   on screen?** That is the single most important thing you can tell me.
8. **Log a slip.** From the main screen. Read what comes back carefully — it
   should not make you feel bad. Try undoing it.
9. **Settings.** Open it and go through every section: Panic access, Discreet
   Mode, Breathing, Privacy & Data, Support & resources. In **Panic access**, tap
   "Add the lock-screen widget" and confirm it re-opens the widget screen from
   step 6.
10. **Breathing → "Breathe with taps".** Turn it on, then run the panic flow again
    **with your eyes shut**. Can you follow the rhythm by feel alone?

### 3.2 Persona passes — pick the one that fits you

- **Vape / nicotine.** Answer the spend question honestly; check the summary's
  yearly figure against your own arithmetic. Watch the streak roll over midnight
  if you can.
- **Adult content.** This is the one to run in **Discreet Mode** (§3.3) —
  the real question is whether you would be comfortable with this app on your
  home screen with someone next to you. Say so plainly if not.
- **Alcohol.** You should meet an amber "One thing worth knowing" card exactly
  once, on the summary. Read it and tell me whether it lands as caring or as
  alarming. "Got it" should dismiss it forever; "See resources" should open the
  helpline screen. Confirm it never comes back.
- **Cut down rather than stop.** Pick a "cut down" goal in the questions — you
  get an extra step asking for a weekly limit. Check the main screen respects it.

### 3.3 The discreet pass — for anyone testing camouflage

1. Settings → **Discreet Mode** → turn on the toggle for your streak. The widget
   should drop to numbers only — no habit name anywhere on it.
2. Settings → **App Icon** → "Calendar style" or "Timer style". The home-screen
   icon and its name change.
3. Add the **"Reset"** control (Control Center gallery) instead of "Panic". Same
   flow, neutral name and glyph.
4. **The real test:** hand your unlocked phone to someone. Can they tell what the
   app is for from the home screen, the widget, or the Control Center gallery?

### 3.4 Going around twice

Settings → **Privacy & Data** → **Erase everything**. Hold the button for about a
second. This genuinely deletes everything, resets the app icon, and puts the app
back to a fresh install — reopen it and the age check returns. Your subscription
is not affected; it lives with your Apple Account.

---

## §4. Known issues — tell testers, or they will report these as bugs

### 4.1 Subscriptions in TestFlight

- **Purchases are free, and the tester needs no special setup.** "Apps downloaded
  from TestFlight will automatically operate in a sandbox environment" — Apple's
  words. The tester uses the **normal Apple Account** they already have; there is
  no Sandbox Apple Account to create, sign out of, or configure. (A Sandbox Apple
  Account is optional, only for exercising specific purchase scenarios, and only
  works inside your own developer account — so it is for *your* device sitting,
  not for testers.) Nobody is charged.
- **Renewals are compressed, and TestFlight's compression is not the sandbox's.**
  Apple's TestFlight rate is **one renewal per 24 hours for every subscription
  duration** — a 1-year plan renews daily just like a 1-week plan — up to
  **6 renewals within a week, after which auto-renewal is disabled**. So a tester
  who subscribes on day 1 will find themselves un-subscribed around day 7. That is
  Apple, not the app.
  ([Testing subscriptions and In-App Purchases in TestFlight](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testing-subscriptions-and-in-app-purchases-in-testflight/))
- **That expiry is an opportunity, and it is worth planning for.** It is the only
  free way to watch a real lapse, which is what proves the R46.2 fix — the
  entitlement now refreshes on foreground rather than riding a launch-time
  snapshot, so a subscription that lapsed while the app was backgrounded should be
  noticed on the next foreground rather than at the next cold launch. Ask a
  week-one tester to reopen the app around day 7 and say what they see. It should
  be the dashboard or a **dismissible** win-back offer — never a wall.

### 4.2 The rest

| What a tester will hit | Status |
|---|---|
| The subscription screen has no close button | **Expected** — §0.1. Purchase (free) or relaunch |
| Terms and Privacy links fail | **Known, and now fixable by you.** The links are real and correct; the pages are not published yet. The site's landing + beta pages ship in `site/`; `terms.html`/`privacy.html` are counsel-owned. Deploy per `docs/public-site-deploy.md`, verify with `scripts/verify_public_site.sh`, then **delete this row** — do not leave testers briefed to expect a failure that no longer happens |
| Helplines are US and Turkey only | **By design.** Every other region gets written guidance and no tappable number, because an unverified crisis number is worse than none. Weight recruiting to US/TR or accept it (`operator-expected.md` §5) |
| The app never asks for notifications | **Correct and deliberate, and structurally so.** Verified on two axes: no shipping source references `UserNotifications`, `CoreLocation`, `AVFoundation` capture, `Photos`, `Contacts`, `HealthKit`, `EventKit` or `AuthenticationServices`; **and** the generated Info.plist declares no `*UsageDescription` key at all (`project.yml`), which is what iOS requires before it will present a prompt. So "any permission prompt is a bug" is a safe thing to tell a tester — the app has no way to raise one |
| The streak widget shows nothing useful | Ask them to **open the app once** after adding it — the launch pass writes the widget's feed. If it still fails, this is the day-counter report (`operator-expected.md` §7) and you want the build number, what the widget shows, what the in-app screen shows, and whether logging anything updates it within a minute |
| Anyone who had an older build with a placeholder widget | Must **remove and re-add** "Streak" once — the widget kind changed, and a placed placeholder just disappears |
| Prices look wrong for their country | Should **not** happen since S48B — the paywall now binds Apple's real storefront price per territory. If a tester sees a price that disagrees with Apple's own purchase sheet, that is a real bug and a high-priority one |

---

## §5. What to collect, and the gate it feeds

The gate has two halves and it is worth separating them, because one is a
recruiting target and the other is a measurement:

- **M3 / External TestFlight beta** — **≥15 external testers across the three
  personas** (`roadmap.md:37`, `:265`), recruited through authentic outreach that
  doubles as distribution groundwork. Cross-check this against the **geography**
  decision in `operator-expected.md` §5: verified helplines exist for US and TR
  only, so where you recruit and what a tester sees on the resources screen are
  the same decision.
- **Beta hardening** (`roadmap.md:266`) — **crash-free ≥99.5%**, **quiz median
  ≤120 s across 5 test users**, MITM payload audit clean, panic-latency signpost
  within budget. The last two are device/keys work (critical path steps 3 and 6),
  not beta work.

With analytics dormant (§0.4), the beta half is entirely manual. Watch five
things:

1. **Crashes** — TestFlight → Crashes. Needs §0.5. This is the gate's numerator.
2. **Did they get through the paywall?** With no funnel events, the only way to
   know is to ask. If testers are stalling there, that is the strongest possible
   argument for pasting the Superwall key and taking §0.1 option 2 before the
   external round.
3. **Panic latency, subjectively.** §3.1 step 7. Not a substitute for the
   Instruments measurement (`operator-expected.md` §1, `spike-panic-latency.md`)
   — that stays yours — but fifteen people saying "instant" or "laggy" is real
   evidence, and it is the claim the marketing copy hangs on.
4. **Quiz time — you have to hold a stopwatch.** The gate wants a **median ≤120 s
   across 5 testers**, and with the analytics transport dormant nothing measures
   it for you. Ask five testers to note the clock when the age check appears and
   again when the summary lands, or time it yourself over their shoulder. Do it
   early: if the quiz is running long, that is a finding worth having quickly.
   (**Updated S53:** ME-8, the quiz visual pass, has now LANDED, so this is no
   longer a "learn it before that work" item — it is a "learn it before **ME-8b**",
   which is the increment that would add two interstitial screens to the quiz. A
   quiz already running long is an argument for placing those two screens
   carefully, or not at all.)
5. **Wording.** The copy pass closed in S46 and every string is founder-signed,
   so a tester saying "this sentence made me feel judged" is the highest-value
   report in the whole beta. It is also the one thing no test lane, no lint, and
   no golden can produce.

**Feed it back here.** Anything structural goes to `operator-expected.md` as a
new open item; anything about copy goes to `redesign/product-copy.md`; a real
defect goes to the next session's docket.
