# Archive Status

## Status

This repository is a historical snapshot, not an active JSON gem fork.

## Preserved Surface

- Version: 1.7.5
- Pure Ruby parser and generator implementation
- Native extension sources
- JRuby-related Java sources and gemspec metadata
- Parser, generator, encoding, additions, and fixture tests
- Malformed-input fixtures, including the unterminated block comment case
- Pure parser comment behavior, including line comments terminated by EOF
- Fixture entries in the checked-in `json` and `json_pure` gemspec manifests
- README maintenance notes for every canonical `docs/plans` record

## Verification Baseline

Use `make verify` for local maintenance checks. The default verification path
forces `JSON=pure` and avoids Bundler/native-extension compilation so the
archived pure Ruby implementation is exercised consistently.

The canonical maintenance baseline is recorded in
`docs/plans/2026-06-08-rubyimpjson-baseline.md`.

## Change Policy

- Keep behavior changes tied to fixtures or tests.
- Keep gemspec fixture manifests aligned with the checked-in fixture corpus.
- Keep README maintenance plan links aligned with `docs/plans`.
- Do not remove native or JRuby artifacts without an archive rationale.
- Do not claim modern gem support without a dedicated compatibility plan.
- Preserve security-relevant parser fixtures for malformed JSON and encoding
  edge cases.
