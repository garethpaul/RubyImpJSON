# Local Server Access-Log Privacy

Status: Completed

## Context

The optional loopback-only WEBrick demo sent common, referrer, and user-agent
access logs to the same error stream used for server diagnostics. The accepted
`/json` endpoint permits query strings, so a local request could persist query
values plus caller-controlled referrer and user-agent metadata in terminal or
captured logs even though none of that data is needed by the archive demo.

## Priority

P2 local-demo privacy. Preserve useful WEBrick error diagnostics while
removing request metadata that the archived example does not need.

## Requirements

- Keep the server bound to IPv4 loopback.
- Keep WEBrick error logging available for startup and runtime diagnostics.
- Disable request access logs rather than attempting incomplete field-by-field
  redaction.
- Prove query values, referrers, and user-agent strings do not reach the log.
- Preserve `/json`, static-file, response-header, and archive parser behavior.

## Verification

- Run the focused executable regression in the digest-pinned Ruby 2.7 image.
- Reject mutations that restore common, referrer, or user-agent formats or
  remove the executable privacy regression.
- Run repository and external-directory `make check` in the pinned image.
- Require hosted archive and Java verification plus exact-head Codex review
  before merge.

## Risks

- This prevents routine access metadata from being persisted; unexpected
  WEBrick error messages may still contain operational context.
- The server remains an archived local demo, not a production service.

## Verification Completed

- The pre-fix pinned Ruby 2.7 focused regression failed after the query value
  appeared in the WEBrick access log.
- The pinned Ruby 2.7 focused regression passed after access logging was
  disabled, and all seven executable server tests passed.
- Four hostile access-log mutations were rejected: restored common logging,
  restored referrer logging, restored user-agent logging, and removal of the
  executable privacy regression.
- repository and external-directory `make check` passed in the digest-pinned
  Ruby 2.7 image.
- Hosted archive and Java gates plus exact-head Codex review remain required
  before merge.
