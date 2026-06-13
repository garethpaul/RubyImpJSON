# Local JSON Response Headers

## Status: In Progress

## Context

The archived loopback WEBrick demo serves valid JSON with a generic
`application/json` content type, but does not declare UTF-8 for its archived
Unicode payload, prevent caching, or disable MIME sniffing. The endpoint is
local-only, yet its executable contract should make browser handling explicit.

## Priority

The response includes non-ASCII names and symbols and is intended for direct
browser/demo use. Explicit, deterministic headers improve interoperability and
avoid cached or reinterpreted responses without changing the historical body.

## Objectives

- Serve `/json` as `application/json; charset=utf-8`.
- Add `Cache-Control: no-store`.
- Add `X-Content-Type-Options: nosniff`.
- Extend the isolated loopback HTTP test to require exact response headers.
- Add fail-closed archive metadata contracts and hostile mutations.
- Preserve loopback binding, status, timestamp, counter, and Unicode payload.

## Planned Verification

- `ruby tests/test_server.rb`
- `ruby scripts/check_archive_metadata.rb`
- `make check`
- Digest-pinned, read-only, network-isolated Ruby 2.7 archive gate
- Focused charset, cache, nosniff, test, documentation, and plan mutations
- Ruby syntax, secret, artifact, and `git diff --check` audits

## Scope Boundary

This remains a plaintext IPv4-loopback archive demo. The change does not make
the server production-ready or alter the vulnerable historical gem snapshot.
