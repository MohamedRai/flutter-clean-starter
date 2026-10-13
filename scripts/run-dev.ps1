# Run the dev flavor. Extra arguments are passed to flutter run.
. (Join-Path $PSScriptRoot "_common.ps1")
Initialize-EnvFiles
Invoke-Step flutter (@("run") + (Get-FlavorArgs "dev") + $args)
