# Organizator

## Table of Contents

- [Overview](#overview)
- [Building and Deployment](#building-and-deployment)
  - [Development Mode](#development-mode)
  - [Production Mode](#production-mode)

## Overview

Organizator is a simple Spring Boot microservices project with TypeScript React frontend to manage organizations.

[![Java](https://img.shields.io/badge/Java-%23ED8B00.svg?logo=openjdk&logoColor=white)](#)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-6DB33F?logo=springboot&logoColor=fff)](#)
[![Postgres](https://img.shields.io/badge/Postgres-%23316192.svg?logo=postgresql&logoColor=white)](#)
[![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?logo=typescript&logoColor=fff)](#)
[![React](https://img.shields.io/badge/React-%2320232a.svg?logo=react&logoColor=%2361DAFB)](#)
[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=fff)](#)

### Submodules

- [LobbyBoy](https://github.com/alldaygooning/organizator-lobby_boy) - Spring Boot microservice for everything user-realted
- [Organaut](https://github.com/alldaygooning/organizator-organaut) - Spring Boot microservice for everything organization-related
- [Webview](https://github.com/alldaygooning/organizator-webview) - TypeScript React frontend

## Building and Deployment

Project can operate in two fully-implemented modes: **Development Mode** and **Production Mode**.

### Environment

Both modes require certain environment variables to be set. List of these variables and their short descriptions could be found in [`.example.envrc`](.example.envrc). For environment variables management I recommend using [`direnv`](https://direnv.net/) utility.

### Development Mode

Use **Development Mode** for fully-containerized development proccess via [Docker Compose configuration](https://github.com/alldaygooning/organizator/blob/master/docker-compose.dev.yaml).

#### Application-wide startup

To run project in this mode execute in Organizator project's root directory:

```bash
docker compose -f docker-compose.dev.yaml up
```

This will automatically run `postgres_dev`, `nginx_dev`, `lobby_boy_dev`, `organaut_dev` and `webview_dev`.

#### Sprint Boot microservices startup

To use this mode, you would need to pull **my custom [`hotswapagent-runtime`](https://hub.docker.com/r/debi1/hotswapagent-runtime/tags)** base image:

```bash
docker pull debi1/hotswapagent-runtime:latest
```

This is done to ensure that [HotswapAgent](https://github.com/HotswapProjects/HotswapAgent) is working properly when running Spring Boot microservices.

If paths to your local LobbyBoy and Organaut projects root directories are set via [environment variables](#environment), `docker compose` will mount respective source folders to all Spring Boot containers. This removes the need for container rebuilds/restarts upon every code change. Finally, to run Spring Boot microservices containers execute following command for each:

```bash
docker compose -f docker-compose.dev.yaml exec <service_name> bash
```

This allows to execute commands _inside_ running containers. Inside the running container you can restart your application however many times you want via:

```bash
gradle debugRun
```

From your IDE of choice, connect to the running container's port ([set with environment variables](#environment)) to enable HotSwap features. Now almost any code changes will be reflected in the running application upon file save - no container restart/rebuild needed! If HotSwap does fail (happens occasionally), without container restart/rebuild kill running application inside the container however you like (`CTRL+C` works) and rerun with `gradle debugRun`.

#### Frontend startup

Just runs Vite's development server with network-exposed address. No specific requirements or configuration.

View your application at `http://localhost:${NGINX_PORT}`

### Production Mode

Use **Production Mode** for running in production (obviously).

Extremely simply, just execute:

```bash
docker compose -f docker-compose.prod.yaml up
```

and you will be able to view your application at `http://localhost:${NGINX_PORT}`
