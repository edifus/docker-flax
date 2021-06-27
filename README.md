# [edifus/flax](https://github.com/edifus/docker-flax)

[flax-blockchain](https://github.com/Flax-Network/flax-blockchain) - Flax blockchain python implementation (full node, farmer, harvester, timelord, and wallet)

## Supported Architectures

| Architecture | Tag |
| :----: | --- |
| x86-64 | amd64-latest |


## Usage

Here are some example snippets to help you get started creating a container.

### docker-compose (recommended)

Compatible with docker-compose v2 schemas.

```yaml
---
version: "2.1"
services:
  rutorrent:
    image: ghcr.io/edifus/flax
    container_name: flax
    environment:
      - PUID=1000
      - PGID=1000
    volumes:
      - /path/to/config:/config
      - /path/to/plots:/plots # optional
    ports:
      - 6888:6888 # node - optional
      - 6885:6885 # farmer - optional
    restart: unless-stopped
```

### docker cli

```
docker run -d \
  --name=flax \
  -e PUID=1000 \
  -e PGID=1000 \
  -p 6888:6888 `# node - optional` \
  -p 6885:6885 `# farmer - optional` \
  -v /path/to/config:/config \
  -v /path/to/plots:/plots `# optional` \
  --restart unless-stopped \
  ghcr.io/edifus/flax
```


## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 6888:6888` | optional: node port |
| `-p 6885:6885` | optional: farmer port |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e PLOTS_DIR=/plots` | optional: path to plots directory for farmer/harvester - use with -v below |
| `-e KEYS=generate` | optional: generate new keys on container init - saves as /config/flax-mnemonic.txt to be imported automatically in the future |
| `-e KEYS_FILE=/keys.txt` | optional: text file of flax mnemonic to import on container init - saves as /config/flax-mnemonic.txt to be imported automatically in the future - use with -v below |
| `-e FULL_NODE=false` | optional: disable full node (node, wallet, farmer, harvester) to enable individual services (see below) - default: true |
| `-e HARVESTER_ONLY=true` | optional: enable harvester only, FARMER_ADDRESS required if not running a farmer in same container - default: false |
| `-e FARMER_ADRESS=x.x.x.x` | optional: remote farmer IP for harvester |
| `-e CACERTS_DIR=/ca` | optional: required if `HARVESTER_ONLY=true` to initialize certs from full-node/farmer (only intialized once) - use with -v below |
| `-e NODE_ONLY=true` | optional: enable node only - default: false |
| `-e TAIL_DEBUG_LOGS=true` | optional: tail debug logs to container console logs - default: false |
| `-e LOG_LEVEL=INFO` | optional: change debug log level - default: INFO |
| `-v /path/to/config:/config` | where to store flax configuration |
| `-v /path/to/plots:/plots` | optional: path to your plots folder |
| `-v /path/to/keys.txt:/keys.txt` | optional: path to your flax mnemonic text file |
| `-v /path/to/cacerts:/ca` | optional: path to your `ca` folder |


## Environment variables from files (Docker secrets)

You can set any environment variable from a file by using a special prepend `FILE__`.

As an example:

```
-e FILE__PASSWORD=/run/secrets/mysecretpassword
```

Will set the environment variable `PASSWORD` based on the contents of the `/run/secrets/mysecretpassword` file.


## Umask for running applications

This image provides the ability to override the default umask settings for services started within the containers using the optional `-e UMASK=022` setting.
Keep in mind umask is not chmod, it masks permissions based on it's value. Please read up [here](https://en.wikipedia.org/wiki/Umask) for more information.


## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id user` as below:

```
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```


## Application Setup

todo..

* **IMPORTANT:** To start individual services set `FULL_NODE=false` and configure `HARVESTER_ONLY` or `NODE_ONLY`.
* If `HARVESTER_ONLY` and `NODE_ONLY` are not provided a full-node will be started.
* `HARVESTER_ONLY=true` **requires** `FARMER_ADDRESS` to be set to connect to a remote farmer.
* `HARVESTER_ONLY=true` **requires** `CACERTS_DIR` to be provided at least once to configure certs signed by the farmer. Copy `ca` certs folder from a previously setup farmer/full-node. Information can be found on the official wiki https://github.com/Chia-Network/chia-blockchain/wiki/Farming-on-many-machines.
* `CACERTS_DIR` will import existing ca-certs to generate the other necessary certificate. This will only be imported once to prevent certs from being regenerated repeatedly, see caution below.
* **CAUTION:** Providing `CACERTS_DIR` to an existing node/wallet container will reset certs and require deleting `/config` and resyncing the entire blockchain!


### Chia command inside container

#### Add keys
```
docker exec -it flax /app/flax-blockchain/venv/bin/flax keys add
```

#### Add plots directory
```
docker exec -it flax /app/flax-blockchain/venv/bin/flax plots add -d /path/to/other/plots
```

#### Show wallet
```
docker exec -it flax /app/flax-blockchain/venv/bin/flax wallet show
```


## Docker Mods


## Support Info
* Shell access whilst the container is running: `docker exec -it flax /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f flax`


## Updating Info

Below are the instructions for updating containers:

### Via Docker Compose
* Update all images: `docker-compose pull`
  * or update a single image: `docker-compose pull rutorrent`
* Let compose update all containers as necessary: `docker-compose up -d`
  * or update a single container: `docker-compose up -d rutorrent`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Run
* Update the image: `docker pull ghcr.io/edifus/flax`
* Stop the running container: `docker stop flax`
* Delete the container: `docker rm flax`
* Recreate a new container with the same docker run parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* You can also remove the old dangling images: `docker image prune`

### Via Watchtower auto-updater (only use if you don't remember the original parameters)
* Pull the latest image at its tag and replace it with the same env variables in one run:
  ```
  docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower --run-once flax
  ```
* You can also remove the old dangling images: `docker image prune`

### Image Update Notifications - Diun (Docker Image Update Notifier)
* Recommended to use [Diun](https://crazymax.dev/diun/) for update notifications. Other tools that automatically update containers unattended are not recommended.


## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:
```
git clone https://github.com/edifus/docker-flax.git
cd docker-flax
docker build  --no-cache --pull -t edifus/flax:test .
```


## Versions

* **2021.05.16:** - Inital version, based on linuxserver.io ubuntu base and official flax-docker container
