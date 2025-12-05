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
RUN mkdir -p ${WORKDIR} /root/.vscode-server/extensions 

# Layer 1: heavy toolchains
RUN apt-get update && apt-get install -y --no-install-recommends \
    git build-essential g++ cmake \
    && rm -rf /var/lib/apt/lists/*

# Layer 2: compilers and large dev libs
RUN apt-get update && apt-get install -y --no-install-recommends \
    libboost-all-dev libclang-dev binutils-dev openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Layer 3: mid-size libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    libdouble-conversion-dev libdwarf-dev libevent-dev libfast-float-dev \
    && rm -rf /var/lib/apt/lists/*

# Layer 4: gflags/glog/gtest/gmock
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgflags-dev libgoogle-glog-dev libgtest-dev libgmock-dev \
    && rm -rf /var/lib/apt/lists/*

# Layer 5: compression libs
RUN apt-get update && apt-get install -y --no-install-recommends \
    liblz4-dev liblzma-dev libzstd-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Layer 6: crypto/network libs
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpcre2-dev libsnappy-dev libsodium-dev libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Layer 7: build helpers
RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf automake libtool pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Layer 8: misc utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ninja-build python3 python3-setuptools xxhash \
    && rm -rf /var/lib/apt/lists/*

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
    . $HOME/.cargo/env

RUN git clone https://github.com/facebook/watchman.git /tmp/watchman \
    && cd /tmp/watchman \
    && ./autogen.sh \
    && mkdir -p /usr/local/{bin,lib} /usr/local/var/run/watchman \
    && cd built && cp bin/* /usr/local/bin && cp lib/* /usr/local/lib \
    && chmod 755 /usr/local/bin/watchman && chmod 2777 /usr/local/var/run/watchman \
    && cd ${WORKDIR} \
    && rm -rf /tmp/watchman
    
WORKDIR ${WORKDIR}

# Keep container running for development purposes
CMD ["tail", "-f", "/dev/null"]