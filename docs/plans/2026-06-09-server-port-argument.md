# Server Port Argument

## Status: Completed

## Context

The historical `tools/server.rb` WEBrick example parsed an optional port from
the command line, but still passed the hard-coded default `6666` to
`create_server`. That made the example ignore caller-selected ports.

## Objectives

- Preserve the archived example server and default port.
- Pass the parsed command-line port into `create_server`.
- Add archive metadata coverage so the example does not regress.
- Keep the change isolated from parser, generator, native extension, and JRuby
  behavior.

## Work Completed

- Updated `tools/server.rb` to pass `port` to `create_server`.
- Extended `scripts/check_archive_metadata.rb` to require the parsed port wiring.
- Updated README, ARCHIVE_STATUS, VISION, SECURITY, and CHANGES notes for the
  example server guard.

## Verification

- `ruby -c tools/server.rb`
- `ruby scripts/check_archive_metadata.rb`
- `env JSON=pure MAKE=make rake do_test_pure`
- `make check`
- `make verify`
- `git diff --check`
