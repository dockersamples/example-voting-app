FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Shared directory so all gunicorn workers report into one /metrics endpoint.
ENV PROMETHEUS_MULTIPROC_DIR=/tmp/prometheus
RUN mkdir -p /tmp/prometheus \
    && useradd --uid 10001 --no-create-home app \
    && chown -R app /tmp/prometheus

USER app
EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD python -c "import urllib.request,sys; urllib.request.urlopen('http://localhost:8080/healthz', timeout=2)" || exit 1
# Clear stale metric files from a previous run before starting gunicorn.
CMD ["sh", "-c", "rm -rf /tmp/prometheus/* && exec gunicorn app:app -c gunicorn.conf.py"]
