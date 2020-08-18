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

Import-Module -Name '.\src\infrastructure\azuredeploy.utilities\' -Force

Register-AzureResourceProviderAndFeature -Verbose:$VerbosePreference
$clusterAdminGroupObjectId = New-ClusterAdminAadGroup -ResourceName $ResourceName -Verbose:$VerbosePreference
Deploy-AzureResourceGroupAndInfrastructure @PSBoundParameters -ClusterAdminGroupObjectId $clusterAdminGroupObjectId