#!/bin/bash

# Set the primary interface of the host to a static value
sudo nmcli con mod 'Wired connection 1' ipv4.method manual ipv4.addresses 10.10.12.180/22 ipv4.gateway 10.10.12.1 ipv4.dns 10.10.12.11,10.10.12.10,8.8.8.8 connection.autoconnect yes

# If using SL-Micro
sudo transactional-update register -e $EMAIL -r $REG_CODE

# Set the hostname of the host
echo "observability" | sudo tee /etc/hostname
