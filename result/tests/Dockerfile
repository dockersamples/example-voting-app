FROM node:22-bookworm-slim@sha256:c3de60bf2f9dd0ac6370e6117950ff62d6e339527e7472301c9c78a017978392 AS base

RUN apt-get update -qq && apt-get install -qy \ 
    ca-certificates \
    bzip2 \
    curl \
    libfontconfig \
    --no-install-recommends

RUN yarn global add phantomjs-prebuilt
WORKDIR /app
# Copy files with node ownership
COPY --chown=node:node . /app
RUN chmod +x /app/tests.sh
# Switch to non-root user to satisfy DS-0002
USER node

CMD ["/app/tests.sh"]
