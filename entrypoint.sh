#!/bin/bash
echo "Args: '$@'"

echo "-> Interface Devices"
ls /dev/net

envsubst < /root/tinyproxy.conf.template > /etc/tinyproxy/tinyproxy.conf

echo -n "-> Running as: "
if [ "$SERVER" == "true" ]; then
	echo Server

	if [ "$#" -eq "0" ]; then
		echo "-> Tinyproxy Configuration"
		cat /etc/tinyproxy/tinyproxy.conf
		service tinyproxy restart

		echo "-> Iodine Server"
		/iodined -c -f -p ${DNS_PORT} -u nobody -P ${PASSPHRASE} ${NETWORK} ${DOMAIN} -D
	else
		/iodined "$@"
	fi
else
	echo Client

	echo "-> Iodine Client"
	if [ "$#" -eq "0" ]; then
		/iodine -u nobody -P ${PASSPHRASE} ${DOMAIN} -r

		echo "-> Network Interface"
		ifconfig dns0
		echo "-> Setting 'http_proxy' Environment Variable"
		export HTTP_PROXY_IP=$(echo "$NETWORK" | cut -d / -f1)
		export http_proxy=http://${HTTP_PROXY_IP}:${HTTP_PROXY_PORT}
		echo "-> Trying 'ifconfig.me' to return IP address of the Proxy"
		export IFCONFIGME="$(curl -s ifconfig.me)"
		echo $IFCONFIGME
		if [ "$IFCONFIGME" = "$HTTP_PROXY_IP" ]; then
			echo "-> Connected"
		fi
		echo "Dropping to shell..."
		bash -i

	else
		/iodine "$@"
	fi
fi

