# [Choice] Node.js version: now using 24-LTS, using Alpine version for smaller footprint
FROM node:24-alpine

# init for VS Code
RUN mkdir -p /root/workspace /root/.vscode-server/extensions 

# Install eslint typescript expo
RUN npm install -g npm@10.8.1 --loglevel verbose && \
    npm install -g eslint@8.57.0 typescript@5.5.3 @expo/ngrok@4.1.3 --loglevel verbose 
RUN npm install -g expo@54.0.25 --loglevel verbose
RUN node --version && npm --version

# Update apk repositories and install git
# --no-cache reduces the image size by not storing package index files
RUN apk update && apk add --no-cache git

# Keep container running for development purposes
CMD ["tail", "-f", "/dev/null"]