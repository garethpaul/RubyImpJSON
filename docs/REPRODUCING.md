# Reproducing the Archive

RubyImpJSON preserves `json` 1.7.5 for historical inspection. It is not a
supported production package. The commands below are verification boundaries
rather than compatibility or security support claims.

## Pure-Ruby Archive Baseline

The maintained executable baseline is the `JSON=pure` suite on Ruby 2.7. The
hosted check uses this exact digest-pinned image:

```text
ruby:2.7@sha256:2347de892e419c7160fc21dec721d5952736909f8c3fbb7f84cb4a07aaf9ce7d
```

With Ruby 2.7 available locally, run:

```bash
make check
```

To reproduce the hosted runtime without installing Ruby on the host, run from
the repository root:

```bash
docker run --rm \
  --user "$(id -u):$(id -g)" \
  --env HOME=/tmp \
  -v "$PWD:/repo:ro" \
  -w /repo \
  ruby:2.7@sha256:2347de892e419c7160fc21dec721d5952736909f8c3fbb7f84cb4a07aaf9ce7d \
  make check
```

`make check` runs archive metadata validation, all 70 pure-Ruby tests, and the
temporary gem package build contract. The test task sets `JSON=pure`, so it
does not load the C extension. No project dependency installation is required
for this baseline because the pinned image already contains the needed Ruby,
Rake, and standard-library components.

The repository's historical `.travis.yml` lists Ruby 1.8, Ruby 1.9, Rubinius,
REE, JRuby, and ruby-head variants. That file is preserved evidence, not an
active support matrix. Only the digest-pinned Ruby 2.7 pure-Ruby path above is
currently enforced.

## Package Construction Is Not Runtime Proof

`make build` builds the native, pure-Ruby, and Java gem archives in a temporary
directory and validates their metadata and representative payloads. It does not
compile or load the native or JRuby extensions. A successful package build
therefore proves archive integrity, not runtime compatibility.

## Native C Extension

The native variant is an optional historical experiment, not a maintained
compatibility target. Attempting it requires Ruby development headers and a C
compiler compatible with the selected Ruby runtime.

The extension sources can be probed independently in a disposable checkout:

```bash
cd ext/json/ext/parser
ruby extconf.rb
make

cd ../generator
ruby extconf.rb
make
```

On the repository's pinned Ruby 2.7 image, the parser compiles but the generator
does not: it references historical C API details such as `rb_cFixnum`,
`rb_cBignum`, and the old `rb_str_new` call shape. Do not patch those archived
sources merely to make this experiment pass; a compatibility port would need a
separate, reviewed scope with runtime tests and provenance.

Because the native probe writes Makefiles and object files, run it only in a
temporary checkout and remove that checkout afterward.

## JRuby Sources

The maintained JRuby-related gate is source compilation against the historical
JRuby API. Install `jruby-jars 1.7.27`, select Java 8, and run:

```bash
make java-check
```

The gate compiles all twelve checked-in Java sources into a temporary directory
with Java 8 source and target compatibility. It does not execute the JRuby
extension runtime. It also does not build the historical jars or claim
compatibility with a currently supported JRuby release.

If Java 8 or the pinned JRuby API gem is unavailable locally, inspect the
`Java 8 archived source compilation` GitHub Actions job for the canonical
hosted reproduction. Do not substitute a newer JRuby API and describe the
result as equivalent.

## Interpreting Results

- A passing `make check` preserves the pure parser, generator, fixtures,
  example server, package manifests, and archive metadata on the pinned Ruby
  boundary.
- A passing `make java-check` proves the Java sources still compile against the
  pinned historical API; it does not prove JRuby runtime behavior.
- Native compilation failures on modern Ruby are expected compatibility
  findings, not regressions in the maintained pure-Ruby archive baseline.
- None of these results makes archived `json` 1.7.5 suitable for new
  production use; see `ARCHIVE_STATUS.md` and `SECURITY.md`.
