FROM python:3.10.2-alpine3.14

WORKDIR /app

RUN addgroup -S vote && adduser -S vote -G vote

COPY requirements.txt /app/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip pip install -r requirements.txt

COPY static .
COPY templates .
COPY app.py .

EXPOSE 80

USER vote:vote

CMD ["gunicorn", "app:app", "-b", "0.0.0.0:80", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]
