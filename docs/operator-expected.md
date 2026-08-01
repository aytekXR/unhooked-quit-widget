# Operator Expected — the live "what only aytek can do" checklist

| Field | Value |
|---|---|
| Status (S60) | LIVE — **only OPEN items are listed here.** **The agent side of the submittable-ASAP path is CLOSED.** R58.2 (the 3.1.2(c) disclosure clipped on the review build's own arm) is fixed and green; **the final golden batch is COMPLETE** — the age gate and the quiz were the last two surfaces without goldens, so nothing in the app is unpinned (165 goldens, 16 suites). **Minting them found the worst defect currently known and fixed it the same day: R60.2 — at the largest accessibility text size the year wheel collapsed to zero, so a legally-required 17+ gate could not be completed, and had been that way since the screen was built.** Three things were also built to shorten YOUR list rather than describe it: `scripts/deploy_public_site.sh` (six manual steps → one command, with `--selftest`), `docs/safety-signoff-package.md` (forward it, no assembly), and `docs/g0-name-clearance.md` (a real finding — `BALLAST` is a LIVE, renewed US trademark to BOSU Fitness in Class 028). **Also closed a submission requirement nothing here tracked:** App Store Connect will not accept a listing without a Support URL, and no such page existed — `site/support.html` now does. **What is left for you is four inputs and a device sitting.** Nothing is waiting on an agent. |
| Read first | **`docs/critical-path-post-uir.md`** — the single-page, dependency-ordered launch playbook; it sequences this file. For the beta: **`docs/testflight-beta-kit.md`**. |
| Rule for agents | Update this file at session end alongside `resume-prompt.md`. **Keep it OPEN-items-only** — when an item closes, DELETE it here and record the closure in the `past-prompts.md` ledger; never re-accrete session history, closed-section stubs, or FYI narrative. Section numbers are kept stable (gaps are fine) because other docs cross-reference §3/§7/§8. TRACKED in `docs/` so the operator can read it anywhere. |

---

## START HERE — the five that unblock everything else

Everything below this block is real and open, but it is a long list and not all of it is
load-bearing. These five are, in this order. Nothing else on this page blocks another item.

| # | Do this | ~Time | Why it is first |
|---|---|---|---|
| 1 | **`scripts/deploy_public_site.sh --apply`** (§3) | **~2 min** | The only gate on the external beta AND on submission. The paywall's Terms/Privacy links and the beta's declared privacy-policy URL all fail at **TLS** today. **S60 collapsed the six manual steps into one script** — it pushes the nginx block, symlinks it, tests it, runs certbot in the right order, rsyncs, and verifies. Dry-run by default; run it once to read the plan. **It needs your SSH key** — that is the whole reason it is yours (root, aytek, ubuntu, deploy, admin and www-data were all tested from this machine; every one is refused) |
| 2 | **Paste your phone number here** (§5 step 2) | ~1 min | The single string blocking Beta App Review; the API rejects the write without it. One command finishes the contact block. Nothing else on this page is blocked on one field |
| 3 | **Submit the newest build + invite the roster** (§5 steps 3–4) | ~10 min | Two commands, after 1 and 2. Then the ≥1-week beta clock finally starts — the longest-running gate you do not control |
| 4 | **Forward `docs/safety-signoff-package.md`** (§3) | **~2 min** | Someone else's clock. **S60 assembled it**: cover note, every string quoted verbatim from the shipping JSON, and the specific question each reviewer must answer — clinician and counsel in one document, no attachments. Was "assemble and send"; it is now "send" |
| 5 | **G0 — the TRADEMARK half only** (critical path step 7) | — | **S60 narrowed this and the narrowing is worth reading.** The App-Store-**name** half is in much better shape than the docs assumed: your ASC record is already reserved as **`Ballast - Quit`**, which means Apple's own uniqueness check accepted it, and a live App Store search returns **no app named "Ballast"** (nearest: "Boat Ballast", "Ballasted" — both Utilities). So what is actually open is the **USPTO trademark knockout**, which is legal work and stays yours. See §3 |

Items 4 and 5 are handoffs — start them the same day as 1 so three clocks run at once. The device
sittings (§1/§2/§7) and the remaining keys (§8) are your own afternoon and block nothing but
themselves.

---

## 0. Redesign acceptance — your half

> The §0 decision is answered: **(B), the redesign runs before launch**, given as a standing
> instruction. It gates nothing now. What is left below is your acceptance of what shipped.

- [ ] **Founder copy pass** over the wave-1/2 DRAFT tables (all shipped operator-instructed, every
      `_meta` kept DRAFT): `widgetMomentCopy.json`, `StreakDetailCopy`, `panicSupport` in
      `safetyCopy.json`, the summary `footer`/`cta`, the erase dialog strings, the dashboard
      panic-entry labels, the wave timer's `elapsedLabel`.
- [ ] **ME-7 adds FIVE strings to that same pass** (`DiscreetSettingsCopy`).
      Deliberately small: the S46 copy pass CLOSED this table, so every byte it signed is
      verbatim — including `hapticPacerRowLabel` "Breathe with taps", which §7 below tells you to
      toggle by name. Only what the new IA genuinely required changed:

      | Field | Was | Now | Why it had to move |
      |---|---|---|---|
      | `screenTitle` | "Discreet Mode" | **"Settings"** | the screen IS Settings now; Discreet Mode is one section inside it. This also aligns §7, which already says "Settings → …". |
      | `discreetModeSectionHeader` (was `widgetsHeader`) | "Widgets" | **"Discreet Mode"** | the section carries the feature's own name |
      | `panicAccessSectionHeader` | — | **"Panic access"** | new first section |
      | `widgetAdoptionRowLabel` | — | **"Add the lock-screen widget"** | its one row (re-opens the widget-adoption moment). ⚠️ **ONE WORD DEVIATES FROM YOUR COPY DOC — read the note below** |
      | `privacyDataSectionHeader` | — | **"Privacy & Data"** | new section (hosts erase; consent + "what leaves this device" join it later) |
      | `breathingSectionHeader` | — | **"Breathing"** | new section |

      Three things an agent deliberately did NOT do, so you can overrule any of them:
      **(a)** the per-quit toggle label stays the QUIT's own name (or "Tracked goal" when
      discreet) rather than a shared "Show numbers only" — with up to three quits, one shared
      label renders three indistinguishable switches, and the neutral-identity rule is a privacy
      panel amendment; **(b)** the `eye.slash` glyph was dropped from those toggle rows (the
      section header now carries the meaning); **(c)** no "Your plan" section header was invented
      — that byte is not drafted, so the win-back row sits in an unlabelled card.

      **⚠️ One byte deviates from `redesign/product-copy.md` §11, and Apple forced it.** The doc
      drafts the panic-access row as **"Add the lock-screen button"**. That fails Apple's
      accessibility audit — *"Label duplicates traits"* — because the row IS a button, so a label
      containing the word "button" restates its own trait. It is a real CI failure, not a warning
      (it reddened run `30220337353`). The word was clearly meant to name the WIDGET's panic
      button, a different object, but the check is a machine one and it gates every merge. The
      shipped byte changes exactly one word: **"Add the lock-screen widget"** — which is arguably
      the truer noun anyway, since what you add is the widget and the widget is what carries the
      button. **The rejected shortcut is worth knowing:** the bytes could have been kept by
      overriding the VoiceOver label instead, and that was refused — it would break WCAG 2.5.3
      (Label in Name), so a Voice Control user saying "tap Add the lock-screen button" would no
      longer match the control. Trading a real accessibility property for a green check is not a
      trade this project makes. **If you want different bytes, any wording without a control-type
      noun works** ("button", "image", "icon", "switch", "toggle"); a unit test now states this in
      one line if a future edit reintroduces one, so nobody rediscovers it from a red UI lane.
- [ ] **ME-8 adds NO new strings** — the Waterline field, the keyboard-step echo and the slider
      detents are all visual. Nothing joins your copy pass from this wave.
      **But two ME-8 judgments are yours, because no CI gate can make them:**
      **(a) Does the field READ?** The quiz now has a horizon behind it that advances as you answer
      (teal-over-indigo bands, a luminous waterline, one soft bloom that surfaces as you go). It ships
      at **6% opacity**, not the 12% the creative doc specifies — and that is not timidity, it is
      arithmetic: compositing the field over `surface/base` and re-measuring every text token puts
      dark-mode `content/tertiary` at **2.63:1 against its 3.0 WCAG floor** at 12%. The hard ceiling
      is now 8%, with 6% the default. **If it reads as invisible on your device, say so** — the honest
      fix is a bolder MOTIF (a taller water band, a stronger waterline), never a bolder opacity,
      because the opacity is what keeps the text legible. Worth checking in **both appearances and
      outdoors**, where a 6% tint can vanish entirely.
      **(b) The slider detents.** "How ready do you feel?" now snaps to four stops with a haptic tick
      on each, one per word. Judge the feel: too sticky, too loose, or right.
      One known-cosmetic item while you are there: the field's advance between steps may read as a
      soft drift or as a clean cut, depending on how SwiftUI treats the layer. Either is acceptable
      and the settled picture is identical; if the cut looks abrupt to you, that is worth reporting.
- [ ] **ME-4 adds NO new strings either** — the summary redesign touches no founder-owned byte, so
      there is nothing here for your copy pass. **But one decision is genuinely yours, because it
      needs copy AND a product call, and an agent may make neither.**

      **Your UX blueprint §6.5 asks the risk window to become "a 24-hour horizontal band with the
      user's likely hard window (e.g. evenings) rendered as a deeper indigo segment". It shipped as
      a designed sunken well with an indigo marker instead — emphasis, not a scale.** Two reasons,
      either sufficient on its own:

      1. **Four of your six trigger tokens have no clock meaning.** The shipped phrases for
         `social` / `alone` / `boredom` / `stress` are "around social plans", "in quiet moments
         alone", "when things get idle" and "when stress spikes". Shading an hour of a 24-hour axis
         for those users asserts a time-of-day finding the derivation never made — which `mvp.md`
         §7 forbids outright ("no fabricated statistics") and which `SummaryDerivation`'s own
         contract already refuses ("insufficient data shows nothing, not guesses"). And there is no
         range to source even for "evenings": `quizConfig.json` carries
         `{"id":"evenings","label":"Evenings"}` — a label, no hours. An 18:00–23:00 bracket would be
         invented precision on a screen whose copy you deliberately hedged to "likely".
      2. **There is no copy for it.** Your copy deck §4 lists the six window lines as "Keep. Same
         six" and drafts no axis labels. A clock needs them, and copy is yours.

      **If you want the arc, it needs exactly two things from you** — the axis labels as DRAFT
      strings for `summaryCopy.json`, and a decision on what the four non-temporal tokens should
      render (no band at all, or something else). It is a small self-contained follow-up, tracked as
      **ME-4b** on the design roadmap. If you would rather not, say so and ME-4b closes: the
      sunken-well treatment is then the final answer.

      **While you are on that screen, two things only your eye can settle** — and the first comes
      with a caveat an agent should state rather than let you discover:

      **(a) The field is mostly HIDDEN on this screen, by design, and that is worth a look.** §6.5
      puts a full-bleed Waterline field behind a full-width card — so the card occludes most of it
      and what actually reaches you is a tint in the side margins plus the area below the card. In
      the recorded goldens the crest reads as a faint arc at the card's left and right edges; it is
      clearer in dark mode than in light. That is the honest picture at the measured-safe 6%. **If
      it reads as nothing at all on your device, the fix is a bolder MOTIF — a taller water band, a
      stronger waterline — never a bolder opacity**, because the opacity is what keeps the text
      legible (and on THIS screen the ceiling is tighter than the quiz's: 0.0695 vs 0.0934).

      **(b) Does the number read as the hero?** The savings figure is now Moss green with the
      luminous horizon rule beneath it and 32pt of clearspace bracketing the stage. That is the
      whole of §6.5's "drama recovered through composition, colour and the motif, never point
      sizes", so it either works or the composition needs another pass.

      One cosmetic item disclosed rather than quietly shipped: in the **zero-spend** variant (no
      money block) the horizon rule has no caption beneath it, so there is a visibly airier gap
      before the risk-window well than in the money variant. It reads as generous whitespace rather
      than a broken layout and the card still ends at a comparable height, so it was not worth a
      billed run to tighten — but if it looks wrong to you, say so and it rides the next pass.
- [ ] **ME-9 adds NO new strings either**, and that is a finding rather than luck: §6.11's "plan
      options for never-paid users" turned out to need no new row and no new byte — the existing
      `winbackRowLabel` already reads **"See your plan options"**, which is exactly right for both
      the lapsed and the never-paid case. Only the row's CONDITION changed.
      **One thing here IS yours, because an agent changed a founder-owned file's metadata:**
      `paywallCopy.json`'s `_meta.status` said **"DRAFT — agents scaffolded, founder owns the
      words"**. It was stale by twelve sessions: your §3 pass closed that table in 46B (`3a10442`)
      and changed three of its strings. The marker now says SIGNED, with the commit named. **This
      is a correction to a description, never to a word you signed** — the 27 strings are
      byte-identical. It mattered because `docs/golden-batch.md` blocks minting goldens for DRAFT
      copy, so that one stale string is why the paywall had no goldens at all until S58.
      Overrule it if you disagree.
      **And one judgment only your eye can make:**
      **Does the paywall band read?** The top third now carries the Waterline horizon, feathered
      out so there is no cut line. Same 6% weight as the quiz and the summary — and on THIS screen
      the measured ceiling is far more generous (**0.1640** with the floors in place, vs the
      summary's 0.0695), so if it reads as invisible there is real headroom to go bolder. As
      elsewhere: the honest fix is a bolder MOTIF, not a bolder opacity.
- [ ] **⚠️ R58.2 is still open and it touches a decision of YOURS.** §8 plans to assign the review
      build to the **teaser** arm. On that arm — and only that arm, because its footer is taller —
      the auto-renewal disclosure Apple's 3.1.2(c) requires is **clipped mid-sentence** at default
      text size. It scrolls into view, and review generally accepts scrollable paywalls, so this is
      a risk to weigh rather than a certainty. **Its sibling R58.1 is now FIXED** (the failure
      banner scrolls its retry into view, gated by a UI test that asserts `isHittable` rather than
      `exists`, because the banner always *existed* — it was off-screen). R58.2 was not bundled
      with it: the fix is a composition change on an Architect-gated monetization surface and it
      rides its own run. **If you would rather the review build went out on the `hard` arm, which
      shows the disclosure in full, say so and nothing else has to change.**
- [ ] **⚠️ R60.2 (HIGH) — at the largest text size, the AGE GATE cannot be completed. Agent-fixable,
      but you should know it exists because it is a submission risk.** The final golden batch minted
      the age gate's first-ever goldens this session, and its AX5 axis found that the year-picker
      wheel **collapses to zero height**: "Year of birth" renders, and the next thing is a
      **disabled** "Continue". There is no control to choose a year, so the CTA can never enable.
      **The app's first screen — a legally-required 17+ gate — is impassable for a user at the
      largest accessibility text size.**
      It is **pre-existing**, not new, and it stayed invisible for the same reason R58.1/R58.2 and
      R60.1 did: the accessibility audit mounts at the DEFAULT content size, so Apple's own
      `.dynamicType` check has never seen AX5 on that screen, and the screen had no goldens. **Four
      defects have now been found by exactly this blindness — the pattern is itself the finding**,
      and it is worth deciding whether the audit should gain an AX5 leg app-wide.
      **✅ R60.2 IS FIXED** (same session, verified on the CI render and re-recorded): the footer
      moved out of the pinned zone into the scrolling content, and the wheel gained a minimum height
      so it can no longer be the child SwiftUI compresses away. At AX5 the wheel now renders and
      Continue is reachable, so the gate can be completed. Nothing is asked of you for that one.
- [ ] **⚠️ R60.3 — ONE THING ONLY A DEVICE CAN SETTLE (~30 seconds, add it to your §7 sitting).**
      In BOTH dark-mode age-gate goldens the year wheel renders as a bright white-to-grey gradient
      slab — the most visually dominant thing on an otherwise dark screen — with "2026"/"2025" at
      poor contrast inside it. **I first wrote this down as a confirmed dark-mode defect and that
      was overconfident.** `UIPickerView` draws its own fade mask, and in a snapshot HOST the
      backdrop behind that mask is not the app's themed surface — so a white fade is exactly what a
      host artifact looks like, and equally what a real defect looks like. From a PNG the two are
      indistinguishable, and chasing it from Linux would be guessing at pixels.
      **What settles it:** open the app in DARK MODE on your device and look at the birth-year
      wheel on the first screen. If it looks like a normal dark picker, this closes as an artifact
      and the note is deleted. If it really is a white slab with hard-to-read years, say so and it
      becomes a real fix with a known reproduction.
- [ ] **Safety-content panel sign-off** on the panic in-flow support PLACEMENT (the strings are
      lexicon-clean and the affordance only adds a path to help, but §_meta says the panel signs
      placement before ship).
- [ ] **Eyeball the current TestFlight build on your device** — the operator half of accepting the
      redesign (agents verified simulator goldens + CI; your thumb on the real widget flow is the
      missing evidence). Always take the newest build: CI uploads one per green `main`, so the
      build number moves constantly and no specific number is worth chasing. **Today the newest is
      145**, and it now carries a "What to Test" note, so TestFlight will show you what to walk.
- [ ] **Glance at the rebuilt Settings screen (~2 min).** It looks different on
      purpose: the system `List` is gone, replaced by a scrolling column of themed cards, and the
      title moved out of the navigation bar into the content. That change is what retires
      the parked AX5 accessibility defect, so the visual delta is the fix, not
      a side effect. Four goldens were eyeballed before adoption, including both at the largest
      accessibility size — but goldens cannot tell you whether it FEELS like a settings screen.
      While you are there, tap **Panic access → "Add the lock-screen widget"** and confirm it
      re-opens the widget-adoption moment.

## 1. E0.3 panic-latency — one 15-minute pass is what is left

The app-owned panic cost is **~104 ms**, measured on device (2483 ms panic arm vs 2379 ms control;
the raw figure is XCTest's own attach/quiescence handshake, not the product). **What is still
unmeasured, and only you can measure it: total lock-to-intervention** — finger down on the
lock-screen widget to a breathing screen. That span also contains the OS's intent→process-spawn
phase (architecture §11 budgets ~500–800 ms), which no in-app instrument sees. Everything points to
comfortably under 2 s, but that is an inference, not the 10/10 evidence MVP §7 asks for.

- [ ] **The 15-minute pass (tooling is ready).** `ffmpeg` is installed and
      `measure_panic.py` (in the S48 session scratch, re-creatable in a minute) parses a
      screen recording frame-by-frame and prints every attempt's span plus p90 against both
      bars. Procedure: start iOS screen recording → lock → wait ~10 s → tap the lock-screen
      panic button → let the breath screen settle → **swipe the app away in the app switcher**
      (otherwise attempts 2-10 are warm, not cold) → repeat ×10 → AirDrop the video to the Mac.
- [ ] With the numbers, settle the wording drift: MVP §7 "<2 s, 10/10" vs test-suite §1.5
      "p90 < 2.0 s" (one-line edit to the losing doc). This also decides whether "<2s" can be
      marketing copy or degrades to "fast". **Until then the copy stays "fast".**
- [ ] **⚠️ BINDING for E3.1 (recorded in `spike-panic-latency.md`):** the plan graduates this
      test into a permanent CI gate **on its raw p90**. It must not — that pins XCTest's
      overhead, not the product, and fails at 2000 ms today for reasons unrelated to the app.
      Gate on the delta (the control now ships beside it) or on the `PanicColdLaunch` signpost.
- [ ] Optional, while on the device (~5 min): feel-pass the 4-7-8 haptic rhythm in the real
      panic flow.

## 2. Try E4.1/the funnel on your device — ~10 min

- [ ] **From Xcode (Mac26 + iOS26 device):** open the project, add scheme Run env vars
      `FORCE_PANIC_ROUTE=1` + `UITEST_SEED_PANIC_SNAPSHOT=1`, run on device. Expect: the seeded
      two-quit picker → the real ~90s panic flow (4-7-8 breath bloom + haptics, urge timer, your
      seeded motivations verbatim, redirect menu) → exit → **"I slipped" → the two-tap slip flow**
      → the forgiveness screen (best/momentum framing + the calm neutral undo banner) → Undo within
      10 min → "Undone. Your streak is right where it was."
- [ ] A plain TestFlight launch shows the **age gate first**; a passing year lands on **the quiz**
      (11–13 screens: 11 always-shown + 2 conditional — the custom-habit name step and the
      reduce-goal weekly-limit step). Answering creates a real quit with your motivations verbatim,
      then the **personalized summary** (projected yearly savings / calm non-monetary reframe; likely
      hard window; your motivation words) → Continue → dashboard. Enter e.g. 2012 to see the blocked
      resources surface (988 on a US device; "Go back" recovers). **The quiz + summary copy is FINAL** —
      this is a confirm-what-you-signed pass, not a draft review.

## 3. Content sign-offs — the work that leaves this repo

- [ ] **Clinician + counsel sign-off — the safety-content SHIP GATE.** The words are
      FINAL pending their pass; nothing else blocks them.

      **➜ S60: this is now ONE action. Forward `docs/safety-signoff-package.md`.**
      It is written to be sent as-is: a cover note in plain language, every string
      quoted **verbatim from the shipping JSON** (with re-extraction commands, so it
      can be proven current rather than trusted), the two reviewers' questions
      separated because they are looking for different things, and a table of exactly
      which two metadata lines clear on approval. No attachments, nothing to install.
      It also surfaces two questions an agent could not answer: whether the alcohol
      notice should name medical supervision more explicitly, and whether firing it
      at goal-CREATION is the right moment.

      *The original assembly notes are kept below, because they name the reasoning
      behind specific strings and the package points back at them.* Send these three:
      (a) `App/Resources/Content/safetyCopy.json` — its `_meta` still reads "DRAFT — needs
      clinician + counsel sign-off" and that line is what clears on their approval. Note
      one change to draw their eye to: the alcohol notice body now says "the safest way
      **forward**" (was "the safest way to **cut down**"). The old phrasing implied gradual
      self-tapering is the safe route, which is directional medical advice and is not true
      for every heavy drinker — both stopping and tapering can require supervision. The same
      fix landed in the degraded fallback (`SafetyResourcesCopy.swift`).
      (b) the PANIC-PATH breath instruction in `panicScript.json` — "Breathe with the taps.
      In for 4, hold for 7, out for 8. Three rounds." (what VoiceOver speaks in haptics-only
      mode). It names no technique and makes no claim; if the clinician wants the counts
      de-emphasized, that is a one-line edit with no golden impact.
      (c) `docs/review-notes.md` — read top to bottom; its factual claims are source-verified.
- [ ] **⚠️ Stand up `ballast.beyondkaira.com` — THE gate on the external beta, and now the ONLY
      thing between you and sending the newest build to Apple.**
      **➜ S60: run `scripts/deploy_public_site.sh`.** It prints the plan and changes nothing;
      add `--apply` to execute. It does all six steps in the order that matters — pushes
      `scripts/ballast-nginx.conf` (extracted verbatim from the runbook §2, so the two cannot
      drift), creates the webroots, symlinks, runs `nginx -t` **before** certbot (the ACME
      challenge needs the :80 block already serving), issues the certificate, rsyncs `site/`,
      and finishes by running the verifier. It warns loudly that `terms.html`/`privacy.html`
      are absent and counsel-owned, and it refuses `--apply` if it cannot reach the host.

      **Runbook: `docs/public-site-deploy.md`** stays the EXPLANATION — why explicit locations,
      why a real 404, what the silent-200 on the apex taught us. The script is the execution.
      **It needs your SSH key and that is not a guess:** root, aytek, ubuntu, deploy, admin and
      www-data were each tried from the build machine, with both keys present, and every one
      returns `Permission denied (publickey,password)`.

      **Why it moved to the front of the queue.** The Test Information now written on the live
      account declares **`https://ballast.beyondkaira.com/privacy`** as the beta privacy policy,
      and the paywall's Terms of Use / Privacy Policy links already point at
      `/terms` and `/privacy`. **Both currently fail at TLS**, not at 404 — the wildcard `A`
      record resolves to the right origin, but the installed certificate does not cover the
      subdomain, so an HTTPS request dies before nginx is consulted. A Beta App Review reviewer
      tapping either link meets a certificate error on a subscription screen, which is the shape
      of a 3.1.2(c) rejection. **That is the whole reason nothing has been submitted yet.**

      | Path | What it is |
      |---|---|
      | `/` | The landing page — implements `redesign/marketing-strategy.md` §5 |
      | **`/beta`** | **The page you share with testers.** What the app is, how to redeem the invite, the close-free-paywall warning, the twenty-minute pass, the known oddities, how to send feedback |
      | **`/support`** | **NEW, and it closes a submission requirement nothing here tracked.** App Store Connect will not accept a listing without a reachable **Support URL**, and there was no such page — the footer linked Privacy, Terms and the beta guide and stopped there. Contact, the questions that come up most, Apple's own cancellation path, and the honest new-phone answer |
      | `/icon.png` | The link-preview image. Sharing `/beta` with a tester used to preview as a blank rectangle; every page now carries Open Graph tags pointing here |
      | `/robots.txt` | Blocks crawlers while G0 name clearance is open |

      ⚠️ **The nginx block in the runbook gained three `location` lines in S60** (`/support`,
      its `.html` redirect, and `/icon.png`). It serves explicit locations and 404s everything
      else, so a file copied up without a matching line is invisible — paste the CURRENT §2
      block, not one you saved earlier.

      Deploy is `rsync -av --delete-after --exclude README.md site/ root@…:/var/www/ballast/`
      (§4.1 of the runbook), then **`scripts/verify_public_site.sh`** — one command, now 20
      assertions, and it reads response **bodies** rather than status codes because the apex
      proved a 200 can be a lie: `beyondkaira.com/terms`, `/privacy` and *every other path*
      return a **16-byte body reading "beyondkaira.com"**. A link-checker would have called
      those legal links healthy while a reviewer met a blank placeholder. Baseline right now is
      **1 passed, 15 failed** of 16 — DNS resolves, everything else fails at TLS.
      A founder copy pass on the two agent-authored pages is owed — three deliberate deviations
      from the §5 blueprint are listed in `site/README.md` for you to overrule.
      `terms.html` / `privacy.html` are **deliberately absent and counsel-owned**; no agent has
      written them. The privacy policy is also where the sensitive-class habit-category
      disclosure lives (see `docs/app-privacy-label.md`), and it must match the App Privacy
      label exactly — a mismatch between the two is itself a review finding.
- [ ] **G0 — the trademark half, and S60 narrowed what is actually open.**
      This has been carried as one undifferentiated "name clearance" item. It is two
      halves with very different states, and only one of them is still work:

      **The App-Store-NAME half is substantially settled, by evidence rather than
      assumption.** Two things measured this session: (1) your App Store Connect record
      already exists under the name **`Ballast - Quit`**, which means Apple's own
      name-uniqueness check accepted that reservation when it was made — a colliding
      name is refused at reservation, not at submission; and (2) a live App Store search
      returns **no app named "Ballast"** anywhere in the US store. The nearest hits are
      **"Boat Ballast"** (Gorman Technology) and **"Ballasted"** (Charles Hanner), both
      **Utilities**, neither an exact-name collision nor a category one.
      *Two honest caveats:* Apple's search index does not expose *reserved but
      unreleased* names, so "no result" is strong but not proof; and the reserved name
      is `Ballast - Quit`, so if you intend to ship as plain **`Ballast`** that is a
      different string and worth confirming in ASC before you build marketing on it.

      **The TRADEMARK half is open, and a preliminary search FOUND SOMETHING — read
      `docs/g0-name-clearance.md` before you spend money on this.** Verified directly
      against USPTO's TSDR, not a third-party summary: **`BALLAST` is a LIVE, RENEWED
      US registration** — Reg. **3353077**, owner **BOSU Fitness LLC**, International
      Class **028** (sporting goods), status *"LIVE/REGISTRATION/Issued and Active"*.
      It is **not** in Class 9 or 42, which is the good news. But relatedness of goods
      is what the analysis turns on, not class identity — BOSU is a recognised fitness
      brand that has actively renewed the mark, and your own App Privacy label declares
      the habit category as **Health & Fitness › Health**. A second, weaker hit
      (**SIMPLIFY BALLAST**, Reg. 8093382, software services, registered Jan 2026) is
      in the file too.
      **None of this says the name is unusable** — co-existence across unrelated classes
      is ordinary. It says the question is now specific and cheap to answer, instead of
      open-ended: *does that Class 28 registration create real risk for a
      Health-&-Fitness iOS app called Ballast?* Hand that one sentence to counsel.
      **What is still unproven:** no bare `BALLAST` in Class 9/42 surfaced, but USPTO's
      API needs credentials and both free mirrors return 403, so that half was searched
      indirectly and deserves ten minutes in USPTO's own interface.
      An agent must not run a knockout and call it clearance — a false negative here is
      expensive and slow to discover — so the opinion stays yours or counsel's.
      **It remains the longest-lead item on the whole critical path and it gates
      screenshots, ASO and the TestFlight public link** — so it is worth starting the
      same day as the site deploy, not after it.
- [ ] **YEDAM 115 operating hours (~5 min, `helplines.json`).** The row ships with
      `hoursVerified: false` and the honest placeholder "Bilinmiyor — yayına almadan
      doğrulayın". Confirm the real hours on yedam.org.tr and replace the string.
- [ ] **US SAMHSA row — re-verify before submission (~5 min).** The 1-800-662-4357 number is
      currently answering, but SAMHSA is mid-restructuring (proposed FY2026 cuts, absorption
      into a new agency). Re-check it close to submission; a dead number on a resources
      screen is the worst class of defect this app can ship.
- [ ] **The two generated app icons** — `AppIconCalendar` + `AppIconTimer` (built to brandkit
      §4.3). Look at them on a device home screen (§7 row). Veto/replace freely; the generator
      (`brandkit/branding-assets/generate-alt-icons.py`) is deterministic and no golden pins
      icon pixels.

**Two small copy calls, both one-line agent edits once you say:**

- [ ] **Control Center / Shortcuts intent wording.** You approved changing the widget's
      VoiceOver label from "Panic — opens a full-screen reset" to "Panic — opens a
      90-second urge exercise" (geometry → function). The SAME "full-screen reset" wording
      still ships in three iOS system-UI strings: `OpenPanicIntent.swift:15`,
      `OpenPanicControlIntent.swift:15`, and `PanicControlStyle.swift:35`. These render in
      the controls gallery and Shortcuts. Left alone deliberately because your §7 device
      matrix checks those exact strings and changing system-surface text mid-matrix is your
      call. Align them or keep them.
- [ ] **Slip encouragement rotation.** `slipCopy.json` carries three encouragement lines but
      `SlipFlowView.swift:215` renders only `.first`, so lines 2 and 3 have never been seen by
      any user. Either activate rotation — one line,
      `copy.encouragement[slipCount % copy.encouragement.count]` — so a repeat user gets fresh
      framing, or delete the two dead strings.

## 5. TestFlight — the external ring, in four steps

> **Read `docs/testflight-beta-kit.md` §0 before you invite anyone (~5 min).** It is the pre-flight:
> what a tester actually meets, and what to put in the invite. Step-by-step ASC mechanics stay in
> `docs/testflight-tester-guide.md`.

**What is already done, so you do not go looking for it.** The external group
**`Friends (external)`** (`8b856317-1da2-4c41-804e-3299349951f3`, public link OFF) exists. The Beta
App Description, the feedback email (`aytek@beyondkaira.com`), the privacy-policy and marketing
URLs, and the newest build's "What to Test" are all written to the live account —
`python3 scripts/testflight_test_info.py --list --secrets-file secret.yml` re-reads every one of
them and scores what is missing. Nothing has been sent to Apple and nobody has been emailed.

The four steps below are in dependency order. Steps 1 and 2 are the only ones that need you.

- [ ] **STEP 1 — deploy the site (§3 above).** Everything else waits on it, for the reason §3
      states: the beta privacy-policy URL and the paywall's two legal links all resolve to a TLS
      failure until certbot issues for the subdomain. **This is the single highest-leverage thing
      on this page.**
- [ ] **STEP 2 — give an agent your phone number, or paste it yourself.** Beta App Review will not
      save without it:

      ```
      HTTP 409  ENTITY_ERROR.ATTRIBUTE.REQUIRED
      "You must provide a value for the attribute 'contactPhone'"
      ```

      That was measured against the live account, and it is worth knowing that **Apple's own
      published schema calls `contactPhone` optional** — the docs JSON lists all eight
      `BetaAppReviewDetailUpdateRequest` attributes as optional. The live API disagrees. One
      command completes the contact block and the review notes together:

      ```bash
      python3 scripts/testflight_test_info.py --secrets-file secret.yml \
              --contact-phone '+90 5xx xxx xx xx' --apply
      ```

      Or type it into App Store Connect → TestFlight → Test Information → App Review Information.
      The name (`Aytek Erdogan`) and email are already set; only the phone is empty.
- [ ] **STEP 3 — submit the NEWEST build for Beta App Review** (one command, after steps 1–2):

      ```bash
      python3 scripts/testflight_test_info.py --secrets-file secret.yml \
              --submit-for-beta-review --apply
      ```

      It is idempotent — if a submission already exists it says so and does nothing. **Review runs
      once per version**, so v0.1.0 pays this cost once; later builds of the same version usually
      clear without a wait. Expect roughly a day.
- [ ] **STEP 4 — hand over the roster and attach the builds.** `friends.csv` is
      `email,firstName,lastName`, one per line, header optional; reordered columns, extra columns,
      missing surnames, Excel's BOM and duplicate rows are all handled, and **one malformed address
      rejects the whole file** rather than half-inviting the list. Keep it out of the repo — it is
      other people's personal data. Dry-run first; it shows exactly who gets emailed.

      ```bash
      python3 scripts/testflight_testers.py --secrets-file secret.yml \
              --group 'Friends (external)' --roster friends.csv          # then --apply
      ```

      *TestFlight invites are **email-only**. There is no SMS or phone-number invite path, so phone
      numbers cannot be used here — names and email addresses are what the roster needs.*

      **This path was EXERCISED against the live account in S60, with synthetic
      addresses and no `--apply`, so nothing was sent.** All four shapes you might
      realistically paste parse correctly — a standard header; a reordered header using
      different names (`Email Address` / `First Name` / `Last Name`); Excel's UTF-8 BOM;
      and no header at all. A malformed address rejects the **whole file** with the line
      number, rather than inviting half the list and stranding the rest. The group
      resolves and reports 0 existing testers. So when you put real people in the file,
      the only untested variable is the people.
- [ ] **⚠️ SET THE REPO VARIABLE `TESTFLIGHT_GROUP` to `Friends (external)`, or the ring never gets
      a build after the first one.** This reverses what this file said in S57, and the reversal is
      a measurement rather than a rethink: the group was created with `hasAccessToAllBuilds: true`
      in the payload, Apple accepted the request, and the attribute **came back `null`**. The
      identical payload sets it on an internal group, so it is an internal-group property in
      practice whatever the create schema implies — and it can never be added later, because
      `hasAccessToAllBuilds` is absent from `BetaGroupUpdateRequest`. So an external ring receives
      only builds that something explicitly ATTACHES.
      `gh variable set TESTFLIGHT_GROUP --body 'Friends (external)'` makes CI's free ubuntu
      distribute job do it on every green `main`. **Do this AFTER step 3**, not before: pointing CI
      at the external group means every future build is auto-attached, and attaching to an external
      group is what hands a build to Apple.
      To attach a build by hand instead — including back-filling 145 — run the
      **"TestFlight distribute (manual)"** workflow from the Actions tab with `sweep` set to the
      number of recent builds, or locally:
      `python3 scripts/testflight_distribute.py --group 'Friends (external)' --sweep 1`.
- [ ] **⚠️ Brief testers about the close-free paywall, or the sitting stalls there (the one that matters).**
      RevenueCat going live flipped the summary CTA: every non-entitled user now routes into the paywall
      (`PostGateRootView.swift:412`), and with Superwall still dormant the variant is always the **hard** arm
      (`PaywallVariant.swift:47`) — **no close button.** Nobody is permanently stuck: force-quit and relaunch and
      the existing-quit branch mounts the dashboard (`PostGateRootView.swift:440`), and the paywall does not
      re-present because a user with no teaser grant re-enters at `.dashboard` (`PaywallRouting.swift:55`).
      In TestFlight the purchase is **free** (sandbox), so the intended
      path works and doubles as your §8 sandbox evidence. But a tester who is not told will refuse the purchase sheet
      and report "the app won't let me in". Beta-kit §2 and §4.1 are written to prevent exactly that, and the build's
      "What to Test" now says it in the tester's own words. **Two notes:**
      a non-purchaser silently skips the ME-1 widget-adoption moment (the north-star metric's only surface) — the
      script routes them back via Settings → Panic access instead; and if testers do stall, that is the argument for
      pasting the Superwall key and assigning the teaser arm (§8), which is already the decided posture for the
      *review* build.
- [ ] **Know what TestFlight does to subscriptions before a tester reports it as a bug.** Verified against
      Apple's own page: in TestFlight **every** subscription duration renews once per **24 hours** — a 1-year plan
      renews daily just like a 1-week plan — up to **6 renewals**, after which auto-renewal is disabled. (This is
      NOT the minute-scale compression the Sandbox environment uses; do not brief the sandbox numbers.) So a tester
      who subscribes on day 1 lapses around day 7 — which is the **only free way to watch a real lapse**, i.e. the
      one test that proves the R46.2 foreground-refresh fix. Ask a week-one tester to reopen the app around day 7:
      correct is the dashboard or a *dismissible* win-back offer, never a wall.
- [ ] **Check the OS floor before spending an invite (~1 min).** Minimum is **iOS 26.0** (`project.yml`). Older
      devices are not offered the build at all, which reads as a broken invite. Relevant to recruiting the ≥15
      external testers the beta gate wants.
- [ ] **Do NOT enable the TestFlight public link yet.** The build wears "Ballast" and G0 trademark/name clearance is
      still open (critical path step 7); a public link is an indexable public exposure of an uncleared name. The
      group was created with `publicLinkEnabled: false` explicitly. Email-invited external testers are fine.
- [ ] **Decide beta-tester GEOGRAPHY before you recruit (~2 min).** Verified helpline rows exist for
      **US and TR only**. Every other region resolves to the GLOBAL bucket, which by your own number-free ruling
      shows text guidance ("…call your local emergency number… visit findahelpline.com") and **no tappable
      number**; a blocked under-17 tester outside US/TR falls back to the US 988 line they cannot dial. Every
      fallback path was probed and they all behave correctly — this is design working as intended, not a bug, and an
      agent may never author a helpline row (official-source verification is yours; the ALO 182 finding is
      exactly why). But if you recruit your ≥15 external testers outside US/TR, that is what they will see. Either
      weight recruiting to US/TR, or add officially-sourced rows for the regions you recruit from — the render
      path is already proven, so adding a row is data-only.
- [ ] **Expire the stray bundle-version-"1" build (~1 min, optional hygiene).** 58 builds sit on the app, all
      VALID and unexpired, and the oldest is build **`1`** from 2026-07-08 — it predates the real widget and shows
      only a hardcoded "Day 0" placeholder. Testers with all-builds access can install it. Expiring is
      **irreversible**, which is why no agent did it: `PATCH /v1/builds/{id}` with `{"expired": true}`, or the
      Expire button in App Store Connect.
- [ ] **Re-add the widget once.** SkeletonWidget was retired for the real "Streak" widget (new kind — a placed
      placeholder disappears). Long-press → add "Streak"; the rectangular size carries the panic button. Any tester
      who had the old placeholder placed must re-add too (one-time).
- [ ] **Optional cleanup: the internal `Friends` group is now vestigial.** It has 0 testers and cannot take any
      (internal groups accept only Users on your ASC account, and there is exactly one — you, already in
      `founders`). It is harmless; delete it in App Store Connect if the two similarly-named groups would ever
      confuse you at 2am.

## 6. Slack webhook rotation — optional hygiene, ~5 min

- [ ] CI reads `secrets.SLACK_WEBHOOK_URL`; the old URL briefly sat in local git history. Rotate when convenient.

## 7. Physical device matrix (E3.3 + the carried device rows) — YOUR half of acceptance

> **Recommended: do everything here as ONE consolidated sitting (~1 hour) on today's build** — it clears the
> E3.3 matrix + the widget/discreet rows + §2's funnel try + the E0.3 measurement (§1 has the procedure and
> the tooling is installed) + the eyeball checks below. **The SECOND sitting** is the sandbox purchase matrix,
> which is live work now that the RevenueCat key is in. The payload audit still waits on the TelemetryDeck app
> ID (§8 — Superwall and TelemetryDeck are both still empty; only RevenueCat is keyed).
> For seeded quits, run from Xcode with scheme env `UITEST_SEED_PANIC_SNAPSHOT=1`.

**The eyeball checks (each a screenshot can't verify):**

- [ ] **Eyes-free / VoiceOver (~2 min):** Settings → toggle **"Breathe with taps"** ON → lock → hit the
      lock-screen panic button → the breath step shows the hand-tap glyph and the on-screen line
      **"Feel the taps — in, hold, out."** instead of the circle (with VoiceOver on you instead HEAR
      "Breathe with the taps. In for 4, hold for 7, out for 8. Three rounds." — two different strings,
      `hapticOnlyLabel` and `instructionNonVisual`), and the 4-7-8 rhythm arrives as TAPS you can follow
      with eyes shut (the haptic feel is yours to judge). Toggle OFF → the visual bloom returns. With
      VoiceOver on, swipe one quiz step + the panic steps + a slip log — every control announces a
      sensible name (the slider says its WORDS; the icon picker says which is selected).
- [ ] **Safety layer (~2 min):** Settings → "Support & resources" → your region's verified lines (US: 988 first,
      then SAMHSA/quitline/NAMI; TR: 112 + 171 + 115 — **182 is gone for good, and that is correct**: established
      against the Ministry of Health's own page that ALO 182 is the MHRS hospital-APPOINTMENT line, not a
      crisis line, so its row stays permanently `verified: false` and can never render); tap a
      number row and confirm the dial sheet shows the number verbatim. Log a slip → the forgiveness screen carries
      the same link. With an alcohol quit (or a reduce goal for one), the amber "One thing worth knowing" card
      appears ONCE — "Got it" dismisses forever, "See resources" opens the same screen.
- [ ] **Streak-ring motion glance (~1 min):** open the dashboard, confirm the **momentum ring** smoothly fills in
      (~0.6s ease-out) on first render. CI goldens capture only the settled ring, so this is device-only QA. With
      Reduce Motion on, the ring should simply appear already-filled (also correct).
- [ ] **Your day-counter report — re-verify (~2 min):** the "lock-screen day counter not working" report was
      triaged as **not a code bug** — the 2026-07-10 binary predated the real widget (it only had the hardcoded
      "Day 0" placeholder). Steps: (1) update to the newest build; (2) remove the dead widget and re-add "Streak";
      (3) open the app once (the launch refresh writes the widget feed). **If it STILL fails**, record: the build
      number, what the widget shows, whether the in-app dashboard shows the right Day N, and whether logging any
      event updates the widget within ~60s — that makes it a real device bug the next session can hunt.

**The E3.3 matrix (any post-E3.3 build works):**

- [ ] **Place the surfaces** from the system galleries: the "Streak" lock-screen widget (its wind button); the
      **"Panic"** control in a lock-screen control slot AND in Control Center; Settings → Action Button → Controls
      → "Panic".
- [ ] **Discreet check:** in the controls gallery, confirm the **"Reset"** control shows the neutral
      counterclockwise-arrow glyph and its description ("Opens a quick reset.") carries zero habit words; place it
      once and fire it.
- [ ] **Run the matrix** — each row × Focus ON and OFF; at least one pass in airplane mode (Epic 3 DoD: zero
      network dependency):

      | # | Launch from | Expect |
      |---|---|---|
      | 1 | Lock-screen widget button | picker (2 quits) → flow |
      | 2 | Lock-screen control slot | same |
      | 3 | Control Center "Panic" | same |
      | 4 | Action button | same |
      | 5 | "Reset" control (any surface) | same |
      | 6 | In-app "Panic" button on the root | picker sheet |

      Attribution values are unit-pinned, so it's enough to confirm each surface OPENS the flow. (Platform note: iOS
      provides no API to tell Control Center vs lock-screen slot vs Action button apart — one registration serves
      all three and you assign placement; rows 2/4/5 recording `controlCenter` is correct.)
- [ ] **Widget rows (~15 min):** (a) **Tinted mode** — set a tinted home screen, add systemSmall/Medium "Streak",
      confirm legibility (device-only; tinted homes can't be host-snapshotted). (b) **Day-ring mid-fill** — the
      circular family's ring fills across your local day. (c) **Freshness** — log an urge/slip, confirm the widget
      updates within ~60s. (d) **Selector binding** — with 2+ quits, long-press → Edit Widget → pick a quit;
      archive/erase it and confirm the widget shows "Ready when you are." (never another habit's streak).
- [ ] **Discreet + icons + shield rows (~10 min):** (a) **Discreet toggle** — Settings sheet → toggle a quit
      discreet → the lock-screen rectangular widget shows "Day N" + the counterclockwise-arrow button ONLY (no
      money); VoiceOver says **"Reset — opens a quick exercise"**. (b) **Alternate icons** — pick "Calendar style",
      confirm the home-screen icon
      swaps (iOS shows its own alert) and the app NAME still reads "Ballast"; this also verifies the actool wiring
      (a misspelled build setting fails silently — only a device proves it). (c) **The shield** — with a discreet
      quit, background the app → the switcher card is BLANK (also try with the panic sheet open); with no discreet
      quit, the card shows content. (d) **Erase** — with an alternate icon set, one-tap erase reverts to the
      primary icon.

## 8. §8 keys + config

> **RevenueCat is LIVE — do not redo it.** Key in the app, RC project + entitlement + all three
> products + offering + In-App Purchase Key configured, all three products READY_TO_SUBMIT across
> 175 territories. **Superwall and TelemetryDeck are still EMPTY** (`SuperwallConfiguration.swift:18`,
> `TelemetryDeckSink.swift:12`) — those two are the open keys below.

- [ ] **FREE, DO IT NOW (~2 min) — confirm no ITMS-91053 email ever arrived.** Both
      `PrivacyInfo.xcprivacy` manifests were checked against the app's actual Required-Reason-API usage and **no
      change is needed** — but that rests on Apple's published System-Boot-Time list naming `systemUptime` and
      **`mach_absolute_time()`**, while `LiveClock.swift:36` deliberately uses **`mach_continuous_time()`** (chosen
      because it keeps counting across device sleep) plus a `kern.bootsessionuuid` sysctl. Neither is named in
      Apple's list, so nothing was declared — and declaring a category you do NOT need is itself a rejection
      (ITMS-91055 "Invalid API reason declaration"), so an agent must not add one speculatively. **You already hold
      the definitive evidence:** App Store Connect emails an **ITMS-91053 "Missing API declaration"** warning after
      it processes a build, and this exact manifest + clock code has been through processing on every green-main
      TestFlight upload — 58 of them now. Search your ASC/developer email for **"ITMS-9105"**. Nothing there ⇒
      closed permanently, delete this line. If a warning IS there, paste it and an agent lands the named category +
      reason code in one run (a two-line XML edit plus its `PrivacyManifestTests` pin).
- [ ] **THE SANDBOX PURCHASE MATRIX — unblocked, and it is Epic 7's operator half.** ASC →
      Users and Access → **Sandbox** → create a test account; on the device Settings → Developer
      → **Sandbox Apple Account** → sign in. Then run: trial start · trial→paid · monthly ·
      restore · reinstall · cancellation · **the on-update regression** (the Quittr-scandal row:
      an existing subscriber must not lose entitlement across an app update). This is also **the
      only test that proves the R46.2 fix** — after a sandbox purchase the win-back settings
      row must disappear immediately, without a relaunch.
      **The first attempt failed; read this before you retry.** The sandbox account signs in fine and
      Apple's purchase sheet OPENS and shows the correct USD price, so StoreKit resolves the products and
      the account is right. The purchase then failed with the app's generic banner. A 4-agent diagnosis
      ruled out, against source: an active StoreKit config in the scheme, bundle-id or SKU mismatch, the
      win-back path being taken by mistake, observer mode, and entitlement/signing causes. The leading
      hypothesis was Apple-side product propagation, which is no longer plausible — the products were
      created several sessions ago. **One-click check first:** in the RevenueCat dashboard confirm the
      `default` offering carries the **Current** badge.
      **The error is now readable.** Retry, then read it with Console.app: connect the phone,
      select it in the sidebar, filter the subsystem to `com.beyondkaira.ballast` and look for category
      `Purchase`. You will get either the missing SKU plus which offering was current, or the RevenueCat
      error code (e.g. 23 `configurationError` = none of the products could be fetched from ASC).
      No `sudo`, no log-collect, no rebuild.
- [ ] **Open `App/Resources/Ballast.storekit` in Xcode 26 once (~5 min, any Mac sitting):** it was hand-authored
      on Linux against Apple's documented structure; a one-time open-and-save validates/normalizes it (and the
      `adHocOffers` win-back entry). Same sitting: run with launch env `UITEST_PAYWALL=1` to eyeball the paywall.
- [ ] **Superwall key:** create the app in the Superwall dashboard and paste the public API key
      into `App/Sources/Monetization/SuperwallConfiguration.swift` (`superwallAPIKey`). Until then every build shows
      the bundled hard-wall control paywall — which is also what every beta tester meets (§5).
- [ ] **Superwall dashboard config (with the key):** two placements — **`quiz_completed`** and **`winback`**; the
      teaser-vs-hard experiment (teaser = escape allowed; hard = no close); the $29.99-vs-$39.99 price experiment
      binding `….annual` (control) vs `….annual.hi` (B arm); then hand an agent the variant ids to fill
      `SuperwallPlacement.variantMapping` (opaque dashboard ids → `teaser`/`hard`; unmapped ids safely render the
      hard control). **Also assign the review build to the TEASER arm** — that is what makes the ratified
      3.1.2 posture true; it is a dashboard setting, not code. ⚠️ **Read the R58.2 item in §0 first** — the teaser
      arm is the one where the auto-renewal disclosure clips. For the App Privacy label: SuperwallKit's manifest
      declares Purchase History + a FileTimestamp reason and pulls a checksummed Rust binary
      (`libcel.xcframework`) — recorded so review surprises no one.
- [ ] **TelemetryDeck app ID (~10 min)** — create the app in the TelemetryDeck console and paste the app ID into
      `App/Sources/TelemetryDeckSink.swift` (`telemetryDeckAppID`). Until then the transport is a Noop sink (zero
      bytes leave any build), which also means **the beta produces no funnel data at all**. This is the ONLY
      analytics gate (the consent step already shipped); the moment a
      build carries it, opted-in users' funnel events flow and decliners still transmit nothing. While creating the
      app, decide the optional **salt** (`Config(appID:salt:)` — 64 chars, set once and never change it, or
      distinct-user continuity breaks); record the decision (wiring it is a one-line agent edit).
- [ ] **RevenueCat privacy toggle (~1 min, do it while you are in there):** Project settings →
      privacy → switch **device-identifier collection OFF**. The App Privacy label declares NO
      Identifiers row, so leaving it on would make that declaration false.
- [ ] **Payload / MITM audit (~30 min, after the app ID ships in a TestFlight build):** run `docs/payload-audit.md`
      — your operator-only release gate (mitmproxy + the §4 procedure; expect the real wire values, e.g. the
      cold-start bucket sends `under_1s`/`1s_to_2s`/`over_2s`). Archive per its §6
      (`docs/audits/payload-audit-<build>.md`) — that archive IS the Epic 8 DoD's operator half and the evidence
      base for the App Privacy label. The zero-before-consent half is verifiable on today's build too.
- [ ] **App Privacy label entry (~15 min at submission time)** — `docs/app-privacy-label.md` is the ready-to-enter
      row set: THREE collected rows (Usage Data › Product Interaction; the habit CATEGORY; Purchases ›
      Purchase History — RC is live now, so this row APPLIES), all Not-linked / Not-tracking, NO Identifiers row.
      **OQ-2 — RATIFIED:** the habit CATEGORY is declared as **Health & Fitness › Health**. Rationale and
      the two rejected alternatives are in `docs/app-privacy-label.md`. Counsel may still veto; if they do, the
      manifest + its key-set pin move in the same session (LOCKSTEP).
