# Gem Package Build Contract

## Status: Completed

## Context

The archive retains native, pure-Ruby, and Java gemspecs. Documentation records
manual builds, but the canonical `make check` gate does not prove that all
three specifications still produce inspectable packages or that their archive
entries remain path-safe.

## Priority

Packaging metadata is part of this historical snapshot. Validation should
catch broken gemspecs, platform drift, missing required payloads, unsafe archive
paths, and generated `.gem` artifacts without reviving publication support.

## Requirements

- R1. Build `json.gemspec`, `json_pure.gemspec`, and `json-java.gemspec` in a
  temporary directory using the current RubyGems executable.
- R2. Verify expected gem names, version `VERSION`, and Ruby/Java platforms.
- R3. Inspect each package and require representative declared library,
  fixture, and native-source payloads where applicable.
- R4. Reject absolute, parent-traversing, empty, duplicate, or non-normalized
  archive entries.
- R5. Leave no `.gem` artifacts in the repository.
- R6. Run the contract from `make build` and therefore `make check`.
- R7. Protect the script, Make wiring, docs, and completed plan with focused
  hostile mutations.

## Scope Boundaries

- Do not publish or install the archived gems.
- Do not change package names, version, dependencies, or historical source.
- Do not claim modern production support for JSON 1.7.5.

## Verification Plan

- `ruby scripts/test_gem_builds.rb`
- `make build`
- `make check`
- read-only network-isolated Ruby 2.7 container validation
- focused hostile gem-build contract mutations
- `git diff --check`

## Work Completed

- Added a RubyGems package harness that builds all three gemspecs into a
  temporary directory with the active Ruby executable.
- Verified package names, version, Ruby/Java platforms, representative declared
  payloads, unique normalized relative archive paths, and repository artifact
  cleanup.
- Added a source-manifest guard because RubyGems normalizes `./` aliases before
  archive inspection, ensuring the canonical gemspec paths remain enforceable.
- Removed redundant `./tests/...` aliases from the native and pure-Ruby
  `s.files` and `s.test_files` manifests while preserving every canonical test
  entry.
- Wired the harness into `make build` and therefore `make check`, then aligned
  archive, security, vision, changelog, README, and structural checker guidance.

## Verification

- `ruby scripts/test_gem_builds.rb` passed for all three packages.
- `make build` and `make check` passed locally.
- The full gate passed in the reviewed digest-pinned Ruby 2.7 container with a
  read-only checkout and no network access.
- 13 focused hostile gem-build mutations were rejected, covering missing
  gemspecs, name and platform drift, payload omissions, traversal and
  normalization checks (including dot and backslash entries), artifact cleanup,
  gemspec aliases, Make wiring, documentation, and completed-plan status.
- No `.gem` files were left in the repository and `git diff --check` passed.
