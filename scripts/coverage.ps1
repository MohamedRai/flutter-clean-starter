# Tests with coverage + the domain/data gate (80 %).
. (Join-Path $PSScriptRoot "_common.ps1")
Invoke-Step flutter @("test", "--coverage")
Invoke-Step dart @("run", "tool/coverage.dart", "--min", "80")
