## RubyImpJSON Vision

RubyImpJSON is a legacy Ruby JSON implementation snapshot with pure Ruby,
native extension, and JRuby-related packaging artifacts, tests, fixtures, and
gem specifications.

The repository is useful as an archive of JSON parser and generator behavior
around Ruby 1.8/1.9-era encoding, extension compilation, additions, and test
fixtures.

The goal is to preserve the implementation and test corpus while making its
historical status and security-sensitive parser behavior clear.

The current focus is:

Priority:

- Preserve parser, generator, fixture, and gemspec files
- Keep README and changelog context available
- Maintain tests for parsing, generation, encoding, additions, and fixtures
- Preserve malformed-input fixtures such as unterminated block comments
- Preserve accepted comment parsing behavior in the pure Ruby parser
- Keep checked-in gemspec fixture manifests aligned with the fixture corpus
- Keep README archived-version notes aligned with the checked-in VERSION file
- Keep README maintenance notes linked to every canonical plan
- Keep completed maintenance plans under `docs/plans`
- Treat version 1.7.5 packaging as historical unless explicitly revived

Next priorities:

- Add reproduction notes for running tests on supported Ruby versions
- Clarify native extension and JRuby build expectations
- Review parser fixtures for security-regression value

Contribution rules:

- One PR = one focused parser, generator, fixture, packaging, or documentation change.
- Add or update tests for any parser/generator behavior change.
- Do not remove historical files without archive rationale.
- Keep security-relevant parsing changes explicit.

## Security And Responsible Use

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

JSON parsers handle untrusted input. Changes should preserve tests for malformed
documents, encoding edge cases, nesting, and resource-heavy payloads, and should
avoid weakening validation without clear rationale.

## What We Will Not Merge (For Now)

- Parser behavior changes without fixtures
- Packaging claims that conflict with the archived version
- Removal of security-relevant tests
- Gemspec fixture manifests that omit checked-in parser fixtures
- Broad modernization that obscures historical behavior

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
