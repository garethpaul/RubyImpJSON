# Safe Make Authority

## Status: Completed

## Context

The Make root split checkout paths containing spaces, while caller-controlled
Ruby, Java, shell, preload, and Makefile-list inputs could redirect archive verification.

## Scope Boundaries

- Do not change archived JSON behavior, gem metadata, server behavior, dependencies, or Java sources.
- Preserve pinned Ruby 2.7 pure-gem and Java 8 archived-source verification.

## Work Completed

- Canonicalize the checked-in Makefile without splitting shell-sensitive paths.
- Freeze explicit Ruby, Java, and shell variables, export the root as data, and reject ambiguous Makefiles before recipes run.
- Defer final file-list validation so a trailing `-f` cannot replace a quality target.
- Keep runtime discovery on the provisioned `PATH`; local callers must treat that path as trusted.
- Detect `MAKEFILES` after GNU Make has parsed the preload. GNU Make can execute preload syntax before this repository Makefile runs, so callers must unset hostile startup inputs rather than treating the guard as a sandbox.
- Fail closed without command execution when GNU Make cannot preserve a literal `$()` sequence in an absolute Makefile path.
- Add the dependency-free authority suite to `make verify` and `make check`.

## Verification Completed

- Ruby 2.7 and Java 8 hosted archive checks passed.
- All 77 executed target, root, shell, Ruby, and Java authority cases passed.
- Both `MAKEFILE_LIST` override channels, a parsed `MAKEFILES` preload, and
  preceding and trailing multiple-Makefile invocations failed before repository recipes ran.
- A literal `$()` checkout path failed closed without creating its command-substitution marker.
- Archive metadata, pure tests, gem builds, Java compilation, `git diff --check`, and Git object validation passed.
