# Format all Dart sources. Pass -Check to fail on unformatted files (CI).
param([switch]$Check)
. (Join-Path $PSScriptRoot "_common.ps1")
$formatArgs = @("format")
if ($Check) { $formatArgs += "--set-exit-if-changed" }
Invoke-Step dart ($formatArgs + $Sources)
