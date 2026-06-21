.DEFAULT_GOAL := check

.PHONY: build check java-check lint root-test test verify
.SECONDEXPANSION:

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
override ROOT := $(shell sed_path=/usr/bin/sed; [ -x "$$sed_path" ] || sed_path=/bin/sed; [ -x "$$sed_path" ] || exit 1; path=$$(printf '%s' '$(subst ','"'"',$(MAKEFILE_LIST))' | "$$sed_path" 's/^ //'); [ -f "$$path" ] || exit 1; directory=$${path%/*}; [ "$$directory" != "$$path" ] || directory=.; CDPATH= cd "$$directory" && pwd -P)
export ROOT
ifeq ($(strip $(ROOT)),)
$(error repository Makefile path could not be resolved)
endif

build check java-check lint root-test test verify: $$(if $$(filter file,$$(origin MAKEFILE_LIST)),,$$(error MAKEFILE_LIST must not be overridden))
build check java-check lint root-test test verify: $$(if $$(shell sed_path=/usr/bin/sed && [ -x "$$$$sed_path" ] || sed_path=/bin/sed && [ -x "$$$$sed_path" ] && path=$$$$(printf '%s' '$$(subst ','"'"',$$(MAKEFILE_LIST))' | "$$$$sed_path" 's/^ //') && [ -f "$$$$path" ] && printf '%s' ok),,$$(error repository Makefile must be loaded alone))

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
