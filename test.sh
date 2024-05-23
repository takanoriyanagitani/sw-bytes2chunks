#!/bin/sh

numcpus=8
jobs=$((${numcpus} - 1))

swift \
	test \
	--quiet \
	--parallel \
	--jobs ${jobs} ||
	echo NG
