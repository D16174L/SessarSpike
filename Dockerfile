# [Choice] Node.js version: now using 24-LTS, using Alpine version for smaller footprint
FROM node:24-alpine

ARG WORKDIR=/workspace
# make the arg available as env (optional)
ENV WORKDIR=${WORKDIR}

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV ENV="/root/.shrc" 
ENV SHELL="/bin/sh"

# create workspace used by devcontainer/docker-compose and VS Code extensions
RUN mkdir -p ${WORKDIR} /root/.vscode-server/extensions && \
    apk update && apk add --no-cache git pnpm

# Install npm typescript expo ngrok (global dev tools)
RUN pnpm set registry http://host.docker.internal:4873 && \
    pnpm install -g npm@10.8.1 typescript@5.5.3 expo@54.0.25 @expo/ngrok@4.1.3
    
WORKDIR ${WORKDIR}

# Keep container running for development purposes
CMD ["tail", "-f", "/dev/null"]