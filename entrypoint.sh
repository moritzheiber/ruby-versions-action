#!/bin/sh
set -eu

emit_output() {
    if [ -n "${GITHUB_OUTPUT:-}" ] ; then
        echo "${1}=${2}" >> "${GITHUB_OUTPUT}"
    fi
}

if [ -n "${RVA_REPOSITORY:-}" ] ; then
    # Container-registry mode: list Ruby release tags in the repository.
    set -- docker "${RVA_REPOSITORY}"
    if [ -n "${RVA_SUFFIXES:-}" ] ; then
        set -- "$@" --allow-suffix "${RVA_SUFFIXES}"
    fi
    if [ -n "${RVA_USERNAME:-}" ] && [ -n "${RVA_PASSWORD:-}" ] ; then
        export REGISTRY_USERNAME="${RVA_USERNAME}"
        export REGISTRY_PASSWORD="${RVA_PASSWORD}"
    fi

    OUTPUT="$(/ruby-version-checker "$@")"
    VERSIONS="$(echo "${OUTPUT}" | jq -Mjc '.')"

    echo "Versions: ${VERSIONS}"
    emit_output versions "${VERSIONS}"
else
    # ruby-lang.org mode: latest releases with URL and checksum metadata.
    VERSION_NAME="${RVA_VERSION_NAME:-version}"
    URL_NAME="${RVA_URL_NAME:-url}"
    CHECKSUM_NAME="${RVA_CHECKSUM_NAME:-checksum}"

    OUTPUT="$(/ruby-version-checker check)"
    VERSIONS="$(echo "${OUTPUT}" | jq -Mjc '[.[].name]')"
    METADATA="$(echo "${OUTPUT}" | jq -Mjc \
        --arg version_name "${VERSION_NAME}" \
        --arg url_name "${URL_NAME}" --arg checksum_name "${CHECKSUM_NAME}" '[.[] |
        if (has($version_name) | not) then (.[$version_name] = .name | del(.name)) else . end |
        if (has($url_name) | not) then (.[$url_name] = .url | del(.url)) else . end |
        if (has($checksum_name) | not) then (.[$checksum_name] = .sha256 | del(.sha256)) else . end
    ]')"

    echo "Versions: ${VERSIONS}"
    echo "Metadata: ${METADATA}"
    emit_output versions "${VERSIONS}"
    emit_output metadata "${METADATA}"
fi
