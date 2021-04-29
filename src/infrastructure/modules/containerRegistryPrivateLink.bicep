param location string
param vnetName string
param vnetSubnetName string
param containerRegistryName string
param containerRegistryPrivateLinkDnsZoneName string
param containerRegistryPrivateLinkName string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' existing = {
  name: containerRegistryName
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: vnetName

  resource subnet 'subnets' existing = {
    name: vnetSubnetName
  }
}

resource containerRegistryPrivateLinkDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: containerRegistryPrivateLinkDnsZoneName
  location: 'global'
  
  resource soa 'SOA' = {
    name: '@'
    properties: {
      ttl: 3600
      soaRecord: {
        email: 'azureprivatedns-host.microsoft.com'
        expireTime: 2419200
        host: 'azureprivatedns.net'
        refreshTime: 3600
        retryTime: 300
        serialNumber: 1
        minimumTtl: 10
      }
    }
  }

  resource vnetLink 'virtualNetworkLinks' = {
    parent: containerRegistryPrivateLinkDnsZone
    name: vnetName
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnet.id
      }
    }
  }
}

resource containerRegistryPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-05-01' = {
  name: containerRegistryPrivateLinkName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: containerRegistryPrivateLinkName
        properties: {
          privateLinkServiceId: containerRegistry.id
          groupIds: [
            'registry'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: vnet::subnet.id
    }
  }

  resource zoneGroup 'privateDnsZoneGroups' = {
    name: vnet::subnet.name
    properties: {
      privateDnsZoneConfigs: [
        {
          name: replace(containerRegistryPrivateLinkDnsZoneName, '.', '-')
          properties: {
            privateDnsZoneId: containerRegistryPrivateLinkDnsZone.id
          }
        }
      ]
    }
  }
}
