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
  for spec in "/:200" "/beta:200" "/support:200" "/robots.txt:200" "/icon.png:200" "/definitely-not-a-page:404"; do
    path="${spec%:*}"; want="${spec##*:}"
    got="$(curl -sk -o /dev/null -w '%{http_code}' --max-time 8 "https://localhost:8443$path" || echo 000)"
    if [ "$got" = "$want" ]; then note "PASS  $path -> $got"; else note "FAIL  $path -> $got (want $want)"; fails=$((fails+1)); fi
  done
  # The catch-all guard is the one that matters most: if a nonsense path ever
  # answers 200, every legal link is silently broken again (runbook §1).
  for p in / /beta /support; do
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
MISSING_LEGAL=0
for f in terms.html privacy.html; do
  if [ ! -f "$REPO_ROOT/site/$f" ]; then
    MISSING_LEGAL=1
  fi
done
if [ "$MISSING_LEGAL" = "1" ]; then
  note ""
  note "⚠️  terms.html / privacy.html are NOT in site/ — counsel owns them and no"
  note "    agent has written them. Without them /terms and /privacy 404, and the"
  note "    paywall's two legal links are what Apple Schedule 2 requires to WORK."
  note "    The beta page does not need them; SUBMISSION does. Place counsel's"
  note "    files in site/ (or directly in $WEBROOT) before you submit."
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
run_remote "symlink"  "ln -sfn /etc/nginx/sites-available/$HOST /etc/nginx/sites-enabled/$HOST"

# nginx -t BEFORE certbot is the ordering that matters: certbot's webroot plugin
# needs the :80 server block already serving /.well-known/acme-challenge/.
run_remote "config test + reload" "nginx -t && systemctl reload nginx"

# ------------------------------------------------------------------ 2. certbot
step "2. TLS certificate"
if [ "$SKIP_CERTBOT" = "1" ]; then
  note "skipped (--skip-certbot)"
else
  note "This is the actual gap today: DNS already resolves via a wildcard A record,"
  note "but the installed certificate does not cover $HOST, so every HTTPS request"
  note "fails the hostname check before nginx is consulted."
  run_remote "certbot" "certbot certonly --webroot -w /var/www/certbot -d $HOST --non-interactive --agree-tos -m $CERTBOT_EMAIL"
  run_remote "reload after issuance" "nginx -t && systemctl reload nginx"
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
