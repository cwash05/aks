# workloadid
script for creating aks cluster with <br>
workload identity<br>
api vnet integration<br>
node and pod subnets<br>
azure network plugin<br>
azure network policy<br>
azure defender<br>
azure keyvault secrets provider<br>
kubelet identity<br>
running on Mariner/W2022 node pools<br>
<br>

A keyvault is setup with a secret 'Secret1'.<br>
A workload(managaed) identity is setup ${aksPrefix}-workid.<br>
A service accoount {aksPrefix}-sa is created in namespace {aksPrefix}-ns.<br>
A federated account is seteup ${aksPrefix}-fed.<br>
A quick-start pod is deployed to the namespace using the service account and pulls the secret from the keyvault<br>
<br>

You can get the logs for the quick-start pod to verify workload identity. 
   
**kubectl logs quick-start**

```script
I1013 22:49:29.872708       1 main.go:30] "successfully got secret" secret="Hello!"
```

#### Deploy to a location that supports Zones
./aksdeploy.sh
