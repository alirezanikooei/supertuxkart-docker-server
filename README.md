# SuperTuxKart Docker Server

Run a dedicated SuperTuxKart LAN server with Docker on Linux (`amd64`). Connect
through the game's LAN lobby or enter the Docker host's address and port `2759`.
Host networking lets the server respond to LAN discovery on `2757/udp`.
Gameplay uses `2759/udp` by default.

## Run with Compose

Compose uses `ghcr.io/alirezanikooei/supertuxkart-docker-server:latest`.
[View the package on GitHub](https://github.com/alirezanikooei/supertuxkart-docker-server/pkgs/container/supertuxkart-docker-server)

```sh
docker compose pull
docker compose up -d
docker compose logs -f supertuxkart
```

The server creates a default configuration on first startup. Compose stores
configuration and generated files in the `stk-data` volume. To upgrade, run
`docker compose pull` and `docker compose up -d` again.

## Change the game mode

Copy `.env.example` to `.env` if you don't already have one. Set
`GAME_MODE=soccer` in `.env`, then run `docker compose up -d` to apply it.

| `GAME_MODE` | In-game mode |
| --- | --- |
| `race` | Normal race |
| `time-trial` | Time trial |
| `soccer` | Soccer |
| `free-for-all` | Free-for-all battle |
| `capture-the-flag` | Capture the flag |

With `GAME_MODE` empty, the server uses `server-mode` from `server_config.xml`.
The default configuration runs a normal race. The environment setting
applies at startup and preserves the XML file.

## Edit the server configuration

A bind mount lets you edit the configuration on the host.

```sh
mkdir -p stk_config_data
cp -n server_config.example.xml stk_config_data/server_config.xml
STK_DATA_VOLUME=./stk_config_data docker compose up -d
```

The bind-mounted directory must be writable by the container user (UID 1000).
For an existing deployment, point `STK_DATA_VOLUME` at its existing directory.
Restart the server after editing `server_config.xml`.
Keep real passwords and runtime data in that directory.

Set `AI_KARTS=3` when starting Compose to enable three AI karts in a supported
race mode. The default is zero.

## Run with Docker

```sh
docker pull ghcr.io/alirezanikooei/supertuxkart-docker-server:latest
docker run -d --name stk-server --restart unless-stopped --network host \
  -v stk-data:/home/stkserver/.config/supertuxkart/config-0.10 \
  ghcr.io/alirezanikooei/supertuxkart-docker-server:latest
```

## Build locally

```sh
docker build -t supertuxkart-docker-server:local .
STK_IMAGE=supertuxkart-docker-server:local docker compose up -d
```

## Publish from GitHub

The GitHub Actions workflow builds a Linux `amd64` image on the default branch,
checks that LAN discovery reports the configured mode, and pushes the image to
GHCR using GitHub's workflow token. It publishes the `latest` and `sha-<commit>` tags.
The image name follows the repository name.

For a new package, open it on GitHub after the first successful run and select
**Package settings → Change visibility → Public** to enable anonymous pulls.
[GitHub package visibility documentation](https://docs.github.com/en/packages/learn-github-packages/configuring-a-packages-access-control-and-visibility#configuring-visibility-of-packages-for-your-personal-account).

## License

The Docker and deployment files are licensed under GPL-3.0-or-later.
SuperTuxKart, its assets, and the Alpine packages retain their own licenses.
[Project license](LICENSE) · [Third-party licenses and corresponding sources](THIRD_PARTY_NOTICES.md)
