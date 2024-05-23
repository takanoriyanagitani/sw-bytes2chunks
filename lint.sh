#!/bin/sh

swift \
	package \
	plugin \
	swiftlint \
	--strict \
	--progress \
	Sources
