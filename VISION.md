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

- Keep CVE-2013-0269 and CVE-2020-10663 visible as archived package risks
- Preserve parser, generator, fixture, and gemspec files
- Keep README and changelog context available
- Maintain tests for parsing, generation, encoding, additions, and fixtures
- Preserve malformed-input fixtures such as unterminated block comments
- Preserve byte-exact invalid UTF-8 fixtures and cross-MRI rejection behavior
- Keep fixture pass/fail classification independent of checkout paths
- Preserve accepted comment parsing behavior in the pure Ruby parser
- Keep checked-in gemspec fixture manifests aligned with the fixture corpus
- Keep the native, pure-Ruby, and Java gem package build contract temporary,
  path-safe, and artifact-free
- Keep Ruby or GPL-2.0-only package metadata aligned with preserved license
  texts and keep the historical `permutation` development range bounded
- Keep README archived-version notes aligned with the checked-in VERSION file
- Keep README maintenance notes linked to every canonical plan
- Keep historical example tools wired to their documented arguments
- Keep example server port arguments validated before startup
- Keep the local startup URL aligned with WEBrick's actual bound port
- Keep the historical WEBrick HTTP example bound to loopback
- Keep the local `/json` response covered by executable archive tests
- Keep the exact `/json` path distinct from rejected descendant routes
- Keep explicit UTF-8, no-store, and nosniff headers on the local JSON response
- Keep local request targets, query values, referrers, and user agents out of
  WEBrick access logs
- Keep fuzzer frequency selection tied to the sampled random value
- Keep fuzzer count arguments validated before payload generation
- Keep completed maintenance plans under `docs/plans`
- Keep the full pure Ruby archive suite enforced in pinned hosted validation
- Keep the Java source compile gate pinned to the historical JRuby 1.7.27 API
  and Java 8 compatibility without committing compiler output
- Keep the archive reproduction guide explicit that Ruby 2.7 pure verification,
  native extension experiments, and JRuby source compilation prove different
  things
- Treat version 1.7.5 packaging as historical unless explicitly revived

Next priorities:

- Review generator edge cases for archive-regression value

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
Prototype `parseQuery` and Java `parseObject` names are historical
parser/prototype helpers, not Parse SDK or backend integrations.

## What We Will Not Merge (For Now)

- Claims that version 1.7.5 is safe for new production use despite its known
  advisories (CVE-2013-0269 and CVE-2020-10663)

- Parser behavior changes without fixtures
- Packaging claims that conflict with the archived version
- Removal of security-relevant tests
- Gemspec fixture manifests that omit checked-in parser fixtures
- Example tool changes without metadata checks
- Broad modernization that obscures historical behavior

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
