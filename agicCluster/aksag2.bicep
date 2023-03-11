@description('Specifies the location of AKS cluster.')
param location string 
param aksPrefix string
// @description('Specifies the name of the AKS cluster.')
// param aksClusterName string = 'aks-${uniqueString(resourceGroup().id)}'

// @description('Specifies the DNS prefix specified when creating the managed cluster.')
// param aksClusterDnsPrefix string = aksClusterName

// @description('Specifies the tags of the AKS cluster.')
// param aksClusterTags object = {
//   resourceType: 'AKS Cluster'
//   createdBy: 'ARM Template'
// }

// @description('Specifies the network plugin used for building Kubernetes network. - azure or kubenet.')
// @allowed([
//   'azure'
//   'kubenet'
// ])
// param aksClusterNetworkPlugin string = 'azure'

// @description('Specifies the network policy used for building Kubernetes network. - calico or azure')
// @allowed([
//   'azure'
//   'calico'
// ])
// param aksClusterNetworkPolicy string = 'azure'

// @description('Specifies the CIDR notation IP range from which to assign pod IPs when kubenet is used.')
// param aksClusterPodCidr string = '10.244.0.0/16'

// @description('A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges.')
// param aksClusterServiceCidr string = '10.3.0.0/16'

// @description('Specifies the IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in serviceCidr.')
// param aksClusterDnsServiceIP string = '10.3.0.10'

// @description('Specifies the CIDR notation IP range assigned to the Docker bridge network. It must not overlap with any Subnet IP ranges or the Kubernetes service address range.')
// param aksClusterDockerBridgeCidr string = '172.17.0.1/16'

// @description('Specifies the sku of the load balancer used by the virtual machine scale sets used by nodepools.')
// @allowed([
//   'basic'
//   'standard'
// ])
// param aksClusterLoadBalancerSku string = 'standard'

// @description('Specifies outbound (egress) routing method. - loadBalancer or userDefinedRouting.')
// @allowed([
//   'loadBalancer'
//   'userDefinedRouting'
// ])
// param aksClusterOutboundType string = 'loadBalancer'

// @description('Specifies the tier of a managed cluster SKU: Paid or Free')
// @allowed([
//   'Paid'
//   'Free'
// ])
// param aksClusterSkuTier string = 'Paid'

// @description('Specifies the version of Kubernetes specified when creating the managed cluster.')
// param aksClusterKubernetesVersion string = '1.20.5'

// @description('Specifies the administrator username of Linux virtual machines.')
// param aksClusterAdminUsername string

// @description('Specifies the SSH RSA public key string for the Linux nodes.')
// param aksClusterSshPublicKey string

// @description('Specifies whether enabling AAD integration.')
// param aadEnabled bool = false

// @description('Specifies the tenant id of the Azure Active Directory used by the AKS cluster for authentication.')
// param aadProfileTenantId string = subscription().tenantId

// @description('Specifies the AAD group object IDs that will have admin role of the cluster.')
// param aadProfileAdminGroupObjectIDs array = []

// @description('Specifies whether to create the cluster as a private cluster or not.')
// param aksClusterEnablePrivateCluster bool = false

// @description('Specifies whether to enable managed AAD integration.')
// param aadProfileManaged bool = false

// @description('Specifies whether to  to enable Azure RBAC for Kubernetes authorization.')
// param aadProfileEnableAzureRBAC bool = false

// @description('Specifies the unique name of of the system node pool profile in the context of the subscription and resource group.')
// param systemNodePoolName string = 'system'

// @description('Specifies the vm size of nodes in the system node pool.')
// param systemNodePoolVmSize string = 'Standard_D16s_v3'

// @description('Specifies the OS Disk Size in GB to be used to specify the disk size for every machine in the system agent pool. If you specify 0, it will apply the default osDisk size according to the vmSize specified..')
// param systemNodePoolOsDiskSizeGB int = 100

// @description('Specifies the number of agents (VMs) to host docker containers in the system node pool. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1.')
// param systemNodePoolAgentCount int = 3

// @description('Specifies the OS type for the vms in the system node pool. Choose from Linux and Windows. Default to Linux.')
// @allowed([
//   'Linux'
//   'Windows'
// ])
// param systemNodePoolOsType string = 'Linux'

// @description('Specifies the maximum number of pods that can run on a node in the system node pool. The maximum number of pods per node in an AKS cluster is 250. The default maximum number of pods per node varies between kubenet and Azure CNI networking, and the method of cluster deployment.')
// param systemNodePoolMaxPods int = 30

// @description('Specifies the maximum number of nodes for auto-scaling for the system node pool.')
// param systemNodePoolMaxCount int = 5

// @description('Specifies the minimum number of nodes for auto-scaling for the system node pool.')
// param systemNodePoolMinCount int = 3

// @description('Specifies whether to enable auto-scaling for the system node pool.')
// param systemNodePoolEnableAutoScaling bool = true

// @description('Specifies the virtual machine scale set priority in the system node pool: Spot or Regular.')
// @allowed([
//   'Spot'
//   'Regular'
// ])
// param systemNodePoolScaleSetPriority string = 'Regular'

// @description('Specifies the ScaleSetEvictionPolicy to be used to specify eviction policy for spot virtual machine scale set. Default to Delete. Allowed values are Delete or Deallocate.')
// @allowed([
//   'Delete'
//   'Deallocate'
// ])
// param systemNodePoolScaleSetEvictionPolicy string = 'Delete'

// @description('Specifies the Agent pool node labels to be persisted across all nodes in the system node pool.')
// param systemNodePoolNodeLabels object = {
// }

// @description('Specifies the taints added to new nodes during node pool create and scale. For example, key=value:NoSchedule. - string')
// param systemNodePoolNodeTaints array = []

// @description('Specifies the type for the system node pool: VirtualMachineScaleSets or AvailabilitySet')
// @allowed([
//   'VirtualMachineScaleSets'
//   'AvailabilitySet'
// ])
// param systemNodePoolType string = 'VirtualMachineScaleSets'

// @description('Specifies the availability zones for the agent nodes in the system node pool. Requirese the use of VirtualMachineScaleSets as node pool type.')
// param systemNodePoolAvailabilityZones array = []

// @description('Specifies the unique name of of the user node pool profile in the context of the subscription and resource group.')
// param userNodePoolName string = 'user'

// @description('Specifies the vm size of nodes in the user node pool.')
// param userNodePoolVmSize string = 'Standard_D16s_v3'

// @description('Specifies the OS Disk Size in GB to be used to specify the disk size for every machine in the system agent pool. If you specify 0, it will apply the default osDisk size according to the vmSize specified..')
// param userNodePoolOsDiskSizeGB int = 100

// @description('Specifies the number of agents (VMs) to host docker containers in the user node pool. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1.')
// param userNodePoolAgentCount int = 3

// @description('Specifies the OS type for the vms in the user node pool. Choose from Linux and Windows. Default to Linux.')
// @allowed([
//   'Linux'
//   'Windows'
// ])
// param userNodePoolOsType string = 'Linux'

// @description('Specifies the maximum number of pods that can run on a node in the user node pool. The maximum number of pods per node in an AKS cluster is 250. The default maximum number of pods per node varies between kubenet and Azure CNI networking, and the method of cluster deployment.')
// param userNodePoolMaxPods int = 30

// @description('Specifies the maximum number of nodes for auto-scaling for the user node pool.')
// param userNodePoolMaxCount int = 5

// @description('Specifies the minimum number of nodes for auto-scaling for the user node pool.')
// param userNodePoolMinCount int = 3

// @description('Specifies whether to enable auto-scaling for the user node pool.')
// param userNodePoolEnableAutoScaling bool = true

// @description('Specifies the virtual machine scale set priority in the user node pool: Spot or Regular.')
// @allowed([
//   'Spot'
//   'Regular'
// ])
// param userNodePoolScaleSetPriority string = 'Regular'

// @description('Specifies the ScaleSetEvictionPolicy to be used to specify eviction policy for spot virtual machine scale set. Default to Delete. Allowed values are Delete or Deallocate.')
// @allowed([
//   'Delete'
//   'Deallocate'
// ])
// param userNodePoolScaleSetEvictionPolicy string = 'Delete'

// @description('Specifies the Agent pool node labels to be persisted across all nodes in the user node pool.')
// param userNodePoolNodeLabels object = {
// }

// @description('Specifies the taints added to new nodes during node pool create and scale. For example, key=value:NoSchedule. - string')
// param userNodePoolNodeTaints array = []

// @description('Specifies the type for the user node pool: VirtualMachineScaleSets or AvailabilitySet')
// @allowed([
//   'VirtualMachineScaleSets'
//   'AvailabilitySet'
// ])
// param userNodePoolType string = 'VirtualMachineScaleSets'

// @description('Specifies the availability zones for the agent nodes in the user node pool. Requirese the use of VirtualMachineScaleSets as node pool type.')
// param userNodePoolAvailabilityZones array = []

// @description('Specifies whether the httpApplicationRouting add-on is enabled or not.')
// param httpApplicationRoutingEnabled bool = false

// @description('Specifies whether the aciConnectorLinux add-on is enabled or not.')
// param aciConnectorLinuxEnabled bool = false

// @description('Specifies whether the azurepolicy add-on is enabled or not.')
// param azurePolicyEnabled bool = true

// @description('Specifies whether the kubeDashboard add-on is enabled or not.')
// param kubeDashboardEnabled bool = false

// @description('Specifies whether the pod identity addon is enabled..')
// param podIdentityProfileEnabled bool = false

// @description('Specifies the scan interval of the auto-scaler of the AKS cluster.')
// param autoScalerProfileScanInterval string = '10s'

// @description('Specifies the scale down delay after add of the auto-scaler of the AKS cluster.')
// param autoScalerProfileScaleDownDelayAfterAdd string = '10m'

// @description('Specifies the scale down delay after delete of the auto-scaler of the AKS cluster.')
// param autoScalerProfileScaleDownDelayAfterDelete string = '20s'

// @description('Specifies scale down delay after failure of the auto-scaler of the AKS cluster.')
// param autoScalerProfileScaleDownDelayAfterFailure string = '3m'

// @description('Specifies the scale down unneeded time of the auto-scaler of the AKS cluster.')
// param autoScalerProfileScaleDownUnneededTime string = '10m'

// @description('Specifies the scale down unready time of the auto-scaler of the AKS cluster.')
// param autoScalerProfileScaleDownUnreadyTime string = '20m'

// @description('Specifies the utilization threshold of the auto-scaler of the AKS cluster.')
// param autoScalerProfileUtilizationThreshold string = '0.5'

// @description('Specifies the max graceful termination time interval in seconds for the auto-scaler of the AKS cluster.')
// param autoScalerProfileMaxGracefulTerminationSec string = '600'

// @description('Specifies the name of the virtual network.')
// param virtualNetworkName string = '${aksClusterName}Vnet'

// // @description('Specifies the address prefixes of the virtual network.')
// // param virtualNetworkAddressPrefixes string = '10.0.0.0/8'

// @description('Specifies the name of the subnet hosting the system node pool of the AKS cluster.')
// param aksSubnetName string = 'AksSubnet'

// // @description('Specifies the address prefix of the subnet hosting the system node pool of the AKS cluster.')
// // param aksSubnetAddressPrefix string = '10.0.0.0/16'

// @description('Specifies the name of the Log Analytics Workspace.')
// param logAnalyticsWorkspaceName string = '${aksClusterName}Workspace'

// @description('Specifies the service tier of the workspace: Free, Standalone, PerNode, Per-GB.')
// @allowed([
//   'Free'
//   'Standalone'
//   'PerNode'
//   'PerGB2018'
// ])
// param logAnalyticsSku string = 'PerGB2018'

// @description('Specifies the workspace data retention in days. -1 means Unlimited retention for the Unlimited Sku. 730 days is the maximum allowed for all other Skus.')
// param logAnalyticsRetentionInDays int = 60

// @description('Specifies the name of the subnet which contains the virtual machine.')
// param vmSubnetName string = 'VmSubnet'

// @description('Specifies the address prefix of the subnet which contains the virtual machine.')
// param vmSubnetAddressPrefix string = '10.1.0.0/16'

// @description('Specifies the name of the subnet which contains the the Application Gateway.')
// param applicationGatewaySubnetName string = 'AppGatewaySubnet'

// @description('Specifies the address prefix of the subnet which contains the Application Gateway.')
// param applicationGatewaySubnetAddressPrefix string = '10.2.0.0/24'

// @description('Specifies the name of the virtual machine.')
// param vmName string = 'TestVm'

// @description('Specifies the size of the virtual machine.')
// param vmSize string = 'Standard_D4s_v3'

// @description('Specifies the image publisher of the disk image used to create the virtual machine.')
// param imagePublisher string = 'Canonical'

// @description('Specifies the offer of the platform image or marketplace image used to create the virtual machine.')
// param imageOffer string = 'UbuntuServer'

// @description('Specifies the Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version.')
// param imageSku string = '18.04-LTS'

// @description('Specifies the type of authentication when accessing the Virtual Machine. SSH key is recommended.')
// @allowed([
//   'sshPublicKey'
//   'password'
// ])
// param authenticationType string = 'password'

// @description('Specifies the name of the administrator account of the virtual machine.')
// param vmAdminUsername string

// @description('Specifies the SSH Key or password for the virtual machine. SSH key is recommended.')
// @secure()
// param vmAdminPasswordOrKey string

// @description('Specifies the storage account type for OS and data disk.')
// @allowed([
//   'Premium_LRS'
//   'Premium_ZRS'
//   'StandardSSD_LRS'
//   'StandardSSD_ZRS'
//   'Standard_LRS'
// ])
// param diskStorageAccounType string = 'Premium_LRS'

// @description('Specifies the number of data disks of the virtual machine.')
// @minValue(0)
// @maxValue(64)
// param numDataDisks int = 1

// @description('Specifies the size in GB of the OS disk of the VM.')
// param osDiskSize int = 50

// @description('Specifies the size in GB of the OS disk of the virtual machine.')
// param dataDiskSize int = 50

// @description('Specifies the caching requirements for the data disks.')
// param dataDiskCaching string = 'ReadWrite'

// @description('Specifies the globally unique name for the storage account used to store the boot diagnostics logs of the virtual machine.')
// param blobStorageAccountName string = 'boot${uniqueString(resourceGroup().id)}'

// @description('Specifies the name of the private link to the boot diagnostics storage account.')
// param blobStorageAccountPrivateEndpointName string = 'BlobStorageAccountPrivateEndpoint'

// @description('Specifies the name of the private link to the Azure Container Registry.')
// param acrPrivateEndpointName string = 'AcrPrivateEndpoint'

// @description('Name of your Azure Container Registry')
// @minLength(5)
// @maxLength(50)
// param acrName string = 'acr${uniqueString(resourceGroup().id)}'

// @description('Enable admin user that have push / pull permission to the registry.')
// param acrAdminUserEnabled bool = false

// @description('The default action of allow or deny when no other rules match. Allowed values: Allow or Deny')
// @allowed([
//   'Allow'
//   'Deny'
// ])
// param acrNetworkRuleSetDefaultAction string = 'Deny'

// @description('Whether or not public network access is allowed for the container registry. Allowed values: Enabled or Disabled')
// @allowed([
//   'Enabled'
//   'Disabled'
// ])
// param acrPublicNetworkAccess string = 'Enabled'

// @description('Tier of your Azure Container Registry.')
// @allowed([
//   'Basic'
//   'Standard'
//   'Premium'
// ])
// param acrSku string = 'Premium'

// @description('Specifies the Bastion subnet IP prefix. This prefix must be within vnet IP prefix address space.')
// param bastionSubnetAddressPrefix string = '10.2.1.0/24'

// @description('Specifies the name of the Azure Bastion resource.')
// param bastionHostName string = '${aksClusterName}Bastion'

// @description('Specifies the name of the private link to the Key Vault.')
// param keyVaultPrivateEndpointName string = 'KeyVaultPrivateEndpoint'

// @description('Specifies the name of the Key Vault resource.')
// param keyVaultName string = 'keyvault-${uniqueString(resourceGroup().id)}'

// @description('The default action of allow or deny when no other rules match. Allowed values: Allow or Deny')
// @allowed([
//   'Allow'
//   'Deny'
// ])
// param keyVaultNetworkRuleSetDefaultAction string = 'Deny'

@description('Specifies the name of the Application Gateway.')
param applicationGatewayName string 

@description('Specifies the availability zones of the Application Gateway.')
param applicationGatewayZones array = []


param applicationGatewaySubnetId string

// @description('Specifies the name of the WAF policy')
// param wafPolicyName string = '${applicationGatewayName}WafPolicy'

// @description('Specifies the mode of the WAF policy.')
// @allowed([
//   'Detection'
//   'Prevention'
// ])
// // param wafPolicyMode string = 'Prevention'

// @description('Specifies the state of the WAF policy.')
// @allowed([
//   'Enabled'
//   'Disabled '
// ])
// param wafPolicyState string = 'Enabled'

// @description('Specifies the maximum file upload size in Mb for the WAF policy.')
// param wafPolicyFileUploadLimitInMb int = 100

// @description('Specifies the maximum request body size in Kb for the WAF policy.')
// param wafPolicyMaxRequestBodySizeInKb int = 128

// @description('Specifies the whether to allow WAF to check request Body.')
// param wafPolicyRequestBodyCheck bool = true

// @description('Specifies the rule set type.')
// param wafPolicyRuleSetType string = 'OWASP'

// @description('Specifies the rule set version.')
// param wafPolicyRuleSetVersion string = '3.1'


param baseTime string = utcNow()

var guidGen = dateTimeAdd(baseTime, '-P9D')

// var readerRoleDefinitionName = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
var contributorRoleDefinitionName = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
// var acrPullRoleDefinitionName = '7f951dda-4ed3-4680-a7ca-43fe172d538d'
// var aksClusterUserDefinedManagedIdentityName = '${aksClusterName}ManagedIdentity'
// var aksClusterUserDefinedManagedIdentityId = aksClusterUserDefinedManagedIdentity.id
// var applicationGatewayUserDefinedManagedIdentityName = '${applicationGatewayName}ManagedIdentity'
// var applicationGatewayUserDefinedManagedIdentityId = applicationGatewayUserDefinedManagedIdentity.id
// var aadPodIdentityUserDefinedManagedIdentityName = '${aksClusterName}AadPodManagedIdentity'
// var aadPodIdentityUserDefinedManagedIdentityId = aadPodIdentityUserDefinedManagedIdentity.id
// var vmSubnetNsgName = '${vmSubnetName}Nsg'
// var vmSubnetNsgId = vmSubnetNsg.id
// var virtualNetworkId = virtualNetwork.id
// var bastionSubnetNsgName = '${bastionHostName}Nsg'
// var bastionSubnetNsgId = bastionSubnetNsg.id
// var aksSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, aksSubnetName)
// var vmSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, vmSubnetName)
// var applicationGatewaySubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, applicationGatewaySubnetName)
// var vmNicName = '${vmName}Nic'
// var vmNicId = vmNic.id
// var blobStorageAccountId = blobStorageAccount.id
// var blobPublicDNSZoneForwarder = 'blob.${environment().suffixes.storage}'
// var blobPrivateDnsZoneName = 'privatelink.${blobPublicDNSZoneForwarder}'
// var blobPrivateDnsZoneId = blobPrivateDnsZone.id
// var blobStorageAccountPrivateEndpointGroupName = 'blob'
// var blobPrivateDnsZoneGroupName = '${blobStorageAccountPrivateEndpointGroupName}PrivateDnsZoneGroup'
// var blobStorageAccountPrivateEndpointId = blobStorageAccountPrivateEndpoint.id
// var vmId = vm.id
// var omsAgentForLinuxName = 'LogAnalytics'
// var omsAgentForLinuxId = vmName_omsAgentForLinux.id
// var omsDependencyAgentForLinuxName = 'DependencyAgent'
// var linuxConfiguration = {
//   disablePasswordAuthentication: true
//   ssh: {
//     publicKeys: [
//       {
//         path: '/home/${vmAdminUsername}/.ssh/authorized_keys'
//         keyData: vmAdminPasswordOrKey
//       }
//     ]
//   }
//   provisionVMAgent: true
// }
// var bastionPublicIpAddressName = '${bastionHostName}PublicIp'
// var bastionPublicIpAddressId = bastionPublicIpAddress.id
// var bastionSubnetName = 'AzureBastionSubnet'
// var bastionSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, bastionSubnetName)
// var bastionHostId = bastionHost.id
// var workspaceId = logAnalyticsWorkspace.id
// var readerRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', readerRoleDefinitionName)
var contributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinitionName)
// var acrPullRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleDefinitionName)
// var aksContributorRoleAssignmentName = guid(concat(resourceGroup().id, aksClusterUserDefinedManagedIdentityName, aksClusterName))
// var aksContributorRoleAssignmentId = aksContributorRoleAssignment.id
var appGwContributorRoleAssignmentName = guid(concat(resourceGroup().id, guidGen, applicationGatewayName))
// var acrPullRoleAssignmentName = 'Microsoft.Authorization/${guid('${resourceGroup().id}acrPullRoleAssignment')}'
// var containerInsightsSolutionName = 'ContainerInsights(${logAnalyticsWorkspaceName})'
// var acrPublicDNSZoneForwarder = ((toLower(environment().name) == 'azureusgovernment') ? 'azurecr.us' : 'azurecr.io')
// var acrPrivateDnsZoneName = 'privatelink.${acrPublicDNSZoneForwarder}'
// var acrPrivateDnsZoneId = acrPrivateDnsZone.id
// var acrPrivateEndpointGroupName = 'registry'
// var acrPrivateDnsZoneGroupName = '${acrPrivateEndpointGroupName}PrivateDnsZoneGroup'
// var acrPrivateDnsZoneGroupId = resourceId('Microsoft.Network/privateEndpoints/privateDnsZoneGroups', acrPrivateEndpointName, '${acrPrivateEndpointGroupName}PrivateDnsZoneGroup')
// var acrPrivateEndpointId = acrPrivateEndpoint.id
// var acrId = acr.id
// var aksClusterId = aksCluster.id
// var keyVaultPublicDNSZoneForwarder = ((toLower(environment().name) == 'azureusgovernment') ? '.vaultcore.usgovcloudapi.net' : '.vaultcore.azure.net')
// var keyVaultPrivateDnsZoneName = 'privatelink${keyVaultPublicDNSZoneForwarder}'
// var keyVaultPrivateDnsZoneId = keyVaultPrivateDnsZone.id
// var keyVaultPrivateEndpointId = keyVaultPrivateEndpoint.id
// var keyVaultPrivateEndpointGroupName = 'vault'
// var keyVaultPrivateDnsZoneGroupName = '${keyVaultPrivateEndpointGroupName}PrivateDnsZoneGroup'
// var keyVaultPrivateDnsZoneGroupId = resourceId('Microsoft.Network/privateEndpoints/privateDnsZoneGroups', keyVaultPrivateEndpointName, '${keyVaultPrivateEndpointGroupName}PrivateDnsZoneGroup')
// var keyVaultId = keyVault.id
// var wafPolicyId = wafPolicy.id
//var applicationGatewayId = applicationGateway.id
var applicationGatewayPublicIPAddressName = '${aksPrefix}-AG-PublicIp'
// var applicationGatewayPublicIPAddressId = applicationGatewayPublicIPAddress.id
var applicationGatewayIPConfigurationName = '${aksPrefix}-applicationGatewayIPConfiguration'
var applicationGatewayFrontendIPConfigurationName = '${aksPrefix}-applicationGatewayFrontendIPConfiguration'
var applicationGatewayFrontendIPConfigurationId = resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, applicationGatewayFrontendIPConfigurationName)
var applicationGatewayFrontendPortName = '${aksPrefix}-applicationGatewayFrontendPort80'
var applicationGatewayFrontendPortId = resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, applicationGatewayFrontendPortName)
var applicationGatewayHttpListenerName = '${aksPrefix}-applicationGatewayHttpListener'
var applicationGatewayHttpListenerId = resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, applicationGatewayHttpListenerName)
var applicationGatewayBackendAddressPoolName = '${aksPrefix}-applicationGatewayBackendPool'
var applicationGatewayBackendAddressPoolId = resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, applicationGatewayBackendAddressPoolName)
var applicationGatewayBackendHttpSettingsName = 'defaulthttpsetting' //'${aksPrefix}-applicationGatewayBackendHttpSettings'
var applicationGatewayBackendHttpSettingsId = resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, applicationGatewayBackendHttpSettingsName)
var applicationGatewayRequestRoutingRuleName = '${aksPrefix}-DefaultRoutingRule'
var applicationGatewayDefaultHttpProbeName = 'defaultHttpProbe'
var applicationGatewayDefaultHttpProbeNameId = resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, applicationGatewayDefaultHttpProbeName)
var applicationGatewayDefaultHttpsProbeName = 'defaultHttpsProbe'
// var aadProfileConfiguration = {
//   managed: aadProfileManaged
//   enableAzureRBAC: aadProfileEnableAzureRBAC
//   adminGroupObjectIDs: aadProfileAdminGroupObjectIDs
//   tenantID: aadProfileTenantId
// }


resource applicationGatewayID 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${applicationGatewayName}Id'
  location: location
}


resource applicationGatewayPublicIPAddress 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: applicationGatewayPublicIPAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// resource wafPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2020-06-01' = {
//   name: wafPolicyName
//   location: location
//   properties: {
//     customRules: [
//       {
//         name: 'BlockMe'
//         priority: 1
//         ruleType: 'MatchRule'
//         action: 'Block'
//         matchConditions: [
//           {
//             matchVariables: [
//               {
//                 variableName: 'QueryString'
//               }
//             ]
//             operator: 'Contains'
//             negationConditon: false
//             matchValues: [
//               'blockme'
//             ]
//           }
//         ]
//       }
//       {
//         name: 'BlockEvilBot'
//         priority: 2
//         ruleType: 'MatchRule'
//         action: 'Block'
//         matchConditions: [
//           {
//             matchVariables: [
//               {
//                 variableName: 'RequestHeaders'
//                 selector: 'User-Agent'
//               }
//             ]
//             operator: 'Contains'
//             negationConditon: false
//             matchValues: [
//               'evilbot'
//             ]
//             transforms: [
//               'Lowercase'
//             ]
//           }
//         ]
//       }
//     ]
//     policySettings: {
//       requestBodyCheck: wafPolicyRequestBodyCheck
//       maxRequestBodySizeInKb: wafPolicyMaxRequestBodySizeInKb
//       fileUploadLimitInMb: wafPolicyFileUploadLimitInMb
//       mode: wafPolicyMode
//       state: wafPolicyState
//     }
//     managedRules: {
//       managedRuleSets: [
//         {
//           ruleSetType: wafPolicyRuleSetType
//           ruleSetVersion: wafPolicyRuleSetVersion
//         }
//       ]
//     }
//   }
// }

resource applicationGateway 'Microsoft.Network/applicationGateways@2022-07-01' = {
  name: applicationGatewayName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${applicationGatewayID.id}': {
      }
    }
  }
  zones: applicationGatewayZones
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: applicationGatewayIPConfigurationName
        properties: {
          subnet: {
            id: applicationGatewaySubnetId
          }
        }
      }
    ]
    sslCertificates: []
    trustedRootCertificates: []
    trustedClientCertificates: []
    sslProfiles: []
    frontendIPConfigurations: [
      {
        name: applicationGatewayFrontendIPConfigurationName
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: applicationGatewayPublicIPAddress.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: applicationGatewayFrontendPortName
        properties: {
          port: 80
        }
      }
    ]
    // autoscaleConfiguration: {
    //   minCapacity: 0
    //   maxCapacity: 10
    // }
    enableHttp2: false
    backendAddressPools: [
      {
        name: applicationGatewayBackendAddressPoolName
        properties: {
          backendAddresses: []
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: applicationGatewayBackendHttpSettingsName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe:{
            id: applicationGatewayDefaultHttpProbeNameId
            }
        }
      }
    ]
    backendSettingsCollection: []
    httpListeners: [
      {
        name: applicationGatewayHttpListenerName
        properties: {
          // firewallPolicy: {
          //   id: wafPolicyId
          // }
          frontendIPConfiguration: {
            id: applicationGatewayFrontendIPConfigurationId
          }
          frontendPort: {
            id: applicationGatewayFrontendPortId
          }
          protocol: 'Http'
          hostNames: []
          requireServerNameIndication: false
        }
      }
    ]
    listeners: []
    urlPathMaps: []
    requestRoutingRules: [
      {
        name: applicationGatewayRequestRoutingRuleName
        properties: {
          ruleType: 'Basic'
          priority: 19500
          httpListener: {
            id: applicationGatewayHttpListenerId
          }
          backendAddressPool: {
            id: applicationGatewayBackendAddressPoolId
          }
          backendHttpSettings: {
            id: applicationGatewayBackendHttpSettingsId
          }
        }
      }
    ]
    routingRules: []
    probes: [
      {
        name: applicationGatewayDefaultHttpProbeName
        properties: {
          protocol: 'Http'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {
          }
        }
      }
      {
        name: applicationGatewayDefaultHttpsProbeName
        properties: {
          protocol: 'Https'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {
          }
        }
      }
    ]
    // webApplicationFirewallConfiguration: {
    //   enabled: true
    //   firewallMode: wafPolicyMode
    //   ruleSetType: wafPolicyRuleSetType
    //   ruleSetVersion: wafPolicyRuleSetVersion
    //   requestBodyCheck: wafPolicyRequestBodyCheck
    //   maxRequestBodySizeInKb: wafPolicyMaxRequestBodySizeInKb
    //   fileUploadLimitInMb: wafPolicyFileUploadLimitInMb
    // }
    // firewallPolicy: {
    //   id: wafPolicyId
    // }
  }
  // dependsOn: [
    // keyVaultId
    // virtualNetworkId
    // wafPolicyId
  // ]
}

// resource applicationGatewayName_Microsoft_Insights_default 'Microsoft.Network/applicationGateways/providers/diagnosticSettings@2017-05-01-preview' = {
//   name: '${applicationGatewayName}/Microsoft.Insights/default'
//   properties: {
//     workspaceId: workspaceId
//     logs: [
//       {
//         category: 'ApplicationGatewayAccessLog'
//         enabled: true
//       }
//       {
//         category: 'ApplicationGatewayPerformanceLog'
//         enabled: true
//       }
//       {
//         category: 'ApplicationGatewayFirewallLog'
//         enabled: true
//       }
//     ]
//     metrics: [
//       {
//         category: 'AllMetrics'
//         enabled: true
//       }
//     ]
//   }
//   dependsOn: [
//     applicationGatewayId
//     workspaceId
//   ]
// }

resource appGwContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: appGwContributorRoleAssignmentName
  properties: {
    roleDefinitionId: contributorRoleId
    principalId: applicationGatewayID.properties.principalId
    principalType: 'ServicePrincipal'
    
  }
  scope: resourceGroup()
  dependsOn: [
    applicationGateway
  ]
}
