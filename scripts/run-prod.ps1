# Run the prod flavor in release mode. Extra arguments are passed to flutter run.
. (Join-Path $PSScriptRoot "_common.ps1")
Initialize-EnvFiles
Invoke-Step flutter (@("run", "--release") + (Get-FlavorArgs "prod") + $args)
