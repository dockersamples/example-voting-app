# Define a base stage that uses the official python runtime base image
FROM python:3.11-slim AS base

# Add curl for healthcheck
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Set the application directory
WORKDIR /usr/local/app

# Install our requirements.txt
COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
RUN opentelemetry-bootstrap --action=install
# Define a stage specifically for development, where it'll watch for
# filesystem changes
FROM base AS final
RUN pip install watchdog
#CMD ["python", "app.py"]
COPY . .
EXPOSE 80
CMD ["/bin/bash", "-c", "opentelemetry-instrument --traces_exporter console,otlp --metrics_exporter console --service_name python_vote --exporter_otlp_endpoint http://141.148.199.176:4318 python app.py"]
# Define the final stage that will bundle the application for production
#FROM base AS final

# Copy our code from the current folder to the working directory inside the container
#COPY . .

# Make port 80 available for links and/or publish
#EXPOSE 80

# Define our command to be run when launching the container
#CMD ["gunicorn", "app:app", "-b", "0.0.0.0:80", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]
