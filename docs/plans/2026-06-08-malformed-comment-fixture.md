# Malformed Comment Fixture

## Status: Completed

## Context

`RubyImpJSON` preserves a historical JSON parser that accepts JavaScript-style
comments. The existing tests cover valid comments and several malformed comment
forms, but the fixture corpus did not explicitly preserve an unterminated block
comment rejection case.

## Objectives

- Preserve the current parser behavior for unterminated block comments.
- Add the malformed input to the fixture corpus instead of changing parser
  behavior.
- Make archive metadata checks require the fixture and its documentation.
- Keep the update in the pure Ruby `make check` path.

## Work Completed

- Added `tests/fixtures/fail29.json` for an unterminated block comment.
- Extended archive metadata checks to require the fixture.
- Documented the fixture in ARCHIVE_STATUS, README, VISION, and CHANGES.

## Verification

- `ruby scripts/check_archive_metadata.rb`
- `env JSON=pure MAKE=make rake do_test_pure`
- `make check`
- `make verify`
- `git diff --check`

## Follow-Up Candidates

- Review the remaining malformed JSON fixtures for duplicate or missing parser
  boundary cases.
- Add native-extension parity coverage if the archive is revived for active
  compatibility work.
