# Install dependencies, mason bricks and generate code.
. (Join-Path $PSScriptRoot "_common.ps1")
Initialize-EnvFiles
Invoke-Step flutter @("pub", "get")
Invoke-Step flutter @("gen-l10n")
Invoke-Step dart @("run", "build_runner", "build")
Invoke-Step dart @("pub", "global", "activate", "mason_cli")
Invoke-Step mason @("get")
