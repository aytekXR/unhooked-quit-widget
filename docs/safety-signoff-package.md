# Safety-content sign-off package — forward this

| Field | Value |
|---|---|
| Status | **READY TO SEND.** Assembled S60 so the operator's `operator-expected.md` §3 item is one action instead of an assembly job. |
| Who it goes to | A **licensed clinician** (addiction/behavioural health) and **counsel**, together — they answer different questions about the same words |
| What it unblocks | The safety-content **ship gate**. `safetyCopy.json`'s `_meta.review_status` reads *"DRAFT — needs clinician + counsel sign-off"*, and that line is what clears on their approval. Nothing else blocks these strings |
| Rule for agents | Every string below is **quoted verbatim from the shipping JSON**. If a string changes, re-extract — a review package that misquotes what ships is worse than no package. Re-extract with the commands in the appendix |

---

## 1. Cover note — paste into the email

> Hi — I'm about to ship an iOS app called Ballast. It's a habit-tracking tool: you
> pick something you're cutting down or stopping (vaping, alcohol, adult content,
> cannabis, doomscrolling, or your own), it keeps a streak, and it puts a "panic
> button" on the lock screen that opens a 90-second breathing exercise.
>
> **It is not a treatment app and makes no clinical claim.** That's deliberate and
> it's enforced in the build — there are automated checks that fail the release if
> medical or efficacy vocabulary appears anywhere in the copy.
>
> But four pieces of text sit close enough to health that I don't want to ship them
> on my own judgement. They're below, in full, with the specific question I need
> answered for each. There are no attachments to open and nothing to install.
>
> If anything reads wrong to you, a one-line rewrite is genuinely easy — none of
> this is baked into artwork or screenshots.

---

## 2. For the CLINICIAN

### 2.1 The alcohol notice — the highest-stakes string in the app

Shown **once**, when someone creates an alcohol quit or a "cut down" goal for
alcohol. Dismissing it is permanent; it never reappears.

> **One thing worth knowing**
>
> For some people who drink heavily or daily, stopping suddenly can be physically
> risky. If that might be you, it's worth talking to a doctor or a helpline about
> the safest way forward. This app tracks your progress — it isn't medical care.
>
> `[See resources]`  `[Got it]`

**The question:** does this warn adequately without over-claiming? One wording
change already happened for exactly this reason and it is worth knowing about —
the body used to end *"the safest way to **cut down**"*, which implied that
gradual self-tapering is the safe route. That isn't true for everyone: both
stopping and tapering can require supervision. It now says *"the safest way
**forward**"*. **Is that the right neutral framing, or should it name medical
supervision more explicitly?**

**A second question, and it's a product decision as much as a clinical one:** the
notice fires when the goal is *created*. A user who never converts on the
subscription screen reaches the dashboard by relaunching, so they do still see it
— but the ordering means the notice can arrive before any drinking has been
logged. Is once-at-creation the right moment, or should it also (or instead)
appear at some later point?

### 2.2 The breathing instruction

Two strings, because the exercise has a visual mode and an eyes-free haptic mode.
The second is what VoiceOver speaks.

> **Visual:** "Follow the circle. In for 4, hold for 7, out for 8. Three rounds."
>
> **Haptic / VoiceOver:** "Breathe with the taps. In for 4, hold for 7, out for 8. Three rounds."

It deliberately **names no technique** and makes **no claim** about what breathing
does. **The question:** are the 4-7-8 counts appropriate to put in front of an
unsupervised user in distress, and should the counts be de-emphasised? If you want
them softened, that's a one-line edit with no downstream cost.

### 2.3 The in-flow route to help — placement, not wording

During the panic flow, after the breathing pacer, a quiet link appears:

> "More support" (on the wave-timer and reasons steps)
>
> "Or talk to someone — free, confidential helplines" (on the redirect step)

It opens the helpline screen as a sheet inside the flow. **It is deliberately NOT
on the breathing frame itself.** **The question:** is that the right placement — is
offering help *after* the pacer rather than during it correct, or should the route
be available from the first moment?

### 2.4 The helplines that actually render

Only verified rows ship. Everywhere outside the US and Turkey, the app shows
written guidance and **no phone number at all**, on the reasoning that an
unverified crisis number is worse than none.

| Region | Rows shown |
|---|---|
| US | 988 Suicide & Crisis Lifeline · SAMHSA National Helpline · 1-800-QUIT-NOW · NAMI HelpLine |
| TR | 112 Acil Çağrı · ALO 171 (Sigara Bırakma) · YEDAM 115 |
| Everywhere else | Text guidance only — "call your local emergency number", findahelpline.com |

**The question:** is that set appropriate and correctly ordered for someone in
distress — and is "no number rather than an unverified number" the right call
outside those two countries?

*(One row is deliberately absent and worth stating: ALO 182 was removed
permanently after it was established to be Turkey's hospital **appointment**
booking line, not a crisis line. It had been listed with a crisis description that
was inaccurate.)*

### 2.5 The standing disclaimer

Rendered wherever the app describes what it is:

> "Ballast is a self-tracking tool, not medical or mental-health care. Milestones
> describe what people commonly report, not clinical outcomes."

**The question:** is that sufficient, and is it in the right register?

---

## 3. For COUNSEL

Counsel is looking at the same words for different reasons, plus two things the
clinician doesn't need to see.

1. **The safety strings above** — specifically whether anything in §2.1–§2.5
   constitutes medical advice, creates a duty of care, or needs a stronger
   disclaimer for the jurisdictions we'll ship in (worldwide, English only at v1).
2. **`docs/review-notes.md`** — the notes submitted to Apple's review team. Read
   top to bottom; every factual claim in it is source-verified, but it describes
   the app to a regulator-adjacent audience and is worth counsel's eye.
3. **The privacy policy and terms are counsel-owned and NOT yet written.** They
   are the one hard blocker on submission: the subscription screen links to
   `ballast.beyondkaira.com/terms` and `/privacy` as real tappable links, and
   Apple requires those to work. Two content requirements come from our side
   rather than counsel's, and both are easy to miss:
   - the privacy policy must carry the **sensitive-class habit-category
     disclosure** (GDPR / Washington My Health My Data), and it must match the
     App Privacy label **exactly** — a mismatch between the two is itself a
     review finding;
   - the auto-renewal boilerplate should be checked against App Store Connect's
     current wording ("Apple Account", not "Apple ID").

---

## 4. What happens when they approve

Two metadata lines change and the gate clears. Nothing else moves:

| File | Line today | Becomes |
|---|---|---|
| `App/Resources/Content/safetyCopy.json` | `"review_status": "DRAFT — needs clinician + counsel sign-off"` | signed, with the date and who signed |
| same file, `_meta.audit` | *"…wording below is a drafting placeholder, not cleared copy."* | the placeholder caveat is removed |

If either reviewer wants a wording change, it is a JSON edit plus a re-record of
the goldens that render the changed string — cheap, and it does not touch code.

---

## Appendix — re-extract these strings

Nothing here is transcribed by hand. To confirm the package still quotes what
ships:

```bash
python3 -c "import json;d=json.load(open('App/Resources/Content/safetyCopy.json'));print(json.dumps(d,indent=2,ensure_ascii=False))"
python3 -c "import json;print(json.dumps(json.load(open('App/Resources/Content/panicScript.json')),indent=2,ensure_ascii=False))" | grep -i 'in for 4'
python3 -c "import json;print(json.dumps(json.load(open('App/Resources/Content/helplines.json')),indent=2,ensure_ascii=False))"
```
