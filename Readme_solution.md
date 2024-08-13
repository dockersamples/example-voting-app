# scenario 2 Production environment setup-

## Application Environments
### Development Environment:
Used by developers for local development and testing.
Isolated from other environments to avoid unintended interference.
### Staging Environment:
A near-identical setup to production used for integration testing and pre-release validation.
Useful for user acceptance testing (UAT) and ensuring that new features or fixes work as expected.
Also used to validate infrastructure changes before applying them to production.
### Production Environment:
The live environment where the application is available to end-users.
Must be highly reliable, secure, and performant.

## Separation:
### Virtual Private Cloud (VPC) and Subnets:
**Production Environment**: Should be in its own VPC with private and public subnets. Only the public-facing components like the front-end and results web apps should be in public subnets, while Redis, the .NET worker, and Postgres should be in private subnets.

**QA Staging Environment**: Should reside in a separate VPC to avoid any accidental cross-environment issues. If cost is a concern, it can share the same VPC but be isolated using separate subnets and security groups.

**Development Environment**: Typically isolated on local machines or within a cloud sandbox environment using its own set of subnets.

### Separate Clusters
**Development Cluster**:
A separate Kubernetes cluster dedicated to development.
Typically runs on lower-cost infrastructure, potentially with reduced resource limits.
Developers have more access to this environment for testing and debugging.

**QA (Staging) Cluster**:
A Kubernetes cluster that closely mirrors the production environment.
Used for integration testing, performance testing, and user acceptance testing (UAT).
Access is more restricted compared to development, ensuring that only finalized builds are tested.

**Production Cluster**:
A highly available and secure Kubernetes cluster running on production-grade infrastructure.
Access is tightly controlled with strict security policies.
Designed for high reliability, scalability, and performance.

###  Or Single Cluster with Separate Namespaces

- Use Kubernetes namespaces to logically separate environments within a single cluster.
- dev namespace: Contains resources (pods, services, etc.) related to the development environment.
- qa namespace: Used for staging/QA, mirroring the production setup.
- prod namespace: Reserved for production workloads.
- Resource quotas and network policies are applied to each namespace to manage resource usage and isolate traffic.

### Resource Separation and Isolation
**Resource Quotas and Limits**
- Set resource quotas in Kubernetes to control the amount of CPU, memory, and other resources that can be consumed by each environment.
- Apply resource limits to individual containers to prevent any single workload from consuming excessive resources.
##### Network Policies
- Implement network policies to restrict communication between namespaces.
- For example, allow the dev namespace to communicate only with certain external resources, while prod may have stricter controls.
- Ensure that the production namespace can only communicate with trusted internal services and external APIs necessary for operation.

### CICD Pipeline Segregation:

**Development Pipelines**: Triggered by commits to development branches, deploys to the development cluster or namespace.

**QA/Staging Pipelines**: Triggered by merges to the staging branch, deploys to the QA namespace or cluster after passing automated tests.

**Production Pipelines**: Triggered by merges to the main/master branch, deploys to production after rigorous testing and manual approval.

### Environment-Specific Configurations:

- Use environment-specific Kubernetes manifests or Helm values files.
- Store secrets and environment-specific configurations using Kubernetes Secrets and ConfigMaps, with different versions for dev, QA, and production

### Security and Access Control
**Role-Based Access Control (RBAC)**:
Define Kubernetes roles and role bindings to ensure that only authorized users and service accounts can access each environment.
Developers might have more privileges in the development environment, while access to production is tightly controlled.

**Image Registry Separation**:
Use different Docker registries or repository namespaces for storing images for each environment (e.g., dev, qa, prod).
Implement automated image scanning for vulnerabilities before deploying to QA and production.

### Monitoring and Logging
**Environment-Specific Monitoring**:

- Set up monitoring tools like Prometheus, Grafana, and ELK/EFK Stack in each environment to track environment-specific metrics and logs.
- Use labels or annotations to differentiate logs and metrics by environment.
##### Alerting:

- Configure environment-specific alerting rules. For example, production alerts may have a higher severity and different notification channels compared to development alerts.

### DNS and Ingress Management
**Ingress Controllers**:
- Deploy separate ingress controllers for each environment or use one with environment-specific configurations.
Use different domain names or subdomains for each environment:
Development: dev.yourapp.com
QA: qa.yourapp.com
Production: yourapp.com

**DNS Records**:
Manage DNS records to route traffic to the appropriate ingress controllers or services within each environment.

## CI/CD Tooling and Zero-Downtime Deployment
### Tooling Recommendation:
#### CI/CD Pipeline:

**GitHub Actions / GitLab CI / Jenkins or AWS Code Build and Pipeline**:
Integrates well with popular version control systems.
Supports containerized workflows, allowing for automated testing, building, and deployment of Docker images.
Provides flexibility with custom pipelines and plugins.

**Docker Hub / AWS ECR**:
For storing Docker images.
Ensures versioned, secure storage of container images.

## Zero-Downtime Deployment:

### Blue-Green Deployment:
- Maintains two production environments: "blue" and "green." At any time, only one serves live traffic.
New releases are deployed to the idle environment, tested, and then traffic is switched over if successful.
- In a blue-green deployment, two identical environments (blue and green) exist. One environment is live (e.g., blue), and the other is idle (e.g., green).
- Deploy the new version of the application to the idle environment.
- After thorough testing, switch the traffic to the new environment by updating the service or ingress configuration.
- If anything goes wrong, you can quickly switch back to the previous environment.

### Rolling Updates: 
- Incrementally updates instances of the application with the new version while keeping the old version running until the update is verified.
- Kubernetes natively supports rolling updates, which gradually replace old versions of Pods with new ones without taking the application offline.
- This ensures that at least some instances of your application are always available to serve traffic during the update process.

**How it Works**:

Kubernetes deploys new Pods with the updated application while keeping the old Pods running.
Traffic is gradually shifted from the old Pods to the new ones.
The process continues until all old Pods are replaced by the new ones.
Configuration:

Define maxUnavailable and maxSurge parameters in the deployment YAML:
maxUnavailable: The maximum number of Pods that can be unavailable during the update.
maxSurge: The maximum number of Pods that can be created above the desired number of Pods.


```strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 0
    maxSurge: 1
```

### Canary Deployment:

- Gradually roll out the new version of the application to a small subset of users while the majority continue using the previous version.
- Monitor the performance and behavior of the new version.
- If no issues arise, gradually increase the traffic to the new version until all traffic is directed to it.

## Additional Tooling for Production
### Observability:
#### Monitoring:
**Prometheus**: For collecting and storing metrics. Prometheus scrapes metrics from a Kubernetes cluster using its built-in discovery mechanisms and by querying endpoints that expose metrics in a format it can consume.

##### **1. Exposing Metrics in Kubernetes**
Metrics Endpoint:

- Applications running in Kubernetes must expose their metrics in a format that Prometheus can scrape, typically via an HTTP endpoint (e.g., /metrics).
- Popular libraries like Prometheus client libraries for various programming languages (Python, Go, Java, etc.) help in instrumenting your application to expose these metrics.
Kubernetes Components:

- Kubernetes itself exposes various metrics for cluster components like nodes, pods, and services. These are typically collected by Prometheus from the Kubelet, API Server, kube-state-metrics, and other system components.

##### **2. Prometheus Deployment in Kubernetes**
Prometheus Operator:

- Prometheus Operator is a Kubernetes operator that simplifies deploying and managing Prometheus instances within a Kubernetes cluster.
- It uses custom resources like ServiceMonitor and PodMonitor to define how Prometheus should scrape metrics from services and pods.

##### **3. Service Discovery**
Prometheus uses Kubernetes' native service discovery to find endpoints to scrape metrics from:

Kubernetes Service Discovery:

- Prometheus queries the Kubernetes API server to discover Pods, Nodes, and Endpoints.
- It uses labels and annotations to automatically discover and target applications that expose metrics.

**Configuring Service Discovery in Prometheus**:

- In the Prometheus configuration file (prometheus.yml), the kubernetes_sd_configs section is used to define how Prometheus discovers services, pods, and nodes.
- Example configuration for scraping services:
```
scrape_configs:
  - job_name: 'kubernetes-service-endpoints'
    kubernetes_sd_configs:
      - role: endpoints
    relabel_configs:
      - source_labels: [__meta_kubernetes_namespace]
        action: keep
        regex: monitoring
```        
##### **4. ServiceMonitors and PodMonitors**
ServiceMonitor:

- A custom resource that tells Prometheus to scrape a specific Kubernetes service.
- It specifies the namespace, label selectors, and ports to monitor.
- Example:
```
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: example-servicemonitor
  labels:
    team: frontend
spec:
  selector:
    matchLabels:
      app: my-app
  endpoints:
  - port: metrics
    interval: 30s
  namespaceSelector:
    matchNames:
    - default
```    
This instructs Prometheus to scrape metrics from services labeled with app: my-app in the default namespace.
PodMonitor:

Similar to ServiceMonitor but targets individual Pods directly, which is useful for applications that don't expose a Kubernetes Service.
Example:
yaml
```
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: example-podmonitor
  labels:
    team: backend
spec:
  selector:
    matchLabels:
      app: my-app
  podMetricsEndpoints:
  - port: metrics
    path: /metrics
  namespaceSelector:
    matchNames:
    - default
```
- This instructs Prometheus to scrape metrics directly from Pods labeled with app: my-app.

##### **6. Scraping Metrics**
Scrape Interval:

- Prometheus scrapes targets at a regular interval defined in the scrape_interval setting.
- The default is 30s, but it can be configured per job or globally.

**Metrics Collection**:

- Once targets are discovered, Prometheus sends HTTP GET requests to the /metrics endpoint of the application.
- The scraped metrics are then stored in Prometheus's time-series database.

##### **7. Monitoring System Metrics**
Node Exporter:
Prometheus can also scrape system-level metrics from Kubernetes nodes using exporters like Node Exporter.
kube-state-metrics provides detailed insights into the state of Kubernetes objects like deployments, nodes, and pods.

##### **8. Example of a Full Prometheus Configuration for Kubernetes**
```
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'kubernetes-apiservers'
    kubernetes_sd_configs:
      - role: endpoints
    relabel_configs:
      - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
        action: keep
        regex: default;kubernetes;https

  - job_name: 'kubernetes-nodes'
    kubernetes_sd_configs:
      - role: node
    relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
      - target_label: __address__
        replacement: $(__meta_kubernetes_node_name):9100
```
`This configuration defines how Prometheus discovers and scrapes metrics from Kubernetes components like the API server, nodes, and other services.`

**Grafana**: For visualizing metrics and creating dashboards. Grafana can use the metrics scraped from Prometheus to create visualizations and dashboards that provide insights into the general health and performance of your applications.

##### **1. Connecting Grafana to Prometheus**
Data Source Configuration:
- In Grafana, you first need to configure Prometheus as a data source.
- This is done by navigating to the Data Sources section in Grafana, selecting Prometheus, and providing the URL of the Prometheus server (e.g., http://prometheus-server:9090).

##### **2. Querying Prometheus Metrics**
PromQL Queries:
- Grafana uses Prometheus Query Language (PromQL) to query metrics from Prometheus.
- When creating visualizations, you define PromQL queries to extract specific metrics.
- For example, to monitor the CPU usage of a Kubernetes cluster, you might use a query like:
`promql`

`sum(rate(container_cpu_usage_seconds_total[5m])) by (namespace, pod)`

##### **3. Creating Visualizations**
Types of Visualizations:

- Grafana supports various visualization types, including:
- Graphs/Time Series: Plots metrics over time, useful for showing trends like CPU or memory usage.
- Single Stat: Displays a single value, often used for metrics like uptime or error rate.
- Heatmaps: Shows density of events or values over time.
- Gauge/Bar Gauge: Displays current value against a scale, useful for showing the status of a metric relative to a threshold.
- Tables: Presents metrics in a tabular format, useful for detailed views of multiple metrics.
- Building a Graph:

- Select Graph as the visualization type.
- Enter your PromQL query in the Query tab.
- Grafana will fetch the data from Prometheus and plot it on the graph.
- Customize the graph by setting the time range, choosing line styles, setting axes labels, and defining thresholds for coloring.

##### **4. Creating Dashboards**
Dashboards:

- Dashboards in Grafana are collections of multiple visualizations that provide a comprehensive view of application health.
- You can combine multiple graphs, gauges, and tables on a single dashboard to monitor different aspects of the application.

Dashboard Panels:

- Each visualization in Grafana is known as a panel.
- Panels can be resized, moved, and arranged on the dashboard to suit your monitoring needs.
- Example panels might include:
- CPU and Memory Usage: Time-series graphs showing resource usage over time.
- Error Rate: A single stat panel showing the current error rate of the application.
- Request Latency: A heatmap or graph showing the distribution of request latencies.

##### **5. Alerting in Grafana**
Alert Rules:

- Grafana allows you to create alerts based on Prometheus metrics.
- Alerts are configured on individual panels. If a certain condition is met (e.g., CPU usage exceeds 80%), Grafana can trigger an alert.

Alert Notifications:

- Grafana can send notifications via various channels, such as email, Slack, or PagerDuty.
- Alert rules can be configured with thresholds, and Grafana will regularly evaluate these conditions.

##### **6. Kubernetes Cluster Health**:

- A dashboard that includes panels for node resource usage, pod status, and network metrics.
- Queries might include:
`promql`
` sum(rate(container_cpu_usage_seconds_total[5m])) by (node)
`
`promql`
` sum(kube_pod_status_phase{phase="Running"}) by (namespace)
`

**Application Performance Monitoring**:

- Monitor application-specific metrics like request rates, error rates, and latency.
- Example query for request rate:
`promql`
` rate(http_requests_total[5m])
`
- Example query for error rate:
`promql`

`sum(rate(http_requests_total{status=~"5.."}[5m]))
`

**Logging**:
ELK/EFK Stack:
- Elasticsearch: For indexing logs.
- Logstash/Fluentd: For log aggregation.
- Kibana: For visualizing and querying logs.

Tracing:
Jaeger or OpenTelemetry: To trace requests across distributed services and identify bottlenecks or failures.

## Networking & DNS Management
Networking:
- VPC Configuration:
Use private subnets for all backend services (Redis, .NET worker, Postgres) and public subnets for the front-end and results web apps.
Utilize Network ACLs and Security Groups to control traffic between services.

Load Balancer:
- Application Load Balancer (ALB) / NGINX:
Routes incoming traffic to the correct containers.
Ensures that only the front-end and results web apps are exposed to the internet.

DNS Management:
- Route 53 (AWS) or Cloud DNS (GCP):
Manage DNS records, including A, CNAME, and TXT records, for routing traffic to the correct environment.
Configure domain names for the production and staging environments with appropriate subdomains (e.g., staging.yourapp.com and app.yourapp.com).

Networking Protection Rules:
Security Groups:
- Restrict inbound and outbound traffic based on IP ranges, ports, and protocols.
- Ensure that only the necessary ports are open (e.g., HTTP/HTTPS for web apps, Redis only accessible by the worker).
WAF (Web Application Firewall):
- Protects the front-end and results web apps from common web exploits like SQL injection and cross-site scripting (XSS).

### Mechanisms for Reliability and Scalability
Reliability:
- Auto-Scaling: Implement auto-scaling groups for containers running the front-end, worker, and results apps.
Scale based on CPU, memory usage, or custom metrics like the number of queued votes.
- Health Checks: Use container orchestrators (like Kubernetes) to perform regular health checks and restart unhealthy containers.

Scalability:
- Load Balancing:
Use an ALB to distribute traffic evenly across multiple instances of the front-end and results web apps.
- Database Replication:
Set up read replicas for the Postgres database to handle read-heavy operations (like viewing results).

### Alerting Tools

- Prometheus Alertmanager:
Set up alerting rules based on metrics (e.g., CPU usage, memory usage, request latency).
Sends alerts to channels like Slack, email, or SMS.
Custom Alerts:
Set up custom alerts for application-specific metrics like the number of failed vote submissions or database query failures.

- Notification Channels:
Integrate with tools like PagerDuty or servicenow for incident management or teams channel, ensuring that critical alerts are handled promptly.

- Escalation Policies:
Define escalation policies so that unresolved alerts are escalated to higher levels of support after a certain period.
