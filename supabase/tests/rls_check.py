#!/usr/bin/env python3
"""
Permission checks for the LOCAL Supabase database.

Logs in as the seed.sql test users and tries things the app might do -
reading, adding, editing, deleting - checking each one is allowed or blocked
as expected. The main promise being checked: one family can never see or
change another family's data.

Run from the repo root, with the local database running (`supabase start`):
    python3 supabase/tests/rls_check.py

Exits with status 1 if any check fails. Anything it creates is tidied up at
the end, so it can be re-run any number of times.
"""
import json
import subprocess
import sys
import time
import urllib.error
import urllib.request

FAMILY_A = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"  # Test Family: Parent + Ella
FAMILY_B = "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"  # Other Family: Stranger
PASSWORD = "password123"
RUN = str(int(time.time()))  # makes names unique per run, e.g. "Scouts 1759152000"


def local_config():
    out = subprocess.run(["supabase", "status", "-o", "json"],
                         capture_output=True, text=True).stdout
    try:
        status = json.loads(out[out.index("{"):])
    except ValueError:
        sys.exit("Couldn't read `supabase status`. Is the local database running? Try `supabase start`.")
    url = status["API_URL"]
    # Safety: never run against anything but the local database
    if not url.startswith(("http://127.0.0.1", "http://localhost")):
        sys.exit(f"Refusing to run: {url} is not the local database.")
    return url, status["PUBLISHABLE_KEY"]


API, KEY = local_config()


def call(method, path, token=None, body=None):
    """Make one API request. Returns (HTTP status, parsed JSON response)."""
    headers = {"apikey": KEY, "Content-Type": "application/json", "Prefer": "return=representation"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(API + path, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req) as resp:
            status, raw = resp.status, resp.read()
    except urllib.error.HTTPError as err:
        status, raw = err.code, err.read()
    return status, (json.loads(raw) if raw else None)


def login(email):
    status, body = call("POST", "/auth/v1/token?grant_type=password",
                        body={"email": email, "password": PASSWORD})
    if status != 200:
        sys.exit(f"Couldn't log in as {email} ({status}). Has seed.sql run? Try `supabase db reset`.")
    return body["access_token"]


results = []


def check(label, got_status, expected_status, ok=True):
    passed = got_status == expected_status and ok
    results.append(passed)
    print(f"{'PASS' if passed else 'FAIL'}  {label}  (HTTP {got_status}, expected {expected_status})")


def titles(rows):
    return {r["title"] for r in rows or []}


def names(rows):
    return {r["name"] for r in rows or []}


parent = login("parent@example.com")
stranger = login("stranger@example.com")

# --- Reading: each family sees only its own ---------------------------------
print("\nReading")
s, rows = call("GET", "/rest/v1/events?select=title,event_members(members(display_name))", parent)
check("Parent sees own events, not Other Family's", s, 200,
      {"Swimming", "Bins out"} <= titles(rows) and "Football" not in titles(rows))
bins = next((r for r in rows or [] if r["title"] == "Bins out"), None)
check("'Bins out' has nobody attached (= whole family)", s, 200, bins is not None and bins["event_members"] == [])

s, rows = call("GET", "/rest/v1/events?select=title", stranger)
check("Stranger sees only Other Family's events", s, 200, titles(rows) == {"Football"})

s, rows = call("GET", "/rest/v1/members?select=display_name", parent)
check("Parent sees own family members, including child", s, 200,
      {r["display_name"] for r in rows or []} == {"Parent", "Ella"})

s, rows = call("GET", "/rest/v1/categories?select=name", stranger)
check("Stranger can't see Test Family's categories", s, 200, "Hurling" not in names(rows))

s, _ = call("GET", "/rest/v1/events?select=title")
check("Not logged in: can't read events", s, 401)

# --- Writing that should work -----------------------------------------------
print("\nWriting (should be allowed)")
s, rows = call("POST", "/rest/v1/categories", parent, {"family_id": FAMILY_A, "name": f"Scouts {RUN}", "emoji": "⛺"})
check("Parent adds own family category, with an emoji", s, 201)
category_id = rows[0]["id"] if s == 201 else None

s, rows = call("POST", "/rest/v1/events", parent, {
    "family_id": FAMILY_A, "title": f"Gala {RUN}", "category_id": category_id, "location": "Leisure Centre",
    "starts_at": "2026-10-03T09:00:00Z", "ends_at": "2026-10-03T12:00:00Z"})
check("Parent adds event to own family, with a location", s, 201)
event = rows[0] if s == 201 else {}

s, rows = call("GET", "/rest/v1/members?select=id&display_name=eq.Ella", parent)
ella_id = rows[0]["id"]
s, _ = call("POST", "/rest/v1/event_members", parent, {"event_id": event.get("id"), "member_id": ella_id})
check("Parent puts Ella on the event", s, 201)

s, rows = call("PATCH", f"/rest/v1/events?id=eq.{event.get('id')}", parent, {"title": f"Swimming gala {RUN}"})
check("Parent edits event; updated_at changes", s, 200,
      bool(rows) and rows[0]["updated_at"] != event.get("updated_at"))

s, rows = call("POST", "/rest/v1/events", parent, {
    "family_id": FAMILY_A, "title": f"Recycling out {RUN}", "starts_at": "2026-10-01T05:00:00Z"})
check("Parent adds event with no end time", s, 201, bool(rows) and rows[0]["ends_at"] is None)
no_end_event_id = rows[0]["id"] if s == 201 else None

s, rows = call("POST", "/rest/v1/categories", stranger, {"family_id": FAMILY_B, "name": f"Rugby {RUN}"})
check("Stranger adds own family category", s, 201)
other_category_id = rows[0]["id"] if s == 201 else None

# --- Writing that should be blocked -----------------------------------------
print("\nWriting (should be blocked)")
s, _ = call("POST", "/rest/v1/events", parent, {
    "family_id": FAMILY_B, "title": "Sneaky", "starts_at": "2026-10-03T09:00:00Z"})
check("Parent can't add event to Other Family", s, 403)

s, rows = call("GET", "/rest/v1/members?select=id&display_name=eq.Stranger", stranger)
stranger_member_id = rows[0]["id"]
s, _ = call("POST", "/rest/v1/event_members", parent, {"event_id": event.get("id"), "member_id": stranger_member_id})
check("Parent can't put Stranger on own event", s, 403)

s, _ = call("POST", "/rest/v1/events", parent, {
    "family_id": FAMILY_A, "title": "Rugby", "category_id": other_category_id, "starts_at": "2026-10-03T10:00:00Z"})
check("Parent can't use Other Family's category", s, 403)

s, rows = call("PATCH", f"/rest/v1/categories?id=eq.{other_category_id}", parent, {"name": "Hacked"})
check("Parent can't rename Other Family's category (0 rows changed)", s, 200, rows == [])

s, rows = call("DELETE", f"/rest/v1/events?id=eq.{event.get('id')}", stranger)
check("Stranger can't delete Parent's event (0 rows deleted)", s, 200, rows == [])

s, _ = call("POST", "/rest/v1/events", parent, {
    "family_id": FAMILY_A, "title": "Backwards",
    "starts_at": "2026-10-03T10:00:00Z", "ends_at": "2026-10-03T09:00:00Z"})
check("Event can't end before it starts", s, 400)

s, _ = call("POST", "/rest/v1/events", parent, {
    "family_id": FAMILY_A, "title": "Birthday", "repeat": "FREQ=YEARLY", "starts_at": "2026-10-03T10:00:00Z"})
check("Repeat must be daily/weekly/monthly", s, 400)

s, _ = call("POST", "/rest/v1/categories", parent, {"family_id": FAMILY_A, "name": "hurling"})
check("No duplicate category names (case-insensitive)", s, 409)

s, _ = call("POST", "/rest/v1/events", parent, {
    "family_id": FAMILY_A, "title": "Blank place", "location": "  ", "starts_at": "2026-10-03T10:00:00Z"})
check("Location can't be blank (leave it empty instead)", s, 400)

# --- Tidy up what this run created ------------------------------------------
call("DELETE", f"/rest/v1/events?id=eq.{event.get('id')}", parent)
call("DELETE", f"/rest/v1/events?id=eq.{no_end_event_id}", parent)
call("DELETE", f"/rest/v1/categories?id=eq.{category_id}", parent)
call("DELETE", f"/rest/v1/categories?id=eq.{other_category_id}", stranger)

passed = sum(results)
print(f"\n{passed}/{len(results)} checks passed")
sys.exit(0 if passed == len(results) else 1)
