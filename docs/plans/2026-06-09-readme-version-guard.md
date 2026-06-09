# README Version Guard

## Status: Completed

## Context

`ARCHIVE_STATUS.md`, `VERSION`, and the checked-in gemspecs preserve
RubyImpJSON as version 1.7.5, but the public README did not expose that archived
version near the usage notes. Readers should see the historical version before
treating the repository as an active fork or supported gem release.

## Objectives

- Keep the README aligned with the checked-in `VERSION` file.
- Preserve the archive status without changing parser or packaging behavior.
- Add deterministic metadata validation for the README version note.
- Avoid broader gemspec regeneration or release modernization.

## Work Completed

- Added an archived version note to README usage guidance.
- Extended `scripts/check_archive_metadata.rb` to require the README version
  note to match `VERSION`.
- Updated README, VISION, and CHANGES notes for the version guard.

## Verification

- `ruby scripts/check_archive_metadata.rb`
- `make check`
- `git diff --check`
