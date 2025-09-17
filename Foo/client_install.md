# SUSE Observability - Lab Version


```
helm upgrade --install \
--namespace suse-observability \
--create-namespace \
--set-string 'stackstate.apiKey'='svctok-fIQxfGzepXWavlqd8ddyC5VtNpfbInRl' \
--set-string 'stackstate.cluster.name'='rancher' \
--set-string 'stackstate.url'='https://observability.kubernerdes.lab/receiver/stsAgent' \
--set 'nodeAgent.skipKubeletTLSVerify'=true \
--set-string 'global.skipSslValidation'=true \
suse-observability-agent suse-observability/suse-observability-agent
```
