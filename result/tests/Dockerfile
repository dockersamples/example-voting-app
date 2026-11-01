
FROM node:18-slim@sha256:f9ab18e354e6855ae56ef2b290dd225c1e51a564f87584b9bd21dd651838830e

# Install utilities required by the test script
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        bash \
        curl \
        bzip2 \
        libfontconfig1 \
        tini && \
    rm -rf /var/lib/apt/lists/*

# Install PhantomJS for browser-based testing
RUN npm install --global phantomjs-prebuilt

WORKDIR /app

# Copy the test files
COPY tests.sh render.js ./

# Create a non-root user and set file ownership
RUN groupadd --system appuser && \
    useradd --system --gid appuser --create-home appuser && \
    chown -R appuser:appuser /app && \
    chmod +x /app/tests.sh

USER appuser

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/app/tests.sh"]
