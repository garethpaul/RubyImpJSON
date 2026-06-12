# Hosted Archive Validation

Status: Completed

## Context

The archived version 1.7.5 pure Ruby implementation has 62 tests and 2,011
assertions, but the default branch did not run them in hosted validation. The
suite passes on Ruby 2.7, whose standard library still includes the historical
WEBrick dependency used by the local-only example server. On Ruby 3.4 the core
parser and generator tests execute, but the server regression requires an
undeclared external `webrick` gem.

## Objectives

- Run the complete pure Ruby archive contract on pushes and pull requests.
- Preserve the archive dependency boundary without adding modern gem metadata.
- Pin the Ruby runtime image by digest and third-party actions by commit.
- Install no project dependencies in hosted validation.
- Keep `make check` independent of the caller's current directory.

## Work Completed

- Added `.github/workflows/check.yml` on a fixed Ubuntu 24.04 runner.
- Selected the official Ruby 2.7 image and pinned it by immutable digest.
- Pinned checkout to its reviewed v6.0.3 commit with read-only permissions.
- Made the Makefile and archive checker resolve paths from the repository root.
- Extended archive metadata validation to fail closed when the hosted runtime,
  action pin, workflow, or completed plan drifts.

## Verification

- `make check`
- `make -f /path/to/repository/Makefile check` from outside the repository
- `docker run --rm -v "$PWD:/work:ro" -w /work ruby:2.7@sha256:2347de892e419c7160fc21dec721d5952736909f8c3fbb7f84cb4a07aaf9ce7d make check`
- `git diff --check`
