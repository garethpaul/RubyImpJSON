# Make Root Override Protection

## Status: Planned

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
