ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
RUBY ?= ruby

.PHONY: build check lint test verify

lint:
	cd "$(ROOT)" && $(RUBY) scripts/check_archive_metadata.rb

test:
	cd "$(ROOT)" && env JSON=pure MAKE=make rake do_test_pure

build: lint
	cd "$(ROOT)" && $(RUBY) scripts/test_gem_builds.rb

verify: lint test build

check: verify
