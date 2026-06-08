# Pure Ruby Verification

## Problem

The legacy default Rake test path depends on Bundler and native-extension setup.
In this environment, Bundler is not installed and direct unqualified test runs
fall through to extension/system JSON behavior instead of the archived pure Ruby
implementation.

## TDD Evidence

1. Confirmed `bundle exec rake test` is unavailable because `bundle` is missing.
2. Confirmed direct unqualified tests fail under modern Ruby when they do not
   force the pure variant.
3. Added `scripts/check_archive_metadata.rb` and ran it before README updates;
   it failed until `make verify` and `JSON=pure` were documented.
4. Wired `make verify` to run metadata checks and `env JSON=pure rake do_test_pure`.

## Verification

- `make lint`
- `make test`
- `make build`
- `make verify`
- `git diff --check`
