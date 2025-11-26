# SUSE Observability - Lab Version


# NOTE: NOTE: NOTE
#   YOU NEED TO UPDATE stackstate.cluster.name to the value you entered when creating the stackpack
```
helm upgrade --install \
--namespace suse-observability \
--create-namespace \
--set-string 'stackstate.apiKey'=$SERVICE_TOKEN \
--set-string 'stackstate.cluster.name'='harvester-dc' \
--set-string 'stackstate.url'='https://observability.kubernerdes.lab/receiver/stsAgent' \
--set 'nodeAgent.skipKubeletTLSVerify'=true \
--set-string 'global.skipSslValidation'=true \
suse-observability-agent suse-observability/suse-observability-agent
```
