
FROM python:3.11-slim@sha256:cce12316475d7d56d605f76e1d811d0dc4e7227f2d4afd29951521264f504ff8 AS base

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd --system appgroup && \
    useradd --system --gid appgroup --home-dir /home/appuser \
    --create-home appuser

WORKDIR /usr/local/app

COPY requirements.txt ./requirements.txt
RUN python -m pip install --no-cache-dir --upgrade \
    wheel \
    jaraco.context && \
    python -m pip install --no-cache-dir -r requirements.txt

FROM base AS dev
RUN pip install watchdog
ENV FLASK_ENV=development
USER appuser
CMD ["python", "app.py"]

FROM base AS final
COPY --chown=appuser:appgroup . .
EXPOSE 80
USER appuser
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:80", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]
