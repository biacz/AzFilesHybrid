[CmdletBinding()]
param (
    [string]$SubscriptionId,
    [string]$ResourceGroupName,
    [string]$StorageAccountName
)

$SamAccountName = $StorageAccountName
$DomainAccountType = "ComputerAccount"
$OuDistinguishedName = ""
$EncryptionType = "AES256"
$KeyVaultSub = ""
$tenantId = ""

Install-Module Az.KeyVault -Force -Confirm:$true -Verbose:$false
Import-Module ./AzFilesHybrid -Verbose:$false -force

# Disconnecting from Azure to refresh token
write-verbose -verbose -message "Disconnecting from Azure to refresh token"
Disconnect-AzAccount

# Connecting again
write-verbose -verbose -message "Connecting again"
Connect-AzAccount -Identity -Subscription $KeyVaultSub -Tenant $tenantId

try {
    # Select the target subscription for the current session
    Set-AzContext -Subscription $KeyVaultSub -Tenant $tenantId
}
catch {
    write-error -message "Error switching to keyvault subscription: $($_.Exception)"
}

try {
    # create AD creds
    $VaultName = ""
    $clientSecretName = ""
    $secret = Get-AzKeyVaultSecret -VaultName $VaultName -Name $clientSecretName -AsPlainText
    [securestring]$secStringPassword = ConvertTo-SecureString $secret -AsPlainText -Force
    write-verbose -verbose -message "create AD creds"
    [pscredential]$ADCredentials = New-Object System.Management.Automation.PSCredential ($clientSecretName, $secStringPassword)
    # Selecting Storage Account Subscription
    write-verbose -verbose -message "Selecting Storage Account Subscription"
} catch {
    Write-Error -Message "Error querying keyvault and setting ADcreds: $($_.Exception)"
}

try {
    # Select the target subscription for the current session
    Set-AzContext -subscription $SubscriptionId -tenant $tenantId
}
catch {
    write-error -message "Error switching to storage account subscription: $($_.Exception)"
}

Join-AzStorageAccount `
        -ResourceGroupName $ResourceGroupName `
        -StorageAccountName $StorageAccountName `
        -SamAccountName $SamAccountName `
        -DomainAccountType $DomainAccountType `
        -OrganizationalUnitDistinguishedName $OuDistinguishedName `
        -EncryptionType $EncryptionType `
        -ADCredentials $ADCredentials `
        -OverwriteExistingADObject `
        -verbose

# Setting default NTFS permissions
write-verbose -verbose -message "Setting default NTFS permissions"
$defaultPermission = "StorageFileDataSmbShareContributor"
$account = Set-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName -DefaultSharePermission $defaultPermission
$account.AzureFilesIdentityBasedAuth

# Map the drive using the SAS key
# Set permissions using icacls for the storage admin group
# Disconnect the drive again

Debug-AzStorageAccountAuth -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -Verbose