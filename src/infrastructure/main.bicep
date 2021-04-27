// Base information
@description('The base name of the Kubernetes cluster and related resources.')
param name string = 'mykube${uniqueString(resourceGroup().id)}'

@description('The location where the resources will be deployed.')
param location string = resourceGroup().location

// Log Analytics
@allowed([
  'CapacityReservation'
  'Free'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
@description('The SKU of the Log Analytics workspace to create.')
param logAnalyticsSku string = 'PerGB2018'

// Container Registry
@allowed([
  'Basic'
  'Classic'
  'Standard'
  'Premium'
])
@description('The SKU of the Azure Container Registry to create.')
param containerRegistrySku string = 'Premium'

@description('Boolean flag to connect the container registry to the cluster nodes VNET using a Private Link endpoint.')
param containerRegistryPrivateLink bool = true

@description('The name of the Private Link DNS private zone.')
param containerRegistryPrivateLinkDnsZoneName string = 'privatelink.azurecr.io'

@allowed([
  'Enabled'
  'Disabled'
])
@description('Specifies whether or not public network access is allowed to the container registry.')
param containerRegistryPublicNetworkAccess string = 'Enabled'

// Core cluster information
@description('The version of Kubernetes to use for this cluster.')
param kubernetesVersion string = '1.19.7'

@description('The format string used to name the resource group used to contain the nodes and other Azure resources created by this cluster. `%clusterName%` is used to insert the name of the cluster. \'%resourceGroupName%\' is used to insert the name of the resource group for this deployment.')
param clusterNodeResourceGroupFormat string = '%resourceGroupName%-%clusterName%-aks'

// Cluster features
@description('Array of Azure AD Group object Ids to use for cluster administrators.')
param clusterAdminGroupObjectIds array = []

@description('Boolean flag to turn on and off of http application routing.')
param clusterEnableHttpApplicationRouting bool = false

@description('boolean flag to turn on and off of RBAC')
param clusterEnableRbac bool = true

// Virtual network
@description('The address space of the virtual network to put the cluster nodes into.')
param vnetAddressPrefix string = '10.0.0.0/8'

@description('The name of the subnet of the virtual network to put the cluster nodes into.')
param vnetSubnetName string = 'clusterNodesSubnet'

@description('The address space of the subnet of the virtual network to put the cluster nodes into.')
param vnetSubnetPrefix string = '10.240.0.0/16'

// Cluster networking
@allowed([
  'azure'
  'kubenet'
])
@description('Network plugin used for building Kubernetes network.')
param clusterNetworkPlugin string = 'azure'

@description('The CIDR notation IP range from which to assign Kubernetes service cluster IPs.')
param clusterServiceCidr string = '10.0.0.0/16'

@description('Kubernetes containers DNS server IP address.')
param clusterDnsServiceIp string = '10.0.0.10'

@description('The CIDR notation IP for Docker bridge in the Kubernetes cluster.')
param clusterDockerBridgeCidr string = '172.17.0.1/16'

@allowed([
  'calico'
  'azure'
])
@description('The Kubernetes cluster network policy to use.')
param clusterNetworkPolicy string = 'azure'

@allowed([
  'standard'
  'basic'
])
@description('The Kubernetes cluster network load balancer SKU. Set to standard if node pools should support availability zones.')
param clusterNetworkLoadBalancerSku string = 'standard'

// System Node Pool settings
@minValue(0)
@maxValue(1023)
@description('Disk size (in GB) to provision for each of the system agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
param systemNodePoolOsDiskSizeGB int = 500

@minValue(1)
@maxValue(50)
@description('The number of system agent nodes for the cluster. Production workloads have a recommended minimum of 3.')
param systemNodePoolNodeCount int = 2

@minValue(1)
@maxValue(50)
@description('The minimum number of system agent nodes the cluster will scale in to. Production workloads have a recommended minimum of 3.')
param systemNodePoolMinNodeCount int = 2

@minValue(1)
@maxValue(50)
@description('The maximum number of system agent nodes the cluster will scale out to. Production workloads have a recommended minimum of 3.')
param systemNodePoolMaxNodeCount int = 5

@description('The size of the Virtual Machines for the system agent nodes.')
param systemNodePoolVmSize string = 'Standard_D2_v2'

@minValue(30)
@maxValue(100)
@description('Maximum number of pods that can run on each system agent node.')
param systemNodePoolMaxPods int = 30

// Workload Node Pools
@description('The Windows workload node pool.')
param workloadWindowsNodePool object = {
  name: 'win01'
  count: 2
  minCount: 2
}

@description('The Linux workload node pool')
param workloadLinuxNodePool object = {
  name: 'linux01'
  count: 2
  minCount: 2
}

var clusterName = name
var clusterNodeResourceGroupName = replace(replace(clusterNodeResourceGroupFormat, '%clusterName%', clusterName), '%resourceGroupName%', resourceGroup().name)
var vnetName = '${name}-vnet'
var containerRegistryName = name
var containerRegistryPrivateLinkName = '${name}-ple'
var logAnalyticsWorkspaceName = '${name}-law'
var clusterDnsPrefix = name
var systemPoolProfile = [
  {
    name: 'agentpool'
    osType: 'Linux'
    enableAutoScaling: true
    count: systemNodePoolNodeCount
    minCount: systemNodePoolMinNodeCount
    maxCount: systemNodePoolMaxNodeCount
    vmSize: systemNodePoolVmSize
    osDiskSizeGB: systemNodePoolOsDiskSizeGB
    type: 'VirtualMachineScaleSets'
    storageProfile: 'ManagedDisks'
    vnetSubnetId: virtualNetworkModule.outputs.vnetSubnetId
    maxPods: systemNodePoolMaxPods
    mode: 'System'
  }
]
var defaultWindowsPoolProfile = {
  name: 'windowsPool'
  osDiskSizeGB: 500
  count: 2
  vmSize: 'Standard_D4_v3'
  osType: 'Windows'
  storageProfile: 'ManagedDisks'
  maxPods: 30
  type: 'VirtualMachineScaleSets'
  enableAutoScaling: true
  minCount: 2
  maxCount: 5
  mode: 'User'
  availabilityZones: [
    '1'
    '2'
    '3'
  ]
  nodeTaints: [
    'os=windows:NoSchedule'
  ]
}
var defaultLinuxPoolProfile = {
  name: 'linuxPool'
  osDiskSizeGB: 500
  count: 3
  vmSize: 'Standard_D2_v2'
  osType: 'Linux'
  storageProfile: 'ManagedDisks'
  maxPods: 30
  type: 'VirtualMachineScaleSets'
  enableAutoScaling: true
  minCount: 3
  maxCount: 5
  mode: 'User'
  availabilityZones: [
    '1'
    '2'
    '3'
  ]
}
var workloadWindowsNodePoolWithSubnetId = union(defaultWindowsPoolProfile, json('{"vnetSubnetId": "${virtualNetworkModule.outputs.vnetSubnetId}"}'), workloadWindowsNodePool)
var workloadLinuxNodePoolWithSubnetId = union(defaultLinuxPoolProfile, json('{"vnetSubnetId": "${virtualNetworkModule.outputs.vnetSubnetId}"}'), workloadLinuxNodePool)
var agentPoolProfiles = concat(array(systemPoolProfile), array(workloadWindowsNodePoolWithSubnetId), array(workloadLinuxNodePoolWithSubnetId))

resource cluster 'Microsoft.ContainerService/managedClusters@2020-04-01' = {
  name: clusterName
  location: location
  properties: {
    kubernetesVersion: kubernetesVersion
    enableRBAC: clusterEnableRbac
    dnsPrefix: clusterDnsPrefix
    aadProfile: {
      managed: true
      adminGroupObjectIDs: clusterAdminGroupObjectIds
      tenantID: subscription().tenantId
    }
    addonProfiles: {
      httpApplicationRouting: {
        enabled: clusterEnableHttpApplicationRouting
      }
      omsAgent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceModule.outputs.logAnalyticsWorkspaceId
        }
      }
    }
    nodeResourceGroup: clusterNodeResourceGroupName
    agentPoolProfiles: agentPoolProfiles
    networkProfile: {
      networkPlugin: clusterNetworkPlugin
      serviceCidr: clusterServiceCidr
      dnsServiceIP: clusterDnsServiceIp
      dockerBridgeCidr: clusterDockerBridgeCidr
      networkPolicy: clusterNetworkPolicy
      loadBalancerSku: clusterNetworkLoadBalancerSku
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource clusterDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  scope: cluster
  name: 'Send to ${logAnalyticsWorkspaceName}'
  properties: {
    workspaceId: logAnalyticsWorkspaceModule.outputs.logAnalyticsWorkspaceId
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
        category: 'kube-apiserver'
        enabled: true
      }
      {
        category: 'kube-audit'
        enabled: true
      }
      {
        category: 'kube-controller-manager'
        enabled: true
      }
      {
        category: 'kube-scheduler'
        enabled: true
      }
      {
        category: 'cluster-autoscaler'
        enabled: true
      }
    ]
  }
}

module logAnalyticsWorkspaceModule './modules/logAnalyticsWorkspace.bicep' = {
  name: 'LogAnalyticsWorkspaceDeployment'
  scope: resourceGroup(resourceGroup().name)
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    logAnalyticsSku: logAnalyticsSku
  }
}

module containerRegistryModule './modules/containerRegistry.bicep' = {
  name: 'containerRegistryModule'
  params: {
    location: location
    containerRegistryName: containerRegistryName
    containerRegistrySku: containerRegistrySku
    containerRegistryPublicNetworkAccess: containerRegistryPublicNetworkAccess
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceModule.outputs.logAnalyticsWorkspaceId
  }
}

module virtualNetworkModule './modules/virtualNetwork.bicep' = {
  name: 'virtualNetworkModule'
  params: {
    location: location
    vnetName: vnetName
    vnetAddressPrefix: vnetAddressPrefix
    vnetSubnetName: vnetSubnetName
    vnetSubnetPrefix: vnetSubnetPrefix
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceModule.outputs.logAnalyticsWorkspaceId
    containerRegistryPrivateLink: containerRegistryPrivateLink
  }
}

module containerRegistryPrivateLinkModule './modules/containerRegistryPrivateLink.bicep' = if (containerRegistryPrivateLink) {
  name: 'containerRegistryPrivateLinkModule'
  params: {
    location: location
    vnetName: virtualNetworkModule.outputs.vnetName
    vnetSubnetName: virtualNetworkModule.outputs.vnetSubnetName
    containerRegistryName: containerRegistryModule.outputs.containerRegistryName
    containerRegistryPrivateLinkDnsZoneName: containerRegistryPrivateLinkDnsZoneName
    containerRegistryPrivateLinkName: containerRegistryPrivateLinkName
  }
}

module roleAssignmentsModule './modules/roleAssignments.bicep' = {
  name: 'roleAssignmentsModule'
  params: {
    clusterName: cluster.name
    vnetName: virtualNetworkModule.outputs.vnetName
    vnetSubnetName: virtualNetworkModule.outputs.vnetSubnetName
    containerRegistryName: containerRegistryModule.outputs.containerRegistryName
  }
}

output logAnalyticsWorkspaceId string =logAnalyticsWorkspaceModule.outputs.logAnalyticsWorkspaceId
output containerRegistryId string = containerRegistryModule.outputs.containerRegistryId
output vnetId string = virtualNetworkModule.outputs.vnetId
output vnetSubnetId string = virtualNetworkModule.outputs.vnetSubnetId
