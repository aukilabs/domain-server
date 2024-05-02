# Domain Server
## Operation Mode
- Public: anyone can save data to your server. Auki Labs is running one at https://domain-server.posemesh.org. You can find all the other servers run by the community from the Posemesh Console's `Domain Servers` page.
- Private: only people from your organization can save their data to your server, but anyone will be able to read.

## Create Server
1. Log into the Posemesh Console at https://console.posemesh.org/
2. Open the `Domain Servers` page and create a server. `Redirect URL` is optional; it's the URL you want to redirect users to when they scan a portal using a non-Posemesh SDK app. This value can be overwritten by specifying redirect URLs for domains hosted by this domain server or for portals within the domains. If empty, https://aukilabs.com will be used by default.
3. Make sure you have copied the registration credentials. You will need them for the domain server configuration.

# Deployment

- [Docker Compose](#docker-compose)
- [Binary](#binary)
- [Docker](#docker)

## Docker Compose

Since domain server needs to be exposed with an HTTPS address and domain server itself doesn't terminate HTTPS, instead of using the pure Docker setup as described above, we recommend you to use our Docker Compose file that sets up an `nginx-proxy` container that terminates HTTPS and a `letsencrypt` container that obtains a free Let's Encrypt SSL certificate alongside domain server.

1. Configure your domain name to point to your externally exposed public IP address and configure any firewalls and port forwarding rules to allow incoming traffic to ports 80 and 443.
2. Download the latest Docker Compose YAML file from [GitHub](https://github.com/aukilabs/domains/blob/main/docker-compose.yml).
3. Set DS_REGISTRATION_CREDENTIALS to the one you copied from the Posemesh Console.
4. Configure other environment variables to your liking (you must at least set `VIRTUAL_HOST`, `LETSENCRYPT_HOST` and `DS_PUBLIC_URL`, set these to the domain name you configured in step 1).
4. With the YAML file in the same folder, start the containers using Docker Compose: `docker-compose up -d`

Just as with the pure Docker setup, we recommend you configure Docker to start automatically with your operating system. If you use our standard Docker Compose YAML file, the containers will start automatically after the Docker daemon has started.

### Host domain server and hagall under the same domain name
1. Change `example.com` to your domain name in `docker-compose-allinone.yml`, trailing slash is essential in HAGALL_PUBLIC_ENDPOINT.
2. If you have Hagall running using this [docker-compose file](https://github.com/aukilabs/hagall/blob/main/docker-compose.yml), make sure to stop your Hagall server first, e.g. `docker compose -f hagall-docker-compose-file-path.yaml down`, in order to release port 443 and 80.
3. Run `docker compose -f docker-compose-allinone.yml up -d` to start the Hagall server and domain server under the same domain. Hagall is hosted at `https://your-domain-name/hagall/` and domain server is at `https://your-domain-name/domains/`
4. You will always need to specify `-f docker-compose-allinone.yml` when you run any docker compose command like `up`, `pull`, `down` and `stop`.

### Upgrading

You can do the same steps as for Docker, but if you're not already running domain server or you have modified the `docker-compose.yml` file recently and want to deploy the changes, you can navigate to the folder where you have your `docker-compose.yml` file and then run `docker-compose pull` followed by `docker-compose down` and `docker-compose up -d`.

Note that the `docker-compose pull` command will also upgrade the other containers defined in `docker-compose.yml` such as the nginx proxy and the Let's Encrypt helper.

## Binary

> **_NOTE:_** If you choose to use this deployment method, you need to set up your own HTTPS web server or reverse proxy with an SSL certificate. Domain server listens for incoming connections on port 4000 by default, but this is changeable, see the configuration options above.

### Currently supported platforms

We build pre-compiled binaries for these operating systems and architectures:

- Windows x86, x86_64
- macOS x86_64, ARM64 (Apple Silicon)
- Linux x86, x86_64, ARM, ARM64
- FreeBSD x86, x86_64
- Solaris x86_64

> **_NOTE:_** Auki Labs doesn't test all of these platforms actively. Windows, FreeBSD and Solaris builds are currently experimental. We don't guarantee that everything works but feel free to reach out with your test results.

1. Download the latest domain server from [GitHub](https://github.com/aukilabs/domains/releases).
2. Run it with `./ds --public-url=https://domains.example.com --registration-credentials=xxx`
3. Expose it using your own reverse proxy with an SSL certificate.

We recommend you use a daemon manager such as systemd, launchd, SysV Init, runit or Supervisord, to make sure domain server stays running at all times.

## Docker

Domain server is available on [Docker Hub](https://hub.docker.com/r/aukilabs/domain-server).

Here's an example of how to run it:

You need Postgres 14 to start a domain server. Check PostgreSQL [official website](https://www.postgresql.org/download/) or [Docker Hub Repository](https://hub.docker.com/_/postgres). Create a database that domain server can connect to.

```shell
docker run --name=domains --restart=unless-stopped --detach \
-e DS_PUBLIC_URL=https://domains.example.com \
-e DS_REGISTRATION_CREDENTIALS=xxx \
-e DS_POSTGRES_URL=postgres://pg_user:pg_password@pg_host:pg_port/db_name?sslmode=disable \
-p 4000:4000 aukilabs/domain-server:stable
```

We also recommend you to configure Docker to start automatically with your operating system. Using `--restart=unless-stopped` in your `docker run` command will start domain server automatically after the Docker daemon has started.

### Supported tags

_See the full list on [Docker Hub](https://hub.docker.com/r/aukilabs/domain-server)._

- `latest` (bleeding edge, not recommended)
- `stable` (latest stable version, recommended)
- `v0` (specific major version)
- `v0.5` (specific minor version)
- `v0.5.0` (specific patch version)

### Upgrading

If you're using a non-version specific tag (`stable` or `latest`) or if the version tag you use matches the new version of domain server you want to upgrade to, simply run `docker pull aukilabs/domain-server:stable` (where `stable` is the tag you use) and then restart your container with `docker restart domain-server` (if `domain-server` is the name of your container).

If you're using a version-specific tag and the new version of domain server you want to upgrade to doesn't match the tag you use, you need to first change the tag you use and then restart your container. (`v0` matches any v0.x.x version, `v0.5` matches any v0.5.x version, and so on.)
