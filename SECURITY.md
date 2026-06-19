# Security Policy

## Supported Versions

The supported security scope for `RubyImpJSON` is the current default branch, `master`. Older commits, tags, branches, forks, demos, and generated artifacts are not actively supported unless the repository explicitly marks them as maintained.

Project summary: No GitHub description is currently set.

The Java source compile gate verifies the exact `jruby-core` 1.7.27 jar hash
before compiling archived sources into a temporary directory. Compiled classes
and dependency jars must never be committed or used to imply that the archived
runtime is safe for production.

## Reporting a Vulnerability

Please report suspected vulnerabilities through GitHub's private vulnerability reporting or by opening a draft GitHub Security Advisory for `garethpaul/RubyImpJSON` when that option is available. If GitHub does not show a private reporting option for this repository, contact the repository owner through GitHub and avoid posting exploit details publicly until the issue can be assessed.

Do not open a public issue that includes exploit code, secrets, personal data, or detailed reproduction steps for an unpatched vulnerability.

## What to Include

Helpful reports include:

- the affected file, endpoint, permission, dependency, or workflow
- a concise impact statement explaining what an attacker could do
- reproduction steps using test data and accounts you control
- the branch, commit SHA, platform version, device, runtime, or dependency versions used
- logs, screenshots, or proof-of-concept snippets that demonstrate impact without exposing private data

## Project Security Posture

- This repository appears to be a Ruby project. The active security scope is the code and documentation on the default branch.
- Review found authentication, token, or session-related code paths; changes in those areas should receive security-focused review before merge.
- Review found external API integrations or credential-adjacent configuration; changes in those areas should receive security-focused review before merge.
- Review found network clients, sockets, web APIs, or service endpoints; changes in those areas should receive security-focused review before merge.
- Review found file, document, data, or media parsing flows; changes in those areas should receive security-focused review before merge.
- Review found shell execution, subprocess, or dynamic evaluation surfaces; changes in those areas should receive security-focused review before merge.
- Dependency manifests detected: Gemfile. Dependency updates should preserve lockfiles when present and avoid introducing packages without a clear maintenance reason.

## Service and API Notes

For web services, APIs, sockets, or scraping workflows, prioritize reports involving authentication bypass, authorization errors, injection, server-side request forgery, unsafe deserialization, credential leakage, data exposure, or denial-of-service conditions. Use test accounts and minimal proof-of-concept traffic only.

The historical `tools/server.rb` WEBrick example should keep its port handling
explicit so local test runs do not silently ignore caller-selected ports.
It is a local-only HTTP archive demo and should stay bound to loopback unless a
dedicated service design is added.
Its `/json` response should retain explicit UTF-8, `Cache-Control: no-store`,
`X-Content-Type-Options: nosniff`, and `Referrer-Policy: no-referrer` headers.
Only a literal `/json` request target with an optional query is accepted;
encoded, duplicate-slash, traversal, and descendant aliases are rejected.
Static demo responses are limited to regular non-symlink files below 1 MiB
inside a real document-root directory.
Parser fixture classification should use fixture basenames so checkout paths
cannot silently move malformed inputs into the passing corpus.
The historical `tools/fuzz.rb` example should reject invalid count arguments
before generating parser payloads.
Prototype `parseQuery` and Java `parseObject` references are historical
parser/prototype helper names, not Parse SDK or backend integrations.

## Dependency and Supply Chain Security

Archived `json` 1.7.5 is affected by CVE-2013-0269 and CVE-2020-10663. This
repository is retained for historical verification, not production use. New
applications should use a currently supported JSON implementation.

Hosted archive validation installs no project dependencies, grants only read
access to repository contents, and pins both the Ruby image and checkout action
immutably. Checkout credentials are not persisted after source retrieval.
The gem package build contract writes only to a temporary directory, rejects
unsafe archive paths, and verifies that no `.gem` artifact is left in the
repository. It also verifies the preserved Ruby or GPL-2.0-only metadata and
the bounded `permutation ~> 0.1` development requirement. It is packaging
validation, not a publication or support claim.

Dependency updates should come from trusted package managers and should keep lockfiles in sync when lockfiles exist. Do not commit credentials, private keys, tokens, generated secrets, or machine-local configuration. If a vulnerability depends on a compromised package, typosquatting risk, insecure transitive dependency, or unsafe build step, include the package name, affected version, and the path through which it is used.

## Safe Research Guidelines

Good-faith research is welcome when it stays within these boundaries:

- use only accounts, devices, data, and infrastructure that you own or have explicit permission to test
- avoid destructive actions, persistence, spam, phishing, social engineering, or denial-of-service testing
- minimize access to personal data and stop testing immediately if private data is exposed
- do not exfiltrate secrets or third-party data; report the minimum evidence needed to verify impact
- keep vulnerability details confidential until the maintainer has assessed the report

## Maintainer Response

The maintainer will review complete reports as availability allows, prioritize issues by exploitability and impact, and coordinate a fix or mitigation when the affected code is still maintained. For sample, archived, or educational repositories, the likely remediation may be documentation, dependency updates, or clearly marking unsupported code rather than a production-style patch release.
