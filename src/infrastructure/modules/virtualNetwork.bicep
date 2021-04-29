param location string
param vnetName string
param vnetAddressPrefix string
param vnetSubnetName string
param vnetSubnetPrefix string
param logAnalyticsWorkspaceName string
param logAnalyticsWorkspaceId string
param containerRegistryPrivateLink bool

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: vnetSubnetName
        properties: {
          addressPrefix: vnetSubnetPrefix
          privateEndpointNetworkPolicies: (containerRegistryPrivateLink ? 'Disabled' : 'Enabled')
        }
      }
    ]
  }

  resource subnet 'subnets' existing = {
    name: vnetSubnetName
  }
}

resource vnetDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  scope: vnet
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
        category: 'VMProtectionAlerts'
        enabled: true
      }
    ]
  }
}

output vnetName string = vnet.name
output vnetId string = vnet.id
output vnetSubnetName string = vnet::subnet.name
output vnetSubnetId string = vnet::subnet.id
