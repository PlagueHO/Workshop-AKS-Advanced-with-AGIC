[CmdletBinding()]
param (
    [Parameter()]
    [System.String]
    $BaseResourceName = 'mykube',

    [Parameter()]
    [System.String]
    $Location = 'eastus',

    [Parameter()]
    [ValidateSet('ARM','Bicep')]
    [System.String]
    $Method = 'ARM',

    [Parameter()]
    [switch]
    $WhatIf
)

Import-Module -Name '.\src\infrastructure\azuredeploy.utilities\' -Force

Register-AzureResourceProviderAndFeature -Verbose:$VerbosePreference
$clusterAdminGroupObjectId = New-ClusterAdminAadGroup -ResourceName $ResourceName -Verbose:$VerbosePreference

$templateFile = ($Method -eq 'ARM') ? './src/infrastructure/azuredeploy.json' : './src/infrastructure/main.bicep'
$resourceGroupName = "$($BaseResourceName)-$($Method.ToLower())-rg"
$resourceName = "$($BaseResourceName)$($Method.ToLower())"

Deploy-AzureResourceGroupAndInfrastructure `
    -ResourceGroupName $resourceGroupName `
    -ResourceName $resourceName `
    -Location $Location `
    -ClusterAdminGroupObjectId $clusterAdminGroupObjectId `
    -TemplateFile $templateFile
