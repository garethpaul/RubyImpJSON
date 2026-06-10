# Fixture Basename Classification

## Status: Completed

## Context

The fixture test partition searched each full path for the substring `pass`.
A checkout directory such as `second-pass` therefore moved every `fail*.json`
fixture into the passing set and caused path-dependent test failures.

## Objectives

- Classify JSON fixtures only from their basenames.
- Preserve all existing passing and failing fixture expectations.
- Detect regressions independently of the CI checkout directory.

## Work Completed

- Added a basename-based fixture classification helper.
- Added a synthetic `second-pass/fail1.json` regression assertion.
- Added archive metadata coverage for the classification contract.
- Updated README, ARCHIVE_STATUS, SECURITY, VISION, and CHANGES guidance.

## Verification

- `ruby scripts/check_archive_metadata.rb`
- `env JSON=pure MAKE=make rake do_test_pure`
- `make check`
- `make verify`
- `git diff --check`
