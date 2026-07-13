# Pinned to release that still has only a single sub-command
FROM ghcr.io/moritzheiber/ruby-version-checker@sha256:bc434b19f541bb26e866448ae33bc93b1288786eb477d5a35b4107721462b4b9 as source
FROM alpine:3.23

# hadolint ignore=DL3018
RUN apk --no-cache add jq

COPY --from=source /ruby-version-checker /ruby-version-checker
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
