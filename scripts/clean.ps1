# Remove build outputs and reinstall packages.
. (Join-Path $PSScriptRoot "_common.ps1")
Invoke-Step flutter @("clean")
if (Test-Path coverage) { Remove-Item -Recurse -Force coverage }
Invoke-Step flutter @("pub", "get")
