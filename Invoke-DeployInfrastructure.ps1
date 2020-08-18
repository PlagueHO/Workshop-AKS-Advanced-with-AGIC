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

Import-Module -Name .\src\infrastructure\azuredeployutils.psm1 -Force

Register-AzureResourceProviderAndFeature
$clusterAdminGroupObjectId = New-ClusterAdminAadGroup -ResourceName $ResourceName
Deploy-AzureResourceGroupAndInfrastructure @PSBoundParameters -ClusterAdminGroupObjectId $clusterAdminGroupObjectId