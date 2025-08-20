#!/bin/bash


# check you are root
if [ `whoami` != "root" ]; then echo "ERROR: you should be root"; exit 9; fi

# Setup sudo for mansible (for later)
echo 'mansible ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/mansible-nopasswd-all

# Set some Variables for K3s
export MY_K3S_TOKEN=o11yiskey
export MY_K3S_ENDPOINT=10.10.12.180
export MY_K3S_HOSTNAME=observability.kubernerdes.lab

echo "curl -sfL https://get.k3s.io | sh -s - server --cluster-init --token ${MY_K3S_TOKEN} --tls-san ${MY_K3S_ENDPOINT},${MY_K3S_HOSTNAME}"

curl -sfL https://get.k3s.io | sh -s - server --cluster-init --token ${MY_K3S_TOKEN} --tls-san ${MY_K3S_ENDPOINT},${MY_K3S_HOSTNAME}

# 
shutdown now -r

### AS non-root user (mansible, in my case) 
export MY_K3S_ENDPOINT=10.10.12.180

# Make a copy of the KUBECONFIG for non-root use
mkdir ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config; sudo chown $(whoami) ~/.kube/config; 
export KUBECONFIG=~/.kube/config
chmod 0644 $KUBECONFIG
openssl s_client -connect 127.0.0.1:6443 -showcerts </dev/null | openssl x509 -noout -text > cert.0
grep DNS cert.0

# Replace localhost IP with the HAproxy endpoint
sed -i -e "s/127.0.0.1/${MY_K3S_ENDPOINT}/g" $KUBECONFIG
openssl s_client -connect 127.0.0.1:6443 -showcerts </dev/null | openssl x509 -noout -text > cert.1

# Manually update $KUBECONFIG to reflect cluster name (sed 's/default/observability/g', basically)
