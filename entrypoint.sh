#!/bin/bash

echo "-> Interface Devices"

ls /dev/net

echo -n "-> Running as: "
if [ "$SERVER" == "true" ]; then
	echo server

	echo "-> Tinyproxy Configuration"
	envsubst < /root/tinyproxy.conf.template | tee /etc/tinyproxy/tinyproxy.conf
	service tinyproxy restart

	echo "-> Iodine Server"
	/iodined -c -f -p ${DNS_PORT} -u nobody -P ${PASSPHRASE} ${NETWORK} ${DOMAIN} -D
        
else
	echo client

	service tinyproxy stop

	echo "-> Iodine Client"
	/iodine -u nobody -P ${PASSPHRASE} ${DOMAIN} -r

	echo "-> Network Interface"
	ifconfig dns0
	echo "-> Setting 'http_proxy' Environment Variable"
	export HTTP_PROXY_IP=$(echo "$NETWORK" | cut -d / -f1)
	export http_proxy=http://${HTTP_PROXY_IP}:${HTTP_PROXY_PORT}
	echo "-> Trying 'ifconfig.me' to return IP address of the Proxy"
	curl ifconfig.me ; echo
	echo "Dropping to shell..."
	bash -i
fi

