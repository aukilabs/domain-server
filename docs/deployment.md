# Deployment

## Create Server
1. Log into the Posemesh Console at https://console.auki.network/
2. Open the `Domain Servers` page and create a server. 
3. Set the operation mode of the domain server. `Redirect URL` is optional; it's the URL you want to redirect users to when they scan a portal using a non-Posemesh SDK app. This value can be overwritten by specifying redirect URLs for domains hosted by this domain server or for portals within the domains. If empty, https://aukilabs.com will be used by default.
4. Make sure you have copied the registration credentials. You will need them for the domain server configuration.
5. On the Staking page, connect your wallet and stake the correct amount of $AUKI tokens based on your intended operation mode (dedicated or public).

## Storage Options
Domain Server supports two types of domain data storage backends:

* **Local filesystem** (default)
* **S3-compatible object/blob storage**

When using **S3 storage**, the domain server becomes **horizontally scalable** — multiple instances can be deployed concurrently to handle more traffic and increase fault tolerance, since the domain data is no longer bound to a single machine's disk.

To enable S3 storage, set the following environment variables:

```env
DS_STORAGE_TYPE=s3
DS_STORAGE_S3_BUCKET=your-bucket-name
DS_STORAGE_S3_REGION=your-region
DS_STORAGE_S3_ACCESS_KEY=your-access-key
DS_STORAGE_S3_SECRET_KEY=your-secret-key
DS_STORAGE_S3_BASE_ENDPOINT=https://s3.your-region.amazonaws.com
```

For more information on the S3 storage configuration, see [AWS SDK Configuration](https://docs.aws.amazon.com/sdk-for-go/v2/developer-guide/configure-gosdk.html) and [S3 Reference Guide](https://docs.aws.amazon.com/general/latest/gr/s3.html).

You can switch between local and S3 backends at any time.

> ✅ A **migration utility** is provided to **copy data from local filesystem to S3** (or the other way around). See [Storage Migration](#storage-migration) below.

## Deployment Methods

- [Docker Compose](#docker-compose)
- [Binary](#binary)
- [Docker](#docker)
- [Kubernetes](#kubernetes)

### Docker Compose

Since the domain server needs to be exposed with an HTTPS address and the domain server itself doesn't terminate HTTPS, instead of using the pure Docker setup as described below, we recommend you to use our Docker Compose file that sets up an `nginx-proxy` container that terminates HTTPS and a `letsencrypt` container that obtains a free Let's Encrypt SSL certificate alongside the domain server.

1. Configure your domain name to point to your externally exposed public IP address and configure any firewalls and port forwarding rules to allow incoming traffic to ports 80 and 443.
2. Clone or [download](https://github.com/aukilabs/domain-server/archive/refs/heads/main.zip) this repository or download the Docker Compose YAML [file](https://raw.githubusercontent.com/aukilabs/domain-server/main/docker-compose.yml) and [`client_max_body_size.conf`](https://raw.githubusercontent.com/aukilabs/domain-server/main/client_max_body_size.conf) separately.
3. Modify `docker-compose.yml` to set `DS_REGISTRATION_CREDENTIALS` to the credentials you copied from the Posemesh Console.
4. Change the `POSTGRES_PASSWORD` and `DS_POSTGRES_URL` environment variables to use a random password of at least 24 characters. If you want to know how to generate a random password, you can check out the [Generating random passwords](#generating-random-passwords) section. The password must be the same in both environment variables so the domain server can authenticate with PostgreSQL.
5. Configure other environment variables to your liking (you must at least set `VIRTUAL_HOST`, `LETSENCRYPT_HOST` and `DS_PUBLIC_URL`, set these to the domain name you configured in step 1).
6. Configure the wallet private key to use. See [Configuration](docs/configuration.md).
7. With the YAML file in the same folder, start the containers using Docker Compose: `docker compose up -d`

Just as with the pure Docker setup, we recommend you configure Docker to start automatically with your operating system. If you use our standard Docker Compose YAML file, the containers will start automatically after the Docker daemon has started.

#### Host a Domain and Relay (Hagall) server under the same domain name
1. Change `example.com` to your domain name in `docker-compose-allinone.yml`, trailing slash is essential in `HAGALL_PUBLIC_ENDPOINT`.
2. If you have Hagall running using this [docker-compose file](https://github.com/aukilabs/hagall/blob/main/docker-compose.yml), make sure to stop your Hagall server first, e.g. `docker compose down`, in order to release port 443 and 80.
3. Run `docker compose -f docker-compose-allinone.yml up -d` to start Hagall and the domain server under the same domain. Hagall will be hosted at `https://your-domain-name/hagall/` and the domain server at `https://your-domain-name/domains/`
4. You will always need to specify `-f docker-compose-allinone.yml` when you run any Docker Compose command like `up`, `pull`, `down` and `stop`.

#### Upgrading

You can do the same steps as for Docker, but if you're not already running a domain server or you have modified the `docker-compose.yml` file recently and want to deploy the changes, you can navigate to the folder where you have your `docker-compose.yml` file and then run `docker compose pull` followed by `docker compose down` and `docker compose up -d`.

Note that the `docker compose pull` command will also upgrade the other containers defined in `docker-compose.yml` such as the nginx proxy and the Let's Encrypt helper.

### Binary

> **_NOTE:_** If you choose to use this deployment method, you need to set up your own HTTPS web server or reverse proxy with an SSL certificate. Domain server listens for incoming connections on port 4000 by default, but this is changeable, see the configuration options above.

#### Currently supported platforms

We build pre-compiled binaries for these operating systems and architectures:

- Windows x86, x86_64
- macOS x86_64, ARM64 (Apple Silicon)
- Linux x86, x86_64, ARM, ARM64
- FreeBSD x86, x86_64
- Solaris x86_64

> **_NOTE:_** Auki Labs doesn't test all of these platforms actively. Windows, FreeBSD and Solaris builds are currently experimental. We don't guarantee that everything works but feel free to reach out with your test results.

1. Download the latest version of the domain server from [GitHub](https://github.com/aukilabs/domain-server/releases).
2. Run it with `./ds --public-url=https://domains.example.com --registration-credentials=xxx`
3. Expose it using your own reverse proxy with an SSL certificate.

We recommend you use a daemon manager such as systemd, launchd, SysV Init, runit or Supervisord to make sure your domain server stays running at all times.

### Docker

Domain server is available on [Docker Hub](https://hub.docker.com/r/aukilabs/domain-server).

Here's an example of how to run it:

You need a recent PostgreSQL server to start a domain server. Check PostgreSQL [official website](https://www.postgresql.org/download/) or [Docker Hub Repository](https://hub.docker.com/_/postgres). Create a database that domain server can connect to.

```shell
docker run --name=domain-server --restart=unless-stopped --detach \
-e DS_PUBLIC_URL=https://domains.example.com \
-e DS_REGISTRATION_CREDENTIALS=xxx \
-e "DS_POSTGRES_URL=postgres://pg_user:pg_password@pg_host:pg_port/db_name?sslmode=disable" \
-p 4000:4000 aukilabs/domain-server:stable
```

We also recommend you to configure Docker to start automatically with your operating system. Then, just like in the example above, use `--restart=unless-stopped` in your `docker run` command to start the domain server automatically after the Docker daemon has started.

#### Supported tags

_See the full list on [Docker Hub](https://hub.docker.com/r/aukilabs/domain-server)._

- `latest` (bleeding edge, not recommended)
- `stable` (latest stable version, recommended)
- `v0` (specific major version)
- `v0.5` (specific minor version)
- `v0.5.0` (specific patch version)

#### Upgrading

If you're using a non-version specific tag (`stable` or `latest`) or if the version tag you use matches the new version of the domain server you want to upgrade to, simply run `docker pull aukilabs/domain-server:stable` (where `stable` is the tag you use) and then restart your container with `docker restart domain-server` (if `domain-server` is the name of your container).

If you're using a version-specific tag and the new version of the domain server you want to upgrade to doesn't match the tag you use, you need to first change the tag you use and then restart your container. (`v0` matches any v0.x.x version, `v0.5` matches any v0.5.x version, and so on.)

### Kubernetes

Auki provides a Helm chart for running the Domain server in Kubernetes. We recommend that you use this Helm chart rather than writing your own Kubernetes manifests. For more information about [what Helm is](https://helm.sh/docs/topics/architecture/) and how to [install](https://helm.sh/docs/intro/install/) it, see Helm's official website.

#### Requirements

- Kubernetes 1.14+
- Helm 3
- An HTTPS compatible ingress controller with an SSL certificate that has already been configured

#### Installing

The chart can be deployed by CI/CD tools such as ArgoCD or Flux or it can be deployed using Helm on the command line like this (replace the values with your own):

```shell
helm repo add aukilabs https://charts.aukiverse.com
helm install domain-server aukilabs/domain-server --set envVars.DS_PUBLIC_URL=https://domain-server.example.com --set secretFile.registrationCredentials=MDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwOmludmFsaWQ= --set-file secretFile.privateKey=domain-server-private.key
```

#### Uninstalling

To uninstall (delete) the `domain-server` deployment:

```shell
helm delete domain-server
```

#### Values

Please see [values.yaml](https://github.com/aukilabs/helm-charts/blob/main/charts/domain-server/values.yaml) for the available values and their defaults.

Values can be overridden either by using a values file (the `-f` or `--values` flags) or by setting them on the command line using the `--set` flag. For more information, see the official [documentation](https://helm.sh/docs/helm/helm_install/).

You must at least set the `envVars.DS_PUBLIC_URL` key for server registration to work. Depending on which ingress controller you use, you may also need to set `ingress.enabled=true`, `ingress.hosts[0]=domain-server.example.com`, `ingress.tls[0].hosts[0]` and so on. You also need to configure a secret containing the private key of your Domain server-exclusive wallet, one per Domain server, either using an existing secret inside Kubernetes or by passing the wallet as a file, letting the chart create the Kubernetes secret for you. If you want to use an existing secret, set `useExistingSecrets=true` and `existingSecretName` to the name of the secret you want to use.

#### Upgrading

We recommend you change to use `image.pullPolicy: Always` if you use a non-specific version tag like `stable`/`v0`/`v0.5` (configured by changing the `image.tag` value of the Helm chart) or choose to use a specific version tag like `v0.5.0`. Check *Supported tags* or the *Tags* tab on [Docker Hub](https://hub.docker.com/r/aukilabs/domain-server) for the tags you can use.

## Storage Migration

To migrate your domain data between **local filesystem** and **S3**, the domain server includes a CLI command:

```bash
./ds migrate-storage
```

This will:

* Connect to the Postgres database to list all domain data metadata.
* Copy domain data blobs to the **desired backend** (determined by `DS_STORAGE_TYPE`) from the **other backend**.

    * If `DS_STORAGE_TYPE=s3`, it will copy **from local FS → S3**
    * If `DS_STORAGE_TYPE=local`, it will copy **from S3 → local FS**

**Important:**
- The domain server must be shut down before running the migration command to ensure no data loss.
- Make sure to configure all required environment variables (both S3 access and path settings) before running the command.
- The database must be configured and running.

### Example:

```bash
DS_POSTGRES_URL=postgres://user:pass@host:5432/db \
DS_STORAGE_LOCAL_PATH=./volume \
DS_STORAGE_TYPE=s3 \ # migrating to S3 storage
DS_STORAGE_S3_BUCKET=my-bucket \
DS_STORAGE_S3_REGION=ap-southeast-1 \
DS_STORAGE_S3_ACCESS_KEY=AKIA... \
DS_STORAGE_S3_SECRET_KEY=abcd1234 \
DS_STORAGE_S3_BASE_ENDPOINT=https://s3.my-provider.com \
./ds migrate-storage
```

When migrating storage backends, you must ensure that both are configured and accessible. 
The easiest way is to run the migration command inside the same container as the domain server, so it has access to the same environment variables and the database connection.
Configure environment variables for the new storage backend and set the storage type to `local` or `s3` before running the command.

## Generating random passwords

To generate a random password you can use one of the following commands in Linux or Mac terminal:

```
openssl rand -base64 64 | tr -dc A-Za-z0-9 | head -c 24
```

```
cat /dev/urandom | base64 | tr -dc A-Za-z0-9 | head -c24
```

This will first generate a random string encoded in base64, then run it through `tr` command to leave only alphanumeric characters and then use `head` command to cut the string to 24 characters.

To generate a random password, you can also use one of the password manager apps like Bitwarden, Lastpass, 1Password etc. which have built-in random password generators. You can usually pick what type of characters and how many you want the generated password to include. We recommend to include lowercase letters, uppercase letter and numbers, and generate a password of at least 24 characters.
