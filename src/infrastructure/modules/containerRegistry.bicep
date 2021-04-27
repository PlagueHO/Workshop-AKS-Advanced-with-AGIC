param location string
param containerRegistryName string
param containerRegistrySku string
param logAnalyticsWorkspaceName string
param logAnalyticsWorkspaceId string
param containerRegistryPublicNetworkAccess string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-12-01-preview' = {
  name: containerRegistryName
  location: location
  sku: {
    name: containerRegistrySku
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: containerRegistryPublicNetworkAccess
  }
}

resource containerRegistryDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  scope: containerRegistry
  name: 'Send to ${logAnalyticsWorkspaceName}'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
    logs: [
      {
        category: 'ContainerRegistryRepositoryEvents'
        enabled: true
      }
      {
        category: 'ContainerRegistryLoginEvents'
        enabled: true
      }
    ]
  }
}

output containerRegistryName string = containerRegistry.name
output containerRegistryId string = containerRegistry.id
