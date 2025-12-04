# [Choice] Node.js version: now using 24-LTS, using Alpine version for smaller footprint
FROM node:24-bookworm-slim

ARG WORKDIR=/workspace
# make the arg available as env (optional)
ENV WORKDIR=${WORKDIR}

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV ENV="/root/.shrc" 
ENV SHELL="/bin/sh"

# create workspace used by devcontainer/docker-compose and VS Code extensions
RUN mkdir -p ${WORKDIR} /root/.vscode-server/extensions \
    && apt update && apt install -y \
    git \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    curl \
    python3 \
    g++ \
    make \
    openjdk-17-jdk \
    rustc \
    cargo \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install npm typescript expo ngrok (global dev tools)
RUN curl -fsSL https://get.pnpm.io/install.sh | sh - && \
    pnpm install -g npm@10.8.1 typescript@5.5.3 expo@54.0.25 @expo/ngrok@4.1.3

RUN git clone https://github.com/facebook/watchman.git /tmp/watchman \
    && cd /tmp/watchman \
    && git checkout v2025.11.24.00 \ 
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && rm -rf /tmp/watchman
    
WORKDIR ${WORKDIR}

# Keep container running for development purposes
CMD ["tail", "-f", "/dev/null"]