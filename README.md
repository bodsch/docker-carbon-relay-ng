# docker-carbon-relay-ng

A Docker container for the fast carbon relay+aggregator with admin interfaces for making changes online (https://github.com/graphite-ng/carbon-relay-ng)

# Status

[![Docker Pulls](https://img.shields.io/docker/pulls/bodsch/docker-carbon-relay-ng.svg?branch=1705-01)][hub]
[![Image Size](https://images.microbadger.com/badges/image/bodsch/docker-carbon-relay-ng.svg?branch=1705-01)][microbadger]
[![Build Status](https://travis-ci.org/bodsch/docker-carbon-relay-ng.svg?branch=1705-01)][travis]

[hub]: https://hub.docker.com/r/bodsch/docker-carbon-relay-ng/
[microbadger]: https://microbadger.com/images/bodsch/docker-carbon-relay-ng
[travis]: https://travis-ci.org/bodsch/docker-carbon-relay-ng


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

