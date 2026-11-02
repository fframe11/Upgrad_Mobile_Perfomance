# Thermal Mitigation & Background Battery Saver Module
param(
    [string]$AdbPath = "",
    [string]$DeviceId = ""
)

$PSScriptRootCurrent = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$PSScriptRootCurrent\00-detect-environment.ps1"

if (-not $AdbPath) { $AdbPath = Get-AdbExecutable }
if (-not $DeviceId) { $DeviceId = Get-ConnectedDevice -AdbPath $AdbPath }

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [5/7] THERMAL MITIGATION & BACKGROUND ENERGY MANAGEMENT" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Disable 24/7 background RF scanning (Wi-Fi & Bluetooth background location pings)
Write-Host "1. Disabling Continuous Background Wi-Fi & Bluetooth Scanning..." -NoNewline
& $AdbPath -s $DeviceId shell settings put global wifi_scan_always_enabled 0
& $AdbPath -s $DeviceId shell settings put global ble_scan_always_enabled 0
& $AdbPath -s $DeviceId shell settings put system nearby_scanning_enabled 0
& $AdbPath -s $DeviceId shell settings put global send_action_app_error 0
Write-Host " [OK]" -ForegroundColor Green

# 2. Restrict aggressive background battery drainers
$configPath = Join-Path (Split-Path -Parent $PSScriptRootCurrent) "config\high-drain-apps.json"
if (Test-Path $configPath) {
    $drainConfig = Get-Content -Raw $configPath | ConvertFrom-Json
    Write-Host "2. Applying Restricted Standby Buckets to High-Drain Third-Party Apps..."
    foreach ($pkg in $drainConfig.packages) {
        $installed = & $AdbPath -s $DeviceId shell pm path $pkg 2>$null
        if ($installed) {
            & $AdbPath -s $DeviceId shell cmd appops set $pkg RUN_IN_BACKGROUND ignore 2>$null
            & $AdbPath -s $DeviceId shell am set-standby-bucket $pkg restricted 2>$null
            Write-Host "   -> Restricted: $pkg" -ForegroundColor Yellow
        }
    }
}

# 3. Trim Dirty File System Caches
Write-Host "3. Trimming Dirty File System Caches across all packages..." -NoNewline
& $AdbPath -s $DeviceId shell pm trim-caches 999G 2>$null
Write-Host " [OK]" -ForegroundColor Green

Write-Host "`nThermal mitigations and background restrictions active!" -ForegroundColor Green
