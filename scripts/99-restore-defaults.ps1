# System Rollback & Restore Defaults Module
param(
    [string]$AdbPath = "",
    [string]$DeviceId = ""
)

$PSScriptRootCurrent = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$PSScriptRootCurrent\00-detect-environment.ps1"

if (-not $AdbPath) { $AdbPath = Get-AdbExecutable }
if (-not $DeviceId) { $DeviceId = Get-ConnectedDevice -AdbPath $AdbPath }

Write-Host "==========================================================" -ForegroundColor Red
Write-Host " [ROLLBACK] RESTORING ORIGINAL ANDROID / SAMSUNG SETTINGS" -ForegroundColor Red
Write-Host "==========================================================" -ForegroundColor Red

# 1. Re-enable all debloated packages
$configPath = Join-Path (Split-Path -Parent $PSScriptRootCurrent) "config\debloat-packages.json"
if (Test-Path $configPath) {
    $config = Get-Content -Raw $configPath | ConvertFrom-Json
    Write-Host "1. Re-enabling debloated OEM packages..."
    foreach ($item in $config.packages) {
        $pkg = $item.package
        & $AdbPath -s $DeviceId shell pm enable $pkg 2>$null | Out-Null
        Write-Host "   -> Enabled: $pkg" -ForegroundColor Green
    }
}

# 2. Reset Animation Scales to default 1.0x
Write-Host "2. Resetting animation scales to default (1.0x)..." -NoNewline
& $AdbPath -s $DeviceId shell settings put global window_animation_scale 1.0
& $AdbPath -s $DeviceId shell settings put global transition_animation_scale 1.0
& $AdbPath -s $DeviceId shell settings put global animator_duration_scale 1.0
Write-Host " [OK]" -ForegroundColor Green

# 3. Re-enable GPU window blurs
Write-Host "3. Re-enabling GPU window blurs..." -NoNewline
& $AdbPath -s $DeviceId shell settings put global disable_window_blurs 0
& $AdbPath -s $DeviceId shell settings put secure accessibility_reduce_transparency 0
Write-Host " [OK]" -ForegroundColor Green

# 4. Reset Private DNS to Automatic (default)
Write-Host "4. Resetting Private DNS to Automatic..." -NoNewline
& $AdbPath -s $DeviceId shell settings put global private_dns_mode opportunistic
& $AdbPath -s $DeviceId shell settings put global private_dns_specifier ""
Write-Host " [OK]" -ForegroundColor Green

# 5. Reset Display Refresh Rate to Adaptive (Default on supported panels)
Write-Host "5. Resetting display refresh rate mode to Adaptive/Default..." -NoNewline
& $AdbPath -s $DeviceId shell settings delete system refresh_rate_mode 2>$null
& $AdbPath -s $DeviceId shell settings delete system peak_refresh_rate 2>$null
& $AdbPath -s $DeviceId shell settings delete system min_refresh_rate 2>$null
Write-Host " [OK]" -ForegroundColor Green

Write-Host "`nAll settings have been successfully restored to factory defaults!" -ForegroundColor Green
