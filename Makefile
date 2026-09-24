GIT_COMMIT := $(shell git rev-parse HEAD)
GIT_COMMIT_SHORT := $(shell echo "$(GIT_COMMIT)" | head -c 7)

BUILD_NAME := ze2_build_$(GIT_COMMIT_SHORT).pk3
BUILD_PATH := $(abspath bin/$(BUILD_NAME))

.PHONY: build

build:
	rm -rf .build
	mkdir -p bin
	mkdir -p .build
	cp -r src/* .build/
	echo 'return "$(GIT_COMMIT)"' > .build/Lua/game/version.lua
	cd .build && zip -r9 "$(BUILD_PATH)" *
	rm -rf .build