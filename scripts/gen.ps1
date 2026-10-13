# Run code generation once (freezed, json, DI, routes, assets, l10n).
. (Join-Path $PSScriptRoot "_common.ps1")
Invoke-Step flutter @("gen-l10n")
Invoke-Step dart @("run", "build_runner", "build")
