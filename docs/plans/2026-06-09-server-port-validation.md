# Server Port Validation

## Status: Completed

## Context

The historical `tools/server.rb` example now passes the parsed command-line
port to `create_server`, but it still used `to_i` for parsing. That silently
turns malformed values such as `abc` into port `0`, which makes the example
less predictable when run during archive exploration.

## Objectives

- Preserve the default WEBrick server port of `6666`.
- Require explicit integer parsing for optional port arguments.
- Reject ports outside the TCP range before starting WEBrick.
- Keep the behavior covered by the archive metadata checker.

## Work Completed

- Added `parse_port(value)` to validate integer port arguments and range.
- Replaced `to_i` coercion with the validated parser before server startup.
- Extended `scripts/check_archive_metadata.rb` to require the validation
  pattern and parsed-port wiring.
- Updated README, ARCHIVE_STATUS, VISION, and CHANGES notes for the guard.

## Verification

- `ruby -c tools/server.rb`
- `ruby scripts/check_archive_metadata.rb`
- `env JSON=pure MAKE=make rake do_test_pure`
- `make check`
- `make verify`
- `git diff --check`
