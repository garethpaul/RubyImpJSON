# Repository-Relative Server Load Path

## Status: Planned

## Context

`tools/server.rb` adds `ext` and `lib` relative to the caller's working
directory. An absolute invocation from outside the checkout therefore loads the
system JSON gem instead of this archived source tree.

## Requirements

- Resolve the archived `lib` and `ext` directories relative to the server
  script, independent of caller working directory.
- Keep the pure-Ruby archive variant selectable through the existing `JSON`
  environment contract.
- Prove an external-directory absolute load uses archived JSON 1.7.5 rather
  than the system gem.
- Preserve loopback binding, exact `/json` routing, response headers, payload,
  port validation, and Ruby 2.7 compatibility.
- Protect the source, regression, documentation, and completed plan with
  mutation-sensitive checks.

## Implementation Units

- Update `tools/server.rb` to prepend repository-derived absolute load paths.
- Extend `tests/test_server.rb` with an external-directory subprocess load.
- Extend `scripts/check_archive_metadata.rb` and maintenance docs with the
  repository-relative server contract.

## Verification

- focused server tests
- repository and external-directory `make check`
- digest-pinned read-only network-isolated Ruby 2.7 gate when cached
- hostile load-path, external-cwd, version, documentation, and plan mutations
- exact diff, generated-artifact, secret, and conflict-marker audits

## Scope Boundaries

- Do not change the archived JSON implementation, gem metadata, HTTP payload,
  network exposure, or production suitability.
- Do not merge or close stacked pull requests without explicit authorization.
