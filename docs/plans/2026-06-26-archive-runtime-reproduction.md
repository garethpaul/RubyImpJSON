# Archive Runtime Reproduction

Status: Completed

## Context

The archive has executable pure-Ruby and Java compilation gates, but the
README does not clearly separate those maintained verification boundaries
from the historical native-extension and JRuby runtime surfaces. The existing
setup section can therefore imply broader modern-runtime support than the
repository proves.

## Goal

Document reproducible, non-production verification paths without claiming
that archived `json` 1.7.5 is supported on modern Ruby or JRuby runtimes.

## Design

- Add one canonical runtime reproduction guide.
- Define the digest-pinned Ruby 2.7 pure-Ruby gate as the maintained executable
  archive baseline.
- Explain that `make build` packages all gem variants without compiling or
  loading the native or JRuby extensions.
- Bound native-extension work to an optional historical experiment requiring
  compatible Ruby headers and a C toolchain.
- Bound `make java-check` to Java 8 plus `jruby-jars` 1.7.27 source compilation
  and explicitly state that it does not execute the JRuby extension runtime.
- Link the guide from the README and archive status, retire the two completed
  roadmap items, and protect the claims with fail-closed metadata checks.

## Verification

- The new metadata contracts failed before the guide existed.
- The focused archive metadata checker passed in the pinned Ruby 2.7 image.
- Repository and external-directory `make check` passed: each run executed 70
  tests with 2,020 assertions, built and inspected all three gem packages, and
  passed 77 Make authority cases.
- The exact documented read-only Docker command passed while running as the
  caller with an isolated writable home directory.
- Twelve isolated hostile mutations covering all ten guide claims and both
  document links were rejected.
- A disposable native probe confirmed the parser compiles on pinned Ruby 2.7
  while the generator fails on removed historical C API details.
- Local `make java-check` was not run because this host has Java 11 and no Ruby
  or `jruby-jars` installation; the exact Java 8 hosted gate remains required.
