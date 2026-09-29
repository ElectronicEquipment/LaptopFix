# setup-git-hooks.ps1

$hooksDir = Join-Path $HOME ".git-hooks"

# Create hook directory
New-Item -ItemType Directory -Force -Path $hooksDir | Out-Null

# Set global hooks path
git config --global core.hooksPath "$hooksDir"

# Create pre-commit hook
$hookContent = @'
#!/usr/bin/env bash

git symbolic-ref -q HEAD >/dev/null || {
    echo "ERROR: committing on detached HEAD"
    exit 1
}
'@

$hookPath = Join-Path $hooksDir "pre-commit"
Set-Content -Path $hookPath -Value $hookContent -NoNewline

$prePushContent = @'
#!/usr/bin/env bash

git symbolic-ref -q HEAD >/dev/null || {
    echo "ERROR: pushing from detached HEAD"
    exit 1
}
'@

Set-Content -Path (Join-Path $hooksDir "pre-push") -Value $prePushContent -NoNewline

Write-Host "Installed global Git pre-commit and pre-push hook at $hookPath"
Write-Host "Git will now reject commits and pushes made from a detached HEAD."