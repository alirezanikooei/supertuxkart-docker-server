# SuperTuxKart Docker Server

Run a dedicated SuperTuxKart LAN server with Docker on Linux. Connect through
the game's LAN lobby or enter the Docker host's address and port `2759`.
Host networking lets the server respond to LAN discovery on `2757/udp`.
Gameplay uses `2759/udp` by default.

## Build and run with Compose

```sh
docker compose up --build -d
docker compose logs -f supertuxkart
```

The server creates a default configuration on first startup. Compose stores
configuration and generated files in the `stk-data` volume.

A bind mount lets you edit the configuration on the host.

```sh
mkdir -p stk_config_data
cp -n server_config.example.xml stk_config_data/server_config.xml
STK_DATA_VOLUME=./stk_config_data docker compose up --build -d
```

The bind-mounted directory must be writable by the container user (UID 1000).
For an existing deployment, point `STK_DATA_VOLUME` at its existing directory.
Restart the server after editing `server_config.xml`.
Keep real passwords and runtime data in that directory.

Set `AI_KARTS=3` when starting Compose to enable three AI karts in a supported
race mode. The default is zero.

## Use the published image

Replace `owner` with the lowercase GitHub account or organization name.

```sh
docker run -d --name stk-server --restart unless-stopped --network host \
  -v stk-data:/home/stkserver/.config/supertuxkart/config-0.10 \
  ghcr.io/owner/supertuxkart-docker-server:latest
```

## Publish from GitHub

The GitHub Actions workflow builds a Linux `amd64` image on the default branch,
checks that it answers a LAN discovery request, and pushes it to GHCR using
GitHub's workflow token. It publishes the `latest` and `sha-<commit>` tags.
The image name follows the repository name.

After the first successful run, open the package on GitHub and select
**Package settings → Change visibility → Public** to enable anonymous pulls.
[GitHub package visibility documentation](https://docs.github.com/en/packages/learn-github-packages/configuring-a-packages-access-control-and-visibility#configuring-visibility-of-packages-for-your-personal-account).

## Upstream sources

The image uses Alpine's SuperTuxKart packages. Upstream game code is licensed
under GPL-3.0-or-later. The upstream source archive includes asset-specific
license and credit files. Use `apk info -v supertuxkart-server` inside the image
to identify the installed package version. The Alpine build recipe lists the
corresponding source archives and patches.

- [SuperTuxKart releases and source archives](https://github.com/supertuxkart/stk-code/releases)
- [Alpine 3.24 SuperTuxKart build recipe](https://gitlab.alpinelinux.org/alpine/aports/-/tree/3.24-stable/community/supertuxkart)
- [Alpine 3.24 package sources](https://gitlab.alpinelinux.org/alpine/aports/-/tree/3.24-stable)
