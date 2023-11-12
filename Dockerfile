FROM ghcr.io/moritzheiber/ruby-version-checker:latest as source
FROM alpine:3.18

# hadolint ignore=DL3018
RUN apk --no-cache add jq

COPY --from=source /ruby-version-checker /ruby-version-checker
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
