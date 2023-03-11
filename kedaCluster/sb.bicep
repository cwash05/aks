param location string = resourceGroup().location
param servicebusNamespaceName string 
param userAssnFedIdNameObjectId string
param queueName string
param guidGen string

var monitoringDataRecieverRoleId = '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0'

resource servicebusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: servicebusNamespaceName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    premiumMessagingPartitions: 0
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: false
  }
}

resource servicebusAuthRules 'Microsoft.ServiceBus/namespaces/authorizationrules@2022-10-01-preview' = {
  parent: servicebusNamespace
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource servicebuseNetworkRules 'Microsoft.ServiceBus/namespaces/networkRuleSets@2022-10-01-preview' = {
  parent: servicebusNamespace
  name: 'default'
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Allow'
    virtualNetworkRules: []
    ipRules: []
  }
}

resource servicebusQueue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  parent: servicebusNamespace
  name: queueName
  properties: {
    maxMessageSizeInKilobytes: 256
    lockDuration: 'PT1M'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'P14D'
    deadLetteringOnMessageExpiration: false
    enableBatchedOperations: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    status: 'Active'
    enablePartitioning: false
    enableExpress: false
  }
}


resource servicebusRecieverRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(guidGen, queueName, location)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', monitoringDataRecieverRoleId)
    principalId: userAssnFedIdNameObjectId
    principalType: 'ServicePrincipal'
  }
  scope: servicebusNamespace
}


