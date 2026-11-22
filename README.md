
# Caddy PPH
> A fully integrated Caddy Docker image featuring PPH DNS-01 ACME validation

Deploy a hassle-free Caddy server with built-in support for PPH DNS-01 ACME challenges. Streamline your SSL certificate management and ensure your server stays secure without manual updates, making it an effortless and reliable solution.


## Table of Contents

- [Caddy PPH](#caddy-pph)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Quick Start](#quick-start)
  - [Sample Caddyfile](#sample-caddyfile)
  - [Included Modules](#included-modules)
  - [Usage](#usage)
    - [Docker Pull](#docker-pull)
    - [Caddyfile Examples](#caddyfile-examples)
      - [Global DNS Configuration](#global-dns-configuration)
      - [Per-Site DNS Configuration](#per-site-dns-configuration)
  - [Configuration](#configuration)
    - [ACME DNS Challenge Configuration](#acme-dns-challenge-configuration)
  - [Tags](#tags)
    - [Default or slim?](#default-or-slim)
      - [Troubleshooting](#troubleshooting)
  - [Tags](#tags-1)
    - [Why `alpine` tags point to the same image](#why-alpine-tags-point-to-the-same-image)
    - [Why did a digest change?](#why-did-a-digest-change)
  - [Platform Support](#platform-support)
    - [Alpine](#alpine)
    - [Raspberry Pi](#raspberry-pi)
  - [Troubleshooting](#troubleshooting-1)
    - [Verifying Modules](#verifying-modules)
    - [Official Resources](#official-resources)
  - [How It Works](#how-it-works)
  - [Building Your Own Image](#building-your-own-image)
    - [Prerequisites](#prerequisites)
    - [Setup Instructions](#setup-instructions)
  - [Usage](#usage-1)
  - [Contributing](#contributing)
  - [License](#license)

## Features

- **Automated Builds** -- Twice-daily checks for new Caddy releases with automatic image builds.
- **Module Update Detection** -- Tracks upstream module commits and rebuilds when dependencies change.
- **Base Image Tracking** -- Rebuilds when the base image is republished with OS or Go toolchain fixes.
- **Cloudflare DNS-01 Integration** -- Automatic SSL certificate management via DNS challenges.
- **Cloudflare IP Trust** -- Real client IPs preserved when proxying through Cloudflare.
- **Multi-Platform** -- Supports `amd64`, `arm64`, `arm/v7` (Raspberry Pi), `ppc64le`, and `s390x`.
- **Alpine-Based** -- Built on the official Caddy image, which uses Alpine Linux. A `slim` variant drops the stock binary.
- **Fork-Friendly** -- Image names derived automatically from your GitHub repository.

## Quick Start

Pull the image and set up a `docker-compose.yml`:

To use the pre-built Docker image, pull it from the GitHub Container Registry:

```sh
docker pull ghcr.io/cellebyte/caddy-pph:latest
# alpine
docker pull ghcr.io/cellebyte/caddy-pph:alpine
```
You can use the image in your Docker setup. Here is an example `docker-compose.yml` file:
```yaml
services:
  caddy:
    image: ghcr.io/cellebyte/caddy-pph:latest
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - $PWD/Caddyfile:/etc/caddy/Caddyfile
      - $PWD/site:/srv
      - caddy_data:/data
      - caddy_config:/config
    environment:
      - PPH_API_TOKEN=your_pph_api_token

volumes:
  caddy_data:
    external: true
  caddy_config:
```

Replace `your_pph_api_token` with your actual PPH API token.

## Sample Caddyfile
Here is a sample Caddyfile configuration to get you started. This configuration sets up the ACME DNS challenge provider to use PPH and serves a simple static site.

## Included Modules

These modules are compiled into Caddy at build time using [xcaddy](https://github.com/caddyserver/xcaddy). No additional installation is needed.

| Module | Purpose | Repository |
|--------|---------|------------|
| `caddy-dns/cloudflare` | DNS-01 ACME challenge provider for Cloudflare | [caddy-dns/cloudflare](https://github.com/caddy-dns/cloudflare) |
| `caddy-cloudflare-ip` | Automatically trust Cloudflare proxy IP ranges for correct client IPs | [WeidiDeng/caddy-cloudflare-ip](https://github.com/WeidiDeng/caddy-cloudflare-ip) |
| `caddy-combine-ip-ranges` | Combine IP ranges from multiple sources (e.g. Cloudflare plus your own) for `trusted_proxies` | [fvbommel/caddy-combine-ip-ranges](https://github.com/fvbommel/caddy-combine-ip-ranges) |
| `caddy-ratelimit` | Rate limit requests per real client IP, even behind Cloudflare's proxy | [mholt/caddy-ratelimit](https://github.com/mholt/caddy-ratelimit) |

## Usage

### Docker Pull

```sh
docker pull ghcr.io/caddybuilds/caddy-cloudflare:latest
docker pull caddybuilds/caddy-cloudflare:latest
```

See [Quick Start](#quick-start) for a full docker-compose setup.

### Caddyfile Examples

#### Global DNS Configuration

Set the ACME DNS challenge provider globally so it applies to all sites:

```
{
  # Set the ACME DNS challenge provider to use PPH for all sites
  acme_dns pph {env.PPH_API_TOKEN}
}

example.com {
    root * /usr/share/caddy
    file_server
    encode gzip
}

another-example.com {
    reverse_proxy localhost:8080
}
```

#### Per-Site DNS Configuration

Configure DNS challenge individually per site:

```
example.com {
    root * /usr/share/caddy
    file_server
    encode gzip

    tls {
        dns pph {env.PPH_API_TOKEN}
    }
}

another-example.com {
    reverse_proxy localhost:8080

    tls {
        dns pph {env.PPH_API_TOKEN}
    }
}
```

## Configuration
### ACME DNS Challenge Configuration
To configure the [ACME DNS challenge](https://caddyserver.com/docs/automatic-https#dns-challenge) provider for all ACME transactions, add the following to your Caddyfile:

```
{
   acme_dns pph {env.PPH_API_TOKEN}
}
```

This is equivalent to specifying the provider in the [tls directive's ACME issuer](https://caddyserver.com/docs/caddyfile/directives/tls#acme) configuration. See [Caddyfile Examples](#caddyfile-examples) for full samples.

## Tags

The image is available on [GitHub Container Registry](https://github.com/caddybuilds/caddy-cloudflare/pkgs/container/caddy-cloudflare) and Docker Hub. There are two images, default and slim, each under a few tags:

| Tags | Image |
|------|-------|
| `latest`, `<version>`, `<major>.<minor>`, `<major>` | Default |
| `alpine`, `<version>-alpine`, `<major>.<minor>-alpine`, `<major>-alpine` | Default (same image, see below) |
| `slim`, `<version>-slim`, `<major>.<minor>-slim`, `<major>-slim` | Slim |

`<version>` pins a release (e.g. `2.11.7`), `<major>.<minor>` follows the latest patch (e.g. `2.11`) and `<major>` the latest release (e.g. `2`). Slim tags exist from `2.11.7` onward.

### Default or slim?
This configuration sets up the provider to use the PPH DNS module with the API token provided as an environment variable. It ensures that your Caddy server can automatically issue and renew SSL certificates using DNS-01 challenges via PPH.

This setup is the same as specifying the provider in the [tls directive's ACME issuer](https://caddyserver.com/docs/caddyfile/directives/tls#acme) configuration.

[Sample Caddyfile](#sample-caddyfile)

#### Troubleshooting

You may encounter `solving challenges: presenting for challenge: adding temporary record for zone xyz.: got error status: HTTP 403.` 
In such cases, try setting custom DNS resolvers like below to bypass resolver issues:
```
tls {
  dns pph {env.CF_API_TOKEN}
  resolvers 1.1.1.1
}
```

[Official troubleshooting guide](https://github.com/caddy-dns/pph?tab=readme-ov-file#troubleshooting)

## Tags

The [caddy-pph](https://github.com/cellebyte/caddy-pph/pkgs/container/caddy-pph) image on GitHub Container Registry and Docker Hub provides the following tags:

- **`latest`**: 
  - Always points to the most recent stable release of Caddy with the PPH DNS module.
  - Automatically updated to ensure you have the latest features and improvements.

- **`<version>`**:
  - Specific version tags for precise version control and consistency in deployments.
  - Examples include:
    - **`2.7.6`**: Full version tag for Caddy version 2.7.6, ensuring you are using this exact release. 
    
         (eg: ```docker pull ghcr.io/cellebyte/caddy-pph:2.8.0``` )
    - **`2.7`**: Minor version tag for the latest patch release within the 2.7 series, allowing for minor updates without breaking changes.
    - **`2`**: Major version tag for the latest release within the 2.x series, providing updates within the major version while maintaining compatibility.  

Both run the same Caddy binary with the same modules. They differ only in the image underneath.

| | Default | Slim |
|---|---|---|
| Built on | The official [Caddy image](https://hub.docker.com/_/caddy) | [caddy-base](https://github.com/CaddyBuilds/caddy-base#the-caddy-base-image): the official image without its Caddy binary |
| Download size (amd64) | about 43 MB | about 24 MB |
| Caddy binaries inside | Two: the stock one stays in a lower layer, ours replaces it on top | One: ours |
| Rebuilt for base fixes when | The official Caddy image is republished | Alpine is republished (caddy-base rebuilds, then slim follows) |

Everything else is the same: Alpine, packages, default Caddyfile, `/data` and `/config`, ports, command, platforms, and permission to bind ports 80 and 443 as a non-root user.

Use **slim** for a smaller image. Use **default** if you want to stay on the Docker Official Image exactly as Caddy ships it.

### Why `alpine` tags point to the same image

This follows the official Caddy image. On Linux, `caddy:latest`, `caddy:2.11.7` and `caddy:2.11.7-alpine` are all the same Alpine image. The plain tags also include Windows builds, which is the only reason both exist. We only build Linux images, so the `-alpine` tags are aliases: a setup that uses `caddy:2.11.7-alpine` can switch to `caddy-cloudflare:2.11.7-alpine` without changing anything else.

> **Note:** Starting from `v2.11.0`, the image includes the `caddy-cloudflare-ip` and `caddy-combine-ip-ranges` modules by default.

### Why did a digest change?

Images are rebuilt without a new Caddy version when a module gets new commits or a base image is republished with OS or Go fixes (the official Caddy image for the default tags, the caddy-base image for `slim`). Each rebuild is logged under **Rebuilds** in that version's [GitHub Release](https://github.com/caddybuilds/caddy-cloudflare/releases), and the reason is stored in the image labels:

```sh
docker inspect --format '{{ index .Config.Labels "caddy-build.reason" }}: {{ index .Config.Labels "caddy-build.details" }}' ghcr.io/caddybuilds/caddy-cloudflare:latest
```

## Platform Support

The image is built for the following platforms:
The `cellebyte/caddy-pph` image is built to support multiple platforms, ensuring compatibility across a wide range of devices and systems. The supported platforms include:

- **linux/amd64** -- Standard x86_64 (desktops, servers)
- **linux/arm64** -- ARM 64-bit (modern ARM servers, Apple Silicon via emulation)
- **linux/arm/v7** -- ARM 32-bit (Raspberry Pi 3+)
- **linux/ppc64le** -- 64-bit PowerPC Little Endian
- **linux/s390x** -- 64-bit IBM System z

### Alpine

Both images are built on [Alpine Linux](https://alpinelinux.org/): the default through the official Caddy image, slim through caddy-base. Alpine uses musl libc instead of glibc, which may cause compatibility issues with some software. Additional tools (git, bash, etc.) are not included by default.

### Raspberry Pi

The `linux/arm/v7` build supports Raspberry Pi 3 and later. No special configuration is needed beyond having Docker installed on a compatible OS (such as Raspberry Pi OS).

## Troubleshooting

```sh
docker pull ghcr.io/cellebyte/caddy-pph:alpine
```

### Verifying Modules

To confirm the bundled modules are loaded:

```sh
docker run --rm ghcr.io/cellebyte/caddy-pph:latest caddy list-modules | grep -E "pph|hetzner|cloudflare"
This Docker image is optimized for Raspberry Pi, allowing you to deploy Caddy with PPH DNS integration on these popular single-board computers. Whether you are using a Raspberry Pi 3 or the latest Raspberry Pi 4, this image provides the necessary support for seamless operation.

To use the image on a Raspberry Pi, ensure you are running a compatible operating system (such as Raspberry Pi OS) and have Docker installed. You can then pull the image and run it as you would on any other system:

```sh
docker pull ghcr.io/cellebyte/caddy-pph:latest
```

### Official Resources

- [caddy-dns/cloudflare troubleshooting guide](https://github.com/caddy-dns/cloudflare?tab=readme-ov-file#troubleshooting)
- [Caddy ACME DNS challenge docs](https://caddyserver.com/docs/automatic-https#dns-challenge)

## How It Works

The build pipeline is fully automated via GitHub Actions and shared with the other CaddyBuilds images through [caddy-base](https://github.com/CaddyBuilds/caddy-base). This repo holds only what is specific to this image: the `Dockerfile` (module list), `caddy-image.json` (title, description, verified module) and three thin workflows that call the shared ones.

1. **Release check** -- A workflow scheduled twice daily queries the GitHub API for new [Caddy releases](https://github.com/caddyserver/caddy/releases) and verifies the official Docker image is available with all required platforms before triggering a build. GitHub may delay or drop scheduled runs and disables schedules after 60 days of repository inactivity. Re-enable the workflow in Actions if disabled; it can also be run manually.

2. **Module update detection** -- The pipeline reads the module list from the `Dockerfile` and tracks each module's latest commit SHA in `module-versions.json`. If any module has new commits, a rebuild is triggered even without a new Caddy release.

3. **Base image tracking** -- Docker Official Images republish existing Caddy versions for base OS and Go toolchain fixes, and caddy-base is rebuilt when Alpine is republished. The check compares each base image with when ours was built, and rebuilds if the base is newer.

4. **Multi-platform build** -- The shared workflow builds the default and slim images for all supported architectures. Images are pushed to GitHub Container Registry (primary) and optionally Docker Hub.

5. **Fork-friendly** -- Image names are derived from the `GITHUB_REPOSITORY` environment variable, so forks produce correctly named images without any configuration changes.

6. **Failure notifications** -- If a build fails, a GitHub issue is automatically created for visibility.

7. **Vulnerability scans** -- [Trivy](https://trivy.dev) scans the published `latest` and `slim` images daily and after every build. Results go to the repo's code scanning alerts and, readable by anyone, to the summary of each [Scan Images run](https://github.com/caddybuilds/caddy-cloudflare/actions/workflows/scan-images.yml). Fixes arrive through rebuilds, not dependency pins, so a finding stays open until Caddy, a module or the base image ships the fix.

## Building Your Own Image

### Prerequisites

- GitHub account
- Docker Hub account (optional, for pushing to Docker Hub)
- GitHub Secrets configured:
  - `GITHUB_TOKEN` (automatically available in GitHub Actions)
  - `DOCKERHUB_USERNAME` (optional)
  - `DOCKERHUB_TOKEN` (optional)
  - `DOCKERHUB_REPOSITORY_NAME` (optional, to customize the Docker Hub repository name)

### Setup Instructions

1. **[Fork this repository](https://github.com/cellebyte/caddy-pph/fork)** to your GitHub account.

2. **Set up GitHub Secrets** (optional, for Docker Hub):
   - Navigate to `Settings` > `Secrets and variables` > `Actions`.
   - Add `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`, and optionally `DOCKERHUB_REPOSITORY_NAME`.

3. **Enable GitHub Actions**:
   - Go to the `Actions` tab. If prompted, click "I understand my workflows, go ahead and enable them".

4. **Customize the modules** (optional):
   - Add or change `--with` lines in the `Dockerfile`; the scheduled check follows the list from there. Adjust the title and description in `caddy-image.json` if you like.

5. **Trigger a build** (optional):
   - In the `Actions` tab, select `Build and Push Docker Image` and click `Run workflow`. The optional note is recorded in the release notes.

6. **Pull your image**:
   ```sh
   docker pull ghcr.io/YOUR_GITHUB_USERNAME/YOUR_REPOSITORY_NAME:latest
   ```

Use the image in your docker-compose setup as shown in the [Quick Start](#quick-start), replacing the image name with your own.
## Usage

You can use the built Docker image in your projects. Here is an example of how to use it in a `docker-compose.yml` file:

```yaml
services:
  caddy:
    image: ghcr.io/YOUR_GITHUB_USERNAME/YOUR_GITHUB_REPOSITORY_NAME:latest
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - $PWD/Caddyfile:/etc/caddy/Caddyfile
      - $PWD/site:/srv
      - caddy_data:/data
      - caddy_config:/config
    environment:
      - PPH_API_TOKEN=your_pph_api_token

volumes:
  caddy_data:
    external: true
  caddy_config:
```
Defining the data volume as [external](https://docs.docker.com/compose/compose-file/compose-file-v3/#external) makes sure `docker-compose down` does not delete the volume. You may need to create it manually using `docker volume create caddy_data`.

Replace `YOUR_GITHUB_USERNAME` with your GitHub username and `your_pph_api_token` with your actual PPH API token.

## Contributing

Feel free to open issues or submit pull requests if you have any improvements or bug fixes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
