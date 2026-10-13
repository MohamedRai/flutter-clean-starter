# Run unit and widget tests.
. (Join-Path $PSScriptRoot "_common.ps1")
Invoke-Step flutter (@("test") + $args)
