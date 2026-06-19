# RubyImpJSON Deep Review Server Hardening Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

## Status: Completed

**Goal:** Consolidate PRs #1-#7 while preserving the archived demo and closing concrete request-routing and filesystem-disclosure gaps.

**Architecture:** Keep the existing loopback-only WEBrick server and stacked archive/package checks. Add a request callback that enforces canonical raw `/json` routing and common no-cache/security headers, plus WEBrick file callbacks that reject symlinks, non-regular files, and oversized static assets without replacing the historical demo architecture.

**Tech Stack:** Ruby 2.7-compatible WEBrick, test-unit, Net::HTTP/raw TCP regression tests, RubyGems packaging checks, Java 8/JRuby 1.7.27 compilation gate, GitHub Actions.

---

### Task 1: Canonical request-target regression coverage

**Files:**
- Modify: `tests/test_server.rb`

**Step 1: Write the failing test**

Add raw TCP requests for encoded, duplicate-slash, traversal, and NUL-bearing `/json` variants. Require 404 responses, non-JSON error bodies, and no counter mutation while preserving `/json?query`.

**Step 2: Run test to verify it fails**

Run: `JSON=pure ruby -Ilib tests/test_server.rb --name test_json_endpoint_rejects_noncanonical_request_targets`

Expected: FAIL because variants currently return JSON, the document root, or a 500 response.

### Task 2: Static file boundary regression coverage

**Files:**
- Modify: `tests/test_server.rb`

**Step 1: Write the failing tests**

Create temporary document roots containing an external-file symlink, an oversized regular file, and a normal asset. Require the symlink to be hidden, the oversized file to be rejected, and normal static responses to retain bounded framing and security headers.

**Step 2: Run tests to verify they fail**

Run: `JSON=pure ruby -Ilib tests/test_server.rb`

Expected: FAIL because WEBrick currently follows symlinks, serves unbounded files, and omits the shared response headers on static/error responses.

### Task 3: Minimal WEBrick boundary hardening

**Files:**
- Modify: `tools/server.rb`
- Modify: `tests/test_server.rb`
- Modify: `README.md`
- Modify: `SECURITY.md`

**Step 1: Implement canonical routing**

Extract the raw request target from `request_line`, permit only literal `/json` with an optional query, and reject encoded/normalized aliases before servlet dispatch.

**Step 2: Implement safe static callbacks**

Validate the document root, reject symlinked paths and non-regular files/directories, cap individual static responses, and preserve normal index/JavaScript serving.

**Step 3: Apply shared response headers**

Set no-store, nosniff, and no-referrer headers before dispatch so success and error responses use the same local-demo policy. Verify Content-Length matches actual response bytes.

**Step 4: Run focused tests**

Run: `JSON=pure ruby -Ilib tests/test_server.rb`

Expected: PASS.

### Task 4: Archive/package/runtime validation

**Files:**
- Modify only if a concrete validation defect is reproduced.

**Step 1: Run full Ruby checks**

Run: `make check`

Expected: 68+ tests pass, metadata passes, and all three gem packages build without repository artifacts.

**Step 2: Run external-directory checks**

Run the absolute server load and root Make targets from outside the checkout.

Expected: PASS with repository-relative library and Make resolution.

**Step 3: Run Java gate where feasible**

Run: `make java-check`

Expected: PASS only with Java 8 plus `jruby-jars 1.7.27`; otherwise record the local runtime limitation and rely on the exact hosted gate.

### Task 5: Mutations, credential scan, and landing

**Files:**
- Create temporary mutation copies outside the tracked tree only.

**Step 1: Run hostile mutations**

Disable each new route, symlink, size, and header guard independently and prove focused tests fail.

**Step 2: Scan credentials without outputting values**

Scan the current tree and all reachable history with redacted findings only.

**Step 3: Create one aggregate PR**

Push the reviewed PR #7 tip plus hardening commit to a new branch based on the stack tip, open a PR to `master`, wait for exact hosted checks, then squash-merge it. Close PRs #1-#7 only after confirming the merged tree contains their complete changes.

## Verification

- `JSON=pure ruby -Ilib tests/test_server.rb`
- `make check`
- External-directory `make check`
- Hosted Ruby 2.7, Java 8, and CodeQL gates on the aggregate PR and final default branch
