# docker-carbon-relay-ng

A Docker container for the fast carbon relay+aggregator with admin interfaces for making changes online (https://github.com/graphite-ng/carbon-relay-ng)

# Status

[![Build Status](https://travis-ci.org/bodsch/docker-carbon-relay-ng.svg?branch=1703-04)](https://travis-ci.org/bodsch/docker-carbon-relay-g)


# Build

Your can use the included Makefile.

To build the Container: `make build`

To remove the builded Docker Image: `make clean`

Starts the Container: `make run`

Starts the Container with Login Shell: `make shell`

Entering the Container: `make exec`

Stop (but **not kill**): `make stop`

History `make history`


# Docker Hub

You can find the Container also at  [DockerHub](https://hub.docker.com/r/bodsch/docker-carbon-relay-ng)

## get

    docker pull bodsch/docker-carbon-relay-ng


# supported Environment Vars

  - GRAPHITE_HOST  (default: `graphite`)
  - GRAPHITE_PORT  (default: `2003`)


# Ports

 - 2003
 - 2004
 - 8081

