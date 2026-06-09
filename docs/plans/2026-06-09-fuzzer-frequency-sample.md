# Fuzzer Frequency Sample

## Status: Completed

## Context

The archived `tools/fuzz.rb` utility normalizes frequency weights and samples a
random value before selecting the matching bucket. The `pick` method assigned
that sampled value to `r`, but then called `rand` again inside the bucket
lookup, so selection was based on a different random value than the one the
method recorded.

## Objectives

- Preserve the historical fuzzer utility while fixing the sampled-bucket bug.
- Use the sampled value consistently during frequency bucket selection.
- Add archive metadata coverage so the resampling pattern cannot return.
- Avoid broad modernization of the legacy fuzzer script.

## Work Completed

- Updated `tools/fuzz.rb` to use `f.include? r` in `Fuzzer#pick`.
- Extended `scripts/check_archive_metadata.rb` to require use of the sampled
  value and reject `f.include? rand`.
- Updated README, ARCHIVE_STATUS, VISION, and CHANGES notes for the fuzzer
  frequency-sample guard.

## Verification

- `ruby scripts/check_archive_metadata.rb`
- `make lint`
- `make check`
- `make verify`
- `git diff --check`
