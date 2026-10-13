# Static analysis (must report 0 issues).
. (Join-Path $PSScriptRoot "_common.ps1")
Invoke-Step flutter @("analyze")
