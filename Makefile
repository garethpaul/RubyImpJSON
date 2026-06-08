.PHONY: build check lint test verify

lint:
	ruby scripts/check_archive_metadata.rb

test:
	env JSON=pure MAKE=make rake do_test_pure

build: lint

verify: lint test build

check: verify
