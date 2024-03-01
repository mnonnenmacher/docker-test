FROM eclipse-temurin:17.0.10_7-jdk-jammy as base

# Create non privileged user
ARG USERNAME=test
ARG USER_ID=1000
ARG USER_GID=$USER_ID
ARG HOMEDIR=/home/test

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

USER $USER
WORKDIR $HOME

ENTRYPOINT ["/bin/bash"]

# Install Rust
FROM base AS rust-install

ARG RUST_VERSION=1.72.0

ENV RUST_HOME=/opt/rust
ENV CARGO_HOME=$RUST_HOME/cargo
ENV RUSTUP_HOME=$RUST_HOME/rustup
RUN curl -ksSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain $RUST_VERSION

# Copy Rust installation to scratch image
FROM scratch AS rust

COPY --from=rust-install $RUST_HOME $RUST_HOME

# Add installed tools to base image
FROM base AS final

# Add Rust
ENV RUST_HOME=/opt/rust
ENV CARGO_HOME=$RUST_HOME/cargo
ENV RUSTUP_HOME=$RUST_HOME/rustup
ENV PATH=$PATH:$CARGO_HOME/bin:$RUSTUP_HOME/bin
COPY --from=rust --chown=$USER:$USER $RUST_HOME $RUST_HOME
RUN chmod o+rwx $CARGO_HOME

ENTRYPOINT ["/bin/bash"]
