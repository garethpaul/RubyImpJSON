# Invalid UTF-8 JSON String Design

Status: Completed

## Evidence

- The pure parser forces decoded string bytes to UTF-8 without checking
  `valid_encoding?`, and the native MRI parser similarly associates UTF-8
  after unescaping without validating the resulting byte sequence.
- `JSON.parse` currently accepts the six-byte input `5b 22 5c e5 22 5d` and
  returns a string labeled UTF-8 whose `valid_encoding?` result is false.
- JSONTestSuite commit `1ef36fa01286573e846ac449e8683f8833c5b26a`
  classifies this exact boundary as
  `test_parsing/n_string_invalid_utf8_after_escape.json`, meaning parsers
  should reject it. JSONTestSuite is MIT licensed.
- The JRuby `StringDecoder` already calls a validating UTF-8 decoder and throws
  a parser error for invalid or incomplete byte sequences.

## Considered Approaches

### Add only a reviewed fixture

This would document the defect but keep accepting invalid UTF-8, so it does not
provide security-regression value.

### Fix only the pure Ruby parser

This is easy to exercise in the canonical local gate, but the default native
MRI parser would retain the same invalid output.

### Validate decoded strings in both MRI implementations

Add one malformed fixture, reject broken UTF-8 after pure decoding, and reject
the same coderange in the native Ragel source and generated C file. Leave the
already-strict JRuby decoder unchanged. This preserves deliberate legacy escape
compatibility while preventing invalidly encoded Ruby strings.

## Decision

Use the cross-MRI validation approach. Raise `JSON::ParserError` before parsed
values enter arrays, objects, additions, or callers. Keep source and generated
native parser files synchronized and require exact fixture bytes in archive
metadata.

## Validation

- Add the fixture and watch the pure fixture suite fail because parsing
  succeeds.
- Make pure parsing reject the fixture and retain all existing fixtures.
- Build and test the native extension under the supported Ruby container.
- Compile the Java source gate to prove the already-validating JRuby path stays
  buildable.
- Run all Make aliases, package builds, archive contracts, hostile mutations,
  and exact-head hosted validation before merge.

The implemented design passed repository and external-directory `make check`;
the implementation plan records the complete red/green and platform evidence.
