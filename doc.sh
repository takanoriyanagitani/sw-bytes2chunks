#!/bin/sh

targets() {
	echo Bytes2Chunks
}

numcpus=8
jobs=$((${numcpus} - 1))

docdir=./doc.d
mkdir -p "${docdir}"

targets | while read line; do
	dirname="${docdir}/${line}"
	mkdir -p "${dirname}"

	swift \
		package \
		--jobs ${jobs} \
		--allow-writing-to-directory "${docdir}" \
		generate-documentation \
		--output-path "${docdir}/${line}" \
		--hosting-base-path "${line}" \
		--product ${line}
done
