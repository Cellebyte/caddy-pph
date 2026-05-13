
# Caddy PPH
> A fully integrated Caddy Docker image featuring PPH DNS-01 ACME validation

Deploy a hassle-free Caddy server with built-in support for PPH DNS-01 ACME challenges. Streamline your SSL certificate management and ensure your server stays secure without manual updates, making it an effortless and reliable solution.


## Table of Contents

- [Features](#features)
- [Usage](#usage)
  - [Using the Pre-built Docker Image](#using-the-pre-built-docker-image)
  - [Building Your Own Docker Image](#building-your-own-docker-image)
  - [Sample Caddyfile](#sample-caddyfile)
- [Configuration](#configuration)
  - [ACME DNS Challenge Configuration](#acme-dns-challenge-configuration)
  - [Creating a Cloudflare API Token](#creating-a-cloudflare-api-token)
- [Platform Support](#platform-support)
  - [Raspberry Pi](#raspberry-pi-support)
- [Tags](#tags)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Automated Builds**: Automatically checks for new Caddy releases and builds Docker images.
- **Continuous Integration**: Utilizes GitHub Actions for seamless CI/CD.
- **PPH DNS Integration**: Integrates PPH DNS for automatic SSL certificate management.
- **Multi-Platform Support**: Builds images for multiple architectures, including `amd64`, `arm64`, `arm/v7` (Raspberry Pi), `ppc64le`, and `s390x` , ensuring compatibility across a wide range of devices and systems.
- **Alpine-based Image**: Provides a lightweight Alpine-based image for smaller size and faster deployment.
- **Manual Trigger**: Allows manual triggering of the build process.
- **Open Source**: Contributions are welcome under the MIT License.

## Usage

### Using the Pre-built Docker Image

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
Defining the data volume as [external](https://docs.docker.com/compose/compose-file/compose-file-v3/#external) makes sure `docker-compose down` does not delete the volume. You may need to create it manually using `docker volume create caddy_data`.

Replace `your_pph_api_token` with your actual PPH API token.

## Sample Caddyfile
Here is a sample Caddyfile configuration to get you started. This configuration sets up the ACME DNS challenge provider to use PPH and serves a simple static site.

### Global Configuration (Use DNS Challenge for All Sites)
In this configuration, the ACME DNS challenge provider is set globally, so it applies to all sites served by Caddy.

```
# To use your own domain name (with automatic HTTPS), first make
# sure your domain's A/AAAA DNS records are properly pointed to
# this machine's public IP, then replace "example.com" below with your
# domain name.

{
  # Set the ACME DNS challenge provider to use PPH for all sites
  acme_dns pph {env.PPH_API_TOKEN}
}

example.com {

    # Set this path to your site's directory.
    root * /usr/share/caddy

    # Enable the static file server.
    file_server

    # Another common task is to set up a reverse proxy:
    # reverse_proxy localhost:8080

    # Or serve a PHP site through php-fpm:
    # php_fastcgi localhost:9000

    encode gzip

    tls {
      # No need to specify dns here, it's already set globally
    }
}

another-example.com {
    root * /usr/share/caddy
    file_server
    encode gzip

    tls {
        # No need to specify dns here, it's already set globally
    }
}
```
### Per-site Configuration
```
example.com {
  
    # Set this path to your site's directory.
    root * /usr/share/caddy

    # Enable the static file server.
    file_server

    # Another common task is to set up a reverse proxy:
    # reverse_proxy localhost:8080

    # Or serve a PHP site through php-fpm:
    # php_fastcgi localhost:9000

    encode gzip

    tls {
        dns pph {env.PPH_API_TOKEN}
    }
}

another-example.com {
    root * /usr/share/caddy
    file_server
    encode gzip

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

- `alpine`: Always points to the latest stable release of the Alpine-based image.
  - `<version>-alpine`: Specific version tags for the Alpine-based image (e.g., `2.7.6-alpine`).

## Platform Support

The `cellebyte/caddy-pph` image is built to support multiple platforms, ensuring compatibility across a wide range of devices and systems. The supported platforms include:

- **linux/amd64**: Standard x86_64 architecture, commonly used in desktop and server environments.
- **linux/arm64**: ARM 64-bit architecture, used in many modern servers and high-end ARM devices.
- **linux/arm/v7**: ARM 32-bit architecture, widely used in devices like Raspberry Pi.
- **linux/ppc64le**: 64-bit PowerPC Little Endian architecture.
- **linux/s390x**: 64-bit IBM System z architecture.

### Alpine Support

The Alpine-based image provides a lightweight alternative, based on the popular Alpine Linux project. Alpine Linux is much smaller than most distribution base images (~5MB), leading to much slimmer images in general.

#### Benefits of Alpine-based Image

- **Smaller Size**: The image size is significantly reduced, which can be beneficial for faster downloads and reduced storage usage.
- **Minimal Base**: Alpine Linux uses musl libc instead of glibc, making it lightweight. However, this may lead to compatibility issues with software that requires glibc.
- **Customization**: To keep the image minimal, additional tools (such as git or bash) are not included by default. You can customize the image by adding the necessary packages in your Dockerfile.

To use the Alpine-based image, pull it from the GitHub Container Registry or Docker Hub:

```sh
docker pull ghcr.io/cellebyte/caddy-pph:alpine
```

### Raspberry Pi Support

This Docker image is optimized for Raspberry Pi, allowing you to deploy Caddy with PPH DNS integration on these popular single-board computers. Whether you are using a Raspberry Pi 3 or the latest Raspberry Pi 4, this image provides the necessary support for seamless operation.

To use the image on a Raspberry Pi, ensure you are running a compatible operating system (such as Raspberry Pi OS) and have Docker installed. You can then pull the image and run it as you would on any other system:

```sh
docker pull ghcr.io/cellebyte/caddy-pph:latest
```
# Building Your Own Docker Image
If you prefer to build your own Docker image, follow these steps:

## Prerequisites

- GitHub account
- GitHub Secrets configured:
  - `GITHUB_TOKEN` (automatically available in GitHub Actions)
  secret or variable to customize the target DockerHub repository)


## Setup Instructions

1. **[Fork this repository](https://github.com/cellebyte/caddy-pph/fork)** to your GitHub account.

2. **Set up GitHub Secrets**:
   - Go to your repository on GitHub.
   - Navigate to `Settings` > `Secrets and variables` > `Actions`.
   - Add the following secrets:
     - `GITHUB_TOKEN`: This is automatically available in GitHub Actions.
     - `DOCKERHUB_USERNAME`: Your DockerHub username (optional).
     - `DOCKERHUB_TOKEN`: Your DockerHub access token (optional).
     - `DOCKERHUB_REPOSITORY_NAME` (optional, can be set as a repository secret or variable to customize the target DockerHub repository)

3. **Manually trigger the workflow** (optional):
   - Go to the `Actions` tab in your GitHub repository.
   - Select the `Build and Push Docker Image` workflow.
   - Click the `Run workflow` button to trigger the build process manually.

4. **Enable the workflow**:
    - Make sure GitHub Actions is enabled for your repository. Go to the `Actions` tab and, if prompted, click "I understand my workflows, go ahead and enable them" to activate Actions for your fork.

5. **Monitor the workflow**:
   - You can monitor the progress and logs of the workflow in the `Actions` tab of your GitHub repository.

6. **Docker image**:
   - Once the workflow completes successfully, the Docker image will be available in the GitHub Container Registry under your repository.
   - You can pull the image using:
     ```sh
     docker pull ghcr.io/YOUR_GITHUB_USERNAME/YOUR_GITHUB_REPOSITORY_NAME:latest
     ```

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
