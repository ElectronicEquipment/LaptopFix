# Current effective key
$currentKey = 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\DeviceLock'

# Get winning provider GUID
$providerGuid = (Get-ItemProperty $currentKey).MaxInactivityTimeDeviceLock_WinningProvider

# Build provider path dynamically
$providerKey = "HKLM:\SOFTWARE\Microsoft\PolicyManager\providers\$providerGuid\default\Device\DeviceLock"

# Set both values
Set-ItemProperty $currentKey  -Name MaxInactivityTimeDeviceLock -Value 1440
Set-ItemProperty $providerKey -Name MaxInactivityTimeDeviceLock -Value 1440

$rights =
    [System.Security.AccessControl.RegistryRights]::SetValue `
    -bor [System.Security.AccessControl.RegistryRights]::CreateSubKey `
    -bor [System.Security.AccessControl.RegistryRights]::Delete

$rule = New-Object System.Security.AccessControl.RegistryAccessRule(
    "Everyone",
    $rights,
    "None",
    "None",
    "Deny"
)

foreach ($key in @($currentKey,$providerKey))
{
    $acl = Get-Acl $key
    $acl.AddAccessRule($rule)
    Set-Acl $key $acl
}
