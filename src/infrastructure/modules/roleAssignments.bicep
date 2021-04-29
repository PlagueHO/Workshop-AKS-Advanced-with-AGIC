param clusterName string
param containerRegistryName string
param vnetName string
param vnetSubnetName string

var contributorRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') // As per https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor
var networkContributorRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7') // As per https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#network-contributor
var monitoringMetricsPublisherRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb') // As per https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#monitoring-metrics-publisher

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: vnetName

  resource subnet 'subnets' existing = {
    name: vnetSubnetName
  }
}

resource cluster 'Microsoft.ContainerService/managedClusters@2021-03-01' existing = {
  name: clusterName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' existing = {
  name: containerRegistryName 
}

resource clusterContainerRegistryRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: containerRegistry
  name: guid(containerRegistry.id, cluster.id, contributorRoleDefinitionId)
  properties: {
    roleDefinitionId: contributorRoleDefinitionId
    principalId: cluster.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}

resource clusterSubnetRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: vnet::subnet
  name: guid(vnet::subnet.id, cluster.id, networkContributorRoleDefinitionId)
  properties: {
    roleDefinitionId: networkContributorRoleDefinitionId
    principalId: cluster.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}

resource clusterMonitoringMetricPublisherRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: cluster
  name: guid(cluster.id, monitoringMetricsPublisherRoleDefinitionId)
  properties: {
    roleDefinitionId: monitoringMetricsPublisherRoleDefinitionId
    principalId: cluster.properties.addonProfiles.omsAgent.identity.objectId
    principalType: 'ServicePrincipal'
  }
}
