Example Voting App
==================

This is an example Docker app with multiple services. It is run with Docker Compose and uses Docker Networking to connect containers together.

More info at https://blog.docker.com/2015/11/docker-toolbox-compose/


Running
-------

Since this app makes use of Compose's experimental networking support, it must be started with:

    $ cd vote-apps/
    $ docker-compose --x-networking up -d

The app will be running on port 5000 on your Docker host, and the results will be on port 5001.
