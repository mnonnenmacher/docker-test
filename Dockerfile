FROM eclipse-temurin:17.0.10_7-jdk-jammy

#ARG USERNAME=test
#ARG USER_ID=1000
#ARG USER_GID=$USER_ID
#ARG HOMEDIR=/home/test
#ENV HOME=$HOMEDIR
#ENV USER=$USERNAME

# Non privileged user
#RUN groupadd --gid $USER_GID $USERNAME \
#    && useradd \
#    --uid $USER_ID \
#    --gid $USER_GID \
#    --shell /bin/bash \
#    --home-dir $HOMEDIR \
#    --create-home $USERNAME

ARG RUST_VERSION=1.72.0

ENV RUST_HOME=/opt/rust
ENV CARGO_HOME=$RUST_HOME/cargo
ENV RUSTUP_HOME=$RUST_HOME/rustup
RUN curl -ksSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain $RUST_VERSION

ENV PATH=$PATH:$CARGO_HOME/bin:$RUSTUP_HOME/bin

ENTRYPOINT ["/bin/bash"]
