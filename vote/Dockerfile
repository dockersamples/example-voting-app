
# base defines a base stage that uses the official python runtime base image
FROM python:3.11-slim AS base

# Add curl for healthcheck
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/app

COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# dev: hot reload for local development
FROM base AS dev
RUN pip install watchdog
ENV FLASK_ENV=development
CMD ["python", "app.py"]

# final: production image, runs as non-root
FROM base AS final

# Create an unprivileged user with no login shell
RUN useradd --uid 10001 --no-create-home --shell /usr/sbin/nologin appuser

# Copy the code, owned by the app user
COPY . .

USER 10001

# Non-root users cannot bind ports below 1024, so we use 8080
EXPOSE 8080

CMD ["gunicorn", "app:app", "-b", "0.0.0.0:8080", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]
