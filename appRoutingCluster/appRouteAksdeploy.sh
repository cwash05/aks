#!/bin/bash

# Template
template="appRouteCluster.bicep"
# graftemplate="FullAzureMonitorMetricsProfile.bicep"
#parameters="main.parameters.json"

echo -n 'Enter AKS prefix: '
read aksPrefix

ZoneRegions=(
''
'AustraliaEast'
'BrazilSouth'
'CanadaCentral'
'EastAsia'
'EastUS'
'EastUS2'
'FranceCentral'
'GermanyWestCentral'
'CentralIndia'
'CentralUS'
'ChinaNorth3'
'NorthEurope'
'NorwayEast'	
'JapanEast'
'KoreaCentral'
'QatarCentral'			
'Southeast Asia'
'SouthCentralUS'	
'SouthAfricaNorth'	
'SwedenCentral'			
'SwitzerlandNorth'
'UAENorth'
'UKSouth'
'USGovVirginia'
'WestEurope'		
'WestUS2'	
'WestUS3'
)
printf "Enter the location for the resource group: (Should support Zones) \n"
select location in ${ZoneRegions[@]};
  do echo -n "you selected" $location
  break;
done

echo ''
Regions=(
"eastus"
"eastus2"
"centralindia"
"centralus"
"northeurope"
"southcentralus"
"southeastasia"
"uksouth"
"westeurope"
"westus"
"westus2") 
printf "Enter the location for the Azure Monitor Workspace: \n"
select azureMonitorLocation in ${Regions[@]};
  do echo -n "you selected" $azureMonitorLocation
  break;
done

echo ''
GrafanaRegions=(
''
'AustraliaEast'
'CanadaCentral'
'EastAsia'
'EastUS'
'EastUS2'
'CentralUS'
'NorthEurope'
'SouthCentralUS'	
'SwedenCentral'			
'UKSouth'
'WestCentralUS'
'WestEurope'		
'WestUS3'
)
printf "Enter the location for the Grafana dashboard \n"
select grafanaLocation in ${GrafanaRegions[@]};
  do echo -n "you selected" $grafanaLocation
  break;
done

# echo -n 'Enter the Admin password'
# read -sp 'Password: ' admin_pw 
echo

aksResourceGroupName="${aksPrefix}-${location}-rg"
userAssnFedIdName="${aksPrefix}WorkloadId"
fedCredentialIdName="${aksPrefix}FedId"  
serviceAccountName="${aksPrefix,,}-sa" 
serviceAccountNamespace="${aksPrefix,,}-ns" 
dnsZoneName="${aksPrefix,,}.com" 

# AKS cluster name
aksName="${aksPrefix}-aks"
validateTemplate=1
useWhatIf=1
update=1
installExtensions=1
ids=("ccpID_$aksName" "kubeletID_$aksName")

# Subscription id, subscription name, and tenant id of the current subscription
subscriptionId=$(az account show --query id --output tsv)
subscriptionName=$(az account show --query name --output tsv)
tenantId=$(az account show --query tenantId --output tsv)

# Get the user principal name of the current user
echo "Retrieving the user principal name of the current user from the [$tenantId] Azure AD tenant..."
userPrincipalName=$(az account show --query user.name --output tsv)
if [[ -n $userPrincipalName ]]; then
  echo "[$userPrincipalName] user principal name successfully retrieved from the [$tenantId] Azure AD tenant"
else
  echo "Failed to retrieve the user principal name of the current user from the [$tenantId] Azure AD tenant"
  exit
fi

# Retrieve the objectId of the user in the Azure AD tenant used by AKS for user authentication
echo "Retrieving the objectId of the [$userPrincipalName] user principal name from the [$tenantId] Azure AD tenant..."
userObjectId=$(az ad user show --id $userPrincipalName --query id --output tsv)

if [[ -n $userObjectId ]]; then
  echo "[$userObjectId] objectId successfully retrieved for the [$userPrincipalName] user principal name"
else
  echo "Failed to retrieve the objectId of the [$userPrincipalName] user principal name"
  exit
fi

# Install aks-preview Azure extension
if [[ $installExtensions == 1 ]]; then
  echo "Checking if [aks-preview] extension is already installed..."
  az extension show --name aks-preview #&>/dev/null

  if [[ $? == 0 ]]; then
    echo "[aks-preview] extension is already installed"

    # Update the extension to make sure you have the latest version installed
    echo "Updating [aks-preview] extension..."
    az extension update --name aks-preview &>/dev/null
  else
    echo "[aks-preview] extension is not installed. Installing..."

    # Install aks-preview extension
    az extension add --name aks-preview 1>/dev/null

    if [[ $? == 0 ]]; then
      echo "[aks-preview] extension successfully installed"
    else
      echo "Failed to install [aks-preview] extension"
      exit
    fi
  fi

  # Registering AKS feature extensions
    aksExtensions=(
    "KubeletDisk"
    "AKS-PrometheusAddonPreview"
    "AKS-KedaPreview"
    "RunCommandPreview"
    "UserAssignedIdentityPreview"
    "EnablePrivateClusterPublicFQDN"
    "PodSubnetPreview"
    "EnableOIDCIssuerPreview"
    "EnableWorkloadIdentityPreview"
    "EnableImageCleanerPreview"
    "AKSWindowsGmsaPreview"
    "EnableAPIServerVnetIntegrationPreview"
    "PodSubnetPreview"
    "AKS-AzureKeyVaultSecretsProvider"
    "EnableAzureDiskFileCSIDriver"
    "AKS-GitOps")
  ok=0
  registeringExtensions=()
  for aksExtension in ${aksExtensions[@]}; do
    echo "Checking if [$aksExtension] extension is already registered..."
    extension=$(az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/$aksExtension') && @.properties.state == 'Registered'].{Name:name}" --output tsv)
    if [[ -z $extension ]]; then
      echo "[$aksExtension] extension is not registered."
      echo "Registering [$aksExtension] extension..."
      az feature register --name $aksExtension --namespace Microsoft.ContainerService
      registeringExtensions+=("$aksExtension")
      ok=1
    else
      echo "[$aksExtension] extension is already registered."
    fi
  done
  echo $registeringExtensions
  delay=1
  for aksExtension in ${registeringExtensions[@]}; do
    echo -n "Checking if [$aksExtension] extension is already registered..."
    while true; do
      extension=$(az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/$aksExtension') && @.properties.state == 'Registered'].{Name:name}" --output tsv)
      if [[ -z $extension ]]; then
        echo -n "."
        sleep $delay
      else
        echo "."
        break
      fi
    done
  done

  if [[ $ok == 1 ]]; then
    echo "Refreshing the registration of the Microsoft.ContainerService resource provider..."
    az provider register --namespace Microsoft.ContainerService
    echo "Microsoft.ContainerService resource provider registration successfully refreshed"
  fi
fi

# Get the last Kubernetes version available in the region
kubernetesVersion=$(az aks get-versions --location $location --query "orchestrators[?isPreview==false].orchestratorVersion | sort(@) | [-1]" --output tsv)

if [[ -n $kubernetesVersion ]]; then
  echo "Successfully retrieved the last Kubernetes version [$kubernetesVersion] supported by AKS in [$location] Azure region"
else
  echo "Failed to retrieve the last Kubernetes version supported by AKS in [$location] Azure region"
  exit
fi

# Check if the resource group already exists
echo "Checking if [$aksResourceGroupName] resource group actually exists in the [$subscriptionName] subscription..."

az group show --name $aksResourceGroupName &>/dev/null

if [[ $? != 0 ]]; then
  echo "No [$aksResourceGroupName] resource group actually exists in the [$subscriptionName] subscription"
  echo "Creating [$aksResourceGroupName] resource group in the [$subscriptionName] subscription..."

  # Create the resource group
  az group create --name $aksResourceGroupName --location $location 1>/dev/null

  echo 'Creating user assigned mananged identity for workload identity' $userAssnFedIdName
  az identity create --name $userAssnFedIdName --resource-group $aksResourceGroupName --location $location 

  if [[ $? == 0 ]]; then
    echo "[$aksResourceGroupName] resource group successfully created in the [$subscriptionName] subscription"
  else
    echo "Failed to create [$aksResourceGroupName] resource group in the [$subscriptionName] subscription"
    exit
  fi
else
  echo "[$aksResourceGroupName] resource group already exists in the [$subscriptionName] subscription"
fi


userAssnFedIdNameClientId="$(az identity show --resource-group $aksResourceGroupName --name $userAssnFedIdName --query 'clientId' -otsv)"
userAssnFedIdNameObjectId="$(az identity show --resource-group $aksResourceGroupName --name $userAssnFedIdName --query 'principalId' -otsv)"



# Create AKS cluster if does not exist
echo "Checking if [$aksName] aks cluster actually exists in the [$aksResourceGroupName] resource group..."

az aks show --name $aksName --resource-group $aksResourceGroupName &>/dev/null
notExists=$?

if [[ $notExists != 0 || $update == 1 ]]; then

  if [[ $notExists != 0 ]]; then
    echo "No [$aksName] aks cluster actually exists in the [$aksResourceGroupName] resource group"
    assignments=true
  else
    echo "[$aksName] aks cluster already exists in the [$aksResourceGroupName] resource group. Updating the cluster..."
    assignments=false
  fi

  # Delete any existing role assignments for the user-defined managed identity of the AKS cluster
  # in case you are re-deploying the solution in an existing resource group
  for id in "ccpID_$aksName" "kubeletID_$aksName" 
  do
    echo "Retrieving the list of role assignments for id [$id] in the [$aksResourceGroupName] resource group..."
    assignmentIds=$(az role assignment list \
      --scope "/subscriptions/${subscriptionId}/resourceGroups/${aksResourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$id" \
      --query [].id \
      --output tsv \
      --only-show-errors)
  
    if [[ -n $assignmentIds ]]; then
      echo "[${#assignmentIds[@]}] role assignments have been found on id [$id] in [$aksResourceGroupName] resource group"
      for assignmentId in ${assignmentIds[@]}; do
        if [[ -n $assignmentId ]]; then
          az role assignment delete --ids $assignmentId
  
          if [[ $? == 0 ]]; then
            assignmentName=$(echo $assignmentId | awk -F '/' '{print $NF}')
            echo "[$assignmentName] role assignment for [$id] in  [$aksResourceGroupName] resource group successfully deleted"

          fi
        fi
      done
    else
     echo "No role assignment for [$id] actually exists on [$aksResourceGroupName] resource group"

    fi
  done

  # Get the kubelet managed identity used by the AKS cluster
  echo "Retrieving the kubelet identity from the [$aksName] AKS cluster..."
  clientId=$(az aks show \
    --name $aksName \
    --resource-group $aksResourceGroupName \
    --query identityProfile.kubeletidentity.clientId \
    --output tsv 2>/dev/null)


  # Validate the Bicep template
  if [[ $validateTemplate == 1 ]]; then
    if [[ $useWhatIf == 1 ]]; then
      # Execute a deployment What-If operation at resource group scope.
      echo "Previewing changes deployed by [$template] Bicep template..."
      az deployment group what-if \
        --resource-group $aksResourceGroupName \
        --template-file $template \
        --parameters cluster_name=$aksName \
        kubernetes_version=$kubernetesVersion \
        aksPrefix=$aksPrefix \
        userAssnFedIdNameObjectId=$userAssnFedIdNameObjectId \
        userObjectId=$userObjectId \
        assignments=$assignments \
        azureMonitorLocation=$azureMonitorLocation \
        grafanaLocation=$grafanaLocation


      if [[ $? == 0 ]]; then
        echo "[$template] Bicep template validation succeeded"
      else
        echo "Failed to validate [$template] Bicep template"
        exit
      fi
    else
      # Validate the Bicep template
      echo "Validating [$template] Bicep template..."
      output=$(az deployment group validate \
        --resource-group $aksResourceGroupName \
        --template-file $template \
        --parameters cluster_name=$aksName \
        kubernetes_version=$kubernetesVersion \
        aksPrefix=$aksPrefix \
        userAssnFedIdNameObjectId=$userAssnFedIdNameObjectId \
        userObjectId=$userObjectId \
        assignments=$assignments \
        azureMonitorLocation=$azureMonitorLocation \
        grafanaLocation=$grafanaLocation) 

      if [[ $? == 0 ]]; then
        echo "[$template] Bicep template validation succeeded"
      else
        echo "Failed to validate [$template] Bicep template"
        echo $output
        exit
      fi
    fi
  fi

  # Deploy the Bicep cluster template
  echo "Deploying [$template] Bicep cluster template..."
  az deployment group create \
    --resource-group $aksResourceGroupName \
    --only-show-errors \
    --template-file $template \
    --parameters cluster_name=$aksName \
    kubernetes_version=$kubernetesVersion \
    aksPrefix=$aksPrefix \
    userAssnFedIdNameObjectId=$userAssnFedIdNameObjectId \
    userObjectId=$userObjectId \
    assignments=$assignments \
    azureMonitorLocation=$azureMonitorLocation \
    grafanaLocation=$grafanaLocation

  if [[ $? == 0 ]]; then
    echo "[$template] Bicep template successfully provisioned"
  else
    echo "Failed to provision the [$template] Bicep template"
    exit
  fi
else
  echo "[$aksName] aks cluster already exists in the [$aksResourceGroupName] resource group"
fi


# Retrieve the resource id of the AKS cluster
echo "Retrieving the resource id of the [$aksName] AKS cluster..."
aksClusterId=$(az aks show \
  --name "$aksName" \
  --resource-group "$aksResourceGroupName" \
  --query id \
  --output tsv 2>/dev/null)

if [[ -n $aksClusterId ]]; then
  echo "Resource id of the [$aksName] AKS cluster successfully retrieved"
else
  echo "Failed to retrieve the resource id of the [$aksName] AKS cluster"
  exit
fi

echo 'Retreiving the OIDC URL'
AKS_OIDC_ISSUER="$(az aks show -n $aksName -g $aksResourceGroupName --query "oidcIssuerProfile.issuerUrl" -otsv)"
echo $AKS_OIDC_ISSUER

keyVaultName=$(az deployment group show  -g $aksResourceGroupName -n ${template/.bicep} --query properties.outputs.keyVaultName.value -otsv)
kvSecretName=$(az deployment group show  -g $aksResourceGroupName -n ${template/.bicep} --query properties.outputs.kvSecretName.value -otsv)
keyVaultUri=$(az deployment group show  -g $aksResourceGroupName -n ${template/.bicep} --query properties.outputs.keyVaultUri.value -otsv)

grafanaDashboardUrl=$(az deployment group show  -g $aksResourceGroupName -n ${template/.bicep}  --query properties.outputs.grafanaDashboardUrl.value -otsv)



echo 'Logging into clusster'
az aks get-credentials -n $aksName -g $aksResourceGroupName


namespaceStatus=$(kubectl get ns $serviceAccountNamespace -o json | jq .status.phase -r)
if [[ $namespaceStatus != "Active" ]]; then
    kubectl create ns $serviceAccountNamespace
  

echo 'Creating service acount'
cat <<EOF | kubectl apply -f - 
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: ${userAssnFedIdNameClientId}
  labels:
    azure.workload.identity/use: "true"
  name: $serviceAccountName
  namespace: $serviceAccountNamespace
---  
EOF


echo 'Creating federated identity ' $fedIdName
az identity federated-credential create --name $fedCredentialIdName --identity-name $userAssnFedIdName --resource-group $aksResourceGroupName --issuer $AKS_OIDC_ISSUER --subject system:serviceaccount:$serviceAccountNamespace:$serviceAccountName

echo 'Creating pod'
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: quick-start
  namespace: $serviceAccountNamespace
  labels:
    azure.workload.identity/use: "true"
spec:
  serviceAccountName: $serviceAccountName
  containers:
    - image: ghcr.io/azure/azure-workload-identity/msal-go
      name: oidc
      env:
      - name: KEYVAULT_URL
        value: $keyVaultUri
      - name: SECRET_NAME
        value: $kvSecretName
  nodeSelector:
    kubernetes.io/os: linux
---
EOF
else
echo "Namespace [${serviceAccountNamespace}] already exist."
fi  


cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aks-helloworld  
spec:
  replicas: 1
  selector:
    matchLabels:
      app: aks-helloworld
  template:
    metadata:
      labels:
        app: aks-helloworld
    spec:
      containers:
      - name: aks-helloworld
        image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
        ports:
        - containerPort: 80
        env:
        - name: TITLE
          value: "Welcome to Azure Kubernetes Service (AKS)"
      nodeSelector:
        kubernetes.io/os: linux
---
apiVersion: v1
kind: Service
metadata:
  name: aks-helloworld
spec:
  type: ClusterIP
  ports:
  - port: 80
  selector:
    app: aks-helloworld
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
  name: aks-helloworld
spec:
  ingressClassName: webapprouting.kubernetes.azure.com
  rules:
  - http:
      paths:
      - backend:
          service:
            name: aks-helloworld
            port:
              number: 80
        path: /
        pathType: Prefix
---
EOF



echo '**********************'

kubectl create ns monitoring
kubectl apply -f ../utility/metricsMonitor/windows-exporter-ds.yaml
kubectl apply -f ../utility/metricsMonitor/ama-metrics-settings-cm.yaml

# adminpw=$(az deployment group show  -g $aksResourceGroupName -n ${template/.bicep} --query properties.outputs.adminpw.value -otsv)
sleep 10
appRoutingId=$(az aks show -g $aksResourceGroupName -n $aksName --query ingressProfile.webAppRouting.identity.objectId -o tsv)
dnsZoneId=$(az network dns zone show -g $aksResourceGroupName -n $dnsZoneName --query "id" --output tsv)

sleep 15
ingressIp=$(kubectl get ingress aks-helloworld --output jsonpath='{.status.loadBalancer.ingress[0].ip}')

# echo App Routing Id: $appRoutingId
# echo DNS Zone id: $dnsZoneId
# echo Ingress Ip: $ingressIp

echo "Creating role assignment"
MSYS_NO_PATHCONV=1 az role assignment create --role "DNS Zone Contributor" --assignee $appRoutingId --scope $dnsZoneId
echo
echo "Creating NSG Rule"
az network nsg rule create --resource-group $aksResourceGroupName --nsg-name "$aksPrefix-vnet-linuxz1-sub-nsg" --name Allow-HTTP-All --access Allow --protocol Tcp --direction Inbound --priority 500 --source-address-prefix Internet --source-port-range "*" --destination-address-prefix $ingressIp --destination-port-range 80


echo "Running logs quick-start -n $serviceAccountNamespace"
kubectl logs quick-start -n $serviceAccountNamespace
echo
echo 'Grafana dashboard Url:' $grafanaDashboardUrl
echo 'Aspnet application URL: http://'$ingressIp
echo
echo 'Finished'
echo '*************************'