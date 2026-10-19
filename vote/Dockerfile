FROM python:3.12-slim AS base

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

RUN python -m pip install --no-cache-dir --upgrade pip setuptools wheel jaraco.context

WORKDIR /usr/local/app

COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

FROM base AS dev

RUN pip install --no-cache-dir watchdog==6.0.0
ENV FLASK_ENV=development
CMD ["python", "app.py"]

FROM base AS final

COPY . .

RUN useradd --create-home --uid 10001 voteuser && \
    chown -R voteuser:voteuser /usr/local/app

USER voteuser

EXPOSE 8080

CMD ["gunicorn", "app:app", "-b", "0.0.0.0:8080", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]
