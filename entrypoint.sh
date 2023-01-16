#!/bin/sh

OUTPUT="$(/ruby-version-checker)"
VERSIONS="$(echo ${OUTPUT} | jq -Mjc '[.[].name]')"
CHECKSUMS="$(echo ${OUTPUT} | jq -Mjc '[.[] | .["ruby"] = .name | .["ruby_checksum"] = .sha256 | del(.name,.url,.sha256)]')"
export VERSIONS CHECKSUMS

if [ -n "${GITHUB_OUTPUT}" ] ; then
    echo "checksum=${CHECKSUMS}" >> "${GITHUB_OUTPUT}"
    echo "versions=${VERSIONS}" >> "${GITHUB_OUTPUT}"
fi
