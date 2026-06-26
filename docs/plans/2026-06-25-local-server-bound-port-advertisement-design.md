# Local Server Bound-Port Advertisement Design

Status: Completed

## Context

`create_server` accepts port `0`, which asks the operating system to allocate an
available loopback port. The function currently writes its startup URL before
WEBrick creates the listener, so callers receive `http://127.0.0.1:0` instead
of the endpoint that was actually bound. The same ordering can also emit a URL
before a later bind failure proves that no server exists there.

## Decision

Construct the WEBrick server first, read the bound port from its loopback
listener, and only then write the local-demo URL. Preserve the existing logger,
loopback binding, explicit-port behavior, and server return value.

## Verification

- Add an executable regression that creates a server on port `0` and requires
  the diagnostic URL to contain the listener's nonzero bound port.
- Keep the existing loopback, request, static-file, privacy, and archive tests.
- Add an archive metadata contract and hostile mutation for the regression.
- Run repository and external-directory `make check` in the pinned Ruby 2.7
  image, then require hosted Ruby/Java/CodeQL checks and exact-head Codex review.

## Risks

The listener must already exist when `HTTPServer.new` returns. Existing tests
already inspect `server.listeners.first` before `server.start`, so this is part
of the repository's current WEBrick boundary.

## Verification Completed

- The pinned Ruby 2.7 focused regression failed before the implementation and
  passed after the listener-derived advertisement was added.
- The full server suite passed, and repository/external `make check` evidence
  is recorded in the implementation plan.
