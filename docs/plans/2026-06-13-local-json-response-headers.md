# Local JSON Response Headers

## Status: Completed

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

## Work Completed

- Declared the local JSON response as UTF-8.
- Added no-store cache policy and MIME-sniffing protection.
- Extended the real loopback request test to require all three exact headers.
- Added fail-closed source, executable-test, documentation, and plan contracts.
- Updated README, security, vision, changes, and archive-status documentation.

## Verification

- `ruby tests/test_server.rb`
- `ruby scripts/check_archive_metadata.rb`
- `make check`
- Digest-pinned, read-only, network-isolated Ruby 2.7 archive gate
- Six focused charset, cache, nosniff, test, documentation, and plan mutations
- Ruby syntax, secret, artifact, and `git diff --check` audits

The isolated server test passed against a real loopback request. Full
`make check` passed 64 archive tests with 2,014 assertions and all three
temporary gem package builds; the exact digest-pinned Ruby 2.7 container gate
also passed with a read-only checkout and disabled networking. All six focused
mutations were rejected by the archive metadata checker.

## Scope Boundary

This remains a plaintext IPv4-loopback archive demo. The change does not make
the server production-ready or alter the vulnerable historical gem snapshot.
