# Java Source Compile Gate

## Status: Completed

## Context

The archive contains twelve JRuby extension sources and an old conditional
Rake compilation task, but the maintained root verification commands never
compile those sources. The legacy Ant instructions are not runnable because
their project files are absent. A direct Java 8 compile against the matching
JRuby 1.7.27 API succeeds and can provide a reproducible compiler boundary
without changing the archived package.

## Priority

Expose and enforce a real Java compiler command for the checked-in JRuby
extension sources while preserving the pure-Ruby archive baseline.

## Requirements

- Add a documented `make java-check` target that compiles all twelve Java
  sources with Java 8 source and target compatibility.
- Resolve only the pinned `jruby-core` 1.7.27 jar from the installed
  `jruby-jars` 1.7.27 gem or an explicit environment override.
- Compile into a temporary directory and remove it on success or failure.
- Fail closed when `javac`, the exact gem version, the core jar, any expected
  source, or successful class output is missing.
- Add a separate hosted Java 8 job that installs the pinned gem and runs the
  compiler command without weakening the existing pure-Ruby archive job.
- Add mutation-sensitive static contracts for the Make target, pin, compiler
  flags, complete source set, cleanup behavior, workflow, documentation, and
  completed-plan evidence.

## Verification

- Focused compiler-script tests with the isolated `jruby-jars` 1.7.27 gem.
- Repository and external-directory `make java-check`.
- Existing repository and external-directory `make check`.
- Hostile mutations covering target removal, version drift, source omission,
  compiler-flag drift, cleanup removal, workflow bypass, documentation drift,
  and false completion evidence.
- Exact diff, generated-artifact, credential-pattern, conflict-marker, and
  whitespace audits.

## Scope Boundary

This change does not upgrade JRuby, regenerate parser sources, alter archived
Java or Ruby behavior, add compiled classes or jars to git, modify gem payloads,
or claim execution of the JRuby extension runtime.

## Verification Results

- The repository and external-directory `make java-check` passed under Java 8
  with the exact `jruby-jars` 1.7.27 dependency; all twelve sources produced
  39 temporary class files and left no class output in the checkout.
- The repository and external-directory `make check` passed the metadata gate,
  65 pure-Ruby tests with 2,015 assertions, and all three temporary gem package
  builds.
- Ten hostile compiler-gate mutations were rejected across the Make target,
  dependency version, source inventory, compiler flags, temporary cleanup,
  workflow pin, guidance, plan status, jar hash, and missing compiler paths.
- Workflow YAML parsing, exact diff, generated-artifact, credential-pattern,
  conflict-marker, and whitespace audits passed.
- The JRuby extension runtime was not executed; this change proves compilation
  against the historical API, not runtime compatibility or production safety.
