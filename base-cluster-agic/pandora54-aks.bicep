param managedClusters_pandora54_aks_name string = 'pandora54-aks'
param virtualNetworks_pandora54_westus3_rg_vnet_externalid string = '/subscriptions/2159f493-f4d2-4f96-ad4d-a9f6ae4ee050/resourceGroups/pandora54-westus3-rg/providers/Microsoft.Network/virtualNetworks/pandora54-westus3-rg-vnet'
param applicationGateways_ingress_appgateway_externalid string = '/subscriptions/2159f493-f4d2-4f96-ad4d-a9f6ae4ee050/resourceGroups/MC_pandora54-westus3-rg_pandora54-aks_westus3/providers/Microsoft.Network/applicationGateways/ingress-appgateway'
param workspaces_pandora54_westus3_rg_la_externalid string = '/subscriptions/2159f493-f4d2-4f96-ad4d-a9f6ae4ee050/resourceGroups/pandora54-westus3-rg/providers/Microsoft.OperationalInsights/workspaces/pandora54-westus3-rg-la'
param publicIPAddresses_fa9c9b9d_337d_4ff8_9d95_e1681d9d733a_externalid string = '/subscriptions/2159f493-f4d2-4f96-ad4d-a9f6ae4ee050/resourceGroups/MC_pandora54-westus3-rg_pandora54-aks_westus3/providers/Microsoft.Network/publicIPAddresses/fa9c9b9d-337d-4ff8-9d95-e1681d9d733a'
param userAssignedIdentities_kubeletID_pandora54_aks_externalid string = '/subscriptions/2159f493-f4d2-4f96-ad4d-a9f6ae4ee050/resourceGroups/pandora54-westus3-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/kubeletID_pandora54-aks'

resource managedClusters_pandora54_aks_name_resource 'Microsoft.ContainerService/managedClusters@2022-08-03-preview' = {
  name: managedClusters_pandora54_aks_name
  location: 'westus3'
  sku: {
    name: 'Basic'
    tier: 'Free'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/2159f493-f4d2-4f96-ad4d-a9f6ae4ee050/resourceGroups/pandora54-westus3-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/ccpID_pandora54-aks': {
      }
    }
  }
  properties: {
    kubernetesVersion: '1.24.6'
    dnsPrefix: '${managedClusters_pandora54_aks_name}-pandora54-westus3-rg-2759f4'
    agentPoolProfiles: [
      {
        name: 'nodepool1'
        count: 1
        vmSize: 'Standard_D2s_v3'
        osDiskSizeGB: 128
        osDiskType: 'Managed'
        kubeletDiskType: 'OS'
        workloadRuntime: 'OCIContainer'
        vnetSubnetID: '${virtualNetworks_pandora54_westus3_rg_vnet_externalid}/subnets/sysnode-sub'
        maxPods: 30
        type: 'VirtualMachineScaleSets'
        availabilityZones: [
          '2'
        ]
        enableAutoScaling: false
        powerState: {
          code: 'Running'
        }
        orchestratorVersion: '1.24.6'
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
      {
        name: 'workid'
        count: 1
        vmSize: 'Standard_D2s_v3'
        osDiskSizeGB: 128
        osDiskType: 'Managed'
        kubeletDiskType: 'OS'
        workloadRuntime: 'OCIContainer'
        vnetSubnetID: '${virtualNetworks_pandora54_westus3_rg_vnet_externalid}/subnets/winz1-sub'
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
        orchestratorVersion: '1.24.6'
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
    ]
    windowsProfile: {
      adminUsername: 'chwash'
      enableCSIProxy: true
    }
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    addonProfiles: {
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'false'
          rotationPollInterval: '2m'
        }
      }
      azurepolicy: {
        enabled: true
      }
      httpApplicationRouting: {
        enabled: false
      }
      ingressApplicationGateway: {
        enabled: true
        config: {
          applicationGatewayName: 'ingress-appgateway'
          effectiveApplicationGatewayId: applicationGateways_ingress_appgateway_externalid
          subnetPrefix: '10.2.21.0/24'
        }
      }
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: workspaces_pandora54_westus3_rg_la_externalid
        }
      }
    }
    nodeResourceGroup: 'MC_pandora54-westus3-rg_${managedClusters_pandora54_aks_name}_westus3'
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
        effectiveOutboundIPs: [
          {
            id: publicIPAddresses_fa9c9b9d_337d_4ff8_9d95_e1681d9d733a_externalid
          }
        ]
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
      subnetId: '${virtualNetworks_pandora54_westus3_rg_vnet_externalid}/subnets/apiserver-sub'
    }
    identityProfile: {
      kubeletidentity: {
        resourceId: userAssignedIdentities_kubeletID_pandora54_aks_externalid
        clientId: '05c65838-1f81-44a8-b160-69e52d5017e3'
        objectId: 'c3b00d22-729f-42d5-8b27-84b31ffcea7b'
      }
    }
    disableLocalAccounts: false
    securityProfile: {
      defender: {
        logAnalyticsWorkspaceResourceId: workspaces_pandora54_westus3_rg_la_externalid
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
      version: '1.24.6'
    }
    workloadAutoScalerProfile: {
    }
  }
}

resource managedClusters_pandora54_aks_name_nodepool1 'Microsoft.ContainerService/managedClusters/agentPools@2022-08-03-preview' = {
  parent: managedClusters_pandora54_aks_name_resource
  name: 'nodepool1'
  properties: {
    count: 1
    vmSize: 'Standard_D2s_v3'
    osDiskSizeGB: 128
    osDiskType: 'Managed'
    kubeletDiskType: 'OS'
    workloadRuntime: 'OCIContainer'
    vnetSubnetID: '${virtualNetworks_pandora54_westus3_rg_vnet_externalid}/subnets/sysnode-sub'
    maxPods: 30
    type: 'VirtualMachineScaleSets'
    availabilityZones: [
      '2'
    ]
    enableAutoScaling: false
    powerState: {
      code: 'Running'
    }
    orchestratorVersion: '1.24.6'
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

resource managedClusters_pandora54_aks_name_workid 'Microsoft.ContainerService/managedClusters/agentPools@2022-08-03-preview' = {
  parent: managedClusters_pandora54_aks_name_resource
  name: 'workid'
  properties: {
    count: 1
    vmSize: 'Standard_D2s_v3'
    osDiskSizeGB: 128
    osDiskType: 'Managed'
    kubeletDiskType: 'OS'
    workloadRuntime: 'OCIContainer'
    vnetSubnetID: '${virtualNetworks_pandora54_westus3_rg_vnet_externalid}/subnets/winz1-sub'
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
    orchestratorVersion: '1.24.6'
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