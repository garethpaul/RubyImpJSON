# Changes

## 2026-06-08

- Added a Bundler-free `make verify` gate for archive metadata and the pure-Ruby
  JSON test corpus.
- Added metadata checks for version consistency, fixture presence, Rake pure-test
  wiring, and README verification instructions.
- Documented the `JSON=pure` verification path separately from the historical
  Bundler/native-extension test path.
- Added `ARCHIVE_STATUS.md` and metadata checks that keep historical snapshot
  status, version, and `JSON=pure` verification expectations explicit.
