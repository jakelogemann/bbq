FROM mcr.microsoft.com/vscode/devcontainers/rust:0-1
VOLUME [ "/workspace" ]
WORKDIR /workspace

ARG RUST_VERSION="stable"
ARG RUST_PROFILE="default"
RUN rustup toolchain install \
      --profile=${RUST_PROFILE} \
      --component=rls,rust-src,rust-analysis \
      ${RUST_VERSION} \
&&  rustup default ${RUST_VERSION}
