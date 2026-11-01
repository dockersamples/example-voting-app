# Example Voting App

A simple distributed application running across multiple Docker containers.

## Getting started

Download [Docker Desktop](https://www.docker.com/products/docker-desktop) for Mac or Windows. [Docker Compose](https://docs.docker.com/compose) will be automatically installed. On Linux, make sure you have the latest version of [Compose](https://docs.docker.com/compose/install/).

This solution uses Python, Node.js, .NET, with Redis for messaging and Postgres for storage.

Run in this directory to build and run the app:

```shell
docker compose up
```

The `vote` app will be running at [http://localhost:8080](http://localhost:8080), and the `results` will be at [http://localhost:8081](http://localhost:8081).

Alternately, if you want to run it on a [Docker Swarm](https://docs.docker.com/engine/swarm/), first make sure you have a swarm. If you don't, run:

```shell
docker swarm init
```

Once you have your swarm, in this directory run:

```shell
docker stack deploy --compose-file docker-stack.yml vote
```

## Run the app in Kubernetes

The folder k8s-specifications contains the YAML specifications of the Voting App's services.

Run the following command to create the deployments and services. Note it will create these resources in your current namespace (`default` if you haven't changed it.)

```shell
kubectl create -f k8s-specifications/
```

The `vote` web app is then available on port 31000 on each host of the cluster, the `result` web app is available on port 31001.

To remove them, run:

```shell
kubectl delete -f k8s-specifications/
```

## Architecture

![Architecture diagram](architecture.excalidraw.png)

* A front-end web app in [Python](/vote) which lets you vote between two options
* A [Redis](https://hub.docker.com/_/redis/) which collects new votes
* A [.NET](/worker/) worker which consumes votes and stores them in…
* A [Postgres](https://hub.docker.com/_/postgres/) database backed by a Docker volume
* A [Node.js](/result) web app which shows the results of the voting in real time

## Notes

The voting application only accepts one vote per client browser. It does not register additional votes if a vote has already been submitted from a client.

This isn't an example of a properly architected perfectly designed distributed app... it's just a simple
example of the various types of pieces and languages you might see (queues, persistent data, etc), and how to
deal with them in Docker at a basic level.

###### Pros and Cons ###############
This is a very interesting architecture! It looks like a distributed voting application using microservices and asynchronous communication.

The architecture separates the voting interface, result interface, background processing, temporary storage, and permanent database storage.

I'll explain how it works, why someone would design it this way, and its advantages and disadvantages.

# 1. Understand the architecture

[Demo Example Voting Application - KodeKloud](https://images.openai.com/static-rsc-4/F43I5Mnw8VA-vqnhtkmSYc6C9xBp00H9PIL2jGNJs-erg_hdPZn6gl8Q58orLVOREQTgkmWZjtntNUWeZD0OCndZ6SVhwgO4ihKipQuljq4KDvMakj5kifY4ss8uX-uD_jQ944qNDqf7uKlOuynfhb3YwW1GfbXKE3DwOl4-rZk?purpose=inline)

[notes.kodekloud.com](https://notes.kodekloud.com/docs/Docker-SWARM-SERVICES-STACKS-Hands-on/Docker-Compose/Demo-Example-Voting-Application/page?utm_source=chatgpt.com)

Your diagram contains five major components:

| Component | Technology | Responsibility                     |
| --------- | ---------- | ---------------------------------- |
| Vote      | Python     | Accepts votes from users           |
| Result    | Node.js    | Displays voting results            |
| Worker    | .NET       | Processes votes asynchronously     |
| Redis     | Redis      | Temporarily stores incoming votes  |
| DB        | PostgreSQL | Permanently stores processed votes |

Let's follow a vote through the architecture.

# 2. How does the architecture work?

Imagine you're building an application where users vote for either Python or .NET.

Step 1: User submits a vote

The user opens the application and selects Python.

The Python application receives the request.

Step 2: Vote is stored in Redis

Instead of immediately writing the vote to PostgreSQL, the Python application places the vote into Redis.

Why?

Redis is an in-memory data store, which makes it very fast.

[Redis Logo PNG Vector (SVG) Free Download](https://images.openai.com/static-rsc-4/epIZvTJqrn11fZoyLAql3XQvzvr05WTs4k_hS-9tdnMQyi9Nak_EpGx1d16Qeud3z3mmGKrPzkfB8l4M10kTA8OEXwDm6CtTKKvBDOawlkZbKJwF8Jjm3IiHXcBUIohDPkufesDQyxMCNKXpFH79YSUkxtDVtdaR-HKvPqdpBXw?purpose=inline)

Redis

Example queue:

```
Vote Queue
----------------
1. Python
2. .NET
3. Python
4. Python
5. .NET
```

Fast temporary storage

Step 3: .NET Worker processes the votes

The .NET worker continuously checks Redis for new votes.

When it finds a vote:

1. Retrieves the vote from Redis.
2. Processes the vote.
3. Writes the vote into PostgreSQL.

This is called asynchronous processing.

The user doesn't need to wait for the database operation to finish before receiving an acknowledgement.

Step 4: PostgreSQL stores the results

PostgreSQL stores the votes permanently.

For example:

| Vote   | Count |
| ------ | ----- |
| Python | 3     |
| .NET   | 2     |

Step 5: Node.js displays the results

The Node.js application reads the results from PostgreSQL and displays them to the user.

Notice that the Result application doesn't need to communicate directly with the Vote application.

That is an important architectural decision.

# 3. Advantages (Pros)

Let's understand why developers might choose this architecture.

## A. Loose coupling

Major advantage

Each component has a specific responsibility.

For example:

- Python handles voting.
- Redis handles temporary vote storage.
- .NET processes votes.
- PostgreSQL stores permanent data.
- Node.js displays results.

Suppose you want to replace Python with Java.

You can potentially replace the Vote service without changing the entire application, provided the new service maintains the same Redis message contract.

This is called loose coupling.

## B. Better performance through asynchronous processing

Imagine 10,000 users submit votes simultaneously.

Without Redis:

```
User → Python → PostgreSQL
```

Every request attempts to write directly to the database.

This can create database pressure.

With Redis:

```
User → Python → Redis → .NET Worker → PostgreSQL
```

The application can accept votes quickly and process them at a controlled rate.

This helps absorb traffic spikes.

## C. Independent scalability

You can scale individual components independently.

For example:

| Component      | Scaling requirement                                  |
| -------------- | ---------------------------------------------------- |
| Python Vote    | More instances if incoming requests increase         |
| Redis          | Increase capacity or use a scalable Redis deployment |
| .NET Worker    | Add worker instances if the queue grows              |
| PostgreSQL     | Increase database resources or use read replicas     |
| Node.js Result | More instances if result-page traffic increases      |

This is one of the main advantages of microservices.

## D. Technology independence

You can use different programming languages for different services.

For example:

- Python for machine learning.
- .NET for business processing.
- Node.js for web applications.

Each service can use the technology best suited to its responsibility.

## E. Fault isolation

Suppose the Node.js Result application crashes.

The Python Vote application can potentially continue accepting votes.

Similarly, if the worker temporarily stops, votes can accumulate in Redis until processing resumes.

This improves resilience, assuming the queue is configured for appropriate durability.

# 4. Disadvantages (Cons)

This is where things become interesting from a software architecture and cloud engineering perspective.

## A. More infrastructure and operational complexity

Major disadvantage

Instead of deploying one application, you now have several components.

You must manage:

- Python application.
- Node.js application.
- .NET worker.
- Redis.
- PostgreSQL.
- Networking between components.
- Monitoring and logging.
- Deployment and configuration.

More components mean more things that can fail.

## B. Redis can become a single point of failure

Imagine Redis crashes before the worker processes the votes.

What happens to the votes?

That depends on how Redis is configured.

Redis is primarily an in-memory data store. Although it supports persistence, you must configure and test it appropriately.

You should understand:

- RDB snapshots.
- AOF (Append Only File).
- Redis replication.
- Redis Sentinel.
- Redis Cluster.
- Backup and recovery.

Important: Redis should not automatically be assumed to provide durable message delivery.

For a production application, you must consider what happens if Redis loses data.

## C. Eventual consistency

Important concept

Imagine you submit a vote for Python.

The following happens:

1. Vote is accepted by Python.
2. Vote is stored in Redis.
3. The Result application immediately queries PostgreSQL.
4. The .NET worker hasn't processed the vote yet.

The result page may still show the old count.

Why?

Because the database hasn't received the new vote yet.

This is called eventual consistency.

The data becomes consistent after the worker processes the pending votes.

This is an important concept in distributed systems.

## D. Worker failures and duplicate processing

Imagine the .NET worker:

1. Retrieves a vote from Redis.
2. Writes the vote to PostgreSQL.
3. Crashes before acknowledging/removing the message.

When the worker restarts, it might process the same vote again.

Now you could have duplicate votes.

You need to understand:

- Message acknowledgement.
- Retry mechanisms.
- Dead-letter queues.
- Idempotency.
- At-least-once delivery.
- At-most-once delivery.
- Exactly-once processing limitations.

A common solution is to give every vote a unique ID and enforce uniqueness in PostgreSQL.

## E. Database bottlenecks

Even though Redis can absorb incoming traffic, PostgreSQL eventually needs to process all those votes.

If the worker processes votes faster than PostgreSQL can accept them, or multiple workers compete for database resources, PostgreSQL can become a bottleneck.

You need database optimization, connection pooling, indexing, and potentially read replicas.

## F. More difficult debugging

Consider this scenario:

A user submits a vote, but the result doesn't update.

Where is the problem?

- Python?
- Redis?
- .NET worker?
- PostgreSQL?
- Node.js?

You need centralized logging, distributed tracing, metrics, and correlation IDs.

# 5. Summary: Pros vs. Cons

| Advantages              | Disadvantages                   |
| ----------------------- | ------------------------------- |
| Loose coupling          | More infrastructure             |
| Independent scalability | More operational complexity     |
| Fast vote acceptance    | Redis durability concerns       |
| Asynchronous processing | Eventual consistency            |
| Technology independence | Duplicate processing risks      |
| Fault isolation         | More difficult debugging        |
| Handles traffic spikes  | Additional infrastructure costs |

# 6. What I would improve in this architecture

If I were designing this for a production environment, I would consider the following improvements.

1\. Introduce a durable message broker

Consider Azure Service Bus instead of relying on a basic Redis queue.

[Microsoft - Azure - Servicebus - Messageidplugin 2 - Azure Service Bus Logo Clipart - Large Size Png Image - PikPng](https://images.openai.com/static-rsc-4/V2k_ClRvS-99LezhhM45Nke7UoIQvROD6rNGQYVqRRf4NgaoBrsxaweoIOO-aCWqeACjUjn8D6qO_KQ8wpOjKxv3udHIoi05ZMIXOViLr3uGGW1Kt4qkwL6roul3o4HBFr6bxmEYfLW0gzXY5JDYxu_1UGK9wYxMTYZt9GblG-8?purpose=inline)

Azure Service Bus

Message queues, dead-lettering, retries and delivery guarantees

2\. Add monitoring and observability

Use Azure Monitor and Application Insights to monitor all services.

[bigdoorsolutions](https://images.openai.com/static-rsc-4/oi8XM71RkZG4mH1SggRmK9eVEv49lTry-B24wwY8iXVBac8u2ZRNDIB_gghosJ9NzFhiWz_uG3GukkGsUL20LdBwlE09AvcCVpifsFL06grhKTZt63-bRSxZ3TUk--9nF5MGgMxV1Y48W9vPeFzqAf29CnjZ24Z6WOJD8ZYsI5M?purpose=inline)

Azure Monitor

3\. Secure service-to-service communication

Use managed identities where supported, secure secrets in Azure Key Vault, and restrict network access.

4\. Make vote processing idempotent

Ensure that processing the same vote twice does not result in duplicate records.

5\. Deploy using containers

Use Azure Container Apps or AKS depending on operational complexity and scaling requirements.

# 7. Important concepts to study for AZ-500 / Azure security

This architecture also gives you a practical way to learn several Azure security topics.

| Architecture component        | Azure topics to study                                                   |
| ----------------------------- | ----------------------------------------------------------------------- |
| Python / Node.js applications | App Service, Container Apps, managed identities                         |
| Redis                         | Azure Cache for Redis alternatives, network security, private endpoints |
| .NET Worker                   | Workload identities, container security                                 |
| PostgreSQL                    | Azure Database for PostgreSQL security, encryption, private access      |
| Communication                 | NSGs, VNets, Private Link                                               |
| Monitoring                    | Azure Monitor, Defender for Cloud                                       |
| Secrets                       | Azure Key Vault                                                         |
| Deployment                    | Azure RBAC, Microsoft Entra ID                                          |

# 8. Test your understanding

These are the kinds of questions I would expect you to understand after studying this architecture.

Architecture knowledge check

0/4

Q1. The .NET worker is temporarily unavailable. You want the Python application to continue accepting votes. Which architectural concept makes this possible?

Tight coupling

Asynchronous messaging

Direct database communication

Synchronous processing

Q2. A user submits a vote, but the result page doesn't immediately reflect it. What is this called?

Strong consistency

Eventual consistency

Data encryption

Horizontal scaling

Q3. The .NET worker crashes after saving a vote but before acknowledging the message. What risk exists?

Duplicate processing

Network encryption

Database replication

Authentication failure

Q4. You need to ensure that a worker can access Azure resources without storing credentials in application code. What should you use?

Hardcoded passwords

Managed identity

Public IP address

Redis password in source code

Check answers

My biggest takeaway: The most important concepts in this diagram are microservices, asynchronous messaging, message queues, eventual consistency, fault tolerance, and idempotency. These concepts are useful not only for Azure certification but also for real-world cloud architecture and system design. 

Good explanation

