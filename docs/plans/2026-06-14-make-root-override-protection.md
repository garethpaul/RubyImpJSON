# Make Root Override Protection

## Status: Completed

## Context

The archive Makefile derives its repository root from the loaded file and uses
that path for metadata, pure-Ruby tests, and gem-package builds. GNU Make
command-line variables outrank an ordinary assignment, so `make ROOT=/tmp
check` can redirect those gates away from the checkout.

## Requirements

- **R1:** Prevent command-line and environment values from replacing the
  Makefile-derived repository root.
- **R2:** Keep the `RUBY` interpreter configurable.
- **R3:** Require the exact protected declaration in the archive checker.
- **R4:** Prove every public Make alias from the checkout and an external
  directory with a hostile `ROOT` argument.
- **R5:** Preserve archive metadata, pure-Ruby behavior, server contracts,
  fixture handling, and gem package builds.

## Implementation Units

### U1. Protected Root

Give the repository-derived root override precedence without changing recipes
or runtime selection.

### U2. Archive Contract

Extend `scripts/check_archive_metadata.rb` to reject weakened, duplicate,
displaced, or caller-controlled root declarations and incomplete evidence.

### U3. Verification

Run the archive checker, pure tests, gem builds, all Make aliases, the exact
hosted Ruby image, hostile mutations, and integrity screening.

## Scope Boundary

- Do not modify archived library, extension, fixture, or server behavior.
- Do not change gem metadata, dependency bounds, workflow policy, or runtime.
- Do not add built gems, caches, credentials, or generated archive files.

## Verification

- `ruby scripts/check_archive_metadata.rb`
- `make check`
- external `make ROOT=/tmp check`
- root-declaration, checker, plan-status, README-index, and evidence mutations
- Ruby syntax, workflow YAML, protected-file, secret, artifact, and
  `git diff --check` gates

## Work Completed

- Protected the Makefile-derived repository root from command-line and
  environment overrides while preserving configurable Ruby selection.
- Added exact declaration and completed-evidence archive contracts.
- Preserved archived source, fixtures, server behavior, gem metadata, and
  package-build boundaries.

## Verification Results

- `ruby scripts/check_archive_metadata.rb` passed.
- From both the checkout and an external directory, all five public Make aliases passed.
- `make ROOT=/tmp check` passed externally while still running repository-owned
  archive, pure-test, and gem-package gates.
- The digest-pinned Ruby 2.7 hosted image passed `make check` with networking
  disabled and the source mounted read-only.
- Six hostile mutations were rejected across root declaration, checker
  expectation, plan status, README indexing, and recorded evidence.
- Ruby syntax, workflow YAML, exact-base protected-file comparison, secret
  screening, generated-artifact screening, and `git diff --check` passed before
  shipping.
