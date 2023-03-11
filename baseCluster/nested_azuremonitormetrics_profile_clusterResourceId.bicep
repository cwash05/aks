
param variables_clusterName string
param clusterLocation string
//param clusterResourceId string
// param metricLabelsAllowlist string
// param metricAnnotationsAllowList string

resource variables_cluster 'Microsoft.ContainerService/managedClusters@2022-11-02-preview' = {
  name: variables_clusterName
  location: clusterLocation
  properties: {
    azureMonitorProfile: {
      metrics: {
        enabled: true
        kubeStateMetrics: {
          // metricLabelsAllowlist: metricLabelsAllowlist
          // metricAnnotationsAllowList: metricAnnotationsAllowList
        }
      }
    }
  }
}
