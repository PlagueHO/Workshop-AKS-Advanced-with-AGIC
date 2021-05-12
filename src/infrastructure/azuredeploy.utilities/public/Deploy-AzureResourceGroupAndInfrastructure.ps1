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
        [System.String]
        $TemplateFile,

        [Parameter()]
        [switch]
        $WhatIf
    )

    Write-Verbose -Message "Create Resource Group '$ResourceGroupName' in '$Location'"

    New-AzResourceGroup `
        -Name $ResourceGroupName `
        -Location $Location `
        -Force

    Write-Verbose -Message "Deplying Resources to Resource Group '$ResourceGroupName' from '$TemplateFile'"
    Write-Verbose -Message "Cluster Admin Group Object Id is '$($clusterAdminGroupObjectId -join ',')'"

    New-AzResourceGroupDeployment `
        -ResourceGroupName $ResourceGroupName `
        -TemplateFile $TemplateFile `
        -TemplateParameterObject @{
            name                       = $ResourceName
            clusterAdminGroupObjectIds = @( $clusterAdminGroupObjectId )
        } -WhatIf:$WhatIf
}
