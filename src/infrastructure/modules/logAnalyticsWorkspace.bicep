param location string
param logAnalyticsWorkspaceName string
param logAnalyticsSku string

var containerInsightsSolutionName = 'ContainerInsights(${logAnalyticsWorkspaceName})'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2015-11-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: logAnalyticsSku
    }
  }
}

resource containerInsights 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: containerInsightsSolutionName
  location: location
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
  plan: {
    name: containerInsightsSolutionName
    product: 'OMSGallery/ContainerInsights'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
