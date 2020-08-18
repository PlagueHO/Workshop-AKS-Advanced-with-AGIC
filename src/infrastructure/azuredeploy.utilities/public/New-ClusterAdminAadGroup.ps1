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