# https://github.com/microsoft/vscode-dev-containers/tree/v0.224.2/containers/alpine/.devcontainer/base.Dockerfile
ARG VARIANT="3.15"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-alpine-${VARIANT}
RUN apk update && apk add --no-cache zola
