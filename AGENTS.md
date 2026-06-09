# AGENTS.md

## Repository purpose

`garethpaul/RubyImpJSON` is a Ruby project. The checked-in files describe a Ruby project with the structure summarized below.

## Project structure

- `Makefile` - repository verification targets
- `scripts` - baseline checks and helper scripts
- `docs` - plans, notes, and generated README assets
- `lib` - library source code
- `tests` - tests and fixtures
- `Gemfile` - Ruby dependency definition

## Development commands

- Install dependencies: `bundle install`
- Full baseline: `make check`
- Combined verification: `make verify`
- Lint/static checks: `make lint`
- Tests: `make test`
- Build: `make build`
- If a command above skips because a platform toolchain is missing, verify on a machine with that SDK before claiming platform behavior is tested.

## Coding conventions

- Language mix noted in the README: Ruby (35), Java (12), C/C++ headers (3), C (2), JavaScript (1).
- Use Bundler for Ruby dependency and test commands when available.

## Testing guidance

- Test-related files detected: `docs/plans/2026-06-09-gemspec-fixture-manifest.md`, `json-java.gemspec`, `json.gemspec`, `json_pure.gemspec`, `tests/`, `tests/test_json.rb`, `tests/test_json_addition.rb`, `tests/test_json_encoding.rb`, `tests/test_json_fixtures.rb`, `tests/test_json_generate.rb`
- Start with the narrowest relevant test or Make target, then run `make check` before handing off if the change is not documentation-only.
- Keep README verification notes in sync when commands, fixtures, or supported toolchains change.

## PR / change guidance

- Keep diffs focused on the requested repository and avoid unrelated modernization or formatting churn.
- Preserve public APIs, sample behavior, file formats, and documented environment variables unless the task explicitly changes them.
- Update tests, README notes, or docs/plans when behavior, security posture, or validation commands change.
- Call out skipped platform validation, legacy toolchain assumptions, and any risky files touched in the final summary.

## Safety and gotchas

- No required secret or credential file was identified in the repository scan. If you add integrations later, keep secrets out of git.
- See `ARCHIVE_STATUS.md` for the historical snapshot boundary and verification baseline.
- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `VISION.md` for project direction and contribution guardrails.
- See `docs/plans/2026-06-08-rubyimpjson-baseline.md` for the canonical archive verification baseline.
- See `docs/plans/2026-06-08-malformed-comment-fixture.md` for the malformed comment fixture update.

## Agent workflow

1. Inspect the README, Makefile, manifests, and the files directly related to the request.
2. Make the smallest source or docs change that satisfies the task; avoid generated, vendored, or local-environment files unless required.
3. Run the narrowest useful validation first, then `make check` or the documented package/platform gate when available.
4. If a required SDK, service credential, or external runtime is unavailable, record the skipped command and why.
5. Summarize changed files, commands run, and remaining risks or follow-up validation.
