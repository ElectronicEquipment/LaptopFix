#Requires -RunAsAdministrator

$ErrorActionPreference = 'Stop'

function Get-ActiveConsoleUser {
    $nativeCode = @'
using System;
using System.Runtime.InteropServices;

public static class TerminalServices
{
    [DllImport("kernel32.dll")]
    public static extern uint WTSGetActiveConsoleSessionId();
}
'@

    if (-not ('TerminalServices' -as [type])) {
        Add-Type -TypeDefinition $nativeCode
    }

    $consoleSessionId = [TerminalServices]::WTSGetActiveConsoleSessionId()

    if ($consoleSessionId -eq [uint32]::MaxValue) {
        throw 'No active physical-console session was found.'
    }

    $explorerProcesses = Get-CimInstance Win32_Process -Filter "Name = 'explorer.exe'" |
        Where-Object { $_.SessionId -eq $consoleSessionId }

    if (-not $explorerProcesses) {
        throw "No explorer.exe process was found in console session $consoleSessionId."
    }

    foreach ($explorerProcess in $explorerProcesses) {
        $owner = Invoke-CimMethod -InputObject $explorerProcess -MethodName GetOwner

        if ($owner.ReturnValue -eq 0 -and -not [string]::IsNullOrWhiteSpace($owner.User)) {
            if ([string]::IsNullOrWhiteSpace($owner.Domain)) {
                return $owner.User
            }

            return '{0}\{1}' -f $owner.Domain, $owner.User
        }
    }

    throw "Could not determine the user logged on to console session $consoleSessionId."
}

function Get-UserProfilePath {
    param(
        [Parameter(Mandatory)]
        [string]$UserName
    )

    $account = New-Object System.Security.Principal.NTAccount($UserName)
    $sid = $account.Translate([System.Security.Principal.SecurityIdentifier]).Value
    $escapedSid = $sid.Replace("'", "''")
    $profile = Get-CimInstance Win32_UserProfile -Filter "SID = '$escapedSid'"

    if ($null -eq $profile) {
        throw "Could not find a Windows profile for $UserName."
    }

    if ([string]::IsNullOrWhiteSpace($profile.LocalPath)) {
        throw "The Windows profile for $UserName has no local profile path."
    }

    return $profile.LocalPath
}

# Identify the user logged on to the physical console, independently of the
# administrator account that is running this installer.
$currentUser = Get-ActiveConsoleUser
$userName = ($currentUser -split '\\')[-1]
$taskName = 'Never Lock ({0})' -f $userName

Write-Host "Active console user: $currentUser"
Write-Host "Scheduled task name: $taskName"

# Register only once. Do not replace, modify, or start another instance when
# this user's task already exists.
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($null -ne $existingTask) {
    Write-Host "Scheduled task already exists: $taskName"
    Write-Host 'No changes were made.'
    exit 0
}

# Use the logged-on user's profile, not the elevated administrator's
# LOCALAPPDATA environment variable.
$userProfilePath = Get-UserProfilePath -UserName $currentUser
$userLocalAppData = Join-Path $userProfilePath 'AppData\Local'
$installRoot = Join-Path $userLocalAppData 'NeverLockTask'
$runnerPath = Join-Path $installRoot 'stay_awake_runner.ps1'
$oldStartupShortcutPath = Join-Path $userProfilePath 'AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Never Lock.lnk'

function Get-RunnerScriptContent {
    return @'
$ErrorActionPreference = 'Stop'

$code = @"
[DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
public static extern uint SetThreadExecutionState(uint esFlags);
"@

$ste = Add-Type -MemberDefinition $code -Name PowerState -Namespace Win32 -PassThru
$ES_CONTINUOUS       = [uint32]"0x80000000"
$ES_DISPLAY_REQUIRED = [uint32]"0x00000002"
$ES_SYSTEM_REQUIRED  = [uint32]"0x00000001"

try {
    [void]$ste::SetThreadExecutionState(
        $ES_SYSTEM_REQUIRED -bor $ES_DISPLAY_REQUIRED -bor $ES_CONTINUOUS
    )

    while ($true) {
        Start-Sleep -Seconds 3600
    }
}
finally {
    [void]$ste::SetThreadExecutionState($ES_CONTINUOUS)
}
'@
}

New-Item -ItemType Directory -Path $installRoot -Force | Out-Null
Set-Content -LiteralPath $runnerPath -Value (Get-RunnerScriptContent) -Encoding ASCII

if (Test-Path -LiteralPath $oldStartupShortcutPath) {
    Remove-Item -LiteralPath $oldStartupShortcutPath -Force
}

$powershellExe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$cmdExe = Join-Path $env:SystemRoot 'System32\conhost.exe'
$action = New-ScheduledTaskAction `
    -Execute $cmdExe `
    -Argument ('--headless "{1}" -NoLogo -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}"' -f $runnerPath, $powershellExe)

$trigger = New-ScheduledTaskTrigger -AtLogOn -User $currentUser
$principal = New-ScheduledTaskPrincipal -UserId $currentUser -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -MultipleInstances IgnoreNew `
    -ExecutionTimeLimit ([TimeSpan]::Zero)

Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Settings $settings |
    Out-Null

# Start the task only immediately after its first registration.
Start-ScheduledTask -TaskName $taskName

Write-Host "Installed and started scheduled task: $taskName"
Write-Host "Task user: $currentUser"
Write-Host "Runner script: $runnerPath"
