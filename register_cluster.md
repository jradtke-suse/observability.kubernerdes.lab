# Register Cluster

Since I am running this self-hosted in my lab
helm repo add suse-observability https://charts.rancher.com/server-charts/prime/suse-observability
helm repo update

helm upgrade --install \
--namespace suse-observability \
--create-namespace \
--set-string 'stackstate.apiKey'='SERVICE_TOKEN' \
--set-string 'stackstate.cluster.name'='rancher.kubernerdes.lab' \
--set-string 'stackstate.url'='https://stackstate.kubernerdes.lab/receiver/stsAgent' \
--set 'nodeAgent.skipKubeletTLSVerify'=true \
suse-observability-agent suse-observability/suse-observability-agent

