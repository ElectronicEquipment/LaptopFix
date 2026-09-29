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

try {
    # Always create make_admin.bat beside this PowerShell script.
    $root = $PSScriptRoot

    if ([string]::IsNullOrWhiteSpace($root) -and $MyInvocation.MyCommand.Path) {
        $root = Split-Path -Parent $MyInvocation.MyCommand.Path
    }

    if ([string]::IsNullOrWhiteSpace($root)) {
        throw 'Could not determine the directory containing this script.'
    }

    $outputPath = Join-Path $root 'make_admin.bat'
    $currentUser = Get-ActiveConsoleUser

    # Percent signs need escaping when written into a batch file.
    $batchUser = $currentUser.Replace('%', '%%')

    $batchContent = @(
        '@echo off'
        'echo make_admin'
        ('net localgroup Administrators "{0}" /add' -f $batchUser)
    )

    # Set-Content with -Force overwrites an existing make_admin.bat.
    Set-Content -LiteralPath $outputPath -Value $batchContent -Encoding ASCII -Force

    Write-Host "Active console user: $currentUser"
    Write-Host "Created or overwritten: $outputPath"
    exit 0
}
catch {
    [Console]::Error.WriteLine(
        'Failed to create make_admin.bat: {0}',
        $_.Exception.Message
    )
    exit 1
}
