# Dev Environment Exercise

## Background
The company you work for is building a micro-service based platform. They have completed their first sprint of work and are ready to begin preparing to ship it. Being a DevOps genius, you know that it will be difficult to reproduce bugs and increase  ownership if there's not an easy way to  reliably run these services locally as you would in production. At the same time, you want to get some automation that can be reused in production.

## Your Sprint Task
Your next task is to take the two recently built Python Flask APIs and meet the following requirements:

- Read the documentation for the two Python APIs and test them to make sure they work as expected.
- Once you understand their usage, use preferred tools and technology to create automation that stands up local dev environment of the stack, including its dependency (the mongodb database). _Don't worry too much about the nuances of data storage._
- You discuss with the engineers that in order for a micro-services architecture to work best, there will need to be some http routing in front of the services so that requests go to the right places. When the stack is deployed, accessing `/api/auth` should route to the *Auth Service* while `/api/data` should point to the *Data Service*. In other words, `/api/auth/token` should access the `/token` endpoint of the auth service, etc. Use technology and tools you know to implement this behavior.

*Bonus (Optional)*
- If you haven't already, create an efficient docker image based on best practices for at least one service. Be prepared to explain why it's efficient.

# Results: David Hayden, Nov. 2016

My development deployment approach is documented here. I chose to use
docker-compose, a Makefile and a couple helper scripts to implement and
automated local testing for the currently shipped microservices.

The following workstation tools are required. Workstation bootstrap is outside
the scope of this assignment, however, these recommendations could be used to
automate the preparation of a suitible workstation:

- docker 1.10.0 or higher
- docker-compose 1.8.1 or higher
- jq (used to parse json in test script)
- GNU Make (any modern version)

## How it works

To stand up the stack in a development environment, simply run `make`. To run a
complete test cycle run `make check`. The `curl-check.sh` script can be run on
its own once a stack is running.

The Makefile has several targets and defaults to `make populate-mongo`

A test directory has been created which contains two directories. `test/data`
contains dummy data and a helper script for importing that data into mangodb.
This directory is mounted as a volume at `/test/data` inside the mongodb container
and make runs `docker exec` to execute the script within the container. The
`populate-mongo.sh` script is idempotent, and will not attempt to import DB's
that already exist. This action is implemented in the target `make
populate-mongo`.

`test/conf` contains a default.conf file used by the nginx container. The
directory is simply mounted directly to `/etc/nginx/conf.d` and settings are
picked up automatically. This config implements proxy\_pass'ing to direct
traffic to the correct endpoints.

# Update: Nov. 4, 2016

A `Vagrantfile` has been added to facilitate testing on any machine equipped with
VirtualBox and vagrant. This is intended to enforce testing environment
consistency. It was found that the latest versions of docker and docker-compose
are not always intuitive to install on every system. The configuration could be
extended to become quite a bit more capable, for example:

- Test script could take arguments for host and port to test against ports
  exposed to the vagrant host (ie vagrant:80 -> host:8080, curl-check.sh could
  be run from the host as such this simple example: `bash ./curl-check localhost:8080`

- More advanced vagrant provisioning could be used to generate a complete
  development environment. For now it is not recommended to make modifications
  the project files from within the vagrant instance. My idea is to explore
  packer for such workstation creation.

Requirements:

 - VirtualBox (any recent version)
 - vagrant (any recent version)

Usage: 

From within the devops-exercise (project root) directory

`$ vagrant up`

`$ vagrant ssh`

`ubuntu@ubuntu-xenial:/devops/exercise$ make`

Wait for this to build. It may take some time before the services come up
completely. At this point you can run the curl-check.sh script directly, or you
can run `make check`. We're not storing curl-check.sh with the executable bit
on, so be sure to run it with bash: `/bin/bash ./curl-check.sh`

## Refactor of test script

The curl-check.sh script has been refactored to reduce code reuse. I ran into
some issues with how and when bash functions return results. While this test
script is sufficient for this exercise, it is not the ideal testing solution.
