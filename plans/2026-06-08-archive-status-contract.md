# Archive Status Contract

## Status

Completed

## Context

`RubyImpJSON` contains a legacy JSON implementation snapshot with pure Ruby,
native extension, and JRuby artifacts. The README and verification gate explain
how to run the pure-Ruby tests, but the repository does not yet have a durable
archive-status document that distinguishes historical preservation from an
active fork.

## Objectives

- Add `ARCHIVE_STATUS.md` with explicit historical snapshot guidance.
- Link archive status from README and current project vision.
- Extend archive metadata checks so archive status, version, and pure-Ruby
  verification expectations stay documented.

## Verification

- `make lint`
- `make verify`
- `git diff --check`
