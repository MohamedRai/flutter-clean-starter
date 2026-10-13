# Shared helpers for the scripts in this folder (Windows PowerShell 5.1+).
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

# Runs a native command and stops the script if it fails.
function Invoke-Step {
    param([Parameter(Mandatory)][string]$Command, [string[]]$Arguments = @())
    Write-Host "> $Command $($Arguments -join ' ')" -ForegroundColor Cyan
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

# Creates env/<flavor>.json from the committed examples (never overwrites).
function Initialize-EnvFiles {
    foreach ($flavor in 'dev', 'staging', 'prod') {
        $target = "env/$flavor.json"
        if (-not (Test-Path $target)) {
            Copy-Item "env/$flavor.example.json" $target
            Write-Host "created $target"
        }
    }
}

# Arguments that select a flavor: entry point, Android/iOS flavor, env file.
function Get-FlavorArgs([string]$Flavor) {
    return @('--flavor', $Flavor, '-t', "lib/main_$Flavor.dart",
        "--dart-define-from-file=env/$Flavor.json")
}

$Sources = @('lib', 'test', 'integration_test', 'tool')
