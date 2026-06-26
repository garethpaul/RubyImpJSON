# Generator State Depth Recovery Implementation Plan

Status: Completed

**Goal:** Restore reusable pure-generator state depth after failed nested array or hash generation without changing successful JSON output.

**Architecture:** Make each pure array/hash transformation release its own depth increment with `ensure`. Protect the public direct `to_json(state)` path with one focused regression and bind the behavior into the archive metadata contracts.

**Tech Stack:** Ruby 2.7, Test::Unit, pure-Ruby JSON generator, repository metadata checker, Docker, GNU Make.

---

### Task 1: Prove failed generation poisons state

**Files:**
- Modify: `tests/test_json_generate.rb`

**Step 1: Add the failing regression**

Exercise circular arrays and hashes with a nonzero configured starting depth.
After `JSON::NestingError`, require the original depth and successful immediate
reuse for shallow JSON.

**Step 2: Run the focused test**

Run the generator test in the digest-pinned Ruby 2.7 container.

Expected: FAIL because failed recursion leaves `JSON::State#depth` elevated.

### Task 2: Restore owned depth increments

**Files:**
- Modify: `lib/json/pure/generator.rb`

**Step 1: Add exception-safe depth release**

Wrap both collection transformations so each entered array or hash decrements
its one depth increment in `ensure`.

**Step 2: Preserve successful formatting**

Use the captured entered depth for child indentation and `depth - 1` for the
closing delimiter, retaining existing compact and pretty bytes.

**Step 3: Run the focused test**

Expected: PASS, including state recovery and existing generation assertions.

### Task 3: Bind archive evidence

**Files:**
- Modify: `scripts/check_archive_metadata.rb`
- Modify: `README.md`
- Modify: `SECURITY.md`
- Modify: `VISION.md`
- Modify: `ARCHIVE_STATUS.md`
- Modify: `CHANGES.md`
- Modify: `docs/plans/2026-06-26-generator-state-depth.md`

Require the regression, both exception-safe transforms, maintenance guidance,
completed-plan evidence, and latest changelog record.

### Task 4: Validate and merge exact head

Run the full pinned Ruby 2.7 container gate, Java 8 archive compilation,
mutation checks, diff hygiene, and secret scans. Push a focused PR, invoke
Codex review, wait for hosted Ruby/Java/CodeQL checks, and merge only the exact
reviewed green head.

## Work Completed

- Added a red-first array/hash regression with a nonzero starting depth and
  immediate state reuse.
- Made both pure collection transforms release their owned depth increment in
  `ensure` while retaining successful formatting.
- Added archive metadata, README, security, vision, archive-status, design, and
  changelog evidence.

## Verification Completed

- RED: failed array and hash generation left depth `4` instead of the configured
  depth `2`; the earlier direct-array assertion also found depth `19` instead
  of `0`.
- GREEN: all 13 focused generator tests passed with 83 assertions.
- The digest-pinned Ruby 2.7 `make check` gate passed 72 tests with 2,031
  assertions, three temporary gem package builds, and 77 Make authority cases.
- The first full gate rejected only a line-wrapped README contract phrase; the
  contiguous wording passed on the rerun.
- Repository-root and external-directory digest-pinned `make check` both
  passed.
- Two independent depth-release mutations failed the focused regression; five
  implementation and evidence mutations failed the archive metadata gate.
- The host has no Ruby executable, so Ruby validation used the documented
  read-only digest-pinned container.
- Java 8 source compilation, hosted checks, exact-head review, and merge remain
  required before integration; no native or JRuby generator runtime behavior
  is claimed.
