# Public site — `ballast.beyondkaira.com`

| Field | Value |
|---|---|
| Status | **NOT DEPLOYED.** DNS resolves; TLS does not cover the host; nothing is served. |
| Owner | **Operator.** Every step below needs shell access to the origin host, which no agent has. |
| Blocks | App Review (Apple Schedule 2 / guideline 3.1.2(c) — the paywall's Terms + Privacy links must work). |
| Written | Session 56, from measurements taken the same session (recorded below, so they can be re-checked rather than trusted). |

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

    # Anything else is a REAL 404 — never a friendly 200. See §1 conclusion 3.
    location / { return 404; }
}
```

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

**An agent must not write these, and none has.** Terms of Use and Privacy Policy are
counsel-owned — `paywallCopy.json`'s own `_meta.legalNote` says the destinations and the
auto-renew boilerplate are "operator/legal-owned". Place your counsel's text at
`/var/www/ballast/terms.html` and `/var/www/ballast/privacy.html`.

Two content requirements that come from this repo rather than from counsel, and are easy to miss:

- **The privacy policy must carry the sensitive-class habit-category disclosure** (GDPR / WA MHMD).
  `docs/app-privacy-label.md` states what is collected and why; the policy has to match the App
  Privacy label exactly, because a mismatch between the two is itself a review finding.
- **Apple's current boilerplate terminology drifts** — `paywallCopy.json` flags that the
  auto-renew disclosure should be checked against App Store Connect's current wording
  ("Apple Account", not "Apple ID") before submission.

## 5. Verify — the check that would have caught the old failure

Do not stop at a status code. **Fetch the body**, because the apex proved a 200 can be a lie:

```bash
for p in /terms /privacy; do
  printf '%-10s ' "$p"
  curl -sS -o /tmp/body -w 'HTTP %{http_code}  ' "https://ballast.beyondkaira.com$p" \
    && printf 'bytes=%s  ' "$(wc -c < /tmp/body)" \
    && grep -qiE 'terms|privacy|policy' /tmp/body && echo 'CONTENT OK' || echo 'SUSPECT — placeholder?'
done

# And prove a missing path FAILS, so the catch-all class cannot come back:
curl -sS -o /dev/null -w 'nonsense path -> HTTP %{http_code} (want 404)\n' \
  https://ballast.beyondkaira.com/definitely-not-a-page
```

A healthy result is: both pages HTTP 200 with a body of real size containing real words, **and**
a nonsense path returning 404. If the nonsense path returns 200, the catch-all is back and the
legal links are silently broken again.

## 6. Once it is live

- Re-run the check in §5 and tick the `operator-expected.md` §3 item.
- Nothing in the app needs changing — `AppIdentifiers.publicSiteHost` already points here.
- `docs/critical-path-post-uir.md` tracks this as a submission dependency; close it there too.
