function Register-AzureResourceProviderAndFeature
{
    [CmdletBinding()]
    param ()

    Write-Verbose -Message 'Registering Microsoft.ContainerService Provider' -Verbose

    Register-AzResourceProvider `
        -ProviderNamespace 'Microsoft.ContainerService'

    Write-Verbose -Message 'Registering Microsoft.ContainerService\AAD-V2 Feature' -Verbose

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

    Write-Verbose -Message "Looking up '$clusterAdminName' AAD Group" -Verbose

    $clusterAdminGroup = Get-AzADGroup -DisplayName $clusterAdminName

    if ($null -eq $clusterAdminGroup)
    {
        Write-Verbose -Message "Creating '$clusterAdminName' AAD Group" -Verbose

        $clusterAdminGroupObjectId = (New-AzADGroup `
                -DisplayName $clusterAdminName `
                -MailNickname $clusterAdminName).Id
    }
    else
    {
        $clusterAdminGroupObjectId = $clusterAdminGroup.Id
    }

    Write-Verbose -Message "AAD Group '$clusterAdminName' has Object Id '$($clusterAdminGroupObjectId -join ',')'" -Verbose

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

    New-AzResourceGroup `
        -Name $ResourceGroupName `
        -Location $Location `
        -Force

    New-AzResourceGroupDeployment `
        -ResourceGroupName $ResourceGroupName `
        -TemplateFile './src/infrastructure/azuredeploy.json' `
        -TemplateParameterObject @{
        name                       = $ResourceName
        clusterAdminGroupObjectIds = @( $clusterAdminGroupObjectIds )
    } -WhatIf:$WhatIf
}
