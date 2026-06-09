# Gemspec Fixture Manifest Guard

## Status: Completed

## Context

`RubyImpJSON` keeps checked-in `json` and `json_pure` gemspec files as part of
the historical packaging snapshot. After adding the unterminated block comment
fixture, the pure-Ruby tests included it locally, but the gemspec package file
lists did not.

## Objectives

- Keep checked-in gemspec manifests aligned with the fixture corpus.
- Preserve malformed-input parser fixtures in archived package metadata.
- Add the guard to the existing `make check` archive verification path.

## Work Completed

- Added `tests/fixtures/fail29.json` to the `json` and `json_pure` gemspec
  file lists.
- Extended `scripts/check_archive_metadata.rb` to reject gemspec manifests that
  omit any checked-in JSON fixture.
- Documented the packaging manifest guard in README, ARCHIVE_STATUS, VISION,
  and CHANGES.

## Verification

- `ruby scripts/check_archive_metadata.rb`
- `env JSON=pure MAKE=make rake do_test_pure`
- `make check`
- `make verify`
- `git diff --check`

## Follow-Up Candidates

- Add a separate generated-gemspec regeneration note if this archive is revived
  for release work.
- Review non-fixture test files for similar package manifest drift.
