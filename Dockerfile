# syntax=docker/dockerfile:1.4

ARG BOWER_VERSION=1.8.12
ARG NODEJS_VERSION=20.9.0
ARG NPM_VERSION=10.1.0
ARG PNPM_VERSION=8.10.3
ARG RUST_VERSION=1.72.0
ARG YARN_VERSION=1.22.19

ARG NVM_DIR=/opt/nvm
ARG RUST_HOME=/opt/rust
ARG CARGO_HOME=$RUST_HOME/cargo
ARG RUSTUP_HOME=$RUST_HOME/rustup

ARG USERNAME=test
ARG USER_ID=1000
ARG USER_GID=$USER_ID
ARG HOMEDIR=/home/test

FROM eclipse-temurin:17.0.10_7-jdk-jammy as base

# Create non privileged user
ARG USERNAME
ARG USER_ID
ARG USER_GID
ARG HOMEDIR

ENV HOME=$HOMEDIR
ENV USER=$USERNAME

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd \
      --uid $USER_ID \
      --gid $USER_GID \
      --shell /bin/bash \
      --home-dir $HOMEDIR \
      --create-home $USERNAME

RUN chgrp $USER /opt \
    && chmod g+wx /opt

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git

USER $USER
WORKDIR $HOME

ENTRYPOINT ["/bin/bash"]

# Install Node.js
FROM base AS nodejs

ARG BOWER_VERSION
ARG NODEJS_VERSION
ARG NVM_DIR

ENV PATH=$PATH:$NVM_DIR/versions/node/v$NODEJS_VERSION/bin

RUN git clone --depth 1 https://github.com/nvm-sh/nvm.git $NVM_DIR
RUN . $NVM_DIR/nvm.sh \
    && nvm install "$NODEJS_VERSION" \
    && nvm alias default "$NODEJS_VERSION" \
    && nvm use default

ARG NPM_VERSION
ARG PNPM_VERSION
ARG YARN_VERSION

RUN npm install --global npm@$NPM_VERSION bower@$BOWER_VERSION pnpm@$PNPM_VERSION yarn@$YARN_VERSION

# Install Rust
FROM base AS rust

ARG RUST_VERSION
ARG CARGO_HOME
ARG RUSTUP_HOME
RUN curl -ksSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain $RUST_VERSION

# Add installed tools to base image
FROM base AS final

# Add Node.js
ARG NODEJS_VERSION
ARG NVM_DIR
ENV PATH=$PATH:$NVM_DIR/versions/node/v$NODEJS_VERSION/bin
COPY --link --from=nodejs --chown=$USER_ID:$USER_GID $NVM_DIR $NVM_DIR

# Add Rust
ARG RUST_HOME
ARG CARGO_HOME
ARG RUSTUP_HOME
ENV CARGO_HOME=$CARGO_HOME
ENV RUSTUP_HOME=$RUSTUP_HOME
ENV PATH=$PATH:$CARGO_HOME/bin:$RUSTUP_HOME/bin
COPY --link --from=rust --chown=$USER_ID:$USER_GID $RUST_HOME $RUST_HOME
RUN chmod o+rwx $CARGO_HOME

ENTRYPOINT ["/bin/bash"]
