
param variables_clusterName string
param clusterLocation string
// param metricLabelsAllowlist string
// param metricAnnotationsAllowList string

resource variables_cluster 'Microsoft.ContainerService/managedClusters@2022-07-02-preview' = {
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
