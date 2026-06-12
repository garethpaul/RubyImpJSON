# Local Server Loopback

Status: Completed

## Context

The historical WEBrick example printed a host-based `http://` URL. This is an
archive-only local demo, not a production service, so the plaintext endpoint
should stay constrained to loopback and documented as local-only HTTP.

## Changes

- Bound the example WEBrick server to `127.0.0.1`.
- Changed the printed URL to `http://127.0.0.1:<port>`.
- Made the helper loadable without starting its process and added a regression
  test for both configured and actual listening socket addresses.
- Documented that Prototype `parseQuery` and Java `parseObject` references are
  historical parser/prototype names, not Parse SDK/backend integrations.
- Extended archive metadata checks so the local-only server boundary stays
  visible.

## Verification

- `make check`
- `git diff --check`
