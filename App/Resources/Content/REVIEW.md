# Content Drafts — Operator Review (Phase 4, feasibility condition #2)

| Field | Value |
|---|---|
| Status | **DRAFT — awaiting operator line-by-line review + medical/legal sign-off** |
| Author | Agent-drafted 2026-07-08 for review (operator chose "agent drafts") |
| Wired into app? | **No.** Inert JSON at the eventual bundle path. Not referenced in `project.yml`; the audit tests (test-suite §1 tests 12–13 + helpline-region) get added with the UI epic that consumes these. |
| Audit self-check | Passed a local scan: 0 medical-claim tokens, 0 shame-lexicon tokens, all 43 milestones carry a "commonly reported" marker, all JSON valid. |

## Files

| File | What it is |
|---|---|
| `milestones.json` | 43 milestones across all 6 categories (vape, alcohol, porn, weed, doomscroll, custom). Experiential, "commonly reported" framing — deliberately avoids the clinical cessation timeline. |
| `panicScript.json` | The ~90s panic flow: breath (4-7-8 × 3) → timer → reasons (`{{motivations}}` verbatim) → redirect, with discreet-mode overrides and both exits (urge passed / slipped). |
| `slipCopy.json` | Forgiveness flow: confirm, logged (best archived + momentum preserved), optional reflection note, 10-min undo. |
| `safetyCopy.json` | Alcohol withdrawal notice (shown once, calm, points to help, makes no medical claim) + resources-screen framing + not-medical-care disclaimer. |
| `helplines.json` | Region-aware directory (US + TR), verified numbers, dial-tap `dialString`s. |

## ⚠️ Must resolve before ship

1. **Medical + legal sign-off on `safetyCopy.json`** — the alcohol withdrawal notice is drafting placeholder wording; a clinician + counsel must clear it.
2. **Helpline verify-flags** (see `helplines.json._meta.MUST_VERIFY_BEFORE_SHIP`):
   - TR **ALO 182** crisis line: only third-party-verified — confirm on an official Sağlık Bakanlığı page. **112** is included as the confirmed fallback.
   - TR **YEDAM 115** operating hours: unconfirmed.
   - US **compulsive-behavior**: no verified dedicated national hotline exists; the circulating `1-800-837-9041` was deliberately **excluded** as unverified/likely defunct. NAMI + 988 used as the neutral, non-shaming fallback.
3. **Tone/voice review** — confirm the copy matches the brand kit voice (Steady/Forgiving/Honest); the `{{motivations}}`/`{{motivation}}` echo must never be turned into generated religious or moralizing language (brand kit §1.2).
4. **Turkish copy** — TR strings in `helplines.json`/notices are first-pass; the L10n pass (warm-informal *sen*) refines them.

## Categories & tokens (for the eventual consuming code)
- Categories match `HabitCategory`: `vape, porn, alcohol, weed, doomscroll, custom`.
- Tokens the UI must substitute: `{{motivations}}` (panic, verbatim list), `{{motivation}}` (slip, single word), `{{bestStreak}}`, `{{momentum}}`.
- `dialString` → `tel:` link. TR entries are `domesticOnly: true` (short codes don't work with +90).
