#!/bin/bash

# This "script" was not intended to be run as a script, and instead cut-and-paste the pieces (hence no #!/bin/sh at the top ;-_

# SU to root
sudo su -

# Update local hosts file
cat << EOF | tee -a /etc/hosts
10.10.12.221 observability-01.kubernerdes.lab observability-01
10.10.12.222 observability-02.kubernerdes.lab observability-02
10.10.12.223 observability-03.kubernerdes.lab observability-03
EOF

# Set some variables
export MY_K3S_VERSION=v1.32.6+k3s1
export MY_K3S_INSTALL_CHANNEL=v1.32
export MY_K3S_TOKEN=o11yiskey
export MY_K3S_ENDPOINT=10.10.12.220
export MY_K3S_HOSTNAME=observability.kubernerdes.lab

# Run the install process
case $(uname -n) in
  observability-01)
    echo "curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=${MY_K3S_INSTALL_CHANNEL} INSTALL_K3S_EXEC=\"server --cluster-init --token ${MY_K3S_TOKEN} --tls-san ${MY_K3S_ENDPOINT},${MY_K3S_HOSTNAME}\" sh -s"
    curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=${MY_K3S_INSTALL_CHANNEL} INSTALL_K3S_EXEC="server --cluster-init --token ${MY_K3S_TOKEN} --tls-san ${MY_K3S_ENDPOINT},${MY_K3S_HOSTNAME}" sh -s
    # Orig Method (need to test the updated method, but leaving this for fallback)
    #curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=${MY_K3S_INSTALL_CHANNEL} sh -s - --server --cluster-init --token ${MY_K3S_TOKEN} --tls-san ${MY_K3S_ENDPOINT},${MY_K3S_HOSTNAME}
  ;;
  *)
    sleep 120 # Allow first node to come up
    echo "curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=${MY_K3S_INSTALL_CHANNEL} sh -s - --server https://${MY_K3S_ENDPOINT}:6443 --token ${MY_K3S_TOKEN}"
    curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=${MY_K3S_INSTALL_CHANNEL} sh -s - --server https://${MY_K3S_ENDPOINT}:6443 --token ${MY_K3S_TOKEN}
  ;;
esac

# Make a copy of the KUBECONFIG for non-root use
mkdir ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config; sudo chown $(whoami) ~/.kube/config
export KUBECONFIG=~/.kube/config
openssl s_client -connect 127.0.0.1:6443 -showcerts </dev/null | openssl x509 -noout -text > cert.0
grep DNS cert.0
mkdir ~sles/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~sles/.kube/config; sudo chown sles ~/.kube/config
sudo chown -r sles ~sles/.kbue

# Replace localhost IP with the HAproxy endpoint
sed -i -e "s/127.0.0.1/${MY_K3S_ENDPOINT}/g" $KUBECONFIG
openssl s_client -connect 127.0.0.1:6443 -showcerts </dev/null | openssl x509 -noout -text > cert.1
grep DNS cert.1

# Manually update $KUBECONFIG to reflect cluster name (sed 's/default/observability/g', basically)

exit 0
