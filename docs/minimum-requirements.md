# Minimum Requirements

Most modern computers will be able to run a Domain Server. We have tested on desktops, laptops, servers and Raspberry Pis.

- An x86 or ARMv6+ processor
- At least 64 MiB of RAM reserved for the Domain Server
- At least 64 MiB of RAM reserved for PostgreSQL
- At least 30 GiB of disk space
- A supported operating system, we currently provide pre-compiled binaries for Windows, macOS, Linux, FreeBSD, Solaris as well as Docker images

Additionally, you need this in order to expose the Domain Server to the Internet:

- A web server or reverse proxy which
  - is compatible with HTTPS
  - has an SSL certificate installed
- A stable Internet connection with
  - an externally accessible, static and public IP address for your reverse proxy to listen to
  - at least 10 Mbps downstream and upstream
- A domain name configured to point to your IP address
- A [dynamic DNS service](https://en.wikipedia.org/wiki/Dynamic_DNS) if you don't have a static IP address

Additionally, you need to set up a PostgreSQL database. We recommend using the latest
version of PostgreSQL, but any version from 9.x and onwards should work.

You may be able to get started faster if you have en existing Kubernetes cluster to use
or you can use our Docker Compose setup that includes a basic nginx reverse proxy with a
Let's Encrypt-issued SSL certificate and a PostgreSQL database. See
[Deployment](deployment.md) for more information.

Auki's Domain Discovery Service (DDS) will perform regular checks on the health of your
server to determine if it's fit to serve traffic. Make sure that you have enough spare
compute capacity and bandwidth for serving requests or your server's reputation may be
downgraded.
