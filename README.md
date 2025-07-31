# Readme

Deploy Stackstate in Kubernerdes Homelab

Prereqs:  You need to export STACKSTATE_LICENSE prior to running these commands.

```
kubectl config use-context k3s-stackstate
helm repo add suse-observability https://charts.rancher.com/server-charts/prime/suse-observability
helm repo update

mkdir -p $HOME/Developer/kubernerdes.lab/observability; cd $_
SIZING_PROFILE=10-nonha
SIZING_PROFILE=trial
DOMAIN=kubernerdes.lab
HOSTNAME=stackstate

[ -z ${STACKSTATE_LICENSE} ] && { echo "You need to set var: STACKSTATE_LICENSE"; exit 0; }
export VALUES_DIR=.
helm template \
  --set license="${STACKSTATE_LICENSE}" \
  --set baseUrl="https://${HOSTNAME}.${DOMAIN}" \
  --set sizing.profile="${SIZING_PROFILE}" \
  suse-observability-values \
  suse-observability/suse-observability-values --output-dir $VALUES_DIR

helm upgrade --install \
    --namespace suse-observability \
    --create-namespace \
    --values $VALUES_DIR/suse-observability-values/templates/baseConfig_values.yaml \
    --values $VALUES_DIR/suse-observability-values/templates/sizing_values.yaml \
    --values $VALUES_DIR/suse-observability-values/templates/affinity_values.yaml \
    suse-observability \
    suse-observability/suse-observability
kubectl get pods -A  | egrep -v 'Running|Completed'
kubectl get pods -A --field-selector status.phase!=Running

cat << EOF | tee ingress_values.yaml
ingress:
  enabled: true
  ingressClassName: nginx
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"
  hosts:
    - host: ${HOSTNAME}.${DOMAIN}
  tls:
    - hosts:
        - ${HOSTNAME}.${DOMAIN}
      secretName: tls-secret
EOF

kubectl get pods -A --field-selector status.phase!=Running

helm upgrade --install \
  --namespace "suse-observability" \
  --values "ingress_values.yaml" \
  --values $VALUES_DIR/suse-observability-values/templates/baseConfig_values.yaml \
  --values $VALUES_DIR/suse-observability-values/templates/sizing_values.yaml \
  --values $VALUES_DIR/suse-observability-values/templates/affinity_values.yaml \
suse-observability \
suse-observability/suse-observability
```
