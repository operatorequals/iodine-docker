# iodine-docker
Container for Iodine DNS Tunnel (https://code.kryo.se/iodine)

## Usage

### Server Mode

```bash
docker run \
  -e SERVER=true \
  -e PASSPHRASE=secretpassword \
  -e DOMAIN=ns.example.com \
  --cap-add=NET_ADMIN --device /dev/net/tun:/dev/net/tun \
  -p 8888:8888 -p 53:5353/udp \
  -ti ghcr.io/operatorequals/iodine-docker:master

```

### Client Mode

```bash
docker run \
  -e SERVER=false \
  -e PASSPHRASE=secretpassword \
  -e DOMAIN=ns.example.com \
  --cap-add=NET_ADMIN --device /dev/net/tun:/dev/net/tun \
  -ti ghcr.io/operatorequals/iodine-docker:master

```

for reference on inner workings and `iodine[d]` switches, read the Official Project Readme (https://github.com/yarrick/iodine).
