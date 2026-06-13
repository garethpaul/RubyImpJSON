# Local JSON Exact Path

## Status: Planned

## Context

WEBrick dispatches a servlet mounted at `/json` for descendant paths as well as
the mount point. The archived demo therefore returns its JSON payload and
success headers for unintended routes such as `/json/extra`.

## Priority

The local-only example documents one JSON endpoint. Keeping that route exact
reduces accidental surface area and makes the executable server contract match
its documentation without changing the archived JSON payload.

## Objectives

- Serve the demo payload only when the request path is exactly `/json`.
- Return a standard not-found response for descendant paths.
- Preserve query strings on the exact `/json` path.
- Avoid generating or incrementing the demo payload for rejected descendants.
- Add isolated loopback coverage and mutation-sensitive archive contracts.

## Implementation Units

### U1. Characterize exact and descendant routes

**Goal:** Prove the documented route succeeds while a mounted descendant does
not receive the JSON payload.

**Files:** `tests/test_server.rb`

**Approach:** Extend the existing isolated WEBrick subprocess test with real
loopback requests to `/json?source=test` and `/json/extra`.

**Test scenarios:**

- `/json?source=test` returns the existing 200 JSON response and headers.
- `/json/extra` returns 404 and does not carry the JSON content type.

**Verification:** The descendant assertion fails against the current prefix
mount behavior.

### U2. Reject descendant paths before payload generation

**Goal:** Constrain the servlet to its documented request path.

**Dependencies:** U1

**Files:** `tools/server.rb`, `tests/test_server.rb`

**Approach:** Guard `do_GET` using WEBrick's parsed request path and raise its
standard not-found response before constructing the payload or response
headers. Query parameters remain outside the parsed path comparison.

**Patterns to follow:** Preserve loopback binding and existing JSON response
headers for the valid route.

**Verification:** The isolated server test proves both routes and payload
behavior without external networking.

### U3. Synchronize archive evidence

**Goal:** Keep the archive checker and maintenance docs aligned with the exact
route boundary.

**Dependencies:** U1, U2

**Files:** `README.md`, `VISION.md`, `CHANGES.md`,
`scripts/check_archive_metadata.rb`,
`docs/plans/2026-06-13-local-json-exact-path.md`

**Approach:** Protect the exact-path guard, descendant regression, completed
plan, and documentation through the canonical archive contract.

**Verification:** Focused hostile mutations and `make check` pass.

## Scope Boundary

This change does not add authentication, HTTPS, CORS, production deployment
support, or new endpoints, and it does not alter the archived JSON gem payload.
