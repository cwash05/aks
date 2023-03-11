# Base Cluster
script for creating aks cluster with <br>
workload identity<br>
api vnet integration<br>
node and pod subnets<br>
azure network plugin<br>
azure network policy<br>
azure defender<br>
azure keyvault secrets provider<br>
kubelet identity<br>
keda addon<br>
grafana managed addon<br>
promethous managed addon<br>
running on MarinerV2/W2022 node pools<br>
<br>

A keyvault is setup with a secret 'Secret1'.<br>
A workload(managaed) identity is setup ${aksPrefix}-workid.<br>
A service accoount {aksPrefix}-sa is created in namespace {aksPrefix}-ns.<br>
A federated account is seteup ${aksPrefix}-fed.<br>
A quick-start pod is deployed to the namespace using the service account and pulls the secret from the keyvault<br>
<br>

#### Deploy to a location that supports Zones
###### script is set run in a bash shell.
run
```cli
cd baseCluster
./aksdeploy.sh
```


You can get the logs for the quick-start pod to verify workload identity. 
   
**kubectl logs quick-start**

```script
I1013 22:49:29.872708       1 main.go:30] "successfully got secret" secret="Hello!"
```


#### Additonal scripts
[AGIC Cluster](https://github.com/cwash05/aks/tree/main/agicCluster)<br>
[KEDA Cluster](https://github.com/cwash05/aks/tree/main/kedaCluster)<br>  