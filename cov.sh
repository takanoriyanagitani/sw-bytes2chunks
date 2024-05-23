#!/bin/sh

covdir=./cov.d

mkdir -p "${covdir}"

targets() {
	echo Bytes2ChunksPackageTests
}

covDarwin() {
	local name
	name=$1
	readonly name

	local prefix
	prefix="./.build/debug/${name}.xctest"
	readonly prefix

	swift \
		test \
		--quiet \
		--parallel \
		--enable-code-coverage \
		--jobs ${jobs} ||
		exec sh -c 'echo TEST FAILURE; exit 1'

	xcrun llvm-cov \
		export \
		-format=lcov \
		"${prefix}/Contents/MacOS/${name}" \
		-instr-profile ./.build/debug/codecov/default.profdata |
		cat >./cov.lcov

	xcrun llvm-cov \
		report \
		--ignore-filename-regex=.build \
		--summary-only \
		"${prefix}/Contents/MacOS/${name}" \
		-instr-profile ./.build/debug/codecov/default.profdata
}

covLinux() {
	local name
	name=$1
	readonly name

	local covl
	covl="${covdir}/${name}"
	readonly covl
	mkdir -p "${covl}"

	local prefix
	prefix="./.build/debug/${name}.xctest"
	readonly prefix

	swift \
		test \
		--quiet \
		--parallel \
		--enable-code-coverage \
		--jobs ${jobs} ||
		exec sh -c 'echo TEST FAILURE; exit 1'

	llvm-cov \
		export \
		-format=lcov \
		"${prefix}" \
		-instr-profile ./.build/debug/codecov/default.profdata |
		cat >./cov.lcov

	llvm-cov \
		show \
		--ignore-filename-regex='.build' \
		-format=html \
		"${prefix}" \
		-output-dir="${covl}" \
		-instr-profile ./.build/debug/codecov/default.profdata

	llvm-cov \
		report \
		--ignore-filename-regex='\.build/|Tests/' \
		--summary-only \
		"${prefix}" \
		-instr-profile ./.build/debug/codecov/default.profdata
}

numcpus=8
jobs=$((${numcpus} - 1))

targets | while read line; do
	case $(uname -o) in
	GNU/Linux)
		covLinux "${line}"
		;;
	Darwin)
		covDarwin "${line}"
		;;
	*)
		echo 'unknown os: '$(uname -o)
		exit 1
		;;
	esac
done
