# Inception

A small web infrastructure built with **Docker Compose** as part of the 42 / 1337 *Inception* project.
It runs a **WordPress** site behind **NGINX** (HTTPS only), backed by a **MariaDB** database. Each service runs in its own container, built from a custom Dockerfile on `debian:bullseye`.

---

## Table of Contents

1. [Architecture](#architecture)
2. [Project Structure](#project-structure)
3. [Services](#services)
   - [NGINX](#nginx)
   - [WordPress + PHP-FPM](#wordpress--php-fpm)
   - [MariaDB](#mariadb)
4. [Networking](#networking)
5. [Volumes and Persistence](#volumes-and-persistence)
6. [Environment Variables](#environment-variables)
7. [Getting Started](#getting-started)
8. [Makefile Commands](#makefile-commands)
9. [Startup Flow](#startup-flow)
10. [Checking That It Works](#checking-that-it-works)
11. [Subject Rules Followed](#subject-rules-followed)

---

## Architecture

```
                 Browser
                    │
                    │  HTTPS (TLSv1.2 / TLSv1.3) — port 443
                    ▼
┌───────────────────────────────────────────────────────────────┐
│ Host                                                          │
│   ┌──────────────── inception-network (bridge) ────────────┐  │
│   │                                                        │  │
│   │  ┌─────────┐  FastCGI :9000  ┌───────────┐  SQL :3306  ┌─────────┐
│   │  │  nginx  │ ──────────────► │ wordpress │ ──────────► │ mariadb │
│   │  └────┬────┘                 └─────┬─────┘             └────┬────┘
│   │       │                            │                        │
│   └───────┼────────────────────────────┼────────────────────────┼──┘
│           │        volume "wp"         │                        │ volume "db"
│           └───────── /var/www/html ────┘                        │ /var/lib/mysql
│                         │                                       │
│        /home/abel-hid/data/wordpress        /home/abel-hid/data/mariadb
└───────────────────────────────────────────────────────────────┘
```

- **NGINX** is the only entry point. It is the only container that publishes a port (`443`).
- **WordPress** runs PHP-FPM only (no web server). NGINX forwards `.php` requests to it on port `9000`.
- **MariaDB** stores the WordPress database and is only reachable from inside the Docker network.

---

## Project Structure

```
inception/
├── Makefile                         # Build / run / clean commands
├── README.md
└── srcs/
    ├── .env                         # Credentials and configuration (not hard-coded in Dockerfiles)
    ├── docker-compose.yml           # Services, network and volumes
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/mysql.cnf       # MariaDB server config (listen on 0.0.0.0:3306)
        │   └── tools/mysql.sh       # First-run DB/user setup, then starts mysqld
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/nginx.conf      # HTTPS server block + FastCGI to wordpress:9000
        │   └── tools/nginx.sh       # Generates self-signed cert, then starts nginx
        └── wordpress/
            ├── Dockerfile
            ├── conf/www.conf        # PHP-FPM pool (listen on 9000)
            └── tools/wordpress.sh   # Installs WordPress with WP-CLI, then starts php-fpm
```

---

## Services

### NGINX

| | |
|---|---|
| Base image | `debian:bullseye` |
| Packages | `nginx`, `openssl` |
| Port | `443` (published to the host) |
| Volume | `wp` → `/var/www/html` (read the WordPress files) |

**[Dockerfile](srcs/requirements/nginx/Dockerfile)** installs NGINX and OpenSSL, copies the site config to `/etc/nginx/sites-enabled/default`, and runs `nginx.sh`.

**[nginx.sh](srcs/requirements/nginx/tools/nginx.sh)**
1. If no certificate exists yet, generates a **self-signed TLS certificate** (`/etc/nginx/ssl/nginx.crt` + `.key`, RSA 2048, valid 365 days, CN `abel-hid.42.fr`).
2. Starts NGINX in the foreground with `nginx -g "daemon off;"`, so it is the container's main process (PID 1).

**[nginx.conf](srcs/requirements/nginx/conf/nginx.conf)**
- `listen 443 ssl;` — HTTPS only, no port 80.
- `ssl_protocols TLSv1.2 TLSv1.3;` — older protocols are refused.
- `root /var/www/html;`, `index index.php;`
- Every `*.php` request is passed to `fastcgi_pass wordpress:9000;` (the WordPress container, resolved by Docker's internal DNS).

### WordPress + PHP-FPM

| | |
|---|---|
| Base image | `debian:bullseye` |
| Packages | `php7.4`, `php-fpm`, `php-mysqli`, `wget` |
| Port | `9000` (internal only) |
| Volume | `wp` → `/var/www/html` |

**[www.conf](srcs/requirements/wordpress/conf/www.conf)** configures the PHP-FPM pool to run as `www-data` and to `listen = 9000` on TCP (instead of the default Unix socket), so NGINX can reach it from another container.

**[wordpress.sh](srcs/requirements/wordpress/tools/wordpress.sh)**
1. Creates `/run/php/` (needed by PHP-FPM).
2. If `wp-config.php` does **not** exist (first run):
   - Downloads **WP-CLI** to `/usr/local/bin/wp`.
   - `wp core download` — downloads WordPress into `/var/www/html`.
   - `wp config create` — writes `wp-config.php` with the database name, user, password and host (`mariadb`).
   - `wp core install` — installs the site with the URL, title and **administrator** account.
   - `wp user create` — creates a second, **regular** user.
   - Fixes ownership (`www-data`) and permissions (`755` dirs / `644` files).
3. Starts PHP-FPM in the foreground: `php-fpm7.4 -F`.

On later starts, `wp-config.php` already exists in the volume, so setup is skipped and the existing site is served.

### MariaDB

| | |
|---|---|
| Base image | `debian:bullseye` |
| Packages | `mariadb-server` |
| Port | `3306` (internal only) |
| Volume | `db` → `/var/lib/mysql` |

**[mysql.cnf](srcs/requirements/mariadb/conf/mysql.cnf)** sets `bind-address = 0.0.0.0` so other containers on the network can connect (the default only allows `localhost`).

**[mysql.sh](srcs/requirements/mariadb/tools/mysql.sh)**
1. Creates `/run/mysqld` and gives `mysql` ownership of the runtime and data directories.
2. If the database directory `/var/lib/mysql/$DB_NAME` does **not** exist (first run):
   - Starts a temporary `mysqld` in the background.
   - Runs an SQL script that:
     - creates the database `$DB_NAME`,
     - creates the user `$DB_USER` (allowed from any host, `'%'`) with `$DB_PASSWORD`,
     - grants that user all privileges on the database,
     - sets the **root** password to `$MYSQL_ROOT_PASSWORD`.
   - Shuts the temporary server down with `mysqladmin`.
3. Starts `mysqld` in the foreground as the container's main process.

---

## Networking

```yaml
networks:
  inception-network:
    driver: bridge
```

All three containers join a single user-defined **bridge** network. Docker provides built-in DNS on it, so containers reach each other by service name:

- NGINX → `wordpress:9000`
- WordPress → `mariadb:3306`

No `network: host`, `links:` or `--link` is used. Only port `443` is exposed to the host.

---

## Volumes and Persistence

Two named volumes are bind-mounted to folders on the host, so data survives container rebuilds:

| Volume | Container path | Host path | Used by |
|---|---|---|---|
| `wp` | `/var/www/html` | `/home/abel-hid/data/wordpress` | wordpress, nginx |
| `db` | `/var/lib/mysql` | `/home/abel-hid/data/mariadb` | mariadb |

The host folders are created by `make init`. The `wp` volume is shared: WordPress writes the site files, and NGINX reads them to serve static files and to resolve which `.php` script to pass to PHP-FPM.

---

## Environment Variables

All credentials live in [srcs/.env](srcs/.env) and are loaded into every container with `env_file: .env`. Nothing secret is written in the Dockerfiles.

| Variable | Used by | Description |
|---|---|---|
| `DOMAIN_NAME` | — | Site domain (`abel-hid.42.fr`) |
| `MYSQL_HOSTNAME` | wordpress | Database host (`mariadb`) |
| `MYSQL_ROOT_PASSWORD` | mariadb | Password for the MariaDB `root` user |
| `DB_NAME` | mariadb, wordpress | WordPress database name |
| `DB_USER` | mariadb, wordpress | Database user for WordPress |
| `DB_PASSWORD` | mariadb, wordpress | Password for `DB_USER` |
| `WP_URL` | wordpress | Site URL (e.g. `https://abel-hid.42.fr`) |
| `WP_TITLE` | wordpress | Site title |
| `WP_ADMIN_LOGIN` / `WP_ADMIN_PASSWORD` / `WP_ADMIN_EMAIL` | wordpress | Administrator account (login must not contain `admin`) |
| `WP_USER_LOGIN` / `WP_USER_PASSWORD` / `WP_USER_EMAIL` | wordpress | Second, regular user |

`MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD` and `MYSQL_USER_EMAIL` are also defined but not used by the current scripts.

Example `.env`:

```env
DOMAIN_NAME=abel-hid.42.fr
MYSQL_HOSTNAME=mariadb
MYSQL_ROOT_PASSWORD=change_me

DB_NAME=wordpress
DB_USER=wpuser
DB_PASSWORD=change_me

WP_URL=https://abel-hid.42.fr
WP_TITLE=Inception
WP_ADMIN_LOGIN=boss
WP_ADMIN_PASSWORD=change_me
WP_ADMIN_EMAIL=boss@example.com

WP_USER_LOGIN=editor
WP_USER_PASSWORD=change_me
WP_USER_EMAIL=editor@example.com
```

---

## Getting Started

### Requirements

- A Linux virtual machine (required by the subject)
- Docker Engine and the Docker Compose plugin (`docker compose`)
- `make`
- `sudo` rights (to create folders in `/home/abel-hid/data`)

### 1. Point the domain to your machine

Add this line to `/etc/hosts`:

```
127.0.0.1   abel-hid.42.fr
```

### 2. Fill in `srcs/.env`

Set your own passwords (see [Environment Variables](#environment-variables)).

### 3. Build and run

```bash
make
```

### 4. Open the site

Go to **https://abel-hid.42.fr**. The browser will warn that the certificate is self-signed — accept it to continue.
The admin dashboard is at **https://abel-hid.42.fr/wp-admin**.

> To run on another machine or login, replace `abel-hid` in the `Makefile`, `docker-compose.yml` (volume paths), `nginx.conf` (`server_name`), `nginx.sh` (certificate CN) and `.env`.

---

## Makefile Commands

| Command | What it does |
|---|---|
| `make` / `make all` | Same as `make build` |
| `make init` | Creates the host data folders `/home/abel-hid/data/{wordpress,mariadb}` |
| `make build` | Runs `clean` and `init`, then `docker compose up --build` (fresh build from scratch) |
| `make up` | Starts the containers without rebuilding |
| `make down` | Stops and removes the containers (data is kept) |
| `make clean` | Removes containers, images and volumes, runs `docker system prune -af`, and **deletes `/home/abel-hid/data`** |
| `make re` | `clean` then `all` |

> ⚠️ `make`, `make build`, `make clean` and `make re` **delete all site and database data**, and `docker system prune -af` removes **every** unused Docker image on the machine, not just this project's. Use `make up` / `make down` to restart without losing data.

---

## Startup Flow

1. `docker compose` builds the three images from their Dockerfiles and creates the network and volumes.
2. **mariadb** starts. On first run it creates the database, the WordPress user and the root password, then runs `mysqld`.
3. **wordpress** starts. On first run it downloads WordPress, writes `wp-config.php`, installs the site, creates both users, then runs `php-fpm` on port 9000.
4. **nginx** starts, generates its TLS certificate if needed, and listens on port 443.
5. A request to `https://abel-hid.42.fr`:
   - static files (CSS, JS, images) are served directly by NGINX from the shared volume;
   - `.php` files are passed to PHP-FPM at `wordpress:9000`, which queries `mariadb:3306` and returns the HTML to NGINX.

All services use `restart: always`, so a crashed container is restarted automatically.

---

## Checking That It Works

```bash
# Running containers
docker ps

# Logs of one service
docker logs nginx
docker logs wordpress
docker logs mariadb

# Only TLS 1.2 / 1.3 are accepted
openssl s_client -connect abel-hid.42.fr:443 -tls1_2   # works
openssl s_client -connect abel-hid.42.fr:443 -tls1_1   # refused

# Port 80 is closed
curl http://abel-hid.42.fr                               # fails

# Database contents
docker exec -it mariadb mysql -u root -p
#   SHOW DATABASES;
#   USE <DB_NAME>;
#   SELECT user_login FROM wp_users;

# Data persists on the host
ls /home/abel-hid/data/wordpress /home/abel-hid/data/mariadb
```

---

## Subject Rules Followed

- ✅ One service per container, each built from its own Dockerfile.
- ✅ Images built from `debian:bullseye` (penultimate stable Debian); no ready-made images pulled and no `latest` tag.
- ✅ NGINX is the only entry point, on port 443 only, with TLSv1.2 / TLSv1.3.
- ✅ WordPress runs with PHP-FPM only, without NGINX inside its container.
- ✅ MariaDB runs without NGINX.
- ✅ Two volumes: one for the database, one for the WordPress files, stored in `/home/<login>/data`.
- ✅ A user-defined Docker network connects the containers; no `network: host`, `links` or `--link`.
- ✅ Containers restart automatically on crash (`restart: always`).
- ✅ Each container's main process runs in the foreground (`nginx -g "daemon off;"`, `php-fpm -F`, `mysqld`) — no `tail -f`, `sleep infinity` or `while true` hacks.
- ✅ Credentials come from `.env`, not from the Dockerfiles.
- ✅ Two WordPress users, one of them an administrator.
- ✅ Domain `abel-hid.42.fr` points to the local IP.
