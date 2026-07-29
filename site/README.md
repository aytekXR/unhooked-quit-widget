# `site/` — what gets served at `ballast.beyondkaira.com`

Static files, no build step, no JavaScript. Deploy by copying this directory to
the origin's web root. The runbook is **`docs/public-site-deploy.md`** — it holds
the nginx server block, the certbot invocation, and the verification step.

| File | Purpose | Owner |
|---|---|---|
| `index.html` | The landing page (`/`) — implements `redesign/marketing-strategy.md` §5 | agent-authored, **founder copy pass owed** |
| `beta.html` | The beta guide (`/beta`) — **this is the link you share with testers** | agent-authored, **founder copy pass owed** |
| `robots.txt` | Blocks crawlers until name clearance | agent-authored |
| `terms.html` | Terms of Use (`/terms`) | **NOT IN THIS REPO — counsel-owned** |
| `privacy.html` | Privacy Policy (`/privacy`) | **NOT IN THIS REPO — counsel-owned** |

## The two files that are deliberately absent

`terms.html` and `privacy.html` are **not here and must not be written by an
agent.** `paywallCopy.json`'s own `_meta.legalNote` marks those destinations
legal-owned, and the app links to them as real, tappable URLs that Apple's
Schedule 2 requires to work. Place counsel's text at `/var/www/ballast/terms.html`
and `/var/www/ballast/privacy.html` on the server.

Two content requirements come from this repo rather than from counsel, and both
are easy to miss:

- The privacy policy must carry the **sensitive-class habit-category
  disclosure** (GDPR / Washington MHMD). `docs/app-privacy-label.md` states what
  is collected and why, and the policy has to match the App Privacy label
  exactly — a mismatch between the two is itself a review finding.
- Apple's auto-renew boilerplate terminology drifts. Check the current wording in
  App Store Connect before publishing ("Apple Account", not "Apple ID").

## Constraints that shaped these pages

**No JavaScript, anywhere.** The origin serves a strict policy —
`default-src 'none'; style-src 'self' 'unsafe-inline'; img-src 'self'` — which
blocks all script, all webfonts, and every external request. The pages are static
by construction, so the policy costs nothing and is free evidence for the privacy
claims the app itself makes.

**Styles are inline in each page, not shared.** The nginx block serves *explicit*
locations and returns a real 404 for everything else — deliberately, because a
catch-all is what made the old apex return HTTP 200 for pages that did not exist.
A shared `/style.css` that nobody added to the config would therefore 404 and
render both pages unstyled. Duplicating ~180 lines of CSS is the cheaper failure.

**Palette is `docs/design/tokens-v2.md` verbatim**, so the contrast ratios
verified there hold here too. Dark is the default because the audience visits at
night; light is supported via `prefers-color-scheme`.

**System font stack.** The brand direction asks for Inter Display, but a webfont
is impossible under the CSP and `brandkit/branding-assets/BRAND-GUIDELINES.md` §4
says "SF Pro (system) everywhere; no custom fonts" — so the system stack agrees
with the app rather than compromising with the marketing spec.

## Copy status — a founder pass is owed

The words are drafted from already-approved sources, not invented: the hero,
section headings and FAQ come from `redesign/marketing-strategy.md` §5 verbatim
where it drafts them, the taglines from §3, and `beta.html` from
`docs/testflight-beta-kit.md` §2–§4. Three deviations were made deliberately and
each is the founder's to overrule:

1. **No newsletter field.** §5's Section 8 asks for one. A form needs script and a
   POST target, both of which the CSP forbids, and there is no list to collect
   into. Dropped rather than faked.
2. **No product screenshots.** §5 asks for real captures. The lock-screen widget is
   drawn in CSS instead — a stale screenshot makes a false claim about the product
   the day the UI moves, and the redesign is still landing waves.
3. **The privacy FAQ answer is hedged for RevenueCat.** §5 drafts "None, unless you
   opt in." That was true when the transport was dormant; RevenueCat is live now
   and `docs/app-privacy-label.md` declares a Purchases › Purchase History row. The
   answer now says so, because the page must match the label.

## Verify a deploy

```bash
scripts/verify_public_site.sh
```

It reads response **bodies**, not just status codes — the old apex returned HTTP
200 with a 16-byte placeholder for every path, so a status-code sweep called those
legal links healthy while a reviewer met a blank page.

## Before launch

- [ ] Founder copy pass over `index.html` and `beta.html`.
- [ ] Counsel's `terms.html` + `privacy.html` placed on the server.
- [ ] **On name clearance:** delete `robots.txt` and the `noindex` meta tag from
      both pages. Forgetting this ships an invisible launch site.
