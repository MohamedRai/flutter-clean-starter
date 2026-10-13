# Regenerate code on every change.
. (Join-Path $PSScriptRoot "_common.ps1")
Invoke-Step dart @("run", "build_runner", "watch")
