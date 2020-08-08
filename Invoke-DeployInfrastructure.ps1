[CmdletBinding()]
param (
    [Parameter()]
    [System.String]
    $SubscriptionName = 'Customer',

    [Parameter()]
    [System.String]
    $ResourceGroupName = 'dsr-kube-rg',

    [Parameter()]
    [System.String]
    $ResourceName = 'dsrkube',

    [Parameter()]
    [System.String]
    $Location = 'eastus',

    [Parameter()]
    [switch]
    $WhatIf
)

Select-AzSubscription -SubscriptionName $SubscriptionName

Register-AzResourceProvider `
    -ProviderNamespace 'Microsoft.ContainerService'

Register-AzProviderFeature `
    -Feature 'AAD-V2' `
    -ProviderNamespace 'Microsoft.ContainerService'

New-AzResourceGroup `
    -Name $ResourceGroupName `
    -Location $Location

$clusterAdminGroupObjectIds = (New-AzADGroup `
    -DisplayName "${ResourceName}ClusterAdmin" `
    -MailNickname "${ResourceName}ClusterAdmin").Id

New-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile './src/infrastructure/azuredeploy.json' `
    -TemplateParameterObject @{
        name = $ResourceName
        clusterAdminGroupObjectIds = @( $clusterAdminGroupObjectIds )
    }
