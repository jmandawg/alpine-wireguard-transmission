#!/bin/sh

WG_CONFIG_DIR="/data/wireguard-config"
TRANS_CONFIG_DIR="/data/transmission-config"

#Setup DNS for container
mkdir -p /etc/netns/container/
echo "nameserver ${WG_IF_DNS}" > /etc/netns/container/resolv.conf

if [ ! -f "${WG_CONFIG_DIR}" ]; then
    echo "wireguard config folder not found creating"
    mkdir -p "${WG_CONFIG_DIR}"
    chown "${USER_ID}":"${GROUP_ID}" -R "${WG_CONFIG_DIR}"
fi
envsubst < /templates/wg0.conf > "${WG_CONFIG_DIR}"/wg0.conf
chown 1000:1000 "${WG_CONFIG_DIR}"/wg0.conf

if [ ! -f "${TRANS_CONFIG_DIR}"/settings.json ]; then
    echo "Transmission config not found copying template"
    mkdir -p "${TRANS_CONFIG_DIR}"
    cp templates/settings.json "${TRANS_CONFIG_DIR}"
    chown "${USER_ID}":"${GROUP_ID}" -R "${TRANS_CONFIG_DIR}"
fi

ip netns add container
ip link add wg0 type wireguard
#if these are first, it will not resolve the endpoint hostname and you must use the ip address
#ip -n container addr add "${WG_IF_ADDRESS}" dev wg0
#ip netns exec container wg setconf wg0 "${WG_CONFIG_DIR}"/wg0.conf
wg setconf wg0 "${WG_CONFIG_DIR}"/wg0.conf
ip link set wg0 netns container
ip -n container addr add "${WG_IF_ADDRESS}" dev wg0
ip -n container link set wg0 up
ip -n container route add default dev wg0

ip link add name veth1 type veth peer name veth2
ip link set dev veth2 netns container
ip netns exec container ip link set dev veth2 up
ip netns exec container ip address add 10.1.1.2/24 dev veth2
ip address add 10.1.1.1/24 dev veth1
ip link set dev veth1 up

#Reference
#https://unix.stackexchange.com/questions/391193/how-to-forward-traffic-between-linux-network-namespaces/393468#393468

iptables -t nat -A PREROUTING ! -s 10.1.1.0/24 -p tcp -m tcp --dport 9091 -j DNAT --to-destination 10.1.1.2
iptables -t nat -A POSTROUTING -d 10.1.1.2/24 -j SNAT --to-source 10.1.1.1

#With this in place you can test from any other host, but not from the host itself. To do this, also add a DNAT rule similar to the previous DNAT, but in OUTPUT and changed (else any outgoing http connexion would be changed too) to your own IP. Let's say your IP is 192.168.1.2:
# iptables -t nat -A OUTPUT -d 192.168.1.2 -p tcp -m tcp --dport 80 -j DNAT --to-destination 10.1.1.2


#Notes: opther options for non-containerd mode routing by userId
#These notes are just for reference
#add new routing table named 10 vpn
#ip route add default dev wg0 proto static scope link table vpn
#ip rule add from 192.168.2.203 lookup vpn #This is just forwarding a random PC through the vpn
#ip rule add  uidrange 224-224 lookup vpn
#ip rule add  uidrange 224-224 sport 9091 lookup main

addgroup -g "${GROUP_ID}" trans
adduser -u "${USER_ID}" -G trans -D trans

ip netns exec container su - trans -c "/usr/bin/transmission-daemon --foreground --config-dir ${TRANS_CONFIG_DIR}"

