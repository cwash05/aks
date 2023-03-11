
param resourceId_Microsoft_Insights_dataCollectionRules_variables_dcrName string
param variables_clusterName string
param variables_dcraName string
param clusterLocation string

resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-11-02-preview' existing = {
  name: variables_clusterName
}


resource dataCollectionRuleAssoc 'Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview' = {
  name: '${variables_clusterName}-${variables_dcraName}'
  location: clusterLocation
  properties: {
  //  dataCollectionEndpointId: dataCollectionEndpointLinux.id
    dataCollectionRuleId: resourceId_Microsoft_Insights_dataCollectionRules_variables_dcrName
    description: 'Association of data collection rule. Deleting this association will break the data collection for this AKS Cluster.'
  }
  scope: aksCluster
}
