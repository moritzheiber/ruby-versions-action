#!/bin/sh

OUTPUT="$(/ruby-version-checker)"
VERSIONS="$(echo ${OUTPUT} | jq -Mjc '[.[].name]')"
CHECKSUMS="$(echo ${OUTPUT} | jq -Mjc '[.[] | .["ruby"] = .name | .["ruby_checksum"] = .sha256 | del(.name,.url,.sha256)]')"
export VERSIONS CHECKSUMS

echo "Versions: ${VERSIONS}"
echo "Checksums: ${CHECKSUMS}"

if [ -n "${GITHUB_OUTPUT}" ] ; then
    echo "checksums=${CHECKSUMS}" >> "${GITHUB_OUTPUT}"
    echo "versions=${VERSIONS}" >> "${GITHUB_OUTPUT}"
fi
