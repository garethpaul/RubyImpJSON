# Changes

## 2026-06-25T13:09:56-07:00 — P2 local-demo access-log privacy

- Cycle: inspected the explicitly licensed historical archive, existing plans,
  open work, recent hardening, server behavior, verification authority, and
  hosted boundaries before changing the optional loopback demo.
- Threads: prioritized privacy over parser modernization because archived
  `json` 1.7.5 is intentionally non-production while the maintained demo was
  still persisting accepted query values, referrers, and user-agent strings.
- Bug: WEBrick common, referrer, and agent access logs wrote caller-controlled
  request metadata to the diagnostic stream even though the demo needs only
  error logging.
- Files: changed `tools/server.rb`, `tests/test_server.rb`,
  `scripts/check_archive_metadata.rb`, archive/security/vision/README guidance,
  and `docs/plans/2026-06-25-local-server-access-log-privacy.md`.
- Validation: the pre-fix pinned Ruby 2.7 regression failed on a logged query
  token; the fix passed all seven server tests and four hostile mutations for
  common, referrer, agent, and missing-regression behavior. Root and external
  pinned-runtime `make check` each passed 69 tests, 2,019 assertions, 77 Make
  authority cases, archive metadata checks, and three temporary gem builds.
- Blockers: the host has no Ruby executable, so all Ruby behavior runs in the
  same digest-pinned Ruby 2.7 container used by CI; JRuby runtime behavior is
  outside this privacy-only change.
- Next: require hosted archive and Java checks plus clean exact-head Codex
  review before merge; continue preserving error diagnostics without routine
  request metadata.

## 2026-06-21

- Hardened Make verification for spaced paths, portable `sed` discovery,
  explicit root/runtime/shell overrides, and preceding or trailing Makefiles.

## 2026-06-19

- Bounded the pure package's maintenance Rake dependency to patched
  `~> 13.4.2`, excluding CVE-2020-8130 without changing the archived parser.

## 2026-06-16

- Added a Java source compile gate that verifies the pinned JRuby 1.7.27 API,
  compiles all twelve archived extension sources with Java 8 compatibility,
  and leaves no class files in the checkout.

## 2026-06-14

- Made the loopback server resolve archived JSON load paths from its own
  location instead of silently loading the system gem from external callers.

## 2026-06-13

- Restricted the archived servlet to the exact `/json` path while preserving
  query strings and rejecting descendants before payload generation.
- Added explicit UTF-8, no-store, and nosniff headers to the loopback `/json`
  response and required them through the executable archive test.

## 2026-06-12

- Added an executable `/json` response test for the loopback-only WEBrick demo,
  including status, content type, counter, timestamp, and Unicode payload checks.
- Hardened hosted validation with credential-free checkout, exact release
  pinning, strict action/permission/trigger contracts, and all-branch push runs.
- Recorded CVE-2013-0269 and CVE-2020-10663 against archived `json` 1.7.5,
  successful gem builds, and the explicit non-production package policy.
- Added a dependency-free gem package build contract for all three archived
  gemspecs with metadata, payload, archive-path, and artifact-cleanup checks.
- Declared the preserved Ruby or GPL-2.0-only package metadata, included both
  JRuby license texts, and bounded the `permutation` development dependency.

## 2026-06-10

- Bound the historical WEBrick example server to loopback and documented it as
  a local-only HTTP archive demo.
- Made JSON fixture pass/fail classification independent of checkout directory
  names and added a parent-path regression test.
- Clarified that Prototype `parseQuery` and Java `parseObject` references are
  parser/prototype helpers, not Parse SDK/backend integrations.
- Added dependency-free hosted validation for all 63 pure Ruby archive tests in
  a digest-pinned Ruby 2.7 container.
- Made the Makefile and archive checker independent of the caller's directory.
- Added fail-closed checks for the hosted runtime and immutable action pin.

## 2026-06-09

- Validated example fuzzer count arguments as positive integers before payload
  generation, with archive metadata coverage.
- Fixed the archived fuzzer to use its sampled random value when selecting
  frequency buckets, with archive metadata coverage.
- Validated example WEBrick server port arguments before starting the server,
  with archive metadata coverage.
- Added README plan-index validation so canonical archive maintenance plans
  stay discoverable and stale plan links fail verification.
- Fixed the example WEBrick server so the parsed command-line port is passed to
  `create_server`, with archive metadata coverage.
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
