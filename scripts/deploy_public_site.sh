#!/usr/bin/env bash
# Deploy ballast.beyondkaira.com end to end, from this repo, in one command.
#
# WHY THIS EXISTS
# ---------------
# `docs/public-site-deploy.md` is correct and complete, and it is also six manual
# steps across two machines: paste an nginx block, symlink it, test it, run
# certbot, rsync the files, verify. Six steps is five chances to do one out of
# order — and the failure modes are quiet. Forget the symlink and nginx serves
# nothing. Run certbot before `nginx -t` passes and the ACME challenge 404s.
# rsync a new page without adding its `location` and the file is invisible.
#
# So this does all of it, in the right order, idempotently. The runbook stays the
# explanation; this is the execution.
#
# WHAT IT NEEDS FROM YOU
# ----------------------
# SSH access to the origin as root (or a sudoer). No agent has it — this was
# tested, not assumed: `ssh root@161.97.172.146` from the build machine returns
# `Permission denied (publickey,password)` for every user and key present. That
# is the whole reason this step is yours.
#
# SAFETY
# ------
# DRY-RUN BY DEFAULT, like every other script in this directory. It prints the
# exact remote commands and the rsync manifest, and changes nothing until --apply.
# `rsync --delete-after` is genuinely destructive to /var/www/ballast, so the dry
# run shows the deletion list too.
#
# Usage:
#   scripts/deploy_public_site.sh --selftest      # prove it serves, locally, no root
#   scripts/deploy_public_site.sh                 # show the plan, change nothing
#   scripts/deploy_public_site.sh --apply         # do it
#   scripts/deploy_public_site.sh --apply --skip-certbot   # files only, cert exists
#
# START WITH --selftest. It stands the REAL server block up on :8443 over a
# throwaway cert and checks 13 things — every path serves, a nonsense path 404s,
# all three pages carry noindex, all four security headers are emitted. No root,
# no network, nothing touched. It found `http2 on;` before the origin ever did.
#
set -euo pipefail

HOST="${BALLAST_HOST:-ballast.beyondkaira.com}"
SSH_TARGET="${BALLAST_SSH:-root@161.97.172.146}"
WEBROOT="/var/www/ballast"
CERTBOT_EMAIL="${BALLAST_CERTBOT_EMAIL:-aytek@beyondkaira.com}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bold() { printf '\033[1m%s\033[0m\n' "$1"; }
step() { printf '\n\033[1m▶ %s\033[0m\n' "$1"; }
note() { printf '  %s\n' "$1"; }

APPLY=0
SKIP_CERTBOT=0
SELFTEST=0
for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=1 ;;
    --skip-certbot) SKIP_CERTBOT=1 ;;
    --selftest) SELFTEST=1 ;;
    -h|--help) sed -n '2,40p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

# ---------------------------------------------------------------- self-test
# Stand the REAL server block up locally, on high ports, over a throwaway cert,
# and prove the pages actually serve BEFORE anything touches the origin.
#
# This exists because the alternative is discovering a config or content problem
# on the one machine nobody can iterate on. It already earned itself once: the
# block carried `http2 on;` (nginx >= 1.25.1 syntax) for four sessions, which is
# an [emerg] unknown-directive on older nginx and would have failed `nginx -t` at
# step 1 of the operator's first deploy. Ubuntu LTS still ships 1.24.
#
# Needs nginx and openssl locally. Root is NOT needed — that is the point of the
# high ports.
if [ "$SELFTEST" = "1" ]; then
  command -v nginx >/dev/null || { echo "self-test needs nginx installed locally" >&2; exit 1; }
  W="$(mktemp -d)"; trap 'nginx -s quit -c "$W/n.conf" -p "$W" 2>/dev/null || true; rm -rf "$W"' EXIT
  mkdir -p "$W/www" "$W/logs"
  cp "$REPO_ROOT"/site/*.html "$REPO_ROOT"/site/robots.txt "$REPO_ROOT"/site/icon.png "$W/www/" 2>/dev/null || true
  rm -f "$W/www/README.md"
  openssl req -x509 -newkey rsa:2048 -nodes -keyout "$W/k.pem" -out "$W/c.pem" -days 1 \
    -subj "/CN=$HOST" -addext "subjectAltName=DNS:$HOST,DNS:localhost" 2>/dev/null
  {
    echo "pid $W/n.pid;"; echo "events { worker_connections 16; }"; echo "http {"
    echo "  include /etc/nginx/mime.types;"
    echo "  access_log $W/logs/a.log; error_log $W/logs/e.log;"
    echo "  client_body_temp_path $W/cbt; proxy_temp_path $W/pt;"
    echo "  fastcgi_temp_path $W/ft; uwsgi_temp_path $W/ut; scgi_temp_path $W/st;"
    sed -e "s|listen 443 ssl http2;|listen 8443 ssl http2;|" \
        -e "s|listen \[::\]:443 ssl http2;||" \
        -e "s|listen 80;|listen 8080;|" -e "s|listen \[::\]:80;||" \
        -e "s|/etc/letsencrypt/live/$HOST/fullchain.pem|$W/c.pem|" \
        -e "s|/etc/letsencrypt/live/$HOST/privkey.pem|$W/k.pem|" \
        -e "s|include             /etc/letsencrypt/options-ssl-nginx.conf;||" \
        -e "s|ssl_dhparam         /etc/letsencrypt/ssl-dhparams.pem;||" \
        -e "s|$WEBROOT|$W/www|g" -e "s|/var/www/certbot|$W/www|g" \
        "$REPO_ROOT/scripts/ballast-nginx.conf"
    echo "}"
  } > "$W/n.conf"

  bold "Self-test — the real block, served locally on :8443"
  nginx -t -c "$W/n.conf" -p "$W" 2>&1 | sed 's/^/  /'
  nginx -c "$W/n.conf" -p "$W"
  sleep 1
  fails=0
  # S61 — /terms and /privacy JOIN THIS LIST, and they are the two that matter most.
  # They were routed by the server block and linked by the paywall, the TestFlight
  # Test Information and this site's own footer, while no file existed behind either:
  # a deploy would have served 404 on exactly the two pages Apple requires to work.
  # The self-test could not see it because its check list was hand-written and they
  # were not on it. A gate that only checks the pages someone remembered is a gate
  # with the same blind spot as the person who wrote it.
  for spec in "/:200" "/beta:200" "/support:200" "/terms:200" "/privacy:200" "/robots.txt:200" "/icon.png:200" "/definitely-not-a-page:404"; do
    path="${spec%:*}"; want="${spec##*:}"
    got="$(curl -sk -o /dev/null -w '%{http_code}' --max-time 8 "https://localhost:8443$path" || echo 000)"
    if [ "$got" = "$want" ]; then note "PASS  $path -> $got"; else note "FAIL  $path -> $got (want $want)"; fails=$((fails+1)); fi
  done
  # The catch-all guard is the one that matters most: if a nonsense path ever
  # answers 200, every legal link is silently broken again (runbook §1).
  for p in / /beta /support /terms /privacy; do
    if curl -sk --max-time 8 "https://localhost:8443$p" | grep -qi 'name="robots"[^>]*noindex'; then
      note "PASS  $p carries noindex"
    else note "FAIL  $p is MISSING noindex"; fails=$((fails+1)); fi
  done
  for h in strict-transport-security x-content-type-options content-security-policy referrer-policy; do
    if curl -skI --max-time 8 https://localhost:8443/ | grep -qi "^$h:"; then note "PASS  header $h"
    else note "FAIL  header $h missing"; fails=$((fails+1)); fi
  done
  echo
  [ "$fails" = "0" ] && bold "self-test PASSED — the block and the pages serve correctly" \
                     || bold "self-test FAILED with $fails problem(s)"
  exit "$fails"
fi

run_remote() {
  # $1 = human label, $2 = the command
  note "ssh $SSH_TARGET '$2'"
  if [ "$APPLY" = "1" ]; then
    ssh -o BatchMode=yes -o ConnectTimeout=15 "$SSH_TARGET" "$2"
  fi
}

bold "Ballast public site deploy$([ "$APPLY" = "1" ] || echo '   [DRY RUN — nothing changes]')"
note "host    : $HOST"
note "origin  : $SSH_TARGET"
note "webroot : $WEBROOT"
note "source  : $REPO_ROOT/site/"

# --------------------------------------------------------------- 0. pre-flight
step "0. Pre-flight"

if [ ! -f "$REPO_ROOT/site/index.html" ]; then
  echo "  FAIL: $REPO_ROOT/site/index.html is missing — wrong directory?" >&2
  exit 1
fi

# The two counsel-owned pages are NOT in this repo by design. Deploying without
# them leaves /terms and /privacy returning a real 404, which is a rejection when
# a reviewer taps them from the paywall. Warn loudly; do not block, because
# deploying the rest is still progress and the beta page does not need them.
# S61 — the two legal pages now EXIST (`site/terms.html`, `site/privacy.html`), so
# the old "counsel owns them and no agent has written them" warning is retired. What
# replaces it is a SIGN-OFF gate, because the risk simply moved: it used to be a 404,
# and it is now unreviewed text on a subscription app's legal pages.
#
# Both were written by a build agent from facts already established in this repo —
# `docs/app-privacy-label.md` (code-derived from the closed `AnalyticsEvent` enum),
# `docs/payload-audit.md`, and `paywallCopy.json`'s auto-renewal sentence quoted
# verbatim — and the Terms page deliberately AUTHORS no licence: it points at Apple's
# standard EULA, which is the agreement that already applies when a developer supplies
# none. That keeps the drafting to disclosure rather than negotiation.
#
# It is still not counsel-reviewed, and an agent may not sign that off. So: the deploy
# prints this until the operator sets BALLAST_LEGAL_REVIEWED=1, which is a deliberate
# act rather than a remembered one.
MISSING_LEGAL=0
for f in terms.html privacy.html; do
  if [ ! -f "$REPO_ROOT/site/$f" ]; then
    MISSING_LEGAL=1
  fi
done
if [ "$MISSING_LEGAL" = "1" ]; then
  note ""
  note "⚠️  terms.html / privacy.html are MISSING from site/ — /terms and /privacy will"
  note "    404, and the paywall's two legal links are what Apple Schedule 2 requires"
  note "    to WORK. The beta page does not need them; SUBMISSION does."
elif [ "${BALLAST_LEGAL_REVIEWED:-0}" != "1" ]; then
  note ""
  note "⚠️  terms.html / privacy.html exist but are NOT MARKED REVIEWED."
  note "    S61 wrote both so the pages would stop 404-ing; every fact in them is"
  note "    derived from this repo, and the Terms page points at Apple's standard"
  note "    EULA rather than inventing one. Neither has been read by counsel."
  note "    Read them, amend or replace freely, then re-run with"
  note "    BALLAST_LEGAL_REVIEWED=1 to silence this. Deploying anyway is allowed —"
  note "    a working, accurate page beats a 404 — but the review is still owed."
fi

if ! ssh -o BatchMode=yes -o ConnectTimeout=10 "$SSH_TARGET" 'echo ok' >/dev/null 2>&1; then
  note ""
  note "⚠️  Cannot SSH to $SSH_TARGET with the keys on this machine."
  note "    Everything below is printed so you can run it from a machine that can,"
  note "    or paste the remote parts into a console session."
  [ "$APPLY" = "1" ] && { echo "  Refusing --apply without a working connection." >&2; exit 1; }
fi

# ------------------------------------------------------------- 1. server block
step "1. nginx server block"
note "Written from docs/public-site-deploy.md §2 — the SAME text, so the two cannot drift."
NGINX_CONF="$REPO_ROOT/scripts/ballast-nginx.conf"
if [ ! -f "$NGINX_CONF" ]; then
  echo "  FAIL: $NGINX_CONF missing (it ships beside this script)." >&2
  exit 1
fi
note "source: scripts/ballast-nginx.conf ($(wc -l < "$NGINX_CONF") lines)"
if [ "$APPLY" = "1" ]; then
  scp -o BatchMode=yes "$NGINX_CONF" "$SSH_TARGET:/etc/nginx/sites-available/$HOST"
else
  note "scp scripts/ballast-nginx.conf $SSH_TARGET:/etc/nginx/sites-available/$HOST"
fi

run_remote "webroots" "mkdir -p /var/www/certbot $WEBROOT"

# ── S61 — THE BOOTSTRAP THAT WAS MISSING, AND IT WOULD HAVE ABORTED RUN 1 ──────
# The old order was: install the full block -> `nginx -t && systemctl reload` ->
# certbot. Its comment was right that certbot's webroot plugin needs the :80 block
# live first. What it missed is that THE SAME FILE also contains the :443 block,
# which names a certificate certbot has not issued yet:
#
#   ssl_certificate /etc/letsencrypt/live/ballast.beyondkaira.com/fullchain.pem;
#
# so `nginx -t` fails before certbot ever runs. Reproduced locally against the real
# block with the cert absent:
#
#   [emerg] cannot load certificate "/etc/letsencrypt/live/ballast.beyondkaira.com/
#           fullchain.pem": BIO_new_file() failed
#
# and this script runs under `set -euo pipefail`, so run 1 dies at step 1 with the
# site still down. That is the classic certbot chicken-and-egg, and it was live in
# the operator's one command. Confirmed against the origin the same day: the served
# certificate is `CN=beyondkaira.com` with SANs for seven OTHER subdomains and not
# this one, so the lineage genuinely does not exist yet.
#
# THE FIX: serve a :80-ONLY block first so ACME can complete, then install the full
# block once the cert exists. The bootstrap conf is EXTRACTED from the real one at
# run time rather than kept as a second file, so the two cannot drift.
BOOTSTRAP_CONF="$(mktemp)"
awk '
  /^server[[:space:]]*\{/ { inblock = 1 }
  inblock {
    print
    depth += gsub(/\{/, "{")
    depth -= gsub(/\}/, "}")
    if (depth == 0) exit
  }
' "$NGINX_CONF" > "$BOOTSTRAP_CONF"
if ! grep -q "acme-challenge" "$BOOTSTRAP_CONF"; then
  echo "  FAIL: the extracted :80 bootstrap block has no ACME location — refusing to" >&2
  echo "        continue, because certbot could never complete the challenge." >&2
  exit 1
fi
if grep -q "ssl_certificate" "$BOOTSTRAP_CONF"; then
  echo "  FAIL: the extracted bootstrap block still references a certificate, which is" >&2
  echo "        the exact thing it exists to avoid. Check the server-block order in" >&2
  echo "        $NGINX_CONF (the :80 block must come first)." >&2
  exit 1
fi
note "bootstrap block: $(wc -l < "$BOOTSTRAP_CONF") lines, :80 only, ACME location present"

if [ "$APPLY" = "1" ]; then
  scp -o BatchMode=yes "$BOOTSTRAP_CONF" "$SSH_TARGET:/etc/nginx/sites-available/$HOST.bootstrap"
else
  note "scp <extracted :80 block> $SSH_TARGET:/etc/nginx/sites-available/$HOST.bootstrap"
fi

# ------------------------------------------------------------------ 2. certbot
step "2. TLS certificate (bootstrap -> issue -> full block)"
if [ "$SKIP_CERTBOT" = "1" ]; then
  note "skipped (--skip-certbot) — installing the full block directly"
  run_remote "symlink"  "ln -sfn /etc/nginx/sites-available/$HOST /etc/nginx/sites-enabled/$HOST"
  run_remote "config test + reload" "nginx -t && systemctl reload nginx"
else
  note "The gap today, measured rather than assumed: DNS resolves, but the served"
  note "certificate is CN=beyondkaira.com covering seven other subdomains and NOT"
  note "$HOST, so HTTPS fails the hostname check before nginx is consulted."
  note "One remote block, so it is correct whether or not the cert already exists."
  run_remote "bootstrap + issue + install" "set -e
    CERT=/etc/letsencrypt/live/$HOST/fullchain.pem
    if [ ! -f \"\$CERT\" ]; then
      echo '-> no certificate yet: serving the :80-only block so ACME can complete'
      ln -sfn /etc/nginx/sites-available/$HOST.bootstrap /etc/nginx/sites-enabled/$HOST
      nginx -t && systemctl reload nginx
      certbot certonly --webroot -w /var/www/certbot -d $HOST --non-interactive --agree-tos -m $CERTBOT_EMAIL
    else
      echo '-> certificate already present, skipping issuance'
    fi
    echo '-> installing the full block'
    ln -sfn /etc/nginx/sites-available/$HOST /etc/nginx/sites-enabled/$HOST
    rm -f /etc/nginx/sites-enabled/$HOST.bootstrap
    nginx -t && systemctl reload nginx"
  run_remote "renewal timer armed" "systemctl list-timers | grep -i certbot || echo 'NOTE: no certbot timer found — check auto-renew'"
fi

# -------------------------------------------------------------------- 3. files
step "3. Copy the pages"
note "README.md is documentation, not a page — excluded (it has no nginx location)."
RSYNC_FLAGS=(-av --delete-after --exclude README.md)
if [ "$APPLY" = "1" ]; then
  rsync "${RSYNC_FLAGS[@]}" "$REPO_ROOT/site/" "$SSH_TARGET:$WEBROOT/"
else
  note "rsync -av --delete-after --exclude README.md site/ $SSH_TARGET:$WEBROOT/"
  note ""
  note "would transfer:"
  rsync "${RSYNC_FLAGS[@]}" --dry-run "$REPO_ROOT/site/" "$SSH_TARGET:$WEBROOT/" 2>/dev/null \
    | sed 's/^/    /' || note "    (dry-run listing unavailable — no SSH from this machine)"
fi

# ------------------------------------------------------------------- 4. verify
step "4. Verify"
note "Reads response BODIES, not status codes — the apex proved a 200 can be a lie."
if [ "$APPLY" = "1" ]; then
  "$REPO_ROOT/scripts/verify_public_site.sh" "$HOST"
else
  note "scripts/verify_public_site.sh $HOST"
  note ""
  note "DRY RUN — nothing was changed. Re-run with --apply to execute this plan."
fi
