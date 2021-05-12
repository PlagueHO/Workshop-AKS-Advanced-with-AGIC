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

$deployAzureResourceGroupAndInfrastructure_Parameters = $PSBoundParameters + {
    ClusterAdminGroupObjectId = $clusterAdminGroupObjectId
    TemplatePath = $templateFile
}
$deployAzureResourceGroupAndInfrastructure_Parameters.Remove('Method')

Deploy-AzureResourceGroupAndInfrastructure @PSBoundParameters `
    -ClusterAdminGroupObjectId $clusterAdminGroupObjectId `
    -TemplateFile $TemplateFile