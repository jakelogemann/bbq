FROM ghcr.io/fnctl/alpine:latest
RUN apk add -u --no-cache zola git jq curl ca-certificates npm
RUN npm i -g @cloudflare/wrangler
ENTRYPOINT ["/usr/bin/zola"]
