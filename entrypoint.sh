#!/bin/sh

VERSION_NAME="${1:-version}"
URL_NAME="${2:-url}"
CHECKSUM_NAME="${3:-checksum}"

export VERSION_NAME URL_NAME CHECKSUM_NAME

OUTPUT="$(/ruby-version-checker)"
VERSIONS="$(echo ${OUTPUT} | jq -Mjc '[.[].name]')"
METADATA="$(echo ${OUTPUT} | jq -Mjc \
    --arg version_name ${VERSION_NAME} \
    --arg url_name ${URL_NAME} --arg checksum_name ${CHECKSUM_NAME} '[.[] |
    if (has($version_name) | not) then (.[$version_name] = .name | del(.name)) else . end |
    if (has($url_name) | not) then (.[$url_name] = .url | del(.url)) else . end |
    if (has($checksum_name) | not) then (.[$checksum_name] = .sha256 | del(.sha256)) else . end
]')"
export VERSIONS METADATA

echo "Versions: ${VERSIONS}"
echo "Metadata: ${METADATA}"

if [ -n "${GITHUB_OUTPUT}" ] ; then
    echo "versions=${VERSIONS}" >> "${GITHUB_OUTPUT}"
    echo "metadata=${METADATA}" >> "${GITHUB_OUTPUT}"
fi
