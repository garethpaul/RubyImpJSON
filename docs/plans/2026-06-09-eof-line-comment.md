# EOF Line Comment Parsing

## Status: Completed

## Context

The pure Ruby parser already accepts `//` comments when they end with a newline,
but rejected an otherwise equivalent trailing line comment at end-of-file. Since
comment handling is part of this archived implementation's compatibility
surface, EOF line comments should be covered by the pure parser tests.

## Objectives

- Preserve existing comment parsing and malformed block-comment rejection.
- Accept a final `//` line comment when it is terminated by end-of-file.
- Add focused pure-Ruby parser regression coverage.
- Avoid native extension or JRuby modernization in this archive pass.

## Work Completed

- Added an EOF line-comment assertion to `tests/test_json.rb`.
- Updated the pure parser ignored-comment regex to accept `\z` as a line
  comment terminator.
- Updated README, ARCHIVE_STATUS, VISION, and CHANGES notes for the parser
  compatibility guard.

## Verification

- `env JSON=pure ruby -I. -Ilib tests/test_json.rb -n test_comments`
- `make check`
- `make verify`
- `git diff --check`
