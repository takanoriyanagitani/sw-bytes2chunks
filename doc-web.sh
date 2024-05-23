#!/bin/sh

docdir=./doc.d
port=52480

python3 \
	-m http.server \
	--bind 127.0.0.1 \
	--directory "${docdir}" \
	${port}
