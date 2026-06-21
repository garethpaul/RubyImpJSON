.DEFAULT_GOAL := check

.PHONY: build check java-check lint root-test test verify

override SHELL := /bin/sh
override .SHELLFLAGS := -c
override RUBY := ruby
override JAVAC := javac
ifneq ($(strip $(MAKEFILES)),)
$(error MAKEFILES must be empty; repository verification requires this Makefile to be loaded alone)
endif
override MAKEFILES :=
ifneq ($(origin MAKEFILE_LIST),file)
$(error MAKEFILE_LIST must not be overridden)
endif
override ROOT := $(shell path='$(subst ','"'"',$(MAKEFILE_LIST))'; path=$$(printf '%s' "$$path" | /bin/sed 's/^ //'); [ -f "$$path" ] || exit 1; directory=$$(/usr/bin/dirname -- "$$path"); CDPATH= cd -- "$$directory" && /bin/pwd -P)
export ROOT
ifeq ($(strip $(ROOT)),)
$(error repository Makefile path could not be resolved)
endif

lint:
	cd "$$ROOT" && $(RUBY) scripts/check_archive_metadata.rb

test:
	cd "$$ROOT" && env JSON=pure MAKE=make rake do_test_pure

build: lint
	cd "$$ROOT" && $(RUBY) scripts/test_gem_builds.rb

java-check:
	cd "$$ROOT" && JAVAC="$(JAVAC)" $(RUBY) scripts/check_java_sources.rb

root-test:
	"$$ROOT/scripts/test-makefile-root.sh"

verify: root-test lint test build

check: verify
