
$key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

$acl = Get-Acl $key

$rule = New-Object System.Security.AccessControl.RegistryAccessRule(
    "Everyone",
    "FullControl",
    "ContainerInherit,ObjectInherit",
    "None",
    "Deny"
)

$acl.AddAccessRule($rule)
Set-Acl $key $acl
