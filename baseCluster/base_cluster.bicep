
// @allowed([
// 'AustraliaEast'
// 'BrazilSouth'
// 'CanadaCentral'
// 'EastAsia'
// 'EastUS'
// 'EastUS2'
// 'FranceCentral'
// 'GermanyWestCentral'
// 'CentralIndia'
// 'CentralUS'
// 'ChinaNorth3'
// 'NorthEurope'
// 'NorwayEast'	
// 'JapanEast'
// 'KoreaCentral'
// 'QatarCentral'			
// 'Southeast Asia'
// 'SouthCentralUS'	
// 'SouthAfricaNorth'	
// 'SwedenCentral'			
// 'SwitzerlandNorth'
// 'UAENorth'
// 'UKSouth'
// 'USGovVirginia'
// 'WestEurope'		
// 'WestUS2'	
// 'WestUS3'
// ])
param location string = resourceGroup().location
param rg_name string = resourceGroup().name
param tenantId string = subscription().tenantId
param cluster_name string = '${rg_name}-aks'

param aksPrefix string = 'edge01'

param api_sub_name string = 'apiserver-sub'
param linux_z1_sub_name string = 'linuxz1-sub'
param linux_z1_pod_sub_name string = 'linuxz1-pod-sub'
param win_z1_sub_name string = 'winz1-sub'
param win_z1_pod_sub_name string = 'winz1-pod-sub'
param sysnode_sub_name string = 'sysnode-sub'

param api_address_prefix string = '10.2.1.0/28'
param linux_z1_address_prefix string = '10.2.6.0/23'
param linux_z1_pod_address_prefix string = '10.2.8.0/21'
param win_z1_address_prefix string = '10.2.18.0/23'
param win_z1_pod_address_prefix string = '10.2.24.0/21'
param sysnode_address_prefix string = '10.2.3.0/24'
param vnet_address_prefix string = '10.2.0.0/16'

param networkPolicy string = 'azure'
param networkPlugin string = 'azure'
param vnet_name string = '${aksPrefix}-vnet'
param admin string = 'chwash'
param kubernetes_version string ='1.24.3'
param vmSKU string = 'Standard_D2s_v3'
param default_node_pool_name string = 'system'
param win_node_pool_name string = 'win123'
param maxPods int = 30
param osDiskSizeGB int = 128
param sysNodeCount int = 3

@allowed([
  'centralus'
  'centraluseuap'
  'eastus'
  'eastus2'
  'eastus2euap'
  'northeurope'
  'southcentralus'
  'southeastasia'
  'uksouth'
  'westeurope'
  'westus'
  'westus2'
])
param azureMonitorLocation string

// @allowed([
// 'australiaaast'
// 'canadaentral'
// 'eastasia'
// 'eastus'
// 'eastus2'
// 'centralus'
// 'northeurope'
// 'southcentralus'	
// 'swedencentral'			
// 'uksouth'
// 'westcentralus'
// 'westeurope'		
// 'westus3'
// ])
param grafanaLocation string

param guidValue string = newGuid()


param kubeletID_name string = 'kubeletID'
param ccpID_name string = 'ccpID'
param log_analytics_name string = '${rg_name}-la'
param baseTime string = utcNow()

param assignments bool = true

@allowed([
  'Managed'
  'Ephemeral'
])
param osDiskType string = 'Managed'
param enabledForDeployment bool = true
param networkAclsDefaultAction string = 'Allow'
@description('Specifies whether the Azure Key Vault resource is enabled for disk encryption.')
param enabledForDiskEncryption bool = true

@description('Specifies whether the Azure Key Vault resource is enabled for template deployment.')
param enabledForTemplateDeployment bool = true

@description('Specifies whether the soft deelete is enabled for this Azure Key Vault resource.')
param enableSoftDelete bool = true

@description('Specifies the object ID of the managed identity to configure in Key Vault access policies.')
param userAssnFedIdNameObjectId string
param userObjectId string

var guidGen = dateTimeAdd(baseTime, '-P9D')
var akvRawName = 'kv-${replace(aksPrefix, '-', '')}-${uniqueString(resourceGroup().id, aksPrefix)}'
var akvName = length(akvRawName) > 24 ? substring(akvRawName, 0, 24) : akvRawName
var monitoringDataReaderRoleId = 'b0d8363b-8ddd-447d-831f-62ca05bff136'
var monitoringReaderRoleId = '43d0d8ad-25c7-4714-9337-8ba259a9fe05'
var grafanaAdminRoleId = '22926164-76b3-42b3-bc55-97df8dab3e41'
var networkContributorRoleDefinitionId  = '4d97b98b-1d4f-4787-a291-c67834d212e7'
var contributorRoleDefinitionId  = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
var manangeIdentityOperatorRoleId = 'f1a07417-d97a-45cb-824c-7a7467783830'
var admin_password  = '${toUpper(uniqueString(resourceGroup().id))}-${guidValue}'

output adminpw string = admin_password


resource azureMonitorWorkspace 'Microsoft.Monitor/accounts@2021-06-03-preview' = {
  name: '${aksPrefix}-AMW'
  location: azureMonitorLocation

}


resource grafanaManagedDashboard 'Microsoft.Dashboard/grafana@2022-08-01' = {
  name: '${aksPrefix}-dashboard'
  identity:{
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Standard'
  }
  location: grafanaLocation
  properties: {
    grafanaIntegrations: {
      azureMonitorWorkspaceIntegrations: [
        {
          azureMonitorWorkspaceResourceId: azureMonitorWorkspace.id
        }
      ]
    }
  }

}



resource grafanaDataReaderRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(guidGen, rg_name, baseTime)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', monitoringDataReaderRoleId)
    principalId: grafanaManagedDashboard.identity.principalId
    principalType: 'ServicePrincipal'
  }
  scope: azureMonitorWorkspace
}

module grafanaMonitoringRederRole 'sub_perms.bicep' =  {
  name: guid(guidGen, baseTime, azureMonitorWorkspace.id)
  params:{
    principalId: grafanaManagedDashboard.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', monitoringReaderRoleId)
    roleNameGuid: guid(guidGen, monitoringReaderRoleId, rg_name) 
  }
  scope: subscription()

}
resource userGrafanaAdminRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(guidGen, aksPrefix, rg_name)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', grafanaAdminRoleId)
    principalId: userObjectId
    principalType: 'User'
  }
  scope: grafanaManagedDashboard
}




resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: akvName
  location: location
  properties: {
    accessPolicies: [ {
      tenantId: subscription().tenantId
      objectId: userAssnFedIdNameObjectId
      permissions: {
        keys: [
          'get'
          'list'
        ]
        secrets: [
          'get'
          'list'
        ]
        certificates: [
          'get'
          'list'
        ]
      }
    }
  ]
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: networkAclsDefaultAction
    }
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enableSoftDelete: enableSoftDelete
  }
}

output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri


resource kvSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'Secret1'
  parent: keyVault
  properties: {
    contentType: 'string'
    value: 'SHH!Thisisasecret'
  }
}

output kvSecretName string = kvSecret.name

resource laworkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: log_analytics_name
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}


resource kubeletID 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview'  = {
  name: '${kubeletID_name}_${cluster_name}'
   location: location
 }

 resource kubletManagedIdOpRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (assignments) {
  name: guid(linux_z1_sub_name, manangeIdentityOperatorRoleId, rg_name)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', manangeIdentityOperatorRoleId)
    principalId: kubeletID.properties.principalId
    principalType: 'ServicePrincipal'
  }
  scope: kubeletID
}


module subContributorRole 'sub_perms.bicep' = if (assignments) {
  name: guid(guidGen, 'addContributorRole')
  params:{
    principalId: kubeletID.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinitionId)
    roleNameGuid: guid(guidGen, cluster_name, rg_name) 
  }
  scope: subscription()

}

 resource ccpID 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview'  = {
   name: '${ccpID_name}_${cluster_name}'
   location: location
 }


resource ccpNetAdminRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (assignments) {
  name: guid(vnet_name, networkContributorRoleDefinitionId, rg_name)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinitionId)
    principalId: ccpID.properties.principalId
    principalType: 'ServicePrincipal'
  }
  scope: resourceGroup()
}


module apiSubNsg 'vnetnsg.bicep' = {
  name: '${vnet_name}-${api_sub_name}-nsg'
  params:{
    nsgName: '${vnet_name}-${api_sub_name}-nsg'
    rglocation: location
  }
}

module linuxNodeSubNsg 'vnetnsg.bicep' = {
  name: '${vnet_name}-${linux_z1_sub_name}-nsg'
  params:{
    nsgName: '${vnet_name}-${linux_z1_sub_name}-nsg'
    rglocation: location
  }
}
module linuxPodSubNsg 'vnetnsg.bicep' = {
  name: '${vnet_name}-${linux_z1_pod_sub_name}-nsg'
  params:{
    nsgName: '${vnet_name}-${linux_z1_pod_sub_name}-nsg'
    rglocation: location
  }
}
module winNodeSubNsg 'vnetnsg.bicep' = {
  name: '${vnet_name}-${win_z1_sub_name}-nsg'
  params:{
    nsgName: '${vnet_name}-${win_z1_sub_name}-nsg'
    rglocation: location
  }
}
module winPodSubNsg 'vnetnsg.bicep' = {
  name: '${vnet_name}-${win_z1_pod_sub_name}-nsg'
  params:{
    nsgName: '${vnet_name}-${win_z1_pod_sub_name}-nsg'
    rglocation: location
  }
}
module sysNodeSubNsg 'vnetnsg.bicep' = {
  name: '${vnet_name}-${sysnode_sub_name}-nsg'
  params:{
    nsgName: '${vnet_name}-${sysnode_sub_name}-nsg'
    rglocation: location
  }
}
resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vnet_name
  dependsOn:[ laworkspace ]
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet_address_prefix
      ]
    }
    dhcpOptions: {
      dnsServers: []
    }
    subnets: [
      {
        name: sysnode_sub_name
        properties: {
          addressPrefix: sysnode_address_prefix
          networkSecurityGroup: { id: sysNodeSubNsg.outputs.nsgID }
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: linux_z1_sub_name
        properties: {
          addressPrefix: linux_z1_address_prefix
          networkSecurityGroup: { id: linuxNodeSubNsg.outputs.nsgID }
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: win_z1_sub_name
        properties: {
          addressPrefix: win_z1_address_prefix
          networkSecurityGroup: { id: winNodeSubNsg.outputs.nsgID }
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: win_z1_pod_sub_name
        properties: {
          addressPrefix: win_z1_pod_address_prefix
          networkSecurityGroup: { id: winPodSubNsg.outputs.nsgID}
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: linux_z1_pod_sub_name
        properties: {
          addressPrefix: linux_z1_pod_address_prefix
          networkSecurityGroup: { id: linuxPodSubNsg.outputs.nsgID}
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: api_sub_name
        properties: {
          addressPrefix: api_address_prefix
          networkSecurityGroup: { id: apiSubNsg.outputs.nsgID }
          serviceEndpoints: []
          delegations: [
            {
              name: 'aks-delegation'
              properties: {
                serviceName: 'Microsoft.ContainerService/managedClusters'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource aks_cluster 'Microsoft.ContainerService/managedClusters@2022-11-02-preview' = {
  name: cluster_name
  dependsOn:[
    ccpNetAdminRole
    subContributorRole

  ]
  location: location
  sku: {
    name: 'Basic'
    tier: 'Free'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {'${ccpID.id}': {}}
  }
  properties: {
    kubernetesVersion: kubernetes_version
    dnsPrefix: '${cluster_name}-${rg_name}-2759f4'
    agentPoolProfiles: [
      {
        name: default_node_pool_name
        count: sysNodeCount
        vmSize: vmSKU

        osDiskSizeGB: osDiskSizeGB
        osDiskType: osDiskType
        kubeletDiskType: 'OS'
        workloadRuntime: 'OCIContainer'
        vnetSubnetID: '${vnet.id}/subnets/${sysnode_sub_name}'
        maxPods: maxPods
        type: 'VirtualMachineScaleSets'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        enableAutoScaling: false
        powerState: {
          code: 'Running'
        }
        orchestratorVersion: kubernetes_version
        enableNodePublicIP: false
        enableCustomCATrust: false
        mode: 'System'
        enableEncryptionAtHost: false
        enableUltraSSD: false
        osType: 'Linux'
        osSKU: 'Mariner'
        upgradeSettings: {
        }
        enableFIPS: false
      }
    ]
    windowsProfile: {
      adminUsername: admin
      adminPassword: admin_password
      enableCSIProxy: true
    }
    addonProfiles: {
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'false'
          rotationPollInterval: '2m'
        }
      }
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: laworkspace.id
        }
      }
      azurepolicy: {
        enabled:true
      }
    }
    enableRBAC: true
    enablePodSecurityPolicy: false
    networkProfile: {
      networkPlugin: networkPlugin
      networkPolicy: networkPolicy
      loadBalancerSku: 'Standard'
      loadBalancerProfile: {
        managedOutboundIPs: {
          count: 1
        }
        backendPoolType: 'nodeIPConfiguration'
      }
      serviceCidr: '10.3.0.0/24'
      dnsServiceIP: '10.3.0.10'
      dockerBridgeCidr: '172.17.0.1/16'
      outboundType: 'loadBalancer'
      serviceCidrs: [
        '10.3.0.0/24'
      ]
      ipFamilies: [
        'IPv4'
      ]
    }
    apiServerAccessProfile: {
      enablePrivateCluster: false
      enableVnetIntegration: true
      subnetId: '${vnet.id}/subnets/${api_sub_name}'
    }
    identityProfile: {
      kubeletidentity: {
        resourceId: kubeletID.id
        clientId: kubeletID.properties.clientId
        objectId: kubeletID.properties.principalId
        
      }
    }
    disableLocalAccounts: false
    securityProfile: {
      defender: {
        logAnalyticsWorkspaceResourceId: laworkspace.id
        securityMonitoring: {
          enabled: true
        }
      }
      workloadIdentity: {
        enabled: true
      }
    }
    storageProfile: {
      diskCSIDriver: {
        enabled: true
        version: 'v1'
      }
      fileCSIDriver: {
        enabled: true
      }
      snapshotController: {
        enabled: true
      }
    }
    oidcIssuerProfile: {
      enabled: true
    }
    guardrailsProfile: {
      level: 'Off'
      version: kubernetes_version
    }
    workloadAutoScalerProfile: {
      keda: {
        enabled: true }
    }

  }
}

resource win_node_pool 'Microsoft.ContainerService/managedClusters/agentPools@2022-11-02-preview' = {
  parent: aks_cluster
  name: win_node_pool_name
  properties: {
    count: 1
    vmSize: vmSKU
    osDiskSizeGB: 128
    osDiskType: 'Managed'
    kubeletDiskType: 'OS'
    workloadRuntime: 'OCIContainer'
    vnetSubnetID: '${vnet.id}/subnets/${win_z1_sub_name}'
    maxPods: 30
    type: 'VirtualMachineScaleSets'
    availabilityZones: [
      '1'
    ]
    enableAutoScaling: false
    scaleDownMode: 'Delete'
    powerState: {
      code: 'Running'
    }
    orchestratorVersion: kubernetes_version
    enableNodePublicIP: false
    enableCustomCATrust: false
    mode: 'User'
    enableEncryptionAtHost: false
    enableUltraSSD: false
    osType: 'Windows'
    osSKU: 'Windows2022'
    upgradeSettings: {
    }
    enableFIPS: false
  }
}


module managedProGraf './FullAzureMonitorMetricsProfile.bicep' = {
  name: 'monitor-${cluster_name}'
  params:{
    azureMonitorWorkspaceLocation: azureMonitorLocation
    azureMonitorWorkspaceResourceId: azureMonitorWorkspace.id
    clusterLocation: location
    // grafanaLocation: grafanaLocation
    // grafanaResourceId: grafanaManagedDashboard.id
    clusterResourceId: aks_cluster.id
    metricLabelsAllowlist: ''
    metricAnnotationsAllowList: '' 
  }
  dependsOn:[
    win_node_pool
  ]
}


output azMonWorkspaceId string = azureMonitorWorkspace.id
output grafanaDashboardId string = grafanaManagedDashboard.id
output grafanaDashboardUrl string = grafanaManagedDashboard.properties.endpoint

