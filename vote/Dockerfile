# base defines a base stage that uses the official python runtime base image

# Base image for the voting application

FROM python:3.11-slim@sha256:b7a9e5f6a93d6d4a31f129bbd4bdee69efccb6ded0fb230d78aafaf37af98377 AS base

# Install curl for the Compose health check
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/app

# Install Python dependencies
COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Development stage: preserve existing local workflow
FROM base AS dev
RUN pip install --no-cache-dir watchdog

# Create an unprivileged application user
RUN useradd --create-home --uid 10001 appuser

WORKDIR /usr/local/app
COPY --chown=appuser:appuser . .

USER appuser

ENV FLASK_ENV=development
CMD ["python", "app.py"]

# Production stage
FROM base AS final

# Create an unprivileged application user
RUN useradd --create-home --uid 10001 appuser

COPY --chown=appuser:appuser . .

USER appuser

EXPOSE 8080

CMD ["gunicorn", "app:app", "-b", "0.0.0.0:8080", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]
