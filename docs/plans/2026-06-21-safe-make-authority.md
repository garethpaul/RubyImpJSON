# Safe Make Authority

## Status: Completed

## Context

The Make root split checkout paths containing spaces, while caller-controlled
Ruby, Java, shell, preload, and Makefile-list authority could redirect archive verification.

## Scope Boundaries

- Do not change archived JSON behavior, gem metadata, server behavior, dependencies, or Java sources.
- Preserve pinned Ruby 2.7 pure-gem and Java 8 archived-source verification.

## Work Completed

- Canonicalize the checked-in Makefile without splitting shell-sensitive paths.
- Freeze Ruby, Java, and shell authority, export the root as data, and reject preloaded or ambiguous Makefiles.
- Add the dependency-free authority suite to `make verify` and `make check`.

## Verification Completed

- Ruby 2.7 and Java 8 hosted archive checks passed.
- All 77 executed target, root, shell, Ruby, and Java authority cases passed.
- Both `MAKEFILE_LIST` override channels, a `MAKEFILES` preload, and an
  ambiguous multiple-Makefile invocation failed closed.
- Archive metadata, pure tests, gem builds, Java compilation, `git diff --check`, and Git object validation passed.
