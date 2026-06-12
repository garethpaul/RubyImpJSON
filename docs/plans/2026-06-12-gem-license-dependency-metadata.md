# Gem License And Dependency Metadata

## Status: Completed

## Context

The archived native, pure-Ruby, and Java gemspecs still build, but current
RubyGems reports that every package omits license metadata. It also reports an
open-ended `permutation >= 0` development dependency for the native and
pure-Ruby packages. The repository's preserved license files establish the
historical Ruby-license-or-GPL boundary, and the complete published
`permutation` series is `0.1.3` through `0.1.8`.

## Priority

Package metadata should accurately describe the archived distribution and
avoid unconstrained development resolution. These changes reduce ambiguity
for package inspection without changing JSON 1.7.5 runtime behavior or
reviving publication support.

## Requirements

- R1. Declare SPDX-compatible `Ruby` and `GPL-2.0-only` license identifiers in
  all three gemspecs, matching `COPYING`, `COPYING-json-jruby`, and `GPL`.
- R2. Replace `permutation >= 0` with `permutation ~> 0.1` everywhere it can be
  selected by the historical RubyGems compatibility branches, and align the
  Rakefile gemspec generators so regeneration cannot undo the metadata fix.
- R3. Extend the package build contract to verify exact license metadata and
  the bounded development dependency for the native and pure-Ruby gems.
- R4. Capture RubyGems build output and fail if either remediated metadata
  warning returns.
- R5. Extend the archive checker and documentation to preserve the metadata
  contract and completed verification evidence.
- R6. Protect licenses, dependency bounds, warning rejection, checker wiring,
  documentation, and plan completion with focused hostile mutations.

## Scope Boundaries

- Do not change package names, version `1.7.5`, runtime dependencies, source,
  parser behavior, or supported historical implementation variants.
- Do not install or publish the archived gems.
- Do not claim that metadata hardening makes JSON 1.7.5 safe for production;
  CVE-2013-0269 and CVE-2020-10663 remain disclosed archive risks.
- Do not replace the preserved license texts or infer a new licensing grant.

## Verification Plan

- `ruby scripts/test_gem_builds.rb`
- direct `gem build` warning inspection for all three gemspecs
- `make check` locally and from outside the repository root
- read-only, network-isolated Ruby 2.7 container validation
- focused hostile metadata-contract mutations
- Ruby syntax, gemspec load, generated-artifact, secret, and diff checks

## Work Completed

- Declared `Ruby` and `GPL-2.0-only` on the native, pure-Ruby, and Java
  specifications, matching the preserved dual-license texts.
- Included `COPYING-json-jruby` and `GPL` in the Java package payload.
- Replaced every historical `permutation >= 0` branch with `~> 0.1`, retaining
  compatibility with the complete published `0.1.x` series.
- Aligned both Rakefile gemspec generators with the same dual-license and
  bounded dependency metadata so regeneration cannot restore the warnings.
- Extended the gem package harness to verify exact built licenses, dependency
  type and range, Java license payloads, and absence of the remediated RubyGems
  warnings.
- Extended the archive checker and maintenance documentation to preserve the
  package metadata boundary without changing runtime behavior or production
  support policy.

## Verification

- `ruby scripts/test_gem_builds.rb` passed for all three packages.
- Direct `gem build` commands produced all three packages without license or
  open-ended dependency warnings.
- `make check` passed the archive checker, 64 tests with 2,014 assertions, and
  all three package builds with zero failures or errors.
- Root-independent `make -f /path/to/Makefile check` passed the same complete
  gate from `/tmp`.
- The exact digest-pinned Ruby 2.7 hosted image passed `make check` with a
  read-only source mount, disabled networking, an ephemeral writable temporary
  directory, and no project dependency installation.
- Nine focused hostile mutations were rejected: missing or incorrect licenses,
  open-ended or runtime `permutation`, omitted Java license payloads, stale
  Rakefile generator metadata, removed warning guards, missing README guidance,
  and an incomplete plan.
- Ruby syntax, gemspec loads, package artifact cleanup, and `git diff --check`
  passed.
