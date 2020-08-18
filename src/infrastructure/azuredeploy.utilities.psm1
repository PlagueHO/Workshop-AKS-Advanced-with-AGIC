function Register-AzureResourceProviderAndFeature
{
    [CmdletBinding()]
    param ()

    Write-Verbose -Message 'Registering Microsoft.ContainerService Provider'

    Register-AzResourceProvider `
        -ProviderNamespace 'Microsoft.ContainerService'

    Write-Verbose -Message 'Registering Microsoft.ContainerService\AAD-V2 Feature'

    Register-AzProviderFeature `
        -Feature 'AAD-V2' `
        -ProviderNamespace 'Microsoft.ContainerService'
}


function New-ClusterAdminAadGroup
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param (
        [Parameter()]
        [System.String]
        $ResourceName = 'mykube'
    )

    $clusterAdminName = "${ResourceName}ClusterAdmin"

    Write-Verbose -Message "Looking up '$clusterAdminName' AAD Group"

    $clusterAdminGroup = Get-AzADGroup -DisplayName $clusterAdminName

    if ($null -eq $clusterAdminGroup)
    {
        Write-Verbose -Message "Creating '$clusterAdminName' AAD Group"

        $clusterAdminGroupObjectId = (New-AzADGroup `
                -DisplayName $clusterAdminName `
                -MailNickname $clusterAdminName).Id
    }
    else
    {
        $clusterAdminGroupObjectId = $clusterAdminGroup.Id
    }

    Write-Verbose -Message "AAD Group '$clusterAdminName' has Object Id '$($clusterAdminGroupObjectId -join ',')'"

    return $clusterAdminGroupObjectId
}

function Deploy-AzureResourceGroupAndInfrastructure
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Location,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $clusterAdminGroupObjectId,

        [Parameter()]
        [switch]
        $WhatIf
    )

    Write-Verbose -Message "Create Resource Group '$ResourceGroupName' in '$Location'"

    New-AzResourceGroup `
        -Name $ResourceGroupName `
        -Location $Location `
        -Force

    Write-Verbose -Message "Deplying Resources to Resource Group '$ResourceGroupName' from './src/infrastructure/azuredeploy.json'"
    Write-Verbose -Message "Cluster Admin Group Object Id is '$($clusterAdminGroupObjectId -join ',')'"

    New-AzResourceGroupDeployment `
        -ResourceGroupName $ResourceGroupName `
        -TemplateFile './src/infrastructure/azuredeploy.json' `
        -TemplateParameterObject @{
            name                       = $ResourceName
            clusterAdminGroupObjectIds = @( $clusterAdminGroupObjectId )
        } -WhatIf:$WhatIf
}
