FROM node:18-slim@sha256:f9ab18e354e6855ae56ef2b290dd225c1e51a564f87584b9bd21dd651838830e

# Install runtime utilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl tini && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/app

# Install production dependencies
COPY package*.json ./
RUN npm ci --omit=dev && \
    npm cache clean --force && \
    mv /usr/local/app/node_modules /node_modules

# Copy application files
COPY . .

# Create a dedicated non-root user and set file ownership
RUN groupadd --system appuser && \
    useradd --system --gid appuser --home-dir /home/appuser \
    --create-home appuser && \
    chown -R appuser:appuser /usr/local/app

ENV PORT=80
EXPOSE 80

# Run as non-root
USER appuser

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
