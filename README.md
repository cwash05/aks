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

A public cluster is created with API VNet integration. <br>
The cluster has 3 nodes pools.  A dedicated system node pool<br>
A linux node pool and a Windows node pool.  Each in their own subnet<br>
Each node pool has a seperate pod subnet<br>
Autoscaling is not enabled<br>
A keyvault is setup with a secret 'Secret1'.<br>
A workload(managaed) identity is setup ${aksPrefix}WorkloadId.<br>
A service accoount {aksPrefix}-sa is created in namespace {aksPrefix}-ns.<br>
A federated account is seteup ${aksPrefix}FedId.<br>
A quick-start pod is deployed to the namespace using the service account and pulls the secret from the keyvault<br>
The link to the Grafana dashboard is printed. <br>
The Windows node exporter is installed. <br>
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
