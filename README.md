# Alpine-wireguard-transmission README

# Requirements
o
 * Create a folder to map that will store torrents and config in the example below it's "/home/jmandawg/data"
 * The user-id and group-id that will be used on the output files/folders - This user must have read/write access to the /data folder above
 * All variables prefixed with "WG_" come from your VPN provider
 * After first run your transmission settings.json file will be located in /data/transmission-config directory.  
   You can stop the docker container and moify them to your liking.  Do not modify "rpc-bind-address" or "rpc-whitelist"
 * The web interface should be available on the docker host on port 9091 (or whatever port you map it to).
 * This will probaly only work on ipv4 as that's all i can test on.

# Example Running
'''
docker run -it \
  -e WG_IF_PRIVATE_KEY="abc123...." \
  -e WG_IF_ADDRESS="10.x.x./32" \
  -e WG_IF_DNS="10.x.x.x" \
  -e WG_PEER_PUBLIC_KEY="abc123...." \
  -e WG_PEER_PRESHARED_KEY="abc123..." \
  -e WG_PEER_ENDPOINT="host:port" \
  -e GROUP_ID="1000" \
  -e USER_ID="1000" \
  --privileged \
  --name wireguard-transmission \
  -p 9099:9091 \
  --sysctl net.ipv4.ip_forward=1 \
  -v /home/jmandawg/data:/data \
'''
