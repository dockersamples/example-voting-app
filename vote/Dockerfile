FROM python:3.11-slim AS base
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/app

COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

FROM base AS dev
RUN pip install watchdog
ENV FLASK_ENV=development
CMD ["python", "app.py"]

FROM base AS final
COPY . .

RUN useradd --no-create-home --uid 10001 appuser
USER appuser

ENV PORT=8080
EXPOSE 8080
CMD ["sh", "-c", "exec gunicorn app:app -b 0.0.0.0:${PORT} --log-file - --access-logfile - --workers 4 --keep-alive 0"]
