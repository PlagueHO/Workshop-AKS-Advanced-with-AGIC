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

    Write-Verbose -Message 'Registering Microsoft.ContainerService\CustomKubeletIdentityPreview Feature'

    Register-AzProviderFeature `
        -Feature 'CustomKubeletIdentityPreview' `
        -ProviderNamespace 'Microsoft.ContainerService'
}
