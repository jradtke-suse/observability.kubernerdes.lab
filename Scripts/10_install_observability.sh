# Deploy Observability 

# NOTE: the rancherUrl bits need to be tested.  CORS was added and this should fix any issues

# I create a directory to contain all my work
mkdir -p ~/Developer/Projects/observability.kubernerdes.lab; cd $_

# Since I am running this self-hosted in my lab
helm repo add suse-observability https://charts.rancher.com/server-charts/prime/suse-observability
helm repo update

install_server() {
export O11Y_LICENSE=example
export BASEURL=observability.kubernerdes.lab
export RANCHERURL=rancher.kubernerdes.lab
export SIZING_PROFILE=10-nonha #trial

export VALUES_DIR=.
helm template \
  --set license="$O11Y_LICENSE" \
  --set baseUrl="$BASEURL" \
  --set rancherUrl="$RANCHERURL" \
  --set sizing.profile="$SIZING_PROFILE" \
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
}

install_client() {
helm upgrade --install \
--namespace suse-observability \
--create-namespace \
--set-string 'stackstate.apiKey'='SERVICE_TOKEN' \
--set-string 'stackstate.cluster.name'='rancher.kubernerdes.lab' \
--set-string 'stackstate.url'='https://observability.kubernerdes.lab/receiver/stsAgent' \
--set 'nodeAgent.skipKubeletTLSVerify'=true \
suse-observability-agent suse-observability/suse-observability-agent
}

kubectl get all -n suse-observability

# temp forward 
kubectl port-forward service/suse-observability-router 8080:8080 --namespace suse-observability


# Expose App
cat << EOF | tee suse-observability-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: suse-observability-ingress
  namespace: suse-observability
spec:
  rules:
    - host: observability.kubernerdes.lab
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: suse-observability-router
                port:
                  number: 8080
#  tls:
#    - hosts:
#        - observability.kubernerdes.lab
#      secretName: tls-secret
EOF
kubectl apply -f suse-observability-ingress.yaml

exit 0
clean_up() {
helm uninstall suse-observability-agent -n suse-observability
}

###
In summary, “SUSE Observability Trail” delivers enterprise-grade, real-time observability—while “10nonha” is a lightweight, non-HA configuration intended for smaller, less critical environments. If you expect growth or need redundancy, start with HA deployment from the beginning.
