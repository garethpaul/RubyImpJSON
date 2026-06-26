# Local Server Bound-Port Advertisement

Status: Completed

## Goal

Make the optional loopback demo advertise the endpoint it actually bound,
including when callers request an operating-system-assigned port with `0`.

## Steps

1. Add a failing executable test for the port-`0` startup URL.
2. Move URL output until after WEBrick creates its loopback listener.
3. Bind the regression into archive metadata verification and hostile mutation.
4. Run focused, repository, external-directory, hosted, and review gates.

## Acceptance Criteria

- The advertised port equals `server.listeners.first.addr[1]`.
- A port-`0` server never advertises port `0`.
- Explicit ports, loopback-only binding, and error-only logging remain intact.
- All existing archive and package checks pass without generated artifacts.

## Verification Completed

- The pre-fix pinned Ruby 2.7 regression observed a nonzero listener port but
  failed because the startup log still advertised port `0`.
- The pinned Ruby 2.7 focused regression passed after startup output moved
  behind listener creation, and all eight server tests passed.
- hostile bound-port mutations were rejected for restoring caller-port
  interpolation, removing the listener lookup, and removing the executable
  regression.
- repository and external-directory `make check` passed in the digest-pinned
  Ruby 2.7 image.
- Hosted archive, Java, and CodeQL checks plus exact-head Codex review remain
  required before merge.
