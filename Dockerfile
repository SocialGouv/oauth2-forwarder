# renovate: datasource=docker depName=ubuntu versioning=ubuntu
ARG UBUNTU_VERSION=22.04

# renovate: datasource=node depName=node versioning=node
ARG NODE_VERSION=20.1.0

FROM ubuntu:$UBUNTU_VERSION as base
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
  curl \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

ARG NODE_VERSION
ARG NODE_PACKAGE=node-v$NODE_VERSION-linux-x64
ARG NODE_HOME=/opt/$NODE_PACKAGE

ENV NODE_PATH $NODE_HOME/lib/node_modules
ENV PATH $NODE_HOME/bin:$PATH

RUN curl https://nodejs.org/dist/v$NODE_VERSION/$NODE_PACKAGE.tar.gz | tar -xzC /opt/

RUN npm i -g yarn
RUN mkdir -p /yarn/cache
RUN chown -R 1001:1001 /yarn
ENV YARN_CACHE_FOLDER /yarn/cache

RUN groupadd -g 1001 ubuntu && useradd -rm -d /home/ubuntu -s /bin/bash -g ubuntu -G sudo -u 1001 ubuntu
ENV HOME=/home/ubuntu
RUN chmod 0777 /home/ubuntu

RUN mkdir -p /app && chown -R 1001:1001 /app
USER 1001
WORKDIR /app

COPY --chown=1001:1001 yarn.lock .yarnrc.yml ./
COPY --chown=1001:1001 .yarn .yarn
COPY --chown=1001:1001 . .
RUN yarn fetch workspaces focus --production && yarn cache clean

USER 1001

CMD ["node","index.js"]