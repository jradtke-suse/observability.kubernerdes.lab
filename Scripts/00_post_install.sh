#!/bin/bash

# Setup sudo for mansible (for later)
echo 'mansible ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/mansible-nopasswd-all

# Set the hostname of the host
echo "observability-01" | sudo tee /etc/hostname
echo "observability-02" | sudo tee /etc/hostname
echo "observability-03" | sudo tee /etc/hostname

# Set the primary interface of the host to a static value
sudo nmcli con mod 'Wired connection 1' ipv4.method manual ipv4.addresses 10.10.12.181/22 ipv4.gateway 10.10.12.1 ipv4.dns 10.10.12.11,10.10.12.10,8.8.8.8 connection.autoconnect yes
sudo nmcli con mod 'Wired connection 1' ipv4.method manual ipv4.addresses 10.10.12.182/22 ipv4.gateway 10.10.12.1 ipv4.dns 10.10.12.11,10.10.12.10,8.8.8.8 connection.autoconnect yes
sudo nmcli con mod 'Wired connection 1' ipv4.method manual ipv4.addresses 10.10.12.183/22 ipv4.gateway 10.10.12.1 ipv4.dns 10.10.12.11,10.10.12.10,8.8.8.8 connection.autoconnect yes

# disable IPv6 (doesn't work in my setup)
cat << EOF | tee /etc/sysctl.d/10-disable_ipv6.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

# Disable firewalld (revisit this)
systemctl disable firewalld --now

# Remove existing entry
sudo sed -i -e '/observ/d' /etc/hosts
# Add all the Rancher Nodes to /etc/hosts
cat << EOF | tee -a /etc/hosts

# Rancher Nodes
10.10.12.181    observability-01.kubernerdes.lab observability-01
10.10.12.182    observability-02.kubernerdes.lab observability-02
10.10.12.183    observability-03.kubernerdes.lab observability-03
EOF

# If using SL-Micro
sudo transactional-update register -e $EMAIL -r $REG_CODE

# Shutdown to update host
sudo shutdown now -r

exit 0

restart() {

ssh-keygen -R 10.10.15.86 -f /home/mansible/.ssh/known_hosts
ssh-keygen -R observability.kubernerdes.lab -f /home/mansible/.ssh/known_hosts
}
