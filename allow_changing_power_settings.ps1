
$key = "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Power"

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
