# Changes

## 2026-06-09

- Added README plan-index validation so canonical archive maintenance plans
  stay discoverable and stale plan links fail verification.
- Added README archived-version coverage and metadata validation so public
  usage notes stay aligned with `VERSION`.
- Added pure parser coverage for `//` line comments at end-of-file and allowed
  EOF to terminate those comments.
- Added archive metadata checks that require the checked-in `json` and
  `json_pure` gemspec manifests to include every parser fixture.
- Added the unterminated block comment fixture to both checked-in gemspec
  package file lists so archived package manifests preserve the test corpus.

## 2026-06-08

- Added a malformed-input fixture for unterminated block comments and made the
  archive metadata check preserve it.
- Added `make check` as the shared repository verification alias.
- Added a Bundler-free `make verify` gate for archive metadata and the pure-Ruby
  JSON test corpus.
- Added metadata checks for version consistency, fixture presence, Rake pure-test
  wiring, and README verification instructions.
- Documented the `JSON=pure` verification path separately from the historical
  Bundler/native-extension test path.
- Added `ARCHIVE_STATUS.md` and metadata checks that keep historical snapshot
  status, version, and `JSON=pure` verification expectations explicit.
- Added canonical `docs/plans` coverage and made archive metadata checks
  require completed plans.
