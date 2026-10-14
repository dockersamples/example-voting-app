# Same pinned image as vote: Python 3.9 is end of life, and this one is already cached
FROM python:3.11-slim@sha256:e88e9763f943ec1834f992a4b51e0f24500486803e8bc534e5767af9ea65f6ce

# add apache bench (ab) tool
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    apache2-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /seed

COPY . .

# create POST data files with ab friendly formats (runs as root at build time)
RUN python make-data.py

RUN useradd --system --uid 10001 --no-create-home --shell /usr/sbin/nologin app
USER 10001

CMD ["/seed/generate-votes.sh"]