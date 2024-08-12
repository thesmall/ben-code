function Add-AzureKeyVaultEntry {
    [CmdletBinding()]
    param(
        $VaultName,

        $SubscriptionId,

        $SecretName,

        $Value
    )

    $hashtable = @{}
    $jsonObject = $Value | ConvertFrom-Json
    $jsonObject.PSObject.Properties | ForEach-Object { $hashtable[$_.Name] = $_.Value }
    
    Set-Secret -Vault $VaultName -Name $SecretName -Secret $hashtable -Verbose
}

$VaultName      = 'VaultName'
$SubscriptionId = 'SubscriptionId'
$SecretName     = 'SecretName'
$value          = @"
{
    "password": "SuperSecretPassword123!",
    "username": "CoolGuy"
}
"@

# Install module Microsoft.PowerShell.SecretManagement
Install-Module 'Microsoft.PowerShell.SecretManagement' -Repository 'PSGallery' -AllowPrerelease
    
# Register vault for Secret Management

$registerParams = @{
    Name            = $VaultName
    ModuleName      = 'Az.KeyVault'
    VaultParameters = @{
        AZKVaultName   = "$VaultName"
        SubscriptionId = "$SubscriptionId" 
    }
}

Register-SecretVault @registerParams

$addKVParams = @{
    VaultName      = $VaultName
    SubscriptionId = $SubscriptionId
    SecretName     = $SecretName
    Value          = $value
}

Add-AzureKeyVaultEntry @addKVParams