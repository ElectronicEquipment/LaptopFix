#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    # Optional. When omitted, use the directory containing this script.
    [string]$Root
)

$ErrorActionPreference = 'Stop'

try {
    if ([string]::IsNullOrWhiteSpace($Root)) {
        $Root = $PSScriptRoot
    }

    if ([string]::IsNullOrWhiteSpace($Root) -and $MyInvocation.MyCommand.Path) {
        $Root = Split-Path -Parent $MyInvocation.MyCommand.Path
    }

    if ([string]::IsNullOrWhiteSpace($Root)) {
        throw 'Could not determine the directory containing ensure_fix_task.ps1.'
    }

    $Root = [System.IO.Path]::GetFullPath($Root).TrimEnd('\')

    $SourceXmlPath    = Join-Path $Root 'Fix.xml'
    $ModifiedXmlPath  = Join-Path $Root 'Fix.modified.xml'
    $FixBatchPath     = Join-Path $Root 'fix.bat'
    $WorkingDirectory = $Root + '\'

    $TaskPath     = '\Fix\'
    $TaskName     = 'Fix'
    $FullTaskName = '\Fix\Fix'

    Write-Host "Checking scheduled task: $FullTaskName"

    $ExistingTask = Get-ScheduledTask `
        -TaskPath $TaskPath `
        -TaskName $TaskName `
        -ErrorAction SilentlyContinue

    if ($null -ne $ExistingTask -and $ExistingTask.Settings.Enabled) {
        Write-Host "Scheduled task '$FullTaskName' already exists and is enabled."
        exit 0
    }

    if ($null -eq $ExistingTask) {
        Write-Host "Scheduled task '$FullTaskName' does not exist."
    }
    else {
        Write-Host "Scheduled task '$FullTaskName' exists but is disabled."
    }

    if (-not (Test-Path -LiteralPath $SourceXmlPath -PathType Leaf)) {
        throw "Source XML file was not found: $SourceXmlPath"
    }

    if (-not (Test-Path -LiteralPath $FixBatchPath -PathType Leaf)) {
        throw "Batch file was not found: $FixBatchPath"
    }

    Write-Host "Loading source XML: $SourceXmlPath"

    $XmlDocument = New-Object System.Xml.XmlDocument
    $XmlDocument.PreserveWhitespace = $true
    $XmlDocument.Load($SourceXmlPath)

    # Match task action elements regardless of the Task Scheduler XML namespace.
    $CommandNodes = $XmlDocument.SelectNodes(
        "//*[local-name()='Exec']/*[local-name()='Command']"
    )

    $WorkingDirectoryNodes = $XmlDocument.SelectNodes(
        "//*[local-name()='Exec']/*[local-name()='WorkingDirectory']"
    )

    if ($null -eq $CommandNodes -or $CommandNodes.Count -eq 0) {
        throw "No <Exec><Command> element was found in '$SourceXmlPath'."
    }

    if ($null -eq $WorkingDirectoryNodes -or $WorkingDirectoryNodes.Count -eq 0) {
        throw "No <Exec><WorkingDirectory> element was found in '$SourceXmlPath'."
    }

    foreach ($CommandNode in $CommandNodes) {
        $CommandNode.InnerText = $FixBatchPath
    }

    foreach ($WorkingDirectoryNode in $WorkingDirectoryNodes) {
        $WorkingDirectoryNode.InnerText = $WorkingDirectory
    }

    # Save Fix.modified.xml as UTF-8 without a byte-order mark.
    $Utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
    $WriterSettings = New-Object System.Xml.XmlWriterSettings
    $WriterSettings.Encoding = $Utf8WithoutBom
    $WriterSettings.Indent = $true
    $WriterSettings.OmitXmlDeclaration = $false

    $XmlWriter = [System.Xml.XmlWriter]::Create(
        $ModifiedXmlPath,
        $WriterSettings
    )

    try {
        $XmlDocument.Save($XmlWriter)
    }
    finally {
        if ($null -ne $XmlWriter) {
            $XmlWriter.Dispose()
        }
    }

    Write-Host "Modified XML saved to: $ModifiedXmlPath"
    Write-Host "Command:             $FixBatchPath"
    Write-Host "Working directory:   $WorkingDirectory"

    # Register-ScheduledTask receives a .NET Unicode string. Remove the
    # file-level encoding declaration to avoid "unable to switch the encoding".
    $TaskXml = [System.IO.File]::ReadAllText(
        $ModifiedXmlPath,
        [System.Text.Encoding]::UTF8
    )
    $TaskXml = $TaskXml -replace '^\s*<\?xml[^?]*\?>\s*', ''

    # Ensure that the Task Scheduler folder exists.
    $Scheduler = New-Object -ComObject 'Schedule.Service'
    $Scheduler.Connect()
    $RootFolder = $Scheduler.GetFolder('\')

    try {
        $null = $Scheduler.GetFolder('\Fix')
    }
    catch {
        Write-Host 'Creating Task Scheduler folder: \Fix'
        $null = $RootFolder.CreateFolder('Fix')
    }

    Write-Host "Importing scheduled task: $FullTaskName"

    $null = Register-ScheduledTask `
        -TaskPath $TaskPath `
        -TaskName $TaskName `
        -Xml $TaskXml `
        -Force `
        -ErrorAction Stop

    $null = Enable-ScheduledTask `
        -TaskPath $TaskPath `
        -TaskName $TaskName `
        -ErrorAction Stop

    $ImportedTask = Get-ScheduledTask `
        -TaskPath $TaskPath `
        -TaskName $TaskName `
        -ErrorAction Stop

    if (-not $ImportedTask.Settings.Enabled) {
        throw "Scheduled task '$FullTaskName' was imported but is disabled."
    }

    Write-Host "Scheduled task '$FullTaskName' was imported and enabled successfully."
    exit 0
}
catch {
    [Console]::Error.WriteLine(
        "Failed to ensure scheduled task '\Fix\Fix': {0}",
        $_.Exception.Message
    )
    exit 1
}
