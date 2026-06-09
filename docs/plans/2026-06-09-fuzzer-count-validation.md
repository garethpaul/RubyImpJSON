# Fuzzer Count Validation

## Status: Completed

## Context

The archived `tools/fuzz.rb` example accepts a payload count argument. It used
`to_i`, which silently turns invalid input into `0` and lets the tool continue
with unclear behavior.

## Objectives

- Preserve the historical fuzzer behavior for valid positive counts.
- Reject non-integer count arguments before payload generation.
- Reject zero or negative counts before payload generation.
- Cover the example tool behavior in the archive metadata checker.

## Work Completed

- Added `parse_count(value)` to validate the fuzzer count argument.
- Replaced `ARGV.shift.to_i`-style parsing with `n = parse_count(ARGV.shift)`.
- Extended `scripts/check_archive_metadata.rb` to require the count guard.
- Updated README, ARCHIVE_STATUS, SECURITY, VISION, and CHANGES notes.

## Verification

- `ruby -c tools/fuzz.rb`
- `ruby -c scripts/check_archive_metadata.rb`
- `ruby scripts/check_archive_metadata.rb`
- `make lint`
- `make check`
- `make verify`
- `git diff --check`
