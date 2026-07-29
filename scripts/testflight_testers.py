#!/usr/bin/env python3
"""Manage the TestFlight tester ring: list it, create an external group, add people.

WHY THIS EXISTS
---------------
`testflight_distribute.py` gets BUILDS to a group. Nothing got PEOPLE into one, so
the last mile of a beta sitting was hand-work in App Store Connect — retyping names
and emails one at a time, with no record of who was invited.

THE CONSTRAINT THAT SHAPES THIS SCRIPT — and it is Apple's, not ours
--------------------------------------------------------------------
Apple's TestFlight page divides testers in two, and the division is not cosmetic:

  INTERNAL  up to 100, and every one of them must be a member of your team holding
            an App Store Connect role (Account Holder, Admin, App Manager, Developer
            or Marketing). Builds arrive with NO Beta App Review wait.
  EXTERNAL  up to 10,000, and they are "anyone with an email address" — no App Store
            Connect account needed. The cost is Beta App Review: "your builds are
            automatically sent for review once they're added to a group."

So an ordinary friend CANNOT go in an internal group. Putting them there means making
them a team member on the developer account, with a role that can see and change real
things. For a friends-and-family ring the external group is the correct vehicle, and
the one-time Beta App Review is the price.

**A group's `isInternalGroup` cannot be changed after creation.** Verified against
Apple's own `BetaGroupUpdateRequest.Data.Attributes` schema, which lists only `name`,
`publicLinkEnabled`, `publicLinkLimit`, `publicLinkLimitEnabled`, `feedbackEnabled`,
`iosBuildsAvailableForAppleSiliconMac` and `iosBuildsAvailableForAppleVision`. An
internal group can therefore never be converted — a second, external group is the
only route.

Every request shape below was verified against Apple's published schema JSON rather
than assumed:
  * `BetaTesterCreateRequest.Data.Attributes` -> email (REQUIRED), firstName, lastName
  * `BetaTesterCreateRequest.Data.Relationships` -> betaGroups, builds
  * `BetaGroupCreateRequest.Data.Attributes` -> name (REQUIRED), isInternalGroup,
    hasAccessToAllBuilds, feedbackEnabled, publicLink*
  * POST /v1/betaGroups/{id}/relationships/betaTesters -> 204, adds existing testers

SAFETY
------
Adding an external tester SENDS THEM AN EMAIL, immediately. So this script is
DRY-RUN BY DEFAULT: it prints the plan and changes nothing until you pass --apply.

Usage:
    # See what exists right now. Changes nothing.
    testflight_testers.py --list

    # Create the external ring (one-time). Prints the plan; --apply to execute.
    testflight_testers.py --create-external-group "Friends (external)" --apply

    # Add people. Dry-run first, then --apply.
    testflight_testers.py --group "Friends (external)" --roster friends.csv
    testflight_testers.py --group "Friends (external)" --roster friends.csv --apply

Roster format — CSV, header optional, extra columns ignored:
    email,firstName,lastName
    sam@example.com,Sam,Rivera
    dana@example.com,Dana,

Credentials: ASC_KEY_ID, ASC_ISSUER_ID, ASC_API_KEY_P8_BASE64 from the environment,
or --secrets-file secret.yml to read them from the operator's local mirror.
"""

from __future__ import annotations

import argparse
import base64
import csv
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

API = "https://api.appstoreconnect.apple.com/v1"

# Deliberately permissive: the authority on whether an address is real is Apple's own
# validation plus the invite actually arriving. This only catches typos like a missing
# "@" that would otherwise cost a round-trip to discover.
EMAIL_RE = re.compile(r"^[^@\s,;]+@[^@\s,;]+\.[^@\s,;]+$")

# Roles that Apple's TestFlight page lists as eligible to be an internal tester.
INTERNAL_ELIGIBLE_ROLES = {"ACCOUNT_HOLDER", "ADMIN", "APP_MANAGER", "DEVELOPER", "MARKETING"}


def log(msg: str = "") -> None:
    print(msg, flush=True)


def fail(msg: str) -> "NoReturn":  # type: ignore[valid-type]
    print(f"::error title=TestFlight testers::{msg}", flush=True)
    sys.exit(1)


# --------------------------------------------------------------------------- auth


def load_secrets_file(path: str) -> None:
    """Populate the three ASC vars from a secret.yml-shaped file, without printing them.

    The file is the operator's local mirror of the GitHub Actions secrets. Keys are
    found at whatever depth they sit, so the file's grouping can change freely.
    """
    try:
        import yaml
    except ImportError:
        fail("--secrets-file needs PyYAML: pip install pyyaml")
    try:
        with open(path) as fh:
            doc = yaml.safe_load(fh)
    except OSError as exc:
        fail(f"cannot read {path}: {exc}")

    found: dict[str, str] = {}

    def walk(node) -> None:
        if isinstance(node, dict):
            for key, value in node.items():
                if isinstance(value, (dict, list)):
                    walk(value)
                elif value is not None:
                    found[str(key)] = str(value)
        elif isinstance(node, list):
            for value in node:
                walk(value)

    walk(doc)
    for var in ("ASC_KEY_ID", "ASC_ISSUER_ID", "ASC_API_KEY_P8_BASE64"):
        if var in found and not os.environ.get(var):
            os.environ[var] = found[var]


def make_token() -> str:
    try:
        import jwt  # PyJWT
    except ImportError:
        fail("PyJWT is not installed — run: pip install pyjwt cryptography")

    for var in ("ASC_KEY_ID", "ASC_ISSUER_ID", "ASC_API_KEY_P8_BASE64"):
        if not os.environ.get(var):
            fail(
                f"{var} is empty. Export the three ASC vars, or pass "
                "--secrets-file secret.yml to read them from your local mirror."
            )
    try:
        private_key = base64.b64decode(os.environ["ASC_API_KEY_P8_BASE64"]).decode("utf-8")
    except Exception as exc:  # noqa: BLE001
        fail(f"ASC_API_KEY_P8_BASE64 is not valid base64: {exc}")

    now = int(time.time())
    return jwt.encode(
        # ASC rejects tokens with a lifetime over 20 minutes.
        {"iss": os.environ["ASC_ISSUER_ID"], "iat": now, "exp": now + 19 * 60, "aud": "appstoreconnect-v1"},
        private_key,
        algorithm="ES256",
        headers={"kid": os.environ["ASC_KEY_ID"], "typ": "JWT"},
    )


# ---------------------------------------------------------------------- transport


class Client:
    def __init__(self) -> None:
        self.token = make_token()

    def request(self, method: str, path: str, params=None, body=None, tolerate=()):
        url = f"{API}{path}"
        if params:
            # ASC uses bracketed filter keys; they must survive urlencode intact.
            url += "?" + urllib.parse.urlencode(params, safe="[]")
        data = json.dumps(body).encode() if body is not None else None
        req = urllib.request.Request(url, data=data, method=method)
        req.add_header("Authorization", f"Bearer {self.token}")
        if data:
            req.add_header("Content-Type", "application/json")
        try:
            with urllib.request.urlopen(req, timeout=60) as resp:
                raw = resp.read()
                return json.loads(raw) if raw else {}
        except urllib.error.HTTPError as exc:
            detail = exc.read().decode("utf-8", "replace")[:800]
            if exc.code in tolerate:
                return {"__status__": exc.code, "__detail__": detail}
            fail(f"{method} {path} -> HTTP {exc.code}\n{detail}")
        except urllib.error.URLError as exc:
            fail(f"{method} {path} -> network error: {exc}")

    def paged(self, path: str, params=None):
        """Follow ASC's cursor pagination so a roster over one page is never silently cut."""
        params = dict(params or {})
        params.setdefault("limit", 200)
        out = []
        url_path, url_params = path, params
        while True:
            payload = self.request("GET", url_path, url_params)
            out.extend(payload.get("data", []))
            nxt = payload.get("links", {}).get("next")
            if not nxt:
                return out
            parsed = urllib.parse.urlparse(nxt)
            url_path = parsed.path[len("/v1") :] if parsed.path.startswith("/v1") else parsed.path
            url_params = dict(urllib.parse.parse_qsl(parsed.query, keep_blank_values=True))


# ------------------------------------------------------------------------ domain


def resolve_app(api: Client, bundle_id: str) -> str:
    apps = api.request("GET", "/apps", {"filter[bundleId]": bundle_id, "limit": 10}).get("data", [])
    if not apps:
        fail(f"No App Store Connect app with bundleId '{bundle_id}'.")
    app = apps[0]
    log(f"  app     : {app['attributes'].get('name')!r} ({bundle_id}) id={app['id']}")
    return app["id"]


def all_groups(api: Client, app_id: str) -> list[dict]:
    return api.paged("/betaGroups", {"filter[app]": app_id})


def find_group(groups: list[dict], name: str) -> dict | None:
    for group in groups:
        if group["attributes"].get("name", "").strip().lower() == name.strip().lower():
            return group
    return None


def group_testers(api: Client, group_id: str) -> list[dict]:
    return api.paged(f"/betaGroups/{group_id}/betaTesters")


def app_testers(api: Client, app_id: str) -> list[dict]:
    return api.paged("/betaTesters", {"filter[apps]": app_id})


def describe_group(group: dict, testers: int | None = None) -> str:
    attrs = group["attributes"]
    kind = "internal" if attrs.get("isInternalGroup") else "EXTERNAL"
    bits = [
        f"'{attrs.get('name')}'",
        f"id={group['id']}",
        kind,
        f"allBuilds={'yes' if attrs.get('hasAccessToAllBuilds') else 'no'}",
        f"publicLink={'ON' if attrs.get('publicLinkEnabled') else 'off'}",
    ]
    if testers is not None:
        bits.append(f"testers={testers}")
    return "  ".join(bits)


# ------------------------------------------------------------------------ roster


def read_roster(path: str) -> list[dict]:
    """Parse a CSV roster into [{email, firstName, lastName}], order preserved.

    Tolerates a missing header, arbitrary column order, extra columns, and blank
    names — because the operator will paste this from a phone or a chat thread, not
    author it carefully.
    """
    try:
        with open(path, newline="", encoding="utf-8-sig") as fh:
            rows = [r for r in csv.reader(fh) if any((c or "").strip() for c in r)]
    except OSError as exc:
        fail(f"cannot read roster {path}: {exc}")
    if not rows:
        fail(f"roster {path} is empty.")

    def norm(cell: str) -> str:
        return re.sub(r"[^a-z]", "", (cell or "").lower())

    email_col, first_col, last_col = 0, 1, 2
    header = rows[0]
    # A header row is one whose cells NAME columns rather than contain data. The
    # reliable tell is that no cell parses as an email address.
    if not any(EMAIL_RE.match((c or "").strip()) for c in header):
        mapping = {norm(c): i for i, c in enumerate(header)}
        email_col = next((mapping[k] for k in ("email", "emailaddress", "mail", "email") if k in mapping), None)
        if email_col is None:
            fail(
                f"roster {path}: header row has no email column "
                f"(saw: {', '.join(repr(c) for c in header)}). "
                "Expected a column named 'email'."
            )
        first_col = next((mapping[k] for k in ("firstname", "first", "givenname", "name") if k in mapping), None)
        last_col = next((mapping[k] for k in ("lastname", "last", "surname", "familyname") if k in mapping), None)
        rows = rows[1:]
        if not rows:
            fail(f"roster {path} has a header but no rows.")

    def cell(row: list[str], idx: int | None) -> str:
        if idx is None or idx >= len(row):
            return ""
        return (row[idx] or "").strip()

    out: list[dict] = []
    seen: set[str] = set()
    problems: list[str] = []
    for lineno, row in enumerate(rows, start=1):
        email = cell(row, email_col)
        if not email:
            problems.append(f"line {lineno}: no email")
            continue
        if not EMAIL_RE.match(email):
            problems.append(f"line {lineno}: {email!r} does not look like an email address")
            continue
        key = email.lower()
        if key in seen:
            log(f"  note: {email} appears more than once in the roster — keeping the first")
            continue
        seen.add(key)
        entry = {"email": email, "firstName": cell(row, first_col), "lastName": cell(row, last_col)}
        # A one-word "name" column lands in firstName, which is what Apple shows.
        out.append(entry)

    if problems:
        # Refuse the whole roster rather than silently invite a subset: a typo'd
        # address is a friend who never gets the build and never knows why.
        fail(f"roster {path} has {len(problems)} bad row(s):\n    " + "\n    ".join(problems))
    return out


# ----------------------------------------------------------------------- actions


def create_external_group(api: Client, app_id: str, name: str, apply: bool) -> dict | None:
    log()
    log(f"PLAN: create EXTERNAL beta group {name!r} with access to all builds.")
    log("  Consequences, so none of them are a surprise:")
    log("    * External testers are invited by EMAIL and need no App Store Connect account.")
    log("    * Apple sends builds in an external group for BETA APP REVIEW automatically.")
    log("      Because hasAccessToAllBuilds is set, that applies to existing builds too.")
    log("    * Beta App Review needs the Beta App Description + feedback email filled in")
    log("      (App Store Connect > TestFlight > Test Information). docs/testflight-beta-kit.md")
    log("      §1.2/§1.3 carry paste-ready text for both.")
    log("    * The public link stays OFF. It is a separate, opt-in setting and this does")
    log("      not touch it — trademark clearance (gate G0) is still open.")
    if not apply:
        log("  DRY RUN — nothing created. Re-run with --apply to create it.")
        return None

    payload = api.request(
        "POST",
        "/betaGroups",
        body={
            "data": {
                "type": "betaGroups",
                "attributes": {
                    "name": name,
                    "isInternalGroup": False,
                    # Set at CREATE time on purpose: it is not in the update schema, so
                    # it can never be added later. Every build, past and future, reaches
                    # the group as a property of the group rather than because a CI step
                    # remembered to attach it.
                    "hasAccessToAllBuilds": True,
                    "feedbackEnabled": True,
                    # Explicit rather than defaulted, so the intent is on the record.
                    "publicLinkEnabled": False,
                },
                "relationships": {"app": {"data": {"type": "apps", "id": app_id}}},
            }
        },
    )
    group = payload.get("data", {})
    if not group.get("id"):
        fail(f"create returned no group id: {json.dumps(payload)[:400]}")
    log(f"  CREATED {describe_group(group)}")
    return group


def add_testers(
    api: Client, app_id: str, group: dict, roster: list[dict], apply: bool, force_internal: bool
) -> int:
    attrs = group["attributes"]
    internal = bool(attrs.get("isInternalGroup"))
    group_id = group["id"]

    if internal and not force_internal:
        fail(
            f"'{attrs.get('name')}' is an INTERNAL group, so it cannot take ordinary friends.\n"
            "    Apple's rule: internal testers must be members of your team holding an App\n"
            "    Store Connect role (Account Holder, Admin, App Manager, Developer, Marketing),\n"
            "    max 100. External testers are 'anyone with an email address', max 10,000.\n"
            "\n"
            "    A group's internal/external nature CANNOT be changed after creation — Apple's\n"
            "    BetaGroupUpdateRequest schema has no isInternalGroup field. So there are two\n"
            "    honest routes and no third:\n"
            "\n"
            "      (a) RECOMMENDED — make an external group and invite by email:\n"
            f"          {sys.argv[0]} --create-external-group 'Friends (external)' --apply\n"
            "          then re-run this with --group 'Friends (external)'.\n"
            "          Cost: one-time Beta App Review of the build. No account for testers.\n"
            "\n"
            "      (b) Add each person as a USER on the App Store Connect account first\n"
            "          (Users and Access > invite), then add them here. Cost: every friend\n"
            "          becomes a team member who can see and change real things on the\n"
            "          account. Appropriate for a co-founder, not for a friends ring.\n"
            "\n"
            "    --force-internal attempts it anyway. Unverified: whether the API rejects a\n"
            "    non-team email outright or accepts it and never delivers. Not tested here,\n"
            "    because testing it means emailing a real person from a live account."
        )

    existing_in_group = {
        (t["attributes"].get("email") or "").lower(): t for t in group_testers(api, group_id)
    }
    log(f"  group has {len(existing_in_group)} tester(s) already")

    # A tester can exist on the app but sit in a different group; that person is
    # LINKED, not created, so they are not invited a second time.
    on_app = {(t["attributes"].get("email") or "").lower(): t for t in app_testers(api, app_id)}

    to_link: list[dict] = []
    to_create: list[dict] = []
    already: list[dict] = []
    for person in roster:
        key = person["email"].lower()
        if key in existing_in_group:
            already.append(person)
        elif key in on_app:
            to_link.append({**person, "id": on_app[key]["id"]})
        else:
            to_create.append(person)

    def name_of(person: dict) -> str:
        full = " ".join(p for p in (person.get("firstName"), person.get("lastName")) if p)
        return full or "(no name)"

    log()
    log(f"PLAN for group '{attrs.get('name')}' ({'internal' if internal else 'EXTERNAL'}):")
    log(f"  {len(already):>3} already in the group — skipping")
    for person in already:
        log(f"        = {person['email']:<40} {name_of(person)}")
    log(f"  {len(to_link):>3} already a tester on this app — will be LINKED (no new invite email)")
    for person in to_link:
        log(f"        + {person['email']:<40} {name_of(person)}")
    log(f"  {len(to_create):>3} new — will be CREATED and INVITED BY EMAIL")
    for person in to_create:
        log(f"        * {person['email']:<40} {name_of(person)}")

    if not to_link and not to_create:
        log()
        log("Nothing to do — every person in the roster is already in the group.")
        return 0

    if not apply:
        log()
        log("DRY RUN — nobody was added and no email was sent.")
        log("Re-run with --apply to execute this plan.")
        return 0

    changed = 0
    if to_link:
        # One linkage call carries the whole batch; 204 No Content on success.
        api.request(
            "POST",
            f"/betaGroups/{group_id}/relationships/betaTesters",
            body={"data": [{"type": "betaTesters", "id": p["id"]} for p in to_link]},
        )
        log()
        for person in to_link:
            log(f"  linked  {person['email']}")
        changed += len(to_link)

    for person in to_create:
        attributes = {"email": person["email"]}
        # Send only what we have: an empty firstName/lastName is worse than absent,
        # because it shows as blank in the tester's own invite.
        if person.get("firstName"):
            attributes["firstName"] = person["firstName"]
        if person.get("lastName"):
            attributes["lastName"] = person["lastName"]
        result = api.request(
            "POST",
            "/betaTesters",
            body={
                "data": {
                    "type": "betaTesters",
                    "attributes": attributes,
                    "relationships": {"betaGroups": {"data": [{"type": "betaGroups", "id": group_id}]}},
                }
            },
            # 409 is "this tester already exists" — a benign race, not a failure. Keep
            # going so one duplicate cannot strand the rest of the roster.
            tolerate=(409,),
        )
        if result.get("__status__") == 409:
            log(f"  exists  {person['email']} (409 — already a tester; check the group in ASC)")
            continue
        log(f"  invited {person['email']}")
        changed += 1

    return changed


def cmd_list(api: Client, app_id: str) -> None:
    groups = all_groups(api, app_id)
    log()
    log(f"BETA GROUPS ({len(groups)}):")
    for group in groups:
        testers = group_testers(api, group["id"])
        log(f"  {describe_group(group, len(testers))}")
        for tester in testers:
            ta = tester["attributes"]
            full = " ".join(p for p in (ta.get("firstName"), ta.get("lastName")) if p) or "(no name)"
            log(f"        - {ta.get('email'):<40} {full:<24} state={ta.get('state')}")

    users = api.paged("/users")
    log()
    log(f"ACCOUNT USERS ({len(users)}) — the only people eligible for an INTERNAL group:")
    for user in users:
        ua = user["attributes"]
        roles = ua.get("roles") or []
        eligible = "eligible" if set(roles) & INTERNAL_ELIGIBLE_ROLES else "NOT eligible"
        full = " ".join(p for p in (ua.get("firstName"), ua.get("lastName")) if p) or "(no name)"
        log(f"  - {ua.get('username'):<40} {full:<24} {','.join(roles)} ({eligible})")


def main() -> None:
    ap = argparse.ArgumentParser(
        description="List the TestFlight tester ring, create an external group, add testers.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    ap.add_argument("--bundle-id", default="com.beyondkaira.ballast")
    ap.add_argument("--group", help="Group to add testers to.")
    ap.add_argument("--roster", help="CSV of email,firstName,lastName.")
    ap.add_argument("--create-external-group", metavar="NAME", help="Create an external group with all-builds access.")
    ap.add_argument("--list", action="store_true", help="Show groups, testers and account users. Read-only.")
    ap.add_argument("--apply", action="store_true", help="Actually make changes. Without it, this is a dry run.")
    ap.add_argument(
        "--force-internal",
        action="store_true",
        help="Attempt to add testers to an INTERNAL group anyway (see the note in --help output).",
    )
    ap.add_argument("--secrets-file", help="Read ASC_* from a secret.yml-shaped file.")
    args = ap.parse_args()

    if not (args.list or args.create_external_group or args.roster):
        ap.error("nothing to do — pass --list, --create-external-group, or --roster.")
    if args.roster and not args.group and not args.create_external_group:
        ap.error("--roster needs --group (or --create-external-group to make it first).")

    if args.secrets_file:
        load_secrets_file(args.secrets_file)

    # Parse the roster BEFORE touching the network: a typo should cost nothing.
    roster = read_roster(args.roster) if args.roster else []
    if roster:
        log(f"roster  : {len(roster)} person/people from {args.roster}")

    api = Client()
    log("TestFlight tester ring" + ("" if args.apply else "   [DRY RUN — no changes]"))
    app_id = resolve_app(api, args.bundle_id)

    if args.list:
        cmd_list(api, app_id)
        return

    groups = all_groups(api, app_id)
    target = None

    if args.create_external_group:
        clash = find_group(groups, args.create_external_group)
        if clash:
            kind = "internal" if clash["attributes"].get("isInternalGroup") else "external"
            fail(
                f"a group named '{args.create_external_group}' already exists and it is {kind}.\n"
                f"    {describe_group(clash)}\n"
                "    Pick a different name, or pass --group to use the existing one."
            )
        target = create_external_group(api, app_id, args.create_external_group, args.apply)
        if target is None and roster:
            log()
            log("Skipping the tester plan: the group does not exist yet in this dry run.")
            return

    if args.group:
        target = find_group(groups, args.group)
        if not target:
            available = ", ".join(sorted(g["attributes"].get("name", "?") for g in groups)) or "(none)"
            fail(f"no beta group named '{args.group}'. Groups that exist: {available}.")
        log(f"  {describe_group(target)}")

    if roster and target:
        changed = add_testers(api, app_id, target, roster, args.apply, args.force_internal)
        if args.apply:
            log()
            log(f"Done — {changed} tester(s) added to '{target['attributes'].get('name')}'.")
            log("They receive an email from TestFlight; they need the TestFlight app to redeem it.")


if __name__ == "__main__":
    main()
