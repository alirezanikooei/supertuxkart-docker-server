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

You can change the game mode with the published image already on your host.

### Set the default in `.env`

With an image that supports `GAME_MODE`, copy `.env.example` to `.env` if you
don't already have one. Set `GAME_MODE=soccer` in `.env` and apply it with Compose.

```sh
docker compose up -d --pull never supertuxkart
```

Compose recreates the server container with the new environment using the
local image. The data volume is preserved, and connected players must rejoin.

| `GAME_MODE` | XML `server-mode` | In-game mode |
| --- | --- | --- |
| `race` | `3` | Normal race |
| `time-trial` | `4` | Time trial |
| `soccer` | `6` | Soccer |
| `free-for-all` | `7` | Free-for-all battle |
| `capture-the-flag` | `8` | Capture the flag |

### Set the default in `server_config.xml`

With `GAME_MODE` empty, the server uses the XML value. Edit `server-mode` in
the active [server configuration](#edit-the-server-configuration) while the
server is stopped. This example sets soccer as the default.

```xml
<server-mode value="6" />
```

Start the server again with `docker compose up -d --pull never supertuxkart`.
This also applies any change to `GAME_MODE` in `.env`.

### Switch modes in the lobby

To let the server owner change modes between races without restarting the
server, set this option in `server_config.xml` while the server is stopped.
Start the server again once to enable it.

```xml
<server-configurable value="true" />
```

While the lobby is waiting to start, the server owner can open
**Configuration** and choose a mode. This works on servers with a lobby owner
outside Grand Prix mode. The lobby selection lasts until the server restarts.
[SuperTuxKart networking guide](https://github.com/supertuxkart/stk-code/blob/1.5/NETWORKING.md)

## Edit the server configuration

Stop the server before editing its XML. SuperTuxKart can write its settings
when shutting down and reads the file at startup.

```sh
docker compose stop supertuxkart
```

With the default named volume, use a temporary container to edit the file.

```sh
docker compose run --rm --no-deps --pull never --entrypoint busybox supertuxkart \
  vi /home/stkserver/.config/supertuxkart/config-0.10/server_config.xml
```

To edit from the host, set `STK_DATA_VOLUME=./stk_config_data` in `.env` and
prepare `stk_config_data/server_config.xml` from the example if needed. If you
already use a bind mount, keep its current directory and edit the file there.

```sh
mkdir -p stk_config_data
cp -n server_config.example.xml stk_config_data/server_config.xml
```

The bind-mounted directory must be writable by the container user (UID 1000).
Keep real passwords and runtime data in that directory.

After saving, start the server again.

```sh
docker compose up -d --pull never supertuxkart
```

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
