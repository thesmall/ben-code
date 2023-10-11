#!/bin/bash

#Export Private Internet Access Information to /mnt/torrents/pia-info.txt

connectionState=$(piactl get connectionstate)
vpnIP=$(piactl get vpnip)
port=$(piactl get portforward)
region=$(piactl get region)

echo "ConnectionState: $connectionState
VPN IP: $vpnIP
Port: $port
Region: $region" > /mnt/torrents/pia-info.txt