# Invalid UTF-8 JSON String Implementation Plan

Status: Completed

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Reject JSON strings whose decoded bytes are not valid UTF-8 in both pure and native MRI parsers.

**Architecture:** Add a JSONTestSuite-derived failing fixture to the existing fixture corpus. Validate the decoded string immediately after UTF-8 association in pure Ruby and in both the native Ragel source and checked-in generated C parser; JRuby remains unchanged because its `StringDecoder` already validates UTF-8.

**Tech Stack:** Ruby 2.7, C extension, Ragel-generated C, JRuby Java source, Test::Unit, GNU Make, Docker

---

### Task 1: Establish the malformed fixture

**Files:**
- Create: `tests/fixtures/fail30.json`
- Modify: `tests/test_json_fixtures.rb`

**Step 1: Write the failing test**

Create the exact bytes `5b 22 5c e5 22 5d` and add a focused assertion that
the fixture is binary-identical to the reviewed JSONTestSuite case and raises
`JSON::ParserError`.

**Step 2: Run test to verify it fails**

Run: `docker run --rm -v "$PWD:/work" -w /work ruby:2.7 env JSON=pure MAKE=make rake do_test_pure`

Expected: FAIL because the parser returns an invalid UTF-8 string.

### Task 2: Fix the pure parser

**Files:**
- Modify: `lib/json/pure/parser.rb`

**Step 1: Implement minimal validation**

After forcing decoded bytes to UTF-8, raise `ParserError` unless
`valid_encoding?` is true.

**Step 2: Run pure tests**

Run the focused fixture test, then `rake do_test_pure`.

Expected: PASS with all prior legacy escape fixtures unchanged.

### Task 3: Fix the native MRI parser

**Files:**
- Modify: `ext/json/ext/parser/parser.rl`
- Modify: `ext/json/ext/parser/parser.c`

**Step 1: Add coderange validation**

After `FORCE_UTF8`, use Ruby's encoding coderange API when available and raise
the parser error on a broken string. Apply the identical semantic edit to the
checked-in generated C source.

**Step 2: Build and test native extension**

Run: `env JSON=ext bundle exec rake test_ext` in the supported Ruby 2.7
container.

Expected: PASS, including `fail30.json`.

### Task 4: Bind archive contracts

**Files:**
- Modify: `scripts/check_archive_metadata.rb`
- Modify: `README.md`
- Modify: `ARCHIVE_STATUS.md`
- Modify: `SECURITY.md`
- Modify: `VISION.md`
- Modify: `CHANGES.md`
- Modify: `docs/plans/2026-06-26-invalid-utf8-string.md`

**Step 1: Add mutation-sensitive contracts**

Require exact fixture bytes, pure/native validation, synchronized Ragel/C
logic, completed plan evidence, and retention of the deliberate legacy escape
fixtures.

**Step 2: Run full verification**

Run all Make aliases, pure/native tests, Java source compile gate, gem package
builds, metadata mutations, shell syntax, and `git diff --check`.

Expected: all available checks pass; any unavailable historical runtime is
recorded without an unsupported claim.

### Task 5: Publish exact-head evidence

**Files:**
- Modify: `docs/plans/2026-06-26-invalid-utf8-string.md`

**Step 1: Record RED/GREEN and hosted results**

Document exact commands, variant results, mutation count, external fixture
commit, and remaining archive limitations.

**Step 2: Commit**

Run: `git commit -m "fix: reject invalid UTF-8 JSON strings"`

Expected: one focused commit ready for PR review.

## Verification Evidence

- Provenance: JSONTestSuite commit `1ef36fa01286573e846ac449e8683f8833c5b26a`
  contains the exact six-byte fixture at
  `test_parsing/n_string_invalid_utf8_after_escape.json`.
- RED: the pure parser accepted the invalid UTF-8 fixture before the fix, so
  both the failing-fixture loop and focused regression failed.
- RED: the native parser accepted the invalid UTF-8 fixture before the fix in
  a parser-only extension load.
- GREEN: the focused pure fixture suite passed with 4 tests and 37 assertions.
- GREEN: the parser-only native extension regression passed after rebuilding
  `ext/json/ext/parser/parser.so` under Ruby 2.7.
- Compatibility: the full pure suite passed with 71 tests and 2,023
  assertions, including the deliberate `pass15`, `pass16`, and `pass17`
  legacy escape fixtures.
- Packaging: all three gem package builds retained `fail30.json` without
  leaving repository artifacts.
- Java: `make java-check` under Java 8 and `jruby-jars 1.7.27` compiled all 12
  archived sources into 39 temporary class files.
- Archive authority: 77 Make target/authority cases passed.
- Mutation testing: 11 isolated hostile changes covering fixture bytes, legacy
  fixtures, both parser implementations, the focused test, both MRI manifests,
  package retention, archive documentation, and plan evidence were rejected.
- Canonical verification: repository and external-directory `make check`
  passed in the pinned Ruby 2.7 container.
- Native boundary: a parser-only native build and regression passed; the full
  historical native task remains outside the maintained gate because the
  generator uses Ruby C APIs removed before Ruby 2.7.
