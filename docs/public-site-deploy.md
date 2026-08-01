# Public site — `ballast.beyondkaira.com`

| Field | Value |
|---|---|
| Status | **NOT DEPLOYED.** DNS resolves; TLS does not cover the host; nothing is served. Re-measured 2026-07-31 — `https://ballast.beyondkaira.com/` still fails the hostname check, `http://` 404s, and the apex still answers every path with the same 16-byte body. Unchanged from S56/S57. |
| Owner | **Operator.** Every step below needs shell access to the origin host, which no agent has — and that was tested rather than assumed: `ssh root@161.97.172.146` from the build machine returns `Permission denied (publickey,password)`. |
| Blocks | App Review (Apple Schedule 2 / guideline 3.1.2(c) — the paywall's Terms + Privacy links must work) **and the external TestFlight beta.** As of S59 that second one is no longer indirect: the Test Information written to the live account **declares `https://ballast.beyondkaira.com/privacy` as the beta privacy policy**, and everything else external distribution needs is already filled. **This deploy is the only remaining gate on submitting build 145 to Beta App Review** — see `operator-expected.md` §5 step 1. |
| Written | Session 56, from measurements taken the same session (recorded below, so they can be re-checked rather than trusted). |
| Updated | Session 57 — the pages now EXIST, in `site/`. Two of them (`/` and `/beta`) are agent-authored and ready to copy; `terms.html` and `privacy.html` remain counsel-owned and absent. Verification is now a script rather than a paste-along. |

> **What changed in S57, and why it matters for link-sharing.** The nginx block below
> serves explicit locations and 404s everything else — which is correct, but it meant
> **`/` had no `index.html` to serve, so the bare domain was a 404.** Anyone sent
> `ballast.beyondkaira.com` would have met a dead link. There are now two real pages:
> the landing page at `/`, and **`/beta` — the page you actually share with testers**
> (what the app is, how to redeem the invite, the close-free paywall warning, the
> twenty-minute pass, and the known oddities). Neither carries an invite or a build,
> so forwarding either one leaks nothing.

---

## 1. What was measured, and what it means

These are observations, not assumptions — re-run the commands to confirm before acting.

```bash
getent hosts ballast.beyondkaira.com
#   161.97.172.146   ballast.beyondkaira.com      ← resolves (same origin as the apex)

curl -sS -o /dev/null -w '%{http_code}\n' https://ballast.beyondkaira.com/terms
#   curl: (60) SSL: no alternative certificate subject name matches
#   target host name 'ballast.beyondkaira.com'    ← TLS does NOT cover the host

curl -sS https://beyondkaira.com/terms | head -c 40
#   beyondkaira.com                               ← 16 bytes, HTTP 200

curl -sS -o /dev/null -w '%{http_code}\n' https://beyondkaira.com/any-nonsense-path
#   200                                           ← the origin answers 200 to EVERYTHING
```

**Three conclusions:**

1. **DNS is already done** — a wildcard `A` record covers the subdomain. No registrar work needed.
2. **TLS is the actual gap.** The certificate installed on the origin does not list
   `ballast.beyondkaira.com`, so every HTTPS request to it fails before any nginx rule is
   consulted. This is the one thing that must change for the app's links to resolve at all.
3. **The apex is a catch-all, not a site.** `beyondkaira.com/terms` and `/privacy` were never
   real pages — they returned HTTP 200 with a 16-byte body reading `beyondkaira.com`, and so
   does every other path. **This matters more than it looks:** a link-checker, an uptime probe,
   or any 404-based sweep would have reported those legal links as healthy, while a reviewer
   tapping "Terms of Use" met a blank placeholder. The failure was invisible to automation and
   visible only to a human — which is exactly the kind Apple rejects for.

## 2. Server block

Origin runs **nginx** (confirmed from the `Server:` response header). Drop this at
`/etc/nginx/sites-available/ballast.beyondkaira.com` and symlink into `sites-enabled/`.

Serve the two legal pages as **static files with explicit locations** rather than relying on a
catch-all. That is deliberate: a catch-all is what produced the silent-200 problem on the apex,
and an explicit `location` plus a real `404` means a missing page fails **loudly** — which is the
failure mode you want, because it is the one monitoring can see.

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name ballast.beyondkaira.com;

    # ACME needs plain HTTP on this path; everything else goes to TLS.
    location /.well-known/acme-challenge/ { root /var/www/certbot; }
    location / { return 301 https://$host$request_uri; }
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    http2 on;
    server_name ballast.beyondkaira.com;

    ssl_certificate     /etc/letsencrypt/live/ballast.beyondkaira.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ballast.beyondkaira.com/privkey.pem;
    include             /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam         /etc/letsencrypt/ssl-dhparams.pem;

    root /var/www/ballast;
    index index.html;

    # No credentials, no forms, no third-party anything on these pages — so the
    # policy can be this strict, and a strict policy is free evidence for the
    # privacy claims the app itself makes.
    add_header X-Content-Type-Options    "nosniff"                  always;
    add_header X-Frame-Options           "DENY"                     always;
    add_header Referrer-Policy           "no-referrer"              always;
    add_header Strict-Transport-Security "max-age=31536000"         always;
    add_header Content-Security-Policy   "default-src 'none'; style-src 'self' 'unsafe-inline'; img-src 'self'" always;

    # EXPLICIT locations. Extensionless URLs, because the app links to
    # /terms and /privacy with no suffix (Shared/Sources/AppIdentifiers.swift).
    location = /terms   { try_files /terms.html   =404; }
    location = /privacy { try_files /privacy.html =404; }
    location = /        { try_files /index.html   =404; }

    # /beta is the page you share with testers. Extensionless to match the others,
    # and worth a redirect from the .html form because people will type it.
    location = /beta       { try_files /beta.html =404; }
    location = /beta.html  { return 301 https://$host/beta; }

    # /support is REQUIRED, not optional: App Store Connect will not accept a
    # listing without a reachable Support URL, and this is the page that field
    # points at. Same extensionless shape and the same .html redirect.
    location = /support      { try_files /support.html =404; }
    location = /support.html { return 301 https://$host/support; }

    # The link-preview image every page's og:image points at. Needed because
    # img-src is 'self' — an image served from anywhere else is blocked, and a
    # page whose og:image 404s previews worse than one with no tag at all.
    location = /icon.png   { try_files /icon.png =404; }

    # robots.txt must be reachable, and it is the ONLY file outside the set above
    # that is. It disallows crawling while trademark clearance (gate G0) is open.
    location = /robots.txt { try_files /robots.txt =404; }

    # Anything else is a REAL 404 — never a friendly 200. See §1 conclusion 3.
    location / { return 404; }
}
```

**Adding a page later means adding a `location` here.** That is the deliberate cost of
refusing a catch-all: a file copied to `/var/www/ballast` that has no `location` line is
invisible, which is a loud, findable failure. `scripts/verify_public_site.sh` checks
every path this block claims to serve, so a forgotten line shows up as a FAIL rather
than as a page nobody notices is missing.

## 3. Certificate

```bash
sudo mkdir -p /var/www/certbot /var/www/ballast
sudo ln -s /etc/nginx/sites-available/ballast.beyondkaira.com /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx        # must pass BEFORE certbot

sudo certbot certonly --webroot -w /var/www/certbot \
     -d ballast.beyondkaira.com \
     --non-interactive --agree-tos -m <your-email>

sudo nginx -t && sudo systemctl reload nginx
systemctl list-timers | grep -i certbot              # confirm auto-renew is armed
```

If the apex certificate is managed as a single bundle, the alternative is to add
`ballast.beyondkaira.com` to it (`-d beyondkaira.com -d ballast.beyondkaira.com --expand`).
Either is fine; a separate cert keeps the product host independent of the org site.

## 4. The pages themselves

### 4.1 The two that are ready — copy them up

They live in **`site/`** in this repo. Static HTML, no build step, no JavaScript.

```bash
# From a checkout of this repo, on your machine:
rsync -av --delete-after \
      --exclude README.md \
      site/ root@161.97.172.146:/var/www/ballast/

# Or without rsync:
scp site/index.html site/beta.html site/robots.txt root@161.97.172.146:/var/www/ballast/
```

`site/README.md` is documentation for you, not a page — exclude it (the nginx block has
no `location` for it, so serving it would just 404, but there is no reason to ship it).

| Path | File | What it is |
|---|---|---|
| `/` | `index.html` | The landing page. Implements `redesign/marketing-strategy.md` §5 |
| `/beta` | `beta.html` | **The link you share with testers** |
| `/support` | `support.html` | **Required for submission** — App Store Connect's Support URL field. Contact, the common questions, cancellation (Apple's own path, in words), and the honest no-account/new-phone answer |
| `/icon.png` | `icon.png` | The `og:image` every page points at, so a shared link previews with a title and a mark instead of blank |
| `/robots.txt` | `robots.txt` | Blocks crawlers until name clearance |

Both pages are self-contained: inline CSS, a system font stack, inline SVG, zero
JavaScript, zero external requests. That is not stylistic — the CSP in §2 blocks
external stylesheets, webfonts and all script, so anything else would silently fail in
production while looking fine locally. `scripts/site_copy_lint.py` enforces it, along
with the brand's tone rules.

### 4.2 The two that are NOT here, and must not be agent-written

**Terms of Use and Privacy Policy are counsel-owned, and no agent has written them.**
`paywallCopy.json`'s own `_meta.legalNote` says the destinations and the auto-renew
boilerplate are "operator/legal-owned". Place your counsel's text at
`/var/www/ballast/terms.html` and `/var/www/ballast/privacy.html`.

Two content requirements that come from this repo rather than from counsel, and are easy to miss:

- **The privacy policy must carry the sensitive-class habit-category disclosure** (GDPR / WA MHMD).
  `docs/app-privacy-label.md` states what is collected and why; the policy has to match the App
  Privacy label exactly, because a mismatch between the two is itself a review finding.
- **Apple's current boilerplate terminology drifts** — `paywallCopy.json` flags that the
  auto-renew disclosure should be checked against App Store Connect's current wording
  ("Apple Account", not "Apple ID") before submission.

### 4.3 A founder copy pass is owed on the two agent-authored pages

The words are drafted from already-approved sources rather than invented — the hero,
headings and FAQ from `redesign/marketing-strategy.md` §5 verbatim where it drafts them,
and `beta.html` from `docs/testflight-beta-kit.md` §2–§4. **Three deviations were made
deliberately, and each is yours to overrule** (they are listed with reasoning in
`site/README.md`): no newsletter field (a form needs script and a POST target, both
CSP-forbidden, and there is no list to collect into); no product screenshots (the
lock-screen widget is drawn in CSS, because a stale screenshot makes a false claim the
day the UI moves and the redesign is still landing waves); and the privacy FAQ answer is
hedged for RevenueCat, because §5's drafted "None, unless you opt in" predates the live
key and `app-privacy-label.md` now declares a Purchases › Purchase History row.

## 5. Verify — one command

```bash
scripts/verify_public_site.sh
```

It reads response **bodies**, not status codes, because the apex proved a 200 can be a
lie. **Sixteen** assertions across five groups: DNS and TLS; that each of `/`, `/beta`,
`/support`, `/terms` and `/privacy` returns 200 with a body over 200 bytes containing
expected words; that a nonsense path returns **404**; that `robots.txt` and all three
`noindex` tags are in place; and that the four security headers from §2 are actually
being sent.

> **The count was wrong before S60, and it is worth saying how.** This paragraph read
> "Nineteen assertions" from the day it was written, while the script has only ever had
> fourteen — the number was never counted, only asserted. It is sixteen now (`/support`
> added a page check and a `noindex` check), and it was counted:
> `scripts/verify_public_site.sh | grep -cE 'PASS|FAIL'`. Same rule as everywhere else in
> this repo — count, never quote.

Two of those assertions are the non-obvious ones, and they exist because of §1:

- **A body under 200 bytes is reported as the catch-all placeholder, not as a page.** The
  old apex answered every path with 16 bytes reading `beyondkaira.com`.
- **A nonsense path returning 200 is a FAIL.** If it ever does, the catch-all is back and
  every legal link is silently broken again.

Run against any host by passing it: `scripts/verify_public_site.sh staging.example.com`.

**Baseline, re-measured 2026-08-01 (nothing deployed yet):** `1 passed, 15 failed` — DNS
resolves, and everything else fails at TLS. That is the expected pre-deploy reading, so a
first run that looks like this means the script is working, not that you broke something.

## 6. Once it is live

- Re-run `scripts/verify_public_site.sh` — it must print **READY**.
- Tick the `operator-expected.md` §3 item.
- Nothing in the app needs changing — `AppIdentifiers.publicSiteHost` already points here.
- `docs/critical-path-post-uir.md` tracks this as a submission dependency; close it there too.
- **The TestFlight beta kit's "Terms and Privacy links 404" known-issue row stops being
  true** — it is marked in `docs/testflight-beta-kit.md` §4.2 as pending this deploy, and
  the tester-facing line in §3.1 step 5 says the links will 404. Both need retiring, or
  testers will be told to expect a failure that no longer happens.
- **On name clearance (gate G0), and not before:** delete `site/robots.txt` and the
  `noindex` meta tag from both pages, then redeploy. Leaving either in place ships a
  launch site that search engines cannot see — a quiet and expensive failure. The verify
  script asserts the gate is CLOSED, so it will start failing group 4 by design; flip
  those two assertions when you flip the gate.
