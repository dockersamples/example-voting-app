FROM node:18-slim AS base

# add curl for healthcheck
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    curl \
    tini \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package*.json ./

RUN npm ci \
 && npm cache clean --force \
 && mv /app/node_modules /node_modules

COPY . .

ENV PORT 80
EXPOSE 80


###################### DEVELOPMENT #######################
FROM base AS development

# have nodemon available for local dev use (file watching)
RUN npm install -g nodemon

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["nodemon", "server.js"]


###################### PRODUCTION #######################
FROM base AS production

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]