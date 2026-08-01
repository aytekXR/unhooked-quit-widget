# G0 — name clearance: what is settled, and what a preliminary search found

| Field | Value |
|---|---|
| Status | **Two halves, different states.** The App-Store-NAME half is substantially settled by evidence. The TRADEMARK half is open, and a preliminary search found something counsel needs to see |
| Measured | 2026-08-01 (S60), against live sources — Apple's own search API and USPTO's TSDR, not secondary summaries |
| ⚠️ NOT LEGAL ADVICE | This is a **preliminary knockout**, performed by an agent to save counsel's time — not clearance. A knockout search does not cover common-law marks, state registrations, foreign registrations, or design marks, and it does not perform a likelihood-of-confusion analysis. **Do not treat a clean-looking result here as permission to launch.** |
| Blocks | Screenshots, ASO, the TestFlight public link, submission (`critical-path-post-uir.md` step 7) |

---

## 1. The App-Store-name half — substantially settled

Two independent measurements, both against Apple:

**1.1 Your reservation already succeeded.** The App Store Connect record exists as
**`Ballast - Quit`** (`com.beyondkaira.ballast`, ASC id `6788964100`). Apple enforces
app-name uniqueness **at reservation**, not at submission — a colliding name is
refused when you create the record. So that specific string is already yours.

**1.2 No app is named "Ballast" in the US store.** A live query of Apple's search
API (`itunes.apple.com/search?term=ballast&entity=software&country=us`) returned 39
results, of which only two contain the word at all:

| App | Seller | Category |
|---|---|---|
| Boat Ballast | Gorman Technology Pty Ltd | Utilities, Sports |
| Ballasted | Charles Hanner | Utilities |

Neither is an exact-name collision and neither is in a related category.

**Two caveats, stated rather than buried.** Apple's search index does **not** expose
names that are *reserved but unreleased*, so "no result" is strong evidence and not
proof. And the reserved string is `Ballast - Quit` — **if you intend to ship as plain
`Ballast`, that is a different name** and worth confirming in ASC before any
marketing is built on it.

---

## 2. The trademark half — the finding

### 2.1 ⚠️ `BALLAST` is a LIVE, RENEWED US registration — in a fitness class

Verified directly against USPTO's Trademark Status & Document Retrieval, not a
third-party summary:

| Field | Value |
|---|---|
| Mark | **BALLAST** |
| US Registration No. | **3353077** |
| US Serial No. | 77047760 |
| Owner | **BOSU Fitness LLC** |
| Filed | Nov 20, 2006 |
| Status | **LIVE / REGISTRATION / Issued and Active** — "The registration has been renewed" |
| Status date | Feb 16, 2017 |
| International Class | **028** (sporting goods / exercise equipment), Class Status ACTIVE |

**Why this is worth counsel's attention rather than a shrug.** It is *not* in Class 9
(downloadable software) or Class 42 (SaaS), which is the good news. But the analysis
that matters is **relatedness of goods and channels of trade**, not class identity —
and two facts push in the wrong direction:

- BOSU is a **recognised fitness brand**, not a dormant registrant, and the mark has
  been actively renewed rather than left to lapse.
- Ballast's own App Privacy label declares the habit category as **Health & Fitness ›
  Health** (`docs/app-privacy-label.md`, OQ-2 ratified), and the product positions
  around quitting and wellbeing. "Exercise balls" and "habit-tracking software" are
  genuinely different goods, but they sit in the same consumer wellness space.

**Nothing here says the name is unusable.** Co-existence across unrelated classes is
ordinary. It says a competent opinion is needed before the name is baked into
screenshots, ASO and a public TestFlight link — which is exactly what gate G0 exists
to prevent.

### 2.2 A second, weaker hit

| Field | Value |
|---|---|
| Mark | **SIMPLIFY BALLAST** |
| US Registration No. | 8093382 (serial 99175729) |
| Owner | Mark Andrew Riggio (PA) |
| Filed / Registered | May 8, 2025 / Jan 6, 2026 |
| Status | **LIVE / REGISTRATION / Issued and Active** (TSDR-verified) |
| International Class | **042** — SaaS / software services, Class Status ACTIVE |
| Mark type | **Stylized/design**: *"the mark consists of the stylized wording 'simplify ballast' with simplify in light blue and ballast…"* |

**Two things about this one cut in opposite directions, and both are TSDR-verified
rather than inferred.** It is in **Class 042** — the software-services class, i.e.
genuinely the neighbourhood, not a distant industry. But it is a **composite** mark
AND a **stylized** one, and both narrow it: the commercial impression is
"SIMPLIFY BALLAST" rather than "BALLAST", and protection for a stylized mark attaches
to the presentation as much as the words. It belongs in counsel's file; it is not
the hit that should worry anyone most. That remains §2.1.

### 2.3 What was NOT found, and how much that is worth

**No BARE-WORD `BALLAST` registration in Class 9 or Class 42 surfaced** — the only
Class 042 hit is the stylized composite in §2.2, and the only bare-word `BALLAST` is
the Class 028 registration in §2.1. Both were confirmed against TSDR by serial
number, so the two hits themselves are facts rather than search results.

**But treat the ABSENCE as unproven, not as clear**, and the distinction matters:
confirming a mark you have found is easy, and proving none exists is not. USPTO's own
search API requires credentials this project does not hold, and the free mirrors block
automated access (Justia and Trademarkia both return HTTP 403 to it). What was done
here is targeted lookup, not an exhaustive class sweep. **Ten minutes in USPTO's own
search interface closes that gap** — search `BALLAST` restricted to Classes 009 and
042, live marks only. That is the single remaining piece of this page an agent could
not do.

---

## 3. What to do with this

- **Give §2 to counsel** alongside the safety package (`docs/safety-signoff-package.md`).
  The specific question is narrow and answerable: *does BOSU Fitness LLC's live Class
  28 registration for BALLAST create a real risk for a Health-&-Fitness-categorised
  iOS habit-tracking app named Ballast?*
- **Run the Class 9 / Class 42 search properly** in USPTO's own search — that is the
  gap §2.3 leaves open, and it is ten minutes of your time or five of counsel's.
- **Decide the exact string** — `Ballast` vs the reserved `Ballast - Quit`. They are
  different names for both purposes, and the second is already reserved.

**Until this closes, the standing constraints hold:** the TestFlight public link stays
off (an indexable public exposure of an uncleared name), and no screenshot, ASO field
or marketing asset gets built around the name.

## Appendix — reproduce these

```bash
# App Store, live
curl -s "https://itunes.apple.com/search?term=ballast&entity=software&country=us&limit=40" \
  | python3 -c "import json,sys; [print(r['trackName'],'—',r['sellerName']) for r in json.load(sys.stdin)['results'] if 'ballast' in r['trackName'].lower()]"

# USPTO TSDR, authoritative status for a known serial
curl -s -A "Mozilla/5.0" "https://tsdr.uspto.gov/statusview/sn77047760" | grep -o "LIVE/[A-Z/]*"
```
