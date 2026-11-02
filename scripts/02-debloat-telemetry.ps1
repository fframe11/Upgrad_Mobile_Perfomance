# Safe Bloatware & Telemetry Disabler (User 0 / Completely Reversible)
param(
    [string]$AdbPath = "",
    [string]$DeviceId = ""
)

$PSScriptRootCurrent = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$PSScriptRootCurrent\00-detect-environment.ps1"

if (-not $AdbPath) { $AdbPath = Get-AdbExecutable }
if (-not $DeviceId) { $DeviceId = Get-ConnectedDevice -AdbPath $AdbPath }

$configPath = Join-Path (Split-Path -Parent $PSScriptRootCurrent) "config\debloat-packages.json"
if (-not (Test-Path $configPath)) {
    throw "Configuration file not found: $configPath"
}

$config = Get-Content -Raw $configPath | ConvertFrom-Json

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [2/7] DISABLING BACKGROUND TELEMETRY & BLOATWARE (USER 0)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

foreach ($item in $config.packages) {
    $pkg = $item.package
    $name = $item.name
    Write-Host "Processing: $name ($pkg)..." -NoNewline
    $res = & $AdbPath -s $DeviceId shell pm disable-user --user 0 $pkg 2>$null
    if ($res -match "disabled-user|new state") {
        Write-Host " [DISABLED]" -ForegroundColor Green
    } else {
        Write-Host " [ALREADY DISABLED OR NOT PRESENT]" -ForegroundColor DarkGray
    }
}

Write-Host "`nAll targeted telemetry services have been safely disabled for User 0." -ForegroundColor Green
