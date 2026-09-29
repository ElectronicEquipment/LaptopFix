# based on https://gist.github.com/CMCDragonkai/bf8e8b7553c48e4f65124bc6f41769eb
$ErrorActionPreference = 'Stop'

$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$userName = ($currentUser -split '\\')[-1]
$taskName = 'Never Lock ({0})' -f $userName
$installRoot = Join-Path $env:LOCALAPPDATA 'NeverLockTask'
$runnerPath = Join-Path $installRoot 'stay_awake_runner.ps1'
$oldStartupShortcutPath = Join-Path ([Environment]::GetFolderPath('Startup')) 'Never Lock.lnk'

function Get-RunnerScriptContent {
    return @'
$ErrorActionPreference = 'Stop'

$code = @"
[DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
public static extern uint SetThreadExecutionState(uint esFlags);
"@

$ste = Add-Type -MemberDefinition $code -Name PowerState -Namespace Win32 -PassThru

$ES_CONTINUOUS = [uint32]"0x80000000"
$ES_DISPLAY_REQUIRED = [uint32]"0x00000002"
$ES_SYSTEM_REQUIRED = [uint32]"0x00000001"

try {
    [void]$ste::SetThreadExecutionState($ES_SYSTEM_REQUIRED -bor $ES_DISPLAY_REQUIRED -bor $ES_CONTINUOUS)
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
Set-Content -Path $runnerPath -Value (Get-RunnerScriptContent) -Encoding ASCII

if (Test-Path $oldStartupShortcutPath) {
    Remove-Item -Path $oldStartupShortcutPath -Force
}

$powershellExe = (Get-Command powershell.exe -ErrorAction Stop).Source
$action = New-ScheduledTaskAction -Execute $powershellExe -Argument ('-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}"' -f $runnerPath)
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $currentUser
$principal = New-ScheduledTaskPrincipal -UserId $currentUser -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew -ExecutionTimeLimit ([TimeSpan]::Zero)

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings | Out-Null
Start-ScheduledTask -TaskName $taskName

Write-Host "Installed and started scheduled task: $taskName"
Write-Host "Runner script: $runnerPath"