# [Choice] Node.js version: now using 24-LTS, using Alpine version for smaller footprint
FROM localhost:5000/node:24-bookworm-slim

ARG WORKDIR=/workspace
# make the arg available as env (optional)
ENV WORKDIR=${WORKDIR}

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV ENV="/root/.shrc" 
ENV SHELL="/bin/sh"

# create workspace used by devcontainer/docker-compose and VS Code extensions
RUN mkdir -p ${WORKDIR} /root/.vscode-server/extensions \
    && apt update && apt install -y git build-essential autoconf
RUN apt update && apt install -y automake libtool pkg-config curl
RUN apt update && apt install -y python3 g++ make openjdk-17-jdk
RUN apt update && apt install -y libssl-dev 

# Install npm typescript expo ngrok (global dev tools)
RUN curl -fsSL https://get.pnpm.io/install.sh | sh - && \
    && pnpm set-registry http://docker.host.internal:4873 \
    pnpm install -g npm@10.8.1 typescript@5.5.3 expo@54.0.25 @expo/ngrok@4.1.3

# patch fast_float in order to be able to compile watchman
RUN apt-get remove -y libfast-float-dev && \
    git clone https://github.com/fastfloat/fast_float.git /tmp/fast_float && \
    cd /tmp/fast_float && \
    cmake -B build -DCMAKE_BUILD_TYPE=Release && \
    cmake --build build -j$(nproc) && \
    cmake --install build && \
    cd ${WORKDIR} &&  rm -rf /tmp/fast_float

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    source $HOME/.cargo/env

RUN git clone https://github.com/facebook/watchman.git /tmp/watchman \
    && cd /tmp/watchman \
    && ./install-system-packages.sh \
    && ./autogen.sh \
    && mkdir -p /usr/local/{bin,lib} /usr/local/var/run/watchman \
    && cd built && cp bin/* /usr/local/bin && cp lib/* /usr/local/lib \
    && chmod 755 /usr/local/bin/watchman && chmod 2777 /usr/local/var/run/watchman \
    && cd ${WORKDIR} \
    && rm -rf /tmp/watchman
    
WORKDIR ${WORKDIR}

# Keep container running for development purposes
CMD ["tail", "-f", "/dev/null"]