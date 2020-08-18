[CmdletBinding()]
param (
    [Parameter()]
    [System.String]
    $ResourceGroupName = 'kubernetes-rg',

    [Parameter()]
    [System.String]
    $ResourceName = 'mykube',

    [Parameter()]
    [System.String]
    $Location = 'eastus',

    [Parameter()]
    [switch]
    $WhatIf
)

Register-AzResourceProvider `
    -ProviderNamespace 'Microsoft.ContainerService'

Register-AzProviderFeature `
    -Feature 'AAD-V2' `
    -ProviderNamespace 'Microsoft.ContainerService'

New-AzResourceGroup `
    -Name $ResourceGroupName `
    -Location $Location `
    -Force

$clusterAdminName = "${ResourceName}ClusterAdmin"
$clusterAdminGroupObjectIds = (New-AzADGroup `
    -DisplayName $clusterAdminName `
    -MailNickname $clusterAdminName).Id

New-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile './src/infrastructure/azuredeploy.json' `
    -TemplateParameterObject @{
        name = $ResourceName
        clusterAdminGroupObjectIds = @( $clusterAdminGroupObjectIds )
    }
