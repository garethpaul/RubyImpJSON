# README Plan Index

## Status: Completed

## Context

RubyImpJSON keeps canonical maintenance plans under `docs/plans/` and links
them from README maintenance notes, but the archive metadata checker did not
require that index to stay complete. A completed archive guard could be added
without a public README pointer, or README could retain stale links after a
plan rename.

## Objectives

- Require README to reference every canonical plan under `docs/plans/`.
- Reject README links to missing canonical plans.
- Preserve the archive's parser, fixture, and packaging behavior unchanged.

## Work Completed

- Extended `scripts/check_archive_metadata.rb` to validate README plan links in
  both directions.
- Added the README reference for this completed plan.
- Updated ARCHIVE_STATUS, VISION, and CHANGES notes for the plan-index guard.

## Verification

- `ruby scripts/check_archive_metadata.rb`
- `env JSON=pure MAKE=make rake do_test_pure`
- `make check`
- `make verify`
- `git diff --check`
