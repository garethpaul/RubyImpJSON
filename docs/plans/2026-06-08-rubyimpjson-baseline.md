# RubyImpJSON Baseline

## Status: Completed

## Context

`RubyImpJSON` is a historical JSON implementation snapshot with pure Ruby,
native extension, and JRuby artifacts. The default maintenance path should
exercise the archived pure Ruby implementation and keep archive-status metadata
honest without requiring Bundler or native extension compilation.

## Objectives

- Preserve parser, generator, fixture, gemspec, native extension, and JRuby
  artifacts as historical context.
- Keep version metadata aligned across `VERSION`, gemspecs, and
  `lib/json/version.rb`.
- Run the pure Ruby JSON test corpus through the repository `make check` gate.
- Keep archive status and security-relevant parser fixtures documented.
- Maintain completed maintenance plans under `docs/plans`.

## Work Completed

- Confirmed `make check` runs archive metadata validation and the pure Ruby
  test corpus with `JSON=pure`.
- Added canonical `docs/plans` coverage for the current archive baseline.
- Extended archive metadata validation to require completed `docs/plans`
  entries with `make check` verification.
- Updated README, VISION, CHANGES, and archive status notes to make the
  baseline discoverable.

## Verification

- `ruby scripts/check_archive_metadata.rb`
- `env JSON=pure MAKE=make rake do_test_pure`
- `make check`
- `make verify`
- `git diff --check`

## Follow-Up Candidates

- Add reproduction notes for specific Ruby versions that should run the full
  native extension and JRuby paths.
- Review malformed JSON fixtures for security-regression coverage value.
