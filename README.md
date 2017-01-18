Instavote
=========

Getting started
---------------

Download [Docker for Mac or Windows](https://www.docker.com).

Run in this directory:

    $ docker-compose up

The app will be running at [http://localhost:5000](http://localhost:5000), and the results will be at [http://localhost:5001](http://localhost:5001).

Architecture
-----

![Architecture diagram](images/architecture.png)

* A Python webapp which lets you vote between two options
* A Redis queue which collects new votes
* A .NET worker which consumes votes and stores them in…
* A Postgres database backed by a Docker volume
* A Node.js webapp which shows the results of the voting in real time




Perquisites:
Add your registry (Docker Hub, GCR etc.) credentials in the account admin. 

Let's add the 3 services:
Fork this repository to your own GitHub account. 
Create 3 services: *vote*, *result* and *worker*.
For each one use the corresponding yml file for your liking.


