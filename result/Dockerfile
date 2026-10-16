
FROM node:18-slim

# Install runtime utilities and create a dedicated non-root user
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl tini && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd --system app && \
    useradd --system --gid app --home-dir /home/app --create-home app

WORKDIR /usr/local/app

# Install nodemon for the development workflow
RUN npm install -g nodemon

COPY package*.json ./

RUN npm ci && \
    npm cache clean --force && \
    mv /usr/local/app/node_modules /node_modules

# Ensure the application files belong to the non-root user
COPY --chown=app:app . .

ENV PORT=80
EXPOSE 80

ENTRYPOINT ["/usr/bin/tini", "--"]

# Run the application without root privileges
USER app

CMD ["node", "server.js"]
