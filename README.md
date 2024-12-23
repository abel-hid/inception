# Inception Project

## Overview
This project is a **System Administration** exercise designed to expand your understanding of Docker and its components. You'll be creating multiple Docker images for a small infrastructure setup on your virtual machine, which includes **NGINX**, **WordPress with php-fpm**, and **MariaDB**.

- **Version**: 3

---

## Table of Contents

1. [Preamble](#preamble)
2. [Introduction](#introduction)
3. [General Guidelines](#general-guidelines)
4. [Mandatory Part](#mandatory-part)
   1. [Infrastructure Overview](#infrastructure-overview)
   2. [Services Setup](#services-setup)
5. [Prohibited Practices](#prohibited-practices)
6. [Directory Structure](#directory-structure)

---

## Preamble
This section is reserved for additional introductory information or guidelines if needed.

---

## Introduction
The purpose of this project is to familiarize yourself with **Docker** and its related technologies. The goal is to create and configure a set of Docker containers for a fully functional web infrastructure. You'll be working with **NGINX**, **WordPress**, and **MariaDB**, leveraging **Docker Compose** for orchestration.

---

## General Guidelines

- **Virtual Machine**: The project must be completed within a Virtual Machine environment.
- **Configuration Files**: All configuration files (including Docker-related files) must be placed in the `srcs` folder for better organization.
- **Makefile**: The `Makefile` is required and must:
  - Set up and build your entire application.
  - Use `docker-compose.yml` to build the Docker images.
- **Documentation**: Make use of relevant Docker documentation to get familiar with Docker concepts.

---

## Mandatory Part

### Infrastructure Overview

You are required to set up a small infrastructure that includes the following components:

1. **Docker Containers**:
   - **NGINX**: Acts as a reverse proxy and must support TLSv1.2 or TLSv1.3 only.
   - **WordPress with php-fpm**: WordPress should be installed and configured independently, without direct NGINX integration.
   - **MariaDB**: Installed and configured for database management.

2. **Volumes**:
   - Ensure that the WordPress database and website files are stored in persistent volumes.

3. **Networking**:
   - Set up a Docker network to link the containers together.

### Services Setup

1. **Docker Compose**:
   - Use **Docker Compose** to orchestrate and manage the containers.
   - Each container must restart automatically if it crashes.
   - Each service must run in its own dedicated container.
   - The containers must be built using **Alpine** or **Debian** (penultimate stable version).
   - Write your own `Dockerfile` for each service to define their behavior.

2. **Environment Variables**:
   - Credentials and passwords must not be hard-coded in the `Dockerfiles`.
   - Use environment variables that are stored in a `.env` file to manage sensitive data like credentials.

3. **Domain Configuration**:
   - The domain name should point to your local IP (e.g., `<login>.42.fr`).

4. **NGINX Configuration**:
   - NGINX must act as the only entry point via **port 443**, using TLSv1.2 or TLSv1.3 encryption.

---

## Prohibited Practices

The following practices are **prohibited**:

- Using `network: host`, `--link`, or `links:` for container networking.
- Running containers with infinite loops such as `tail -f`, `bash`, `sleep infinity`, or `while true` in `CMD` or `ENTRYPOINT`.
- Using the `latest` Docker tag; always specify a stable version.

---

## Directory Structure

The directory structure for the project must follow this pattern:

```
$> ls -alR
./
├── Makefile
├── srcs/
│   ├── docker-compose.yml
│   ├── .env
│   ├── requirements/
│   │   ├── mariadb/
│   │   │   ├── tools/
│   │   │   │   ├── mysql.sh
│   │   │   ├── conf/
│   │   │   │   ├── mysql.cnf
│   │   │   ├── Dockerfile
│   │   ├── nginx/
│   │   │   ├── conf/
│   │   │   │   ├── nginx.conf
│   │   │   ├── tools/
│   │   │   │   ├── nginx.sh
│   │   │   ├── Dockerfile
│   │   └── wordpress/
│   │       ├── conf/
│   │       │   ├── www.conf
│   │       ├── tools/
│   │       │   ├── wordpress.sh
│   │       ├── Dockerfile

```