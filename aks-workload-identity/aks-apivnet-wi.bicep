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

param vnet_name string = '${rg_name}-vnet'
param admin string = 'chwash'
param kubernetes_version string ='1.24.3'
param vmSKU string = 'Standard_D2s_v3'


//param ustring string = uniqueString(subscription().subscriptionId, utcNow())
// var adminPassword = '${toUpper(uniqueString(resourceGroup().id))}-${guidValue}'
//@secure()

param guidValue string = newGuid()

var admin_password  = '${toUpper(uniqueString(resourceGroup().id))}-${guidValue}'
param kubeletID_name string = 'kubeletID'
param ccpID_name string = 'ccpID'
param log_analytics_name string = '${rg_name}-la'
param baseTime string = utcNow()

param assignments bool = true

param networkContributorRoleDefinitionId string = '4d97b98b-1d4f-4787-a291-c67834d212e7'
param contributorRoleDefinitionId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
param manangeIdentityOperatorRoleId string = 'f1a07417-d97a-45cb-824c-7a7467783830'

param enabledForDeployment bool = true
param networkAclsDefaultAction string = 'Allow'
@description('Specifies whether the Azure Key Vault resource is enabled for disk encryption.')
param enabledForDiskEncryption bool = true

@description('Specifies whether the Azure Key Vault resource is enabled for template deployment.')
param enabledForTemplateDeployment bool = true

@description('Specifies whether the soft deelete is enabled for this Azure Key Vault resource.')
param enableSoftDelete bool = true

@description('Specifies the object ID of the managed identity to configure in Key Vault access policies.')
param objectId string

var guidGen = dateTimeAdd(baseTime, '-P9D')
var akvRawName = 'kv-${replace(aksPrefix, '-', '')}-${uniqueString(resourceGroup().id, aksPrefix)}'
var akvName = length(akvRawName) > 24 ? substring(akvRawName, 0, 24) : akvRawName

output adminpw string = admin_password


resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: akvName
  location: location
  properties: {
    accessPolicies: [ {
      tenantId: subscription().tenantId
      objectId: objectId
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

resource ccpManagedIdOpRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (assignments) {
  name: guid(linux_z1_sub_name, manangeIdentityOperatorRoleId, rg_name)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', manangeIdentityOperatorRoleId)
    principalId: ccpID.properties.principalId
    principalType: 'ServicePrincipal'
  }
  scope: kubeletID
}

resource ccpNetAdminRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (assignments) {
  name: guid(vnet_name, networkContributorRoleDefinitionId, rg_name)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', networkContributorRoleDefinitionId)
    principalId: ccpID.properties.principalId
    principalType: 'ServicePrincipal'
  }
  scope: vnet
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
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
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

resource aks_cluster 'Microsoft.ContainerService/managedClusters@2022-08-03-preview' = {
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
        name: 'nodepool1'
        count: 1
        vmSize: vmSKU

        osDiskSizeGB: 128
        osDiskType: 'Managed'
        kubeletDiskType: 'OS'
        workloadRuntime: 'OCIContainer'
        vnetSubnetID: '${vnet.id}/subnets/${sysnode_sub_name}'
        maxPods: 30
        type: 'VirtualMachineScaleSets'
        availabilityZones: [
          '2'
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
      networkPlugin: 'azure'
      networkPolicy: 'Azure'
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
    }
  }
}

resource cluster_name_nodepool1 'Microsoft.ContainerService/managedClusters/agentPools@2022-08-03-preview' = {
  parent: aks_cluster
  name: 'nodepool1'
  properties: {
    count: 1
    vmSize: vmSKU
    osDiskSizeGB: 128
    osDiskType: 'Managed'
    kubeletDiskType: 'OS'
    workloadRuntime: 'OCIContainer'
    vnetSubnetID: '${vnet.id}/subnets/${sysnode_sub_name}'
    maxPods: 30
    type: 'VirtualMachineScaleSets'
    availabilityZones: [
      '2'
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
}

resource cluster_name_workid 'Microsoft.ContainerService/managedClusters/agentPools@2022-08-03-preview' = {
  parent: aks_cluster
  name: 'workid'
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


