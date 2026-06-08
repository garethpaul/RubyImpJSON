.PHONY: lint test build verify

lint:
	ruby scripts/check_archive_metadata.rb

test:
	env JSON=pure MAKE=make rake do_test_pure

build: lint

verify: lint test build
